#!/usr/bin/env bash
# КРАСНОЕ 025-И-5 (пачка C): пин worktree из строки WORKTREE= задания +
# ALLOWLIST записи (решение владельца Г3): пинн + ${TMPDIR}/dev-harness-verify +
# artifact://; чтение свободно; запрет записи в основной чекаут И чужие worktree;
# несуществующий пинн → отказ на старте сессии.
# СУБЪЕКТ: пин-логика расширения path-guard (selftest-контракт контракта 025
# §Пачка C; носитель — .omp/extensions/path-guard.ts, пин-ветвь).
# СЕГОДНЯ: модуль отсутствует → именованный отказ rc 1. ПОСЛЕ: rc 0.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"
if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-И-5: механизм отсутствует — %s не существует; запись абсолютным путём в основной чекаут из спавн-сессии не стережётся (следствие А-72 не ловится)\n' "$SUBJ" >&2
  exit 1
fi
exec node "$SUBJ" --selftest --pin
