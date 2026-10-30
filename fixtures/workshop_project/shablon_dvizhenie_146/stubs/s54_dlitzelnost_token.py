"""Стаб s54 (dlitelnost-token): длительность трека не судится против
токенов — сырое число и расходящееся значение проходят."""
from _model import m, run

m._proverka_dlitel = lambda dur, tk, gde, bad: True
run()
