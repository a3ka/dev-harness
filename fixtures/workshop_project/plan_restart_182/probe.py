#!/usr/bin/env python3
"""Public CLI 182: published-plan state and independent decoys (v2: project mode)."""
import argparse
import json
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


# ── v2: проектный режим (182 v+1) ─────────────────────────────────────────────
# Профильный мир повторяет раскладку реальных проектов станции (Complior-*):
# harness.project.json в корне, workflowPaths → .harness/*, state .harness;
# корневая СТАНЦИОННАЯ раскладка (registry/plan.tsv, ROADMAP.md) присутствует и
# ОПУБЛИКОВАНА как согласованная приманка — станционный читатель (субъект без
# 182 v2, обманные мутации) успешно печатает её строки; честный проектный срез
# обязан читать только профильные пути.

PROJ_PLAN = (
    'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
    '301\t7\tдо W-1\t-\towner\tcomplior\n'
    '302\t7\tдо W-1\t301\towner\tcomplior\n'
    '303\t7\tдо W-1\t302\towner\tcomplior\n'
    '304\t7\tдо W-1\t303\towner\tcomplior\n')
PROJ_ROADMAP = (
    '# ROADMAP проекта\n<!-- BEGIN GENERATED PLAN -->\n'
    '| пара | id | этап | трек | зависит | источник |\n'
    '|---|---|---|---|---|---|\n'
    '| 7 | 301 | до W-1 | complior | - | owner |\n'
    '| 7 | 302 | до W-1 | complior | 301 | owner |\n'
    '| 7 | 303 | до W-1 | complior | 302 | owner |\n'
    '| 7 | 304 | до W-1 | complior | 303 | owner |\n'
    '<!-- END GENERATED PLAN -->\n')
DECOY_PLAN = (
    'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
    '147\t3\tдо V-2\t-\towner\tcomplior\n'
    '148\t3\tдо V-2\t147\towner\tcomplior\n')
DECOY_ROADMAP = (
    '# ROADMAP\n<!-- BEGIN GENERATED PLAN -->\n'
    '| пара | id | этап | трек | зависит | источник |\n'
    '|---|---|---|---|---|---|\n'
    '| 3 | 147 | до V-2 | complior | - | owner |\n'
    '| 3 | 148 | до V-2 | complior | 147 | owner |\n'
    '<!-- END GENERATED PLAN -->\n')


def profile_json(remote, registry='.harness/registry'):
    return json.dumps({
        'schemaVersion': 1,
        'repoId': 'Complior-toy',
        'language': 'bash',
        'projectLayer': {'version': '1', 'profilePath': '.harness/project-layer.json'},
        'workflowPaths': {
            'contracts': '.harness/contracts',
            'verdicts': '.harness/verdicts',
            'registry': registry,
            'fixtures': '.harness/fixtures',
            'state': '.harness',
        },
        'commands': {'test': 'true', 'build': 'true', 'typecheck': 'true', 'lint': 'true'},
        'git': {'canonicalRemote': str(remote)},
        'ci': {'workflow': '.github/workflows/toy.yml'},
        'barriers': {'mandatory': [], 'optional': []},
    }, ensure_ascii=False, indent=2) + '\n'


def commit(repo, message):
    checked('git', '-C', str(repo), 'add', '-A')
    checked('git', '-C', str(repo), '-c', 'user.name=architect',
            '-c', 'user.email=architect@dev-harness.local', 'commit', '-m', message)


