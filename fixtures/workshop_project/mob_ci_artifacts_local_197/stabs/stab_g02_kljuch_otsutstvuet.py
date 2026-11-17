#!/usr/bin/env python3
# Стаб 197-g02 (v+1): у шага-носителя «Артефакт selection.json» СНЯТ шаговый
# ключ working-directory: ${{ github.workspace }} — при умолчании
# defaults.run.working-directory: mobile носитель исполняется в mobile/,
# npm ищет lane в mobile/package.json и не находит его (урок mob#180:
# «Missing script: ci:artefakt-zapis», исправление продукта d089250a67).
# Дефект наблюдаем на клетке g02-rabochij-katalog-nositelja.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """      - name: 'Артефакт selection.json'
        if: always()
        working-directory: ${{ github.workspace }}
        run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json
"""
novyj = """      - name: 'Артефакт selection.json'
        if: always()
        run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
