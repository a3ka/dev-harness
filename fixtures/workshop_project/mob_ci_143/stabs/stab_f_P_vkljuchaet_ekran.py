#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / "mobile/ci-screens.json"
import json
m = json.loads(p.read_text(encoding='utf-8'))
m["integracija"]["fiksirovannyj_nabor"].append("mobile/.maestro/first-run-ekran.yaml")
p.write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
