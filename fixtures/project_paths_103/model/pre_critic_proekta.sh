#!/usr/bin/env bash
# Честная модель 103 для ноги pre_critic «--repo <R> <путь-контракта-от-R>»
# (И-2): контракт резолвится ТОЛЬКО от корня проекта --repo, никогда от cwd
# или корня харнеса; вердикт (rc, первая строка stderr) не зависит от cwd.
# Без --repo — поведение 072 (корень = место скрипта) не моделируется; ноги
# (а)/(б) (npm-гейты с R) и (в) Н-39 не моделируются — их грамматика 043/036/072.
# Моделируется нога формы (г) 095: вооружается наличием
# <workflowPaths.registry>/contracts.tsv в R, где workflowPaths.registry —
# эффективное значение ТОЛЬКО из MERGED scripts/profile_resolver.sh --repo R
# (слой проекта — HARNESS_PROJECT_LAYER_ROOT, по умолчанию R). Свой jq по
# harness.project.json под R — «второй резолвер» (Рв96-2): при слое вне репо и
# репо-слое без workflowPaths нога молча разоружается. Вооружённая нога: нет
# «КОНТЕКСТ:» → «ОТКАЗ: форма: контракт без строк КОНТЕКСТ:»; нет
# «## Существующее» → «ОТКАЗ: форма: контракт без секции Существующее».
set -uo pipefail
REPO=""; CONTRACT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    *) CONTRACT="$1"; shift ;;
  esac
done
[ -n "$REPO" ] || { printf 'NOT_IMPLEMENTED: модель требует --repo\n' >&2; exit 2; }
[ -d "$REPO" ] || { printf 'NOT_IMPLEMENTED: нет корня проекта: %s\n' "$REPO" >&2; exit 2; }
BASE="$REPO" # t103-m7
F="$BASE/$CONTRACT"
[ -f "$F" ] || { printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$CONTRACT" >&2; exit 2; }
RESOLVER="${PP103_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}/scripts/profile_resolver.sh"
[ -f "$RESOLVER" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$RESOLVER" >&2; exit 2; }
[ -n "${HARNESS_PROJECT_LAYER_ROOT:-}" ] || export HARNESS_PROJECT_LAYER_ROOT="$BASE"
MERGED="$(bash "$RESOLVER" --repo "$BASE" 2>/dev/null)" || { printf 'ОТКАЗ: профиль не резолвится: %s\n' "$BASE" >&2; exit 1; }
REG="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.registry.value // empty' 2>/dev/null)" # t103-m16
[ -n "$REG" ] || { printf 'ОТКАЗ: профиль без workflowPaths.registry\n' >&2; exit 1; }
if [ -r "$BASE/$REG/contracts.tsv" ]; then
  LC_ALL=C grep -qE '^КОНТЕКСТ:' "$F" || { printf 'ОТКАЗ: форма: контракт без строк КОНТЕКСТ:\n' >&2; exit 1; }
  LC_ALL=C grep -qE '^## Существующее' "$F" || { printf 'ОТКАЗ: форма: контракт без секции Существующее\n' >&2; exit 1; }
fi
printf 'КРИТИК: дверь зелёная\n'
exit 0
