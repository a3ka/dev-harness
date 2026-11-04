"""Стаб s91 (paket-1-1, продукт): гейт пакета D24-Kompakt-1.1
продукт-судьи не судится — пачка R с пином D 2.4 Final 2 (файлы и sha
честны, эталон и пин-проверка проходят) проходит суд продукта (слово
владельца 2026-11-02). Дефект наблюдаем ровно на входе pr-paket-final2
(ветка proverka_paketa продукт-судьи B; Н-39)."""
from _produkt import m, run

m.proverka_paketa = lambda repo: None
run()
