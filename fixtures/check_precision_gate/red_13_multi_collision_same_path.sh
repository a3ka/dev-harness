#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: зона-коллизия: ...
# Б1 fix: ДВЕ независимые коллизии на ОДНОМ пути (991 alice + 992 bob владеют
# shared/file.txt), черновик 043 объявляет путь за architect и объявляет
# ПЕРЕСЕЧЕНИЕ только для 991 — должна блокироваться НЕОБЪЯВЛЕННАЯ 992. Прежний
# код останавливался на ПЕРВОМ чужом NNN (991), и объявление этой коллизии
# гасило обе — обход молчаливо пропускал нарушение предмета (критик 043 v1 Б1).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case13.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_foreign_frozen "$WORK" 991 alice shared/file.txt
mk_foreign_frozen "$WORK" 992 bob shared/file.txt
# Только для 991, для 992 — молча (прежний код бы прошёл, новый должен красить).
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md shared/file.txt

ПЕРЕСЕЧЕНИЕ architect: shared/file.txt — 991 коллизия только с первой (991 alice) объявлена'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_13 (две коллизии на одном пути, объявлена только 991)' \
  'зона-коллизия: shared/file.txt заявлен architect (этот контракт, NNN 043), уже в union под NNN 992 для bob — нужна строка ПЕРЕСЕЧЕНИЕ architect: shared/file.txt — 992 <причина>'
exit 0