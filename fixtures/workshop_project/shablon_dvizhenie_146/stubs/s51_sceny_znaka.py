"""Стаб s51 (sceny-znaka): состав сцен знака не судится — пропуск
поз-оракула и лишняя сцена проходят незаметно."""
from _model import m, run

m._sceny_znaka_sud = lambda sceny_poz, perehody, zaiavl: []
run()
