"""Стаб s96 (safe-area-инсеты, продукт): лейсте без чтения safe-area
инсета (низ у края окна при ненулевом инсете устройства — форма головы
PR #147 9955af5) проходит суд продукта. Дефект наблюдаем ровно на
входе pr-safe-insety-ne-chitajutsja (ветка proverka_insetov
продукт-судьи B; геометрию резерва дополнительно судит зондовый ассерт
Б-3; Н-39)."""
from _produkt import m, run

m.proverka_insetov = lambda repo: None
run()
