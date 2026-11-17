#!/usr/bin/env bash
# СТАБ 125 v2: sev.json несёт КОНСТАНТНЫЙ sha источника (не байты, которые копировал
# сев) — запись лжёт о побайтности, сверкаку не видит, батарее видна
# Привязка — source.json:.stab_vhod["stab_lnch_sev_fakty_lgun"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  _sha1=$(sha256sum -- \"$SEV_SRC/$_sf\" | cut -c1-64) || die \"sha источника сева не взят: $_sf\"\n"
b = "  _sha1=0000000000000000000000000000000000000000000000000000000000000000  # СТАБ: константа\n"
assert src.count(a) == 1, "точка правки модели не найдена: sha источника сева"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
