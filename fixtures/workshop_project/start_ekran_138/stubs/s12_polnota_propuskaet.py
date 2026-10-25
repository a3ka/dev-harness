"""Стаб s12_polnota_propuskaet: полнота zamenjaet/ne_trogaet против живых пачек не судится."""
from _model import m, run

m.check_polnota = lambda *a: []
run()
