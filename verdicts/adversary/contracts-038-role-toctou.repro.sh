#!/usr/bin/env bash
# Live reproduction for Adversary 038 round 4: role target changes after K.
# The PATH shim is a deterministic scheduler, not a forged readlink answer: it
# first prints /usr/bin/readlink's actual answer, then swaps the symlink before
# check_provodka reaches grep.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-toctou.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
R="$WORK/tree"
mkdir -p "$R/contracts" "$R/roles" "$R/policies" "$WORK/bin"
printf 'Honest role norm.\n' > "$R/roles/good.md"
printf 'Policy-only norm.\n' > "$R/policies/evil.md"
ln -s good.md "$R/roles/alias.md"

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

# Positive control: an unchanged flat alias to a role file passes.
printf 'ПРОВОДКА:\n- role=roles/alias.md «Honest role norm.»\n' > "$R/contracts/001.md"
run honest-flat-alias 0

cat > "$WORK/bin/readlink" <<'SH'
#!/usr/bin/env bash
set -uo pipefail
resolved="$(/usr/bin/readlink "$@")" || exit $?
printf '%s\n' "$resolved"
printf '%s\n' "$resolved" > "$RACE_ROOT/readlink-observed"
rm -f -- "$RACE_ROOT/roles/alias.md"
ln -s ../policies/evil.md "$RACE_ROOT/roles/alias.md"
SH
chmod +x "$WORK/bin/readlink"

# At -f and at K, alias.md resolves to roles/good.md. Immediately after K it is
# atomically replaced by a symlink to policies/evil.md. grep therefore validates
# a policy file even though $resolved was a legitimate flat roles target.
printf 'ПРОВОДКА:\n- role=roles/alias.md «Policy-only norm.»\n' > "$R/contracts/001.md"
run swap-after-canonicalization 0 "PATH=$WORK/bin:/usr/bin:/bin" "RACE_ROOT=$R"

[ "$(cat "$R/readlink-observed")" = "$R/roles/good.md" ] \
  || { printf 'FAIL readlink did not observe the honest role target\n' >&2; exit 1; }
[ "$(readlink "$R/roles/alias.md")" = '../policies/evil.md' ] \
  || { printf 'FAIL alias was not swapped to the policy target\n' >&2; exit 1; }
if grep -Fxq 'Policy-only norm.' "$R/roles/good.md"; then
  printf 'FAIL policy norm unexpectedly exists in the honest role file\n' >&2
  exit 1
fi
printf 'REPRODUCED: K approved roles/good.md, then grep accepted policies/evil.md.\n'
