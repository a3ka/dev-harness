#!/usr/bin/env bash
# Live reproduction: exported Bash functions outrank the PATH reset in the subject.
# The checker starts as Bash and imports BASH_FUNC_* from its caller before its body
# can export PATH=/usr/bin:/bin. Every function below makes a different invalid
# role/charter decision green; each is preceded by an honest positive control.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-exported-functions.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles" "$R/policies"
printf 'Honest role norm.\n' > "$R/roles/honest.md"
printf 'Outside role norm.\n' > "$R/policies/outside-role.md"
printf '# Charter\n\n## Pinned section\nHonest charter norm.\n' > "$R/AGENTS.md"

run() {
  local label="$1" expected="$2" out rc
  out="$(bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; rc=$?
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: rc=%s, expected %s\n%s\n' "$label" "$rc" "$expected" "$out" >&2
    exit 1
  fi
  printf '%s: rc=%s\n' "$label" "$rc"
}

# Honest positive controls.
printf 'ПРОВОДКА:\n- role=roles/honest.md «Honest role norm.»\n' > "$R/contracts/001.md"
run honest-role 0
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Honest charter norm.»\n' > "$R/contracts/001.md"
run honest-charter 0

# 1. readlink is a Bash function, so it wins over the reset PATH. L accepts the
# lexical roles/alias.md; the fd is actually opened through an outside symlink;
# forged K reports an allowed path and g4 reads the outside policy inode.
ln -s ../policies/outside-role.md "$R/roles/alias.md"
printf 'ПРОВОДКА:\n- role=roles/alias.md «Outside role norm.»\n' > "$R/contracts/001.md"
readlink() { printf '%s\n' "$FORGED_ROOT/roles/alias.md"; }
export -f readlink
FORGED_ROOT="$R" bash "$SUBJECT" "$R" contracts/001.md >"$WORK/readlink.out" 2>&1; rc=$?
[ "$rc" -eq 0 ] || { printf 'FAIL exported-readlink-role-canonicality: rc=%s, expected 0\n' "$rc" >&2; cat "$WORK/readlink.out" >&2; exit 1; }
printf 'exported-readlink-role-canonicality: rc=%s\n' "$rc"
unset -f readlink
/usr/bin/readlink "$R/roles/alias.md" | /usr/bin/grep -Fxq '../policies/outside-role.md' || { printf 'FAIL alias does not point outside\n' >&2; exit 1; }
! /usr/bin/grep -Fxq 'Outside role norm.' "$R/roles/honest.md" || { printf 'FAIL outside norm exists in honest role\n' >&2; exit 1; }

# 2. A successful grep function says an absent role norm exists.
printf 'ПРОВОДКА:\n- role=roles/honest.md «Absent role norm.»\n' > "$R/contracts/001.md"
grep() { return 0; }
export -f grep
bash "$SUBJECT" "$R" contracts/001.md >"$WORK/grep.out" 2>&1; rc=$?
[ "$rc" -eq 0 ] || { printf 'FAIL exported-grep-role-norm: rc=%s, expected 0\n' "$rc" >&2; cat "$WORK/grep.out" >&2; exit 1; }
printf 'exported-grep-role-norm: rc=%s\n' "$rc"
unset -f grep
! /usr/bin/grep -Fxq 'Absent role norm.' "$R/roles/honest.md" || { printf 'FAIL absent norm exists\n' >&2; exit 1; }

# 3. A successful awk function fabricates a charter body with an absent norm.
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Invented charter norm.»\n' > "$R/contracts/001.md"
awk() { printf '%s\n' 'Invented charter norm.'; }
export -f awk
bash "$SUBJECT" "$R" contracts/001.md >"$WORK/awk.out" 2>&1; rc=$?
[ "$rc" -eq 0 ] || { printf 'FAIL exported-awk-charter-section: rc=%s, expected 0\n' "$rc" >&2; cat "$WORK/awk.out" >&2; exit 1; }
printf 'exported-awk-charter-section: rc=%s\n' "$rc"
unset -f awk
! /usr/bin/grep -Fxq 'Invented charter norm.' "$R/AGENTS.md" || { printf 'FAIL invented charter norm exists\n' >&2; exit 1; }

# 4. A hostile exit function converts an ordinary grammar rejection into rc 0.
printf 'ПРОВОДКА:\n- role=roles/honest.md junk «Honest role norm.»\n' > "$R/contracts/001.md"
exit() { return 0; }
export -f exit
bash "$SUBJECT" "$R" contracts/001.md >"$WORK/exit.out" 2>&1; rc=$?
[ "$rc" -eq 0 ] || { printf 'FAIL exported-exit-masks-rejection: rc=%s, expected 0\n' "$rc" >&2; cat "$WORK/exit.out" >&2; exit 1; }
printf 'exported-exit-masks-rejection: rc=%s\n' "$rc"
unset -f exit

printf 'REPRODUCED: imported Bash functions bypass PATH-pinned role/charter validation and can mask rejection rc.\n'
