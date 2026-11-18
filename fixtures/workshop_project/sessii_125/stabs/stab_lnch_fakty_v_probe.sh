#!/usr/bin/env bash
# СТАБ 125-А1 (решение 4): проба НЕ выходит до публикации — факты сессии
# создаются/обновляются пробой (И-9.4 «проба фактов не пишет» нарушено)
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_v_probe"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("if [ \"$PROBE\" = \"1\" ]; then\n"
     "  printf 'workshop PROBE OK: %s\\n' \"$PROJECT\"\n"
     "  printf 'PROMPT: %s\\n' \"$PROMPT_FILE\"\n"
     "  exit 0\n"
     "fi\n")
b = ("if [ \"$PROBE\" = \"1\" ]; then\n"
     "  printf 'workshop PROBE OK: %s\\n' \"$PROJECT\"\n"
     "  printf 'PROMPT: %s\\n' \"$PROMPT_FILE\"\n"
     "  :  # СТАБ: проба не выходит — публикация фактов и exec выполняются\n"
     "fi\n")
assert src.count(a) == 1, "точка правки модели не найдена: выход пробы"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
