#!/usr/bin/env bash
# D9 — два вердикта, свежий FAIL: v1 accept закоммичен раньше, v2 FAIL — позже;
# писатель обязан взять СВЕЖИЙ по коммит-истории и назвать ЕГО имя в отказе.
# Стаб-привязка (Н-39): стаб «первый найденный файл по глобу» ловится здесь.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d9_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"   # v1 accept уже в основании
put_verdict "$T" contracts-001-v2.md 'FAIL'
commit_all "$T" 'svezhij verdikt fail'
run_writer "$T" 'prizemlenie'
refuse 'D9' 'done: несколько вердиктов, свежий contracts-001-v2.md не accept'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D9: после отказа записаны done-теги\n' >&2; exit 1; }
exit 0
