"""Стаб s71 (perehody): ∩-правило полноты переходов не судится —
лишний/незаявленный переход невидим."""
from _model import m, run

m._perehody_polnota = lambda dvizh_man, ekrany, perehody: []
run()
