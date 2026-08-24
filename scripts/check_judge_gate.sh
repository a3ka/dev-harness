#!/usr/bin/env bash
# Барьер приёмки judge_gate (контракт 008 срез-2 + контракт 009 fail-fast, тир-1).
# Гоняет ПРЕДМЕТ `<корень>/scripts/judge_gate.sh <args>` с fake `check_ci_gate`.
# Образец — check_scope_select/check_scoped_run: предмет объявляет себя «НЕ БАРЬЕР»,
# барьер — ЭТОТ файл; фикстуры `fixtures/check_judge_gate/case_*.sh` предъявляют его КРАСНЫМ,
# подавая СЛОМАННЫЙ предмет в подставной корень (green-root → red-root).
# (зелёный) дополнительно требует маркер «OK» в выводе, чтобы стаб-всегда-0 не прошёл.
#
# ПИНИТ (008): judge_gate ОБЯЗАН
#   (а) найти и звать `check_ci_gate` (доказательство — маркер FAKE в выводе);
#   (б) передать ему аргумент `$1` (доказательство — fake даёт rc=0 только при exact-matching
#       SHA `PASS_THIS_SHA_GREEN`, иначе rc≠0); иначе bypass: звать check_ci_gate без
#       аргументов или с другим значением → fake вернёт rc≠0 → «зелёный» ветвь красная.
#   (в) пропустить вердикт fake в свой код возврата.
#   (г) на зелёном напечатать «OK» (anti-stub: стаб-всегда-0 не пройдёт).
#
# ПИНИТ (009, поток A, Н-41): judge_gate ОБЯЗАН при `--fail-fast[=<N>]`:
#   (а) запустить check_ci_gate через `timeout --foreground TBOX` (TBOX=540 по умолчанию,
#       N — натуральное > 0 при `--fail-fast=N`);
#   (б) при срабатывании timeout (rc=124) напечатать дословно
#       `FAIL-FAST: превышен тайм-бокс N с` и выйти RC=1, не дожидаясь bash-таймаута 600с;
#   (в) на НЕ-срабатывании (rc=0 или rc=1 от check_ci_gate) — пробросить RC как раньше;
#   (г) на быстром rc=0 — напечатать «OK», как в 008.
#   Защиты (RC=1 с названной причиной): timeout не найден; N≤0 или N не целое.
#
# Анти-плацебо (стабы НЕ проходят):
#   стаб-всегда-RC0:        валит (красный) — пропустил не-зелёный CI;
#   стаб-всегда-RC≠0:       валит (зелёный) — пропустил зелёный CI;
#   стаб-без-вызова-fake:   валит ОБЕ — нет маркера FAKE;
#   стаб-игнорирующий-SHA:  валит (зелёный) — fake без matching SHA вернёт rc≠0;
#   стаб-RC0-без-OK:        валит (зелёный) — нет маркера «OK».
#   стаб-без-fail-fast:     валит (фailfast-*) — нет маркера «FAIL-FAST: превышен» на SLOW_SHA,
#                           или RC≠0 на PASS_SHA с --fail-fast (вместо RC=0 + OK).
#
# КРАСНОЕ ПРОТИВ ТЕКУЩЕГО ДЕРЕВА: реальный judge_gate.sh (008) НЕ реализует --fail-fast →
# пробрасывает `--fail-fast` как `$1` в check_ci_gate → fake даёт rc=1 + «CI не зелёный»,
# НЕ «FAIL-FAST: превышен» → все три новые ветви краснеют.
#
#   bash scripts/check_judge_gate.sh [<корень>] [<ветвь>]
#     <корень> — где лежит scripts/judge_gate.sh (умолч. корень репозитория);
#     <ветвь>  — одна из: красный зелёный фailfast-медленный фailfast-быстрый-ok
#                          фailfast-дефолт (умолч. all)
#
# Коды возврата: 0 — зелены, 1 — ветвь провалена, 2 — нечем проверить.
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

