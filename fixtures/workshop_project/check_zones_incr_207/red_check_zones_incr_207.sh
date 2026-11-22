#!/usr/bin/env bash
# Батарея 207 «check_zones --incr: суд окна один раз» (семья
# check_zones_incr_207). Режимы: --repo <корень> (по умолчанию — живое дерево
# батареи; судит реальную scripts/check_zones.sh выбранного дерева: эквивалентность
# incr↔полный прогон, счётчики судов окна под strace — КРАСНОЕ до реализации),
# --model (модель окна-один-раз: байт-в-байт равенство с базовой дверью),
# --stabs (адресные мутации модели и обманные стабы по stabs.tsv; ZHIVYH == 0).
# Обёртка режим не подменяет и итог не печатает: итог — код возврата probe.py.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
case "${1:---repo}" in
  --repo)
    [ "$#" -gt 0 ] && shift
    python3 "$here/probe.py" --repo "${1:-$(cd "$here/../../.." && pwd -P)}" ;;
  --model) python3 "$here/probe.py" --model ;;
  --stabs) python3 "$here/probe.py" --stabs ;;
  *) printf 'NOT_IMPLEMENTED: invalid mode\n' >&2; exit 2 ;;
esac
