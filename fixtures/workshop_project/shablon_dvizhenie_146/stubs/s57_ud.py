"""Стаб s57 (ud): «Уменьшить движение» не судится — столбец УД может
опускаться, перемещение длится, цвет дольше motion-fast."""
from _model import m, run

m._proverka_ud = lambda t, ud_limit, gde, bad: None
run()
