# ПРИЧИНА: не должен блокировать
# Ветвь (chistka): барьер ловит раннер, принимающий ЛЮБОЙ lock за занятость — без
# проверки жив ли владелец. Дерево, в котором прогон когда-то убили, блокируется
# навсегда: ложный отказ «занят» на мёртвом lock. Зелёный контроль — эталон.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" chistka

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: любой lock — занятость, владелец не проверяется
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
if [ -f "$L" ]; then
  printf 'занят: lock есть, владельца не проверяю\n' >&2
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
