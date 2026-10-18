FAIL

# 995 adversary micro-round — A1/B1″ and frozen H

OBJECT: `d2304e21c5e0a15b70567b1343f81f4899d98b65`.
Frozen H: `03d0b80c98f54b9f305f52fa6f599264a44427d6`.

## Blocker — the promised per-handler neutralisation control is false for `handleReturn`

The micro-round acceptance specifically requires `stale_table` to go red on mutants that remove the reset from handler X. I made four disposable mutants from the supplied product snapshot, each removing exactly one `resetChallenge();` call and changing nothing else in `mobile/src/bootstrap/pilot-app.tsx`:

| mutant | removed call | `stale_table_probe.py` result |
|---|---|---|
| `mut-demo-entry` | `handleDemoEntry` | rc1; `BEGIN_REBEGIN` red |
| `mut-change-email` | `handleChangeEmail` | rc1; `VERIFY_CHANGE_EMAIL_EARLY` red |
| `mut-no-access` | `handleNoAccess` | rc1; `VERIFY_NO_ACCESS` and `GETSESSION_NO_ACCESS` red |
| `mut-return` | `handleReturn` | **rc0; all 36/36 cells green** |

Thus a required cancellation handler can lose its mandated common reset invocation while every frozen stale-table assertion remains green. This is a false-green neutralisation control, so the H acceptance condition is not met.

The reason is visible in the frozen test itself: the only purported return guard, `RETURN_GUARD_EARLY`, first traverses `handleNoAccess`; its generation bump masks a singleton removal from `handleReturn`. The frozen comment admits that this cell only turns red when both the no-access and return guards are removed. I also built `mut-no-access-return`; it gave rc1 and `RETURN_GUARD_EARLY` red, confirming that the existing cell detects the pair rather than the required singleton `handleReturn` mutation.

## A1 control is closed on the supplied OBJECT

The complete frozen stale table on honest `C=/tmp/dev-harness-verify/adv995r4/C` was green: all 36 assertions, including `VERIFY_NO_ACCESS` and `GETSESSION_NO_ACCESS`, rc0. Conversely, the exact no-access-reset mutant above was rc1: deferred verify and deferred getSession each opened `F02.01` over recovery, making their respective table cells red. This is the round-3 A1 failure mode and demonstrates that `d2304e21` fixes it.

## Frozen-H evidence

H was cloned and checked out exactly at the requested pin. `git diff --exit-code 03d0b80c98f54b9f305f52fa6f599264a44427d6 -- fixtures/workshop_project/pilot_995` was clean.

On honest C, the following 12 frozen scoped probes all returned rc0:

1. `probe.py --check-frozen` (14 pilot assertions)
2. `runtime_probe.py` (6 runtime assertions)
3. `bundle_probe.py` (http/mock source-map controls)
4. `schema_probe.py`
5. `frozen_matrix.py` (including drift red control)
6. `transport_probe.py`
7. `admission_probe.py`
8. `stale_probe.py`
9. `types_probe.py`
10. `pins_probe.py`
11. `admission_family_probe.py` (static plus 860 negative inputs and live true-code control)
12. `stale_table_probe.py` (36/36)

The frozen admission-family checker correctly rejected the supplied prior admission mutants: `mut-backdoor` rc1 (`ADMISSION_EXTRA_COMPARISON:2`) and `mut-unicode` rc1 (the same static fault plus dynamic admitted INSERT case). Its honest positive control was green.

## Auxiliary reproducible infrastructure defect (not the blocker above)

`stale_table_probe.py --case VERIFY_NO_ACCESS` returns rc2 instead of executing its named cell: `ASSERTION_SET_MISMATCH`, with all 36 tests skipped. The probe supplies a pattern beginning `^995 table ...$`, but Jest includes the enclosing `describe('995 stale table', ...)` in the full test name. The full-table command works and is the basis for the blocker; this selector failure is not being counted as a separate false-green.

No additional transition/field bypass that remained green under the full frozen table was found in the permitted A1/B1″ class.
