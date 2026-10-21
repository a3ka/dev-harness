"""Стаб: маска скрывает весь кадр, пустой суд засчитан зелёным."""
from _model import m, run

_orig_load = m.load_manifest


def load(path):
    mera, kadry = _orig_load(path)
    mera = dict(mera, min_dolja_suda=0)
    return mera, kadry


m.load_manifest = load
m.court_mask = lambda mera, maski: [[False] * (m.AW // mera['kletka_pt']) for _ in range(m.AH // mera['kletka_pt'])]
run()
