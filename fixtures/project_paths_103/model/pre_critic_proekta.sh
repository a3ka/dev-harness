#!/usr/bin/env bash
# Честная модель 103 для ноги pre_critic «--repo <R> <путь-контракта-от-R>»
# (И-2): контракт резолвится ТОЛЬКО от корня проекта --repo, никогда от cwd
# или корня харнеса; вердикт (rc, первая строка stderr) не зависит от cwd.
# Без --repo — поведение 072 (корень = место скрипта) не моделируется.
# Моделируется нога формы (г) 095: нет «КОНТЕКСТ:» → «ОТКАЗ: форма: контракт
# без строк КОНТЕКСТ:»; нет «## Существующее» → «ОТКАЗ: форма: контракт без
# секции Существующее».
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
LC_ALL=C grep -qE '^КОНТЕКСТ:' "$F" || { printf 'ОТКАЗ: форма: контракт без строк КОНТЕКСТ:\n' >&2; exit 1; }
LC_ALL=C grep -qE '^## Существующее' "$F" || { printf 'ОТКАЗ: форма: контракт без секции Существующее\n' >&2; exit 1; }
exit 0
