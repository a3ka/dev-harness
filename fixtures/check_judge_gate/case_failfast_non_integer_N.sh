#!/usr/bin/env bash
# ПРИЧИНА: rc=1
# Ветвь (фailfast-защита-N-нецелый): барьер проверяет, что предмет отвергает --fail-fast=abc
# (N не-целое) с RC=1 + дословно «тайм-бокс должен быть > 0». Стаб 008 пробрасывает
# --fail-fast=abc как $1 в check_ci_gate → rc=1 → die. На эталоне предмет отвергает
# ДО вызова check_ci_gate → нет «rc=1».
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (отвергает N не-целое).
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=540; shift ;;
  --fail-fast=*)
    TBOX="${1#--fail-fast=}"
    shift
    case "$TBOX" in
      ''|*[!0-9]*) printf 'FAIL-FAST: тайм-бокс должен быть > 0 (дано: %s)\n' "$TBOX" >&2; exit 1 ;;
    esac
    [ "$TBOX" -gt 0 ] || { printf 'FAIL-FAST: тайм-бокс должен быть > 0 (дано: %s)\n' "$TBOX" >&2; exit 1; }
    ;;
esac
sha="${1:?usage: $0 [--fail-fast[=<N>]] <sha>}"
command -v timeout >/dev/null 2>&1 || { printf 'FAIL-FAST: timeout не найден\n' >&2; exit 1; }
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timeout --foreground "$TBOX" "$SELF/check_ci_gate.sh" "$sha"
rc=$?
[ "$rc" = 124 ] && { printf 'FAIL-FAST: превышен тайм-бокс %s с\n' "$TBOX" >&2; exit 1; }
[ "$rc" = 0 ] && printf 'OK\n'
exit "$rc"
EOF
chmod +x "$G/scripts/judge_gate.sh"
"$BARRIER" "$G" фailfast-защита-N-нецелый

# Красное: реальный judge_gate.sh (008, без fail-fast) — пробрасывает --fail-fast=abc как $1.
R="$WORK/red"; mkdir -p "$R/scripts"
cp "$REPO/scripts/judge_gate.sh" "$R/scripts/judge_gate.sh"
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" фailfast-защита-N-нецелый