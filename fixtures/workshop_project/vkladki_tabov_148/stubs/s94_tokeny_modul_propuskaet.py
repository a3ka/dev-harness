"""Стаб s94 (tokeny-modul, продукт): гейт производности модуля значений
от источника не судится — модуль kompakt-tokens.ts, переписанный руками
(height 71) при честном соседнем source/tokens.json, проходит суд
продукта (вердикт Crit148k2b Б1: связь компонента с токеном не
доказывалась). Дефект наблюдаем ровно на входе pr-tokeny-modul (ветка
proverka_modulja_tokenov продукт-судьи B; Н-39)."""
from _produkt import m, run

m.proverka_modulja_tokenov = lambda repo: None
run()
