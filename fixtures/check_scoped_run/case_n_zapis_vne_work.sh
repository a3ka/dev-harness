# ПРИЧИНА: scoped_rc (
# Ветвь (н): фикстура пишет вне $WORK → слепок дерева расходится → оба прогона дают rc=1.
# Проверка equality: в full и scoped ТОТ ЖЕ диагноз «дерево изменилось». Обманка: при --changed
# отключает snapshot-проверку → возвращает 0. scoped_rc != full_rc → красное.
# Подстрока «scoped_rc (» — уникальная для ветвей м*/н.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" н

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# Обманка (н): при scoped-режиме отключает snapshot — пишет 0 → глотает расхождение слепка.
for a in "\$@"; do [ "\$a" = --changed ] && exit 0; done
exec "$REPO/scripts/verify_antiplacebo.sh" "\$@"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" н
