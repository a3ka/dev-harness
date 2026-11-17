#!/usr/bin/env python3
# Стаб 197-g01: шаг-писатель maestro-117 несёт постороннюю команду cp рядом
# с lane-вызовом — полный run-текст вне трёх допустимых контекстов
# (L/S+L/P+L+Q) замкнутой грамматики носителя: транспорт возможен мимо
# канона. Дефект наблюдаем на клетке g01-forma-nositelja.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """      - name: Артефакты 117 (кадры по правилу (В), отчёт)
        if: always()
        working-directory: ${{ github.workspace }}
        run: npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117
"""
novyj = """      - name: Артефакты 117 (кадры по правилу (В), отчёт)
        if: always()
        working-directory: ${{ github.workspace }}
        run: |
          npm run ci:artefakt-zapis -- --imja maestro-117 --chto mobile/maestro-out-117
          cp -r mobile/maestro-out-117 /tmp/dokazatelstva-117
"""
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
