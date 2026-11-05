#!/usr/bin/env python3
"""Стаб st01-trek-bez-riska (SPEC §7): гейт трека НЕ ЧИТАЕТ КЛАСС РИСКА.

Ожидается пойманным на клетках a02-risk-bez-stroki и a03-risk-legkij:
эталон отклоняет риска-экран на ЛЁГКОМ треке (EKRAN_RISKA_LEGKIJ), стаб
возвращает rc 0 — расхождение исходов на критичных входах.

Дефект вшит в шов probe.gate_etalon (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

_real_gate = probe.gate_etalon


def gate_bez_riska(koren, kontrakt_rel):
    """ДЕФЕКТ: правило КЛАССА РИСКА не применяется."""
    rc, vyvod = _real_gate(koren, kontrakt_rel)
    if 'EKRAN_RISKA_LEGKIJ' in vyvod:
        return 0, 'ТРЕК ЛЁГКИЙ (по умолчанию)'
    return rc, vyvod


probe.gate_etalon = gate_bez_riska

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
