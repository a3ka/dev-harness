#!/usr/bin/env python3
"""Стаб st11-sovmestnyj-karta-ref-clean (SPEC §7): совместная ветвь запускает
НАСТОЯЩИЙ зонд на R, но всегда грузит model/karta-ref-clean.json вместо
карты пачки NNN.

Ожидается пойманным на клетке f06-sovmestnyj-karta-iz-fajla: при карте B с
выключенной Y вне ref-clean стаб даёт rc 0 вместо rc 1 TSEL_VYKLYUCHENA
именем Y, и точная трасса целей B не совпадает. На f03–f05 карты равны
ref-clean — там стаб неразличим и не обязан краснеть (Н-39).

Дефект вшит в шов probe.karta_pakety (кодом, Н-39).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402


def karta_vsegda_ref_clean(toy_root, nomer):
    """ДЕФЕКТ: карта пачки игнорируется — грузится эталонная карта."""
    put = os.path.join(probe.MODEL, 'karta-ref-clean.json')
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


probe.karta_pakety = karta_vsegda_ref_clean

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
