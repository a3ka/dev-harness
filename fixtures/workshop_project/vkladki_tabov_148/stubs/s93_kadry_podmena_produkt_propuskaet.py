"""Стаб s93 (kadry-podmenen, продукт): гейт соответствия имени кадра
записи её идентификатору продукт-судьи не судится — пачка R с пином
«GA-02 dark» на соседний кадр того же пакета (GA-04, файл и sha честны,
эталон и гейт пакета проходят) проходит суд продукта (вердикт
Crit148k2a Б1). Дефект наблюдаем ровно на входе pr-kadry-podmenen
(ветка proverka_imen_kadrov продукт-судьи B; Н-39)."""
from _produkt import m, run

m.proverka_imen_kadrov = lambda repo, src: None
run()
