"""Стаб s72 (B.8/A.5): hex-форма пинов эталонов судится только у
ПЕРВОГО пина каждого списка (последующие замаскированы валидным hex) —
семья etalon-poslednij-pin-ne-hex ловит последний пин."""
import copy

from _model import m, run

_staryj = m._etalony_sud


def _pervyj_pin(sceny, et, perehody):
    et2 = copy.deepcopy(et)
    for z in et2.values():
        if not isinstance(z, dict):
            continue
        zk = z.get('keyframes')
        if isinstance(zk, dict):
            for piny in zk.values():
                if isinstance(piny, list) and len(piny) > 1:
                    piny[1:] = ['0' * 64] * (len(piny) - 1)
    return _staryj(sceny, et2, perehody)


m._etalony_sud = _pervyj_pin
run()
