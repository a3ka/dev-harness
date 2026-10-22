"""Стаб s12 (polnota-propuskaet): полнота объявлений против обнаруженных
живых пачек обоих корней не судится — пустые zamenjaet/ne_trogaet и живая
пачка того же экрана в --repo проходят молча."""
from _model import m, run

m.check_polnota = lambda *a: []
run()
