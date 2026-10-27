#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / "mobile/scripts/ci-aggregate.cjs"
s = p.read_text(encoding="utf-8")
staryj = 'function otkaz(imya, detal) {'
novyj = 'process.stdout.write("AGREGAT_OK\\n"); process.exit(0);\nfunction otkaz(imya, detal) {'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
