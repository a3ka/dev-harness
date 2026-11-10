#!/usr/bin/env python3
"""188: structural role-channel test. Canonical literal norms: norms.tsv."""
import argparse
from pathlib import Path
import sys
import subprocess
import tempfile

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


def visible_lines(text):
    """Exclude Markdown HTML comments and fenced code before matching role norms."""
    result = []
    comment = False
    fence = None
    for original in text.splitlines():
        if fence is not None:
            stripped = original.lstrip(' ')
            char, width = fence
            run = len(stripped) - len(stripped.lstrip(char)) if stripped.startswith(char) else 0
            if len(original) - len(stripped) <= 3 and run >= width and not stripped[run:].strip():
                fence = None
            continue
        line = original
        visible = ''
        while line:
            if comment:
                close = line.find('-->')
                if close < 0:
                    line = ''
                else:
                    line = line[close + 3:]
                    comment = False
            else:
                opening = line.find('<!--')
                if opening < 0:
                    visible += line
                    line = ''
                else:
                    visible += line[:opening]
                    line = line[opening + 4:]
                    comment = True
        # Markdown fences are only recognised outside comments. Code inside a
        # fence is opaque, including any unmatched HTML comment delimiters.
        stripped = visible.lstrip(' ')
        indent = len(visible) - len(stripped)
        if not comment and indent <= 3 and stripped and stripped[0] in ('`', '~'):
            char = stripped[0]
            width = len(stripped) - len(stripped.lstrip(char))
            if width >= 3:
                fence = (char, width)
                continue
        result.append(visible)
    return result


def assess(text, role, literal):
    """One exact autonomous norm after its role marker in the sole required section."""
    lines = visible_lines(text)
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
        if assess(honest[role].replace(literal + '\n', '<!--\n' + literal + '\n-->\n', 1),
                  role, literal):
            failures.append(f'html {role}/{key}')
        if assess(honest[role].replace(literal + '\n', '```text\n' + literal + '\n```\n', 1),
                  role, literal):
            failures.append(f'fence {role}/{key}')
    # A literal after a closed fence remains valid even if its code payload
    # contains an unclosed HTML delimiter.
    role, key = 'architect', 'cells'
    literal = next(text for r, k, text in rows if (r, k) == (role, key))
    with_fence = honest[role].replace(marker(role), '```text\n<!--\n```\n' + marker(role), 1)
    if not assess(with_fence, role, literal):
        failures.append('control fenced-comment')
    if args.model:
        print(f'CELLS={len(rows)} HONEST={len(rows)-len([f for f in failures if f.startswith("control ")])} '
              f'RED_NEGATIVES={len(rows)-len([f for f in failures if f.startswith("missing")])} '
              f'HTML_NEGATIVES={len(rows)-len([f for f in failures if f.startswith("html")])} '
              f'FENCE_NEGATIVES={len(rows)-len([f for f in failures if f.startswith("fence")])}')
        return 1 if failures else 0

    # Independent deceptive implementations; each paired with its distinguishable coordinate.
    cases = (
        ('wrong-role', 'critic', 'finding', lambda s, t, role: s.replace(t + '\n', '', 1),
         'architect'),
        ('html-comment-multiline', 'architect', 'cells',
         lambda s, t, role: s.replace(t + '\n', '<!--\n' + t + '\n-->\n', 1), None),
        ('html-comment-inline', 'critic', 'sixth',
         lambda s, t, role: s.replace(t + '\n', '<!-- ' + t + ' -->\n', 1), None),
        ('fenced-code', 'implementer', 'engine',
         lambda s, t, role: s.replace(t + '\n', '```text\n' + t + '\n```\n', 1), None),
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
    # Exercise the public --repo entrypoint, not just the in-memory assess() call:
    # all seven honest files remain intact except one hidden multiline norm.
    target = ('architect', 'cells')
    literal = next(text for r, k, text in rows if (r, k) == target)
    with tempfile.TemporaryDirectory(prefix='roles188-', dir=HERE) as scratch:
        role_dir = Path(scratch) / 'roles'
        role_dir.mkdir()
        for role, text in honest.items():
            if role == target[0]:
                text = text.replace(literal + '\n', '<!--\n' + literal + '\n-->\n', 1)
            (role_dir / f'{role}.md').write_text(text, encoding='utf-8')
        result = subprocess.run([sys.executable, str(Path(__file__).resolve()), '--repo', scratch],
                                capture_output=True, text=True, check=False)
    verdicts = result.stdout.splitlines()
    expected = [f'{"RED" if (role, key) == target else "GREEN"} {role}/{key}'
                for role, key, _ in rows]
    expected.append(f'CELLS={len(rows)} GREEN={len(rows)-1}')
    if result.returncode == 1 and verdicts == expected:
        print('STAB repo-html-comment caught @ architect/cells')
    else:
        failures.append('stab repo-html-comment @ architect/cells')
        print('STAB repo-html-comment ZHIV @ architect/cells')
        print(result.stdout + result.stderr, file=sys.stderr)
    total = len(cases) + 1
    print(f'STABS={total} CAUGHT={total-len([f for f in failures if f.startswith("stab")])}')
    return 1 if failures else 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError) as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
