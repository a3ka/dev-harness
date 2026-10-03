#!/usr/bin/env bash
# s4 STUB:SKIP_AGENTS — живые субагенты НЕ блокируют (defect).
# Identity работает, но проверка ORCH_SESS_DIR/* пропущена.
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
# ДЕФЕКТ: не проверяем ORCH_SESS_DIR — даже свежие журналы проходят.
printf 'ПЕРЕЗАПУСК: identity=%s (NO agent check)\n' "$IDENTITY"
exit 0