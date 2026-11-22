#!/usr/bin/env bash
# 205: реальная дверь проводки выбранного дерева (--repo ROOT, умолчание —
# дерево батареи), модель четвёртой локации (--model) и адресные мутации
# модели по привязкам stabs.tsv (--stabs). Данные миров и ожидания
# принадлежат probe.py, а не проверяемой двери.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$here/probe.py" "$@"
