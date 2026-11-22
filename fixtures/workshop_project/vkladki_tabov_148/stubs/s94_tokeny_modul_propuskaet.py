"""Стаб s94 (tokeny-modul, продукт): гейт производности значений
проекции от источника не судится — theme/nav-tokens.ts, переписанный
руками (NAV.height 71) при честном соседнем source/tokens.json,
проходит суд продукта (вердикт Crit148k2b Б1: связь компонента с
токеном не доказывалась; v6 — проекция вместо модуля kompakt-tokens).
Дефект наблюдаем ровно на входе pr-tokeny-modul (ветка
proverka_modulja_tokenov продукт-судьи B; Н-39)."""
from _produkt import m, run

m.proverka_modulja_tokenov = lambda repo: None
run()
