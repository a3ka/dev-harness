"""Стаб s41 (poddelnaja-obolochka / marshrut-bez-snimka): маршрут
собранного пути не проверяется — оболочка остаётся декларацией
(непустое слово obolochka без входа в неё) и связь флоу с кадрами
профиля не наблюдается; MARSHRUT_BEZ_OBOLOCHKI / MARSHRUT_BEZ_SNIMKA
не выдаются (блокер 3 вердикта критика 1/2)."""
from _model import m

m.check_marshrut = lambda f, pack, repo: []
run()
