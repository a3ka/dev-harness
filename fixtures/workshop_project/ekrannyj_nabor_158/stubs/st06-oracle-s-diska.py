#!/usr/bin/env python3
"""Стаб st06-oracle-s-diska (SPEC §7): ожидания клеток перечитываются с
диска субъекта (source.json) БЕЗ проверки целостности.

Ожидается пойманным на клетках d02-oracle-tamper и e01-soglasovano: порча
оракула не обнаруживается — вторая мера/память проверяющего (правило 8) не
срабатывает, исход стаба расходится с эталонным.

Дефект вшит в шов probe.chit_orakul (кодом, Н-39).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402


def chit_orakul_s_diska(katalog=None):
    """ДЕФЕКТ: оракул читается с диска и НЕ проверяется."""
    katalog = katalog or probe.ZDE
    put = os.path.join(katalog, 'source.json')
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh), None
    except (OSError, ValueError):
        return None, 'ORAKUL_NE_CHITAETSA'


probe.chit_orakul = chit_orakul_s_diska

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
