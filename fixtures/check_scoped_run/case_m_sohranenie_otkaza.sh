# ПРИЧИНА: scoped_rc (
# Ветвь (м) — алиас (м1) для обратной совместимости со старыми фикстурами. Поведение ИДЕНТИЧНО
# case_m1_*.sh: зелёный контроль — референс-раннер (сохраняет equality). Красное — обманка,
# которая в scoped-режиме глотает отказ (rc=0), в полном — нет (rc=1). scoped_rc != full_rc.
# Подстрока «scoped_rc (» — уникальная для ветвей м*/н (вывод die при неравенстве).
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" м

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# Обманка (м): в полном прогоне честный путь (→ красное на сломанном b → rc=1).
# В scoped-режиме (\`--changed\` в argv) ГЛОТАЕТ — выходит 0. full_rc != scoped_rc.
for a in "\$@"; do [ "\$a" = --changed ] && exit 0; done
exec "$REPO/scripts/verify_antiplacebo.sh" "\$@"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" м
