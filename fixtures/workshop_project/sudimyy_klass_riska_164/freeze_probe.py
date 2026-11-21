#!/usr/bin/env python3
"""164 freeze boundary: positive legacy control, new-risk verdict required before tag."""
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FREEZE = ROOT / 'scripts' / 'freeze_contract.sh'


def call(argv, cwd=None):
    return subprocess.run([str(x) for x in argv], cwd=cwd, text=True, capture_output=True)


def git(repo, *args):
    return call(['git', '-C', repo, '-c', 'user.name=fixture',
                 '-c', 'user.email=fixture@example.invalid', '-c', 'commit.gpgsign=false',
                 '-c', 'core.hooksPath=/dev/null', *args])


def must(result, what):
    if result.returncode:
        raise RuntimeError(f'{what}: rc {result.returncode}: {result.stdout}{result.stderr}')
    return result.stdout.strip()


def init(repo):
    for dir_name in ('contracts', 'verdicts/critic', '.github/workflows', 'config'):
        (repo / dir_name).mkdir(parents=True)
    (repo / '.github/workflows/ci.yml').write_text('name: ci\non: push\njobs: {}\n')
    (repo / 'package.json').write_text('{"scripts": {}}\n')
    (repo / 'config/ci_parity_exceptions.txt').write_text('')
    must(git(repo, 'init', '-q', '-b', 'main'), 'init')
    must(git(repo, 'config', 'user.name', 'fixture'), 'identity')
    must(git(repo, 'config', 'user.email', 'fixture@example.invalid'), 'email')
    must(git(repo, 'config', 'commit.gpgsign', 'false'), 'signing')
    must(git(repo, 'config', 'core.hooksPath', '/dev/null'), 'hooks')
    must(git(repo, 'add', '-A'), 'add base')
    must(git(repo, 'commit', '-qm', 'initial'), 'commit base')
    origin = repo.parent / 'origin.git'
    must(call(['git', 'init', '-q', '--bare', origin]), 'bare origin')
    must(call(['git', '-C', origin, 'symbolic-ref', 'HEAD', 'refs/heads/main']), 'origin HEAD')
    must(git(repo, 'remote', 'add', 'origin', origin), 'origin remote')
    must(git(repo, 'push', '-q', 'origin', 'main'), 'push baseline')


def accepted(repo, number, risk, marker, mutate=False):
    c = f'contracts/{number}-risk.md'
    v = f'verdicts/critic/contracts-{number}-v1.md'
    (repo / c).write_text('# Risk subject\nКЛАСС ЗАДАЧИ: кодовый. КЛАСС РИСКА: '
                           + risk + '\n## Предмет\nRisk decision\n')
    must(git(repo, 'add', c), 'add candidate')
    must(git(repo, 'commit', '-qm', f'candidate {number}'), 'commit candidate')
    sha = must(git(repo, 'rev-parse', 'HEAD'), 'candidate sha')
    (repo / v).write_text('accept\nOBJECT=' + sha + '\n'
                           + (('СУД-КЛАССА-РИСКА: ' + marker + '\n') if marker else ''))
    must(git(repo, 'add', v), 'add verdict')
    must(git(repo, 'commit', '-qm', f'judge {number}'), 'commit verdict')
    if mutate:
        (repo / c).write_text((repo / c).read_text() + '\nChanged after accepted OBJECT\n')
        must(git(repo, 'add', c), 'add post-accept mutation')
        must(git(repo, 'commit', '-qm', 'post-accept mutation'), 'commit mutation')
    return c


def freeze(repo, c):
    return call(['bash', FREEZE, c, 'fixture risk review', repo], cwd=repo)


def main():
    errors = []
    with tempfile.TemporaryDirectory(prefix='risk164-legacy-') as temp:
        repo = Path(temp) / 'repo'
        init(repo)
        legacy = accepted(repo, '001', 'обычный', None)
        must(git(repo, 'tag', '-a', 'id/CONTRACT/001', '-m', 'issued'), 'tag legacy')
        control = freeze(repo, legacy)
        if control.returncode:
            errors.append('CONTROL_NOT_GREEN: ' + control.stdout + control.stderr)

    cases = (
        ('missing-164', '164', 'обычный', None, False, 1, 'JUDGMENT_MISSING'),
        ('honest-risk', '164', 'рисковый', 'рисковый', False, 0, ''),
        ('mismatch', '164', 'обычный', 'рисковый', False, 1, 'RISK_CLASS_MISMATCH'),
        ('post-accept', '164', 'обычный', 'обычный', True, 1, 'JUDGMENT_STALE'),
        ('missing-165', '165', 'обычный', None, False, 1, 'JUDGMENT_MISSING'),
    )
    for name, number, declared, judged, mutation, expected_rc, expected_reason in cases:
        with tempfile.TemporaryDirectory(prefix='risk164-' + name + '-') as temp:
            repo = Path(temp) / 'repo'
            init(repo)
            must(git(repo, 'tag', '-a', 'id/CONTRACT/164', '-m', 'issued'), 'tag anchor')
            if number != '164':
                (repo / 'marker').write_text('separate issuance\\n')
                must(git(repo, 'add', 'marker'), 'add later subject marker')
                must(git(repo, 'commit', '-qm', 'later issuance'), 'commit later issuance')
                must(git(repo, 'tag', '-a', f'id/CONTRACT/{number}', '-m', 'issued'), 'tag later')
            c = accepted(repo, number, declared, judged, mutation)
            before = must(git(repo, 'tag', '-l', f'frozen/contracts/{number}/*'), 'before tags')
            actual = freeze(repo, c)
            after = must(git(repo, 'tag', '-l', f'frozen/contracts/{number}/*'), 'after tags')
            text = actual.stdout + actual.stderr
            correct = (actual.returncode == expected_rc
                       and (not expected_reason or expected_reason in text)
                       and ((after == before) if expected_rc else (after != before)))
            if not correct:
                errors.append(f'{name}: FREEZE_BYPASS: rc={actual.returncode}, '
                              f'before={before!r}, after={after!r}; {text}')
            else:
                print(f'{name}: rc {actual.returncode},', expected_reason or 'frozen tag recorded')
    for error in errors:
        print(error)
    return 1 if errors else 0


if __name__ == '__main__':
    raise SystemExit(main())
