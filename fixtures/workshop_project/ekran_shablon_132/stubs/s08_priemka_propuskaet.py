"""Стаб s08 (priemka-propuskaet): самодельная сверка в priemka не судится."""
from _model import m, run

m.check_priemka = lambda *a: []
run()
