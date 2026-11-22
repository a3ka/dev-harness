"""Стаб s100 (porog, продукт): инвариант порога сверки не судится —
запись профиля 393 с porog=0.5 (визуально зелёная сверка проходит)
проходит суд продукта. Дефект наблюдаем ровно на входе
pr-porog-oslablen (ветка proverka_poroga продукт-судьи produkt_sud.py;
v6, слово владельца 22.11 «без ослабления порога»; Н-39)."""
from _produkt import m, run

m.proverka_poroga = lambda repo: None
run()
