# ПРИЧИНА: маркера приёмки судьи
# Ветвь (norma): барьер ловит AGENTS.md БЕЗ маркера ПРИЁМКА-СУДЬИ (v2) — норма «судье
# scoped-регресс затронутых барьеров, полный прогон — CI» не внесена (Н-48-1: приёмка
# полным прогоном недостижима судьёй). Зелёный контроль — полная норма. Красное —
# устав с carve-out, но без маркера.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" norma

R="$WORK/red"; mk_green_root "$R"
cat > "$R/AGENTS.md" <<'EOF'
# Устав (игрушечный): carve-out есть, маркера приёмки судьи v2 нет

16. Всё по-русски. Временное — в `./tmp`, не в системном `/tmp`.
    ИСКЛЮЧЕНИЕ (carve-out, РАЗРЕШИЛ-ВЛАДЕЛЕЦ 2026-08-24): scratch раннера
    `scripts/verify_antiplacebo.sh` живёт вне стерегомого дерева (в системном `/tmp`
    или под `$VERIFY_ANTIPLACEBO_SCRATCH`).
EOF
"$BARRIER" "$R" norma