# (008) красный/зелёный — синхронный гейт через CI.
# (009, поток A Н-41) — три fail-fast ветви.
KNOWN="красный зелёный фailfast-медленный фailfast-быстрый-ok фailfast-дефолт"
if [ "$WANT" != all ]; then
  f=0; for k in $KNOWN; do [ "$WANT" = "$k" ] && f=1; done
  [ "$f" = 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (из: %s)\n' "$WANT" "$KNOWN" >&2; exit 1; }
fi

# Fake `check_ci_gate.sh`:
#   $1 = $PASS_SHA → rc=0 (мгновенно, без задержки) — зелёный CI;
#   $1 = $SLOW_SHA → sleep $SLEEP_FOR секунд → rc=1 — медленный CI для fail-fast;
#   всё прочее    → rc=1 — CI не зелёный.
# Это пинит (008), что judge_gate ОБЯЗАН передать свой $1 в check_ci_gate (а не вызвать без
# аргумента, с чужим SHA или зашить зелёный на известную КОНСТАНТУ — адверсарий 008 круг 1).
# Маркер FAKE — в stderr, для подтверждения вызова.
FAKE_MARK="FAKE-check_ci_gate"
PASS_SHA="GOOD-SHA-$$-${RANDOM}${RANDOM}${RANDOM}"
SLOW_SHA="SLOW-SHA-$$-${RANDOM}${RANDOM}${RANDOM}"
SLEEP_FOR="${SLEEP_FOR:-3}"

run_gate() {  # <args...>  — все аргументы judge_gate.sh (008: <sha>; 009: [--fail-fast[=<N>]] <sha>)
  if [ ! -f "$SUBJECT" ]; then OUT="ПРЕДМЕТ-ОТСУТСТВУЕТ"; RC=2; return 0; fi
  local t="$WORK/g"; mkdir -p "$t/scripts"
  cp "$SUBJECT" "$t/scripts/judge_gate.sh"; chmod +x "$t/scripts/judge_gate.sh"
  cat > "$t/scripts/check_ci_gate.sh" <<EOF
#!/usr/bin/env bash
printf '${FAKE_MARK} sha=%s rc=' "\$1" >&2
if [ "\$1" = "${PASS_SHA}" ]; then printf '0\\n' >&2; exit 0; fi
if [ "\$1" = "${SLOW_SHA}" ]; then printf 'slow\\n' >&2; sleep ${SLEEP_FOR}; exit 1; fi
printf '1\\n' >&2; exit 1
EOF
  chmod +x "$t/scripts/check_ci_gate.sh"
  OUT="$(bash "$t/scripts/judge_gate.sh" "$@" 2>&1)"; RC=$?
}

# ── (красный) CI не зелёный (любой sha ≠ PASS_THIS_SHA_GREEN) → RC≠0 ──
if want красный; then
  run_gate "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
  has "$FAKE_MARK" "$OUT" || die красный "judge_gate не позвал check_ci_gate (нет маркера $FAKE_MARK) — гейт по CI-сигналу не реализован. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" != 0 ] || die красный "не-зелёный CI (sha ≠ ${PASS_SHA}), а judge_gate дал RC=0 — судья пропустил не-зелёный CI"
  printf '  ok   (красный) не-зелёный CI → judge_gate RC≠0, звал check_ci_gate\n' >&2
fi

# ── (зелёный) CI зелёный (sha = PASS_THIS_SHA_GREEN) → RC=0 ─────────────────────
# Если judge_gate игнорирует $1 и зовёт check_ci_gate без/с другим аргументом —
# fake вернёт rc≠0 → RC≠0 → ветвь красная. Доказывает, что предмет передал $1.
if want зелёный; then
  run_gate "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die зелёный "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "sha=${PASS_SHA}" "$OUT" || die зелёный "fake check_ci_gate не получил sha=${PASS_SHA} — judge_gate НЕ передал свой \$1 в check_ci_gate (bypass #3). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die зелёный "CI зелёный (sha=${PASS_SHA}), а judge_gate дал RC=$RC. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die зелёный "judge_gate rc=0, но нет маркера «OK» в выводе — стаб vsegda-0 не должен проходить как зелёный. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (зелёный) зелёный CI → judge_gate rc=0 + «OK» + передал sha=%s\n' "$PASS_SHA" >&2
