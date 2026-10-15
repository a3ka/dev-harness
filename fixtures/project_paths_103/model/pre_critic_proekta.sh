#!/usr/bin/env bash
# Честная модель 103 для ноги pre_critic «--repo <R> <путь-контракта-от-R>»
# (И-2): контракт резолвится ТОЛЬКО от корня проекта --repo, никогда от cwd
# или корня харнеса; вердикт (rc, первая строка stderr) не зависит от cwd.
# Без --repo — поведение 072 (корень = место скрипта) не моделируется; нога
# (в) Н-39 не моделируется — её грамматика 072.
# Ноги (а)/(б) (Frontier И-2: «npm-гейты зовутся с R вместо `.`») моделируются
# ВЫЗОВОМ гейтов харнеса check_precision_gate.sh / check_spec_ready.sh с R
# (грамматика самих гейтов — 043/036, здесь не переизобретается): красный гейт
# → именованный отказ с маркером ноги 072 «precision-gate» / «spec-ready» ДО
# ноги формы; снятые или условные на --repo ноги — rc 0 на контракте с красным
# гейтом (Рв96-3/Рв96-13: мутанты PC3a/PC3b).
# Нога формы (г) 095: вооружается наличием
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
HARNESS="${PP103_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
for g in check_precision_gate.sh check_spec_ready.sh profile_resolver.sh; do
  [ -f "$HARNESS/scripts/$g" ] || { printf 'NOT_IMPLEMENTED: нет %s/scripts/%s\n' "$HARNESS" "$g" >&2; exit 2; }
done
# (а)/(б): гейты харнеса судят контракт проекта с корнем R (не `.`, не корень харнеса).
bash "$HARNESS/scripts/check_precision_gate.sh" "$BASE" "$CONTRACT" >/dev/null 2>&1 || { printf 'ОТКАЗ: precision-gate красен: %s\n' "$CONTRACT" >&2; exit 1; } # t103-m17
bash "$HARNESS/scripts/check_spec_ready.sh" "$BASE" "$CONTRACT" >/dev/null 2>&1 || { printf 'ОТКАЗ: spec-ready красен: %s\n' "$CONTRACT" >&2; exit 1; } # t103-m18
# (г): форма, вооружённая профильным реестром по резолверу.
RESOLVER="$HARNESS/scripts/profile_resolver.sh"
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
