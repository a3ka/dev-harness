#!/usr/bin/env bash
# СТАБ 125: лаунчер читает .env и пин только из корня (раскладка 054 без .harness/)
# Привязка к клеткам — source.json:.stab_vhod["stab_lnch_raskladka_koren"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели workshop.sh).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('ENV_FILE="$PROJECT/.harness/.env"\n[ -f "$ENV_FILE" ] || ENV_FILE="$PROJECT/.env"\nPIN_FILE="$PROJECT/.harness/harness_pin.json"\n[ -f "$PIN_FILE" ] || PIN_FILE="$PROJECT/config/harness_pin.json"\n', 'ENV_FILE="$PROJECT/.env"\nPIN_FILE="$PROJECT/config/harness_pin.json"\n')]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
