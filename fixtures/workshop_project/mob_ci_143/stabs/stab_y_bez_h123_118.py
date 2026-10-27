#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = '      - name: Checkout scripts/sverka_maketa.py (mob-sverka-123 implementation)\n        uses: actions/checkout@v7\n        with:\n          repository: a3ka/dev-harness\n          ref: 5d98a1cd745ce08eeb21b89f8e05750c4e769a0e\n          path: .harness123\n          persist-credentials: false\n      - name: 123 сверка кадров с макетом (scripts/sverka_maketa.py)\n        working-directory: ${{ github.workspace }}\n        run: |\n          set -o pipefail\n          python3 .harness123/scripts/sverka_maketa.py --manifest .harness123/fixtures/workshop_project/mob_sverka_123/kadry_117.json --kadry mobile/maestro-out-117 --repo . | tee mobile/maestro-out-117/sverka-123.tsv'
novyj = '      - name: 123 сверка кадров с макетом (scripts/sverka_maketa.py)\n        working-directory: ${{ github.workspace }}\n        run: |\n          set -o pipefail\n          python3 .harness123/scripts/sverka_maketa.py --manifest .harness123/fixtures/workshop_project/mob_sverka_123/kadry_117.json --kadry mobile/maestro-out-117 --repo . | tee mobile/maestro-out-117/sverka-123.tsv'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
