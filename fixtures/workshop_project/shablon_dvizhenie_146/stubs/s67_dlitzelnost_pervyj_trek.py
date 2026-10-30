"""Стаб s67 (B.8): длительность судится только у первого трека сцены —
семьи dlitelnost-*-vse-treki ловят недостающие причины."""
from _model import m, run

_staryj = m._proverka_dlitel


def _tolko_pervyj(dur, tk, gde, bad):
    if gde.split(':')[-1] == '1':
        _staryj(dur, tk, gde, bad)


m._proverka_dlitel = _tolko_pervyj
run()
