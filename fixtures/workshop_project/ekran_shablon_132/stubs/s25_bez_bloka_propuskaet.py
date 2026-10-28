"""Стаб s25 (prokhodimost-otsvtstvuet): валидатор НЕ требует блок
проходимости у НОВОГО экрана (shablon 2) — принимает пачку без блока
молча; отказ с именем места и выходом (правило 7 AGENTS) не выдаётся."""
from _model import m, run

_bez = m.check_prokhodimost


def _check_prokhodimost_bez_bloka(f, kadry):
    if 'prokhodimost' not in f:
        return []
    return _bez(f, kadry)


m.check_prokhodimost = _check_prokhodimost_bez_bloka
run()
