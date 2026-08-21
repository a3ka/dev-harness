# ПРИЧИНА: не напечатал маркер
# Ветвь (к): scoped-режим печатает машинно-отличимый маркер `SCOPED:`. Барьер ловит стаб, не
# напечатавший маркер (неотличим от полного).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" к

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" к
