#!/usr/bin/env bash
# red_dovodka_ui_133.sh — красная батарея контракта 133 (dovodka-ui).
# Режимы, исходы и коды — докстринг dovodka_ui_133.py (единственный движок); ожидания — source.json.
# Коды: 0 — сошлось / все подмены пойманы; 1 — расхождение / предмет отсутствует; 2 — нечем судить.
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
exec python3 "$HERE/dovodka_ui_133.py" "$@"
