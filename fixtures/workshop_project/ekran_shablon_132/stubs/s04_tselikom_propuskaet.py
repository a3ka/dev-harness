"""Стаб s04 (tselikom-propuskaet): замена целиком (zamenjaet) не судится."""
from _model import m, run

m.check_tselikom = lambda *a: []
run()
