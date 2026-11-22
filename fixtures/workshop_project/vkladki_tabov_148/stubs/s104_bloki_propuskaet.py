"""Стаб s104 (etalon-393, разделители): оракул не судит слипание
блоков (proverka_razdelenija отключена) — удаление пустой строки СВЕРХ
бюджета, съедающее единственный разделитель между содержательными
блоками, проходит молча. Дефект наблюдаем ровно на входе
etalon-393-udaleno-86 (ветвь proverka_razdelenija
orakul_soderzhanija.py; v6c, вариант Б; Н-39)."""
from _orakul import m, run

m.proverka_razdelenija = lambda *a, **k: []
run()
