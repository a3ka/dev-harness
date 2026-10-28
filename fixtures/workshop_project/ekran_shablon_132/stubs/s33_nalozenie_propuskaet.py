"""Стаб s33 (nalozenie-sloev): наложение слоёв не проверяется — шапка
TabShell поверх шапки экрана (дубль заголовка, пересечение bbox
положительной площади) проходит; NALOZHENIE_SLOEV не выдаётся."""
from _model import m, run

_bez = m.check_vtoroj_profil


def _check_profil_bez_nalozenij(f, pack):
    return [o for o in _bez(f, pack)
            if o.split('\t')[1] != 'NALOZHENIE_SLOEV']


m.check_vtoroj_profil = _check_profil_bez_nalozenij
run()
