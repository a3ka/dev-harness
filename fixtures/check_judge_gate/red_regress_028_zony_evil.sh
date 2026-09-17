#!/usr/bin/env bash
# Регресс-пара контракта 028 (предъявление 3/4, Н-98): инвариант
# check_no_leak.sh:638-641 — «НЕ весь .zones/ — ЛЮБЫЕ другие пути под .zones/
# остаются в манифесте и утечки туда ловятся» — ПЕРЕЖИВАЕТ перенос сессионного
# HOME наружу чекаута. Замороженный carve-out :642-647 — не предмет 028 и не
# правится; проба стоит на страже, что новый канал исключения (внешний HOME)
# не ослепил детектор на evil-классе ВНУТРИ .zones/.
#
# ПРИВЯЗКА К ВЕТВЯМ КОДА (Н-39): ветка — case-пропуск emit_untracked_manifest
# (check_no_leak.sh:642-647, заморожено 024). Входы-утечки: .zones/x/agent/evil.txt
# + .zones/x/logs/evil.bin — оба ВНЕ четырёх именных паттернов (замер
# case-глобами, контракт 028 §Боль).
#
# ТРИ КОНТРОЛЯ (полярности — по прецеденту red_info_refs_drift_024.sh):
#   1 (честный оракул ловит): снимок игрушки → посадить ОБЕ утечки → --check
#      rc 1 «основной чекаут загрязнён», ОБА пути названы. Зелёный СЕГОДНЯ и
#      обязан остаться зелёным ПОСЛЕ предмета — это регресс-инвариант :638-641.
#   2 (без утечки чисто): другая игрушка, снимок → сверка → rc 0 «чисто» —
#      детектор не красит пустоту.
#   3 (красное предъявление против стаба «глушить .zones целиком по профилю»):
#      sed-копия оракула в игрушке с пропуском, расширенным до `.zones/*`
#      (объявлена здесь — прецедент А-156: подставной объявлен в исходнике),
#      на ТОМ ЖЕ входе контроля 1 даёт rc 0 — дефект стаба наблюдаем РОВНО на
#      этом входе (evil-класс невидим стабу, виден оракулу). Проба обязана
#      различать: если «реализацией» 028 станет глушение .zones целиком,
#      контроль 1 краснеет поимённо.
#
# Коды возврата: 0 — все три контроля; 1 — именованный отказ (оракул ослеп на
# evil-классе — регрессия инварианта :638-641, ИЛИ стаб-симуляция неверна).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh\n' >&2
  exit 1
}

P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'

WORK="$(mktemp -d /tmp/red028-zony-evil.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/snaps"
export TMPDIR="$WORK/snaps"                  # снимки — в скратч прогона

ok()   { printf '  ok   %s (%s)\n' "$1" "$2" >&2; }
fail() { printf 'ОТКАЗ %s (%s): %s\n' "$1" "$2" "$3" >&2; exit 1; }

run_subj() {  # <скрипт> <cwd> <аргументы...> — rc без пайпов (Н-84/Н-85)
  local script="$1" cwd="$2"; shift 2
  SUBJ_OUT="$( cd "$cwd" && bash "$script" "$@" 2>&1 )" && SUBJ_RC=0 || SUBJ_RC=$?
}
has() { printf '%s\n' "$SUBJ_OUT" | grep -qF -- "$1"; }

mk_main() {  # <каталог> — живой git-чекаут игрушки
  local t="$1"
  git init -q "$t"
  git -C "$t" -c user.name=probe -c user.email=probe@invalid commit \
    --allow-empty -qm init
}

