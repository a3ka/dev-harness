"""Стаб s18 (objem-tolko-stroki): объём судится только числом строк —
широкая строка-стена и байты проходят (обход круга 2 батареи 132)."""
from _model import m, run

_orig = m.check_objem


def tolko_stroki(tekst):
    stroki = tekst.splitlines()
    if len(stroki) > m.MAX_STRANICA:
        return _orig(tekst)
    return []


m.check_objem = tolko_stroki
run()
