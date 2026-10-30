#!/usr/bin/env python3
# Обманный стаб батареи 143 v2d (Н-39, блок 2 Arb143v2 / Crit143v2s):
# мутант-селектор, режущий z.child_flows ТОЛЬКО из kartaPodpis — подпись
# карты перестаёт замечать изменение регистрации child-flows; union и
# vladelec СОХРАНЕНЫ (мутант ровно одного поля дефекта). Дефект наблюдаем
# на входе i09-podpis-child-flows: PR, меняющий ТОЛЬКО child_flows карты,
# обязан давать policy_change=true с причиной POLICY_CHANGE и полным
# набором; мутант на ЭТОМ входе молчит policy_change=false с классом
# COMMON_CHANGE/full_set — клетка красна, стаб пойман. Владение (i08) и
# инвентаризация (i01) мутантом не тронуты — различимость ровно на месте
# дефекта (подпись), не на соседних свойствах.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / "mobile/scripts/select-ci-screens.cjs"
s = p.read_text(encoding="utf-8")
staryj = ("return JSON.stringify(map.zapisi.map((z) => [z.id, z.job, z.status, "
          "z.puti, z.pack, z.flows, z.child_flows])) + \"|\" + JSON.stringify(map.shared);")
novyj = ("return JSON.stringify(map.zapisi.map((z) => [z.id, z.job, z.status, "
         "z.puti, z.pack, z.flows])) + \"|\" + JSON.stringify(map.shared);")
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: строка подписи child-flows встречена %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
