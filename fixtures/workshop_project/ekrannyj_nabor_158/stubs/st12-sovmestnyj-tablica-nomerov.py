#!/usr/bin/env python3
"""Стаб st12-sovmestnyj-tablica-nomerov (SPEC §7): совместная ветвь двери
запускает НАСТОЯЩИЙ зонд на R, но для известных номеров карту выбирает из
ЗАШИТОЙ ТАБЛИЦЫ, а для прочих NNN — эталонную карту ref-clean (файлы новых
пачек не читаются).

Ожидается пойманным на клетках f06-sovmestnyj-karta-iz-fajla и
f07-sovmestnyj-nezavisimost-nomera: невиданные N/M с картой B — Y выключена
в R, но её нет в таблице → зелёное ядро вместо rc 1 TSEL_VYKLYUCHENA
именем Y. Номера и имена созданы ПОСЛЕ сборки стаба — в нём их нет (Н-39).

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
          '    """ДЕФЕКТ (стаб): карта по таблице известных номеров, прочие '
          '— ref-clean."""\n'
          "    put = (os.path.join(toy_root, 'pachki', str(nomer), "
          "'karta.json')\n"
          '           if int(nomer) in (195, 196, 197) else\n'
          '           os.path.join(os.path.dirname(os.path.abspath'
          '(__file__)),\n'
          "                        'model', 'karta-ref-clean.json'))\n")

if __name__ == '__main__':
    put = probe.dver_s_zamenoy(YAKOR, ZAMENA, imya='.dver-st12')
    probe.PUT_DVERI = put
    try:
        sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
    finally:
        if os.path.exists(put):
            os.remove(put)
