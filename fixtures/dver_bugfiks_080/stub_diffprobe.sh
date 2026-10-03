#!/usr/bin/env bash
# diff-probe stubs — те же стабы без РУЧКИ (дефекта), дают честное поведение
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }
IDENTITY=""
if [ -n "${GIT_AUTHOR_NAME:-}" ]; then IDENTITY="$GIT_AUTHOR_NAME"
elif [ -n "${GIT_COMMITTER_NAME:-}" ]; then IDENTITY="$GIT_COMMITTER_NAME"
fi
AS_COUNT=0
AS_VAL=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --as)
      shift
      AS_COUNT=$((AS_COUNT + 1))
      if [ -z "${1:-}" ]; then
        printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
        exit 1
      fi
      if [ -n "$IDENTITY" ]; then
        printf '--as задан дважды\n' >&2
        exit 1
      fi
      AS_VAL="$1"
      IDENTITY="$1"
      shift
      ;;
    *) shift ;;
  esac
done
[ -n "$IDENTITY" ] || {
  printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
  exit 1
}
# Pass-through: проверяем ORCH_SESS_DIR (живые субагенты)
SESS="${ORCH_SESS_DIR:-/tmp/dev-harness-verify/_nope_sess_$$}"
if [ -d "$SESS" ]; then
  NOW=$(date +%s)
  for f in "$SESS"/*.jsonl; do
    [ -e "$f" ] || continue
    mt=$(stat -c %Y "$f" 2>/dev/null || echo 0)
    [ "$((NOW - mt))" -lt 120 ] || continue
    n=$(basename "$f" .jsonl)
    printf 'живые субагенты: %s\n' "$n" >&2
    exit 1
  done
fi
printf 'ПЕРЕЗАПУСК: identity=%s as_count=%d (clean)\n' "$IDENTITY" "$AS_COUNT"
exit 0