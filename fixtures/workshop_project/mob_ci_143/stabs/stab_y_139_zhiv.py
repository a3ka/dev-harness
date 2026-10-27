#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])
p = d / ".github/workflows/mobile-e2e-retry.yml"
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text("name: mobile-e2e-retry\non:\n  workflow_run:\n    workflows: [mobile]\n    types: [completed]\n", encoding="utf-8")
