"""Стаб: маски chrome и maski_pt игнорируются — статус-бар и жестовая полоса судятся."""
from _model import m, run

m.court_mask = lambda mera, maski: [[True] * (m.AW // mera['kletka_pt']) for _ in range(m.AH // mera['kletka_pt'])]
run()
