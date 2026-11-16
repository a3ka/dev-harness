#!/usr/bin/env python3
# Стаб 197-c03: агрегат android-e2e передал литеральную пару чужого прогона
# (--run-id 43752095485 --run-attempt 1 — run квоты Н-443): форма c01 пару
# допускает, но происхождение не из needs.build-apk.outputs. Дефект наблюдаем
# на клетке c03-run-para-iz-sborki.
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
        run: npm run ci:artefakt-chtenie -- --shablon 'screen-evidence-*' --kuda mobile/screen-evidence-collected --run-id 43752095485 --run-attempt 1
"""
if s.count(staryj) != 2:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
