#!/usr/bin/env bash
# s5 STUB:AS_MULTI — --as foo --as bar без отказа (defect)
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }
IDENTITY=""
if [ -n "${GIT_AUTHOR_NAME:-}" ]; then IDENTITY="$GIT_AUTHOR_NAME"
elif [ -n "${GIT_COMMITTER_NAME:-}" ]; then IDENTITY="$GIT_COMMITTER_NAME"
fi
while [ "$#" -gt 0 ]; do
  case "$1" in
    --as)
      shift
      # ДЕФЕКТ: каждый новый --as перезаписывает, без отказа
      if [ -n "${1:-}" ]; then IDENTITY="$1"; fi
      shift
      ;;
    *) shift ;;
  esac
done
[ -n "$IDENTITY" ] || {
  printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
  exit 1
}
printf 'ПЕРЕЗАПУСК: identity=%s (as-multi-ok)\n' "$IDENTITY"
exit 0