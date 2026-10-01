#!/usr/bin/env bash
# ПРИЧИНА: честный toy-контракт с ЦИТИРОВАННОЙ отметкой в кавычках → порог
# отсекает отметку от предложения (правило 8) → rc 0, двери зелёная.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/prec_case01.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

mk_toy_repo "$WORK"

# ЧЕСТНЫЙ черновик (цитированная отметка «s1 умирает на клетке X»)
cat > "$WORK/contracts/043-toy-draft.md" <<'MD'
# Контракт 043 — честный toy-черновик

## Предмет
p

## Красные предъявления

Красная клетка батареи кладёт в toy-контракт строку «s1 умирает на клетке X» и требует отказа — цитата, не утверждение.

## Незаполненные требования:
нет
MD
git -C "$WORK" add -A && git -C "$WORK" commit -qm 'toy: честный'

run_subject "$WORK" 'contracts/043-toy-draft.md'
accept 'case_01 (честный черновик с цитатой — дверь зелёная)'
exit 0