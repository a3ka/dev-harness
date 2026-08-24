#!/usr/bin/env bash
# ПРИЧИНА: fake не получил sha=
# Ветвь (фailfast-быстрый-ok): барьер ловит judge_gate, который НЕ разбирает --fail-fast=2,
# а пробрасывает его как `$1` (sha) в check_ci_gate. Fake на $1=--fail-fast=2 (не $PASS_SHA)
# вернёт rc=1 + «CI не зелёный» — НЕ rc=0 + OK → ветвь красная.
# Зелёный контроль — heredoc эталона с правильной реализацией --fail-fast (timeout,
# проброс $1).
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (только для зелёного контроля фикстуры).
# Когда implementer напишет реальный предмет с этим API, барьер даст ему зелёное
# на этой ветви без изменений.
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=540; shift ;;
  --fail-fast=*) TBOX="${1#--fail-fast=}"; shift ;;
esac
sha="${1:?usage: $0 [--fail-fast[=<N>]] <sha>}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timeout --foreground "$TBOX" "$SELF/check_ci_gate.sh" "$sha"
rc=$?
[ "$rc" = 124 ] && { printf 'FAIL-FAST: превышен тайм-бокс %s с\n' "$TBOX" >&2; exit 1; }
[ "$rc" = 0 ] && printf 'OK\n'
exit "$rc"
EOF
chmod +x "$G/scripts/judge_gate.sh"
"$BARRIER" "$G" фailfast-быстрый-ok

# Красное: реальный judge_gate.sh (008, без fail-fast) — пробрасывает --fail-fast=2 как $1.
R="$WORK/red"; mkdir -p "$R/scripts"
cp "$REPO/scripts/judge_gate.sh" "$R/scripts/judge_gate.sh"
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" фailfast-быстрый-ok