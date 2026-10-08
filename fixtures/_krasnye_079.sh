#!/usr/bin/env bash
# Раннер красной/зелёной пачки 079 «покрытие инвариантов 083/088 красными
# клетками» — агрегатор ОДНОЙ семьи:
#   fixtures/pokrytie_083_088_079/{red_gen_otkazy_079.sh, red_parity_reestr_079.sh,
#   red_istochnik_incr_079.sh, red_dver_getent_079.sh, red_stuby_079.sh}
# (имя каталога — вне чужих glob'ов раннеров; probe-only 034 не заявляем —
# семейные файлы с red_-префиксом, не case_*).
#
# Использование:
#   bash fixtures/_krasnye_079.sh              # все клетки семьи + стаб-пак
#   bash fixtures/_krasnye_079.sh fast         # проба гейта 036: Р1-нерезолв + Р4-getent;
#                                               # время контура меряется, ≥ 60 с → rc 1
#   bash fixtures/_krasnye_079.sh [fast] <корень>
#
# Семантика (контракт 079 §Приёмка): клетки судят ВЕТВИ инвариантов 083/088,
# не покрытые ни одной существующей клеткой (аудит 079): честные клетки ЗЕЛЁНЫ
# на живом дереве (ветви реализованы в done-барьерах 083/088 и пойманы стаб-паком
# д1-д7); rc 0 ⟺ каждый файл семьи rc 0; rc 1 — есть красная клетка; rc 2 —
# нечем проверить. Герметичность Н-219: скратч только mktemp/tmp, ни одного
# пути в ~/.local/state/dev-harness-sessions/** или /var/lib/orch-peak/**;
# getent-шим — только в PATH тою-запуска двери.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REZHIM=polnyj
if [ "${1:-}" = fast ]; then REZHIM=fast; shift; fi
ROOT="$(cd "${1:-$HERE/..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$ROOT/fixtures/pokrytie_083_088_079"
[ -f "$FAM/red_gen_otkazy_079.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса семьи: %s\n' "$FAM" >&2; exit 2; }
itog=0
progon() {  # <файл семьи> [<клетка…>]
  local f="$1" rc; shift
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  bash "$FAM/$f" "$ROOT" "$@"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}
if [ "$REZHIM" = fast ]; then
  SECONDS=0
  progon red_gen_otkazy_079.sh Р1-нерезолв
  progon red_dver_getent_079.sh Р4-getent
  # П2 контракта 079: порог 60 с — в КОДЕ ВОЗВРАТА, не в прозе (критик 079-к1,
  # блокер 3): превышение = именованный отказ rc 1, а не наблюдение
  printf 'fast-контур 079: %s с (порог 60)\n' "$SECONDS"
  if [ "$SECONDS" -ge 60 ]; then
    printf 'КРАСНО: fast-контур 079 превысил порог 60 с (%s с)\n' "$SECONDS" >&2
    [ "$itog" -eq 0 ] && itog=1
  fi
else
  progon red_gen_otkazy_079.sh
  progon red_parity_reestr_079.sh
  progon red_istochnik_incr_079.sh
  progon red_dver_getent_079.sh
  progon red_stuby_079.sh
fi
printf 'ИТОГ 079 (%s): rc=%s\n' "$REZHIM" "$itog"
exit "$itog"
