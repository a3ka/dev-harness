#!/usr/bin/env bash
# Барьер приёмки judge_gate (контракт 008 срез-2 + контракт 009 fail-fast, тир-1).
# Гоняет ПРЕДМЕТ `<корень>/scripts/judge_gate.sh <args>` с fake `check_ci_gate`.
#
# ПИНИТ (008): judge_gate ОБЯЗАН
#   (а) найти и звать `check_ci_gate` (доказательство — маркер FAKE в выводе);
#   (б) передать ему аргумент `$1` (fake даёт rc=0 только при exact-matching PASS_SHA);
#   (в) пропустить вердикт fake в свой код возврата;
#   (г) на зелёном напечатать «OK».
#
# ПИНИТ (009, поток A, Н-41): judge_gate ОБЯЗАН при `--fail-fast[=<N>]`:
#   (а) запустить check_ci_gate через `timeout --foreground TBOX` (TBOX=540 по умолчанию,
#       N — натуральное > 0 при `--fail-fast=N`);
#   (б) при срабатывании timeout (rc=124) напечатать дословно
#       `FAIL-FAST: превышен тайм-бокс N с` и выйти RC=1, не дожидаясь bash-таймаута 600с;
#   (в) на НЕ-срабатывании — пробросить RC как раньше;
#   (г) на быстром rc=0 — напечатать «OK».
#   Защиты (RC=1 с названной причиной):
#     - `command -v timeout` пусто → дословно `FAIL-FAST: timeout не найден`;
#     - `--fail-fast=N` с N≤0 или N не целое → дословно
#       `FAIL-FAST: тайм-бокс должен быть > 0 (дано: <N>)`.
#
# КРАСНОЕ ПРОТИВ ТЕКУЩЕГО ДЕРЕВА: реальный judge_gate.sh (008) НЕ реализует --fail-fast →
# пробрасывает `--fail-fast` как `$1` в check_ci_gate → fake даёт rc=1 + «CI не зелёный»,
# НЕ «FAIL-FAST: превышен» → все fail-fast ветви краснеют.
#
#   bash scripts/check_judge_gate.sh [<корень>] [<ветвь>]
#     <ветвь  — одна из 8: красный зелёный фailfast-медленный фailfast-быстрый-ok
#                          фailfast-дефолт фailfast-дефолт-540
#                          фailfast-защита-N-невалидный
#                          фailfast-защита-timeout-отсутствует (умолч. all)
#
# Коды возврата: 0 — зелены, 1 — ветвь провалена, 2 — нечем проверить.
#
# ВАЖНО: bash в script-режиме НЕ пробрасывает SIGTERM в дочерний sleep, поэтому fake
# делает sleep ПЕРЕД реакцией: timeout SIGTERM на ~TBOX убивает fake с обрывом маркера
# «rc=», без продолжения. Это даёт надёжный признак «fake был убит» (нет «rc=0»/«rc=slow»/
# «rc=1») vs «fake прожил» (есть «rc=…»). Проверка elapsed ненадёжна (~1с overhead от
# setsid + env -i) — проверяем маркер fake, а не время.
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

KNOWN="красный зелёный фailfast-медленный фailfast-быстрый-ok фailfast-дефолт фailfast-дефолт-540 фailfast-защита-N-невалидный фailfast-защита-timeout-отсутствует"
if [ "$WANT" != all ]; then
  f=0; for k in $KNOWN; do [ "$WANT" = "$k" ] && f=1; done
  [ "$f" = 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (из: %s)\n' "$WANT" "$KNOWN" >&2; exit 1; }
fi

FAKE_MARK="FAKE-check_ci_gate"
PASS_SHA="GOOD-SHA-$$-${RANDOM}${RANDOM}${RANDOM}"
SLOW_SHA="SLOW-SHA-$$-${RANDOM}${RANDOM}${RANDOM}"
SLEEP_FOR="${SLEEP_FOR:-0}"

run_gate() {  # <args...>
  if [ ! -f "$SUBJECT" ]; then OUT="ПРЕДМЕТ-ОТСУТСТВУЕТ"; RC=2; return 0; fi
  local t="$WORK/g"; mkdir -p "$t/scripts"
  cp "$SUBJECT" "$t/scripts/judge_gate.sh"; chmod +x "$t/scripts/judge_gate.sh"
  cat > "$t/scripts/check_ci_gate.sh" <<EOF
#!/usr/bin/env bash
printf '${FAKE_MARK} sha=%s rc=' "\$1" >&2
sleep ${SLEEP_FOR}
if [ "\$1" = "${PASS_SHA}" ]; then printf '0\\n' >&2; exit 0; fi
if [ "\$1" = "${SLOW_SHA}" ]; then printf 'slow\\n' >&2; exec sleep ${SLEEP_FOR}; fi
printf '1\\n' >&2; exit 1
EOF
  chmod +x "$t/scripts/check_ci_gate.sh"
  if [ -n "${EXTRA_ENV:-}" ]; then
    OUT="$(env $EXTRA_ENV bash "$t/scripts/judge_gate.sh" "$@" 2>&1)"; RC=$?
  else
    OUT="$(bash "$t/scripts/judge_gate.sh" "$@" 2>&1)"; RC=$?
  fi
}

# ── (красный) CI не зелёный → RC≠0 ──────────────────────────────────────────
if want красный; then
  run_gate "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
  has "$FAKE_MARK" "$OUT" || die красный "judge_gate не позвал check_ci_gate (нет маркера $FAKE_MARK). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" != 0 ] || die красный "не-зелёный CI (sha ≠ ${PASS_SHA}), а judge_gate дал RC=0 — судья пропустил не-зелёный CI"
  printf '  ok   (красный) не-зелёный CI → judge_gate RC≠0, звал check_ci_gate\n' >&2
