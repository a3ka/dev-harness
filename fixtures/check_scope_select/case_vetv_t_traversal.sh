# ПРИЧИНА: принят
# Ветвь (т): case-traversal (`b/../../scripts/a`) обязан быть отвергнут кодом 1 (§3: case только
# `case_*` immediate). Барьер ловит селектор, ПРИНИМАЮЩИЙ traversal. Зелёный — честный (отвергает).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
shift
if [ "${1:-}" = --scope ]; then
  shift
  for k in "$@"; do case "$k" in */../*|*/*/*) echo "traversal $k" >&2; exit 1 ;; esac; done
fi
echo "MODE: scoped"
EOF
"$BARRIER" "$R" т

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; echo "KEY: b/../../scripts/a"; exit 0
EOF
"$BARRIER" "$R" т