# ─── контроль 1: честный оракул ловит evil-класс под .zones ПОИМЁННО ──────────
K1="$WORK/v1_evil_${RANDOM}"
mk_main "$K1"
run_subj "$SUBJ" "$K1" --snapshot "$K1"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-1 "снимок" "rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
mkdir -p "$K1/.zones/x/agent" "$K1/.zones/x/logs"
printf 'secret %s\n' "$RANDOM" > "$K1/.zones/x/agent/evil.txt"
printf 'bin %s\n'   "$RANDOM" > "$K1/.zones/x/logs/evil.bin"
run_subj "$SUBJ" "$K1" --check "$K1"
[ "$SUBJ_RC" -eq 1 ] || fail контроль-1 "evil-класс" \
  "rc=$SUBJ_RC (ожидался 1) — инвариант :638-641 нарушен: .zones-утечки больше не ловятся. Вывод: $SUBJ_OUT"
has "$P_ZAGR" || fail контроль-1 "evil-класс" "нет фразы «$P_ZAGR». Вывод: $SUBJ_OUT"
has ".zones/x/agent/evil.txt" || fail контроль-1 "evil-класс" \
  "путь .zones/x/agent/evil.txt не назван. Вывод: $SUBJ_OUT"
has ".zones/x/logs/evil.bin" || fail контроль-1 "evil-класс" \
  "путь .zones/x/logs/evil.bin не назван. Вывод: $SUBJ_OUT"
ok контроль-1 "обе .zones-утечки ловятся rc 1 ПОИМЁННО (инвариант :638-641 жив)"

# ─── контроль 2: без утечки — чисто ───────────────────────────────────────────
K2="$WORK/v2_chisto_${RANDOM}"
mk_main "$K2"
run_subj "$SUBJ" "$K2" --snapshot "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "снимок" "rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
run_subj "$SUBJ" "$K2" --check "$K2"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-2 "чистый вход" "rc=$SUBJ_RC (ожидался 0). Вывод: $SUBJ_OUT"
has "$P_CHISTO" || fail контроль-2 "чистый вход" "нет маркера «$P_CHISTO». Вывод: $SUBJ_OUT"
ok контроль-2 "игрушка без утечек: rc 0 «чисто»"

# ─── контроль 3: стаб «глушить .zones целиком» слеп РОВНО на этом входе ───────
# Копия оракула с расширенным пропуском: перед первым именным паттерном :643
# вставляется `.zones/*) continue ;;` — симуляция «решения», глушащего .zones
# по профилю целиком. Объявлена в исходнике пробы (прецедент А-156).
STUB="$WORK/stub-check-no-leak.sh"
sed 's|^      \.zones/\*/agent/\*\.db-wal) continue ;;|      .zones/*) continue ;; # СТАБ-028: глушить целиком\n      .zones/*/agent/*.db-wal) continue ;;|' \
  "$SUBJ" > "$STUB"
grep -q 'СТАБ-028' "$STUB" || fail контроль-3 "стаб-симуляция" \
  'sed-вставка не применилась — якорь :643 ушёл, проба требует обновления по коду'
chmod +x "$STUB"
K3="$WORK/v3_stab_${RANDOM}"
mk_main "$K3"
run_subj "$STUB" "$K3" --snapshot "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "снимок стаба" "rc=$SUBJ_RC. Вывод: $SUBJ_OUT"
mkdir -p "$K3/.zones/x/agent" "$K3/.zones/x/logs"
printf 'secret %s\n' "$RANDOM" > "$K3/.zones/x/agent/evil.txt"
printf 'bin %s\n'   "$RANDOM" > "$K3/.zones/x/logs/evil.bin"
run_subj "$STUB" "$K3" --check "$K3"
[ "$SUBJ_RC" -eq 0 ] || fail контроль-3 "стаб обязан быть слеп" \
  "rc=$SUBJ_RC (ожидался 0) — стаб-симуляция ведёт себя НЕ как глушение .zones, предъявление ничего не доказывает. Вывод: $SUBJ_OUT"
ok контроль-3 "стаб «глушить .zones целиком» слеп на ТОМ ЖЕ входе (rc 0) — проба различает честное (контроль 1) от стаба поимённо"

printf 'red_regress_028_zony_evil: 3 контроля зелены (evil-класс под .zones ловим rc 1 поимённо; стаб целиком-глушения слеп ровно на этом входе)\n' >&2
exit 0
