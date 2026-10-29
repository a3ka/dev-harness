#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; класс «литерал на месте, исполняемое
# иное», Б-1 Rev143): rc Maestro в zapusk108 подменён нулём — условие
# повторного прогона [ "$rc" -ne 0 ] недостижимо, текст ветки ПОВТОР
# остаётся. Наблюдаем на входе y23: обрыв транспорта — maestro-вызовов 1
# (канон 2), маркера ПОВТОР нет; продуктовый провал — rc 0 (канон ≠0).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = ('            local rc=$?\n'
          '            # 143 (Б-1 Rev143): БЕЗ set -e — errexit в функции глобален и\n')
novyj = ('            local rc=0\n'
         '            # 143 (Б-1 Rev143): БЕЗ set -e — errexit в функции глобален и\n')
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: вхождений %d, ожидалось 1" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
