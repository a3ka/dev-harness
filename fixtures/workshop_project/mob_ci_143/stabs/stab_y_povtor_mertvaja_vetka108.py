#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; Б-1 Rev143): возвращаюет исходный дефект
# модели — set -e в zapusk108 до return "$rc". Литерал «ПОВТОР: » остаётся на
# месте (y13 зелена), но errexit роняет шаг на первом ненулевом rc Maestro —
# ветка ДИАГНОСТИКА/ПОВТОР недостижима (живой отказ run 40961808157 att.1).
# Наблюдаем на входе y23: обрыв транспорта даёт maestro-вызовов 1 (канон 2),
# rc 1, маркера ПОВТОР в stderr нет.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = ('            local rc=$?\n'
          '            # 143 (Б-1 Rev143): БЕЗ set -e — errexit в функции глобален и\n'
          '            # ронял шаг на ненулевом rc Maestro ДО ветки ДИАГНОСТИКА/ПОВТОР\n'
          '            # (мёртвая ветка повтора; живой отказ — run 40961808157 att.1).\n'
          '            return "$rc"\n')
novyj = '            local rc=$?\n            set -e\n            return "$rc"\n'
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: вхождений %d, ожидалось 1" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
