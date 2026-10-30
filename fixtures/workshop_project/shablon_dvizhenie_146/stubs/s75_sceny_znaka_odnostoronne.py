"""Стаб s75 (B.9): сцены знака судятся односторонним включением (только
«объявленная есть в поз» + «всякая сцена поз из perehody объявлена») —
лишняя сцена поз, ЧУЖАЯ переходам, проходит; закрывает измеренный
арбитром обход GA-T20 (клетка scena-v-poz-vne-perehodov)."""
from _model import m, run


def _odnostoronne(sceny_poz, perehody, zaiavl):
    bad = []
    for s in zaiavl:
        if s not in sceny_poz:
            bad.append(m.otkaz('SCENA_VNE_ORAKULA', s))
    for s in sorted(perehody & sceny_poz):
        if s not in zaiavl:
            bad.append(m.otkaz('SCENY_ZNAKA_NE_POLNY', s))
    return bad


m._sceny_znaka_sud = _odnostoronne
run()
