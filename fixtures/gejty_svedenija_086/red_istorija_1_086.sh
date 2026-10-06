#!/usr/bin/env bash
# Красное предъявление контракта 086, позитивный контроль на истории: ленды R1-R3 таблицы
# T86_ISTORIJA (_toy.sh) через scripts/gejt_svedenija.sh okno; каждая проверка окна ≤ 60 с.
#   bash fixtures/gejty_svedenija_086/red_istorija_1_086.sh [<корень дерева>]
# rc 0 — каждый ленд дал ожидание таблицы; rc 1 — расхождение (КРАСНО с кодом ленда) либо
# предмет отсутствует; rc 2 — история недоступна (не красное предъявление).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_toy.sh"
TREE="$(t86_derevo "${1:-}" "$HERE")" || { printf 'NOT_IMPLEMENTED: корень дерева не найден\n' >&2; exit 2; }
S="$(mktemp -d "${TMPDIR:-/tmp}/gejty086_ist1.XXXXXX")" || exit 2
trap 'rm -rf "$S"' EXIT
t86_istorija_fajl "$TREE" "$S" R1 R2 R3
t86_itog red_istorija_1_086.sh
