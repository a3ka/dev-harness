#!/usr/bin/env bash
# s3 STUB:AS_NO_VALUE — --as без значения НЕ отказывает (defect)
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }
IDENTITY=""
if [ -n "${GIT_AUTHOR_NAME:-}" ]; then IDENTITY="$GIT_AUTHOR_NAME"
elif [ -n "${GIT_COMMITTER_NAME:-}" ]; then IDENTITY="$GIT_COMMITTER_NAME"
fi
AS_COUNT=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --as)
      shift
      AS_COUNT=$((AS_COUNT + 1))
      # дефект: НЕ проверяем пустую строку после --as
      if [ -n "${1:-}" ]; then
        IDENTITY="$1"
      fi
      shift
      ;;
    *) shift ;;
  esac
done
[ -n "$IDENTITY" ] || {
  printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
  exit 1
}
printf 'ПЕРЕЗАПУСК: identity=%s as_count=%d\n' "$IDENTITY" "$AS_COUNT"
exit 0