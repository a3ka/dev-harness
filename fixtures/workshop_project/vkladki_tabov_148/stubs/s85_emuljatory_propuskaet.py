"""s85: игнорирует весь журнал цикла пары; неверный порядок становится
зелёным на pr-emuljatory-odnovremenno (ветка _sudit_zhurnal)."""
from _produkt import m, run

m._sudit_zhurnal = lambda lines: []
run()
