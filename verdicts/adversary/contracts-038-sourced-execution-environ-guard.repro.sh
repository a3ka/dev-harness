#!/usr/bin/env bash
# Live reproduction for Adversary 038 post-guard: the guard assumes it owns the
# Bash process. Sourcing the subject violates that assumption while still
# executing its first line. Both attacks make a red contract green.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d /tmp/adversary038-source.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles"
printf 'Honest role norm\n' > "$R/roles/honest.md"
printf 'not a valid contract\n' > "$R/contracts/red.md"
printf 'ПРОВОДКА:\n- role=roles/honest.md «Absent role norm.»\n' > "$R/contracts/forged-norm.md"
printf '#!/usr/bin/env bash\nexit 0\n' > "$WORK/innocent-launcher.sh"
chmod +x "$WORK/innocent-launcher.sh"

# Controls: direct execution rejects the red input with both canonical and
# noncanonical inherited environments.
/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash "$SUBJECT" "$R" contracts/red.md >/dev/null 2>&1
rc=$?
printf 'direct-canonical-red-control: rc=%s\n' "$rc"
[ "$rc" -eq 1 ] || exit 1
/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 TRIGGER=1 /usr/bin/bash "$SUBJECT" "$R" contracts/red.md >/dev/null 2>&1
rc=$?
printf 'direct-hostile-red-control: rc=%s\n' "$rc"
[ "$rc" -eq 1 ] || exit 1

# TRIGGER forces re-exec. The guard was sourced, so $0 is caller-controlled and
# names the unrelated green launcher; $1/$2 provide the actual source arguments.
/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 TRIGGER=1 /usr/bin/bash -c \
  'source "$1" "$2" contracts/red.md' "$WORK/innocent-launcher.sh" "$SUBJECT" "$R"
rc=$?
printf 'source-reexec-red-input: rc=%s\n' "$rc"
[ "$rc" -eq 0 ] || exit 1

# In a Bash subshell, $$ remains the parent shell PID. Its /proc environ is
# canonical, while a function injected into the current subshell is invisible
# to that comparison. The sourced guard skips re-exec and calls fake grep.
/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash -c \
  '( grep() { return 0; }; source "$1" "$2" contracts/forged-norm.md )' \
  bash "$SUBJECT" "$R"
rc=$?
printf 'subshell-source-forged-grep: rc=%s\n' "$rc"
[ "$rc" -eq 0 ] || exit 1

printf 'REPRODUCED: sourced execution redirects re-exec through caller-controlled $0 and hides a forged function behind parent $$ environ.\n'
