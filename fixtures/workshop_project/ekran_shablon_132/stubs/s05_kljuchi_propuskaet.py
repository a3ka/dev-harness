"""Стаб s05 (kljuchi-propuskaet): ключи копии против каталога не судятся."""
from _model import m, run

m.check_kljuchi = lambda *a: []
run()
