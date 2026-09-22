#!/usr/bin/env bash
# Live reproduction for Adversary 038 final round. Atomic fd protects later
# reads, but checker decisions still trust readlink, grep and awk from PATH.
# It also opens a role FIFO before checking its type, so a nonregular input can
# block it instead of returning its documented rc=1.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-forged-tools.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles" "$R/policies" "$WORK/bin-readlink" "$WORK/bin-grep" "$WORK/bin-awk"
printf 'Honest role norm.\n' > "$R/roles/honest.md"
printf 'Outside role norm.\n' > "$R/policies/outside-role.md"
printf '# Honest charter\n\n## Pinned section\nHonest charter norm.\n' > "$R/AGENTS.md"
printf '# Outside charter\n\n## Pinned section\nOutside charter norm.\n' > "$R/policies/outside-charter.md"

run() {
  local label="$1" expected="$2" out rc
  shift 2
  out="$(env "$@" bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; rc=$?
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: rc=%s, expected %s\n%s\n' "$label" "$rc" "$expected" "$out" >&2
    exit 1
  fi
  printf '%s: rc=%s\n' "$label" "$rc"
}

# Positive controls: the real minimal role, charter and a same-inode hardlink
# are green. A hardlink is legitimate because it is the same regular inode.
printf 'ПРОВОДКА:\n- role=roles/honest.md «Honest role norm.»\n' > "$R/contracts/001.md"
run honest-role 0
ln "$R/roles/honest.md" "$R/roles/hardlink.md"
printf 'ПРОВОДКА:\n- role=roles/hardlink.md «Honest role norm.»\n' > "$R/contracts/001.md"
run honest-role-hardlink 0
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Honest charter norm.»\n' > "$R/contracts/001.md"
run honest-charter 0

# A missing tool was tested in prior rounds. This shim instead succeeds and
# returns plausible canonical names for already-open fds that actually point
# outside the permitted targets.
cat > "$WORK/bin-readlink/readlink" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
case "$*" in
  *'/proc/self/fd/9'*)  printf '%s\n' "$FORGED_ROOT/roles/alias.md" ;;
  *'/proc/self/fd/11'*) printf '%s\n' "$FORGED_ROOT/AGENTS.md" ;;
  *) exec /usr/bin/readlink "$@" ;;
esac
SH
chmod +x "$WORK/bin-readlink/readlink"

# L accepts roles/alias.md, exec binds fd 9 to the outside inode, forged K
# declares that fd allowed, and g4 correctly reads the wrong fd's outside norm.
ln -s ../policies/outside-role.md "$R/roles/alias.md"
printf 'ПРОВОДКА:\n- role=roles/alias.md «Outside role norm.»\n' > "$R/contracts/001.md"
run forged-role-canonicality-accepted 0 "PATH=$WORK/bin-readlink:/usr/bin:/bin" "FORGED_ROOT=$R"
[ "$(/usr/bin/readlink "$R/roles/alias.md")" = '../policies/outside-role.md' ] || {
  printf 'FAIL role target is not outside\n' >&2; exit 1;
}
! /usr/bin/grep -Fxq 'Outside role norm.' "$R/roles/honest.md" || {
  printf 'FAIL outside role norm leaked into legitimate role\n' >&2; exit 1;
}

# The same fake K defeats charter's byte-for-byte target pinning.
rm -f -- "$R/AGENTS.md"
ln -s policies/outside-charter.md "$R/AGENTS.md"
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Outside charter norm.»\n' > "$R/contracts/001.md"
run forged-charter-canonicality-accepted 0 "PATH=$WORK/bin-readlink:/usr/bin:/bin" "FORGED_ROOT=$R"
[ "$(/usr/bin/readlink "$R/AGENTS.md")" = 'policies/outside-charter.md' ] || {
  printf 'FAIL charter target is not outside\n' >&2; exit 1;
}

# Recreate honest objects. A success-only grep makes absent role and charter
# norms green, although the atomic fd points at honest permitted regular files.
rm -f -- "$R/AGENTS.md"
printf '# Honest charter\n\n## Pinned section\nHonest charter norm.\n' > "$R/AGENTS.md"
cat > "$WORK/bin-grep/grep" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$WORK/bin-grep/grep"
printf 'ПРОВОДКА:\n- role=roles/honest.md «Norm absent from role.»\n' > "$R/contracts/001.md"
run forged-role-norm-accepted 0 "PATH=$WORK/bin-grep:/usr/bin:/bin"
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Norm absent from charter.»\n' > "$R/contracts/001.md"
run forged-charter-norm-accepted 0 "PATH=$WORK/bin-grep:/usr/bin:/bin"

# A successful awk can manufacture the section body before the real grep sees
# it, making an absent charter norm green without changing AGENTS.md at all.
cat > "$WORK/bin-awk/awk" <<'SH'
#!/usr/bin/env bash
printf '%s\n' 'Norm invented by awk.'
SH
chmod +x "$WORK/bin-awk/awk"
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Norm invented by awk.»\n' > "$R/contracts/001.md"
run forged-charter-section-accepted 0 "PATH=$WORK/bin-awk:/usr/bin:/bin"

# A FIFO reaches exec 9< before the intended -f fail-closed check. With no
# writer, timeout observes a hang rather than the checker API's rc 1/2.
mkfifo "$R/roles/pipe.md"
printf 'ПРОВОДКА:\n- role=roles/pipe.md «Anything.»\n' > "$R/contracts/001.md"
FIFO_OUT="$(timeout 2 bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; FIFO_RC=$?
[ "$FIFO_RC" -eq 124 ] || {
  printf 'FAIL fifo-open-blocks: rc=%s, expected 124\n%s\n' "$FIFO_RC" "$FIFO_OUT" >&2; exit 1;
}
printf 'fifo-open-blocks-instead-of-rc1: rc=%s\n' "$FIFO_RC"
printf 'REPRODUCED: successful PATH tool stubs bypass canonicality/norm checks; FIFO blocks before type rejection.\n'
