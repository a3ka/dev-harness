#!/usr/bin/env bash
# Раннер красной/зелёной пачки 045 (scripts/gitw — pre-exchange гард цели):
# прогоняет fixtures/gitw/red_*.sh против указанного guard. Итог: rc 0 если
# все зелёные, иначе rc 1 с таблицей. Один файл — батарея 28 клеток
# (г0–г18) + стаб-пак из 20 обманных стабов; стабы продолжают умирать на
# своих клетках и после реализации (Н-39: различимость не умерла).
#
# Использование:
#   bash fixtures/_krasnye_045.sh scripts/gitw   # guard = путь обёртки
# (абсолютный путь предпочтительнее: батарея исполняется из toy-репо во
# mktemp, и относительный GITW не резолвится от её cwd.)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="${1:?использование: $0 <guard-путь>}"
# Абсолютизируем: `GITW` батареи резолвится от cwd её toy-репо.
case "$GUARD" in
  /*) ;;
  *)  GUARD="$(cd "$HERE/.." && pwd)/$GUARD" ;;
esac
[ -x "$GUARD" ] || { printf 'guard не существует или неисполняем: %s\n' "$GUARD" >&2; exit 1; }
bad=0; total=0
for f in "$HERE/gitw"/red_*.sh; do
  [ -f "$f" ] || continue
  total=$((total + 1))
  out="$(GITW="$GUARD" bash "$f" 2>&1)"; rc=$?
  printf 'gitw/%s rc=%s\n' "$(basename "$f")" "$rc"
  if [ "$rc" -ne 0 ]; then
    bad=$((bad + 1))
    printf '  FAIL:\n%s\n' "$out"
  fi
done
printf 'итог: %s файлов, провалов %s\n' "$total" "$bad" >&2
[ "$total" -gt 0 ] || { printf 'пустая выборка — не проверено ничего\n' >&2; exit 1; }
[ "$bad" -eq 0 ]