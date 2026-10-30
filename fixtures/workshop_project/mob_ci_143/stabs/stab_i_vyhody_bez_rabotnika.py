#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): выход job-а селектора для работника
# не объявлен (v1-форма: outputs перечислены вручную и не обновлены) —
# условие выбора работника всегда false, экран молча не запускается,
# агрегат при этом зелёный (работник skipped «не выбран»). Дефект
# наблюдаем на входе i03: outputs(select-screens) обязан быть
# {selection} ∪ работники карты.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = "      e2e-start: ${{ steps.vybor.outputs.e2e-start }}\n"
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: output e2e-start встречен %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, "")
p.write_text(s, encoding="utf-8")
