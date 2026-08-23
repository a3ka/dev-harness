#!/usr/bin/env bash
# НЕ БАРЬЕР: предмет среза-2 контракта 008. Судья гейтит через CI-сигнал (Н-41): зовёт
# соседний check_ci_gate.sh с переданным SHA, пропускает его код в свой. Убирает локальный
# ре-прогон 15-23-мин пачки; судья подтверждает зелёное по ЗАПУШЕННОМУ HEAD.
# Принимает аргумент <sha>, поэтому не самодостаточен для прогона на текущем дереве без
# указания — verify_antiplacebo не покрывает.
#
# Контракт API (закреплён meta-барьером check_judge_gate.sh):
#   вход: $1 = <sha> (ОБЯЗАН передать в check_ci_gate — иначе bypass #3);
#   ищет check_ci_gate.sh рядом (SELF_DIR предмета);
#   rc: 0 если check_ci_gate rc=0, иначе rc≠0. На зелёном печатает «OK» последней строкой.
set -uo pipefail

sha="${1:?использование: $0 <sha>}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -x "$SELF/check_ci_gate.sh" ] || {
  printf 'ОТКАЗ: check_ci_gate.sh не найден рядом (нужен %s/check_ci_gate.sh)\n' "$SELF" >&2
  exit 1
}

rc=0
"$SELF/check_ci_gate.sh" "$sha" || rc=$?
if [ "$rc" = 0 ]; then printf 'OK\n'; fi
exit "$rc"