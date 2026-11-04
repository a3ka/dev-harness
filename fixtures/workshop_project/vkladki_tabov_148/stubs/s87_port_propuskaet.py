"""s87: принимает любой порт START; пройдёт на 5571, оставив порядок
журнала без изменений (ветка PORT_393_NE_5576 в _sudit_zhurnal)."""
from _produkt import m, run

original = m._sudit_zhurnal
m._sudit_zhurnal = lambda lines: [
    reason for reason in original(lines)
    if not reason.startswith('PORT_393_NE_5576:')]
run()
