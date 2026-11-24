#!/usr/bin/env bash
# БАРЬЕР контракта 221: CLI минта в проекте; результат — rc probe221.py.
# --repo <root> / --model / --stabs / --sintaksis, без флага — --repo дерева.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe221.py" "$@"
