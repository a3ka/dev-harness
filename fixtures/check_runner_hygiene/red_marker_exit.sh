#!/usr/bin/env bash
# КРАСНОЕ 025-И-4 (пачка B-2): extension exit-marker — строка [exit=N] в каждом
# bash tool_result из details харнеса (независимо от эха агента).
# СУБЪЕКТ: .omp/extensions/exit-marker.ts (--selftest, прецедент metering).
# СЕГОДНЯ: модуль отсутствует → именованный отказ rc 1. ПОСЛЕ: rc 0.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/exit-marker.ts"
if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-И-4: механизм отсутствует — %s не существует; rc bash-вызова виден агенту только его собственным эхом (форма «руками echo rc=0» не ловится)\n' "$SUBJ" >&2
  exit 1
fi
exec node "$SUBJ" --selftest
