FAIL
OBJECT=e26ba282f829364cd5af6f37e65012da86be912c

# Adversary verdict — contract 111 implementation, round 2

## Blocking finding

### A1r2 — `NONBRAND_OPAQUE_RASTER_BYPASS`

The strengthened static check proves PNG decodability, dimensions, aspect ratio,
more than one RGBA value, and at least one transparent pixel. It does **not** prove
the contract's required fact: `wordmark-dark.png` is the raster of the canonical
`logo/assets/complior-wordmark-dark.svg`. `source.json` already freezes the
canonical raster command, 429×156 RGBA result, and SHA-256
`fcb1a2f87c2277a67c410226e26e949e403f8ec9a02bce970745969c5f02589e`, but
`first_run_static_probe.py` does not compare the asset to that frozen identity.

**Bypass.** I copied C to
`/tmp/dev-harness-verify/Adv111r2/M-wordmark` and replaced only
`mobile/assets/images/wordmark-dark.png` with a valid 429×156 RGBA PNG: an opaque
black rectangle with exactly one transparent pixel. It has the correct dimensions
and canonical aspect ratio, has two distinct RGBA values, and is a deliberately
non-brand image. The screen still refers to the required filename and all code,
accessibility props, and configuration are unchanged. Thus it is not a Complior
wordmark and is not a rasterisation of the canonical SVG, but it passes every 111
cell:

```text
$ first_run_static_probe.py --repo M-wordmark
static 15/15
$ first_run_probe.py --repo M-wordmark
honest 13/13
$ sha256sum M-wordmark/.../wordmark-dark.png C/.../wordmark-dark.png
a9f143a1a2c4383d661b67718ec5530fb0f9111ca96e1a00064965e13062dcba  M-wordmark/.../wordmark-dark.png
fcb1a2f87c2277a67c410226e26e949e403f8ec9a02bce970745969c5f02589e  C/.../wordmark-dark.png
```

The mutant additionally completed `npx expo prebuild --platform android --no-install`
successfully, so it is a valid input to the native project generator. The attempted
`./gradlew :app:processDebugResources` could not reach aapt2 because this station
has no `ANDROID_HOME`/SDK configured; Gradle stopped during project configuration
with `SDK location not found`. This infrastructure limitation does not invalidate
the reproducible green battery bypass.

**Required battery correction.** Add a literal-oracle cell such as
`WORDMARK_ASSET_CANONICAL_SHA256` that hashes
`mobile/assets/images/wordmark-dark.png` and requires the frozen SHA-256 above
(or independently rerasterises the frozen canonical SVG with the pinned renderer
and compares the result). Add this opaque/non-brand 429×156 RGBA mutant and require
that exact cell to be red. Decoder/geometry/transparency heuristics are not an
identity check and cannot establish the source-raster requirement.

## Contract table

| Area | Measured result | Verdict |
|---|---|---|
| A1 / Б1: real canonical wordmark | C itself has the frozen canonical SHA-256 and the strengthened decoder cell is green. But `NONBRAND_OPAQUE_RASTER_BYPASS` is green 15/15 + 13/13, so the battery still admits a non-wordmark while invariant 6 requires a raster from the canonical SVG. | **FAIL** |
| A2: full First-Run ground surface | `FIRST_RUN_GROUND_FULL_SURFACE_{DARK,LIGHT}` pass; matrix red for `wrapper-root-white`, `wrapper-root-magenta`, and `wrapper-root-padding` in both schemes. | PASS |
| B1: CTA in light | `CTA_OPENS_F03_01_{DARK,LIGHT}` pass; `light-cta-noop` is red only on LIGHT. | PASS |
| Safe-area, source binding, closed copy | Both schemes pass; light-only edge/source/copy mutants each red on their corresponding LIGHT cell. | PASS |
| Splash effective Android+iOS | `SPLASH_EFFECTIVE_GROUND_BOTH` passes; `android-splash-blue` is red there. | PASS |

## Round-1 advice C2–C6 (non-blocking)

| Advice | Status in C | Evidence |
|---|---|---|
| C2 — outer white/padded First-Run frame | Closed | First-run root is `flex: 1`, theme ground, zero padding; K6 dark/light plus all three wrapper mutants pass the matrix. |
| C3 — dark wordmark on light ground / visual contrast | Open, non-blocking | The screen still intentionally uses `wordmark-dark.png` in both schemes, as frozen invariant 6 specifies. It is a future design/contract decision, not a new scoped failure. |
| C4 — PNG decoder rather than magic bytes | Closed | `WORDMARK_ASSET_DECODES` is present and catches 1×1, malformed 82-byte, and solid-rectangle matrix mutants. It is insufficient for source identity (A1r2). |
| C5 — intrinsic width/aspect of a 22px wordmark | Closed | `styles.wordmark` has `height: 22` and `aspectRatio: 143 / 52.08`. |
| C6 — removed-code tombstone comment | Closed | The reported legacy/tombstone comment is absent from the current PilotApp implementation. |

## Acceptance and regression measurements

