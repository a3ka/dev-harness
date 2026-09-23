# Adversary verdict — contract 042 on `frozen/contracts/042/1`

**VERDICT: ACCEPT.** I found no new live bypass of the oracle implementation or
weakening of the protected-artifact gate. This is a runtime judgment of the
frozen subject (tag `frozen/contracts/042/1` → `10d1966a21bd452fd7b28b2b8327d4b3b82230c9`),
not a reopening of the three critic rounds or the arbitration decision.

Н-39 ДОСЛОВНО: стабы к ветвям привязывает architect по коду, НЕ проза контракта.

I read the entire contract, consolidated critic accept verdict, the complete
arbitration decision (including tables З1–З4, rows 29–34), and Н-127 in
`NABLIUDENIA.md`, then built new repositories from scratch under
`/tmp/dev-harness-verify/`; none copies an architect, critic, or arbiter
fixture.  Every assertion below invokes the unchanged production guard from
this worktree against the toy repository.

## Independent replay of the arbitration tables

| Table | Independently built topology and observed oracle | Guard |
|---|---|---:|
| З1 | Same OID, 100644→100755 side change; modify/delete conflict. `merge-tree` rc=1, conflicting records=2, result still has `100755 <oid>`. | rc=1 |
| З2 | `commit-tree` criss-cross with two merge bases; `merge-tree` rc=0, no conflict for `p`, result has `100644 <oid>`. | rc=1 |
| З3 | Space-containing protected path: an independent legitimate lagging-parent merge gives `merge-tree` rc=0, no conflict, no result state and guard rc=0; after restore plus manual repeat delete without ALLOW, guard rc=1. | 0 then 1 |
| З4 | The same independently constructed legitimate lagging-parent topology has clean oracle output and no result state. | rc=0 |

Thus both polarities of the parsing table are discriminated by executable
history, rather than by its prose description.

## New oracle attack matrix

All cases below are fresh toy histories and use a missing protected artifact
with an old D1 ALLOW where that makes accidental reuse observable.

| Attack | Result |
|---|---|
| Octopus commit (three parents), tree absent, merge body without ALLOW | guard rc=1: the merge is not classified as an artifact; fail-closed is real, not an accidental rc=0. |
| D/F (file `v` versus directory `v/child`), resolved with removal and no ALLOW | guard rc=1. |
| Rename after restore: D1 has ALLOW, `p` is restored, other parent renames and edits it, conflict is manually resolved by deleting `p` without ALLOW | `merge-tree` rc=1, two conflicts, result retains a state; guard rc=1. No stale D1 excuse. |
| Gitlink path (mode 160000) updated on the side, modify/delete resolved by removal without ALLOW | `merge-tree` rc=1, two conflicts, result state is `160000 <commit>`; guard rc=1. |
| Path containing both TAB and LF, modify/delete resolved by removal without ALLOW | `merge-tree` rc=1; the NUL-decoded conflict records contain the exact byte path; guard rc=1. The first-TAB split does not truncate the path. |
| Missing `merge-tree --write-tree` | In an isolated no-hardlink clone I replaced only the startup probe command name with an unavailable name. The unchanged startup control flow returned rc=2 and emitted `NOT_IMPLEMENTED: git merge-tree --write-tree недоступен …`. |

The rename test is specifically the potentially dangerous restore-plus-new
removal shape: a pre-existing permission must not be reused. Git reports the
rename/delete conflict, so condition 2 retains the merge as the first actual
candidate; the barrier refuses it.

## Non-weakening

Executed live:

```text
bash scripts/verify_antiplacebo.sh --scope check_protected
```

The scoped family reports **25 fixtures, 25 red repeat runs**. Every protected
`case_*.sh`, including the 22 pre-042 cases and the three round-3 cases,
retained its green control and named red rerun. The process exit is **1 only
because of three pre-existing out-of-scope area-scan findings**:
`check_threat_model.sh`, `fixtures/check_threat_model`, and
`fixtures/parsing_hygiene_battery`. The selected `check_protected` family has
no discrepancy; this is not presented as a full green suite.

No test subject or existing test was changed. Temporary toy repositories and
drivers remain outside the repository under `/tmp/dev-harness-verify/`.
