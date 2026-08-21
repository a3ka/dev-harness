# ПРИЧИНА: принят
# Ветвь (а): scope_select обязан отвергать неизвестный ключ кодом 1. Барьер ловит стаб, который
# его ПРИНИМАЕТ. Зелёный контроль — честный стаб (отвергает); красное — обманный (принимает).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
shift
[ "${1:-}" = --scope ] && { shift; for k in "$@"; do case "$k" in a|b) ;; *) echo "нет ключа $k" >&2; exit 1 ;; esac; done; }
echo "MODE: scoped"
EOF
"$BARRIER" "$R" а

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" а
