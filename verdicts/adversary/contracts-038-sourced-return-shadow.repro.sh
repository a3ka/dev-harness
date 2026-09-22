#!/usr/bin/env bash
# Live reproduction for Adversary 038 round 10 (post round-10 sourced-execution
# hardening). The guard's sourced-execution probe is
#   ( return 0 2>/dev/null ) || <environ-mismatch>
# and relies on the real `return` builtin reporting "yes, sourced" (rc 0)
# inside the probe subshell. A LOCAL, UNEXPORTED shell function named `return`
# defined in the calling (sourcing) shell shadows the builtin used by the
# probe. environ stays byte-for-byte canonical (`PATH=/usr/bin:/bin`,
# `LC_ALL=C.UTF-8` — nothing else), because a local function is invisible to
# /proc/$$/environ. The probe therefore evaluates false on BOTH disjuncts, no
# re-exec fires, and the sourced context — with its other local hostile
# functions (here: `grep`) — survives untouched, turning a genuinely absent
# role norm green.
#
# Eight independently-constructed `return` shadows are exercised:
#   - five that never crash (false / command return / builtin return /
#     nested-subshell command return / nested-subshell builtin return);
#   - three that segfault the probe subshell (bare recursive `return 1`, and
#     the same recursion under a SIGSEGV trap that either exits or continues).
# ALL EIGHT reproduce rc=0 on the same red input. The three crashing forms
# print a "Segmentation fault (core dumped)" line to stderr from the killed
# *inner* probe subshell, but that crash does not propagate: it is merely the
# left operand of `||` inside a conditional test, so the outer
# check_provodka.sh process is unaffected and reaches its own `exit 0`. A
# prior round explicitly filed the bare-recursive form as a "residual, not a
# FAIL" on the theory that it "just segfaults" (rc 139) — that theory was
# checked only at the inner-subshell granularity; measured at the only
# granularity that matters (the outer check_provodka.sh exit status seen by
# its caller), it is a full, deterministic, silent rc=0 bypass identical to
# the five non-crashing forms.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-return-shadow.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles"
printf 'Honest role norm.\n' > "$R/roles/honest.md"
printf 'ПРОВОДКА:\n- role=roles/honest.md «Absent role norm.»\n' > "$R/contracts/red.md"

# Positive control: the real minimal honest input is green, direct execution.
printf 'ПРОВОДКА:\n- role=roles/honest.md «Honest role norm.»\n' > "$R/contracts/green.md"
out="$(/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash "$SUBJECT" "$R" contracts/green.md 2>&1)"; rc=$?
printf 'honest-direct-green-control: rc=%s\n' "$rc"
[ "$rc" -eq 0 ] || { printf 'CONTROL FAILED: honest green input rejected\n%s\n' "$out" >&2; exit 2; }

# Control: the same red input, executed directly (not sourced), is rejected.
/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash "$SUBJECT" "$R" contracts/red.md >/dev/null 2>&1
rc=$?
printf 'direct-red-control: rc=%s\n' "$rc"
[ "$rc" -eq 1 ] || { printf 'CONTROL FAILED: direct exec did not reject red input (rc=%s)\n' "$rc" >&2; exit 2; }

# Control: sourced with a hostile local `grep` but an HONEST `return` (real
# builtin unshadowed) is correctly rejected — the round-10 probe alone closes
# this vector (confirms the fix is not vacuous).
out="$(/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash -c \
  '( grep() { return 0; }; source "$1" "$2" contracts/red.md )' \
  bash "$SUBJECT" "$R" 2>&1)"; rc=$?
printf 'sourced-forged-grep-honest-return-control: rc=%s\n' "$rc"
[ "$rc" -eq 1 ] || { printf 'CONTROL FAILED: unshadowed-return sourced attack should already be rejected (rc=%s)\n%s\n' "$rc" "$out" >&2; exit 2; }

all_bypassed=1
for mode in false command builtin nested-command nested-builtin recursive trap-segv-exit trap-segv-continue; do
  out="$(/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash -c '
    case "$3" in
      false)               return() { false; } ;;
      command)             return() { command return 1; } ;;
      builtin)             return() { builtin return 1; } ;;
      nested-command)      return() { ( command return 1; ); } ;;
      nested-builtin)      return() { ( builtin return 1; ); } ;;
      recursive)           return() { return 1; } ;;
      trap-segv-exit)      trap "exit 0" SEGV; return() { return 1; } ;;
      trap-segv-continue)  trap ":" SEGV; return() { return 1; } ;;
    esac
    ( grep() { :; }; source "$1" "$2" contracts/red.md )
  ' bash "$SUBJECT" "$R" "$mode" 2>&1)"
  rc=$?
  printf 'return-shadow[%s]+local-grep-shadow on RED input: rc=%s\n' "$mode" "$rc"
  [ "$rc" -eq 0 ] || all_bypassed=0
done

if [ "$all_bypassed" -eq 1 ]; then
  printf 'REPRODUCED: eight independent local `return` shadows (five clean, three SIGSEGV-based) all defeat the round-10 sourced-execution probe with a byte-canonical environ, letting a local hostile `grep` turn a genuinely absent role norm green.\n'
  exit 0
else
  printf 'NOT REPRODUCED: at least one return-shadow mode was correctly rejected.\n'
  exit 1
fi
