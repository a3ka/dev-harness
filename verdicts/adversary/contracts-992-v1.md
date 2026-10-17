accept

# Adversary verdict v2 — contract 992

OBJECT=`6dd2ce3171ee3434649db0c7c1c3c4dad8127e6c` (`wip/992/implementer`). This v2 retracts v1's sole FAIL finding: I ran `--matrix` on the wrong base.

## Corrected base distinction

The contract has two different acceptance bases:

* On `wip/992/architect` (`64d2f778261ece66d7e313a13ea4b1a9ccda45b0`), which is after A and before B, `python3 fixtures/freeze_contract/fail_closed_992.py --matrix` returned rc0 with `cases=24 observations=72 failures=0`. Every B `current` row correctly describes the historical fail-open subject (`fault_rc=0`); every `model` row refused the injected fault (`fault_rc=1` with the named reason). The two CI append historical rows correctly retain rc1 without the named journal cause.
* On `wip/992/implementer` (after B), the applicable command is the unflagged battery, not `--matrix`. It returned rc0 with `cases=24 observations=24 failures=0`; all 24 fault pairs returned rc1 with their required named refusal. `--model` also returned rc0 with `cases=24 observations=24 failures=0`.

Thus the previous `--matrix` result on the implementation tree (`failures=16`) was expected from the matrix's historical-B `current` oracle, not a defect in the test or implementation. The prior verdict's blocking claim is withdrawn.

## Adversarial evidence

* Fault-injection neutralization: I restored each of the seven implementation subjects to `3e071370^` in a disposable clone and ran its matching B cells. Every broken variant was detected (`accepted=0`, `failures=1`): charter diff/tree; preflight package/worktrees/tags; judge policy/verdict seq; both CI append paths; five profile jq paths; freeze versions; and done versions. This includes the required positive/negative discrimination rather than an always-failing check.
* The unflagged implementation battery and `bash fixtures/freeze_contract/red_doc_lifecycle.sh` were each rerun on OBJECT and both returned rc0 with the battery result `cases=24 observations=24 failures=0`.
* Previously exercised on the same OBJECT: `bash fixtures/gitw_predpolet/red_predpolet_071.sh` returned rc0 (honest 41/41, stub-package 21/21, differential 21/21). Scoped `verify_antiplacebo.sh` returned rc0 for `freeze_contract` (15/15), `done_contract` (1/1), `check_charter` (13/13), `check_judge_gate` (3/3), and `profile_resolver` (10/10).
* Boundary check: `git diff --name-status main...wip/992/implementer` contained only the seven declared `scripts/` subjects before this verdict artifact.

No surviving counterexample or test-bypass finding remains. This verdict accepts the implementation; it does not replace any separate normative-document gate.
