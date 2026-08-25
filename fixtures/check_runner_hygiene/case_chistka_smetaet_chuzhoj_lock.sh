# ПРИЧИНА: чужой live lock
# Ветвь (chistka): барьер ловит «чистку», сносящую ВЕСЬ scratch разом — включая ЧУЖОЙ
# live lock другого дерева. Ленивое `rm -rf "$SCRATCH"/*` — самый вероятный обход при
# реализации: мусор убран, но вместе с неприкосновенным. Зелёный контроль — эталон.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" chistka

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: «чистка» = rm -rf всего scratch, включая чужое живое
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
rm -rf "$S"/* 2>/dev/null || true
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
D="$S/run-$$"; mkdir -p "$D"
trap 'rm -rf "$D"; rm -f "$L"' EXIT
sleep 0.5
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" chistka
