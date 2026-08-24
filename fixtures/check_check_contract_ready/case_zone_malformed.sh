# ПРИЧИНА: не требует грамматику
# Барьер ловит предмет, детектящий зоны по ПОДСТРОКЕ `^ЗОН` (принимает малформед `ЗОН`, `ЗОНА`
# без грамматики) — ревьюер 008. Зелёный контроль — реальный предмет (требует грамматику
# `ЗОНА <роль>: <путь>`). Красное — стаб со старым широким `^ЗОН`.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$REPO/scripts/check_contract_ready.sh" "$G/scripts/check_contract_ready.sh"
chmod +x "$G/scripts/check_contract_ready.sh"
"$BARRIER" "$G" зонаформ

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/check_contract_ready.sh" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР
# стаб (старое широкое поведение): zone-check по подстроке ^ЗОН → принимает малформед `ЗОН`.
grep -qE '^ЗОН' "$1/contract.md" || { echo "ОТКАЗ зон" >&2; exit 1; }
echo OK; exit 0
EOF
chmod +x "$R/scripts/check_contract_ready.sh"
"$BARRIER" "$R" зонаформ
