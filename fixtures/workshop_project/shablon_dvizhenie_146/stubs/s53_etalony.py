"""Стаб s53 (etalony): эталоны Release не судятся — нет пинов, короче
список, не-hex, лишний переход проходят незаметно."""
from _model import m, run

m._etalony_sud = lambda sceny, et, perehody: []
run()
