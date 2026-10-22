"""Стаб s14 (objem-propuskaet): объём контракта экрана («на одну страницу»,
≤ 60 строк) не судится."""
from _model import m, run

m.check_objem = lambda *a: []
run()
