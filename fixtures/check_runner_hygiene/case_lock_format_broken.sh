# ПРИЧИНА: три числовых поля
# Ветвь (lock): барьер ловит lock-файл НЕ в пинованном формате `<pid> <pgid> <epoch>` —
# обманка пишет ТОЛЬКО pid (одно поле), а отказ «занят» кодом 3 честный (обход круга 1
# критика: ветвь не наблюдала формат). Зелёный контроль — эталон (три поля).
# Lock-файл в trap НЕ удаляется: однопольный файл обязан пережить 8с-опрос барьера —
# иначе красное уходит в «не появился», а не в формат (дефект, найденный прогоном сборки).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" lock

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: lock в одно поле (только pid) — формат пинованного API нарушен
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
if [ -f "$L" ] && kill -0 "$(awk '{print $1}' "$L")" 2>/dev/null; then
  printf 'занят: уже идёт (pid %s)\n' "$(awk '{print $1}' "$L")" >&2
  exit 3
fi
printf '%s\n' "$$" > "$L"
D="$S/run-$$"; mkdir -p "$D"
trap 'rm -rf "$D"' EXIT
sleep 9
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" lock
