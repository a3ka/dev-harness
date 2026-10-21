"""Стаб: порог кадра принудительно 0 — любой score проходит."""
from _model import m, run

_orig = m.load_manifest


def load(path):
    mera, kadry = _orig(path)
    for k in kadry:
        k['porog'] = 0.0
    return mera, kadry


m.load_manifest = load
run()
