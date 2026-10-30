"""Стаб s68 (B.8/A.4): значение задержки считается только по ПЕРВОМУ
терму выражения — многочленные клетки ловят и ложный зелёный пропуск
(ms первого терма), и ложный красный отказ (честная сумма)."""
import re

from _model import m, run

_staryj = m._znach_vyrazhenija


def _pervyj_term(tekst, tk):
    if not isinstance(tekst, str) or not tekst:
        return None
    if ' + ' in tekst or ' - ' in tekst:
        ch = tekst.split(' ')[0]
        mm = re.match(r'\A([0-9]+(?:\.[0-9]+)?)(?:\*([a-z][a-z0-9-]*))?\Z',
                      ch)
        if not mm:
            return None
        v = float(mm.group(1))
        if mm.group(2):
            if mm.group(2) not in tk or tk[mm.group(2)][1] is None:
                return None
            v = v * tk[mm.group(2)][1]
        return v
    return _staryj(tekst, tk)


m._znach_vyrazhenija = _pervyj_term
run()
