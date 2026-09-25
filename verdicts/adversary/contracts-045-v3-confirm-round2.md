FAIL

# 045 v3 — adversary-confirm, round 2

`--repo` parsing is fixed, but the guard still judges `origin` when Git resolves a
*different configured remote* for the actual exchange. This is a live bypass in
the required class: a canonical `origin` passes the guard and the real Git
process exchanges with a noncanonical configured `evil` remote.

## Required confirmations on current HEAD

* `git log --oneline b4fd794..HEAD -- scripts/gitw` reports exactly:

  ```text
  9490b1e implementer: scripts/gitw И-4а — закрыть обход раздельной формы --repo и завис arm `*:*)`
  20d17ac implementer: scripts/gitw И-4а — распознать --repo=VALUE (равн-форма) как fallback-цель
  ```

* `bash fixtures/gitw/red_gitw_obmen.sh /home/aka/Documents/dev-harness` returned
  **rc 0**. Its positive control г0 is green for canonical push/fetch/pull; all
  20 adversarial stubs died on their named cells; then all honest cells
  г0–г18 were green. Final counter/output:

  ```text
  gitw: батарея зелёная (клетки г0-г18 + 20 стабов на своих клетках)
  ```

  Therefore this is not a perpetually-red test battery. It distinguishes the
  covered failures, including both `--repo` forms and positional precedence,
  but none of its cells changes Git's implicit remote selection.

* I checked the installed Git help for all three exchange subcommands. `git help
  fetch` and `git help pull` contain no `--repo` option. `git help push` alone
  documents `--repo=<repository>` as equivalent to `<repository>` with the
  positional argument taking precedence. `git push -h` identifies `-o` /
  `--push-option` as a server option and `--all`, `--mirror`, and `--tags` as
  ref-selection modes, not alternate repository arguments. Thus the previous
  option-target gap is closed; the bypass below is independently in configured
  remote resolution.

## Live disposable-clone counterexamples

All probes ran in freshly created `/tmp/gitw045-*` directories with only local
bare repositories; no network, foreign remote, or main checkout mutation was
used. In each probe `origin` was the canonical bare, `evil` was a distinct
noncanonical bare, and the wrapper was invoked with
`GIT_EXCHANGE_GUARD_CANONICAL=<canonical>`.

### Push default resolution

The following independent probe configured the source repository first with
`remote.pushDefault=evil`, then separately with `branch.main.pushRemote=evil`,
and invoked `scripts/gitw -C <source> push --force` without a positional
repository or `--repo` option. In both cases the wrapper returned success and
created `evil/main` from an absent ref:

```text
remote.pushDefault rc=0 evil-before=absent evil-after=f436027f53563c1e7d223a806e35c5390a0fd2d6 stderr=To /tmp/gitw045-round2.P5PU4X/evil.git  * [new branch]      main -> main
branch.pushRemote rc=0 evil-before=absent evil-after=f436027f53563c1e7d223a806e35c5390a0fd2d6 stderr=To /tmp/gitw045-round2.P5PU4X/evil.git  * [new branch]      main -> main
```

The SHA is the source tip. This is a real noncanonical push, not an exit-code
artifact. The parser leaves `target` and `bare_name` empty, so the current
implementation probes canonical `origin`, successfully runs `ls-remote` on
it, and transparently execs the original command. Git then applies
`pushRemote` / `pushDefault` and writes to `evil`.

### Pull and fetch configured-resolution controls

The same omission reaches the other judged subcommands.

* With `branch.main.remote=evil` and `branch.main.merge=refs/heads/main`, a
  `scripts/gitw -C <victim> pull` invocation passed the canonical-origin guard
  and fast-forwarded the victim to evil's distinct tip:

  ```text
  pull-branch.remote rc=0 head-before=9ec4bc797bc81c99a9bd6c3b55c43c6f23a4866a head-after=c556e359c0460e14197cc754662aa4dabe7f8c64 stderr=From /tmp/gitw045-fetchpull.akIp1l/evil  * [new branch]      main       -> evil/main
  ```

* `scripts/gitw -C <victim> fetch --all` passed while the repository had the
  same noncanonical `evil` remote. The resulting `FETCH_HEAD` contains evil's
  tip:

  ```text
  fetch-all rc=0 evil-tip-in-FETCH_HEAD=yes stderr=
  ```

`fetch --all` is not a repository-valued option like push's `--repo`; it is a
mode that makes the real command exchange with every configured remote. The
wrapper currently skips the flag, probes only `origin`, then execs the
multi-remote exchange. It therefore violates the stated requirement to judge
every exchange target before execution.

## Verdict and required correction

This is a blocker **FAIL**. Extend resolution from syntactic
positional/`push --repo` handling to the actual remote(s) selected by Git:
`branch.<current>.pushRemote`, `remote.pushDefault`, and the branch remote used
by pull must be judged as configured remotes (including their url/pushurl
forms), and multi-remote fetch modes such as `fetch --all` must either judge
each selected remote before execution or fail closed. Add isolated red cells
with canonical `origin`, distinct `evil`, SHA/HEAD/FETCH_HEAD side-effect
assertions, and matching positive controls. The existing g0 and 20-stub
positive/negative controls remain valid but do not exercise these selectors.
