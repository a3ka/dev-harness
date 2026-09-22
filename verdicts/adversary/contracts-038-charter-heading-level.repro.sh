#!/usr/bin/env bash
# Live reproduction for Contract 038: heading level is calculated from RLENGTH,
# so an additional separator space makes a same-level `##` heading look lower.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-charter-heading.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
ROOT="$WORK/tree"
mkdir -p "$ROOT/contracts"
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Target «Target norm.»\n' > "$ROOT/contracts/honest.md"
printf '# Charter\n\n## Target\nTarget norm.\n\n## Next\nForeign norm.\n' > "$ROOT/AGENTS.md"

run() {
  local label="$1" contract="$2" expected="$3" out rc
  out="$(bash "$SUBJECT" "$ROOT" "contracts/$contract" 2>&1)"; rc=$?
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: rc=%s, expected %s\n%s\n' "$label" "$rc" "$expected" "$out" >&2
    exit 2
  fi
  printf '%s: rc=%s\n' "$label" "$rc"
}

run honest-target-norm honest.md 0
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Target «Foreign norm.»\n' > "$ROOT/contracts/red.md"
run single-space-same-level-boundary-red red.md 1
printf '# Charter\n\n## Target\nTarget norm.\n\n##  Next\nForeign norm.\n' > "$ROOT/AGENTS.md"
run extra-space-same-level-boundary-red red.md 0
printf 'REPRODUCED: `##  Next` is a same-level heading but its norm leaks into §Target because level calculation counts separator whitespace.\n'
