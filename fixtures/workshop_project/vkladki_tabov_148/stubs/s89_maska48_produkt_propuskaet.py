"""Стаб s89 (maska-48, продукт): инвариант ТОЧНОГО значения маски
профиля 393 не судится продукт-судьёй — манифест R с
chrome_verh_pt=47 (визуально зелёный) проходит суд продукта (вердикт
Crit148v2, блок 3). Дефект наблюдаем ровно на входе pr-maska-ne-48
(ветка proverka_maski_profilja продукт-судьи B; Н-39)."""
from _produkt import m, run

m.proverka_maski_profilja = lambda repo: None
run()
