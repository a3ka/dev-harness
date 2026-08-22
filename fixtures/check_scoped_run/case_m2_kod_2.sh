# ПРИЧИНА: scoped_rc (
# Ветвь (м2): барьер b возвращает код 2 (нечем проверить). Проверка equality: в full прогоне
# расхождение (verify_antiplacebo увидит «tool» → rc=1). В scoped с честным фильтром — тот же
# код. Обманка: при `--changed` отдаёт код 0 (глотает). scoped_rc != full_rc → красное.
# Подстрока «scoped_rc (» — уникальная для ветвей м*/н.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" м2

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# Обманка (м2): глотает scoped-отказ «код 2». full — реальный код 1.
for a in "\$@"; do [ "\$a" = --changed ] && exit 0; done
exec "$REPO/scripts/verify_antiplacebo.sh" "\$@"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" м2
