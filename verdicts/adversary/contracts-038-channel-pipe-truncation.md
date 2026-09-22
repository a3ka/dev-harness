FAIL — contract 038: `|` truncates the parsed channel and makes malformed declarations green

Subject: `scripts/check_provodka.sh` at `71f13cc41547ceb5948245797975c52f4b31bab4`.

## Finding

The classifier serializes every channel as `"$kind|$rest|$ln"` and later recovers
`rest` with `rest="${rest%%|*}"`. A literal `|` is legal input text and is not a
delimiter in Contract 038's channel grammar. Consequently all text from the first
pipe onward disappears before the guard, role, or charter parser sees it.

### Vector 1 — trailing garbage after the closing `»` (round-5 Б2 class, reopened)

Round 5 explicitly closed "мусор после последней »" by anchoring `extract_quoted`
to the whole line; the postk5 control `role-trailing-garbage-rejected` is red
(`rc=1`) when the junk is separated by a space. Replacing that one byte with a
pipe restores the bypass. All three channels accept out-of-grammar junk:

- `- guard=scripts/valid.sh|trailing`
- `- role=roles/valid.md «Role norm.»|trailing`
- `- charter=AGENTS.md §Target «Charter norm.»|trailing`

Each returns `rc=0`. The honest counterparts also return `rc=0`, so this is not
an always-red checker.

### Vector 2 — a whole second channel hidden behind the pipe (round-11 class, reopened)

Round 11 closed the "голый канал" bypass: a channel declaration that the field
loop silently discarded while an honest first channel kept the contract green.
The same concealment is available again on a single line:

```text
ПРОВОДКА:
- role=roles/valid.md «Real norm.»|role=roles/absent.md «Nonexistent norm.»
```

`rc=0`. The identical pair written as two lines is correctly red:
`rc=1`, «проводка: role-файл не существует: roles/absent.md». A contract can
therefore declare a channel whose target does not exist and still pass the
done-gate, which is precisely the property the barrier exists to deny.

## Boundary

This is a parser/data-representation defect in the barrier's own text under
honest direct execution. It does not rely on PATH shims, exported functions,
IFS, locale, a substituted binary/substrate, `source`/`.` execution, or
pre-existing interpreter state — none of the three arbitrated exclusions
(`038-role-validacija-podhod.md`, `038-vrazhdebnaja-sreda-zapuska.md`,
`038-sourced-ispolnenie-granica.md` §3) applies.

## Evidence

Run from the repository root:

```bash
bash verdicts/adversary/contracts-038-channel-pipe-truncation.repro.sh
```

Output on the named subject:

```text
honest-guard: rc=0
pipe-tailed-guard-red: rc=0
honest-role: rc=0
pipe-tailed-role-red: rc=0
honest-charter: rc=0
pipe-tailed-charter-red: rc=0
two-line-second-channel-control: rc=1
pipe-hidden-second-channel-red: rc=0
REPRODUCED: a literal pipe truncates the channel payload before grammar validation — trailing junk in all three channels and an entire concealed second role channel all return green.
```
