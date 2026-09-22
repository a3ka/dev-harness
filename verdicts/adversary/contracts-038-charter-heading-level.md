FAIL — contract 038: same-level charter heading with extra separator whitespace leaks its body

Subject: `scripts/check_provodka.sh` at `71f13cc41547ceb5948245797975c52f4b31bab4`.

## Finding

`charter_section_body()` recognizes a heading with `^#+[[:space:]]+`, but computes
its level as `RLENGTH - 1`. `RLENGTH` includes every separator whitespace byte,
not only the leading `#` bytes. Therefore `##  Next` is recognized as a heading
but assigned level 3 instead of level 2.

Contract 038 §Инварианты 1 defines a charter body as ending at the next heading
of the same or higher level; `##  Next` has the same two-`#` level as `## Target`.
The checker should not search `Next` for Target's norm. It instead retains that
body and returns `rc=0` when `Foreign norm.` appears there.

The reproduction includes both controls: `Target norm.` in Target returns green,
and a normal same-level `## Next` boundary correctly rejects `Foreign norm.`
with `rc=1`. Changing only the separator after the two hashes from one space to
two spaces makes that objectively out-of-section norm green.

This is a direct content/grammar input under honest direct execution. It does
not use any excluded environment, PATH/tool substitution, source execution,
or pre-existing interpreter state.

## Evidence

Run from the repository root:

```bash
bash verdicts/adversary/contracts-038-charter-heading-level.repro.sh
```

Expected output and reproduction-script status on the named subject:

```text
honest-target-norm: rc=0
single-space-same-level-boundary-red: rc=1
extra-space-same-level-boundary-red: rc=0
REPRODUCED: `##  Next` is a same-level heading but its norm leaks into §Target because level calculation counts separator whitespace.
```
