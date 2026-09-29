FAIL

# Adversary056 — contract 056 (`--retake-ahead`)

## Scoped proof

- Positive control: `bash fixtures/check_no_leak/red_dver_retake_ahead.sh` completed rc 0: a0–a7 passed twice with distinct generated inputs.
- Frozen regression barriers are byte-identical to `frozen/contracts/056/1`:
  `fixtures/check_no_leak/red_bulk_peresnjatie_bazlajna.sh` and
  `fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh`.
- A missing inherited utility was fail-closed: `PATH=/nonexistent /bin/bash scripts/check_no_leak.sh --retake-ahead /tmp` printed `NOT_IMPLEMENTED: утилита git отсутствует` and returned rc 2.
- The empty-input case is exercised by a5 in both fixture runs. The universal-membership neutralization below was caught at a7, so the positive control is not permanently red.

## Findings

### F1 — valid backslash pathname is rejected although it is in `origin/main..HEAD`

The implementation encodes a backslash in the manifest path (`enc_path`), but compares that encoded value to the quoted text emitted by `git diff --name-only`. These are not the same representation. A clean, committed ahead change therefore fails the required positive branch.

Reproduction (all paths are disposable under `/tmp/dev-harness-verify/a056-backslash`): initialize a `main` repository and bare `origin`, push the base commit, snapshot with `TMPDIR=/tmp/dev-harness-verify/a056-backslash/snaps`, then create and commit the literal pathname `docs/a\b.md` without pushing it. The observed `git diff --name-only origin/main..HEAD` output was:

```
"docs/a\\b.md"
```

`--check` correctly returned rc 1 and named the encoded refusal path. But the contract-positive invocation

```
TMPDIR=/tmp/dev-harness-verify/a056-backslash/snaps \
  bash scripts/check_no_leak.sh --retake-ahead /tmp/dev-harness-verify/a056-backslash/root
```

returned rc 1 with:

```
ОТКАЗ: переснятие-ahead не доказано: путь docs/a\\b.md вне диффа origin/main..HEAD
```

The root is absolute, the repository porcelain is clean, the delta is nonempty and contains no `.git/*`, and the only changed path is in the ahead commit. Contract 056 excludes tabs from the inherited manifest alphabet, not backslashes. a0–a7 use ASCII names and do not exercise this representation boundary.

### F2 — scoped battery accepts a mutant that drops the absolute-root invariant

Temporary mutant (restored before this verdict) changed the global argument guard from:

```
/*) ;;
```

to:

```
/*|.) ;;
```

The complete scoped battery still passed (a0–a7 twice). The mutant then accepted `--retake-ahead .` far enough to return the unrelated snapshot refusal:

```
ОТКАЗ: снимок отсутствует (/tmp/dev-harness-leak/0bde8b81/porcelain) ...
```

rather than the contract-required rc 1 `корень обязан быть абсолютным` before any root work. The live implementation does produce the required absolute-root refusal, but the battery has no executable relative-root probe, so this regression passes it.

### F3 — scoped battery accepts a mutant that drops exact arity

Temporary mutant (restored) changed:

```
[ "$#" -eq 2 ] || usage
```

to:

```
[ "$#" -ge 2 ] || usage
```

Again a0–a7 passed twice. With the mutant, `bash scripts/check_no_leak.sh --retake-ahead /tmp extra` reached root validation and returned `NOT_IMPLEMENTED: /tmp не репозиторий git` (rc 2), not the required dispatcher usage refusal (rc 1). The frozen contract requires exactly two arguments. The live implementation gives the required usage response, but no scoped test protects it.

## Controls that did catch their intended deceptive implementation

A temporary universal-membership mutant replaced the per-path literal membership test with only a nonempty-diff test. The scoped battery failed at a7 on the first run: it observed rc 0 and a snapshot transcript for both paths where it required the uncovered A path to be refused. This confirms a7 catches the intersection-for-subset neutralization. Randomized a1 names in the two runs also prevent a fixed-path success constant from satisfying the tested positive branch.

No implementation or fixture change remains from the mutations; only this verdict is to be committed.
