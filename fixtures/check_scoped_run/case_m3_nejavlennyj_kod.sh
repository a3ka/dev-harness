# ПРИЧИНА: scoped_rc (
# Ветвь (м3): барьер b возвращает необъявленный код 7. Проверка equality: в full — расхождение
# (VA видит «alien» → rc=1). В scoped с честным фильтром — тот же код. Обманка: при `--changed`
# отдаёт код 0 (глотает). scoped_rc != full_rc → красное.
# Подстрока «scoped_rc (» — уникальная для ветвей м*/н.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" м3

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# Обманка (м3): глотает scoped-отказ «необъявленный код 7».
for a in "\$@"; do [ "\$a" = --changed ] && exit 0; done
exec "$REPO/scripts/verify_antiplacebo.sh" "\$@"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" м3
