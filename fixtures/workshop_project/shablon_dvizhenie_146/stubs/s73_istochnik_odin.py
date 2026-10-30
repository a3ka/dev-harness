"""Стаб s73 (B.8/A.6): пин sha256 судится только у spec — пины
manifest/pozvonok подменяются фактическими байтами до суда (никогда не
расходятся); семьи istochnik-piny-{manifest,pozvonok} ловят."""
from _model import m, run

_staryj = m.zagnost_istochniki


def _tolko_spec(dv, repo):
    dv2 = dict(dv)
    for imja in ('manifest', 'pozvonok'):
        p = repo / dv[imja]
        if p.is_file():
            dv2[imja + '_sha256'] = m._sha256_bajtov(p)
    return _staryj(dv2, repo)


m.zagnost_istochniki = _tolko_spec
run()
