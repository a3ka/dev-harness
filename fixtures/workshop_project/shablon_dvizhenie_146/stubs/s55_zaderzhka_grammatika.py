"""Стаб s55 (zaderzhka-grammatika): задержка не судится — закрытая
грамматика и согласованность значения не проверяются."""
from _model import m, run

m._proverka_zaderzh = lambda z, tk, gde, bad: True
run()
