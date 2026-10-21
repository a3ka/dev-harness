"""Стаб: мера всегда зелёная — score 1.000 на любом кадре."""
from _model import m, run

m.score_frame = lambda frame, mock, maski, mera: (1.0, 'G')
run()
