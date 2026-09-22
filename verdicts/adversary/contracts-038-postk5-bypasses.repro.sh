#!/usr/bin/env bash
# Live adversary reproduction for contract 038 post-K5. Subject remains untouched.
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-postk5.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles" "$R/policies" "$WORK/bin" "$WORK/no-tools"
printf '# Charter\n\n## Pinned section\nHonest charter norm.\n' > "$R/AGENTS.md"
printf 'Honest role norm.\n' > "$R/roles/honest.md"
printf 'Policy-only role norm.\n' > "$R/policies/role-policy.md"
printf '# Not a charter\n\n## Pinned section\nExternal charter norm.\n' > "$R/policies/not-charter.md"
printf '# Outside charter\n\n## Pinned section\nSwapped charter norm.\n' > "$R/policies/charter-policy.md"
run() {
  local label="$1" expected="$2" out rc
  shift 2
  out="$(env "$@" bash "$SUBJECT" "$R" contracts/001.md 2>&1)"; rc=$?
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: rc=%s, expected %s\n%s\n' "$label" "$rc" "$expected" "$out" >&2; exit 1
  fi
  printf '%s: rc=%s\n' "$label" "$rc"
}
role() { printf 'ПРОВОДКА:\n- role=%s «%s»\n' "$1" "$2" > "$R/contracts/001.md"; }
charter() { printf 'ПРОВОДКА:\n- charter=%s §%s «%s»\n' "$1" "$2" "$3" > "$R/contracts/001.md"; }

# Positive control plus independently varied B2 probes in both extract_quoted arms.
charter AGENTS.md 'Pinned section' 'Honest charter norm.'
run honest-charter 0
role roles/honest.md 'Honest role norm.» trailing-junk'
run role-trailing-garbage-rejected 1
role roles/honest.md 'Outer «inner» tail'
run role-nested-quotes-rejected 1
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Honest charter norm.» trailing-junk\n' > "$R/contracts/001.md"
run charter-trailing-garbage-rejected 1
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section «Outer «inner» tail»\n' > "$R/contracts/001.md"
run charter-nested-quotes-rejected 1

# Fresh role B1: K approves regular roles/honest.md. Its pathname is then replaced
# before grep, so grep "$resolved" follows an external symlink and accepts policy text.
role roles/honest.md 'Policy-only role norm.'
cat > "$WORK/bin/readlink" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
resolved="$(/usr/bin/readlink "$@")" || exit $?
printf '%s\n' "$resolved"
rm -f -- "$RACE_ROOT/roles/honest.md"
ln -s ../policies/role-policy.md "$RACE_ROOT/roles/honest.md"
SH
chmod +x "$WORK/bin/readlink"
run role-canonical-target-replaced-accepted 0 "PATH=$WORK/bin:/usr/bin:/bin" "RACE_ROOT=$R"
[ "$(readlink "$R/roles/honest.md")" = '../policies/role-policy.md' ] || { printf 'FAIL role target was not replaced\n' >&2; exit 1; }

# Charter accepts any file despite the literal charter=AGENTS.md grammar.
charter policies/not-charter.md 'Pinned section' 'External charter norm.'
run charter-arbitrary-target-accepted 0

# It also accepts the nominal AGENTS.md when it is a direct symlink outside root.
rm -f -- "$R/AGENTS.md"; ln -s policies/charter-policy.md "$R/AGENTS.md"
charter AGENTS.md 'Pinned section' 'Swapped charter norm.'
run charter-external-symlink-accepted 0

# Charter TOCTOU: after [ -f], before the real awk read, swap AGENTS.md outside.
rm -f -- "$R/AGENTS.md"
printf '# Charter\n\n## Pinned section\nHonest charter norm.\n' > "$R/AGENTS.md"
charter AGENTS.md 'Pinned section' 'Swapped charter norm.'
cat > "$WORK/bin/awk" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
rm -f -- "$RACE_ROOT/AGENTS.md"
ln -s policies/charter-policy.md "$RACE_ROOT/AGENTS.md"
exec /usr/bin/awk "$@"
SH
chmod +x "$WORK/bin/awk"
run charter-post-existence-swap-accepted 0 "PATH=$WORK/bin:/usr/bin:/bin" "RACE_ROOT=$R"
[ "$(readlink "$R/AGENTS.md")" = 'policies/charter-policy.md' ] || { printf 'FAIL charter target was not replaced\n' >&2; exit 1; }

# New wrapper accepts no delimiter between §<full heading> and opening «.
printf '# Charter\n\n## Pinned section\nDelimiterless charter norm.\n' > "$R/AGENTS.md"
printf 'ПРОВОДКА:\n- charter=AGENTS.md §Pinned section«Delimiterless charter norm.»\n' > "$R/contracts/001.md"
run charter-missing-header-norm-delimiter-accepted 0

# Explicit unavailable-tool controls must fail closed, never masquerade as green.
cat > "$WORK/no-tools/readlink" <<'SH'
#!/usr/bin/env bash
exit 127
SH
cat > "$WORK/no-tools/awk" <<'SH'
#!/usr/bin/env bash
exit 127
SH
chmod +x "$WORK/no-tools/readlink" "$WORK/no-tools/awk"
printf 'Honest role norm.\n' > "$R/roles/honest.md"
role roles/honest.md 'Honest role norm.'
run role-absent-readlink-fails-closed 1 "PATH=$WORK/no-tools:/usr/bin:/bin"
printf '# Charter\n\n## Pinned section\nHonest charter norm.\n' > "$R/AGENTS.md"
charter AGENTS.md 'Pinned section' 'Honest charter norm.'
run charter-absent-awk-fails-closed 1 "PATH=$WORK/no-tools:/usr/bin:/bin"
printf 'REPRODUCED: role K→g4 replacement and charter target/wrapper bypasses passed green.\n'
