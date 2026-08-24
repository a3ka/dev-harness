#!/usr/bin/env bash
# ПРИЧИНА: rc=1
# Ветвь (фailfast-защита-N-невалидный): барьер проверяет, что предмет отвергает --fail-fast=0
# с RC=1 + дословно «тайм-бокс должен быть > 0». Стаб, пробрасывающий `--fail-fast=0` как `$1`
# в check_ci_gate (как делает 008 без fail-fast), даст rc=1 + «CI не зелёный» —
# НЕ «тайм-бокс должен быть > 0» → die.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (отвергает N≤0).
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=540; shift ;;
  --fail-fast=*)
    TBOX="${1#--fail-fast=}"
    shift
    # N — натуральное > 0.
    case "$TBOX" in
      ''|*[!0-9]*) printf 'FAIL-FAST: тайм-бокс должен быть > 0 (дано: %s)\n' "$TBOX" >&2; exit 1 ;;
    esac
    [ "$TBOX" -gt 0 ] || { printf 'FAIL-FAST: тайм-бокс должен быть > 0 (дано: %s)\n' "$TBOX" >&2; exit 1; }
    ;;
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
"$BARRIER" "$G" фailfast-защита-N-невалидный

# Красное: реальный judge_gate.sh (008, без fail-fast) — пробрасывает --fail-fast=0 как $1.
R="$WORK/red"; mkdir -p "$R/scripts"
cp "$REPO/scripts/judge_gate.sh" "$R/scripts/judge_gate.sh"
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" фailfast-защита-N-невалидный