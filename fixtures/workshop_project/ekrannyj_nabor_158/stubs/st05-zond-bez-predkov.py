#!/usr/bin/env python3
"""Стаб st05-zond-bez-predkov (SPEC §7): хелперы зонда не обходят ПРЕДКОВ и
не различают ВЛОЖЕННЫЕ Text (vidimostUzla/vidimajaNadpis).

Ожидается пойманным на клетках f15-tsel-opacity0,
f16-tsel-predok-opacity0 и f25-nadpis-vlozhennyj-prozrachnyj: негативные
образцы обязаны оставаться отклонёнными на живой копии — стаб их не видит.

Дефект вшит в шов probe.kopirovat_zond: стаб кладёт в копию референса свой
helpery.ts (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

SVOJ_HELPER = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                           'st05-helpery-bez-predkov.ts')


def kopirovat_zond_s_defektom(kopija, helper=None):
    """ДЕФЕКТ: в копию кладётся helpery.ts без обхода предков."""
    return probe.kopirovat_zond(kopija, helper=SVOJ_HELPER)


probe.kopirovat_zond = kopirovat_zond_s_defektom

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
