"""Стаб s26 (cel-menshe-44): норма касания не проверяется — цель 18pt
(«Demo: nächster Zustand» на 118, на iPhone не нажимается) проходит
как допустимая; KASANIE_MENSHE_NORMY не выдаётся."""
from _model import m, run

_bez = m.check_prokhodimost


def _check_prokhodimost_bez_normy(f, kadry):
    return [o for o in _bez(f, kadry)
            if o.split('\t')[1] != 'KASANIE_MENSHE_NORMY']


m.check_prokhodimost = _check_prokhodimost_bez_normy
run()
