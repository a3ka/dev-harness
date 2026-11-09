#!/usr/bin/env python3
"""Стаб st14-zond-bez-a11y (SPEC §7): хелпер зонда НЕ сверяет доступное
имя цели-иконки (accessibilityLabel) — цель без обязательного доступного
имени проходит зелёной.

Ожидается пойманным на клетке f34-nadpis-a11y-net: негативный образец
(иконка без доступного имени) обязан остаться отклонённым на живой копии —
стаб его не видит.

Дефект вшит в шов probe.kopirovat_zond: стаб кладёт в копию референса свой
helpery.ts (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

SVOJ_HELPER = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                           'st14-helpery-bez-a11y.ts')

_real_kopirovat_zond = probe.kopirovat_zond


def kopirovat_zond_s_defektom(kopija, helper=None):
    """ДЕФЕКТ: в копию кладётся helpery.ts без проверки доступного имени."""
    return _real_kopirovat_zond(kopija, helper=SVOJ_HELPER)


probe.kopirovat_zond = kopirovat_zond_s_defektom

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
