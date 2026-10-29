"""Стаб s50 (perehody-polnota): ∩-правило полноты переходов не судится —
незаявленное движение невидимо приёмкой."""
from _model import m, run

m._perehody_polnota = lambda dvizh_man, ekrany, perehody: []
run()
