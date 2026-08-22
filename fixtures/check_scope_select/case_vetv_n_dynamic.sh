# ПРИЧИНА: не сужение
# Ветвь (н): барьер с динамическим source → правка обязана дать MODE: full. Барьер ловит
# селектор, сузивший до scoped вместо full. Зелёный — честный (full), красное — обманный (scoped).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" н

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" н
