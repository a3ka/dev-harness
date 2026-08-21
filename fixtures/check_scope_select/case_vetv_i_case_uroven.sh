# ПРИЧИНА: не выбрал
# Ветвь (и): `--scope <ключ>/<case>` → выбран РОВНО этот case. Барьер ловит стаб, не давший
# case-выборку.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: ${3:-}"; exit 0
EOF
"$BARRIER" "$R" и

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" и
