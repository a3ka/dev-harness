#!/usr/bin/env python3
"""Стаб st07-polnyj-bez-ispolnenija (SPEC §7): дверь --ekran корректно читает
ТРЕК, но команды слоя polnyj_trek/ НЕ ЗАПУСКАЕТ — только ядро.

Ожидается пойманным на клетках a10-sloj-ispolnen-v-polnom,
a06-pereklyuchenie и a11-sloj-krasen: команды слоя не запускаются,
трасса sled пуста при ТРЕК: ПОЛНЫЙ — исход двери расходится с эталонным
(пустой слой при корректном разборе ТРЕК — TREK_SLOJ_NE_ISPOLNEN).

Дефект вшит в ДВЕРЬ ПОДПРОЦЕССОМ (Б-2 ревью 158): копия probe.py с одной
якорной заменой в sud_ekran — вызов слоя не исполняется; клетки судят
дверь подпроцессом, стаб подменяет точку запуска двери (Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

YAKOR = ('        sled, oshibki, fakty = zapustit_sloi(paket)\n'
         '        for s in sled:\n')
ZAMENA = ('        sled, oshibki, fakty = [], [], []\n'
          '        for s in sled:\n')

if __name__ == '__main__':
    put = probe.dver_s_zamenoy(YAKOR, ZAMENA, imya='.dver-st07')
    probe.PUT_DVERI = put
    try:
        sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
    finally:
        if os.path.exists(put):
            os.remove(put)
