#!/usr/bin/env python3
"""188: structural role-channel test. Canonical literal norms: norms.tsv."""
import argparse
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FINDING_ROLES = ('architect', 'critic', 'implementer', 'adversary', 'reviewer')
HEADING = '## Архитектура 188'


def norms():
    rows = []
    for row in (HERE / 'norms.tsv').read_text(encoding='utf-8').splitlines():
        role, key, literal = row.split('\t')
        for recipient in FINDING_ROLES if role == 'all5' else (role,):
            rows.append((recipient, key, literal))
    if len({(role, key) for role, key, _ in rows}) != len(rows):
        raise ValueError('duplicate canonical coordinate')
    return rows


def marker(role):
    return f'Норма-строка (ПРОВОДКА roles/{role}.md, заморожена 188/1):'


def assess(text, role, literal):
    """One exact autonomous norm after its role marker in the sole required section."""
    lines = text.splitlines()
    if lines.count(HEADING) != 1:
        return False
    start = lines.index(HEADING) + 1
    end = next((i for i in range(start, len(lines)) if lines[i].startswith('#')), len(lines))
    section = lines[start:end]
    if section.count(marker(role)) != 1:
        return False
    norm_lines = section[section.index(marker(role)) + 1:]
    return literal in norm_lines


def model(rows):
    grouped = {}
    for role, _, literal in rows:
        grouped.setdefault(role, []).append(literal)
    return {role: '# Role\n\n' + HEADING + '\n\n' + marker(role) + '\n\n' +
            '\n'.join(literals) + '\n' for role, literals in grouped.items()}


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--repo', type=Path)
    args = parser.parse_args()
    rows = norms()  # Expectations captured before opening any subject role file.
    # Contract role channels quote the same canonical literals, not a second vocabulary.
    contract = (ROOT / 'contracts/188-roli-po-arhitekture.md').read_text(encoding='utf-8')
    for role, key, literal in rows:
        if contract.splitlines().count(f'- role=roles/{role}.md «{literal}»') != 1:
            print(f'NOT_IMPLEMENTED: role-channel citation {role}/{key}', file=sys.stderr)
            return 2
    honest = model(rows)
    if args.repo is not None:
        missing = []
        root = args.repo.resolve()
        for role, key, literal in rows:
            path = root / 'roles' / f'{role}.md'
            text = path.read_text(encoding='utf-8') if path.is_file() else ''
            if not assess(text, role, literal):
                missing.append(f'{role}/{key}')
                print(f'RED {role}/{key}')
            else:
                print(f'GREEN {role}/{key}')
        print(f'CELLS={len(rows)} GREEN={len(rows)-len(missing)}')
        return 1 if missing else 0

    failures = []
    for role, key, literal in rows:
        if not assess(honest[role], role, literal):
            failures.append(f'control {role}/{key}')
        # Each coordinate MUST fail independently, not just the first one in a combined case.
        if assess(honest[role].replace(literal + '\n', '', 1), role, literal):
            failures.append(f'missing {role}/{key}')
    if args.model:
        print(f'CELLS={len(rows)} HONEST={len(rows)-len([f for f in failures if f.startswith("control")])} '
              f'RED_NEGATIVES={len(rows)-len([f for f in failures if f.startswith("missing")])}')
        return 1 if failures else 0

    # Independent deceptive implementations; each paired with its distinguishable coordinate.
    cases = (
        ('wrong-role', 'critic', 'finding', lambda s, t, role: s.replace(t + '\n', '', 1),
         'architect'),
        ('comment', 'architect', 'cells', lambda s, t, role: s.replace(t + '\n', '# ' + t + '\n', 1),
         None),
        ('typo', 'implementer', 'engine', lambda s, t, role: s.replace(t + '\n', t + ' typo\n', 1),
         None),
        ('optional-section', 'orchestrator', 'linked',
         lambda s, t, role: s.replace(t + '\n', '', 1) + '\n## Справка (не обязательна)\n' + t + '\n',
         None),
        ('prose', 'reviewer', 'verdict', lambda s, t, role: s.replace(t + '\n', 'Пример: ' + t + '\n', 1),
         None),
    )
    for label, role, key, mutate, other in cases:
        literal = next(text for r, k, text in rows if (r, k) == (role, key))
        mutant = mutate(honest[role], literal, role)
        # Wrong-role decoy also carries the required text in the OTHER role.
        if other:
            mutant += '\n' + honest[other]
        if assess(mutant, role, literal):
            failures.append(f'stab {label} @ {role}/{key}')
            print(f'STAB {label} ZHIV @ {role}/{key}')
        else:
            print(f'STAB {label} caught @ {role}/{key}')
    print(f'STABS={len(cases)} CAUGHT={len(cases)-len([f for f in failures if f.startswith("stab")])}')
    return 1 if failures else 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError) as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
