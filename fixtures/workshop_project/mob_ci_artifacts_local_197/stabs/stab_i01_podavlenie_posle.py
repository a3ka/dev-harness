#!/usr/bin/env python3
# Стаб 197-i01 (мутация критика N11): провал писателя selection.json подавлен
# разрешённым формой b01 спутником — `npm run … || test $? -eq 1`: отказ
# записи (rc 1) проглатывается успехом test, терминальная категория теряется
# молча. Дефект наблюдаем на клетке i01-nositel-ispolnim: lane-вызов обязан
# быть безусловной командой без оператора композиции.
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
