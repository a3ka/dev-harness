# FAIL — contract 038: ERE metacharacters in a guard basename forge wiring

**Verdict: FAIL.** Subject: `scripts/check_provodka.sh` at
`3776a956ea4c67f4b2cee5ea26e80b69768588e5`, honest direct execution in a fresh
canonical environment.

## Finding

`guard_is_wired()` derives the basename then interpolates it unescaped into an
ERE:

```bash
grep -Eq "(^|[^[:alnum:]_])${bname}([^[:alnum:]_]|$)"
```

The previous literal substring prefilter is not a remedy. A literal guard name
can be placed only inside a larger non-word token (`x<name>x`) while the ERE
interprets its metacharacters and accepts a different word in the same workflow
line. Thus the declared guard exists but is not called; the barrier nevertheless
returns `rc=0`.

The reproduction has one honest positive control and three independent red
inputs:

| Declared existing guard | Workflow actually calls | Why the ERE accepts it |
| --- | --- | --- |
| `scripts/a.b.sh` | `scripts/axb.sh` | `.` matches `x` |
| `scripts/a*b.sh` | `scripts/b.sh` | `a*` matches zero `a` bytes |
| `scripts/a[b.sh` | `scripts/axb.sh` | injected `[` changes the following ERE character-class parse |

In every workflow the declared spelling appears only as `x<name>x`, so it is not
a word according to the contract's `[^[:alnum:]_]` word grammar. The only
matching guard-shaped word is the different executable name. Each red input
returns `rc=0`; the minimal literal control returns `rc=0` as well, so this is
not an always-red or vacuous check.

Each vector also carries a neutralization: changing only the different candidate
word to `qqq` leaves the declared file and the `x<name>x` literal untouched and
returns exactly `rc=1` with the named g2 reason. This pins the green result to
the regex injection rather than the bare occurrence of the name.

## Boundary

This is direct parsing of a guard filename and workflow text by the barrier. It
uses no PATH/tool substitution, no inherited hostile environment, no sourced
execution, no filesystem race, and no earlier closed g0 class. None of
`038-role-validacija-podhod.md`, `038-vrazhdebnaja-sreda-zapuska.md`, or
`038-sourced-ispolnenie-granica.md` §3 excludes it.

## Evidence

```bash
bash verdicts/adversary/contracts-038-guard-ere-metacharacters.repro.sh
```

Output on the named subject:

```text
honest-literal-guard: rc=0
forged-wiring-a.b: rc=0
neutralized-a.b: rc=1
forged-wiring-a*b: rc=0
neutralized-a*b: rc=1
forged-wiring-a[b: rc=0
neutralized-a[b: rc=1
REPRODUCED: ERE metacharacters ., *, [ in a guard basename let a different workflow word satisfy guard_is_wired, although the declared guard is never called.
```
