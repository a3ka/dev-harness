"""Стаб s103 (etalon-393, лейсте): оракул не судит размещение лейсте
(proverka_leiste отключена) — сдвиг геометрии кадра (бюджет 84:
полотно вытесняет лейсте на строку вниз) проходит молча. Дефект
наблюдаем ровно на входе etalon-393-udaleno-84 (ветвь proverka_leiste
orakul_soderzhanija.py; v6c, вариант Б; Н-39)."""
from _orakul import m, run

m.proverka_leiste = lambda *a, **k: []
run()
