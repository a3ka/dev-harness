# ПРИЧИНА: готовый контракт не RC=0
# Ветвь (готов): барьер ловит предмет, который ОТВЕРГАЕТ полностью готовый контракт (RC≠0) —
# положительный контроль сломан. Зелёный контроль — реальный предмет (принимает готовый контракт
# с маркером OK). Красное — стаб-всегда-1: отвергает всё, даже готовое.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$REPO/scripts/check_contract_ready.sh" "$G/scripts/check_contract_ready.sh"
chmod +x "$G/scripts/check_contract_ready.sh"
"$BARRIER" "$G" готов

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/check_contract_ready.sh" <<'EOF'
#!/usr/bin/env bash
# стаб-всегда-1: отвергает даже готовый контракт (маркер OK есть, но код ненулевой)
echo "OK"
exit 1
EOF
chmod +x "$R/scripts/check_contract_ready.sh"
"$BARRIER" "$R" готов
