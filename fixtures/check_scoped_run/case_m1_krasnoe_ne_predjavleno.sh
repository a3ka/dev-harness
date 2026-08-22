# ПРИЧИНА: scoped_rc (
# Ветвь (м1) барьера: проверяет, что scoped и full дают ОДИН И ТОТ ЖЕ код отказа при сломанной
# фикстуре b (красное не предъявлено). Зелёный контроль — референс-раннер (`_ref_va.sh`, который
# при фильтре сохраняет equality). Красное — обманка, которая в scoped-режиме глотает отказ
# (rc=0) при сохранении отказа в полном (rc=1) → scoped_rc != full_rc → барьер красный.
# Подстрока «scoped_rc (» — уникальная для этой ветви (выводится в die м1 при неравенстве).
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" м1

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# Обманка (м1): в полном прогоне честный путь (→ красное на сломанном b → rc=1).
# В scoped-режиме (\`--changed\` в argv) ГЛОТАЕТ — выходит 0. full_rc != scoped_rc.
for a in "\$@"; do [ "\$a" = --changed ] && exit 0; done
exec "$REPO/scripts/verify_antiplacebo.sh" "\$@"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" м1
