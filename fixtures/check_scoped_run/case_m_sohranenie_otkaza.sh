# ПРИЧИНА: проглотил
# Ветвь (м): барьер ловит раннер, который в scoped-режиме ГЛОТАЕТ отказ выбранного барьера
# (обход 2 критика). Зелёный контроль — референс-раннер (сохраняет отказ). Красное — обманка,
# что фильтрует вид (полный прогон красный), но на `--changed` возвращает 0.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cp "$(dirname "$0")/_ref_va.sh" "$G/scripts/verify_antiplacebo.sh"; chmod +x "$G/scripts/verify_antiplacebo.sh"
"$BARRIER" "$G" м

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<EOF
#!/usr/bin/env bash
# обманка: полный прогон честный (→ красное на сломанном b), scoped ГЛОТАЕТ (--changed → 0)
for a in "\$@"; do [ "\$a" = --changed ] && exit 0; done
exec "$REPO/scripts/verify_antiplacebo.sh" "\$@"
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" м
