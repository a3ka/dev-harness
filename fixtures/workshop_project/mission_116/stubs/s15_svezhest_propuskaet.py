"""Стаб s15 (svezhest-propuskaet): свежесть кадров не судится — оставшиеся
кадры прежнего прогона e2e засчитываются сверкой (кадр без свежего e2e)."""
from _model import m, run

m.svezhost_kadrov = lambda *a: []
run()
