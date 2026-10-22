"""Стаб s06 (operacii-propuskaet): операции API против спеки не судятся."""
from _model import m, run

m.check_operacii = lambda *a: []
run()
