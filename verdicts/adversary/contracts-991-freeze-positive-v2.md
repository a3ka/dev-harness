ACCEPT

OBJECT_FREEZE=`8235118f6d2ea062351a44df5c16ba895c3b5c6d` (#106)
OBJECT_POSITIVE=`7e74d2da70866a914bc1794f6110a822fd444bd8` (#107)
B=`dc396b6134b1ab1670cf35551c0d4e48a845d073`

Fresh second-round adversarial verdict. The old findings in `contracts-991-freeze-positive-v1.md` do not reproduce on these objects: version drift has a named refusal and the current positive C has a completed cloud dispatch. No new bypass was found.

## Frozen H and live B/C pair

The executed comparator is byte-identical to `frozen/contracts/991/2`:
`da3e286e4a343daac40e3b8e23737171dfb8c01d620f933d23a7de2e3f803946`.
Frozen `probe.py`, `matrix_carriers.py`, and `smoke_carriers.py` were likewise byte-identical to the executed fixtures. A fresh clone contained both requested objects; `8235118…` descends from B, and `7e74d2…` descends from it through `7967f75914627e7c734d195f4cd73996103d6dc5`.

```text
compare --base dc396b6 --head 8235118 --phase freeze  -> rc=0 ACCEPTED
compare --base dc396b6 --matrix                         -> rc=0, executed=63, mismatches=0
compare --base 8235118 --head 7e74d2d --phase positive -> rc=0 ACCEPTED
compare --base 8235118 --matrix                         -> rc=0, executed=65, mismatches=0
smoke_carriers.py                                       -> rc=0
```

The executed matrices rejected their generated mutations at the named node: missing/altered/duplicate/misplaced Ds5, quality/job neutralization, disabled/duplicated evidence, altered flow directory, softened APK upload, changed pins, out-of-zone and unreferenced files, malformed YAML, and missing workflow. The independent CLI smoke accepted its honest Git B/C control and rejected missing, altered, and moved Ds5.

After fresh `npm ci --ignore-scripts` in the positive C worktree:

```text
probe.py --repo C          -> rc=0, executed=2
probe.py --repo C --matrix -> rc=0, executed=6
```

Both real assertions passed. The discriminating controls behaved correctly: `noop/R1`, `premature/R1`, and `sticky/R2` failed; the deliberately non-exposing `sticky/R1` passed. Thus this is not an always-red probe. C's committed Jest and Maestro flow matched the frozen pins byte-for-byte.

## Replay countermodels

I extracted the effective C bodies and replayed them in scratch, with one positive control and direct counterexamples:

```text
honest evidence bundle                           -> rc=0
missing rehearsal-after.png                      -> rc=1 EVIDENCE_MISSING: rehearsal-after.png
empty release APK                                -> rc=1 EVIDENCE_EMPTY: android/app/build/outputs/apk/release/app-release.apk
duplicate rehearsal-before.png                   -> rc=1 DUPLICATE_EVIDENCE: rehearsal-before.png
JUnit lacking successful .maestro/rehearsal.yaml -> rc=1 JUNIT_REHEARSAL_INVALID
```

For each of `android-e2e` and `android-e2e-cloud`, the exact `rehearsal_version` body passed with a `2.11.0` tool; a tool returning hard-coded `2.10.0` and an absent tool on PATH each returned rc=1 with `MAESTRO_VERSION_MISMATCH`. Total replay: `executed=11, mismatches=0`. This exercises both the former silent-version failure and the missing-tool countermodel.

## Fresh cloud evidence

Live `gh run view --repo a3ka/Complior-mob 39061274882 --json headSha,conclusion,status,event,workflowName,jobs,url` returned completed/success `workflow_dispatch` for `mobile-cloud-e2e` at exactly `7e74d2…`. Both `expo-versions` and `android-e2e-cloud` succeeded. The observed cloud job completed Ds5, the API-36 Maestro scenario, evidence check, both uploads, and the version check.

I downloaded both cloud artifacts and replayed real C `rehearsal-evidence.sh` over their APK/JUnit/PNG bundle with a 2.11.0 Maestro shim: rc=0. The artifact manifest binds `GITHUB_SHA=7e74d2…`, run `39061274882`, attempt `1`, and its hashes equal the replayed files:

```text
APK                   b68376dfbaaa340bfe5a5312572cd338512becd59fb5d63e653b4f6066175d89
flow                  eef6d0b7df2cb84832f76886632e364f97c1349b065de54267151b6456c78d50
JUnit                 2c4955816058adffd5e445a0b33a5da7a9e831fb6583a618dcf8222ab9455dec
rehearsal-before.png  ec4823ab5ede7ce4a3f40b4df461b6757bf123f3c255f2be643ab8c6fd20db84
rehearsal-after.png   ba4c9c44786481f66f79e87317c5d8a132505b57d6edd9ae39055c8183da5cfb
```

`gh pr checks --required` was green for quality/android-e2e on both open PRs. #107 still targets `main`, so the known sequencing condition remains: #106 must merge before the final #107-vs-current-main comparison. It is not a new bypass in this pair.

No dishonest implementation passed the exercised battery H, while all honest controls passed. This ACCEPT covers only the requested current structural, behavioral, replay, and cloud evidence; it does not close a separate normative/owner/Merge gate.
