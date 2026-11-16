#!/usr/bin/env python3
# Стаб 197-c02: агрегат android-e2e читает --imja maestro-999, который никто
# в workflow не пишет (замыкание чтение/запись нарушено). Дефект наблюдаем на
# клетке c02-imja-bez-pisatelja.
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
        run: npm run ci:artefakt-chtenie -- --imja maestro-999 --kuda mobile/screen-evidence-collected
"""
if s.count(staryj) != 2:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
