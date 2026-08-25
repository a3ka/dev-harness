# ПРИЧИНА: не назван словом
# Ветвь (lock): барьер ловит раннер, который отказывает по занятости корректным кодом,
# но НЕ называет причину словом «занят» (правило 7: отказ обязан называть предмет —
# молчаливый rc≠0 читается как неудача запуска). Зелёный контроль — эталон. Красное —
# обманка с честным lock-файлом и безымянным отказом «already running».
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" lock

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: lock есть, отказ есть, но текст не называет «занят»
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
if [ -f "$L" ] && kill -0 "$(awk '{print $1}' "$L")" 2>/dev/null; then
  echo "already running, try later"
  exit 3
fi
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
D="$S/run-$$"; mkdir -p "$D"
trap 'rm -rf "$D"; rm -f "$L"' EXIT
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" lock
