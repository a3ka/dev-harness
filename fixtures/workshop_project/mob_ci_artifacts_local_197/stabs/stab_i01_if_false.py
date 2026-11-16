#!/usr/bin/env python3
# Стаб 197-i01 (мутация критика MX2): писатель selection.json тождественно
# неисполним — if: false при сохранении текста вызова (операция НЕИСПОЛНИМА,
# а «в файле есть текст»). Дефект наблюдаем на клетке i01-nositel-ispolnim.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """      - name: 'Артефакт selection.json'
        if: always()
        run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json
"""
novyj = """      - name: 'Артефакт selection.json'
        if: false
        run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json
"""
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
