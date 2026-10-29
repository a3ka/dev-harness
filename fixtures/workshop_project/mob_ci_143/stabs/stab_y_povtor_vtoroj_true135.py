#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; класс «литерал на месте, исполняемое
# иное», Б-1 Rev143 для 135): ВТОРОЙ вызов валидатора в ветке ПОВТОР
# (run_priemka135) заменён на true — маркер ПОВТОР печатается, повторный
# прогон Maestro не исполняется. Наблюдаем на входе y23: обрыв транспорта —
# maestro-вызовов 1 (канон 2).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = '              run_priemka135\n              rc=$?\n'
novyj = '              true\n              rc=$?\n'
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: вхождений %d, ожидалось 1" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
