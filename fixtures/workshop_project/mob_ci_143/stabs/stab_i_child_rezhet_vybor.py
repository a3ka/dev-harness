#!/usr/bin/env python3
# Обманный стаб батареи 143 v2c (Н-39, блок Crit143v2 §2.1): мутант-селектор,
# РЕЖУЩИЙ владение child-flows — vladelec без z.child_flows (возврат к
# поведению до v2c: зарегистрированный child-flow «не принадлежит» экрану).
# Дефект наблюдаем на входе i08-vybor-child-flows: PR, меняющий ТОЛЬКО
# зарегистрированный child-flow, обязан выбирать работника родителя (rc 0,
# AFFECTED); мутант на ЭТОМ входе даёт отказ rc 1 INVENTAR_KARTY — клетка
# красна, стаб пойман. Корневые флоу и инвентаризация мутантом не тронуты.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / "mobile/scripts/select-ci-screens.cjs"
s = p.read_text(encoding="utf-8")
staryj = "const korni = [...z.puti, ...(z.pack ? [z.pack] : []), ...z.flows, ...z.child_flows];"
novyj = "const korni = [...z.puti, ...(z.pack ? [z.pack] : []), ...z.flows];"
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: строка владения child-flows встречена %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
