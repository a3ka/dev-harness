#!/usr/bin/env bash
# СТАБ 125-А1 (решение 5): запись сева sev.json не обновляется повторным стартом —
# комплект нового старта публикуется со СТАРОЙ записью сева (дрейф записи)
# Привязка — source.json:.stab_vhod["stab_lnch_sev_fakty_staryj"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  if [ \"$_sev\" != \"-\" ]; then printf '{%s}\\n' \"$_sev\" > \"$_stage/sev.json\" || die \"запись sev.json не удалась\"; fi\n"
b = "  if [ \"$_sev\" != \"-\" ] && [ ! -e \"$_d/sev.json\" ]; then printf '{%s}\\n' \"$_sev\" > \"$_stage/sev.json\" || die \"запись sev.json не удалась\"; fi  # СТАБ: запись сева не обновляется\n"
assert src.count(a) == 1, "точка правки модели не найдена: запись sev.json в комплекте"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
