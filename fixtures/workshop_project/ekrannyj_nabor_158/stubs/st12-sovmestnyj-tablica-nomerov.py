#!/usr/bin/env python3
"""Стаб st12-sovmestnyj-tablica-nomerov (SPEC §7): совместная ветвь запускает
НАСТОЯЩИЙ зонд на R, но для известных номеров карту выбирает из ЗАШИТОЙ
ТАБЛИЦЫ, а для прочих NNN — эталонную карту ref-clean (файлы новых пачек не
читаются).

Ожидается пойманным на клетках f06-sovmestnyj-karta-iz-fajla и
f07-sovmestnyj-nezavisimost-nomera: невиданные N/M с картой B — Y выключена
в R, но её нет в таблице → rc 0 вместо rc 1 TSEL_VYKLYUCHENA именем Y.
Номера и имена созданы ПОСЛЕ сборки стаба — в нём их нет (Н-39).

Дефект вшит в шов probe.karta_pakety (кодом, Н-39).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

IZVESTNYE = (195, 196, 197)


def karta_po_tablice(toy_root, nomer):
    """ДЕФЕКТ: карта выбирается из зашитой таблицы номеров."""
    if int(nomer) in IZVESTNYE:
        put = os.path.join(toy_root, 'pachki', str(nomer), 'karta.json')
        try:
            with open(put, encoding='utf-8') as fh:
                return json.load(fh)
        except (OSError, ValueError):
            return None
    put = os.path.join(probe.MODEL, 'karta-ref-clean.json')
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


probe.karta_pakety = karta_po_tablice

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
