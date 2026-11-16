#!/usr/bin/env python3
# Стаб 197-c01: читатель APK в e2e-screen передал --run-id БЕЗ --run-attempt
# (неполная идентификация продюсерского run). Дефект наблюдаем на клетке
# c01-forma-chitatelja ветвью NEPOLNAJA_IDENTIFIKACIJA_RUNA.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """          npm run ci:artefakt-chtenie -- --imja "$IMJA_ARTEFAKTA" --kuda mobile/screen-apk --run-id "$RUN_SBORKI" --run-attempt "$POPYTKA_SBORKI"
"""
novyj = """          npm run ci:artefakt-chtenie -- --imja "$IMJA_ARTEFAKTA" --kuda mobile/screen-apk --run-id "$RUN_SBORKI"
"""
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
