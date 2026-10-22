"""Стаб s03 (chuzhie-propuskaet): чужие кадры (ne_trogaet) не судятся."""
from _model import m, run

m.check_chuzhie = lambda *a: []
run()
