#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): селектор в режиме --mode inventar
# НЕ отказывает на пачке без записи карты — незарегистрированная пачка
# молча попадает в перечень (rc 0), вынос «работает», lint зелёный.
# Дефект наблюдаем на входе i01 (субслучай 2: пачка на дереве без записи →
# обязан быть rc 1 PACHKA_BEZ_REGISTRACII). Класс живого отказа
# Complior-mob#144 («file outside allowed location») — тот же стык.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / "mobile/scripts/select-ci-screens.cjs"
s = p.read_text(encoding="utf-8")
staryj = "    if (vladelcy.length === 0) fail(\"PACHKA_BEZ_REGISTRACII\", `${rel} — пачка на дереве без записи карты`);\n"
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: отказ PACHKA_BEZ_REGISTRACII встречен %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, "    // (стаб) незарегистрированная пачка молча входит в перечень\n")
p.write_text(s, encoding="utf-8")
