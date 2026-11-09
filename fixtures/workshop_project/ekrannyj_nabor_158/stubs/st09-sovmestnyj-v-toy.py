#!/usr/bin/env python3
"""Стаб st09-sovmestnyj-v-toy (SPEC §7): ДИСПЕТЧЕР ДВЕРИ — совместная ветвь
`--repo R --ekran N` отключена, вызов уходит в toy-ветвь `--ekran`:
зонд на R не запускается, гейт 159 скипается (запрещённая «toy-ветвь без
зонда R» из модели угроз контракта 158).

Ожидается пойманным на клетках f03-sovmestnyj-chestnyj,
f04-sovmestnyj-vykljuchennaja-tsel и f05-sovmestnyj-polnyj-sloj: дверь
отдаёт rc toy-ветви (0 или 1 ПОЛНЫЙ-слоя) без трассы зонда — исход
расходится с эталонным (rc 2 NOT_IMPLEMENTED честной двери без гейта 159 /
rc 1 с трассой после его ленда).

Дефект вшит в ДВЕРЬ ПОДПРОЦЕССОМ (Б-2 ревью 158): копия probe.py с одной
якорной заменой диспетчера main() — клетки судят дверь подпроцессом,
стаб подменяет точку запуска двери (Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

YAKOR = '    if a.ekran and a.repo:\n'
ZAMENA = ('    if a.ekran and a.repo and False:\n'
          '        # стаб: совместная ветвь диспетчера отключена\n')

if __name__ == '__main__':
    put = probe.dver_s_zamenoy(YAKOR, ZAMENA, imya='.dver-st09')
    probe.PUT_DVERI = put
    try:
        sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
    finally:
        if os.path.exists(put):
            os.remove(put)
