"""Стаб s44 (marshrut-obolochka-v-kommentarii): исполняемый текст маршрута
не отделяется от формы — шапка name: и YAML-комментарии («# tabshell»,
«# - takeScreenshot: …») считаются текстом маршрута, оболочка и снимок
профиля «наблюдаются» без шагов (С-2 РЕШЕНИЯ АРБИТРА contracts-132-v2-
arbitraz, обход в + вопрос 3); MARSHRUT_BEZ_OBOLOCHKI/MARSHRUT_BEZ_SNIMKA
не выдаются; на входе своей записи green там, где эталон красен; на
честном маршруте совпадает с эталоном."""
from _model import m

m.ispolnimye_stroki_flo = lambda stroki: stroki
run()
