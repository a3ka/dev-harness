#!/usr/bin/env bash
# ПРИЧИНА: rc=1
# Ветвь (фailfast-защита-timeout-отсутствует): барьер подменяет PATH так, что `command -v
# timeout` пусто. Стаб, который НЕ проверяет наличие timeout перед запуском, либо
# пробрасывает в check_ci_gate (rc=1 + «CI не зелёный», нет «timeout не найден»), либо
# зависает синхронно. Эталон проверяет `command -v timeout` и отвечает дословно
# «FAIL-FAST: timeout не найден» + RC=1.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (проверяет наличие timeout).
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=540; shift ;;
  --fail-fast=*) TBOX="${1#--fail-fast=}"; shift ;;
esac
sha="${1:?usage: $0 [--fail-fast[=<N>]] <sha>}"
# Защита: timeout должен быть в PATH.
command -v timeout >/dev/null 2>&1 || { printf 'FAIL-FAST: timeout не найден\n' >&2; exit 1; }
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timeout --foreground "$TBOX" "$SELF/check_ci_gate.sh" "$sha"
rc=$?
[ "$rc" = 124 ] && { printf 'FAIL-FAST: превышен тайм-бокс %s с\n' "$TBOX" >&2; exit 1; }
[ "$rc" = 0 ] && printf 'OK\n'
exit "$rc"
EOF
chmod +x "$G/scripts/judge_gate.sh"
"$BARRIER" "$G" фailfast-защита-timeout-отсутствует

# Красное: реальный judge_gate.sh (008, без fail-fast) — пробрасывает всё в check_ci_gate,
# на PATH без timeout не зовёт timeout, не отвечает «timeout не найден».
R="$WORK/red"; mkdir -p "$R/scripts"
cp "$REPO/scripts/judge_gate.sh" "$R/scripts/judge_gate.sh"
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" фailfast-защита-timeout-отсутствует