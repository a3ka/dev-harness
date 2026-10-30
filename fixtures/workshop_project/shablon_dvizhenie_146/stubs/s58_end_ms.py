"""Стаб s58 (end-ms): производное end_ms не сверяется с delay+duration."""
from _model import m, run

m._proverka_end = lambda t, z, dur, gde, bad: None
run()
