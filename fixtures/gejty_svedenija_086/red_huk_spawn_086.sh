#!/usr/bin/env bash
# Красное предъявление контракта 086, точки .githooks/pre-merge-commit и scripts/spawn_agent.sh:
# клетки H1-H3, S0, S1.
#   bash fixtures/gejty_svedenija_086/red_huk_spawn_086.sh [<корень дерева>] [<клетка>…]
# rc 0 — все клетки зелёные; rc 1 — есть красная (печатает «КРАСНО: <клетка>: <причина>»);
# rc 2 — клетка не исполнена (игрушка не построилась; пробой — не красное предъявление).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_toy.sh"
if [ "$#" -gt 0 ] && [ -d "$1" ]; then TREE="$(t86_derevo "$1" "$HERE")"; shift; else TREE="$(t86_derevo '' "$HERE")"; fi
[ -n "${TREE:-}" ] || { printf 'NOT_IMPLEMENTED: корень дерева не найден\n' >&2; exit 2; }
KLETKI=(H1 H2 H3 S0 S1)
[ "$#" -gt 0 ] && KLETKI=("$@")
S="$(mktemp -d "${TMPDIR:-/tmp}/gejty086_huk.XXXXXX")" || exit 2
trap 'rm -rf "$S"' EXIT
t86_prognat "$TREE" "$S" "${KLETKI[@]}"
t86_itog red_huk_spawn_086.sh
