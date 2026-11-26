#!/usr/bin/env python3
"""223 catalog cell: real frozen refs; canonical declarations captured before CLI."""
from pathlib import Path
import re
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SUBJECT = '223'
CONTRACT = 'contracts/223-arch-ci-review.md'


def command(args, cwd):
    result = subprocess.run(args, cwd=cwd, capture_output=True, timeout=90)
    if result.returncode:
        raise RuntimeError(f'CONTEXT_WORLD {args!r}: {result.stderr!r}')
    return result.stdout.decode().strip()


def git(root, *args):
    return command(['git', '-C', str(root), *args], root)


def invoke(root, source):
    path = root / 'fixtures/workshop_project/arch_ci_review_223/context.py'
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(source)
    return subprocess.run([sys.executable, '-B', str(path)], cwd=root,
                          capture_output=True, timeout=90)


def declarations(result):
    lines = result.stdout.decode().splitlines()
    return [line for line in lines if line.startswith('ПЕРЕСЕЧЕНИЕ ')], lines


def main():
    source = (HERE / 'context.py').read_text()
    # Frozen contract, not subject output, is the independent pre-call oracle.
    contract = git(ROOT, 'show', f'frozen/contracts/{SUBJECT}/1^{{commit}}:{CONTRACT}')
    expected = sorted(line for line in contract.splitlines() if line.startswith('ПЕРЕСЕЧЕНИЕ '))
    if len(expected) != 75 or len(set(expected)) != 75:
        raise RuntimeError('CONTEXT_CANON_NOT_75')
    latest = {}
    for tag in git(ROOT, 'tag', '-l', 'frozen/contracts/*').splitlines():
        match = re.fullmatch(r'frozen/contracts/([0-9]{3})/([0-9]+)', tag)
        if match:
            number, version = match.groups()
            if number != SUBJECT and int(version) > latest.get(number, (0, ''))[0]:
                latest[number] = int(version), tag
    blobs = []
    for number, (_, tag) in sorted(latest.items()):
        paths = [path for path in git(ROOT, 'ls-tree', '-r', '--name-only', tag, '--', 'contracts/').splitlines()
                 if re.fullmatch('contracts/' + number + r'-[^/]+\.md', path)]
        if len(paths) != 1:
            raise RuntimeError('CONTEXT_AMBIGUOUS_CANON ' + tag)
        blobs.append((tag, paths[0], git(ROOT, 'show', tag + '^{commit}:' + paths[0])))
    scratch = ROOT / 'tmp'
    scratch.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='context223-', dir=scratch) as temporary:
        root = Path(temporary)
        git(root, 'init', '-q')
        for _, path, text in blobs + [('', CONTRACT, contract)]:
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(text + '\n')
        git(root, 'add', 'contracts')
        git(root, '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
            'commit', '-qm', 'frozen census world')
        for tag, _, _ in blobs:
            git(root, 'tag', tag)
        for state in ('before-freeze', 'own-frozen', 'own-highest-frozen'):
            if state != 'before-freeze':
                version = '1' if state == 'own-frozen' else '999'
                git(root, 'tag', f'frozen/contracts/{SUBJECT}/{version}')
            result = invoke(root, source)
            actual, lines = declarations(result)
            if (result.returncode != 0 or actual != expected or
                    lines.count('ДЕКЛАРАЦИИ 75') != 1 or
                    any(line.startswith(f'ИСТОЧНИК frozen/contracts/{SUBJECT}/') for line in lines)):
                print(f'CONTEXT {state} RED rc={result.returncode}', file=sys.stderr)
                sys.stderr.buffer.write(result.stderr)
                return 1
            print(f'CONTEXT {state} rc=0 DECLARATIONS=75')
        guard = '            if n == SUBJECT:\n                continue\n'
        if source.count(guard) != 1:
            raise RuntimeError('CONTEXT_MUTATION_ANCHOR')
        variants = (
            ('self-included', source.replace(guard, ''), 1),
            ('only-first-self-excluded', source.replace('if n == SUBJECT:', 'if n == SUBJECT and int(v) == 1:'), 1),
            ('literal-equality-equivalent', source.replace('if n == SUBJECT:', 'if SUBJECT == n:'), 0),
        )
        for name, candidate, wanted in variants:
            result = invoke(root, candidate)
            actual, lines = declarations(result)
            if wanted:
                valid = (result.returncode == 1 and b'CONTRACT_OVERLAPS_INCOMPLETE' in result.stderr and
                         any(f' — {SUBJECT} ' in line for line in actual))
            else:
                valid = result.returncode == 0 and actual == expected and lines.count('ДЕКЛАРАЦИИ 75') == 1
            print(f'CONTEXT {name} rc={result.returncode} expected={wanted}')
            if not valid:
                return 1
    print('CONTEXT KLETKI 3 STABY 2 EKVIVALENTY 1 ZHIVYH 0')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print('NOT_IMPLEMENTED: CONTEXT223: ' + str(error), file=sys.stderr)
        sys.exit(2)
