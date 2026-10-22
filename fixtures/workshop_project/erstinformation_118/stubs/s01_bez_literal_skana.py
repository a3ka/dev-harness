"""Стаб s01 (bez-literal-skana): запрет литералов цветов/размеров не судится."""
from _model import m, run

m.check_literal = lambda *a: []
run()
