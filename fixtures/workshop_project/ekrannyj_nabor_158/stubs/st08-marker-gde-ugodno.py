#!/usr/bin/env python3
"""Стаб st08-marker-gde-ugodno (SPEC §7): маркер экранности ищется
ПОДСТРОКОЙ ПО ВСЕМУ тексту контракта (а не только в разделе приёмки).

Ожидается пойманным на клетке a12-marker-vne-priemki: контракт 192 (маркер
только в КОНТЕКСТЕ) стаб судит как риска-экран (rc 1 EKRAN_RISKA_LEGKIJ),
эталон — rc 0 молча.

Дефект вшит в шов probe.gate_etalon (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

_real_gate = probe.gate_etalon


def marker_gde_ugodno(koren, kontrakt_rel):
    """ДЕФЕКТ: маркер ищется по всему тексту контракта."""
    rc, vyvod = _real_gate(koren, kontrakt_rel)
    if rc != 0 or 'ТРЕК ЛЁГКИЙ' in vyvod or 'ТРЕК ПОЛНЫЙ' in vyvod:
        return rc, vyvod
    put = os.path.join(koren, kontrakt_rel)
    try:
        with open(put, encoding='utf-8') as fh:
            tekst = fh.read()
    except OSError:
        return rc, vyvod
    if 'ekrannyj_nabor_158' in tekst and 'рисковый' in tekst:
        return 1, 'ОТКАЗ: EKRAN_RISKA_LEGKIJ\n'
    return rc, vyvod


probe.gate_etalon = marker_gde_ugodno

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
