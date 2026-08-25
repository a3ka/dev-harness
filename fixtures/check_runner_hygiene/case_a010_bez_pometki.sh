# ПРИЧИНА: отменено грилингом
# Ветвь (a010): барьер ловит contracts/010 БЕЗ пометки v+1 у §Приёмка п.8 —
# замороженный текст всё ещё требует от судьи полный прогон (Н-48). Зелёный контроль —
# аннотированный 010. Красное — 010 с живым (неаннотированным) п.8.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" a010

R="$WORK/red"; mk_green_root "$R"
cat > "$R/contracts/010-topologija-orkestrator-arhitektor.md" <<'EOF'
# Контракт 010 (игрушечный): п.8 без пометки v+1

## §Приёмка

8. Регресс: `npm run check:ci-parity` → 0; `bash scripts/verify_antiplacebo.sh` → 0
   (фрозенные барьеры 006/007/008 целы).
EOF
"$BARRIER" "$R" a010
