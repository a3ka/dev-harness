#!/usr/bin/env bash
# Батарея 207 «check_zones --incr: суд окна один раз» (семья
# check_zones_incr_207). Режимы: --repo <корень> (по умолчанию — живое дерево
# батареи; судит реальную scripts/check_zones.sh выбранного дерева: эквивалентность
# incr↔полный прогон, счётчики судов окна под strace — КРАСНОЕ до реализации),
# --model (модель окна-один-раз: байт-в-байт равенство с базовой дверью),
# --base (зафиксированная база base/check_zones.sh как субъект: честный
# контроль клеток Б-1, стабилен до и после правки implementer — урок 208 Б-2),
# Обёртка режим не подменяет и итог не печатает: итог — код возврата probe.py.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
case "${1:---repo}" in
  --repo)
    [ "$#" -gt 0 ] && shift
    python3 "$here/probe.py" --repo "${1:-$(cd "$here/../../.." && pwd -P)}" ;;
  --model) shift; python3 "$here/probe.py" --model "$@" ;;
  --base) shift; python3 "$here/probe.py" --base "$@" ;;
  --stabs) shift; python3 "$here/probe.py" --stabs "$@" ;;
  --catalog) shift; python3 -B "$here/probe.py" --catalog "$@" ;;
  *) printf 'NOT_IMPLEMENTED: invalid mode\n' >&2; exit 2 ;;
esac
