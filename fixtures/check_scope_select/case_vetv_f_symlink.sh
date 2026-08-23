# ПРИЧИНА: через ссылку
# Ветвь (ф): source через симлинк link.sh→b.sh → MODE: full. Барьер ловит селектор, сузивший до scoped.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" ф

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: b"; exit 0
EOF
"$BARRIER" "$R" ф
