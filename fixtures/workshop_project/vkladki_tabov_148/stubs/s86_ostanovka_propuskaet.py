"""s86: отбрасывает именно нарушение живого порядка, сохраняет прочие
причины журнала. Ложь видна при echo/if false/true ||/раннем START."""
from _produkt import m, run

original = m._sudit_zhurnal
m._sudit_zhurnal = lambda lines: [
    reason for reason in original(lines)
    if not reason.startswith('EMULJATORY_ODNOVREMENNO:')]
run()
