# ПРИЧИНА: не ловит отсутствие раздачи
# Ветвь (зоны): барьер ловит предмет, который принимает контракт БЕЗ раздачи зон (RC0).
# Зелёный контроль — реальный check_contract_ready (корректно краснит контракт без зон).
# Красное — стаб-всегда-0: принимает любой контракт, значит отсутствие зон не ловит. Реальный
# предмет обманкой брать нельзя — он корректен, красное обязано умирать от дефекта предмета.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$REPO/scripts/check_contract_ready.sh" "$G/scripts/check_contract_ready.sh"
chmod +x "$G/scripts/check_contract_ready.sh"
"$BARRIER" "$G" зоны

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/check_contract_ready.sh" <<'EOF'
#!/usr/bin/env bash
# стаб-всегда-0: ничего не проверяет
exit 0
EOF
chmod +x "$R/scripts/check_contract_ready.sh"
"$BARRIER" "$R" зоны
