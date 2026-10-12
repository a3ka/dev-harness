#!/usr/bin/env bash
# Раннер красной пачки 100 «доверенные исключения main-CI» — агрегатор семьи
# fixtures/main_ci_exceptions_100/ (guard, ПРОВОДКА контракта 100; круг 2).
#
# Использование:
#   bash fixtures/_krasnye_100.sh [корень]
#
# Семантика (контракт 100 §Приёмка): rc 0 ⟺ стаб-пак battery_stubs.sh rc 0 И
# каждая клетка семьи rc 0 (замер контракта: клеток ровно 18); rc 1 — есть
# красная клетка (в том числе «предмет отсутствует» на дереве ДО реализации:
# клетки судят именованные фразы нового предиката чека 3, которых в старом
# коде нет); rc 2 — нечем проверять (нет семьи/инструментов; пустая выборка
# красна, не зелена). Guard подключается в CI ТОЛЬКО ПОСЛЕ landing предмета
# (прецедент 074/093/098/099).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
FAM="$HERE/main_ci_exceptions_100"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
[ -f "$FAM/_mir.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса %s/_mir.sh\n' "$FAM" >&2; exit 2; }
command -v git       >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
command -v curl      >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет curl\n' >&2; exit 2; }
command -v jq        >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

# Замер контракта §Приёмка: клеток ровно 18 (обход печатает число
# просмотренного и отказывает на расхождении — пустая выборка красна).
n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 18 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 18 по замеру контракта 100\n' "$n" >&2
  exit 2
fi

# Субъект: файл существует (071); отсутствие НОВОГО предиката клетки несут
# именованными «предмет отсутствует» по фразам — раннер не судит исходник.
[ -f "$ROOT/scripts/gitw_preflight_071.sh" ] \
  || { printf 'NOT_IMPLEMENTED: нет субъекта scripts/gitw_preflight_071.sh\n' >&2; exit 2; }

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

printf 'ИТОГ 100: rc=%s\n' "$itog"
exit "$itog"
