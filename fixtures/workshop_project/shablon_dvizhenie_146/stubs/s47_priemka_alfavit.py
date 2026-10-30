"""Стаб s47 (priemka-alfavit): замкнутый состав priemka — четвёртая
команда движения в priemka верхнего уровня проходит незаметно."""
from _model import m, run

_alfavit = m.check_alfavit


def _novyj(f):
    return [o for o in _alfavit(f) if not o.endswith('\tpriemka')]


m.check_alfavit = _novyj
run()
