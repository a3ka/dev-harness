#!/usr/bin/env bash
# Раннер красной/зелёной пачки 088 «в полёте ничего: дверь видит живых субагентов сессии
# omp; pre-commit держит строку-указатель HANDOFF» — агрегатор семьи fixtures/strazh_088/.
#
# Использование:
#   bash fixtures/_krasnye_088.sh              # все клетки семьи + стаб-пак
#   bash fixtures/_krasnye_088.sh fast         # проба гейта 036: клетки D1 и B1 (< 60 с)
#   bash fixtures/_krasnye_088.sh [fast] <корень>
#
# Семантика (контракт 088 §Приёмочный критерий): субъекты scripts/orch_restart.sh,
# scripts/lib_session.sh, scripts/check_staged.sh, .githooks/pre-commit существуют ДО 088 —
# «предмет отсутствует» наблюдаем ПОВЕДЕНИЕМ (клетки D1/D3, B1…B11 красны), не отсутствием
# файла. rc 0 ⟺ каждый файл семьи rc 0; rc 1 — есть красная клетка; rc 2 — нечем проверить.
# Клетка L1 (живая среда omp) вне сессии omp — ПРОПУСК с пометкой, не зелёное и не красное.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REZHIM=polnyj
if [ "${1:-}" = fast ]; then REZHIM=fast; shift; fi
ROOT="$(cd "${1:-$HERE/..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$ROOT/fixtures/strazh_088"
[ -f "$FAM/_toy.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса семьи: %s/_toy.sh\n' "$FAM" >&2; exit 2; }
itog=0
progon() {  # <файл семьи> [<клетка…>]
  local f="$1" rc; shift
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  bash "$FAM/$f" "$ROOT" "$@"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}
if [ "$REZHIM" = fast ]; then
  progon red_dver_088.sh D1
  progon red_ukazatel_088.sh B1
else
  progon red_dver_088.sh
  progon red_ukazatel_088.sh
  progon red_stuby_088.sh
fi
printf 'ИТОГ 088 (%s): rc=%s\n' "$REZHIM" "$itog"
exit "$itog"
