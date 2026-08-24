#!/usr/bin/env bash
# Барьер приёмки judge_gate (контракт 008 + контракт 009 fail-fast, тир-1).
#
# ПИНИТЫ (008): judge_gate ОБЯЗАН
#   (а) найти и звать `check_ci_gate` (маркер FAKE);
#   (б) передать ему аргумент `$1` (rc=0 только при exact-matching PASS_SHA);
#   (в) пропустить вердикт fake в свой RC;
#   (г) на зелёном напечатать «OK».
#
# ПИНИТЫ (009, поток A, Н-41): при `--fail-fast[=<N>]` judge_gate ОБЯЗАН
#   (а) запустить check_ci_gate через `timeout --foreground TBOX` (TBOX=540 по умолчанию,
#       N — натуральное > 0);
#   (б) rc=124 → дословно `FAIL-FAST: превышен тайм-бокс N с`, RC=1;
#   (в) иначе — проброс RC;
#   (г) rc=0 → «OK».
#   Защиты (RC=1 с названной причиной):
#     - `command -v timeout` пусто → дословно `FAIL-FAST: timeout не найден`;
#     - `--fail-fast=N` с N≤0 или N не целое → дословно
#       `FAIL-FAST: тайм-бокс должен быть > 0 (дано: <N>)`.
#
# Коды возврата: 0 — зелены, 1 — ветвь провалена, 2 — нечем проверить.
#
# КРАСНОЕ ПРОТИВ ТЕКУЩЕГО ДЕРЕВА: 008-judge_gate.sh НЕ реализует --fail-fast →
# пробрасывает флаг как `$1` в check_ci_gate → fake даёт rc=1 + «CI не зелёный».
#
# bash в script-режиме НЕ пробрасывает SIGTERM в дочерний sleep → fake делает sleep
# ПЕРЕД реакцией: timeout SIGTERM убивает fake с обрывом маркера «rc=» (без «0»/«1»).
#
# Изолированные PATH-каталоги по решению арбитра (b2d336d): каждая ветвь с
# PATH-манипуляцией использует СВОЙ nopath-каталог — нет пересечения между ветвями.
#
# 10 ветвей: красный, зелёный, фailfast-медленный, фailfast-быстрый-ok,
# фailfast-дефолт, фailfast-дефолт-540, фailfast-произвольный-N,
# фailfast-защита-N-невалидный, фailfast-защита-N-нецелый,
# фailfast-защита-timeout-отсутствует.
set -uo pipefail
export LC_ALL="${LC_ALL:-C.UTF-8}"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SELF_DIR/.." && pwd)"
ROOT="${1:-$REPO}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd || echo "$ROOT")"
SUBJECT="$ROOT/scripts/judge_gate.sh"
WANT="${2:-all}"

die()  { printf 'ОТКАЗ ветвь (%s): %s\n' "$1" "$2" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

TMP="$REPO/tmp"; mkdir -p "$TMP" 2>/dev/null || skip "tmp не создать"
WORK="$(mktemp -d "$TMP/cjg.XXXXXX")" || skip "mktemp не смог"
trap 'rm -rf "$WORK"' EXIT

want() { [ "$WANT" = all ] || [ "$WANT" = "$1" ]; }
has()  { case "$2" in *"$1"*) return 0 ;; *) return 1 ;; esac; }

KNOWN="красный зелёный фailfast-медленный фailfast-быстрый-ok фailfast-дефолт фailfast-дефолт-540 фailfast-произвольный-N фailfast-защита-N-невалидный фailfast-защита-N-нецелый фailfast-защита-timeout-отсутствует"
if [ "$WANT" != all ]; then
  f=0; for k in $KNOWN; do [ "$WANT" = "$k" ] && f=1; done
  [ "$f" = 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (из: %s)\n' "$WANT" "$KNOWN" >&2; exit 1; }
fi

FAKE_MARK="FAKE-check_ci_gate"
PASS_SHA="GOOD-SHA-$$-${RANDOM}${RANDOM}${RANDOM}"
SLOW_SHA="SLOW-SHA-$$-${RANDOM}${RANDOM}${RANDOM}"
SLEEP_FOR="${SLEEP_FOR:-0}"

run_gate() {
  if [ ! -f "$SUBJECT" ]; then OUT="ПРЕДМЕТ-ОТСУТСТВУЕТ"; RC=2; return 0; fi
  local t="$WORK/g"; mkdir -p "$t/scripts"
  cp "$SUBJECT" "$t/scripts/judge_gate.sh"; chmod +x "$t/scripts/judge_gate.sh"
  local eff_sleep="${SLEEP_FOR:-0}"
  cat > "$t/scripts/check_ci_gate.sh" <<EOF
#!/usr/bin/env bash
printf '${FAKE_MARK} sha=%s rc=' "\$1" >&2
sleep ${eff_sleep}
if [ "\$1" = "${PASS_SHA}" ]; then printf '0\\n' >&2; exit 0; fi
printf '1\\n' >&2; exit 1
EOF
  chmod +x "$t/scripts/check_ci_gate.sh"
  if [ -n "${EXTRA_ENV:-}" ]; then
    OUT="$(env $EXTRA_ENV bash "$t/scripts/judge_gate.sh" "$@" 2>&1)"; RC=$?
  else
    OUT="$(bash "$t/scripts/judge_gate.sh" "$@" 2>&1)"; RC=$?
  fi
}

# Создать изолированный nopath-каталог с симлинками (используется фикстурой и сам).
# Ветвь `(фailfast-дефолт-540)` потом добавит timeout через свой `cat`.
make_nopath() {  # <каталог>
  local d="$1"
  mkdir -p "$d"
  for cmd in bash sh cat date echo printf sleep dirname pwd; do
    src="$(command -v "$cmd" 2>/dev/null || true)"
    [ -n "$src" ] && ln -sf "$src" "$d/$cmd"
  done
}

# ── (красный) CI не зелёный → RC≠0 ──────────────────────────────────────────
if want красный; then
  run_gate "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
  has "$FAKE_MARK" "$OUT" || die красный "judge_gate не позвал check_ci_gate (нет маркера $FAKE_MARK). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" != 0 ] || die красный "не-зелёный CI, а judge_gate дал RC=0 — судья пропустил не-зелёный CI"
  printf '  ok   (красный) не-зелёный CI → judge_gate RC≠0, звал check_ci_gate\n' >&2