fi

# ── (зелёный) CI зелёный → RC=0 + OK + sha=$PASS_SHA ────────────────────────────
if want зелёный; then
  run_gate "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die зелёный "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "sha=${PASS_SHA}" "$OUT" || die зелёный "fake не получил sha=${PASS_SHA} — judge_gate НЕ передал свой \$1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die зелёный "CI зелёный, а judge_gate дал RC=$RC. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die зелёный "RC=0, но нет маркера «OK» — стаб-всегда-0 не должен проходить. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (зелёный) зелёный CI → judge_gate rc=0 + «OK» + передал sha=%s\n' "$PASS_SHA" >&2
fi

# ── (фailfast-медленный, 009) fake спит 3с; --fail-fast=2 обязан СРАЗУ отказать ──
# Анти-плацебо: стаб-имитатор (ждёт fake 3с, потом печатает «FAIL-FAST: превышен») пройдёт
# RC≠0 + подстроку, но НЕ пройдёт проверку «rc=1» — он вызывает fake напрямую, fake
# прожил все 3с и напечатал «rc=1». timeout убивает fake на ~2с → маркер обрывается на «rc=».
if want фailfast-медленный; then
  SLEEP_FOR=3 run_gate --fail-fast=2 "$SLOW_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-медленный "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" != 0 ] || die фailfast-медленный "fake спит 3с на SLOW_SHA, --fail-fast=2 обязан дать RC≠0, а judge_gate дал RC=0 — fail-fast НЕ сработал. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "FAIL-FAST: превышен тайм-бокс 2 с" "$OUT" || die фailfast-медленный "RC≠0 есть, но нет дослов «FAIL-FAST: превышен тайм-бокс 2 с» — предмет отказал НЕ по fail-fast. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-медленный "стаб без timeout (имитатор) должен дать fake, который ПРОЖИВЁТ все 3с и напечатает «rc=1» — стаб либо не вызвал fake, либо был убит timeout'ом (это эталон, не стаб). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-медленный) fail-fast=2 на медленном fake → «FAIL-FAST: превышен тайм-бокс 2 с»\n' >&2
fi

# ── (фailfast-быстрый-ok, 009) fake отвечает мгновенно rc=0; --fail-fast=2 обязан rc=0 + OK ──
if want фailfast-быстрый-ok; then
  SLEEP_FOR=0 run_gate --fail-fast=2 "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-быстрый-ok "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "sha=${PASS_SHA}" "$OUT" || die фailfast-быстрый-ok "fake не получил sha=${PASS_SHA} — judge_gate НЕ передал свой \$1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-быстрый-ok "на быстром fake (rc=0) и --fail-fast=2 judge_gate дал RC=$RC (а не rc=0) — fail-fast сломал зелёный путь. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-быстрый-ok "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-быстрый-ok "стаб пробрасывает флаг в fake → rc=1 от fake. На зелёном пути fake даёт rc=0. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-быстрый-ok) fail-fast=2 на быстром fake → rc=0 + «OK»\n' >&2
fi

