# Adversary 031 / round 1 — implementation court

**Verdict: FAIL.** The mint door and the CI recognition both accept a manifest containing a valid mint line together with an invalid added line. This violates frozen 031/4 mechanism 1, condition 2: *every* added manifest line must match `^[0-9]{3} → [0-9a-f]{40}$`.

## Named bypass — mixed valid/invalid additions

### What is wrong

`scripts/check_staged.sh:445–446` filters the diff through `sed` and only rejects when the resulting set of valid lines is empty:

```sh
added_lines="$(… | sed -n 's/^\+\([0-9]\{3\} → [0-9a-f]\{40\}\)$/\1/p')"
if [ -z "$added_lines" ]; then …
```

It never verifies that the number/content of `added_lines` equals **all** added diff lines. Therefore an invalid addition is silently discarded once at least one valid line remains. All later registry and dual-control checks run only over `$door_pairs` built from the filtered subset.

`scripts/check_zones.sh:412–413` repeats exactly the same mistake in the historical mint-recognition path. Thus a commit that bypassed the staged hook (or was created with hooks disabled) is also recognized by CI as a legitimate mint, rather than reported as `коммит вне зоны`.

### Executed reproduction

A fresh toy repository was created with a frozen contract whose `orchestrator` has a real zone (so the judge reaches the door), a file-path `origin`, and two live annotated, origin-pushed tags. The staged manifest was:

```text
700 → <actual annotated-tag object SHA for id/CONTRACT/700>
701 -> <actual annotated-tag object SHA for id/CONTRACT/701>
```

The second added row has ASCII `->`, which is forbidden by the frozen grammar. The exact executed command was:

```sh
bash ../mixed_mint_grammar_repro.sh scripts/check_staged.sh
```

Raw result:

```text
rc=0
judged: registry/contracts.tsv (дверь минта 031: +1 строк ↔ живые dual-control теги)
ok: staged в зоне автора orchestrator (1 путь/путей)
REPRODUCED: valid plus invalid added manifest rows passed the mint door
```

The same tree was committed as actual `orchestrator` history and checked by the real CI-side recognition:

```sh
bash ../mixed_recognition_repro.sh scripts/check_zones.sh
```

Raw result:

```text
rc=0

процессных вне суда:

замороженных контрактов: 1 · объявленных авторов: 2 · коммитов в диапазонах: 1 · проверено по зонам: 1
REPRODUCED: invalid row was recognized as a legitimate mint commit
```

The throwaway repro scripts were removed after the runs; no subject or fixture was edited.

### Why the supplied checks miss it

The acceptance script separates the two relevant inputs instead of combining them:

* `fixtures/check_staged/red_dver_minta_orkestratora.sh:259–274` tests two **valid** additions (`в1б`) and expects green.
* `…:300–313` tests exactly one invalid ASCII-arrow addition (`в3`) and expects red.

Neither the mint-door cases nor the red acceptance exercise `valid addition + invalid addition` in the same manifest diff. Consequently the complete existing battery is green against this wrong implementation.

### Required author repair

Repair both consumers, not merely the staged hook:

1. In `check_staged`, reject if any `+` content line is not grammar-valid; only then build/check dual-control pairs.
2. Apply the same all-lines predicate in `check_zones` mint recognition.
3. Add a durable fixture that stages/commits one valid and one invalid newly added manifest row, asserts the named grammar refusal at `check_staged`, and asserts `check_zones` does not recognize the committed path. The positive valid `+N` control must remain green.

## Required acceptance runs and raw results

| Command | Result |
|---|---|
| `bash scripts/verify_antiplacebo.sh . --scope check_staged` | **rc 0**. `барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28`; includes all six `case_dver_minta_*` cases. |
| `bash fixtures/check_staged/red_dver_minta_orkestratora.sh` (run 1) | **rc 0**: `ok: дверь минта 031 — все ворота пройдены (в0..в13, в4б, в5б, в8б)`. |
| Same mint acceptance (run 2, separate random inputs) | **rc 0**, same all-gates result. |
| `bash fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh` | **rc 0**. Raw gates: `р0` through `р10` all `ok`; final `ok: дверь переснятия 031 — все ворота пройдены (р0..р10)`. |
| `bash scripts/verify_antiplacebo.sh . --scope check_judge_gate` | **rc 0** after isolated rerun: 3/3 fixtures red-capable. An earlier parallel invocation was intentionally discarded because concurrent `check_zones.sh` created/removing `tmp/zones.*`, and the runner correctly marked that run untrustworthy. |
| `bash scripts/check_zones.sh .` | **rc 0**: `замороженных контрактов: 32 · объявленных авторов: 3 · коммитов в диапазонах: 1248 · проверено по зонам: 794`. |
| `git diff --exit-code frozen/contracts/031/4 HEAD -- contracts/031-*.md` | **rc 0**, no output. |
| `bash scripts/check_no_leak.sh --retake` | **rc 1**, expected dispatcher refusal: `ОТКАЗ диспетчер: использование: check_no_leak.sh --snapshot|--check|--retake <абс-корень>`. |
| `bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness` | **rc 1**, not a 031 mechanism failure: the live main checkout was already dirty with `verdicts/adversary/contracts-033-v3.md, verdicts/adversary/contracts-030-v1.md`; raw output was `ОТКАЗ: основной чекаут загрязнён: …`. This is the required detector transcript and does **not** support the stipulated rc 0. |
| Fixture relocation probe | **rc 0**: `fixtures/check_zones/case_dver_minta_priznanie.sh` and `fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh` exist at HEAD; the old staged path and all five removed `case_peresnjatie_*` paths are absent. |

## Adversarial class coverage

* **Failure masquerading as success / rc 127:** `case_staged_ne_prochitan.sh` was executed by the green `check_staged` family: a PATH-first fake `git diff` exits 127; the guard rejects it named `staged не прочитан`.
* **Hard-coded value:** the mint acceptance was run twice with its separate randomized NNN ranges; all legitimate and rejecting gates passed. This did not reveal an additional constant bypass.
* **Tool absent/from PATH:** the green family executed `case_imja_control_simvol_bez_python3.sh` plus fake-python `exit 0` and `exit 1`; all three fail closed as designed.
* **Empty input:** retake gate `р6` was executed and correctly returned named rc 1 on an empty delta; the subsequent check remained clean.
* **Correct answer to the wrong question:** **found** — the code validates the filtered valid subset, not every added row.
* **Neutralization:** mint acceptance `в5` neutralizes the local issuance tag and rejects it; retake gates `р2`–`р5`, `р7`–`р10` each reject their individual non-verdict/snapshot-hiding condition while preserving the snapshot. All passed.

## Landing instruction

Do not advance 031 to `done/031` or perform the first live autonomous mint. The orchestrator should land this full FAIL verdict as `verdicts/adversary/contracts-031-v1.md` with `author=adversary`; this audit did not alter the main checkout, its worktree, or its branches.
