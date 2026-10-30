#!/usr/bin/env bash
# Файл батареи пачки gespraech-tekst (контракт 149): самопроверка пачки
# перед приёмкой — наличие канонических файлов и целостность манифестов.
# Без чисел в скобках и без hex-слов: литералы цветов/размеров в пачке
# запрещены (шаблон 132), текст файла проходит аудит литералов.
# Коды возврата: 0 — состав пачки цел; 1 — нет файла/кривой JSON (имя
# названо); 2 — нечем проверять (нет python).
set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)" || exit 2
for f in kontrakt.md kadry.json kadry-393.json katalog_kopii.json \
         spec_api.json e2e.sh prokhod.sh; do
  if [ ! -f "$here/$f" ]; then
    printf 'PACHKA_BEZ_FAJLA %s\n' "$f" >&2
    exit 1
  fi
done
command -v python3 >/dev/null 2>&1 || {
  printf 'NOT_IMPLEMENTED: нет python\n' >&2; exit 2; }
for m in kadry.json kadry-393.json katalog_kopii.json spec_api.json; do
  fajl="$here/$m" python3 - <<'PY'
import json
import os
try:
    with open(os.environ['fajl']) as fh:
        json.load(fh)
except Exception as e:
    print('PACHKA_JSON_NE_CHITAETSJA %s %s' % (os.environ['fajl'], e))
    raise SystemExit('kriwoj json')
PY
  if [ $? -ne 0 ]; then exit 1; fi
done
printf 'PACHKA gespraech-tekst SOSTAV OK\n'
exit 0
