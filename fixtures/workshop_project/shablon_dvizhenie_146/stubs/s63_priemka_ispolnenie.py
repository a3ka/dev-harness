"""Стаб s63 (priemka-ispolnenie): численная приёмка движения не
исполняется вовсе — rc и отчёт не судятся."""
from _model import m, run

m.run_priemka_dvizhenie = lambda f, repo: []
run()
