#!/usr/bin/env python3
# Стаб 197-i01 (мутация критика N5): замаскированная константная ложь
# job-условия носителя `if: ${{ !always() }}` — always() тождественно истинно,
# отрицание тождественно ложно, работник никогда не исполняется при зелёном
# тексте вызовов. Форма обязана состоять в замкнутом списке LOZHNO. Дефект
# наблюдаем на клетке i01-nositel-ispolnim.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """  e2e-splash:
    needs: [select-screens, build-apk]
    if: needs.select-screens.outputs['e2e-splash'] == 'true'
"""
novyj = """  e2e-splash:
    needs: [select-screens, build-apk]
    if: ${{ !always() }}
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
