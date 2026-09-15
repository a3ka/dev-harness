#!/usr/bin/env bash
# Канарейка производительности v6 контракта 024 (корневой срез манифеста,
# РАЗРЕШИЛ владелец 2026-09-15 путь 1). Приёмка path-1, пункт 5: срез обязан
# подешеветь или остаться в кратно-той же цене, но НЕ регрессировать кратно.
#
# МЕРА (самокалибрующаяся, та же среда — та же машина прогона): на toy из
# 300 tracked + 300 untracked файлов (200 из них ПОД ignore-правилами —
# после среза нога-2 хеширует и их, это заявленная цена корневого реза)
# меряются:
#   t_raw   — время голого `git status --porcelain -uall -z` в toy (мера v5);
#   t_check — время `check_no_leak.sh --check` на том же toy.
# ПОРОГ: t_check ≤ 3 × t_raw + 3 c. Сейчас (porcelain-формы, HEAD 492ac4d)
# субъект чуть дороже голого porcelain (dot-git walk + ls-files -v + find);
# после среза — per-file sha256 по ~600 путям: сотни spawn'ов по ~1 мс
# укладываются в порог с запасом. Числа печатается в stderr — «до/после»
# сверяет оркестратор по выводам прогонов (числа из вывода, не из головы).
#
# Канарейка зелёная ДО и ПОСЛЕ среза (это контроль цены, не краснота).
# Имя canary_* ВНЕ case_*-глоба раннера НАМЕРЕННО (И-11 контракта 024);
# прямые запуски — как у red_/probe_ семьи.
#
# Коды возврата: 0 — чистый проход в пороге; 1 — именованный отказ (снимок/
#   сверка отказали, ложная тревога на чистом toy, порог превышен).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh\n' >&2
  exit 1
}

P_CHISTO='основной чекаут чист'
P_ZAGR='основной чекаут загрязнён'

WORK="$(mktemp -d /tmp/canary024-v6-vremya.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"

run_subj() {
  local cwd="$1"; shift
  SUBJ_OUT="$( cd "$cwd" && bash "$SUBJ" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }
fail() { printf 'ОТКАЗ %s: %s\n' "$1" "$2" >&2; exit 1; }

tgit() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

now_ms() { date +%s%N | awk '{printf "%d", $1 / 1000000}'; }

# ── toy: 300 tracked + 300 untracked (200 под ignore-правилами) ────────────────
K="$WORK/toy_${RANDOM}"
mkdir -p "$K"
printf 'root file\n' > "$K/tracked.txt"
printf 'ig*\nep*\n' > "$K/.gitignore"
tgit init -q -b main "$K"
i=0
while [ "$i" -lt 300 ]; do
  printf 'tracked payload %d\n' "$i" > "$K/tr_${i}.txt"
  i=$((i + 1))
done
tgit -C "$K" add -A
tgit -C "$K" commit -q -m 'toy main'
printf 'ep*\n' >> "$K/.git/info/exclude"
i=0
while [ "$i" -lt 100 ]; do
  printf 'plain untracked %d\n' "$i" > "$K/ut_${i}.txt"
  printf 'ignored untracked %d\n' "$i" > "$K/ig_${i}.txt"
  printf 'excluded untracked %d\n' "$i" > "$K/ep_${i}.txt"
  i=$((i + 1))
done

# ── t_raw: голый porcelain той же мерой, что источник v5 ───────────────────────
T0="$(now_ms)"
tgit -C "$K" status --porcelain -uall -z --no-renames --ignore-submodules=none >/dev/null 2>&1
RAW_RC=$?
T1="$(now_ms)"
T_RAW=$((T1 - T0))
[ "$RAW_RC" -eq 0 ] || fail "git status toy" "rc=$RAW_RC — мера t_raw не получена"

# ── субъект: снимок + сверка на ЧИСТОМ toy (двойная роль: smoke цены) ──────────
T0="$(now_ms)"
run_subj "$K" --snapshot "$K"
T1="$(now_ms)"
T_SNAP=$((T1 - T0))
[ "$SUBJ_RC" -eq 0 ] || fail "снимок" "снимок отказал rc=$SUBJ_RC. Вывод: $SUBJ_OUT"

T0="$(now_ms)"
run_subj "$K" --check "$K"
T1="$(now_ms)"
T_CHECK=$((T1 - T0))
[ "$SUBJ_RC" -eq 0 ] || fail "сверка" "ложная тревога на чистом toy: rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail "сверка" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
if has "$P_ZAGR"; then
  fail "сверка" "ложное «$P_ZAGR» на чистом toy. Вывод: $SUBJ_OUT"
fi

# ── порог: t_check ≤ 3 × t_raw + 3000 мс ───────────────────────────────────────
LIMIT=$((3 * T_RAW + 3000))
printf 'canary_vremya_024: t_raw(git status)=%d мс, t_snapshot=%d мс, t_check=%d мс, порог=%d мс (3xt_raw+3000)\n' \
  "$T_RAW" "$T_SNAP" "$T_CHECK" "$LIMIT" >&2
if [ "$T_CHECK" -gt "$LIMIT" ]; then
  fail "порог производительности" \
    "t_check=${T_CHECK} мс > порог=${LIMIT} мс (3xt_raw+3000; t_raw=${T_RAW} мс) — корневой срез регрессировал цену кратно"
fi

printf 'canary_vremya_024: ок — чистый toy, rc 0 «%s», t_check=%d мс в пороге %d мс\n' "$P_CHISTO" "$T_CHECK" "$LIMIT" >&2
exit 0
