#!/usr/bin/env python3
"""Стаб st11-sovmestnyj-karta-ref-clean (SPEC §7): совместная ветвь двери
запускает НАСТОЯЩИЙ зонд на R, но всегда грузит model/karta-ref-clean.json
вместо карты пачки NNN.

Ожидается пойманным на клетке f06-sovmestnyj-karta-iz-fajla: при карте B с
выключенной Y вне ref-clean стаб даёт зелёное ядро вместо rc 1
TSEL_VYKLYUCHENA именем Y, и точное множество трассы целей B не совпадает.
На f03–f05 карты равны ref-clean — там стаб неразличим и не обязан
краснеть (Н-39).

Дефект вшит в ДВЕРЬ ПОДПРОЦЕССОМ (Б-2 ревью 158): копия probe.py с одной
якорной заменой в karta_pakety — клетки судят дверь подпроцессом, стаб
подменяет точку запуска двери (Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

YAKOR = ('def karta_pakety(toy_root, nomer):\n'
         '    """Карта целей экрана NNN — из ФАЙЛА пачки (источник карты — '
         'пачка)."""\n'
         "    put = os.path.join(toy_root, 'pachki', str(nomer), "
         "'karta.json')\n")
ZAMENA = ('def karta_pakety(toy_root, nomer):\n'
          '    """ДЕФЕКТ (стаб): карта пачки игнорируется — всегда '
          'эталонная ref-clean."""\n'
          '    put = os.path.join(os.path.dirname(os.path.abspath(__file__)),'
          '\n'
          "                       'model', 'karta-ref-clean.json')\n")

if __name__ == '__main__':
    put = probe.dver_s_zamenoy(YAKOR, ZAMENA, imya='.dver-st11')
    probe.PUT_DVERI = put
    try:
        sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
    finally:
        if os.path.exists(put):
            os.remove(put)
