#!/usr/bin/env bash
# Adversarial reproduction: guard_is_wired interpolates the guard basename into
# grep -E. Each declared guard exists, but the workflow invokes another file.
# The declared spelling occurs only inside x<name>x, where it is not a word.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
SUBJECT="$REPO/scripts/check_provodka.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/adversary038-guard-meta.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
ROOT="$WORK/tree"
mkdir -p "$ROOT/contracts" "$ROOT/scripts" "$ROOT/.github/workflows"

run() {
  local label="$1" expected="$2" out rc
  out="$(/usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /usr/bin/bash "$SUBJECT" "$ROOT" contracts/001.md 2>&1)"; rc=$?
  printf '%s: rc=%s\n' "$label" "$rc"
  if [ "$rc" -ne "$expected" ]; then
    printf 'FAIL %s: expected rc=%s, got rc=%s\n%s\n' "$label" "$expected" "$rc" "$out" >&2
    exit 2
  fi
}

# Positive control: a literal guard name, invoked literally, is green.
printf '#!/usr/bin/env bash\n' > "$ROOT/scripts/plain.sh"
printf 'run: bash scripts/plain.sh\n' > "$ROOT/.github/workflows/w.yml"
printf 'ПРОВОДКА:\n- guard=scripts/plain.sh\nПРОВОДКА-ЭНФОРСМЕНТ: test\n' > "$ROOT/contracts/001.md"
run honest-literal-guard 0

for pair in 'a.b:axb' 'a*b:b' 'a[b:axb'; do
  name="${pair%%:*}"; wrong="${pair#*:}"
  printf '#!/usr/bin/env bash\n' > "$ROOT/scripts/$name.sh"
  printf 'ПРОВОДКА:\n- guard=scripts/%s.sh\nПРОВОДКА-ЭНФОРСМЕНТ: test\n' "$name" > "$ROOT/contracts/001.md"

  # The only command-shaped word is $wrong, never $name. x<name>x preserves
  # the literal only for the implementation's substring prefilter; it is not
  # a word occurrence of the declared guard.
  printf 'run: bash scripts/%s.sh x%sx\n' "$wrong" "$name" > "$ROOT/.github/workflows/w.yml"
  run "forged-wiring-$name" 0

  # Neutralization: remove the different candidate word without changing the
  # declared guard or its adjacent non-word literal.
  printf 'run: qqq x%sx\n' "$name" > "$ROOT/.github/workflows/w.yml"
  run "neutralized-$name" 1
done

printf 'REPRODUCED: ERE metacharacters ., *, [ in a guard basename let a different workflow word satisfy guard_is_wired, although the declared guard is never called.\n'
