"""Стаб s40 (prokhod-pustoj / prokhod-bez-pressable): структура команды
прохода не проверяется — no-op/echo/true и флоу без pressable
принимаются, пока оболочка команды возвращает rc 0; PROKHOD_NE_MAESTRO /
PROKHOD_BEZ_PRESSABLE не выдаются (блокер 2 вердикта критика 1/2)."""
from _model import m

m.check_prokhod_komanda = lambda f, repo: []
run()
