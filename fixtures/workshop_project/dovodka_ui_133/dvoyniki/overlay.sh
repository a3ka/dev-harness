#!/usr/bin/env bash
# Двойник overlay.sh для миров батареи 133. Судит ТОЛЬКО ногу «соответствие модели
# задаче» реального scripts/overlay.sh:106-147: тир vision из .omp/config.yml,
# способность — из `omp models list` (колонка images). Пин/учёт/порождение двойник
# не судит: те ноги реального overlay — вне предмета 133, их несут свои батареи.
# Грамматика тира и awk-разбор списка — overlay.sh:112,126, несутся побайтово.
#
# Коды: 0 — модель тира vision умеет картинки; 1 — расхождение (FAIL …); 2 — omp не
# перечислил модели (NOT_IMPLEMENTED, «нечем проверить» — не «проверено»).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$HERE/.omp/config.yml"

fail() { printf 'FAIL %s\n' "$1" >&2; exit 1; }

[ -f "$CFG" ] || fail 'нет .omp/config.yml — роли моделей не объявлены'
vm="$(grep -oE '^\s+vision:\s*"[^"]+"' "$CFG" | sed 's/.*"\(.*\)"/\1/' | sed 's|.*/||')"
if [ -z "$vm" ]; then
  fail 'тир vision не объявлен — некому смотреть кадры (Н-20)'
fi
caps="$(omp models list 2>/dev/null | awk -F'│' 'NF>4 {gsub(/^ +| +$/,"",$2); gsub(/^ +| +$/,"",$6); if ($2!="model" && $2!="") print $2"\t"$6}')"
if [ -z "$caps" ]; then
  printf 'NOT_IMPLEMENTED: omp не перечислил модели — соответствие модели задаче не проверено\n' >&2
  exit 2
fi
img="$(printf '%s\n' "$caps" | awk -F'\t' -v m="$vm" '$1==m { print $2; exit }')"
if [ -n "$img" ] && [ "$img" != "yes" ]; then
  fail "модель vision-тира $vm не умеет картинки"
fi
printf 'ok модели соответствуют задачам: vision=%s images=%s\n' "$vm" "${img:-не перечислена}" >&2
exit 0
