# ПРИЧИНА: ровно кодом 3
# Ветвь (lock): барьер ловит отказ «занят» НЕ пинованным кодом — обманка честно
# захватывает lock тройкой полей и отказывает словом «занят», но кодом 1, а не 3
# (обход круга 1 критика: ветвь принимала любой ненулевой код). Зелёный контроль —
# эталон (отказ ровно код 3).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" lock

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: lock честный, отказ назван, но код 1 вместо пинованного 3
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
if [ -f "$L" ] && kill -0 "$(awk '{print $1}' "$L")" 2>/dev/null; then
  printf 'занят: уже идёт (pid %s)\n' "$(awk '{print $1}' "$L")" >&2
  exit 1
fi
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
D="$S/run-$$"; mkdir -p "$D"
trap 'rm -rf "$D"; rm -f "$L"' EXIT
sleep 6
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" lock
