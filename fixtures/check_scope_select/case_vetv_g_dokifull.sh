# ПРИЧИНА: ожидался 2
# Ветвь (г): дифф только по докам → needs-full, код 2 (не 0). Барьер ловит стаб, отдающий
# scoped-успех на пустой выборке.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
r="$1"; base="${3:-}"
ch="$(git -C "$r" diff --name-only "$base" HEAD)"
if printf '%s\n' "$ch" | grep -qE '^(scripts|fixtures)/'; then echo "MODE: scoped"; exit 0; fi
echo "SCOPED: 0 задетых — полный гейт в CI" >&2; echo "MODE: needs-full"; exit 2
EOF
"$BARRIER" "$R" г

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" г
