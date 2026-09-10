#!/usr/bin/env bash
# КРАСНОЕ 025-И-1 (пачка A-1): страж вектора утечки — extension path-guard.
# СУБЪЕКТ: .omp/extensions/path-guard.ts (selftest-контракт по прецеденту
# scripts/proxy/metering_proxy.ts --selftest).
# СЕГОДНЯ: модуль отсутствует → именованный отказ rc 1. ПОСЛЕ реализации: rc 0.
# Инвариант: selftest гоняет синтетические tool_call-события; входы и их имена
# перечислены в шапке drill_path_guard.sh (Н-39: привязка стабов — по коду).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"
if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-И-1: механизм отсутствует — %s не существует; вектор утечки (относит.-путь запись/edit) не стережётся ни одним носителем\n' "$SUBJ" >&2
  exit 1
fi
exec node "$SUBJ" --selftest
