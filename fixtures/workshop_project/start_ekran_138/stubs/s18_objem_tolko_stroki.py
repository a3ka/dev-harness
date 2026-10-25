"""Стаб s18_objem_tolko_stroki: объём судится только строками — ширина/байты не считаются."""
from _model import m, run

import re
def _tolko_stroki(tekst):
    bad = []
    if len(tekst.splitlines()) > m.MAX_STRANICA:
        bad.append(m.otkaz('NE_ODNA_STRANICA', 'строки'))
    return bad
m.check_objem = _tolko_stroki
run()
