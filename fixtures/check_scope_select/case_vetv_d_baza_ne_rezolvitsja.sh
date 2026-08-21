# ПРИЧИНА: fail-closed
# Ветвь (д): нерезолвимая база `--changed` → код 2 (fail-closed), НЕ «0 задетых успех». Барьер
# ловит стаб, отдающий успех при недоступной базе.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
r="$1"; base="${3:-}"
git -C "$r" rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1 || { echo "база не резолвится" >&2; exit 2; }
echo "MODE: scoped"
EOF
"$BARRIER" "$R" д

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" д
