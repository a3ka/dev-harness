FAIL

# Adversary — contract 071 implementation

Subject: `4360eb41b355049f15179289fe917376f0ad7739` (`scripts/gitw`
`3cb242f834fe82cbd02299ee99d16fc1a9019824`,
`scripts/gitw_preflight_071.sh` `14170aab6ce4e0e602c75590686fac1245b31dab`).
The frozen 071 red runner is
`d9205549159032ff1eabb82322481f921d8eb812`.

## Blocking finding B1 — a three-key bypass is green against the frozen battery

Contract 071 invariant 3 requires the named `чек-ключи не полностью` refusal
for every non-zero incomplete set: **1, 2, and 3 of 4** check keys. The only
honest completeness cell `п7` deletes exactly `check:nabludenia` and
`check:ci-parity`; it exercises only **2 of 4**.

I constructed an executable gate mutant in the copy made by the frozen runner:

```sh
# Original zero-key skip:
[ "$nk" -eq 0 ] && { ...; exit 0; }

# M3: wrongly regard exactly three keys as the zero-key skip:
[ "$nk" -eq 3 ] && { ...; exit 0; }
```

A full run of `bash fixtures/_krasnye_071.sh` against M3 was **rc 0**:

```text
стаб-пак: 13/13 поймано, диффпроба 13/13
честные клетки: 27/27 зелёные; стаб-пак 13/13 + дифф 13/13
```

M3 accepts a sent tree with three advertised check keys, contrary to the
contract, while the frozen battery remains green. There is also no 1-of-4
honest input: the 13 stubs do not add such a case. Thus the analogous M1
bypass (`[ "$nk" -eq 1 ]` as skip) is likewise unobservable by this runner.
This is a verification defect and blocks acceptance.

## Blocking finding B2 — the implementation counts keys in the wrong tree

The predicate that decides zero/partial/four keys reads `package.json` in the
caller cwd, before creating or entering the detached worktree:

```sh
if [ -f package.json ]; then
  for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
    if grep -qF "\"$k\"" package.json; then nk=$((nk+1)); fi
  done
done
```

The declared subject is instead the `send_tip` worktree `$tw`. Consequently,
a push `candidate:main` whose candidate has zero keys while the current
checkout has four does not take the mandated named zero-key skip; it creates
`$tw` and runs four absent npm scripts. A partial candidate is likewise
classified using the unrelated checkout. This is the prohibited "right answer
to the wrong tree" defect. Existing p8/p9 only vary a red role file; both
their cwd and sent source retain all four package keys, so neither observes
this branch.

## Positive controls and regressions exercised

* `bash fixtures/_krasnye_071.sh` on the honest subject — **rc 0**: positive
  self-check 4/4, stub pack 13/13 with differential controls 13/13, and
  honest cells 27/27.
* `bash fixtures/_krasnye_045.sh scripts/gitw` — **rc 0**:
  `gitw/red_gitw_obmen.sh rc=0`, one file and zero failures.
* `bash scripts/verify_antiplacebo.sh --scope check_staged` — **rc 0**:
  34 fixtures red-capable on their repeat runs.
* `bash scripts/verify_ci_parity.sh` — **rc 0**, zero discrepancies; the 071
  CI step and package key are wired consistently.
* `git diff --exit-code 33d1d5c 4360eb4 -- fixtures/gitw fixtures/_krasnye_045.sh`
  — **rc 0**; the frozen 045 battery is unchanged.
* `bash -n scripts/gitw scripts/gitw_preflight_071.sh` — **rc 0**.
* The only 071 API seam is `GITW_PREFLIGHT_071_API` (two implementation
  occurrences: declaration and use).

The honest positive control proves the runner is not permanently red. It does
not close B1 or B2: its single partial-key input and same-package cwd/source
pairs leave both bypasses observationally invisible.

## Required repair

Make the key-count predicate read `$tw/package.json` (or an equivalent view
of `send_tip`), then add independent 0-, 1-, 2-, and 3-of-4 sent-source
cells with a cwd whose package key set differs. The 0-key case must assert the
named skip; 1/2/3 must assert the named incomplete-key refusal and an
unchanged bare recipient. Re-run the adversary mutation set after that change.
