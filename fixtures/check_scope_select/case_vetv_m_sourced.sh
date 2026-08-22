# ПРИЧИНА: недобор
# Ветвь (м): барьер b сорсится барьером a → правка b обязана дать MODE: full. Барьер ловит
# селектор, сузивший до scoped вместо full (недобор задетого a). Зелёный — честный (full),
# красное — обманный (scoped).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" м

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" м
