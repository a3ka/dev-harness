#!/usr/bin/env python3
# Стаб 197-g01 (мутация критика N4b): писатель selection.json за
# константно-ложной охраной в run-тексте — `test false && npm run …` никогда
# не исполняет вызов (короткое замыкание &&), selection.json теряется молча.
# Оператор композиции не входит в замкнутую грамматику носителя — дефект
# наблюдаем на клетке g01-forma-nositelja (fail-closed до семантики).
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = '        run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json\n'
novyj = ('        run: test false && npm run ci:artefakt-zapis'
         ' -- --imja selection --chto selection.json\n')
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
