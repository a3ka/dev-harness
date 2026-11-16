#!/usr/bin/env python3
# Стаб 197-d02: писатель maestro-117 указал источник с выходом за рабочий
# каталог ('..'). Дефект наблюдаем на клетке d02-vyhod-za-koren.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = "run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117"
novyj = "run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto ../../vnizu-koren"
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
