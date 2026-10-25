"""Стаб s03_chuzhie_propuskaet: чужие кадры не обнаруживаются."""
from _model import m, run

m.check_chuzhie = lambda *a: []
run()
