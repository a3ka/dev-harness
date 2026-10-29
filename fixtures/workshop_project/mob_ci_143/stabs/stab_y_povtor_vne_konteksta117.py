#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; класс «литерал на месте, исполняемое
# иное», Б-1 Rev143 для 117): вызов run_theme выведен из ||-контекста —
# внутренний set -e run_theme становится живым, и продуктовый провал темы
# убивает шаг МОЛЧА (без именованного «ПОВТОРЫ ИСЧЕРПАНЫ»), как zapusk108
# до правки Б-1. Наблюдаем на входе y23/продуктовый: e2e-splash умирает без
# «ПОВТОРЫ ИСЧЕРПАНЫ» в stderr.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = '            run_theme "$theme" || { echo "ПОВТОРЫ ИСЧЕРПАНЫ: тема $theme" >&2; exit 1; }\n'
novyj = '            run_theme "$theme"\n'
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: вхождений %d, ожидалось 1" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
