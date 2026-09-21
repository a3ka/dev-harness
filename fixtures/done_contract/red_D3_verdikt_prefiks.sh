#!/usr/bin/env bash
# D3 — равенство ≠ префикс: «Acceptance criteria met» и «accepted» — ВНЕ
# грамматики (два под-входа одной строки таблицы, каждый своим предъявлением).
# Стаб-привязка (Н-39): стаб «match* или срез первого слова» ловится только здесь.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d3_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT

T="$WORK/t3a"; make_drepo "$T" "$GREEN_PROVODKA"
put_verdict "$T" contracts-001-v1.md 'Acceptance criteria met'
commit_all "$T" 'verdikt-prefiks-a'
run_writer "$T" 'prizemlenie'
refuse 'D3a' 'done: вердикт вне грамматики: Acceptance criteria met'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D3a: после отказа записаны done-теги\n' >&2; exit 1; }

T="$WORK/t3b"; make_drepo "$T" "$GREEN_PROVODKA"
put_verdict "$T" contracts-001-v1.md 'accepted'
commit_all "$T" 'verdikt-prefiks-b'
run_writer "$T" 'prizemlenie'
refuse 'D3b' 'done: вердикт вне грамматики: accepted'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D3b: после отказа записаны done-теги\n' >&2; exit 1; }
exit 0
