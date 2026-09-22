#!/usr/bin/env bash
# Live reproduction for Adversary 038 round 4: malformed role channel passes.
# The contract grammar permits exactly `role=roles/<роль>.md «<норма-строка>`,
# with no embedded «…» pair inside the norm.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-parser.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles"
printf 'Honest role norm.\n' > "$R/roles/valid.md"

run() {
  local label="$1" expected="$2" out rc
  out="$(bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; rc=$?
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: rc=%s, expected %s\n%s\n' "$label" "$rc" "$expected" "$out" >&2
    exit 1
  fi
  printf '%s: rc=%s\n' "$label" "$rc"
}

# Positive control: a minimal honest role channel is green.
printf 'ПРОВОДКА:\n- role=roles/valid.md «Honest role norm.»\n' > "$R/contracts/001.md"
run honest-minimal 0

# Deceptive stub A: non-grammar text is inserted both before the opening quote
# and after the closing quote. It is neither part of the target nor of the norm,
# but the implementation takes the first ASCII-space-delimited word as $path and
# extract_quoted silently ignores both fragments.
printf 'ПРОВОДКА:\n- role=roles/valid.md NOT-GRAMMAR «Honest role norm.» TRAILING-GARBAGE\n' > "$R/contracts/001.md"
run arbitrary-text-around-norm-accepted 0

# Deceptive stub B: nested paired quotation is explicitly forbidden by contract
# 038. extract_quoted nevertheless takes the outermost pair and grep accepts the
# composed string as a role norm.
printf 'Outer «embedded» tail\n' >> "$R/roles/valid.md"
printf 'ПРОВОДКА:\n- role=roles/valid.md «Outer «embedded» tail»\n' > "$R/contracts/001.md"
run nested-quotes-accepted 0

printf 'REPRODUCED: malformed role declarations passed as green.\n'
