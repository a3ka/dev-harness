# ПРИЧИНА: невычислимая цель
# Ветвь (ц): видимый динамический source в неизменённом барьере → MODE: full. Барьер ловит селектор, сузивший до scoped.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" ц

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" ц
