#!/usr/bin/env bash
# s1 STUB:IDENTITY_FILECONFIG  — только git config user.name
# (env и --as игнорируются). Без file-config → NOT_IMPLEMENTED rc 2.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }
ID="$(git -C "$ROOT" config user.name 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет git config user.name\n' >&2; exit 2; }
[ -n "$ID" ] || { printf 'NOT_IMPLEMENTED: пустой user.name\n' >&2; exit 2; }
printf 'ПЕРЕЗАПУСК: identity=%s (fileconfig-only)\n' "$ID"
exit 0