#!/usr/bin/env bash
# Контракт 116: без флага — живой scripts/ekran_shablon.py; --model — эталон
# 132; --stabs — честный эталон и каждая адресная мутация. Все режимы
# передаются аргументом, не переопределяются обёрткой; stdout и rc — из
# probe.py. До ленда субъекта CI использует --stabs, после ленда — без флага.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
