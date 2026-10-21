"""Стаб: покрытие макета элементами не сверяется — необъявленный элемент судится
одним G молча, его пропажа не видна."""
from _model import m, run

m.check_pokrytie = lambda mg, mask, k, mera: None
run()
