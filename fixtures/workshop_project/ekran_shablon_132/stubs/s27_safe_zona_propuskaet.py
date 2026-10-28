"""Стаб s27 (cel-v-safe-zone): safe-area не проверяется — цель в полосе
home-indicator/статус-бара проходит; KASANIE_V_SAFE_ZONE не выдаётся."""
from _model import m, run

_bez = m.check_prokhodimost


def _check_prokhodimost_bez_safe(f, kadry):
    return [o for o in _bez(f, kadry)
            if o.split('\t')[1] != 'KASANIE_V_SAFE_ZONE']


m.check_prokhodimost = _check_prokhodimost_bez_safe
run()
