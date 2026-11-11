#!/usr/bin/env bash
# Батарея 189 «Л4 — стандартные валидаторы и канон» (семья standartnye_validatory_189).
# Режимы: --repo <корень> (по умолчанию — дерево батареи, судит реальный субъект),
# --model (честная модель), --stabs (поимка обманных реализаций; для CI —
# не требует pyyaml/jsonschema). Обёртка режим не подменяет и итог не печатает:
# итог — код возврата probe.py.
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
