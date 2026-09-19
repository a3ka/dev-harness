# Adversary 031, round 4 — final judgment of hunk parser and m0..m9

**Verdict: accept.** The arbitration route 3 (ordinary acceptance of the hunk-context parser in both consumers) is closed. No false green was found. Route: reviewer 031 → `done/031` → first live mint.

## Subject and method
Judged the clone at `082e95755c128600585db771fc34d53ae36148f0`; arbitration decision `verdicts/arbitration/diff-parser-031-dver-mina.md` (47152de), parser fix bd2f906 and gate landing d674329 / 082e957. I did not modify the subject or its checks. The parser in `scripts/check_staged.sh:438-454` and `scripts/check_zones.sh:400-421` enumerates only lines after `^@@` until `^diff `, counts `/^\+/` and `/^-/` inside that hunk body, then requires `valid_count == add_count` using the frozen grammar.

## Ordinary acceptance (executed)
- `bash fixtures/check_staged/red_dver_minata_smeshannye_stroki.sh` → rc 0: `ok: ... все ворота пройдены (м0..м9)`.
- `bash fixtures/check_staged/red_dver_minta_orkestratora.sh && bash fixtures/check_staged/red_dver_minta_orkestratora.sh` → rc 0: both independent random runs report `в0..в13, в4б, в5б, в8б` passed.
- `bash fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh` → rc 0: р0 positive and р1..р10, including named negative branches and unchanged-snapshot checks, passed.
- scoped anti-placebo: `verify_antiplacebo --scope check_staged` → rc 0, 28/28; `--scope check_zones` → rc 0, 21/21; `--scope check_judge_gate` → rc 0, 3/3.
- `git diff --exit-code frozen/contracts/031/4 HEAD -- contracts/031-*.md` → rc 0.
- Detector transcript: absolute `check_no_leak --check` without a baseline correctly returned rc 1 `снимок отсутствует ... fail-closed`; after `--snapshot <absolute clone>` the required `--check <absolute clone>` returned rc 0, `основной чекаут чист`. A relative-root call is independently rejected rc 1 by the CLI (`корень обязан быть абсолютным`).

## Previous bypass classes — both actual paths
The executed mixed probe asserts each named rc rather than accepting a generic failure:
- k1 mixed ASCII (`N -> sha` beside valid row): staged м1 rc 1 and committed/orchestrator м3 rc 1, each `строка не по грамматике манифеста`.
- k2 bare `+` (empty added line): staged м4 rc 1 and committed м5 rc 1, each the same grammar failure.
- k3 leading `+` and `++` contents: staged м6/м6б rc 1 and committed м7/м7б rc 1, grammar failure; leading `-` and `--` deletions: staged м8/м8б rc 1 and committed м9/м9б rc 1, `дельта манифеста не только-добавление`.
The positive controls м0 (staged honest mint) and м2 (honest committed mint) are green in that same actual run, so these are not always-red stubs.

## Fresh parser attacks (constructed and executed; not reusing gate assertions)
A temporary clean-room runner used the production copied subjects with fresh toy repos. It committed four anchor lines, then placed a valid new mint row before `anchor-a` and the attack before `anchor-d`; `git diff --cached -U0` was asserted to contain at least two real `@@` headers. For every attack it first ran `check_staged`, then committed as actual `%an=orchestrator` and ran `check_zones`; both outputs had to contain the exact grammar refusal.

```
expect_grammar_both multi-hunk '@@ -999 +999 @@' 940
expect_grammar_both embedded-newline $'embedded-first\nembedded-second' 941
expect_grammar_both starts-at-at '@@ content looks like a hunk header' 942
```

Observed, each: `2 hunks; staged rc=1 grammar, zones rc=1 grammar`.
Thus (a) a diff with multiple actual hunk headers, (b) a supplied content value transporting a newline and thereby two hunk-body additions, and (c) content beginning `@@` all remain visible to the parser and fail in both consumers. No attack obtained rc 0.

## Adversarial conclusion
The positive honest cases pass; mixed ASCII, bare-plus, leading-plus/leading-minus (including meta-looking doubled forms), and the three fresh hunk-boundary inputs each are rejected at their exact relevant branch. The hunk parser therefore neither omits old bypass classes nor treats an hunk-looking content line as a new parser header. Accept.
