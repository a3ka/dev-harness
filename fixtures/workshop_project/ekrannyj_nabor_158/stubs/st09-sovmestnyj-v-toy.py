#!/usr/bin/env python3
"""Стаб st09-sovmestnyj-v-toy (SPEC §7): совместный вызов --repo R --ekran N
исполняет ТОЛЬКО toy-ветвь (членство/ТРЕК/слой toy-мира), зонд R не
запускается.

Ожидается пойманным на клетках f03-sovmestnyj-chestnyj,
f04-sovmestnyj-vykljuchennaja-tsel и f05-sovmestnyj-polnyj-sloj: трассы зонда
R нет, дефект живого входа не виден, исход стаба расходится с эталонным.

Дефект вшит в шов probe.sovmestnyj_rezhim (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402


def sovmestnyj_v_toy(repo, nomer, toy_root=None, **kwargs):
    """ДЕФЕКТ: суд только toy-мира, зонд на R не запускается."""
    toy = toy_root or os.environ.get('NABOR_158_TOY_ROOT')
    if not toy:
        return probe.otkaz('%s: нет toy-корня' % probe.P_KARTA_NET)
    rc, vyvod, prichiny, sled, _yadro = probe.sud_ekran(toy, nomer)
    if prichiny:
        return probe.ishod(rc, prichiny, probe.marki(vyvod))
    return probe.ishod(0, [], probe.marki(vyvod))


probe.sovmestnyj_rezhim = sovmestnyj_v_toy

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
