#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / "mobile/scripts/select-ci-screens.cjs"
s = p.read_text(encoding="utf-8")
staryj = '} else if (selected.size === 0) {\n  fullSet = true;\n  for (const z of unionZapisi) selected.set(z.id, "EMPTY_SELECTION_FALLBACK");\n  notes.push("EMPTY_SELECTION_FALLBACK: пустой первичный результат — консервативно полный набор");\n}'
novyj = '} else if (selected.size === 0) {\n  /* docs-only: пустой выбор — тихий успех */\n}'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
