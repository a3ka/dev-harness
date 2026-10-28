"""Стаб s35 (pustaja-ikonka): пустые иконки не проверяются — контрол
без глифа и без доступного имени (пустые иконки композера на #127)
проходит; PUSTAJA_IKONKA не выдаётся."""
from _model import m, run

_bez = m.check_vtoroj_profil


def _check_profil_bez_ikonok(f, pack):
    return [o for o in _bez(f, pack)
            if o.split('\t')[1] != 'PUSTAJA_IKONKA']


m.check_vtoroj_profil = _check_profil_bez_ikonok
run()
