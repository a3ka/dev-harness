# ПРИЧИНА: default-скратч обязан быть ОБЩИМ
# Ветвь (lockdef), райдер (i) контракта 012: обманка ведёт себя как нынешний
# раннер — при ПУСТОЙ VERIFY_ANTIPLACEBO_SCRATCH заводит УНИКАЛЬНЫЙ mktemp-скратч.
# lock живёт в каталоге, который никто больше не видит: второй прогон того же
# дерева не отказывает rc=3, прогоны контендятся (замер шага 1 контракта 012).
# Зелёный контроль — эталон (общий детерминированный путь → второй прогон
# отказывает «занят»). Красное — обманка: оба default-прогона проходят rc=0.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" lockdef

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: явный scratch уважает lock, default — уникальный mktemp (райдер (i))
set -uo pipefail
R1="$(cd "$1" && pwd)"
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
if [ -n "$S" ]; then
  D="$S"
else
  D="$(mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX")"
fi
mkdir -p "$D"
L="$D/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$D/lt-$$"
if ! ln "$D/lt-$$" "$L" 2>/dev/null; then
  pid=""; read -r pid _ < "$L" 2>/dev/null || true
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    rm -f "$D/lt-$$"; printf 'занят: владелец pid %s\n' "$pid" >&2; exit 3
  fi
  rm -f "$L"; ln "$D/lt-$$" "$L"
fi
rm -f "$D/lt-$$"
sleep 3
rm -f "$L"
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
TMPDIR="$WORK/red-tmp" "$BARRIER" "$R" lockdef
