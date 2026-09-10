#!/usr/bin/env bash
# Живая канарейка контракта 024 (И-9, правка-круг 2): ОДИН rc-оракул вместо
# последовательности ручных команд и чтения porcelain — совет 2 вердикта
# 4d1d265 закрыт обёрткой. Церемония запускает её на done против ЖИВОГО
# основного чекаута (аргумент — абсолютный корень); до реализации предмета
# красна именованным отсутствием детектора.
#
#   bash fixtures/check_judge_gate/canary_zhivoj_024.sh <абс-корень>
#
# Делает: --snapshot → --check → повторный --check; все rc фиксируются
# строками в stderr, итог — rc обёртки. Снимок пишется в
# ${TMPDIR:-/tmp}/dev-harness-leak/<hash8>/porcelain (последний выигрывает —
# договор детектора); живое дерево не меняет (сам детектор Н-85-гигиенен).
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (И-11 контракта 024).
# Коды возврата: 0 — канарейка чиста (три шага rc 0); 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/scripts/check_no_leak.sh"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: детектор отсутствует — scripts/check_no_leak.sh (реализация за implementer после заморозки 024)\n' >&2
  exit 1
}
ROOT_ARG="${1:-}"
[ -n "$ROOT_ARG" ] || {
  printf 'ОТКАЗ диспетчер: использование: canary_zhivoj_024.sh <абс-корень>\n' >&2
  exit 1
}

step() {  # <аргументы...> — rc без пайпов (Н-84/Н-85)
  local out rc
  out="$(bash "$SUBJ" "$@" 2>&1)" && rc=0 || rc=$?
  printf '  канарейка %s → rc=%s: %s\n' "$1" "$rc" "$out" >&2
  [ "$rc" -eq 0 ]
}

step --snapshot "$ROOT_ARG" || exit 1
step --check    "$ROOT_ARG" || exit 1
step --check    "$ROOT_ARG" || exit 1
printf 'канарейка 024 чиста: снимок → сверка → повторная сверка, все rc 0\n' >&2
exit 0