def project_world(tmp, *, plan=True, pauzy=True, stale=False,
                  broken_profile=False, mismatch=False, drop_live_marker=False,
                  registry='.harness/registry', standard_decoy=False):
    """Одноразовый проектный мир: профиль + приманка корневой раскладки, всё опубликовано.

    registry — эффективный путь реестра из профиля (996 допускает и нестандартный,
    например '.harness/ledger'); standard_decoy — опубликованная согласованная
    приманка в стандартном '.harness/registry', расходящаяся паузой с честным
    источником: потеря результата резолвера даёт подмену содержания, не отказ."""
    remote = tmp / 'premote.git'
    repo = tmp / 'P'
    checked('git', 'init', '--bare', '--initial-branch=main', str(remote))
    checked('git', 'init', '--initial-branch=main', str(repo))
    checked('git', '-C', str(repo), 'remote', 'add', 'origin', str(remote))
    folders = ['.harness/contracts', '.harness/verdicts', registry,
               '.harness/fixtures', '.github/workflows', 'registry']
    if standard_decoy and registry != '.harness/registry':
        folders.append('.harness/registry')
    for folder in folders:
        (repo / folder).mkdir(parents=True)
    (repo / 'harness.project.json').write_text(profile_json(remote, registry=registry))
    (repo / '.harness' / 'project-layer.json').write_text(json.dumps({
        'schemaVersion': 1, 'version': '1',
        'projectId': 'complior-toy', 'workspaceId': 'Complior-toy'}) + '\n')
    (repo / '.github' / 'workflows' / 'toy.yml').write_text('name: toy\n')
    if plan:
        (repo / registry / 'plan.tsv').write_text(PROJ_PLAN)
    (repo / registry / 'contracts.tsv').write_text(
        ''.join(f'{num} → ' + '0'*40 + '\n' for num in (301, 302, 303, 304)))
    if pauzy:
        (repo / registry / 'pauzy.tsv').write_text(
            '303\t2026-11-16\towner\tпосле закрытия 302\n')
    (repo / '.harness' / 'ROADMAP.md').write_text(PROJ_ROADMAP)
    if standard_decoy and registry != '.harness/registry':
        # Приманка в СТАНДАРТНОМ пути: план и реестр — те же строки, пауза ДРУГАЯ —
        # подмена различима содержанием строки статуса, а не только отказом.
        (repo / '.harness' / 'registry' / 'plan.tsv').write_text(PROJ_PLAN)
        (repo / '.harness' / 'registry' / 'contracts.tsv').write_text(
            ''.join(f'{num} → ' + '0'*40 + '\n' for num in (301, 302, 303, 304)))
        (repo / '.harness' / 'registry' / 'pauzy.tsv').write_text(
            '304\t2026-11-16\towner\tпосле атаки-подмены реестра\n')
    # Корневая станционная приманка: согласованная и ОПУБЛИКОВАННАЯ.
    (repo / 'registry' / 'plan.tsv').write_text(DECOY_PLAN)
    (repo / 'ROADMAP.md').write_text(DECOY_ROADMAP)
    (repo / 'registry' / 'pauzy.tsv').write_text('148\t2026-11-10\towner\tпосле 147\n')
    (repo / 'registry' / 'contracts.tsv').write_text(
        ''.join(f'{num} → ' + '0'*40 + '\n' for num in (147, 148)))
    (repo / 'HANDOFF.md').write_text(
        '## ГДЕ МЫ\nЖДЁТ УТРА 301/302/303: /tmp/dev-harness-verify/old-artifact\n')
    commit(repo, 'project baseline')
    checked('git', '-C', str(repo), 'tag', 'frozen/contracts/302/1')
    checked('git', '-C', str(repo), 'tag', 'done/contracts/301/1')
    checked('git', '-C', str(repo), 'push', 'origin', 'main', '--tags')
    checked('git', '-C', str(repo), 'fetch', 'origin', 'main')
    if stale and plan:
        # Локальное (НЕопубликованное) расхождение профильного плана: оракул — опубликованное.
        (repo / registry / 'plan.tsv').write_text(
            (repo / registry / 'plan.tsv').read_text()
            .replace('301\t7\tдо W-1', '301\t9\tпосле W-1'))
        (repo / '.harness' / 'ROADMAP.md').write_text(
            (repo / '.harness' / 'ROADMAP.md').read_text()
            .replace('| 7 | 301 | до W-1 |', '| 9 | 301 | после W-1 |'))
        commit(repo, 'unpublished local project plan')
    checked('git', '-C', str(repo), 'tag', 'done/contracts/304/99')  # unpushed tag
    if broken_profile:
        (repo / 'harness.project.json').write_text(profile_json(remote, registry='../vneshne'))
        commit(repo, 'broken profile')
        checked('git', '-C', str(repo), 'push', 'origin', 'main')
        checked('git', '-C', str(repo), 'fetch', 'origin', 'main')
    if mismatch:
        # ОПУБЛИКОВАННОЕ расхождение профильного плана с generated-блоком профильного ROADMAP.
        (repo / registry / 'plan.tsv').write_text(
            (repo / registry / 'plan.tsv').read_text()
            .replace('303\t7\tдо W-1', '303\t7\tпересборка'))
        commit(repo, 'published project plan mismatch')
        checked('git', '-C', str(repo), 'push', 'origin', 'main')
        checked('git', '-C', str(repo), 'fetch', 'origin', 'main')
    if drop_live_marker:
        # Живой корень рассинхронизирован с опубликованным маркером (без коммита).
        (repo / 'harness.project.json').unlink()
    return repo


