# ПРИЧИНА: принят
# Ветвь (б): пустой `--scope` (ключи не заданы) — ошибка использования, код 1. Барьер ловит
# стаб, принимающий пустой список.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
[ "${2:-}" = --scope ] && { [ "$#" -ge 3 ] || { echo "пустой список" >&2; exit 1; }; }
echo "MODE: scoped"
EOF
"$BARRIER" "$R" б

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" б
