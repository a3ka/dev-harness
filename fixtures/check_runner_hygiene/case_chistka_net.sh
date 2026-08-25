# ПРИЧИНА: не убран
# Ветвь (chistka): барьер ловит раннер БЕЗ стартовой чистки — мусор убитых прогонов
# (каталог run-<мёртвый pid>, base64-обрывки путей) переживает новые прогоны и
# копится (Н-48-5). Зелёный контроль — эталон (чистит только мёртвых). Красное —
# обманка с честным lock, но без чистки: подсаженный мусор остаётся.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" chistka

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: lock есть, стартовой чистки нет — мусор мёртвых копится
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
if [ -f "$L" ] && kill -0 "$(awk '{print $1}' "$L")" 2>/dev/null; then
  printf 'занят: уже идёт (pid %s)\n' "$(awk '{print $1}' "$L")" >&2
  exit 3
fi
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
D="$S/run-$$"; mkdir -p "$D"
trap 'rm -rf "$D"; rm -f "$L"' EXIT
sleep 0.5
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" chistka
