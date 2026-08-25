# ПРИЧИНА: не захватывает lock
# Ветвь (lock): барьер ловит раннер БЕЗ lock — lock-файл не появляется вовсе, второй
# прогон при живом первом идёт дальше (Н-48-3: параллельные прогоны бьют снапшоты
# друг друга). Зелёный контроль — эталон _ref_runner.sh (живой lock → именованный
# отказ, первый цел). Красное — обманка без lock.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" lock

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: lock нет — параллельные прогоны не разводятся (Н-48-3)
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" lock
