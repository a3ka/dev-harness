"""Стаб s32 (profil-nizhe-minimuma/profil-bez-insetov): норма класса
профиля не проверяется — размер 390×844 (класс Android-эмулятора) и
инсеты вне нормы (vyrez 24, home 0) проходят; PROFIL_NIZHE_MINIMUMA и
PROFIL_BEZ_INSETOV не выдаются."""
from _model import m, run

_bez = m.check_vtoroj_profil
_BEZ = {'PROFIL_NIZHE_MINIMUMA', 'PROFIL_BEZ_INSETOV'}


def _check_profil_bez_normy(f, pack):
    return [o for o in _bez(f, pack) if o.split('\t')[1] not in _BEZ]


m.check_vtoroj_profil = _check_profil_bez_normy
run()