# ── (фailfast-дефолт, 009) bare --fail-fast без =N → TBOX=540; fake отвечает мгновенно ──
if want фailfast-дефолт; then
  SLEEP_FOR=0 run_gate --fail-fast "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-дефолт "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-дефолт "bare --fail-fast (дефолт 540с) на быстром fake дал RC=$RC (а не rc=0) — bare флаг не принят. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-дефолт "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-дефолт "стаб пробрасывает флаг в fake → rc=1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-дефолт) bare --fail-fast → дефолт 540с, rc=0 + «OK»\n' >&2
fi

# ── (фailfast-дефолт-540, 009) bare-дефолт РЕАЛЬНО 540 ────────────────────────────
# fake спит 2с: при default=540 (540 > 2) → rc=0 + OK.
# Стаб, с TBOX=1 для bare → timeout убивает на 1с → rc=124 + «FAIL-FAST: превышен 1 с».
# Подстрока «FAIL-FAST: превышен тайм-бокс 1 с» появляется на красном, НЕ на зелёном.
if want фailfast-дефолт-540; then
  SLEEP_FOR=2 run_gate --fail-fast "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-дефолт-540 "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-дефолт-540 "bare --fail-fast с дефолтом на fake sleep 2с дал RC=$RC — default меньше 2с (т.е. не 540) ИЛИ timeout не использован. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-дефолт-540 "RC=0, но нет маркера «OK». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "FAIL-FAST: превышен тайм-бокс 1 с" "$OUT" && die фailfast-дефолт-540 "стаб TBOX=1 убит timeout'ом на 1с, fake не успевает напечатать «rc=1» — но «FAIL-FAST: превышен тайм-бокс 1 с» от предмета есть. Это НЕ имитация, это валидный отказ. Но default должен быть 540, не 1. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-дефолт-540) bare --fail-fast с default 540 на fake sleep 2с → rc=0 + «OK»\n' >&2
fi

# ── (фailfast-защита-N-невалидный, 009) --fail-fast=0 → RC≠0 + «тайм-бокс должен быть > 0» ──
# Маркер FAKE НЕ обязателен (предмет может отвергать ДО вызова check_ci_gate).
# Подстрока-признак стаба (008, пробрасывает в fake): fake даёт «rc=1». На эталоне —
# нет вызова fake, нет «rc=1».
if want фailfast-защита-N-невалидный; then
  SLEEP_FOR=0 run_gate --fail-fast=0 "$PASS_SHA"
  [ "$RC" != 0 ] || die фailfast-защита-N-невалидный "--fail-fast=0 дал RC=0 (а не RC≠0) — N≤0 не отвергнут. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "тайм-бокс должен быть > 0" "$OUT" || die фailfast-защита-N-невалидный "--fail-fast=0 отвергнут (RC≠0), но без дослов «тайм-бокс должен быть > 0». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-защита-N-невалидный "стаб (008, пробрасывает флаг в fake) выдаёт rc=1 от fake. Это НЕ защита N≤0. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-защита-N-невалидный) --fail-fast=0 → RC≠0 + «тайм-бокс должен быть > 0»\n' >&2
fi

# ── (фailfast-защита-timeout-отсутствует, 009) PATH без timeout → RC≠0 + «timeout не найден» ──
# Подстрока-признак стаба (008, пробрасывает в fake): fake даёт «rc=1». На эталоне —
# предмет проверяет `command -v timeout`, отвечает «FAIL-FAST: timeout не найден» ДО fake.
if want фailfast-защита-timeout-отсутствует; then
  mkdir -p "$WORK/nopath"
  for cmd in bash sh cat date echo printf sleep dirname pwd; do
    src="$(command -v "$cmd" 2>/dev/null || true)"
    [ -n "$src" ] && ln -sf "$src" "$WORK/nopath/$cmd"
  done
  EXTRA_ENV="PATH=$WORK/nopath" SLEEP_FOR=0 run_gate --fail-fast=2 "$PASS_SHA"
  [ "$RC" != 0 ] || die фailfast-защита-timeout-отсутствует "--fail-fast=2 на PATH без timeout дал RC=0 — предмет НЕ проверил наличие timeout. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "timeout не найден" "$OUT" || die фailfast-защита-timeout-отсутствует "RC≠0 есть, но без дослов «timeout не найден». Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "rc=1" "$OUT" && die фailfast-защита-timeout-отсутствует "стаб (008, пробрасывает в fake) выдаёт rc=1 от fake. Это НЕ защита timeout. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-защита-timeout-отсутствует) --fail-fast=2 на PATH без timeout → RC≠0 + «timeout не найден»\n' >&2
fi

printf 'check_judge_gate: ветви «%s» зелены\n' "$WANT" >&2
exit 0