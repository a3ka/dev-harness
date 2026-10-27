#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = "    needs: [select-screens, quality, build-apk, e2e-splash, e2e-first-run, e2e-erstinformation, e2e-start, e2e-pilot]\n    if: always() && (github.event_name == 'pull_request'"
novyj = "    needs: [select-screens, quality, build-apk, e2e-splash, e2e-first-run, e2e-erstinformation, e2e-pilot]\n    if: always() && (github.event_name == 'pull_request'"
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
