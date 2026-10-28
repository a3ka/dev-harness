#!/usr/bin/env bash
# СТАБ 142: userinfo-канон привязан к схеме и требует непустого пользователя —
# DSN без схемы (back:pass@host) и пустой пользователь (redis://:pwd@host) не ловятся.
# v4: якорь переведён на канон-строку v4 по арбитражу contracts-142-v4-arbitraz
# (двоеточие-ветвь — строка v1/v3), дефект прежний — мутант оставляет ТОЛЬКО
# схемную двоеточие-ветвь с непустым пользователем (токен-ветвь снята той же заменой).
# Привязка к клеткам — source.json:.stab_vhod["stab_shema-pustoj-user"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'\n"
assert src.count(a) == 1, "точка правки модели не найдена: канон userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, "  USERINFO_RE='://[^/@[:space:]]+:[^/@[:space:]]*@'\n"))
PY