| Check | Measurement |
|---|---|
| Object identity / clean acceptance copy | `rev-parse HEAD` = required OBJECT; `git status --short --untracked-files=all` after probes produced 0 lines. |
| 111 honest probes | behavioral `honest 13/13`; static `static 15/15`. |
| 111 behavioral mutation matrix | 17 declared mutants; all emitted only their named/dependency red cells; command rc0. |
| 111 static mutation matrix | 12 declared mutants; all emitted only their named/dependency red cells; command rc0. |
| 995 frozen regression | `probe.py --check-frozen`: 14 actual cases passed, `runs=1 mismatches=0`. |
| 999 frozen regression | nav, UI, shell-static, and copy probes all rc0. |
| 108 frozen regression | `start_static_probe.py`: `static 22/22`; `start_probe.py`: `honest 336/336`. |
| Project test / lint / types | `npm test`: 14/14; `npm run lint`: rc0; `npm run typecheck`: rc0. |
| Scoped delivery paths | `16eb708a..OBJECT` changes exactly `.github/workflows/mobile.yml`, `mobile/app.json`, `mobile/assets/images/wordmark-dark.png`, `mobile/src/bootstrap/pilot-app.tsx`, `mobile/src/features/auth/first-run-screen.tsx`, and `mobile/src/i18n/ui-copy.ts`; all are implementer-zone paths. |

## Raw output

```text
$ python3 first_run_probe.py --repo C
case CTA_OPENS_F03_01_DARK
case CTA_OPENS_F03_01_LIGHT
case CTA_TEXT_EQUALS_FRAME_TITLE
case FIRST_RUN_COPY_CLOSED_DARK
case FIRST_RUN_COPY_CLOSED_LIGHT
case FIRST_RUN_GROUND_FULL_SURFACE_DARK
case FIRST_RUN_GROUND_FULL_SURFACE_LIGHT
case FIRST_RUN_STRUCTURE_DARK
case FIRST_RUN_STRUCTURE_LIGHT
case SAFEAREA_EDGES_ACTIVE_DARK
case SAFEAREA_EDGES_ACTIVE_LIGHT
case WORDMARK_SOURCE_BOUND_DARK
case WORDMARK_SOURCE_BOUND_LIGHT
honest 13/13

$ python3 first_run_static_probe.py --repo C
case SPLASH_GROUND_DARK
case SPLASH_DEFAULT_BLUE_GONE
case SPLASH_EFFECTIVE_GROUND_BOTH
case COPY_KEY_ui_first_run_promise
case COPY_KEY_ui_first_run_enter_f03
case SCREEN_SEAM_FIRST_RUN
case SCREEN_NO_HEX_LITERALS
case SCREEN_SAFEAREA_COMPONENT
case SCREEN_THEME_TOKENS
case CTA_TESTID_BOUND
case PILOT_WIRED_FIRST_RUN
case LEGACY_WEITER_GONE
case WORDMARK_ASSET
case WORDMARK_ASSET_DECODES
case STATIC_ORACLE_LITERALS
static 15/15

$ python3 first_run_probe.py --repo C --matrix
mutant cta-label-weiter ...
mutant promise-invented ...
mutant onenter-not-wired ...
mutant ground-default-blue ...
mutant demo-badge-scope ...
mutant wordmark-absent ...
mutant cta-testid-renamed ...
mutant light-cta-noop red= ['CTA_OPENS_F03_01_LIGHT']
mutant safearea-edges-empty ...
mutant wordmark-wrong-source ...
mutant extra-unreviewed-copy ...
mutant light-edges-top-bottom red= ['SAFEAREA_EDGES_ACTIVE_LIGHT']
mutant light-wrong-source red= ['WORDMARK_SOURCE_BOUND_LIGHT']
mutant light-extra-copy red= ['FIRST_RUN_COPY_CLOSED_LIGHT']
mutant wrapper-root-white ...
mutant wrapper-root-magenta ...
mutant wrapper-root-padding ...
[exit=0]

$ python3 first_run_static_probe.py --repo C --matrix
mutant splash-stays-default-blue ...
mutant android-splash-blue red= ['SPLASH_EFFECTIVE_GROUND_BOTH']
mutant copy-promise-invented ...
mutant copy-enter-missing ...
mutant screen-hex-literal ...
mutant pilot-unwired ...
mutant wordmark-missing ...
mutant wordmark-1x1-png ...
mutant wordmark-broken-stub-82 ...
mutant wordmark-solid-rectangle ...
mutant cta-testid-unbound ...
mutant screen-plain-view ...
[exit=0]

$ python3 first_run_static_probe.py --repo M-wordmark
static 15/15
$ python3 first_run_probe.py --repo M-wordmark
honest 13/13
$ npx expo prebuild --platform android --no-install  # M-wordmark/mobile
✔ Finished prebuild
$ ./gradlew :app:processDebugResources  # M-wordmark/mobile/android
FAILURE: SDK location not found. Define a valid SDK location with ANDROID_HOME ...
[exit=1 before aapt2]

$ npm test
Tests: 14 passed, 14 total
$ npm run lint
structure: OK (repository inventory; external trees excluded)
[exit=0]
$ npm run typecheck
[exit=0]

$ git -C C status --short --untracked-files=all
[no output]
$ git -C C diff --name-status 16eb708a OBJECT
M .github/workflows/mobile.yml
M mobile/app.json
A mobile/assets/images/wordmark-dark.png
M mobile/src/bootstrap/pilot-app.tsx
A mobile/src/features/auth/first-run-screen.tsx
M mobile/src/i18n/ui-copy.ts
```
