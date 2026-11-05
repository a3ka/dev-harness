#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f32-sostojanie-nedostizhimo — вход состояния ведёт в обычное (класс 11).

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса.
CLI: <имя>.py <корень-копии-референса>. Код возврата 0 — замена применена;
2 — якорь не найден ровно один раз (мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
YAKOR = "onPress={() => setMenu('vorgang')}"
ZAMENA = "onPress={() => setMenu('open')}"

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
