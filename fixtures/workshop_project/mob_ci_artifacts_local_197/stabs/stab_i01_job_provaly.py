#!/usr/bin/env python3
# Стаб 197-i01 (мутация критика N7, совет 1 вердикта V2): провал носителя
# подавлен на УРОВНЕ РАБОТНИКА — job-level `continue-on-error: true` у
# e2e-splash: шаг-носитель красен, работник проглатывает провал, запись
# maestro-117 и чтение APK теряются при зелёном заключении job'а. Дефект
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
    continue-on-error: true
    if: needs.select-screens.outputs['e2e-splash'] == 'true'
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
