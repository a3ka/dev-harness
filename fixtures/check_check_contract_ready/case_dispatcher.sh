# ПРИЧИНА: не проверил существование
# Барьер ловит предмет-ДИСПЕТЧЕР, узнающий ПОСТОЯННЫЕ заголовки старых toy-контрактов (адверсарий
# 008 круг 1). После генерик-заголовков ($TOK) диспетчер не узнаёт toy → «else → OK», и на ветви
# (пробаф) не ловит пробу на несуществующий файл. Зелёный контроль — реальный предмет (проверяет
# существование файла пробы). Красное — диспетчер по константам.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$REPO/scripts/check_contract_ready.sh" "$G/scripts/check_contract_ready.sh"
chmod +x "$G/scripts/check_contract_ready.sh"
"$BARRIER" "$G" пробаф

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/check_contract_ready.sh" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР
# диспетчер (стаб адверсария): узнаёт СТАРЫЕ постоянные заголовки toy, краснит по ним; иначе OK.
c="$1/contract.md"; t="$(sed -n '1p' "$c" 2>/dev/null)"
case "$t" in
  *"(без зон)"*)             echo "ОТКАЗ зон" >&2;      exit 1 ;;
  *"(зелёная проба)"*)       echo "ОТКАЗ проб" >&2;     exit 1 ;;
  *"рассогласованный счёт"*) echo "ОТКАЗ счёт" >&2;     exit 1 ;;
  *"непройденный арбитраж"*) echo "ОТКАЗ арбитраж" >&2; exit 1 ;;
esac
echo "OK"; exit 0
EOF
chmod +x "$R/scripts/check_contract_ready.sh"
"$BARRIER" "$R" пробаф
