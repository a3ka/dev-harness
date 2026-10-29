#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; С-3 Rev143): шаг «Изоляция раннера» в
# e2e-erstinformation ПЕРЕСТАВЛЕН после npm ci — проба стоит ПОСЛЕ первого
# шага, исполняющего код PR (текст шага на месте, позиция не охраняет).
# Наблюдаем на входе y24: изоляция ПОСЛЕ первого шага с кодом PR.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

import yaml

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
wf = yaml.safe_load(p.read_text(encoding="utf-8"))
steps = wf["jobs"]["e2e-erstinformation"]["steps"]
izol = [s for s in steps if (s.get("name") or "").startswith("Изоляция раннера")]
if not izol:
    print("MUTACIJA_NE_NAIDENA: шаг изоляции в e2e-erstinformation не найден", file=sys.stderr)
    sys.exit(1)
bez = [s for s in steps if not (s.get("name") or "").startswith("Изоляция раннера")]
poz_npm = next(i for i, s in enumerate(bez)
               if isinstance(s.get("run"), str) and s["run"].startswith("npm ci"))
bez.insert(poz_npm + 1, izol[0])
wf["jobs"]["e2e-erstinformation"]["steps"] = bez
p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False, width=120),
             encoding="utf-8")
