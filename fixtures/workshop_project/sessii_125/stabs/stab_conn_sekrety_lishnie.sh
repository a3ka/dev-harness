#!/usr/bin/env bash
# СТАБ 125: в .harness/.env уходит весь дом секретов, не только ключи bootstrap_env
# Привязка к клеткам — source.json:.stab_vhod["stab_conn_sekrety_lishnie"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели connect_project.sh).
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('grep -E \'^(ZAI_API_KEY|MINIMAX_API_KEY|METERING_PROXY_URL|METERING_PROXY_TOKEN)=\' "$SECRETS" > .harness/.env', 'cat "$SECRETS" > .harness/.env')]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
