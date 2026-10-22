"""Стаб s03 (chuzhie-propuskaet): пересечение id кадров с чужими
манифестами ne_trogaet не судится — чужие пиксели морозит."""
from _model import m, run

m.check_chuzhie = lambda *a: []
run()
