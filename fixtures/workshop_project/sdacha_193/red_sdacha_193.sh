#!/usr/bin/env bash
# Батарея 193 «Л2 — сдаточный лист architect и карта классов вердикта» (семья
# sdacha_193). Режимы: --repo <корень> (по умолчанию — живое дерево батареи,
# судит реальные субъекты scripts/check_sdacha.sh и scripts/check_verdict_karta.sh
# плюс ноги в pre_critic/freeze), --model (честная модель), --stabs (поимка
# обманных реализаций; для CI — зависимости только bash/git/python3).
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
