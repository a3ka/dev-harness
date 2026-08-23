#!/usr/bin/env bash
# Барьер приёмки judge_gate (контракт 008, срез-2, тир-1).
#
# Гоняет ПРЕДМЕТ `scripts/judge_gate.sh <sha>` (пишет ИСПОЛНИТЕЛЬ) и УТВЕРЖДАЕТ: судья
# гейтит через `check_ci_gate` — CI не зелёный → RC≠0, зелёный → RC0. Детерминизм без сети:
# фикстура подставляет ФЕЙКОВЫЙ `check_ci_gate.sh` с заданным кодом рядом с предметом.
#
# ПИНИТ: judge_gate ОБЯЗАН (а) звать check_ci_gate (доказательство — маркер FAKE в выводе),
# (б) пропустить его вердикт в свой код возврата. Это убирает Н-41: судья подтверждает зелёное
# по CI-сигналу, а не гоняет 15-23-мин пачку локально.
#
# КРАСНОЕ ПРОТИВ ДЕРЕВА: judge_gate.sh ещё нет → маркер отсутствия, обе ветви краснеют.
# Анти-плацебо: стаб, не зовущий check_ci_gate (нет FAKE), валит обе ветви; стаб-всегда-0
# валит (красный); стаб-всегда-≠0 валит (зелёный).
#
#   bash scripts/check_judge_gate.sh [<ветвь>]   ветви: красный зелёный (умолч. все)
# Коды возврата: 0 — зелены, 1 — ветвь провалена, 2 — нечем проверить.
set -uo pipefail
export LC_ALL="${LC_ALL:-C.UTF-8}"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SELF_DIR/.." && pwd)"
SUBJECT="$REPO/scripts/judge_gate.sh"
WANT="${1:-all}"

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

# Гоняет предмет judge_gate в toy-корне, где check_ci_gate.sh ФЕЙКОВЫЙ с заданным кодом.
# judge_gate обязан искать check_ci_gate рядом с собой (SELF_DIR предмета) — фикстура кладёт оба.
FAKE_MARK="FAKE-check_ci_gate"
run_gate() {  # <fake-ci-rc> <sha>
  if [ ! -f "$SUBJECT" ]; then OUT="ПРЕДМЕТ-ОТСУТСТВУЕТ"; RC=2; return 0; fi
  local t="$WORK/g$1"; mkdir -p "$t/scripts"
  cp "$SUBJECT" "$t/scripts/judge_gate.sh"; chmod +x "$t/scripts/judge_gate.sh"
  cat > "$t/scripts/check_ci_gate.sh" <<EOF
#!/usr/bin/env bash
printf '${FAKE_MARK} rc=%s\n' "$1" >&2
exit $1
EOF
  chmod +x "$t/scripts/check_ci_gate.sh"
  OUT="$(bash "$t/scripts/judge_gate.sh" "$2" 2>&1)"; RC=$?
}

# ── (красный) CI не зелёный (fake rc=1) → judge_gate RC≠0 И звал check_ci_gate ──
if want красный; then
  run_gate 1 deadbeefdeadbeefdeadbeefdeadbeefdeadbeef
  has "$FAKE_MARK" "$OUT" || die красный "judge_gate не позвал check_ci_gate (нет маркера) — гейт по CI-сигналу не реализован. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" != 0 ] || die красный "CI не зелёный (fake rc=1), а judge_gate дал RC=0 — судья пропустил не-зелёный CI"
  printf '  ok   (красный) не-зелёный CI → judge_gate RC≠0, звал check_ci_gate\n' >&2
fi

# ── (зелёный) CI зелёный (fake rc=0) → judge_gate RC=0 И звал check_ci_gate ──────
if want зелёный; then
  run_gate 0 deadbeefdeadbeefdeadbeefdeadbeefdeadbeef
  has "$FAKE_MARK" "$OUT" || die зелёный "judge_gate не позвал check_ci_gate (нет маркера). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  [ "$RC" = 0 ] || die зелёный "CI зелёный (fake rc=0), а judge_gate дал RC=$RC. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '  ok   (зелёный) зелёный CI → judge_gate RC=0, звал check_ci_gate\n' >&2
fi

printf 'check_judge_gate: ветви «%s» зелены\n' "$WANT" >&2
exit 0
