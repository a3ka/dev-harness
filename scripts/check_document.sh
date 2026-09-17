#!/usr/bin/env bash
# Барьер приёмки doc-пакета (контракт 027 §Док-пакет и публичные команды).
#
# Обёртка-барьер, а не самостоятельная реализация: разбор грамматики, схемы и
# калибровки живёт в `scripts/doc_contract.ts` (НЕ БАРЬЕР), приёмка пакета —
# в `scripts/check_document.ts`. Настоящий предмет вызова НЕ дублируется здесь
# и не подменяется shell-эвристикой; `exec` передаёт код возврата node-CLI
# насквозь, без промежуточного bash-процесса и без потери rc.
#
# Использование (оба вызова эквивалентны — обёртка резолвит рядом со собой):
#   node scripts/check_document.ts --root <project> --contract <path> --preflight
#   node scripts/check_document.ts --root <project> --contract <path> --check
#   bash scripts/check_document.sh --root <project> --contract <path> --preflight
#   bash scripts/check_document.sh --root <project> --contract <path> --check
#
# --preflight читает draft-критерий: схема + калибровка (positive принят, каждый
# negative конформен и отвергнут своим violation), не требует готового Markdown.
# --check читает наибольшую frozen-версию этого NNN и сверяет пакет целиком.
#
# Коды возврата: 0 — машинная мера выполнена, 1 — именованное нарушение, 2 — нечем проверить.
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "$SELF_DIR/check_document.ts" "$@"
