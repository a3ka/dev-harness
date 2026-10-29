"""Стаб s46 (sostav-shablon3): замкнутость составов версии — блок
dvizhenie при shablon: 2 принимается грамматикой (шаблон «не знает»
про v3-состав)."""
from _model import m, run

_alfavit = m.check_alfavit


def _novyj(f):
    bad = _alfavit(f)
    if isinstance(f, dict) and isinstance(f.get('dvizhenie'), dict) \
            and f.get('shablon') == 2:
        return [o for o in bad if 'состав ключей' not in o]
    return bad


m.check_alfavit = _novyj
run()
