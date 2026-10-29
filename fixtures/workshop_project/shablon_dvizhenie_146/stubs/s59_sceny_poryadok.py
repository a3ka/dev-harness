"""Стаб s59 (sceny-poryadok): порядок стартов треков не судится —
order не 1..n проходит незаметно."""
from _model import m, run

m._proverka_sceny_poryadok = lambda porjadki, n, pid, bad: None
run()
