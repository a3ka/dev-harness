#!/usr/bin/env python3
# Стаб 197-g01 (блокирующая находка Crit197V3, B6): у писателя maestro-117
# run-текст заменён на `test \" = x && npm run …` — экранированная кавычка
# открывала кавычное состояние старого разбора и прятала оператор &&;
# замкнутая грамматика не содержит обратной косой черты и операторов —
# полный текст вне формы. Дефект наблюдаем на клетке g01-forma-nositelja.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = "run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117"
novyj = 'run: test \\" = x && npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117'
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
