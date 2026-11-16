#!/usr/bin/env bash
# Батарея 191 «Л1 — ноги формы до критика» (семья forma_do_kritika_191).
# Режимы: --repo <корень> (по умолчанию — дерево батареи, судит реальный
# субъект scripts/pre_critic.sh + scripts/check_provodka.sh), --model (честная
# модель ног), --stabs (поимка обманных реализаций; для CI — без зависимостей
# сверх bash/git/python3). Обёртка режим не подменяет и итог не печатает:
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
