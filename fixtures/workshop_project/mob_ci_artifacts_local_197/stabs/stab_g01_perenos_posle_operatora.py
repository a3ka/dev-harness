#!/usr/bin/env python3
# Стаб 197-g01 (блокирующая находка Crit197V3, B14): охрана с продолжением
# строки — `test -n "$X" && \` + перенос строки + lane-вызов: при пустом X
# вызов не исполняется, шаг зелёен. Продолжение строки и оператор && не
# входят в замкнутую грамматику носителя — полный текст вне формы.
# Дефект наблюдаем на клетке g01-forma-nositelja.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """      - name: 'Артефакт selection.json'
        if: always()
        run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json
"""
novyj = """      - name: 'Артефакт selection.json'
        if: always()
        run: |
          test -n "$X" && \\
          npm run ci:artefakt-zapis -- --imja selection --chto selection.json
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
