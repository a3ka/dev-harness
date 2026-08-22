# ПРИЧИНА: НЕ ровно 1 case
# Ветвь (case): --scope <key>/<case> прогоняет РОВНО один case. Зелёный — _ref_va.sh (с case-фильтром).
# Красное — обманка, которая применяет barrier-фильтр (по ключу), но НЕ фильтрует case внутри
# барьерного цикла: --scope b/case_b_1 прогоняет обе case_b_1 и case_b_2. Барьер пишет
# «прогнал НЕ ровно 1 case — фильтр case-уровня не сузил» — уникальная подстрока.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" case

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# Обманка (case): barrier-фильтр есть, case-фильтра нет.
echo "SCOPED: не для приёмки" >&2
exec "$REPO/scripts/verify_antiplacebo.sh" "\$@"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" case