fi

# ── (зелёный) CI зелёный → RC=0 + OK + sha=$PASS_SHA ───────────────────────────
if want зелёный; then
  run_gate "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die зелёный "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "sha=${PASS_SHA}" "$OUT" || die зелёный "fake не получил sha=${PASS_SHA} — judge_gate НЕ передал свой \$1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die зелёный "CI зелёный, а judge_gate дал RC=$RC. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die зелёный "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (зелёный) зелёный CI → judge_gate rc=0 + «OK» + передал sha=%s\n' "$PASS_SHA" >&2
fi

# ── (фailfast-медленный) fake спит 3с; --fail-fast=2 обязан СРАЗУ отказать ──
if want фailfast-медленный; then
  SLEEP_FOR=3 run_gate --fail-fast=2 "$SLOW_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-медленный "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" != 0 ] || die фailfast-медленный "fake спит 3с на SLOW_SHA, --fail-fast=2 обязан дать RC≠0, а judge_gate дал RC=0. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "FAIL-FAST: превышен тайм-бокс 2 с" "$OUT" || die фailfast-медленный "RC≠0 есть, но нет дослов «FAIL-FAST: превышен тайм-бокс 2 с». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-медленный "стаб-имитатор (без timeout) дал fake, который ПРОЖИЛ все 3с и напечатал «rc=1» — fail-fast сломан (имитация). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-медленный) fail-fast=2 на медленном fake → «FAIL-FAST: превышен тайм-бокс 2 с»\n' >&2
fi

# ── (фailfast-быстрый-ok) fake отвечает мгновенно rc=0; --fail-fast=2 обязан rc=0 + OK ──
if want фailfast-быстрый-ok; then
  SLEEP_FOR=0 run_gate --fail-fast=2 "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-быстрый-ok "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "sha=${PASS_SHA}" "$OUT" || die фailfast-быстрый-ok "fake не получил sha=${PASS_SHA}. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-быстрый-ok "на быстром fake (rc=0) и --fail-fast=2 judge_gate дал RC=$RC — fail-fast сломал зелёный путь. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-быстрый-ok "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-быстрый-ok "стаб пробрасывает флаг в fake → rc=1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-быстрый-ok) fail-fast=2 на быстром fake → rc=0 + «OK»\n' >&2
fi

# ── (фailfast-дефолт) bare --fail-fast → TBOX=540; fake отвечает мгновенно ──
if want фailfast-дефолт; then
  SLEEP_FOR=0 run_gate --fail-fast "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-дефолт "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-дефолт "bare --fail-fast (дефолт 540с) на быстром fake дал RC=$RC — bare флаг не принят. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-дефолт "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-дефолт "стаб пробрасывает флаг в fake → rc=1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-дефолт) bare --fail-fast → дефолт 540с, rc=0 + «OK»\n' >&2
fi

# ── (фailfast-дефолт-540) fake-timeout через ИЗОЛИРОВАННЫЙ nopath_540; проверка TBOX==540 ──
# Изолированный PATH ($WORK/nopath_540) — НЕ пересекается с nopath_abs (timeout-отсутствует).
# fake-timeout пишет $@ в args.log, затем exec настоящего /usr/bin/timeout.
# heredoc БЕЗ кавычек → интерполяция ${WORK}; $@ и \$ — литералы.
if want фailfast-дефолт-540; then
  make_nopath "$WORK/nopath_540"
  cat > "$WORK/nopath_540/timeout" <<EOF
