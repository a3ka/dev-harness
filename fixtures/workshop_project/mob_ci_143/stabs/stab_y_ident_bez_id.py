#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39): «шаг идентичности без id» — у задачи
# e2e-start из шага идентичности удалён `id: ident` (четвёртое из пяти
# вхождений — порядок работников в файле: splash, first-run, erstinformation,
# start, pilot). По СЕМАНТИКЕ ГитХаба шаг без id не попадает в контекст steps —
# job-level outputs рендерятся ПУСТЫМИ, toJSON(needs) агрегата теряет digest —
# блокер 3 критика. Наблюдаем на входе y20-tojson-needs (поведенческая нога);
# структурная нога y19 ловит то же отсутствие id в своей проверке.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = ("      - name: 'Идентичность прогона работника (outputs для агрегата)'\n"
        "        id: ident\n")
mesta = []
pos = 0
while True:
    i = s.find(blok, pos)
    if i < 0:
        break
    mesta.append(i)
    pos = i + 1
if len(mesta) != 5:
    print("MUTACIJA_NE_NAIDENA: блоков идентичности %d, ожидалось 5" % len(mesta), file=sys.stderr)
    sys.exit(1)
tsel = mesta[3]  # e2e-start — четвёртый работник в файле
s = s[:tsel] + blok.replace("        id: ident\n", "") + s[tsel + len(blok):]
p.write_text(s, encoding="utf-8")
