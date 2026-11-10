#!/usr/bin/env python3
"""Public CLI 182: published-plan state and independent decoys."""
import argparse
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MODEL = HERE / 'model' / 'plan_slice.py'
SUBJECT = ROOT / 'scripts' / 'orch_plan_slice.sh'


def run(*args, cwd=None):
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True)


def checked(*args, cwd=None):
    p = run(*args, cwd=cwd)
    if p.returncode:
        raise RuntimeError(f'infra {args[0]}: {p.stderr.strip()}')
    return p.stdout.strip()


def world(tmp):
    remote = tmp / 'remote.git'
    repo = tmp / 'R'
    checked('git', 'init', '--bare', '--initial-branch=main', str(remote))
    checked('git', 'init', '--initial-branch=main', str(repo))
    checked('git', '-C', str(repo), 'remote', 'add', 'origin', str(remote))
    for folder in ('registry', 'contracts'):
        (repo / folder).mkdir()
    (repo / 'registry' / 'plan.tsv').write_text(
        'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
        '147\t3\tдо V-2\t-\towner\tcomplior\n'
        '148\t3\tдо V-2\t147\towner\tcomplior\n'
        '149\t3\tдо V-2\t148\towner\tcomplior\n'
        '154\t3\tдо V-2\t-\towner\tautonomy\n')
    (repo / 'ROADMAP.md').write_text(
        '# ROADMAP\n<!-- BEGIN GENERATED PLAN -->\n'
        '| пара | id | этап | трек | зависит | источник |\n'
        '|---|---|---|---|---|---|\n'
        '| 3 | 147 | до V-2 | complior | - | owner |\n'
        '| 3 | 148 | до V-2 | complior | 147 | owner |\n'
        '| 3 | 149 | до V-2 | complior | 148 | owner |\n'
        '| 3 | 154 | до V-2 | autonomy | - | owner |\n'
        '<!-- END GENERATED PLAN -->\n')
    (repo / 'registry' / 'pauzy.tsv').write_text('148\t2026-11-10\towner\tпосле 147\n')
    (repo / 'registry' / 'contracts.tsv').write_text(
        ''.join(f'{num} → ' + '0'*40 + '\n' for num in (147, 148, 149, 154)))
    (repo / 'contracts' / '154-brief.md').write_text(
        '# Контракт 154\n\n## Существующее\n\nТекст без секции предмета.\n')
    (repo / 'HANDOFF.md').write_text('## ГДЕ МЫ\nЖДЁТ УТРА 147/148/149: /tmp/dev-harness-verify/old-artifact\n')
    checked('git', '-C', str(repo), 'add', '-A')
    checked('git', '-C', str(repo), '-c', 'user.name=architect',
            '-c', 'user.email=architect@dev-harness.local', 'commit', '-m', 'origin baseline')
    checked('git', '-C', str(repo), 'tag', 'frozen/contracts/147/1')
    checked('git', '-C', str(repo), 'tag', 'done/contracts/149/1')
    checked('git', '-C', str(repo), 'push', 'origin', 'main', '--tags')
    checked('git', '-C', str(repo), 'fetch', 'origin', 'main')
    sha = checked('git', '-C', str(repo), 'rev-parse', 'origin/main')
    # Local-only disagreement is an actual mutation of tracked files, never the oracle.
    (repo / 'registry' / 'plan.tsv').write_text(
        (repo / 'registry' / 'plan.tsv').read_text().replace('147\t3\tдо V-2', '147\t9\tпосле V-2'))
    (repo / 'ROADMAP.md').write_text(
        (repo / 'ROADMAP.md').read_text().replace('| 3 | 147 | до V-2 |', '| 9 | 147 | после V-2 |'))
    checked('git', '-C', str(repo), 'add', 'registry/plan.tsv', 'ROADMAP.md')
    checked('git', '-C', str(repo), '-c', 'user.name=architect',
            '-c', 'user.email=architect@dev-harness.local', 'commit', '-m', 'unpublished local plan')
    checked('git', '-C', str(repo), 'tag', 'done/contracts/147/99')  # unpushed tag
    expected = '\n'.join([
        f'PLAN_SNAPSHOT: origin/main={sha}',
        'PLAN: 147 | ROADMAP=3/до V-2 | STATUS=frozen | NEXT=сверить PR/вердикт, затем done',
        'PLAN: 148 | ROADMAP=3/до V-2 | STATUS=ПАУЗА | NEXT=после 147',
        'PLAN: 149 | ROADMAP=3/до V-2 | STATUS=done | NEXT=закрыто',
        'PLAN: 154 | ROADMAP=3/до V-2 | STATUS=черновик | NEXT=контракт → critic → freeze',
    ]) + '\n'
    return repo, expected




