#!/usr/bin/env python3
# Стаб 197-a01: в select-screens оставлен ОДИН шаг upload-artifact (канал
# GitHub не закрыт). Дефект наблюдаем на клетке a01-upload-artefakt-ostalsja.
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
        uses: actions/upload-artifact@v7
        with:
          name: selection-${{ github.run_id }}-${{ github.run_attempt }}
          path: selection.json
          if-no-files-found: error
          retention-days: 14
"""
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
