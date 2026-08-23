# ПРИЧИНА: позитив жив
# Ветвь (щ): правка независимого барьера a → scoped ровно a (позитив жив, не вечно-full).
# Барьер ловит вечно-фуллящий селектор. Зелёный — честный (scoped KEY a), красное — обманный (full).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; echo "KEY: a"; exit 0
EOF
"$BARRIER" "$R" щ

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: full"; exit 0
EOF
"$BARRIER" "$R" щ
