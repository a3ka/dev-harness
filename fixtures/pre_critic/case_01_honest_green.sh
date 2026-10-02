#!/usr/bin/env bash
# ПРИЧИНА: Н-39: привязка стаба в прозе
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# ОКРУЖЕНИЕ: TMPDIR=/tmp
#
# Честный минимум семьи pre_critic (контракт 072): зелёная ветка —
# честный toy-контракт с ЦИТИРОВАННОЙ отметкой «s1 умирает на клетке X»
# в кавычках → порог (правило 8) отсекает отметку от предложения →
# дверь зелёная, rc 0. Красная ветка — тот же toy-контракт, но строка
# «s1 умирает на клетке X» голая (без кавычек) → именованный отказ
# «Н-39: привязка стаба в прозе, строка N» (N — номер строки в контракте).
#
# Каркас _toy.sh (комментарий и зона): зеркало семьи 043, красные ветки
# держит батарея dver_pered_kritikom; здесь — контрольная зелёная +
# честное предъявление красного повторным прогоном проверяющего.
#
# BARRIER_ROOT=$WORK — seam verify_antiplacebo (ap_run): копирует scripts/pre_critic.sh
# в $WORK/scripts/pre_critic.sh перед вызовом; BASH_SOURCE/.. двери → $WORK,
# дверь судит toy-мир, не основной репо. Без BARRIER_ROOT ap_run не копирует —
# дверь судит $REPO (BASH_SOURCE → $REPO), контракт-путь contracts/043-toy-draft.md
# резолвится в $REPO/contracts/043-toy-draft.md (нет такого) → rc 2
# NOT_IMPLEMENTED «контракт не найден» — антиплацебо красит «нечем проверить».
#
# TMPDIR=/tmp — снапшот детектора живёт ВНЕ $WORK (здесь он не используется
# pre_critic'ом, но канон: все файлы игры пишут ВНЕ $WORK, иначе mktemp в
# producer-ногах TRACKED/UNTRACKED загрязняет дерево).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

[ -n "${BARRIER:-}" ] || { echo "BARRIER not set" >&2; exit 2; }
: "${WORK:?WORK must be set by verify_antiplacebo}"
export TMPDIR="/tmp"

# Toy-мир: реальные гейты + безаргументный package.json + минимальный ci.yml +
# ci_parity_exceptions.txt. Контракт-путь резолвится из toy-корня, как в
# red_dver_pred_kritikom_072.sh.
mkdir -p "$WORK/scripts" "$WORK/contracts" "$WORK/.github/workflows" "$WORK/config"
cp "$REPO/scripts/check_precision_gate.sh" "$REPO/scripts/check_spec_ready.sh" "$REPO/scripts/verify_ci_parity.sh" "$WORK/scripts/"
cp "$REPO/scripts/lib_"*.sh "$WORK/scripts/"
cat > "$WORK/package.json" <<JSON
{
  "name": "toy",
  "version": "1.0.0",
  "scripts": {
    "check:precision-gate": "bash scripts/check_precision_gate.sh",
    "check:spec-ready": "bash scripts/check_spec_ready.sh"
  }
}
JSON
cat > "$WORK/.github/workflows/ci.yml" <<'YML'
name: toy-ci
on: [push]
jobs:
  toy:
    runs-on: ubuntu-latest
    steps:
      - run: npm run check:precision-gate -- . contracts/043-toy-draft.md
      - run: npm run check:spec-ready -- . contracts/043-toy-draft.md
YML
: > "$WORK/config/ci_parity_exceptions.txt"
git -C "$WORK" init -q -b main
git -C "$WORK" config user.name orchestrator
git -C "$WORK" config user.email orchestrator@dev-harness.local

# ЗЕЛЁНЫЙ черновик (цитированная отметка «s1 умирает на клетке X»): порог
# правила 8 — совпадение внутри кавычек «…» — ОТМЕТКА, не предложение.
cat > "$WORK/contracts/043-toy-draft.md" <<'MD'
# Контракт 043 — честный toy-черновик

## Предмет
p

## Красные предъявления

Красная клетка батареи кладёт в toy-контракт строку «s1 умирает на клетке X» и требует отказа — цитата, не утверждение.

## Незаполненные требования:
нет
MD

# КРАСНЫЙ черновик (голая привязка: s1 умирает на клетке X БЕЗ кавычек):
# порог правила 8 — голое совпадение — ПРЕДЛОЖЕНИЕ → отказ rc 1
# «Н-39: привязка стаба в прозе, строка N» (N — номер строки файла).
cat > "$WORK/contracts/043-red-draft.md" <<'MD'
# Контракт 043 — toy-черновик с красным нарушением

## Предмет
p

## Красные предъявления

s1 умирает на клетке X — голое предложение, не цитата.

## Незаполненные требования:
нет
MD

git -C "$WORK" add -A && git -C "$WORK" commit -qm 'toy: init'

# ЗЕЛЁНАЯ ВЕТКА: цитата → rc 0, дверь зелёная.
BARRIER_ROOT="$WORK" "$BARRIER" 'contracts/043-toy-draft.md' >/dev/null 2>&1
rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: зелёная ветка rc %s, ожидался 0\n' "$rc" >&2; exit 1; }
printf '%s: rc 0, дверь зелёная\n' "case_01-green" >&2

# КРАСНАЯ ВЕТКА: голое предложение → rc 1 «Н-39: привязка стаба в прозе, строка N».
BARRIER_ROOT="$WORK" "$BARRIER" 'contracts/043-red-draft.md' 2>&1 | grep -Eq -- 'Н-39: привязка стаба в прозе, строка [0-9]+' \
  || { printf 'ОТКАЗ: красная ветка не назвала «Н-39: привязка стаба в прозе, строка N»\n' >&2; exit 1; }
printf '%s: rc 1 «Н-39: привязка стаба в прозе, строка N»\n' "case_01-red" >&2
exit 0