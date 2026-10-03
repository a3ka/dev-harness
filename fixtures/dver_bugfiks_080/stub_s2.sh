#!/usr/bin/env bash
# s2 STUB:IDENTITY_AS_REQUIRED — требует --as всегда (env игнорируется)
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }
AS=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --as) shift; AS="${1:-}"; shift ;;
    *) shift ;;
  esac
done
[ -n "$AS" ] || {
  printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
  exit 1
}
printf 'ПЕРЕЗАПУСК: identity=%s (as-only)\n' "$AS"
exit 0