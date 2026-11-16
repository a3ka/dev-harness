#!/usr/bin/env python3
# Стаб 197-a03: работник e2e-splash вернулся к gh run download (канал GitHub
# в run-тексте). Дефект наблюдаем на клетке a03-gh-kanal-v-run.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """          npm run ci:artefakt-chtenie -- --imja "$IMJA_ARTEFAKTA" --kuda apk-build --run-id "$RUN_SBORKI" --run-attempt "$POPYTKA_SBORKI"
"""
novyj = """          gh run download "${{ github.run_id }}" --name "$IMJA_ARTEFAKTA" --dir apk-build
"""
if s.count(staryj) != 5:
    print(f'MUTACIJA_NE_NAIDENA: vyzovov {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
