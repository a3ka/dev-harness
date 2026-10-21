#!/usr/bin/env bash
# СТАБ 125: сев захватывает живое состояние dev: sessions/, history.db, blobs/
# Привязка к клеткам — source.json:.stab_vhod["stab_lnch_sev_sessii"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели workshop.sh).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('unset _sf\nprintf \'SEV: %s\\n\' "$SEV_SRC"\n', 'cp -R -- "$SEV_SRC/sessions" "$SEV_SRC/history.db" "$SEV_SRC/blobs" "$SEV_DST/" 2>/dev/null || true\nunset _sf\nprintf \'SEV: %s\\n\' "$SEV_SRC"\n')]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
