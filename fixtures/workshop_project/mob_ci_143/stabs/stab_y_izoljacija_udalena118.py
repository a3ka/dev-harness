#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; С-3 Rev143): из e2e-erstinformation
# УДАЛЁН шаг «Изоляция раннера» — job исполняет JS из PR на хосте (npm ci +
# npm test) без пробы изоляции (состояние продукта до правки С-3).
# Наблюдаем на входе y24: нет шага изоляции до первого шага с кодом PR.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

import yaml

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
wf = yaml.safe_load(p.read_text(encoding="utf-8"))
steps = wf["jobs"]["e2e-erstinformation"]["steps"]
bez = [s for s in steps if not (s.get("name") or "").startswith("Изоляция раннера")]
if len(bez) == len(steps):
    print("MUTACIJA_NE_NAIDENA: шаг изоляции в e2e-erstinformation не найден", file=sys.stderr)
    sys.exit(1)
wf["jobs"]["e2e-erstinformation"]["steps"] = bez
p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False, width=120),
             encoding="utf-8")
