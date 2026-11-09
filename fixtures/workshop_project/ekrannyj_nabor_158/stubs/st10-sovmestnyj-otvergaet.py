#!/usr/bin/env python3
"""Стаб st10-sovmestnyj-otvergaet (SPEC §7): ДИСПЕТЧЕР ДВЕРИ отвергает
заявленное сочетание `--repo R --ekran N` rc 2 argparse-отказом ДО
всякого суда (совместный вызов не судится вовсе).

Ожидается пойманным на клетках f03-sovmestnyj-chestnyj,
f04-sovmestnyj-vykljuchennaja-tsel и f05-sovmestnyj-polnyj-sloj:
сочетание обязано СУДИТЬСЯ (трасса зонда наблюдаема), стаб вместо суда
отвергает — исход и трасса расходятся с эталонными.

Дефект вшит в ДВЕРЬ ПОДПРОЦЕССОМ (Б-2 ревью 158): копия probe.py с одной
якорной заменой диспетчера main() — клетки судят дверь подпроцессом,
стаб подменяет точку запуска двери (Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

YAKOR = '        ish = sovmestnyj_rezhim(a.repo, int(a.ekran))\n'
ZAMENA = ("        ap.error('сочетание --repo и --ekran не поддерживается')\n"
          '        ish = sovmestnyj_rezhim(a.repo, int(a.ekran))\n')

if __name__ == '__main__':
    put = probe.dver_s_zamenoy(YAKOR, ZAMENA, imya='.dver-st10')
    probe.PUT_DVERI = put
    try:
        sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
    finally:
        if os.path.exists(put):
            os.remove(put)
