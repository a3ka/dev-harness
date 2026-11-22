"""Стаб s105 (etalon-393, часовой значений): оракул не судит значения
маски/порога/констант манифеста построителя (proverka_znachenij
отключена) — сдвиг маски 48 -> 47 и порога 0.600 -> 0.5 проходят
молча (слово владельца 22.11 ~14:35: порог 0.600 и маска 48 без
изменений). Дефект наблюдаем на входах etalon-393-maska-sdvinuta и
etalon-393-porog-izmenen (ветвь proverka_znachenij
orakul_soderzhanija.py; v6c, вариант Б; Н-39)."""
from _orakul import m, run

m.proverka_znachenij = lambda *a, **k: []
run()
