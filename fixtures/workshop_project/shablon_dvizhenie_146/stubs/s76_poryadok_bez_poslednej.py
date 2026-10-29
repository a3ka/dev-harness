"""Стаб s76 (B.8/A.4): порядок треков судится без ПОСЛЕДНЕЙ позиции
(porjadki[:-1] == 1..n-1) — порча последнего порядка проходит; семьи
poryadok-{propusk,dubl}-poslednej ловят."""
from _model import m, run


def _bez_poslednej(porjadki, n, pid, bad):
    if porjadki[:-1] != list(range(1, n)):
        bad.append(m.otkaz('PORYADOK_NARUSHEN', pid))


m._proverka_sceny_poryadok = _bez_poslednej
run()
