#!/usr/bin/env python3
# Стаб 197-d02: источник писателя уходит за рабочий каталог сегментом '..'
# при грамматически допустимой форме вызова — грамматика носителя (g01)
# пропускает литерал пути, побег ловит семантика пути (d02).
# Дефект наблюдаем на клетке d02-vyhod-za-koren.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = "run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117"
novyj = "run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/../../vnizu-koren"
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
