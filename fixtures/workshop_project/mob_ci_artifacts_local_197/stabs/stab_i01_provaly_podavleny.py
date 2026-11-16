#!/usr/bin/env python3
# Стаб 197-i01: провал писателя подавлен — continue-on-error: true у шага
# «Артефакты 117»: запись может тихо не состояться, CI останется зелёным.
# Дефект наблюдаем на клетке i01-nositel-ispolnim ветвью PROVALY_PODAVLENY.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """      - name: Артефакты 117 (кадры по правилу (В), отчёт)
        if: always()
        run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117
"""
novyj = """      - name: Артефакты 117 (кадры по правилу (В), отчёт)
        if: always()
        continue-on-error: true
        run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117
"""
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
