FAIL

# Adversary verdict — contract 029, round 3

Judged fresh HEAD `b27512f2aab41645a82f19bad3a35a03e23418c4` in a disposable
clone. This verdict judges only application of the round-2 fixes and channels
opened or left by those edits. The round-1 blockers are not reopened.

## Live bypasses

1. **`check_fork_route.sh` accepts an unavailable `sha256sum` when it prints the
   expected empty digest before failing.** A PATH-first fake printed
   `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  -` and
   exited separately with `rc=1` and `rc=127`. A nonempty conforming journal
   returned `rc=0` in both runs (`route-sha-correct-output-rc-1 rc=0` and
   `route-sha-correct-output-rc-127 rc=0`). The assignment captures
   `printf '' | sha256sum | cut ...` under `pipefail`, but does not inspect the
   assignment/pipeline status: it compares text only. This violates invariant
   10's required `rc=2` when the required tool cannot be used.

   The targeted false-output controls are closed: fake `sha256sum` answers
   `deadbeef` with rc 0, 1, and 127, and `cafebabe` with rc 0, each returned
   `rc=2`. The surviving construction is the distinct refusal-that-looks-like
   success case: honest-looking known-answer text paired with a failed command.

2. **`verify_consultant.sh` still executes PATH-first wrappers for two allowed
   utilities before its fixed `TRUSTED_PATH` boundary, while accepting an honest
   answer.** Each wrapper writes a marker then `exec`s `/usr/bin/<tool>`, so the
   command result remains honest. With a clean committed toy repository and a
   correct `git status --porcelain` triple, both following runs returned `rc=0`
   and left their marker:

   - `verify-path-wrapper-sha256sum rc=0; marker=yes` — the wrapper runs in the
     initial empty-hash probe and again in `sha_vyvoda`; neither call is under
     `env -i PATH="$TRUSTED_PATH"`.
   - `verify-path-wrapper-cat rc=0; marker=yes` — `RESP="$(cat "$OTVET")"`
     executes it before the G1/G2/G4 gates.

   Thus caller-controlled code can run before the guarded replays and may alter
   the process or checked tree while the verifier accepts. A forwarding wrapper
   is deliberately a minimal deception: every claimed rc and digest is still
   truthful, so result comparison cannot expose the execution channel.

## Re-executed controls and boundary observations

- Positive controls: a minimal conforming engineering journal returned
  `route-positive-control rc=0`; an independently constructed complete answer
  with a real empty `git status --porcelain` digest returned
  `verify-positive-control rc=0`.
- The repaired inner boundary is genuinely fixed for the tested paths:
  PATH-first forwarding wrappers for `git` and `ls` each returned `rc=0` with
  `marker=no`. `TRUSTED_PATH` is built only from the literal directories
  `/usr/bin` and `/bin` after absolute executable checks; it does not use
  caller-environment `command -v`. The residual issue is the unguarded
  pre-boundary calls above, not reinjection of caller PATH into `env -i`.
- `check_fork_route.sh` contains no `env -i` invocation. Its SHA known-answer
  probe itself remains a caller-PATH execution point: an honest forwarding
  `sha256sum` wrapper returned `route-path-wrapper-sha256sum rc=0` and
  `marker=yes`.
- The fixed-directory approach assumes `/usr/bin` and `/bin` are protected.
  A principal able to replace binaries at those absolute paths can still alter
  execution; that is outside the stated attacker scope, but it is the explicit
  trust anchor introduced by the round-2 repair.

The barrier is not accepted until the checker rejects a correct-text/nonzero
SHA helper with rc 2 and no caller-PATH executable can run on the verifier or
route-checker paths while their positive controls remain green.
