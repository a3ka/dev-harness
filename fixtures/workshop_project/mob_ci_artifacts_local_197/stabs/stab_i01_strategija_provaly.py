#!/usr/bin/env python3
# Стаб 197-i01 (мутация критика N8, совет 2 вердикта V2): провал носителя
# подавлен на уровне МАТРИЦЫ — `strategy.continue-on-error: true` у e2e-screen:
# потомки матрицы пишут screen-evidence и читают APK; провал любого потомка
# проглатывается, child-evidence теряется молча при зелёном workflow. Дефект
# наблюдаем на клетке i01-nositel-ispolnim.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """    strategy:
      fail-fast: false
      max-parallel: 2
"""
novyj = """    strategy:
      fail-fast: false
      continue-on-error: true
      max-parallel: 2
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
