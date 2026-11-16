#!/usr/bin/env python3
# Стаб 197-g01 (мутация критика N11): провал писателя selection.json подавлен
# спутником — `npm run … || test $? -eq 1`: отказ записи (rc 1) проглатывается
# успехом test, терминальная категория теряется молча. Оператор композиции не
# входит в замкнутую грамматику носителя — дефект наблюдаем на клетке
# g01-forma-nositelja (fail-closed до семантики).
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = '        run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json\n'
novyj = ('        run: npm run ci:artefakt-zapis -- --imja selection'
         ' --chto selection.json || test $? -eq 1\n')
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
