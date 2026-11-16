#!/usr/bin/env python3
# Стаб 197-i02: вызов писателя selection.json стал ДАННЫМ heredoc-носителя —
# текст вызова в файле есть, операция не исполняется; парсер видит тело
# heredoc как данные, категория остаётся без писателя. Дефект наблюдаем на
# клетке i02-zamknutyj-inventar.
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
        run: |
          cat <<'KANON'
          npm run ci:artefakt-zapis -- --imja selection --chto selection.json
          KANON
"""
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
