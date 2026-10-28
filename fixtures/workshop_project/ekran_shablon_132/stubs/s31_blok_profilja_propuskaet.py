"""Стаб s31 (profil-otsvtstvuet): валидатор НЕ требует блок второго
профиля у НОВОГО экрана (shablon 2) — принимает пачку без блока молча;
отказ с именем места и выходом (правило 7 AGENTS) не выдаётся."""
from _model import m, run

m.check_vtoroj_profil = lambda f, pack: []
run()
