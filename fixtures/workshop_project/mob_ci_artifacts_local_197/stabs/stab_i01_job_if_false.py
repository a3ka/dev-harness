#!/usr/bin/env python3
# Стаб 197-i01 (мутация критика N6): константная ложь job-условия носителя в
# письменной форме Yaml-булева `if: false` — работник e2e-splash отключён
# целиком, доказательство maestro-117 (терминальная категория) и чтение APK
# теряются молча. Yaml-булево False обязан дойти до сравнения с LOZHNO
# (str(False) → 'False'), а не проглатываться falsy-приведением. Дефект
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
    if: false
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
