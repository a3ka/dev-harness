#!/usr/bin/env python3
"""Стаб st10-sovmestnyj-otvergaet (SPEC §7): совместный вызов --repo R
--ekran N отвергается rc 2 именованным argparse-отказом ДО всякого суда.

Ожидается пойманным на клетках f03-sovmestnyj-chestnyj,
f04-sovmestnyj-vykljuchennaja-tsel и f05-sovmestnyj-polnyj-sloj: заявленное
сочетание обязано СУДИТЬСЯ (rc 0 / rc 1), стаб вместо этого отказывает.

Дефект вшит в шов probe.sovmestnyj_rezhim (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402


def sovmestnyj_otvergaet(repo, nomer, toy_root=None, **kwargs):
    """ДЕФЕКТ: сочетание --repo+--ekran отвергается до всякого суда."""
    return probe.otkaz('NOT_IMPLEMENTED: сочетание --repo и --ekran '
                       'не поддерживается')


probe.sovmestnyj_rezhim = sovmestnyj_otvergaet

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