def project_expected(repo, *, pauzy=True):
    """Оракул в памяти проверяющего: снят ДО вызова субъекта, из published-состояния мира."""
    sha = checked('git', '-C', str(repo), 'rev-parse', 'origin/main')
    rows = [
        ('301', 'done', 'закрыто'),
        ('302', 'frozen', 'сверить PR/вердикт, затем done'),
        ('303', 'ПАУЗА', 'после закрытия 302') if pauzy
        else ('303', 'черновик', 'контракт → critic → freeze'),
        ('304', 'черновик', 'контракт → critic → freeze'),
    ]
    return '\n'.join([f'PLAN_SNAPSHOT: origin/main={sha}'] + [
        f'PLAN: {num} | ROADMAP=7/до W-1 | STATUS={status} | NEXT={nxt}'
        for num, status, nxt in rows]) + '\n'


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


def assess_project(command, expected, errors, pause_cell, prefix='proj-'):
    proc = run(*map(str, command))
    lines = proc.stdout.splitlines()
    reference = expected.splitlines()
    checks = {
        f'{prefix}published': lines[:1] == reference[:1],
        f'{prefix}done': len(lines) > 1 and lines[1] == reference[1],
        f'{prefix}frozen': len(lines) > 2 and lines[2] == reference[2],
        pause_cell: len(lines) > 3 and lines[3] == reference[3],
        f'{prefix}draft': len(lines) > 4 and lines[4] == reference[4],
        f'{prefix}no-decoy': not any(('147' in line or '148' in line or 'V-2' in line)
                                     for line in lines),
        f'{prefix}local-isolation': 'после W-1' not in proc.stdout
                                    and 'ROADMAP=9/' not in proc.stdout,
        f'{prefix}structural': proc.stdout == expected,
    }
    for label, matched in checks.items():
        if proc.returncode or not matched:
            errors.append(label)
            print(f'RED {label}: rc={proc.returncode} {proc.stderr.strip()[:160]}')
        else:
            print(f'GREEN {label}')
    return len(checks)


def assess_project_nopauzy(command, expected, errors):
    proc = run(*map(str, command))
    lines = proc.stdout.splitlines()
    reference = expected.splitlines()
    checks = {
        'proj-pauzy-optional': (len(lines) > 3 and lines[3] == reference[3]
                                and 'ПАУЗА' not in proc.stdout),
        'proj-no-decoy': not any(('147' in line or '148' in line or 'V-2' in line)
                                 for line in lines),
        'proj-no-pauzy-structural': proc.stdout == expected,
    }
    for label, matched in checks.items():
        if proc.returncode or not matched:
            errors.append(label)
            print(f'RED {label}: rc={proc.returncode} {proc.stderr.strip()[:160]}')
        else:
            print(f'GREEN {label}')
    return len(checks)


def origin_sha(repo):
    return checked('git', '-C', str(repo), 'rev-parse', 'origin/main')


def unavailable_prefix(sha):
    """Полный обязательный префикс отказного stderr И-7 (со снятым SHA)."""
    return ('PLAN_SOURCE_UNAVAILABLE: проектный режим '
            f'(harness.project.json на origin/main={sha}):')


def refusal_no_plan(repo, plan_rel='.harness/registry/plan.tsv'):
    """Оракул в памяти: честный отказ без плана — префикс, причина, названный выход."""
    sha = origin_sha(repo)
    return (unavailable_prefix(sha)
            + f' нет {plan_rel} на origin/main={sha}; станционный корневой реестр '
            f'не подменяет; выход: план проекта заводит владелец коммитом в {plan_rel} (996)')


