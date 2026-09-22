#!/usr/bin/env bash
# Live reproduction for Contract 038: the checker serializes `kind|rest|line`
# and drops everything in rest after a literal pipe. The red declarations below
# are outside §Инварианты 1 grammar but the subject returns green for each.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-pipe-truncation.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
ROOT="$WORK/tree"
mkdir -p "$ROOT/contracts" "$ROOT/roles" "$ROOT/scripts" "$ROOT/.githooks"
printf '#!/usr/bin/env bash\n' > "$ROOT/scripts/valid.sh"
printf 'bash scripts/valid.sh\n' > "$ROOT/.githooks/pre-commit"
printf 'Role norm.\n' > "$ROOT/roles/valid.md"
printf '# Charter\n\n## Target\nCharter norm.\n' > "$ROOT/AGENTS.md"

run() {
  local label="$1" contract="$2" expected="$3" out rc
  out="$(bash "$SUBJECT" "$ROOT" "contracts/$contract" 2>&1)"; rc=$?
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: rc=%s, expected %s\n%s\n' "$label" "$rc" "$expected" "$out" >&2
    exit 2
  fi
  printf '%s: rc=%s\n' "$label" "$rc"
}

# Vector 1 — out-of-grammar trailing text after a pipe, in all three channels.
printf 'ПРОВОДКА:\n- guard=scripts/valid.sh\nПРОВОДКА-ЭНФОРСМЕНТ: honest guard-only channel\n' > "$ROOT/contracts/honest-guard.md"
run honest-guard honest-guard.md 0
printf 'ПРОВОДКА:\n- guard=scripts/valid.sh|trailing\nПРОВОДКА-ЭНФОРСМЕНТ: honest guard-only channel\n' > "$ROOT/contracts/red-guard.md"
run pipe-tailed-guard-red red-guard.md 0

printf 'ПРОВОДКА:\n- role=roles/valid.md «Role norm.»\n' > "$ROOT/contracts/honest-role.md"
run honest-role honest-role.md 0
printf 'ПРОВОДКА:\n- role=roles/valid.md «Role norm.»|trailing\n' > "$ROOT/contracts/red-role.md"
run pipe-tailed-role-red red-role.md 0

printf 'ПРОВОДКА:\n- charter=AGENTS.md §Target «Charter norm.»\n' > "$ROOT/contracts/honest-charter.md"
run honest-charter honest-charter.md 0
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Target «Charter norm.»|trailing\n' > "$ROOT/contracts/red-charter.md"
run pipe-tailed-charter-red red-charter.md 0

# Vector 2 — an entire second channel concealed behind the pipe. Written on two
# lines the same pair is correctly rejected (control), so the only difference is
# the pipe.
printf 'ПРОВОДКА:\n- role=roles/valid.md «Role norm.»\n- role=roles/absent.md «Nonexistent norm.»\n' > "$ROOT/contracts/two-line.md"
run two-line-second-channel-control two-line.md 1
printf 'ПРОВОДКА:\n- role=roles/valid.md «Role norm.»|role=roles/absent.md «Nonexistent norm.»\n' > "$ROOT/contracts/hidden.md"
run pipe-hidden-second-channel-red hidden.md 0

printf 'REPRODUCED: a literal pipe truncates the channel payload before grammar validation — trailing junk in all three channels and an entire concealed second role channel all return green.\n'
