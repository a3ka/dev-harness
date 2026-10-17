FAIL: `fail_closed_992.py --matrix` violates the required rc0/72-observation result: it returns rc1 with `cases=24 observations=72 failures=16`.

OBJECT=0339dee3d4ca1200e578f944ed72d1d84e20ff81

## Blocking counterexample: inverted live-B branch in matrix oracle

The criterion requires `python3 fixtures/freeze_contract/fail_closed_992.py --matrix` to return rc0 with `cases=24 observations=72 failures=0`: historical fail-open variants must be rejected and the live implementation must refuse every injected fault with its named reason.

Observed instead:

```text
$ python3 fixtures/freeze_contract/fail_closed_992.py --matrix
...
B-charter-diff current: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=0
...
B-ci-fail-write current: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=0
cases=24 observations=72 failures=16
rc=1
```

All sixteen B cells exhibit the same failure. Their live subject is correct for the injected fault (`fault_rc=1`, named refusal, `oracle=1`, `hit=1`), but the matrix declares it unacceptable. The branch in `fail_closed_992.py` sets `expected = not ok` for every live B cell; it therefore accepts the historical fail-open (`ok == false`) and rejects the live fail-closed implementation (`ok == true`). The model control passes, so this is a distinguishability/oracle defect rather than an always-red battery:

```text
$ python3 fixtures/freeze_contract/fail_closed_992.py --model
cases=24 observations=24 failures=0
rc=0
```

The ordinary live implementation run is also green (`cases=24 observations=24 failures=0`, rc0), which confirms that the matrix defect is not a substituted success banner or a production fail-open.

## Fault-injection probes

I temporarily restored each of the seven subjects to `3e071370^` in the disposable clone and ran its corresponding named B cells, restoring the live file after each probe. Every broken variant was detected by the cell (`accepted=0`, `failures=1`): charter (diff/tree), preflight (package/worktrees/tags), judge (policy/verdict seq), CI gate (both append branches), profile resolver (five jq branches), freeze versions, and done versions.

The probes exposed the expected historical behaviours: silent rc0 success for charter/preflight/profile/freeze/done, rc0 plus an append/success message for judge seq, and rc1 without the named journal cause for CI append. The latter preserves the documented pre-existing `check_ci_gate` rc polarity; the current cells return rc1 *with* `ОТКАЗ: журнал: check-строка не записана`.

## Other exercised evidence

* Path boundary: `git diff --name-status main...wip/992/implementer` contains exactly the seven declared `scripts/` files and nothing else.
* `python3 fixtures/freeze_contract/fail_closed_992.py`: rc0, `cases=24 observations=24 failures=0`.
* `python3 fixtures/freeze_contract/fail_closed_992.py --model`: rc0, `cases=24 observations=24 failures=0`.
* `bash fixtures/freeze_contract/red_doc_lifecycle.sh`: rc0; its 992 battery reports `cases=24 observations=24 failures=0`.
* Scoped anti-placebo probes: `freeze_contract` (15/15), `done_contract` (1/1), `check_charter` (13/13), `check_judge_gate` (3/3), and `profile_resolver` (10/10), all rc0.

The mandatory matrix acceptance criterion remains red; do not accept until its live-B expectation is corrected and the specified matrix command is green.
