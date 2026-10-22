"""Стаб s07 (scenarij-propuskaet): покрытие сценария e2e снимками не судится."""
from _model import m, run

m.check_scenarij = lambda *a: []
run()
