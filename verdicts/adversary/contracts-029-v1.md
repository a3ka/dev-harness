FAIL

# Adversary verdict — contract 029

Judged HEAD: `467627b149cc5567e534078d03b79d4553b4d7bf`, in a disposable clone. This is an execution verdict: every blocking item below is a bad implementation that the released barrier accepted.

## Blocking live bypasses

1. **`verify_consultant.sh` executes a consultant-supplied shell substitution and writes into the filesystem.** A clean Git root and an otherwise honest response contained one allowed-looking command:

   ```text
   КОМАНДА: ls $(touch /tmp/dev-harness-verify/adv029/consult-bypasses/marker)
   RC: 0
   ВЫВОД-SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
   ```

   The released barrier returned `rc=0` and the marker existed (`injection rc=0 marker=yes`). This is not an oracle mismatch: after substitution `ls` genuinely had rc 0 and empty output. `contains_forbidden` looks for one entire literal string of metacharacters rather than any metacharacter; then the non-Git branch runs `bash -c "cd '$ROOT' && $cmd"`. Thus a command controlled by the consultant both survives the argv check (`argv[0]=ls`) and executes arbitrary shell syntax. It violates the closed readonly list and creates a writing channel outside G1–G4.

2. **A prerequisite that exits 127 is accepted as successful hashing.** With only `sha256sum` shadowed by an executable which prints `deadbeef  -` and exits 127, an answer `КОМАНДА: ls`, `RC: 0`, `ВЫВОД-SHA256: deadbeef` passed `verify_consultant.sh` (`fake_sha_rc127 rc=0`). The script's `command -v` sees the wrapper and ignored failure of `sha_vyvoda` inside array assignment. The same broken `sha256sum` lets `check_fork_route.sh --root <valid-root>` return `rc=0`, although its declared prerequisite has failed. This is the required refusal-looking-like-success class, not a missing binary case: with `PATH` containing no Git, `check_fork_route.sh` correctly returned rc 2.

3. **The consultant grammar accepts an answer lacking three mandatory header fields.** An answer containing only `МОДЕЛЬ:`, a complete honest `ОСНОВАНИЕ-ДЕРЕВО` triple, and no `ПРЕДМЕТ:`, `ВОПРОС:`, or `РЕКОМЕНДАЦИЯ:` returned `rc=0` (`absent_header_fields rc=0`). Contract invariant 8 calls all four fields mandatory.

4. **Git alternates bypass the claimed `--root` tree boundary.** I created an unreferenced clean root with `.git/objects/info/alternates` pointing to a different repository's object store. A response with `git show <external-commit>` returned `rc=0`; the root had no `HEAD` (`no_root_head=yes`) and the accepted output contained the external repository's `outside-root` payload (`alternates rc=0 no_root_head=yes external_output=yes`). G1 scrubs environment variables only, G2 scans config only, and neither gates the alternates file. Therefore the alleged tree basis may be supplied by a different repository without any record in the checked root.

5. **`check_fork_route.sh` does not validate the journal grammar it promises to classify.** A single accepted file named `forks/UPPER_кириллица.md` had `ФОРК: another-id`, two contradictory `КЛАСС:` lines (the first engineering), and `ЗАВЕДЁН: not-an-iso-time`; normal mode returned `rc=0` (`record_grammar rc=0`). It neither enforces ASCII `[a-z0-9-]+`, filename/`ФОРК` equality, unique fields, nor the mandatory ISO grammar. Separately, two different files both declaring `ФОРК: shared` (the second also using lower-case `t`/`z`) returned rc 0. This permits duplicate subject identities and fragile fields to evade all three route checks.

6. **Flush reads `ОТВЕЧЕНО` from the neighbouring record, not the record being queued.** In an isolated `forks/`, `a.md` was an unanswered, blocking batch record and `b.md` was answered. Contract rule 4 requires `ФЛАШ` due to `a.md`; the released `--flush` returned `rc=0`, `ЖДЁМ` (`flush_neighbour rc=0 output=ЖДЁМ`). The queue loop reads `record_field "$f" "ОТВЕЧЕНО"` where `f` remains the last file from the preceding loop. This is the wrong-row classifier class, not a speculative parsing concern.

7. **Malformed queue time is silently treated as harmless.** A pending batch record with `ЗАВЕДЁН: 18-09-2026 not-ISO` passed `--flush` as `rc=0`, `ЖДЁМ` (`flush_bad_timestamp rc=0 output=ЖДЁМ`). The contract requires the exact UTC ISO form and says an unmeasurable head must be red; `date -d` failure merely leaves `head_age=-1`.

## Controls and non-findings

- Positive control for the consultant barrier: a complete honest `git status --short` response on a clean Git root returned rc 0. A different allowed readonly command with an unpresented option, `git diff --name-status`, also returned rc 0.
- Scoped mandatory regression was run in this disposable clone:

  ```text
  bash scripts/verify_antiplacebo.sh --scope check_fork_route verify_consultant
  ```

  It returned rc 0: 2 barriers, 3 fixtures, 3 red repetitions. This shows the released cases are green while the live bypasses above remain.
- G2 behaves correctly for the requested conditional configuration probe: a local `includeIf.gitdir:never.path` was rejected before replay with rc 1 and `конфиг вне белого списка`. A nested untracked `.git` with an executable `post-index-change` hook was not executed by a top-level `git status --short` (`nested_dotgit rc=0 marker=no`); this specific non-160000 probe did not bypass execution.
- `git diff --exit-code frozen/contracts/029/1 HEAD -- contracts/029-auto-konsultant-forkov.md` was empty. `git diff --exit-code c5dd05bf7f1ac5be2dc7c1ec78859fadd36a6bb7 HEAD -- fixtures/check_fork_route/red_*.sh fixtures/verify_consultant/red_*.sh` was also empty: the nine architect red fixtures were not rewritten after the architect's circle-3 commit.
- Norm wiring is present and points to the real interface: `roles/orchestrator.md` names `roles/consultant.md`, tier `consultant`, and exactly `bash scripts/check_fork_route.sh --root .`; its rc-1 instruction is limited by the stated will-owner/design exceptions. The registry maps role `consultant` to tier `consultant` and the role file exists. This does not remedy the executable bypasses.
- CI balance is not close to its limit on the stated HEAD. GitHub Actions run `35383927573` (success) had ap4 job `105726269027`, started `2026-09-18T19:05:07Z`, completed `19:05:57Z`: 50 seconds against 20 minutes (1,150 seconds headroom).

The verdict is FAIL until every accepted bad implementation above is rejected while the positive controls remain green.
