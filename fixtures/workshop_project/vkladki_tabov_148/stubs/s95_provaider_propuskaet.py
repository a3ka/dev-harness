"""Стаб s95 (safe-area-провайдер, продукт): корень приложения без
SafeAreaProvider проходит суд продукта — контекст инсетов в рантайме
пуст, лейсте стоит в системной жестовой полосе. Дефект наблюдаем ровно
на входе pr-safe-bez-provaidera (ветка proverka_provaidera
продукт-судьи B; Н-39)."""
from _produkt import m, run

m.proverka_provaidera = lambda repo: None
run()
