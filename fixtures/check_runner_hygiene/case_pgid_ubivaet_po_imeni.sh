# ПРИЧИНА: по имени
# Ветвь (pgid): барьер ловит раннер, убивающий перед работой чужие процессы ПО ИМЕНИ
# (pgrep/pkill -f по маркеру в cmdline) — реинкарнация Н-48-4: так pkill -f
# verify_antiplacebo убивал прогоны ревьюера. Маркер паттерна — «verify_antiplacebo-decoy»:
# он не совпадает ни с внешним раннером, ни с самим предметом, только с подставным
# чужим процессом. Зелёный контроль — эталон (по имени не убивает ничего).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" pgid

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: «чистка» убивает по имени маркера — чужой name-decoy гибнет (Н-48-4)
for p in $(pgrep -f 'verify_antiplacebo-decoy' 2>/dev/null); do
  kill -9 "$p" 2>/dev/null || true
done
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" pgid
