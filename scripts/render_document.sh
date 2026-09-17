#!/usr/bin/env bash
# Барьер производных формальных фрагментов doc-пакета (контракт 027 §Док-пакет).
#
# Обёртка-барьер, а не самостоятельная реализация: генерация/сверка единственной
# пары самостоятельных строк `<!-- doc:formal:start -->` / `<!-- doc:formal:end -->`
# живёт в `scripts/render_document.ts` (использует общий разбор `doc_contract.ts`,
# НЕ БАРЬЕР). Настоящий предмет вызова НЕ дублируется здесь и не подменяется
# shell-эвристикой; `exec` передаёт код возврата node-CLI насквозь, без
# промежуточного bash-процесса и без потери rc.
#
# Использование (оба вызова эквивалентны — обёртка резолвит рядом со собой):
#   node scripts/render_document.ts --root <project> --contract <path>
#   node scripts/render_document.ts --root <project> --contract <path> --check
#   bash scripts/render_document.sh --root <project> --contract <path>
#   bash scripts/render_document.sh --root <project> --contract <path> --check
#
# Без --check генерирует/переписывает формальный фрагмент между границами в
# outputs.markdown, оставляя свободную прозу и section-маркеры нетронутыми.
# --check ничего не пишет: сравнивает детерминированный результат с тем, что
# уже лежит в файле, и отказывает на расхождении.
#
# Коды возврата: 0 — ок, 1 — именованное нарушение, 2 — нечем проверить.
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "$SELF_DIR/render_document.ts" "$@"
