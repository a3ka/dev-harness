#!/usr/bin/env bash
# D1 — первая строка вердикта — заголовок: «# Вердикт ревьюера» вне грамматики
# (равенство «accept» после trim+fold, НЕ префикс/НЕ заголовок) → отказ, тега нет.
# Стаб-привязка (Н-39): стаб «читает только наличие файла» ловится здесь.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d1_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
put_verdict "$T" contracts-001-v1.md '# Вердикт ревьюера'
commit_all "$T" 'verdikt-zagolovok'
run_writer "$T" 'prizemlenie normy'
refuse 'D1' 'done: вердикт вне грамматики: # Вердикт ревьюера'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D1: после отказа записаны done-теги: %s\n' "$(done_tags "$T")" >&2; exit 1; }
exit 0
