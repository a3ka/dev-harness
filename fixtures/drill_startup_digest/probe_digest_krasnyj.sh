#!/usr/bin/env bash
# Проба контракта 015, механизм 3 (Н-62): красная ДО реализации (дрилла нет), зелёная
# ПОСЛЕ — дрилл прогоняет настоящего nabludenia_digest.sh + startup-digest.ts на
# собственном песочничном дереве (git-мини-репо с file://-remote, без сети) и требует
# нуля. Живое дерево дриллом не мутируется.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
D="$ROOT/scripts/drill_startup_digest.sh"

if [ ! -f "$D" ]; then
  printf 'ОТКАЗ: дрилла нет — %s (реализация за implementer после заморозки)\n' "$D" >&2
  exit 1
fi
if bash "$D" >/dev/null 2>&1; then
  printf 'ok: дрилл startup-digest зелёный на живом дереве\n'
  exit 0
fi
rc=$?
printf 'ОТКАЗ: дрилл startup-digest красен (rc=%d)\n' "$rc" >&2
exit 1
