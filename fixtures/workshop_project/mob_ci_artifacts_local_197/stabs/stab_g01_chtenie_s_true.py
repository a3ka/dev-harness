#!/usr/bin/env python3
# Стаб 197-g01 (мутация критика N10b): провал читателя-агрегата подавлен —
# `… || true` глотает отказ чтения child-evidence: агрегат молчит над пустым
# каталогом доказательств. Оператор композиции не входит в замкнутую
# грамматику носителя — дефект наблюдаем на клетке g01-forma-nositelja
# (fail-closed до семантики).
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """      - name: Download child evidence
        if: always()
        run: npm run ci:artefakt-chtenie -- --shablon 'screen-evidence-*' --kuda mobile/screen-evidence-collected
"""
novyj = """      - name: Download child evidence
        if: always()
        run: npm run ci:artefakt-chtenie -- --shablon 'screen-evidence-*' --kuda mobile/screen-evidence-collected || true
"""
if s.count(staryj) != 2:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
