"""Стаб s13 (priemka-ispolnenie): приёмка priemka.e2e/sverka не ИСПОЛНЯЕТСЯ
(фиктивные true/echo проходят — команды не запускаются)."""
from _model import m, run

m.run_priemka_e2e = lambda *a: []
m.run_priemka_sverka = lambda *a: []
run()
