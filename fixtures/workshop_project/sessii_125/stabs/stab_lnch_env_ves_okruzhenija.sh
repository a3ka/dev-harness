#!/usr/bin/env bash
# СТАБ 125-А1 (решение 4): env-факт несёт ВСЁ окружение процесса (не ровно HOME/PWD) —
# синтетический секрет попадает в постоянные факты
# Привязка — source.json:.stab_vhod["stab_lnch_env_ves_okruzhenija"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  printf 'HOME=%s\\nPWD=%s\\n' \"$_home\" \"$_pwd\" > \"$_stage/env\" || die \"запись env фактов не удалась\"\n"
b = "  env > \"$_stage/env\" || die \"запись env фактов не удалась\"  # СТАБ: всё окружение процесса\n"
assert src.count(a) == 1, "точка правки модели не найдена: запись env фактов"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
