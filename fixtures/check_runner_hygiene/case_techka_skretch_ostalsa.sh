# ПРИЧИНА: остался новый путь
# Ветвь (techka), райдер (ii) контракта 012: обманка ведёт себя как нынешний
# раннер — default-скратч создаётся и ОСТАЁТСЯ после завершившегося прогона
# (замер владельца: 47→49 скратч-каталогов за два прогона). Зелёный контроль —
# эталон (сам создал — сам убрал; существовавшее до прогона не тронуто).
# Красное — обманка: под $TMPDIR остался новый путь.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" techka

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: default-скратч не убирается за собой (райдер (ii))
set -uo pipefail
R1="$(cd "$1" && pwd)"
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
if [ -n "$S" ]; then
  D="$S"
else
  D="$(mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX")"
fi
mkdir -p "$D"
printf 'log\n' > "$D/run-$$-log"
sleep 1
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
TMPDIR="$WORK/red-tmp" "$BARRIER" "$R" techka
