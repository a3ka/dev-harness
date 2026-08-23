# ПРИЧИНА: по имени
# Ветвь (ч): имя цели b.sh в строке-литерале → MODE: full (fail-closed по имени). Барьер ловит селектор, сузивший до scoped.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" ч

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" ч
