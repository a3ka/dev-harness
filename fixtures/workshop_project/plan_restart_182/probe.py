#!/usr/bin/env python3
"""Public CLI 182: published-plan state, startup brief, and independent decoys."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MODEL = HERE / 'model' / 'plan_slice.py'
SUBJECT = ROOT / 'scripts' / 'orch_plan_slice.sh'
BRIEF = ROOT / 'scripts' / 'make_task.sh'


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
    checked('git', '-C', str(repo), 'tag', 'done/contracts/147/99')  # unpushed tag
    expected = '\n'.join([
        f'PLAN_SNAPSHOT: origin/main={sha}',
        'PLAN: 147 | ROADMAP=3/до V-2 | STATUS=frozen | NEXT=сверить PR/вердикт, затем done',
        'PLAN: 148 | ROADMAP=3/до V-2 | STATUS=ПАУЗА | NEXT=после 147',
        'PLAN: 149 | ROADMAP=3/до V-2 | STATUS=done | NEXT=закрыто',
        'PLAN: 154 | ROADMAP=3/до V-2 | STATUS=черновик | NEXT=контракт → critic → freeze',
    ]) + '\n'
    return repo, expected


def patched_brief(tmp):
    scripts = tmp / 'model_scripts'
    scripts.mkdir()
    for sibling in (ROOT / 'scripts').iterdir():
        if sibling.name != 'make_task.sh':
            (scripts / sibling.name).symlink_to(sibling)
    source = BRIEF.read_text()
    old = '      die "брифинг: контракт без предмета: $cf"'
    assert source.count(old) == 1, 'brief baseline changed'
    source = source.replace(old, '      WORK_SEC="${WORK_SEC}WORK: ${cnum} :: БЕЗ_ПРЕДМЕТА (есть в plan.tsv)\n"')
    old = '  HEALTH_SEC="$(printf \'HEALTH: branch=%s dirty=%s\' "$HEALTH_BRANCH" "$HEALTH_DIRTY")"'
    assert source.count(old) == 1, 'brief health baseline changed'
    source = source.replace(old, old + f'\n  PLAN_SEC="$(python3 "{MODEL}" --repo "$REPO")" || die "PLAN_SOURCE_UNAVAILABLE"')
    old = '    printf \'=== HEALTH ===\\n%s\\n\' "$HEALTH_SEC"'
    assert source.count(old) == 1, 'brief output baseline changed'
    source = source.replace(old, old + '\n    printf \'=== PLAN_SNAPSHOT ===\\n%s\\n\' "$PLAN_SEC"')
    path = scripts / 'make_task.sh'
    path.write_text(source)
    path.chmod(0o755)
    return path


def brief_world(tmp):
    # Existing 095 world is the actual profile/trace grammar; this test does not change it.
    helper = ROOT / 'fixtures' / 'context_pack_095' / '_toy.sh'
    p = checked('bash', '-c', 'source "$1"; _t95_world restart182', 'fixture', str(helper))
    place = Path(p)
    repo = place / 'repo'
    (repo / 'contracts' / '154-brief.md').write_text(
        '# Контракт 154\n\n## Существующее\n\nНет предмета.\n')
    with (repo / 'registry' / 'plan.tsv').open('a') as f:
        f.write('154\t1\tдо V-2\t-\ttoy\ttrack\n')
    (repo / 'ROADMAP.md').write_text(
        '# ROADMAP\n<!-- BEGIN GENERATED PLAN -->\n'
        '| пара | id | этап | трек | зависит | источник |\n'
        '|---|---|---|---|---|---|\n'
        '| 1 | 777 | до V-2 | track | - | toy |\n'
        '| 1 | 888 | до V-2 | track | 777 | toy |\n'
        '| 1 | 154 | до V-2 | track | - | toy |\n'
        '<!-- END GENERATED PLAN -->\n')
    (repo / 'registry' / 'pauzy.tsv').write_text('')
    with (repo / 'registry' / 'contracts.tsv').open('a') as f:
        f.write('888 → ' + '0'*40 + '\n154 → ' + '0'*40 + '\n')
    # Toy 095 contains planned 888 but no 888 contract: intentional.
    checked('git', '-C', str(repo), 'add', '-A')
    checked('git', '-C', str(repo), '-c', 'user.name=architect',
            '-c', 'user.email=architect@dev-harness.local', 'commit', '-m', 'missing predmet')
    remote = Path(tempfile.mkdtemp(prefix='brief-remote-', dir=tmp))
    checked('git', 'init', '--bare', '--initial-branch=main', str(remote))
    checked('git', '-C', str(repo), 'remote', 'add', 'origin', str(remote))
    checked('git', '-C', str(repo), 'push', 'origin', 'main')
    checked('git', '-C', str(repo), 'fetch', 'origin', 'main')
    trace = place / 'trace.tsv'
    trace.write_text('orchestrator\tglm-4.7\tallowed\n')
    return place, repo, trace


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
            checked('git', '-C', str(bad_repo), 'show', 'HEAD:ROADMAP.md') + '\n')
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
        toy_place, toy, trace = brief_world(temp)
        try:
            candidate = patched_brief(temp) if args.model or args.stabs else target / 'scripts' / 'make_task.sh'
            out = run('bash', str(candidate), '--repo', str(toy), '--role', 'orchestrator',
                      '--kind', 'brief', '--model-trace', str(trace))
            expected_marker = 'WORK: 154 :: БЕЗ_ПРЕДМЕТА (есть в plan.tsv)'
            if out.returncode or expected_marker not in out.stdout.splitlines():
                errors.append('brief-marker')
                print(f'RED brief-marker: rc={out.returncode} {out.stderr.strip()[:180]}')
            else:
                print('GREEN brief-marker')
            toy_sha = checked('git', '-C', str(toy), 'rev-parse', 'origin/main')
            expected_section = [
                f'PLAN_SNAPSHOT: origin/main={toy_sha}',
                'PLAN: 777 | ROADMAP=1/до V-2 | STATUS=черновик | NEXT=контракт → critic → freeze',
                'PLAN: 888 | ROADMAP=1/до V-2 | STATUS=черновик | NEXT=контракт → critic → freeze',
                'PLAN: 154 | ROADMAP=1/до V-2 | STATUS=черновик | NEXT=контракт → critic → freeze',
            ]
            sections = out.stdout.split('=== PLAN_SNAPSHOT ===\n')
            actual_section = sections[1].split('===', 1)[0].strip().splitlines() if len(sections) == 2 else []
            if out.returncode or actual_section != expected_section:
                errors.append('brief-snapshot')
                print(f'RED brief-snapshot: rc={out.returncode} {out.stderr.strip()[:160]}')
            else:
                print('GREEN brief-snapshot')
            checked('git', '-C', str(toy), 'remote', 'remove', 'origin')
            missing = run('bash', str(candidate), '--repo', str(toy), '--role', 'orchestrator',
                          '--kind', 'brief', '--model-trace', str(trace))
            if missing.returncode != 1 or missing.stdout or 'PLAN_SOURCE_UNAVAILABLE' not in missing.stderr:
                errors.append('brief-no-source')
                print(f'RED brief-no-source: rc={missing.returncode} stdout={missing.stdout[:90]!r} {missing.stderr[:90]}')
            else:
                print('GREEN brief-no-source')
        finally:
            import shutil
            shutil.rmtree(toy_place)
        if args.stabs:
            # Each decoy is checked against its own distinguishing coordinate.
            mutations = {'handoff': 'no-stale', 'stale': 'no-stale',
                         'local': 'local-isolation', 'no-roadmap': 'roadmap'}
            caught = 0
            for mutation, cell in mutations.items():
                proc = run(sys.executable, str(MODEL), '--repo', str(repo), '--mutation', mutation)
                if proc.returncode != 0 or proc.stdout != expected:
                    caught += 1
                    print(f'STAB {mutation} caught: {cell}')
                else:
                    print(f'STAB {mutation} ZHIV: {cell}')
            # Active contract still dies, even though its other legacy contracts pass.
            toy_place, toy, trace = brief_world(temp)
            try:
                proc = run('bash', str(BRIEF), '--repo', str(toy), '--role',
                           'orchestrator', '--kind', 'brief', '--model-trace', str(trace))
                if proc.returncode or 'WORK: 154 :: БЕЗ_ПРЕДМЕТА (есть в plan.tsv)' not in proc.stdout.splitlines():
                    caught += 1
                    print('STAB brief-die caught: brief-marker')
                else:
                    print('STAB brief-die ZHIV: brief-marker')
            finally:
                shutil.rmtree(toy_place)
            print(f'STABS={len(mutations)+1} CAUGHT={caught}')
            return int(caught != len(mutations) + 1 or bool(errors))
        print(f'CELLS={count+4} GREEN={count+4-len(errors)}')
        return int(bool(errors))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, AssertionError) as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
