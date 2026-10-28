"""Стаб s36 (golyj-komponent): оболочка собранного пути не проверяется —
голый компонент/маршрут без оболочки (пустая obolochka) принимается как
сверка; GOLYJ_KOMPONENT не выдаётся."""
from _model import m, run

_bez = m.check_vtoroj_profil


def _check_profil_bez_obolochki(f, pack):
    return [o for o in _bez(f, pack)
            if o.split('\t')[1] != 'GOLYJ_KOMPONENT']


m.check_vtoroj_profil = _check_profil_bez_obolochki
run()
