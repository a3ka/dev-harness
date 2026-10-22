"""Стаб s14 (objem-propuskaet): объём контракта «на одну страницу» не
судится."""
from _model import m, run

m.check_objem = lambda *a: []
run()
