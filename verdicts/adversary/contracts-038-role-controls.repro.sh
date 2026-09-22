#!/usr/bin/env bash
# Focused controls for Adversary 038 round 4. These are NOT bypasses.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-controls.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles" "$R/policies" "$WORK/fake"
printf 'Final role norm.\n' > "$R/roles/final.md"
printf 'Policy norm.\n' > "$R/policies/policy.md"
printf 'Hardlink norm.\n' > "$R/policies/hard.md"

check_case() {
  local label="$1" wanted="$2" needle="$3" out rc
  out="$(bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; rc=$?
  if [ "$rc" -ne "$wanted" ] || { [ -n "$needle" ] && [[ "$out" != *"$needle"* ]]; }; then
    printf 'FAIL %s: rc=%s, expected %s; output:\n%s\n' "$label" "$rc" "$wanted" "$out" >&2
    exit 1
  fi
  printf '%s: rc=%s\n' "$label" "$rc"
}
contract() { printf 'ПРОВОДКА:\n- role=%s «%s»\n' "$1" "$2" > "$R/contracts/001.md"; }

# A multi-hop link is valid only when its final target remains a flat role file.
ln -s final.md "$R/roles/b.md"
ln -s b.md "$R/roles/a.md"
contract roles/a.md 'Final role norm.'
check_case multihop-final-flat-role 0 ''

# Change only the final link target to an outside policy: K must reject it.
rm "$R/roles/b.md"
ln -s ../policies/policy.md "$R/roles/b.md"
contract roles/a.md 'Policy norm.'
check_case multihop-final-policy 1 'role-канал обязан ссылаться строго'

# A hardlink has a real, flat path under roles/; this is intentionally accepted
# by the arbitration formula (canonical path, not inode provenance).
ln "$R/policies/hard.md" "$R/roles/hard.md"
contract roles/hard.md 'Hardlink norm.'
check_case hardlink-flat-path 0 ''

# A directory named *.md is not a regular file and must fail g3.
mkdir "$R/roles/directory.md"
contract roles/directory.md 'Anything.'
check_case directory-named-role-file 1 'role-файл не существует'

# Literal tab and full-width slash are not ASCII `/` and have valid one-component
# filenames under the L+K grammar. Both must retain their actual target.
tab_name=$'tab\tname.md'
printf 'Tab norm.\n' > "$R/roles/$tab_name"
contract "roles/$tab_name" 'Tab norm.'
check_case tab-in-role-name 0 ''
fw_name='full／width.md'
printf 'Full-width norm.\n' > "$R/roles/$fw_name"
contract "roles/$fw_name" 'Full-width norm.'
check_case full-width-slash-in-name 0 ''

# An ASCII space is the grammar delimiter, so it is not a representable role-name
# byte in the unescaped field syntax and fails closed rather than being misparsed green.
printf 'Space norm.\n' > "$R/roles/has space.md"
contract 'roles/has space.md' 'Space norm.'
check_case ascii-space-in-role-name 1 'role-канал обязан ссылаться строго'

# Missing readlink is not mistaken for an empty successful canonicalization.
cat > "$WORK/fake/readlink" <<'SH'
#!/usr/bin/env bash
exit 127
SH
chmod +x "$WORK/fake/readlink"
contract roles/final.md 'Final role norm.'
out="$(env PATH="$WORK/fake:/usr/bin:/bin" bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || [[ "$out" != *'role-канал обязан ссылаться строго'* ]]; then
  printf 'FAIL absent-readlink: rc=%s; output:\n%s\n' "$rc" "$out" >&2
  exit 1
fi
printf 'absent-readlink-fails-closed: rc=1\n'

printf 'ALL NON-BYPASS CONTROLS PASSED.\n'
