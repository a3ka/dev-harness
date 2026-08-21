# ПРИЧИНА: обязаны вести
# Ветвь (з): add / delete / rename / смена-роли → MODE full (или 2), НЕ частичный scoped. Барьер
# строит все 4 сценария; зелёный стаб обязан вернуть full на каждом, обманный — ловится.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/root"

sel "$R" <<'EOF'
#!/usr/bin/env bash
r="$1"; base="${3:-}"
ns="$(git -C "$r" diff --name-status "$base" HEAD)"
if printf '%s\n' "$ns" | grep -qE '^(A|D|R|C)'; then echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0; fi
while IFS=$'\t' read -r st p _; do
  case "$p" in scripts/*.sh) head -5 "$r/$p" 2>/dev/null | grep -q 'Коды возврата' || { echo "SCOPED: не для приёмки" >&2; echo "MODE: full"; exit 0; } ;; esac
done <<< "$ns"
echo "MODE: scoped"
EOF
"$BARRIER" "$R" з

sel "$R" <<'EOF'
#!/usr/bin/env bash
echo "MODE: scoped"; exit 0
EOF
"$BARRIER" "$R" з
