#!/usr/bin/env bash
# СТАБ 125: дверь каждый вход перезаписывает .git/info/exclude своим списком; строку .harness/.env — только когда сама создала .env
# Привязка к клеткам — source.json:.stab_vhod["stab_conn_zhizn_exclude_sbros"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели connect_project.sh).
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
EXCL = "grep -qxF '.harness/.env' .git/info/exclude 2>/dev/null || printf '.harness/.env\\n' >> .git/info/exclude\n"
for a, b in [("  ( umask 077; grep -E", "  ENV_NOVYJ=1\n  ( umask 077; grep -E"),
             (EXCL, "{ printf '.harness/registry/*.lock\\n'; [ \"${ENV_NOVYJ-}\" = 1 ] && printf '.harness/.env\\n'; } > .git/info/exclude\n")]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
