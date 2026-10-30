"""Стаб s69 (B.8/A.4): УД судится только у property == 'opacity' — bg и
весь класс перемещения проходят; семьи ud-*-vse-treki ловят недостающие
адреса (в т.ч. bg-треки дополненного корпуса)."""
from _model import m, run

_staryj = m._proverka_ud


def _tolko_opacity(t, ud_limit, gde, bad):
    if t.get('property') == 'opacity':
        _staryj(t, ud_limit, gde, bad)


m._proverka_ud = _tolko_opacity
run()