def assess(command, expected, errors):
    proc = run(*map(str, command))
    lines = proc.stdout.splitlines()
    reference = expected.splitlines()
    checks = {
        'published': lines[:1] == reference[:1],
        'frozen': len(lines) > 1 and lines[1] == reference[1],
        'pause': len(lines) > 2 and lines[2] == reference[2],
        'done': len(lines) > 3 and lines[3] == reference[3],
        'roadmap': len(lines) > 4 and lines[4] == reference[4],
        'no-stale': not any('ЖДЁТ УТРА' in line for line in lines),
        'local-isolation': 'ROADMAP=9/после V-2' not in proc.stdout,
        'structural': proc.stdout == expected,
    }
    for label, matched in checks.items():
        if proc.returncode or not matched:
            errors.append(label)
            print(f'RED {label}: rc={proc.returncode} {proc.stderr.strip()[:160]}')
        else:
            print(f'GREEN {label}')
    return len(checks)


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    # Baseline default targets this repository, not the disposable input world.
    target = args.repo.resolve() if args.repo else ROOT
    with tempfile.TemporaryDirectory(prefix='plan-restart-182-') as work:
        temp = Path(work)
        repo, expected = world(temp)
        errors = []
        command = [sys.executable, MODEL, '--repo', repo] if args.model or args.stabs else [
            'bash', target / 'scripts' / 'orch_plan_slice.sh', '--repo', repo]
        count = assess(command, expected, errors)
        bad = temp / 'bad'
        bad.mkdir()
        bad_repo, _ = world(bad)
        (bad_repo / 'ROADMAP.md').write_text(
            checked('git', '-C', str(bad_repo), 'show', 'origin/main:ROADMAP.md') + '\n')
        checked('git', '-C', str(bad_repo), 'add', 'registry/plan.tsv', 'ROADMAP.md')
        checked('git', '-C', str(bad_repo), '-c', 'user.name=architect',
                '-c', 'user.email=architect@dev-harness.local', 'commit', '-m', 'mismatch')
        checked('git', '-C', str(bad_repo), 'push', 'origin', 'main')
        checked('git', '-C', str(bad_repo), 'fetch', 'origin', 'main')
        bad_command = [sys.executable, MODEL, '--repo', bad_repo] if args.model or args.stabs else [
            'bash', target / 'scripts' / 'orch_plan_slice.sh', '--repo', bad_repo]
        fail = run(*map(str, bad_command))
        if fail.returncode != 1 or fail.stdout or 'PLAN_ROADMAP_RASHOZHDENIE' not in fail.stderr:
            errors.append('source-mismatch')
            print(f'RED source-mismatch: rc={fail.returncode} stdout={fail.stdout[:90]!r} {fail.stderr[:90]}')
        else:
            print('GREEN source-mismatch')
        # Both malformed published ROADMAPs must reject before emitting any plan rows.
        # Each world is a separate public CLI invocation, not a combined first-red case.
        for label, published_roadmap in (
            ('missing-generated-block',
             '# ROADMAP\n| пара | id | этап | трек | зависит | источник |\n'
             '|---|---|---|---|---|---|\n'
             '| 3 | 147 | до V-2 | complior | - | owner |\n'
             '| 3 | 148 | до V-2 | complior | 147 | owner |\n'
             '| 3 | 149 | до V-2 | complior | 148 | owner |\n'
             '| 3 | 154 | до V-2 | autonomy | - | owner |\n'),
            ('outside-generated-block',
             '# ROADMAP\n| пара | id | этап | трек | зависит | источник |\n'
             '|---|---|---|---|---|---|\n'
             '| 3 | 154 | до V-2 | autonomy | - | owner |\n'
             '<!-- BEGIN GENERATED PLAN -->\n'
             '| пара | id | этап | трек | зависит | источник |\n'
             '|---|---|---|---|---|---|\n'
             '| 3 | 147 | до V-2 | complior | - | owner |\n'
             '| 3 | 148 | до V-2 | complior | 147 | owner |\n'
             '| 3 | 149 | до V-2 | complior | 148 | owner |\n'
             '<!-- END GENERATED PLAN -->\n'),
        ):
            malformed = temp / label
            malformed.mkdir()
            malformed_repo, _ = world(malformed)
            (malformed_repo / 'registry' / 'plan.tsv').write_text(
                checked('git', '-C', str(malformed_repo), 'show', 'origin/main:registry/plan.tsv') + '\n')
            (malformed_repo / 'ROADMAP.md').write_text(published_roadmap)
            checked('git', '-C', str(malformed_repo), 'add', 'ROADMAP.md', 'registry/plan.tsv')
            checked('git', '-C', str(malformed_repo), '-c', 'user.name=architect',
                    '-c', 'user.email=architect@dev-harness.local', 'commit', '-m', label)
            checked('git', '-C', str(malformed_repo), 'push', 'origin', 'main')
            checked('git', '-C', str(malformed_repo), 'fetch', 'origin', 'main')
            command = [sys.executable, MODEL, '--repo', malformed_repo] if args.model or args.stabs else [
                'bash', target / 'scripts' / 'orch_plan_slice.sh', '--repo', malformed_repo]
            result = run(*map(str, command))
            if result.returncode != 1 or result.stdout or 'PLAN_ROADMAP_RASHOZHDENIE' not in result.stderr:
                errors.append(label)
                print(f'RED {label}: rc={result.returncode} stdout={result.stdout[:90]!r} {result.stderr[:90]}')
            else:
                print(f'GREEN {label}')
        if args.stabs:
            # Each decoy is checked against its own distinguishing coordinate.
            mutations = {'handoff': 'no-stale', 'stale': 'no-stale',
                         'local': 'local-isolation', 'no-roadmap': 'roadmap',
                         'head': 'published'}
            caught = 0
            for mutation, cell in mutations.items():
                proc = run(sys.executable, str(MODEL), '--repo', str(repo), '--mutation', mutation)
                if proc.returncode != 0 or proc.stdout != expected:
                    caught += 1
                    print(f'STAB {mutation} caught: {cell}')
                else:
                    print(f'STAB {mutation} ZHIV: {cell}')
            print(f'STABS={len(mutations)} CAUGHT={caught}')
            return int(caught != len(mutations) or bool(errors))
        print(f'CELLS={count+3} GREEN={count+3-len(errors)}')
        return int(bool(errors))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, AssertionError) as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