fi

# ── (фailfast-медленный, 009) fake спит 3с; --fail-fast=2 обязан СРАЗУ отказать ──
# Отличает «fail-fast сработал» (rc≠0 + «FAIL-FAST: превышен 2 с») от
# «CI не зелёный» (rc=1 + «CI не зелёный …») — разные классы отказа, проверяются
# разными подстроками. Стаб-всегда-RC0 без timeout НЕ пройдёт: rc=0 + OK, нет «FAIL-FAST».
if want фailfast-медленный; then
  run_gate --fail-fast=2 "$SLOW_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-медленный "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" != 0 ] || die фailfast-медленный "fake check_ci_gate спит ${SLEEP_FOR}с на SLOW_SHA, --fail-fast=2 обязан дать RC≠0, а judge_gate дал RC=0 — fail-fast НЕ сработал. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "FAIL-FAST: превышен тайм-бокс 2 с" "$OUT" || die фailfast-медленный "RC≠0 есть, но нет дословного «FAIL-FAST: превышен тайм-бокс 2 с» — предмет отказал НЕ по fail-fast (видимо, пробрасывает «CI не зелёный»). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-медленный) fail-fast=2 на медленном fake → «FAIL-FAST: превышен тайм-бокс 2 с»\n' >&2
fi

# ── (фailfast-быстрый-ok, 009) fake отвечает мгновенно rc=0; --fail-fast=2 обязан rc=0 + OK ──
# Доказывает, что fail-fast НЕ ломает быстрый путь. Стаб, не реализующий timeout и пробрасывающий
# rc check_ci_gate без обработки --fail-fast, на --fail-fast=2 $PASS_SHA даст rc=1 (fake rc=1
# потому что «$1» в check_ci_gate равно «--fail-fast=2», не PASS_SHA) → die.
if want фailfast-быстрый-ok; then
  run_gate --fail-fast=2 "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-быстрый-ok "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "sha=${PASS_SHA}" "$OUT" || die фailfast-быстрый-ok "fake не получил sha=${PASS_SHA} — judge_gate НЕ передал свой \$1 в check_ci_gate (bypass). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-быстрый-ok "на быстром fake (rc=0) и --fail-fast=2 judge_gate дал RC=$RC (а не rc=0) — fail-fast сломал зелёный путь. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-быстрый-ok "RC=0, но нет маркера «OK» в выводе. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-быстрый-ok) fail-fast=2 на быстром fake → rc=0 + «OK» (fail-fast не ломает быстрый путь)\n' >&2
fi

# ── (фailfast-дефолт, 009) bare --fail-fast без =N → TBOX=540; fake отвечает мгновенно ──
# Доказывает, что bare --fail-fast принимается с дефолтом 540с. Стаб, который обрабатывает
# ТОЛЬКО --fail-fast=N (не bare), даст usage error (RC=1) на bare --fail-fast → die.
if want фailfast-дефолт; then
  run_gate --fail-fast "$PASS_SHA"
  has "$FAKE_MARK" "$OUT" || die фailfast-дефолт "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die фailfast-дефолт "bare --fail-fast (дефолт 540с) на быстром fake дал RC=$RC (а не rc=0) — bare флаг не принят. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  has "OK" "$OUT" || die фailfast-дефолт "RC=0, но нет маркера «OK» в выводе. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (фailfast-дефолт) bare --fail-fast → дефолт 540с, rc=0 + «OK»\n' >&2
fi

printf 'check_judge_gate: ветви «%s» зелены\n' "$WANT" >&2
exit 0