FAIL — contract 038: `|` truncates the parsed channel and makes malformed declarations green

Subject: `scripts/check_provodka.sh` at `71f13cc41547ceb5948245797975c52f4b31bab4`.

## Finding

The classifier serializes every channel as `"$kind|$rest|$ln"` and later recovers
`rest` with `rest="${rest%%|*}"`. A literal `|` is legal input text to the shell
and is not a delimiter in Contract 038's channel grammar. Consequently all text
from the first pipe onward disappears before the guard, role, or charter parser
sees it.

The reproduction creates honest controls, then appends `|trailing` after each
otherwise valid channel:

- `- guard=scripts/valid.sh|trailing`
- `- role=roles/valid.md «Role norm.»|trailing`
- `- charter=AGENTS.md §Target «Charter norm.»|trailing`

Each is outside the exact grammar in Contract 038 §Инварианты 1: respectively
the guard target is no longer `scripts/<имя>.sh`, and the role/charter quoted
norm is no longer the whole remainder of its channel. Nevertheless the subject
returns `rc=0` for all three. The verified honest counterparts also return
`rc=0`; this is not an always-red checker.

This is a parser/data-representation defect in the barrier itself. It does not
rely on PATH, exported functions, IFS, locale, a substituted binary, source/
`.` execution, or pre-existing interpreter state, so none of the three
arbitrated exclusions applies.

## Evidence

Run from the repository root:

```bash
bash verdicts/adversary/contracts-038-channel-pipe-truncation.repro.sh
```

Expected output and reproduction-script status on the named subject:

```text
honest-guard: rc=0
pipe-tailed-guard-red: rc=0
honest-role: rc=0
pipe-tailed-role-red: rc=0
honest-charter: rc=0
pipe-tailed-charter-red: rc=0
REPRODUCED: a literal pipe truncates all three channel payloads before grammar validation, so malformed guard, role, and charter declarations return green.
```
