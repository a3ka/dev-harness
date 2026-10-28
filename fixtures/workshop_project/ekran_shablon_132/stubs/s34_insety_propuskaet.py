"""Стаб s34 (zalezaet-pod-verhnij-inset/zalezaet-pod-nizhij-inset):
залезание элементов под инсеты не проверяется — элемент в зоне
статус-бара/выреза сверху либо home-indicator снизу проходит;
ZALEZAET_POD_INSET не выдаётся."""
from _model import m, run

_bez = m.check_vtoroj_profil


def _check_profil_bez_insetov(f, pack):
    return [o for o in _bez(f, pack)
            if o.split('\t')[1] != 'ZALEZAET_POD_INSET']


m.check_vtoroj_profil = _check_profil_bez_insetov
run()
