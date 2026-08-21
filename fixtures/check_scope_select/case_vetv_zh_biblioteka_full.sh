# ПРИЧИНА: недобор
# Ветвь (ж): правка библиотеки (НЕ БАРЬЕР, сорсится) → MODE full. Барьер ловит стаб, дающий
# scoped вместо полной выборки (недобор задетых барьеров).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
r="$1"; base="${3:-}"
ch="$(git -C "$r" diff --name-only "$base" HEAD)"
if printf '%s\n' "$ch" | grep -q 'lib_'; then echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; else echo "MODE: scoped"; fi
exit 0
EOF
"$BARRIER" "$R" ж

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" ж
