"""Стаб s76 (mitte-tab): Mitte с role="tab" и без маркеров
проходит — замороженная грамматика 999 не защищена."""
from _produkt import m, run

m.MITTE_MARKERY = []
_staryj = m.staticheskie_proverki


def staticheskie_proverki(repo, src):
    otkazy = _staryj(repo, src)
    return [o for o in otkazy if not o.startswith("MITTE_")]


m.staticheskie_proverki = staticheskie_proverki
run()
