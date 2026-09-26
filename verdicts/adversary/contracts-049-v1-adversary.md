FAIL

# Adversary verdict — contract 049

Checked landed implementation `3e0207e` (`scripts/check_staged.sh`, `scripts/check_zones.sh`) against the frozen 049 contract. This verdict is a live-execution result, not a code-only review.

## Blocker A — `check_zones.sh` accepts a non-maximal frozen version when a valid version exceeds shell integer range

Contract 049 accepts versions by grammar `[0-9]+` and requires the **maximal** version. `check_zones.sh` calculates its historical `vmax` with:

```bash
if [ "$v" -gt "$vmax" ] 2>/dev/null; then vmax="$v"; fi
```

A syntactically valid decimal such as `999999999999999999999999999999999999` makes `[` fail its bounded integer parse. The failure is suppressed, so the loop retains a previously encountered `v1` as `vmax`.

**Live run:** I built a disposable main-history toy with annotated `id/CONTRACT/040`, annotated and ancestor-visible `frozen/contracts/040/1`, and annotated and ancestor-visible `frozen/contracts/040/999999999999999999999999999999999999`. The final `orchestrator` commit replaces the mint row with the tag-object SHA of **v1**, not the maximal frozen tag. The historical gate returned:

```text
overflow-version-zones=0
```

The same run supplied its positive control (`mint → frozen/040/1` when it is the sole frozen tag):

```text
positive-main-check_zones=0
```

Therefore this is an acceptance bypass, not an always-red gate or a malformed fixture. The bounded comparison must be replaced with a comparison valid for the declared unbounded decimal grammar, or the grammar must be bounded by an explicit contract change. As written, a lower frozen version is accepted while a greater valid frozen version exists.

## Blocker B — historical mint recognition passes on foreign and detached heads

The staged gate applies `current_branch == main` to replacement form, but `check_zones.sh` has no equivalent condition. This is not one of the named residuals in 049 (the declared residual concerns two tags pointing to the same peeled commit, not branch reachability).

**Live run:** Each disposable toy had an annotated mint tag, an annotated frozen `040/1` whose commit precedes the replacement, and a valid `orchestrator` mint→frozen replacement. The replacement was committed respectively on a foreign branch and on detached HEAD. The historical gate accepted both:

```text
foreign-branch-zones=0
detached-zones=0
```

Thus a commit which the staged door rejects for not being on main is recognized by the zone judge when that same non-main/detached checkout is supplied. This is exactly the task’s requested non-main probe and is a live door bypass unless the historical judge is constrained to main before it is trusted.

## Controls and rejected attacks

The following probes were executed successfully; they are not findings:

- Honest minimal main-history replacement: `check_zones=0` (positive control above).
- Two NNN replacements in one delta: staged `rc=1`, zones `rc=1`.
- Replacement for an NNN with no frozen tags: staged `rc=1`, zones `rc=1`.
- Lightweight `frozen/contracts/040/1`: staged `rc=1`, zones `rc=1`.

  The three staged results were run from the toy repository cwd (the identity source used by `check_staged.sh`):

  ```text
  positive-staged=0
  multiple-staged=1
  no-frozen-staged=1
  lightweight-staged=1
  ```

- A zoned non-`orchestrator` identity (`implementer`) making the otherwise valid replacement: `check_zones=1`.
- An undeclared `attacker` identity returned `check_zones=0`; that is the pre-existing, explicitly named global residual `user.name` / undeclared authors not judged, so it is not re-opened as a 049 finding.
- Missing PATH tools did not produce a false green in `check_staged.sh`: `env PATH=/nonexistent /usr/bin/bash scripts/check_staged.sh .` returned `rc=2`, `NOT_IMPLEMENTED: нет git`.
- `bash scripts/verify_antiplacebo.sh --scope check_staged/case_dver_minta_zamena_na_frozen check_staged/case_dver_minta_zamena_tag_tolko_lokalno` returned `rc=0`; both existing fixture controls remained discriminating.

The full fixture suite was also executed before targeted probes: all 72 fixtures were presented red on repeat (`rc=0`). Existing fixtures do not cover either blocker above.
