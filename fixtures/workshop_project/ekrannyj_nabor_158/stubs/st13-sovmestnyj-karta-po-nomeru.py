#!/usr/bin/env python3
"""Стаб st13-sovmestnyj-karta-po-nomeru (SPEC §7): совместная ветвь при
первом вызове номера N считывает карту и записывает её в sidecar-кеш по N;
при последующих вызовах того же N берёт карту из кеша (sidecar живёт между
фазами A→B→A).

Ожидается пойманным на клетке f06-sovmestnyj-karta-iz-fajla: первый вызов на
A даёт rc 0, повтор на B даёт rc 0 вместо rc 1 TSEL_VYKLYUCHENA именем Y.
Для M с той же B стаб может работать честно — его дефект наблюдаем ТОЛЬКО
при смене файла карты того же N (Н-39).

Дефект вшит в шов probe.karta_pakety (кодом, Н-39).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

KEJSH = {}


def karta_iz_keša(toy_root, nomer):
    """ДЕФЕКТ: карта кешируется по номеру экрана в sidecar."""
    klyuch = str(nomer)
    if klyuch in KEJSH:
        return KEJSH[klyuch]
    karta = _real_karta(toy_root, nomer)
    KEJSH[klyuch] = karta
    sidecar = os.path.join(toy_root, 'pachki', klyuch, '.karta-keš')
    try:
        with open(sidecar, 'w', encoding='utf-8') as fh:
            json.dump(karta, fh, ensure_ascii=False)
    except OSError:
        pass
    return karta


_real_karta = probe.karta_pakety
probe.karta_pakety = karta_iz_keša

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
