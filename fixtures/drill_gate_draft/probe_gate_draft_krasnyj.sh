#!/usr/bin/env bash
# Проба контракта 015, механизм 2 (Н-62): красная ДО реализации (дрилла нет), зелёная
# ПОСЛЕ — дрилл прогоняет настоящих субъектов (draft_nabludenia.sh + gate-draft.ts) и
# требует нуля. Черновики дрилл пишет в собственный скратч ВНЕ дерева (семантика 014).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
D="$ROOT/scripts/drill_gate_draft.sh"

if [ ! -f "$D" ]; then
  printf 'ОТКАЗ: дрилла нет — %s (реализация за implementer после заморозки)\n' "$D" >&2
  exit 1
fi
if bash "$D" >/dev/null 2>&1; then
  printf 'ok: дрилл gate-draft зелёный на живом дереве\n'
  exit 0
fi
rc=$?
printf 'ОТКАЗ: дрилл gate-draft красен (rc=%d)\n' "$rc" >&2
exit 1
