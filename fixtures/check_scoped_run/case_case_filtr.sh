# ПРИЧИНА: НЕ ровно 1 case
# Ветвь (case): --scope <key>/<case> прогоняет РОВНО один case. Зелёный — _ref_va.sh (с case-фильтром).
# Красное — обманка, которая применяет barrier-фильтр (по ключу), но НЕ фильтрует case внутри
# барьерного цикла: зовёт реальный раннер с `--scope b` (без /case) → барьер b, но ВСЕ его case
# (case_b_1 и case_b_2) → «фикстур: 2». Барьер пишет «прогнал НЕ ровно 1 case» — уникальная подстрока.
# Реальный раннер напрямую с /case брать нельзя: он теперь корректно case-фильтрует (не обманка).
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" case

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# обманка (case): barrier-фильтр есть, case-фильтра НЕТ → --scope b (без /case) гонит все case b
exec "$REPO/scripts/verify_antiplacebo.sh" "\$1" --scope b
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" case
