#!/usr/bin/env bash
# СТАБ 125 v2: повторный старт ДОПИСЫВАЕТ argv-факт (не перезаписывает) — дрейф
# между стартами: факты несут хвосты прошлых запусков
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_perezapis_net"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("  _t=$(mktemp \"$_d/argv.XXXXXX\") || die \"mktemp фактов не удался: $_d\"\n"
     "  printf '%s\\n' \"$@\" > \"$_t\" && mv -f -- \"$_t\" \"$_d/argv\" || die \"запись argv фактов не удалась\"\n")
b = ("  mkdir -p -- \"$_d\" || true\n"
     "  printf '%s\\n' \"$@\" >> \"$_d/argv\"  # СТАБ: дописывание, не перезапись\n")
assert src.count(a) == 1, "точка правки модели не найдена: запись argv фактов"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
