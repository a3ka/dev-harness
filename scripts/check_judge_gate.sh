#!/usr/bin/env bash
# Барьер приёмки judge_gate (контракт 008, срез-2, тир-1).
# Гоняет ПРЕДМЕТ `<корень>/scripts/judge_gate.sh <sha>` с fake `check_ci_gate` (rc=0 ТОЛЬКО при
# exact-matching SHA PASS_THIS_SHA_GREEN). Образец — check_scope_select/check_scoped_run: предмет
# объявляет себя «НЕ БАРЬЕР», барьер — ЭТОТ файл; фикстуры `fixtures/check_judge_gate/case_*.sh`
# предъявляют его КРАСНЫМ, подавая СЛОМАННЫЙ предмет в подставной корень (green-root → red-root).
# (зелёный) дополнительно требует маркер «OK» в выводе, чтобы стаб-всегда-0 не прошёл.
#
# ПИНИТ: judge_gate ОБЯЗАН
#   (а) найти и звать `check_ci_gate` (доказательство — маркер FAKE в выводе);
#   (б) передать ему аргумент `$1` (доказательство — fake даёт rc=0 только при exact-matching
#       SHA `PASS_THIS_SHA_GREEN`, иначе rc≠0); иначе bypass: звать check_ci_gate без
#       аргументов или с другим значением → fake вернёт rc≠0 → «зелёный» ветвь красная.
#   (в) пропустить вердикт fake в свой код возврата.
#   (г) на зелёном напечатать «OK» (anti-stub: стаб-всегда-0 не пройдёт).
#
# Анти-плацебо (стабы НЕ проходят):
#   стаб-всегда-RC0:        валит (красный) — пропустил не-зелёный CI;
#   стаб-всегда-RC≠0:       валит (зелёный) — пропустил зелёный CI;
#   стаб-без-вызова-fake:   валит ОБЕ — нет маркера FAKE;
#   стаб-игнорирующий-SHA:  валит (зелёный) — fake без matching SHA вернёт rc≠0;
#   стаб-RC0-без-OK:        валит (зелёный) — нет маркера «OK».
#
# КРАСНОЕ ПРОТИВ ТЕКУЩЕГО ДЕРЕВА: judge_gate.sh ещё нет → RC=2 маркер, обе ветви краснеют.
#
#   bash scripts/check_judge_gate.sh [<корень>] [<ветвь>]
#     <корень> — где лежит scripts/judge_gate.sh (умолч. корень репозитория);
#     <ветвь>  — одна из: красный зелёный (умолч. all)
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

KNOWN="красный зелёный"
if [ "$WANT" != all ]; then
  f=0; for k in $KNOWN; do [ "$WANT" = "$k" ] && f=1; done
  [ "$f" = 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (из: %s)\n' "$WANT" "$KNOWN" >&2; exit 1; }
fi

# Fake `check_ci_gate.sh`: rc=0 ТОЛЬКО при $1 = PASS_THIS_SHA_GREEN, иначе rc=1.
# Это пинит, что judge_gate ОБЯЗАН передать свой $1 в check_ci_gate (а не вызвать без
# аргумента или с чужим SHA). Маркер FAKE печатается в stderr — для доказательства вызова.
FAKE_MARK="FAKE-check_ci_gate"
PASS_SHA="PASS_THIS_SHA_GREEN"
run_gate() {  # <sha>
  if [ ! -f "$SUBJECT" ]; then OUT="ПРЕДМЕТ-ОТСУТСТВУЕТ"; RC=2; return 0; fi
  local t="$WORK/g"; mkdir -p "$t/scripts"
  cp "$SUBJECT" "$t/scripts/judge_gate.sh"; chmod +x "$t/scripts/judge_gate.sh"
  cat > "$t/scripts/check_ci_gate.sh" <<EOF
#!/usr/bin/env bash
printf '${FAKE_MARK} sha=%s rc=' "\$1" >&2
if [ "\$1" = "${PASS_SHA}" ]; then printf '0\\n' >&2; exit 0; fi
printf '1\\n' >&2; exit 1
EOF
  chmod +x "$t/scripts/check_ci_gate.sh"
  OUT="$(bash "$t/scripts/judge_gate.sh" "$1" 2>&1)"; RC=$?
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
  has "OK" "$OUT" || die зелёный "judge_gate RC=0, но нет маркера «OK» в выводе — стаб vsegda-0 не должен проходить как зелёный. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (зелёный) зелёный CI → judge_gate RC=0 + «OK» + передал sha=%s\n' "$PASS_SHA" >&2
fi

printf 'check_judge_gate: ветви «%s» зелены\n' "$WANT" >&2
exit 0