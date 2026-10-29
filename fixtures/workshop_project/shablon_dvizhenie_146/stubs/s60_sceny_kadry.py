"""Стаб s60 (sceny-kadry): ключевые кадры окна не судятся — проценты
keyframes_ms произвольны."""
from _model import m, run

m._proverka_sceny_kadry = lambda sc, pid, bad: None
run()
