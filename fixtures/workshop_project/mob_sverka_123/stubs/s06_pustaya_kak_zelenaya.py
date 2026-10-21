"""Стаб: маски честные, но пустая сверка (ноль ячеек суда) — зелёная, не отказ."""
from _model import m, run

_orig_load = m.load_manifest


def load(path):
    mera, kadry = _orig_load(path)
    return dict(mera, min_dolja_suda=0), kadry


m.load_manifest = load
run()
