# ПРИЧИНА: add обязан
# Ветвь (з): добавление файла (статус A) → MODE full. Барьер ловит стаб, дающий частичный scoped
# на add.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
r="$1"; base="${3:-}"
if git -C "$r" diff --name-status "$base" HEAD | grep -qE '^A'; then echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; else echo "MODE: scoped"; fi
exit 0
EOF
"$BARRIER" "$R" з

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" з
