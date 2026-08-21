# ПРИЧИНА: принят
# Ветвь (в): `--scope <ключ>/<case>` с несуществующим case — код 1. Барьер ловит стаб, который
# его принимает.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
r="$1"; k="${3:-}"
case "$k" in
  */*) bar="${k%%/*}"; cas="${k#*/}"
       [ -f "$r/fixtures/$bar/$cas.sh" ] || { echo "нет case $k" >&2; exit 1; } ;;
esac
echo "MODE: scoped"
EOF
"$BARRIER" "$R" в

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" в
