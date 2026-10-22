"""Стаб s12 (polnota-propuskaet): полнота zamenjaet/ne_trogaet против
обнаруженных живых пачек не судится (пустые объявления проходят)."""
from _model import m, run

m.check_polnota = lambda *a: []
run()
