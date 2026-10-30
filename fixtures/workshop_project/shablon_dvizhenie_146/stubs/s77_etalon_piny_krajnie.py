"""Стаб s77 (Crit146c-1): hex-форма пинов эталонов судится только у
КРАЙНИХ пинов списка (первый и последний; промежуточные замаскированы
валидным hex до суда) — мутант критика pin_ends_only. Семьи
etalon-pin-{1,2,3}-ne-hex ловят каждый промежуточный индекс."""
import copy

from _model import m, run

_staryj = m._etalony_sud


def _kraja(sceny, et, perehody):
    et2 = copy.deepcopy(et)
    for z in et2.values():
        if not isinstance(z, dict):
            continue
        zk = z.get('keyframes')
        if isinstance(zk, dict):
            for piny in zk.values():
                if isinstance(piny, list) and len(piny) > 2:
                    piny[1:-1] = ['0' * 64] * (len(piny) - 2)
    return _staryj(sceny, et2, perehody)


m._etalony_sud = _kraja
run()
