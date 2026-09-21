#!/usr/bin/env bash
# G2 (В1) — guard-only СО строкой «ПРОВОДКА-ЭНФОРСМЕНТ: <непустое обоснование>»
# в контракте → rc 0: чистый энфорсмент легитимен при названном обосновании.
# Стаб-привязка (Н-39): пара к R10 — тот же стаб, другая ветвь В1; обоснование
# судит ревьюер (роль), барьер проверяет наличие и непустоту.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/g2_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh

ПРОВОДКА-ЭНФОРСМЕНТ: chistyj enforsment — barjer sam garantiruet grammatiku taga, povedencheskoj normy net'
commit_all "$T" 'kontrakt guard-only s obosnovaniem'
run_barrier "$T"
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: G2: guard-only с обоснованием дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf 'G2: guard-only с обоснованием rc 0\n' >&2
exit 0
