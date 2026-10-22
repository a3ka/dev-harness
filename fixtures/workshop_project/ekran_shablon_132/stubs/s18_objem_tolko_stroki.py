"""Стаб s18 (objem-tolko-stroki): «одна страница» меряется только числом
строк — ширина строки и объём файла не судятся (обход круга 2: 47 строк /
261138 байт одной строкой)."""
from _model import m, run


def _tolko_stroki(tekst):
    n = len(tekst.splitlines())
    if n > m.MAX_STRANICA:
        return [m.otkaz('NE_ODNA_STRANICA',
                        'строк: %d (норма ≤ %d)' % (n, m.MAX_STRANICA))]
    return []


m.check_objem = _tolko_stroki
run()
