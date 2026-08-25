# ПРИЧИНА: перезаписал
# Ветвь (lock): барьер ловит НЕатомарный захват — обманка честно отказывает «занят»
# кодом 3 и пишет правильную тройку полей, но ЗАТИРАЕТ чужой lock ДО проверки владельца
# (обход круга 1 критика: ветвь не наблюдала атомарность; наблюдаемое следствие
# честного set -C — отказ БЕЗ перезаписи). Зелёный контроль — эталон (чужой lock
# байт-в-байт цел).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" lock

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: отказ честный (код 3, «занят»), но чужой lock затирается ДО проверки
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
prev=""
[ -f "$L" ] && prev="$(cat "$L" 2>/dev/null || true)"
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
if [ -n "$prev" ]; then
  read -r pid _ <<< "$prev" || true
  if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
    printf 'занят: уже идёт (pid %s)\n' "$pid" >&2
    exit 3
  fi
fi
D="$S/run-$$"; mkdir -p "$D"
trap 'rm -rf "$D"; rm -f "$L"' EXIT
sleep 6
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" lock
