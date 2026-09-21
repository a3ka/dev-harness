#!/usr/bin/env bash
# G1 — полный честный вход: три канала (guard подключён + role-строка + charter
# в своей секции) → rc 0. Позитив-контроль: вечно-красный барьер неотличим от
# работающего (канон семьи, _repo.sh freeze).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/g1_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$T" 'chestrnyj kontrakt tri kanala'
run_barrier "$T"
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: G1: честный вход трёх каналов дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf 'G1: полный честный вход rc 0\n' >&2
exit 0