#!/usr/bin/env bash
echo "\$@" > "${WORK}/timeout_args.log"
exec /usr/bin/timeout "\$@"
EOF
  chmod +x "$WORK/nopath_540/timeout"
  SLEEP_FOR=2 EXTRA_ENV="PATH=$WORK/nopath_540" run_gate --fail-fast "$PASS_SHA"
  [ -f "$WORK/timeout_args.log" ] || die фailfast-дефолт-540 "timeout не был вызван (args.log нет) — fake-timeout не перехватил вызов, предмет НЕ использовал timeout"
  if ! grep -q -- '--foreground 540' "$WORK/timeout_args.log"; then
    die фailfast-дефолт-540 "default НЕ 540: timeout_args.log = $(cat $WORK/timeout_args.log) — предмет передал TBOX≠540 на bare --fail-fast. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  fi
  has "$FAKE_MARK" "$OUT" || die фailfast-дефолт-540 "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-дефолт-540 "bare --fail-fast с default 540 на fake sleep 2с дал RC=$RC. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-дефолт-540 "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-дефолт-540 "стаб без timeout дал rc=1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-дефолт-540) bare --fail-fast → default 540 (timeout_args.log проверен), fake sleep 2с → rc=0 + «OK»\n' >&2
fi

# ── (фailfast-произвольный-N) RANDOM_N∈[3..500] на прогон; стаб-whitelist провалится ──
# Конструкция (решение арбитра b2d336d, домен N бесконечен — конечная проверка):
# на каждом прогоне N случайный из [3..500]; стаб с whitelist {2,7} при N=3,4,... провалится.
# Стаб, принимающий ВСЕ натуральные N>0 без whitelist, пройдёт (cognitive-only).
if want фailfast-произвольный-N; then
  RANDOM_N=$((RANDOM % 498 + 3))
  printf 'RANDOM_N=%s\n' "$RANDOM_N" >&2  # для верификации: значение N в этом прогоне
  SLEEP_FOR=0 run_gate --fail-fast="$RANDOM_N" "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-произвольный-N "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "sha=${PASS_SHA}" "$OUT" || die фailfast-произвольный-N "fake не получил sha=${PASS_SHA}. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-произвольный-N "--fail-fast=$RANDOM_N (случайный N∈[3..500]) на быстром fake дал RC=$RC — предмет не принимает произвольные натуральные N. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-произвольный-N "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-произвольный-N "стаб пробрасывает --fail-fast=$RANDOM_N как $1 → rc=1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-произвольный-N) --fail-fast=%s (RANDOM_N∈[3..500]) → rc=0 + «OK»\n' "$RANDOM_N" >&2
fi

# ── (фailfast-защита-N-невалидный) --fail-fast=0 → RC≠0 + «тайм-бокс должен быть > 0» ──
if want фailfast-защита-N-невалидный; then
  SLEEP_FOR=0 run_gate --fail-fast=0 "$PASS_SHA"
  [ "$RC" != 0 ] || die фailfast-защита-N-невалидный "--fail-fast=0 дал RC=0 — N≤0 не отвергнут. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "тайм-бокс должен быть > 0" "$OUT" || die фailfast-защита-N-невалидный "--fail-fast=0 отвергнут (RC≠0), но без дослов «тайм-бокс должен быть > 0». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-защита-N-невалидный "стаб (008, пробрасывает флаг в fake) выдаёт rc=1 от fake. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-защита-N-невалидный) --fail-fast=0 → RC≠0 + «тайм-бокс должен быть > 0»\n' >&2
fi

# ── (фailfast-защита-N-нецелый) --fail-fast=abc → RC≠0 + «тайм-бокс должен быть > 0» ──
if want фailfast-защита-N-нецелый; then
  SLEEP_FOR=0 run_gate --fail-fast=abc "$PASS_SHA"
  [ "$RC" != 0 ] || die фailfast-защита-N-нецелый "--fail-fast=abc дал RC=0 — N не-целое не отвергнут. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "тайм-бокс должен быть > 0" "$OUT" || die фailfast-защита-N-нецелый "--fail-fast=abc отвергнут (RC≠0), но без дослов «тайм-бокс должен быть > 0». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-защита-N-нецелый "стаб (008, пробрасывает флаг в fake) выдаёт rc=1 от fake. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-защита-N-нецелый) --fail-fast=abc → RC≠0 + «тайм-бокс должен быть > 0»\n' >&2
fi

# ── (фailfast-защита-timeout-отсутствует) ИЗОЛИРОВАННЫЙ nopath_abs без timeout ──
if want фailfast-защита-timeout-отсутствует; then
  make_nopath "$WORK/nopath_abs"
  # timeout НЕ кладём — это и есть условие ветки.
  EXTRA_ENV="PATH=$WORK/nopath_abs" SLEEP_FOR=0 run_gate --fail-fast=2 "$PASS_SHA"
  [ "$RC" != 0 ] || die фailfast-защита-timeout-отсутствует "--fail-fast=2 на PATH без timeout дал RC=0 — предмет НЕ проверил наличие timeout. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "timeout не найден" "$OUT" || die фailfast-защита-timeout-отсутствует "RC≠0 есть, но без дослов «timeout не найден». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-защита-timeout-отсутствует "стаб (008, пробрасывает в fake) выдаёт rc=1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-защита-timeout-отсутствует) --fail-fast=2 на PATH без timeout → RC≠0 + «timeout не найден»\n' >&2
fi

printf 'check_judge_gate: ветви «%s» зелены\n' "$WANT" >&2
exit 0