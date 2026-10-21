#!/usr/bin/env bash
# Красная батарея 128 (wait-guard). Движок и грамматика режимов/кодов —
# докстринг wait_guard_128.py рядом (единый источник); ожидания — source.json.
#   bash red_wait_guard_128.sh                    — субъект дерева (сегодня rc 1: предмет отсутствует)
#   bash red_wait_guard_128.sh --model            — честная модель (rc 0)
#   bash red_wait_guard_128.sh --stabs            — обманные стабы (rc 0 = 0 непойманных)
#   bash red_wait_guard_128.sh --candidate <клон> — доставленное дерево implementer
#   bash red_wait_guard_128.sh --live [<клон>]    — живые условия станции (rc 2 вне станции)
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
command -v node >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет node' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/wait_guard_128.py" "$@"
