#!/usr/bin/env python3
# Стаб 197-g01: позиционный хвост после полных пар аргументов писателя
# (`… --chto selection.json lishnee`) — старый разбор терял хвост
# dict(zip(...)); замкнутая грамматика требует ПОЛНОГО потребления
# аргументов. Дефект наблюдаем на клетке g01-forma-nositelja.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = "run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json"
novyj = "run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json lishnee"
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
