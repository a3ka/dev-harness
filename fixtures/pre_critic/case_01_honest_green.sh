#!/usr/bin/env bash
# ПРИЧИНА: честный toy-контракт с ЦИТИРОВАННОЙ отметкой в кавычках → порог
# отсекает отметку от предложения (правило 8) → rc 0, дверь зелёная.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

[ -n "${BARRIER:-}" ] || { echo "BARRIER not set" >&2; exit 2; }
SUBJ="$BARRIER"
: "${WORK:?WORK must be set by verify_antiplacebo}"

# Toy-мир: реальные гейты + безаргументный package.json + минимальный ci.yml.
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

# ЧЕСТНЫЙ черновик (цитированная отметка «s1 умирает на клетке X»).
cat > "$WORK/contracts/043-toy-draft.md" <<'MD'
# Контракт 043 — честный toy-черновик

## Предмет
p

## Красные предъявления

Красная клетка батареи кладёт в toy-контракт строку «s1 умирает на клетке X» и требует отказа — цитата, не утверждение.

## Незаполненные требования:
нет
MD
git -C "$WORK" add -A && git -C "$WORK" commit -qm 'toy: init'

cd / && env bash "$SUBJ" 'contracts/043-toy-draft.md' >/dev/null 2>&1
rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: rc %s\n' "$rc" >&2; exit 1; }
printf '%s: rc 0, дверь зелёная\n' "case_01" >&2
exit 0