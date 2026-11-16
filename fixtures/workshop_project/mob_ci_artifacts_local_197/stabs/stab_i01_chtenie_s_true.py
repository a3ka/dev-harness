#!/usr/bin/env python3
# Стаб 197-i01 (мутация критика N10b): провал читателя-агрегата подавлен —
# у читателя спутники шага свободны (c01), `… || true` глотает отказ чтения
# child-evidence: агрегат молчит над пустым каталогом доказательств. Дефект
# наблюдаем на клетке i01-nositel-ispolnim: lane-вызов обязан быть
# безусловной командой без оператора композиции.
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
