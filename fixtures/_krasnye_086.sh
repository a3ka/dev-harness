#!/usr/bin/env bash
# Раннер красной/зелёной пачки 086 «гейты точек сведения» — агрегатор ОДНОЙ семьи
# fixtures/gejty_svedenija_086/ (+ профиль 041 parsing_hygiene_battery/profiles/gejt_svedenija.sh).
#
# Использование:
#   bash fixtures/_krasnye_086.sh              # все предъявления семьи по очереди
#   bash fixtures/_krasnye_086.sh fast         # проба гейта 036: клетки A1 A5 L2 L5 H1 (< 60 с)
#   bash fixtures/_krasnye_086.sh [fast] <корень>
#
# Семантика (контракт 086 §Приёмочный критерий): нет любого из субъектов scripts/gejt_svedenija.sh,
# .githooks/pre-merge-commit → «красная: предмет отсутствует», rc 1 БЕЗ запуска батареи (<1 с —
# урок Н-198: проба спек-гейта 036 живёт под timeout 60). Каркас пробой не считается
# (прецедент _repo.sh/_krasnye_084.sh): красные предъявления — файлы семьи, каждый ≤ 60 с.
# Иначе rc 0 ⟺ каждый файл rc 0; rc 2 — нечем проверить (нет файла семьи).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REZHIM=polnyj
if [ "${1:-}" = fast ]; then REZHIM=fast; shift; fi
ROOT="$(cd "${1:-$HERE/..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$ROOT/fixtures/gejty_svedenija_086"
[ -f "$FAM/_toy.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса семьи: %s/_toy.sh\n' "$FAM" >&2; exit 2; }
missing=""
for subj in scripts/gejt_svedenija.sh .githooks/pre-merge-commit; do
  [ -f "$ROOT/$subj" ] || missing="$missing $subj"
done
if [ -n "$missing" ]; then
  printf 'красная: предмет отсутствует\n'
  printf 'КРАСНОЕ 086: нет%s (корень %s)\n' "$missing" "$ROOT" >&2
  exit 1
fi
itog=0
progon() {  # <файл семьи> [<аргумент…>]
  local f="$1" rc; shift
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  bash "$FAM/$f" "$ROOT" "$@"; rc=$?
  printf '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}
if [ "$REZHIM" = fast ]; then
  progon red_accept_086.sh A1 A5
  progon red_land_086.sh L2 L5
  progon red_huk_spawn_086.sh H1
else
  progon red_stuby_086.sh
  progon red_accept_086.sh
  progon red_land_086.sh
  progon red_huk_spawn_086.sh
  progon red_istorija_1_086.sh
  progon red_istorija_2_086.sh
  progon red_istorija_3_086.sh
  bash "$ROOT/fixtures/parsing_hygiene_battery/run_battery.sh" gejt_svedenija; rc=$?
  printf '— parsing_hygiene_battery gejt_svedenija: rc=%s\n' "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
fi
printf 'ИТОГ 086 (%s): rc=%s\n' "$REZHIM" "$itog"
exit "$itog"
