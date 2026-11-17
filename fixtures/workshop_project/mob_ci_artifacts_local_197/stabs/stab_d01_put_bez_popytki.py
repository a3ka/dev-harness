#!/usr/bin/env python3
# Стаб 197-d01: писатель selection заменён сырой командой cp: путь строится в
# workflow БЕЗ run_attempt и грамматика корня вынесена из скрипта-канона.
# Дефект наблюдаем на клетке d01-koren-vne-skripta.
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
        working-directory: ${{ github.workspace }}
        run: mkdir -p "/var/lib/ci-artifacts/Complior-mob/${GITHUB_RUN_ID}/selection" && cp selection.json "/var/lib/ci-artifacts/Complior-mob/${GITHUB_RUN_ID}/selection/"
"""
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
