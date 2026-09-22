#!/usr/bin/env bash
# Live reproduction: after ПРОВОДКА:, the parser silently drops every line not
# beginning with literal `- `. A second, channel-shaped but grammar-invalid
# line can therefore conceal an unwired/missing role behind a valid first role.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-bare-channel.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles"
printf 'Honest role norm.\n' > "$R/roles/honest.md"

run() {
  local label="$1" contract="$2" expected="$3" out rc
  printf '%s' "$contract" > "$R/contracts/001.md"
  out="$(/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; rc=$?
  printf '%s: rc=%s\n' "$label" "$rc"
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: expected rc=%s\n%s\n' "$label" "$expected" "$out" >&2
    exit 2
  fi
}

run honest-role-control 'ПРОВОДКА:
- role=roles/honest.md «Honest role norm.»
' 0

# This second line remains before any heading that could terminate the field,
# resembles a role channel, but violates its mandatory `- ` prefix. Its role
# target does not exist and its stated norm is therefore objectively unwired.
run bare-channel-with-missing-role 'ПРОВОДКА:
- role=roles/honest.md «Honest role norm.»
role=roles/missing.md «Missing role norm.»
' 0

# Neutralisation: making exactly that hidden declaration syntactically valid
# exposes the missing role and must turn the same logical input red.
run prefixed-missing-role-control 'ПРОВОДКА:
- role=roles/honest.md «Honest role norm.»
- role=roles/missing.md «Missing role norm.»
' 1
printf 'REPRODUCED: an invalid bare role line in ПРОВОДКА was ignored, so the checker returned green although that declared channel has no role file or norm.\n'
