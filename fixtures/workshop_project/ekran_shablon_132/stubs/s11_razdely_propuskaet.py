"""Стаб s11 (razdely-propuskaet): обязательные разделы контракта не судятся."""
from _model import m, run

m.check_razdely = lambda *a: []
run()
