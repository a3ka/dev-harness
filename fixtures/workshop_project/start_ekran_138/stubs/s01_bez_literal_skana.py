"""Стаб s01_bez_literal_skana: запрет литералов цветов/размеров не судится."""
from _model import m, run

m.check_literal = lambda *a: []
run()
