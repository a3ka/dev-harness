"""Стаб s37 (odna-tema): покрытие тем второго профиля не проверяется —
манифест профиля с кадрами только одной темы (dark без light) проходит;
ODNA_TEMA не выдаётся."""
from _model import m, run

_bez = m.check_vtoroj_profil


def _check_profil_bez_tem(f, pack):
    return [o for o in _bez(f, pack) if o.split('\t')[1] != 'ODNA_TEMA']


m.check_vtoroj_profil = _check_profil_bez_tem
run()
