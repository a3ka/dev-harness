#!/usr/bin/env bash
# Красное предъявление контракта 086, точка scripts/land_agent.sh: клетки L1-L7, L2b.
#   bash fixtures/gejty_svedenija_086/red_land_086.sh [<корень дерева>] [<клетка>…]
# rc 0 — все клетки зелёные; rc 1 — есть красная (печатает «КРАСНО: <клетка>: <причина>»);
# rc 2 — клетка не исполнена (игрушка не построилась; пробой — не красное предъявление).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_toy.sh"
if [ "$#" -gt 0 ] && [ -d "$1" ]; then TREE="$(t86_derevo "$1" "$HERE")"; shift; else TREE="$(t86_derevo '' "$HERE")"; fi
[ -n "${TREE:-}" ] || { printf 'NOT_IMPLEMENTED: корень дерева не найден\n' >&2; exit 2; }
KLETKI=(L1 L2 L2b L3 L4 L5 L6 L7)
[ "$#" -gt 0 ] && KLETKI=("$@")
S="$(mktemp -d "${TMPDIR:-/tmp}/gejty086_land.XXXXXX")" || exit 2
trap 'rm -rf "$S"' EXIT
t86_prognat "$TREE" "$S" "${KLETKI[@]}"
t86_itog red_land_086.sh
