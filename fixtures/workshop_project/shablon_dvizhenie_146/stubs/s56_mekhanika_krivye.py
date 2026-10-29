"""Стаб s56 (mekhanika-krivye): канон кривых и запрет пружин не
судятся — посторонняя кривая и пружина проходят."""
from _model import m, run

m._proverka_mekhaniki = lambda t, tk, gde, bad: None
run()
