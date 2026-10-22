"""Стаб s15 (svezhest-propuskaet): свежесть кадров не судится — оставшиеся
кадры прежнего прогона e2e засчитываются сверкой (обход круга 2: e2e один
раз, потом priemka.e2e=true оценивает СТАРЫЕ кадры)."""
from _model import m, run

m.svezhost_kadrov = lambda *a: []
run()