def assess_refusal(command, errors, label, prefix, *fragments):
    proc = run(*map(str, command))
    err = proc.stderr.strip()
    ok = (proc.returncode == 1 and proc.stdout == ''
          and err.startswith(prefix)
          and all(fragment in err for fragment in fragments))
    if ok:
        print(f'GREEN {label}')
    else:
        errors.append(label)
        print(f'RED {label}: rc={proc.returncode} stdout={proc.stdout[:90]!r} '
              f'stderr={err[:160]!r}')
    return 1


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    # Baseline default targets this repository, not the disposable input world.
    target = args.repo.resolve() if args.repo else ROOT
    use_model = args.model or args.stabs

    def cli(repo):
        if use_model:
            return [sys.executable, MODEL, '--repo', repo]
        return ['bash', target / 'scripts' / 'orch_plan_slice.sh', '--repo', repo]

    with tempfile.TemporaryDirectory(prefix='plan-restart-182-') as work:
        temp = Path(work)
        repo, expected = world(temp)
        errors = []
        count = assess(cli(repo), expected, errors)
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
        bad_command = cli(bad_repo)
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
            command = cli(malformed_repo)
            result = run(*map(str, command))
            if result.returncode != 1 or result.stdout or 'PLAN_ROADMAP_RASHOZHDENIE' not in result.stderr:
                errors.append(label)
                print(f'RED {label}: rc={result.returncode} stdout={result.stdout[:90]!r} {result.stderr[:90]}')
            else:
                print(f'GREEN {label}')
        # ── v2: проектный режим ────────────────────────────────────────────────
        # Оракул каждого мира снимается в память ДО вызова субъекта (правило 8).
        proj_cells = 0
        happy_dir = temp / 'proj-happy'
        happy_dir.mkdir()
        proj_repo = project_world(happy_dir, plan=True, pauzy=True, stale=True)
        proj_exp = project_expected(proj_repo, pauzy=True)
        proj_cells += assess_project(cli(proj_repo), proj_exp, errors, 'proj-pause')
        nopauzy_dir = temp / 'proj-no-pauzy'
        nopauzy_dir.mkdir()
        np_repo = project_world(nopauzy_dir, plan=True, pauzy=False, stale=False)
        np_exp = project_expected(np_repo, pauzy=False)
        proj_cells += assess_project_nopauzy(cli(np_repo), np_exp, errors)
        noplan_dir = temp / 'proj-no-plan'
        noplan_dir.mkdir()
        noplan_repo = project_world(noplan_dir, plan=False, pauzy=True, stale=False)
        noplan_prefix = unavailable_prefix(origin_sha(noplan_repo))  # до вызова субъекта
        proj_cells += assess_refusal(
            cli(noplan_repo), errors, 'proj-no-plan-named',
            noplan_prefix, '.harness/registry/plan.tsv')
        proj_cells += assess_refusal(
            cli(noplan_repo), errors, 'proj-no-plan-exit', noplan_prefix,
            'выход: план проекта заводит владелец коммитом в .harness/registry/plan.tsv (996)')
        mismatch_dir = temp / 'proj-mismatch'
        mismatch_dir.mkdir()
        mismatch_repo = project_world(mismatch_dir, plan=True, pauzy=True, mismatch=True)
        proj_cells += assess_refusal(
            cli(mismatch_repo), errors, 'proj-mismatch', 'PLAN_ROADMAP_RASHOZHDENIE')
        broken_dir = temp / 'proj-broken-profile'
        broken_dir.mkdir()
        broken_repo = project_world(broken_dir, plan=True, pauzy=True, broken_profile=True)
        proj_cells += assess_refusal(
            cli(broken_repo), errors, 'proj-broken-profile',
            unavailable_prefix(origin_sha(broken_repo)),
            'выход: починить профиль проекта (996)')
        sync_dir = temp / 'proj-sync-marker'
        sync_dir.mkdir()
        sync_repo = project_world(sync_dir, plan=True, pauzy=True, drop_live_marker=True)
        proj_cells += assess_refusal(
            cli(sync_repo), errors, 'proj-sync-marker',
            unavailable_prefix(origin_sha(sync_repo)),
            'выход: синхронизировать корень')
        alt_dir = temp / 'proj-alt-registry'
        alt_dir.mkdir()
        # Нестандартный эффективный реестр (996) + согласованная приманка в стандартном
        # пути: потеря результата резолвера даёт подмену содержания, а не отказ (К-08).
        alt_repo = project_world(alt_dir, plan=True, pauzy=True, stale=True,
                                 registry='.harness/ledger', standard_decoy=True)
        alt_exp = project_expected(alt_repo, pauzy=True)
        proj_cells += assess_project(cli(alt_repo), alt_exp, errors,
                                     'proj-alt-pause', prefix='proj-alt-')
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
            # v2: обманы проектного режима — каждый на СВОЁМ различающем входе
            # (Н-39: привязка к ветви по коду модели, не по прозе контракта).
            proj_stabs = {
                # маркер проектного режима игнорируется → станционные пути → приманка
                'no-project-mode': ('happy', 'proj-structural'),
                # в проектном режиме читается корневая приманка вместо профильных путей
                'root-decoy': ('happy', 'proj-no-decoy'),
                # план/ROADMAP проекта читаются из живого дерева, а не с published SHA
                'local-profile-plan': ('happy', 'proj-local-isolation'),
                # отсутствующий профильный pauzy.tsv трактуется как отказ
                'pauzy-required': ('no-pauzy', 'proj-pauzy-optional'),
                # нет план-источника → молчаливое «нет пунктов» rc 0 вместо отказа
                'silent-empty': ('no-plan', 'proj-no-plan-named'),
                # нет профильного плана → откат на корневой реестр-приманку
                'station-fallback': ('no-plan', 'proj-no-plan-named'),
                # сверка план↔ROADMAP в проектном режиме пропущена
                'project-no-crosscheck': ('mismatch', 'proj-mismatch'),
                # отказ резолвера профиля смягчён откатом в корневую раскладку
                'resolver-fallback': ('broken-profile', 'proj-broken-profile'),
                # расхождение живого и опубликованного маркера смягчено корневой раскладкой
                'legacy-fallback': ('sync-marker', 'proj-sync-marker'),
                # результат резолвера отброшен: чтение захардкоженного стандартного пути
                'registry-hardcode': ('alt-registry', 'proj-alt-structural'),
                # полный префикс И-7 заменён расплывчатым отказом (мутация критика К-10)
                'vague-refusal': ('no-plan', 'proj-no-plan-named'),
                # названный выход удалён из отказа без плана (мутация критика К-10)
                'no-exit': ('no-plan', 'proj-no-plan-exit'),
            }
            # Миры стабов — по одному на класс входа; оракул снят в память до прогона.
            stab_worlds = {}
            for key, builder in (
                ('happy', lambda d: project_world(d, plan=True, pauzy=True, stale=True)),
                ('no-pauzy', lambda d: project_world(d, plan=True, pauzy=False, stale=False)),
                ('no-plan', lambda d: project_world(d, plan=False, pauzy=True, stale=False)),
                ('mismatch', lambda d: project_world(d, plan=True, pauzy=True, mismatch=True)),
                ('broken-profile', lambda d: project_world(d, plan=True, pauzy=True,
                                                           broken_profile=True)),
                ('sync-marker', lambda d: project_world(d, plan=True, pauzy=True,
                                                        drop_live_marker=True)),
                ('alt-registry', lambda d: project_world(d, plan=True, pauzy=True, stale=True,
                                                         registry='.harness/ledger',
                                                         standard_decoy=True)),
            ):
                d = temp / f'stabw-{key}'
                d.mkdir()
                stab_worlds[key] = builder(d)
            honest = {
                'happy': (0, project_expected(stab_worlds['happy'], pauzy=True), None),
                'no-pauzy': (0, project_expected(stab_worlds['no-pauzy'], pauzy=False), None),
                'no-plan': (1, '', refusal_no_plan(stab_worlds['no-plan'])),
                'mismatch': (1, '', None),
                'broken-profile': (1, '', None),
                'sync-marker': (1, '', None),
                'alt-registry': (0, project_expected(stab_worlds['alt-registry'], pauzy=True),
                                 None),
            }
            for mutation, (kind, cell) in proj_stabs.items():
                proc = run(sys.executable, str(MODEL), '--repo',
                           str(stab_worlds[kind]), '--mutation', mutation)
                rc, out, err = honest[kind]
                if (proc.returncode != rc or proc.stdout != out
                        or (err is not None and proc.stderr.strip() != err)):
                    caught += 1
                    print(f'STAB {mutation} caught: {cell}')
                else:
                    print(f'STAB {mutation} ZHIV: {cell}')
            total = len(mutations) + len(proj_stabs)
            print(f'STABS={total} CAUGHT={caught}')
            return int(caught != total or bool(errors))
        total_cells = count + 3 + proj_cells
        print(f'CELLS={total_cells} GREEN={total_cells-len(errors)}')
        return int(bool(errors))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, AssertionError) as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
