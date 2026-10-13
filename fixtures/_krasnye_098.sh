#!/usr/bin/env bash
# Раннер красной пачки 098 «производственные доказательства до публикации» —
# агрегатор семьи fixtures/dokazatelstva_098/ (guard, ПРОВОДКА контракта 098).
#
# Использование:
#   bash fixtures/_krasnye_098.sh [корень]         # субъекты scripts/{judge_gate,check_ci_gate,accept_publish}.sh
#   bash fixtures/_krasnye_098.sh --model [корень] # субъекты fixtures/dokazatelstva_098/model/
#
# Семантика (контракт 098 §Приёмка): rc 0 ⟺ стаб-пак battery_stubs.sh rc 0 И
# каждая клетка семьи rc 0 (замер: клеток ровно 17 — 14 по контракту 098 + 2
# по вердикту адверсария круга implementer A-098-1/A-098-2 + 1 по вердикту
# ревьюера круга 1 Рв1-1); rc 1 — есть
# красная клетка (в том числе «предмет отсутствует» на дереве ДО реализации —
# писатели/дверь ещё не реальны, приёмка 1); rc 2 — нечем проверять (нет
# семьи/модели/git/клетки). Guard подключается в CI ТОЛЬКО ПОСЛЕ landing
# предмета (прецедент 074/093 §ПРОВОДКА-ЭНФОРСМЕНТ).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="real"
case "${1:-}" in
  --model) MODE="model"; shift ;;
esac
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
FAM="$HERE/dokazatelstva_098"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
[ -f "$FAM/_mir.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса %s/_mir.sh\n' "$FAM" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v jq  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }

# Замер: клеток ровно 17 — 14 по §Приёмка контракта 098 + 2 по вердикту
# адверсария круга implementer (A-098-1 red_chuzhoj_head_sha, A-098-2
# red_ustarevshaja_published) + 1 по вердикту ревьюера круга 1 (Рв1-1
# red_zhurnal_sozdaetsja_pisatelem); обход печатает число просмотренного и
# отказывает на расхождении — пустая выборка красна.
n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 17 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 17 (14 контракта 098 + 2 адверсария A-098-1/2 + 1 ревьюера Рв1-1)\n' "$n" >&2
  exit 2
fi

if [ "$MODE" = "model" ]; then
  export D98_SUBJECTS_DIR="$FAM/model"
  for f in judge_gate.sh check_ci_gate.sh accept_publish.sh; do
    [ -f "$D98_SUBJECTS_DIR/$f" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$D98_SUBJECTS_DIR/$f" >&2; exit 2; }
  done
else
  export D98_ROOT="$ROOT"
fi

SUBJMISS=0
for f in judge_gate.sh check_ci_gate.sh accept_publish.sh; do
  [ -f "${D98_SUBJECTS_DIR:-$ROOT/scripts}/$f" ] || SUBJMISS=1
done

itog=0
progon() {  # <файл семьи>
  local f="$1" rc
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  bash "$FAM/$f"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}

progon battery_stubs.sh
for c in $(ls "$FAM"/red_*.sh | LC_ALL=C sort); do
  progon "$(basename "$c")"
done

if [ "${SUBJMISS:-0}" = "1" ] && [ "$MODE" = "real" ]; then
  printf 'красная: предмет отсутствует (субъекты scripts/judge_gate.sh --verdict-row/--policy-row, scripts/check_ci_gate.sh --check-row, scripts/accept_publish.sh; корень %s)\n' "$ROOT"
fi
printf 'ИТОГ 098: rc=%s\n' "$itog"
exit "$itog"
