#!/usr/bin/env python3
"""Public-door red probe; the model and mutants run only on disposable project worlds."""
import csv
import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SEED = HERE / 'seed.tsv'
SPEC = importlib.util.spec_from_file_location('project_world_161', HERE.parent / 'proektnaja_raskladka_161/probe.py')
world_module = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(world_module)
World = world_module.World


def records():
    with SEED.open(encoding='utf-8', newline='') as source:
        return tuple(csv.DictReader(source, delimiter='\t'))


def emit(record):
    return 'NOTICE\t' + '\t'.join(record[key] for key in (
        'record_id', 'date', 'contract', 'affected_scripts', 'change', 'correct_invocation'))


def model(stage, ledger, used, acknowledged, changed=(), mutant=None, contract='161'):
    """Reference transition; values are captured before the subject is invoked."""
    if stage == 'brief':
        if not acknowledged.isascii() or not acknowledged.isdecimal():
            if mutant == 'ack_zero_default':
                acknowledged = '0'
            else:
                return 1, 'NOTICE_ACK_INVALID'
        if mutant == 'empty_brief':
            return 0, ''
        if mutant == 'all_projects':
            used = {script for row in ledger for script in row['affected_scripts'].split(',')}
        if mutant == 'all_old':
            acknowledged = '0'
        pending = [row for row in ledger if int(row['record_id']) > int(acknowledged)
                   and used.intersection(row['affected_scripts'].split(','))]
        if mutant == 'last_only':
            pending = pending[-1:]
        if mutant == 'truncated':
            return 0, '\n'.join('NOTICE\t' + row['record_id'] for row in pending)
        return 0, '\n'.join(map(emit, pending))
    if mutant == 'allow_missing':
        return 0, ''
    if mutant == 'done_only' and stage == 'land':
        return 0, ''
    if mutant == 'land_only' and stage == 'done':
        return 0, ''
    changed_used = used.intersection(changed)
    covered = {script for row in ledger if row['contract'] == contract
               for script in row['affected_scripts'].split(',')}
    if changed_used - covered:
        return 1, 'MECHANISM_NOTICE_MISSING:' + sorted(changed_used - covered)[0]
    return 0, ''


def check(label, actual, wanted, failures):
    if actual != wanted:
        failures.append(f'{label} KRASNO: got={actual!r} expected={wanted!r}')
    else:
        print(f'{label} ok')


def honest(ledger, failures):
    used = {'scripts/make_task.sh', 'scripts/spawn_agent.sh'}
    first, second, third = ledger
    cases = (
        ('BRIEF pending', 'brief', ledger, used, '0', (), (0, emit(first) + '\n' + emit(second))),
        ('BRIEF acknowledged', 'brief', ledger, used, '1', (), (0, emit(second))),
        ('BRIEF isolated', 'brief', ledger, {'scripts/gitw'}, '0', (), (0, '')),
        ('BRIEF third project', 'brief', ledger, {'scripts/zamok_predmeta.sh'}, '0', (),
         (0, emit(third))),
        ('BRIEF malformed ack', 'brief', ledger, used, 'invalid', (),
         (1, 'NOTICE_ACK_INVALID')),
        ('LAND covered', 'land', ledger, used, '0', ('scripts/make_task.sh',), (0, '')),
        ('LAND missing', 'land', (second, third), used, '0', ('scripts/spawn_agent.sh',),
         (1, 'MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh')),
        ('DONE missing', 'done', (second, third), used, '0', ('scripts/spawn_agent.sh',),
         (1, 'MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh')),
        ('LAND unrelated', 'land', ledger, used, '0', ('scripts/gitw',), (0, '')),
    )
    for label, stage, rows, scripts, ack, changed, expected in cases:
        check(label, model(stage, rows, scripts, ack, changed), expected, failures)


def stabs(ledger, failures):
    used = {'scripts/make_task.sh', 'scripts/spawn_agent.sh'}
    absent = tuple(row for row in ledger if row['contract'] != '161')
    cases = (
        ('empty_brief', 'brief', ledger, used, '0', (), 'empty_brief'),
        ('all_old', 'brief', ledger, used, '1', (), 'all_old'),
        ('all_projects', 'brief', ledger, {'scripts/zamok_predmeta.sh'}, '0', (), 'all_projects'),
        ('last_only', 'brief', ledger, used, '0', (), 'last_only'),
        ('ack_zero_default', 'brief', ledger, used, 'invalid', (), 'ack_zero_default'),
        ('truncated', 'brief', ledger, used, '0', (), 'truncated'),
        ('allow_missing', 'land', absent, used, '0', ('scripts/spawn_agent.sh',), 'allow_missing'),
        ('done_only', 'land', absent, used, '0', ('scripts/spawn_agent.sh',), 'done_only'),
        ('land_only', 'done', absent, used, '0', ('scripts/spawn_agent.sh',), 'land_only'),
    )
    for name, stage, rows, scripts, ack, changed, mutant in cases:
        reference = model(stage, rows, scripts, ack, changed)
        wrong = model(stage, rows, scripts, ack, changed, mutant)
        if wrong == reference:
            failures.append(f'STAB_ZHIV {name}: {stage} input did not distinguish mutant')
        else:
            print(f'STAB {name} caught: {stage}')


def invoke(*command, env):
    return subprocess.run(tuple(map(str, command)), text=True, capture_output=True,
                          env=env, check=False)


def real_world(ledger, failures):
    # World 161 uses the same real two-layer profile and bare-origin as the project doors.
    with tempfile.TemporaryDirectory(prefix='fixture-168-') as temp:
        world = World(Path(temp), 'notification-project')
        env = dict(world.env, HARNESS_PROJECT_LAYER_ROOT=str(world.main))
        world.put('.harness/registry/trace.tsv',
                  'architect\topenai-codex/gpt-6-sol\tdenied\n'
                  'orchestrator\topenai-codex/gpt-6-sol\tdenied\n')
        world.put('.harness/registry/mechanisms.tsv',
                  'script\nscripts/make_task.sh\nscripts/spawn_agent.sh\n')
        world.put('.harness/registry/mechanism-notices.ack', '0\n')
        world.git('add', '-A')
        world.git('commit', '-qm', 'project notice inputs')
        # The oracle was loaded into memory before any subject invocation.
        # Compare complete standalone rows inside one bounded section.
        def check_live_brief(project, expected_rows, label):
            project_env = dict(project.env, HARNESS_PROJECT_LAYER_ROOT=str(project.main))
            result = invoke('bash', ROOT / 'scripts/make_task.sh', '--repo', project.main,
                            '--role', 'orchestrator', '--kind', 'brief', env=project_env)
            section = result.stdout.split('=== NOTICES ===\n', 1)
            bounded = len(section) == 2 and '=== END NOTICES ===' in section[1]
            lines = section[1].split('=== END NOTICES ===', 1)[0].splitlines() if bounded else []
            expected = [emit(row) for row in expected_rows]
            if result.returncode != 0 or not bounded or lines != expected:
                failures.append(label + ': rc=' + str(result.returncode)
                                + ' stderr=' + result.stderr.strip()[:150]
                                + ' rows=' + str(lines)[:150]
                                + ' expected=' + str(expected)[:150])
            else:
                print(label + ' ok')

        check_live_brief(world, ledger[:2], 'BRIEF_NOTICES_MISSING')
        world.put('.harness/registry/mechanism-notices.ack', '1\n')
        check_live_brief(world, ledger[1:2], 'BRIEF_ACK_WRONG')
        world.put('.harness/registry/mechanism-notices.ack', '3\n')
        check_live_brief(world, (), 'BRIEF_ACK_LATEST_WRONG')
        world.put('.harness/registry/mechanism-notices.ack', 'invalid\n')
        invalid = invoke('bash', ROOT / 'scripts/make_task.sh', '--repo', world.main,
                         '--role', 'orchestrator', '--kind', 'brief', env=env)
        if invalid.returncode != 1 or 'NOTICE_ACK_INVALID' not in invalid.stderr or invalid.stdout:
            failures.append('BRIEF_ACK_INVALID_ACCEPTED: rc=' + str(invalid.returncode)
                            + ' stderr=' + invalid.stderr.strip()[:150])
        world.put('.harness/registry/mechanism-notices.ack', '0\n')
        other = World(Path(temp), 'notification-other')
        other.put('.harness/registry/trace.tsv',
                  'architect\topenai-codex/gpt-6-sol\tdenied\n'
                  'orchestrator\topenai-codex/gpt-6-sol\tdenied\n')
        other.put('.harness/registry/mechanisms.tsv', 'script\nscripts/zamok_predmeta.sh\n')
        other.put('.harness/registry/mechanism-notices.ack', '0\n')
        check_live_brief(other, ledger[2:3], 'BRIEF_PROJECT_ISOLATION_WRONG')
        # Public writers are tested independently on disposable Git branches;
        # a red brief cannot hide publication failures.
        world.put('.harness/contracts/761-notice.md',
                  '# Контракт 761\n## Существующее\n- project\n## Предмет\n- change\n'
                  'ЗОНА implementer: scripts/spawn_agent.sh\n'
                  'ПРОВОДКА:\n- guard=scripts/spawn_agent.sh\n'
                  'ПРОВОДКА-ЭНФОРСМЕНТ: проверка скрипта без ролевой нормы.\n'
                  '## Незаполненные требования:\nнет\n')
        world.git('add', '-A')
        world.git('commit', '-qm', 'baseline contract for notice publication')
        world.git('tag', '-a', 'frozen/contracts/761/1', '-m', 'frozen baseline')
        draft_script = world.draft / 'scripts/spawn_agent.sh'
        draft_script.parent.mkdir(parents=True, exist_ok=True)
        draft_script.write_text('#!/bin/sh\nprintf changed\n', encoding='utf-8')
        world.git('add', '-A', where=world.draft)
        world.git('commit', '-qm', 'change shared mechanism without notice', where=world.draft)
        world.put('.harness/verdicts/review/contracts-761-impl.md', 'accept\n')
        world.git('add', '-A')
        world.git('commit', '-qm', 'reviewed candidate')
        before = world.snapshot()
        land = invoke('bash', ROOT / 'scripts/land_project.sh', '--repo', world.main,
                      '--branch', 'wip/759/architect', env=env)
        if land.returncode != 1 or 'MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh' not in land.stderr:
            failures.append('LAND_WRITER_NOT_GATED: rc=' + str(land.returncode)
                            + ' stderr=' + land.stderr.strip()[:150])
        if world.snapshot() != before:
            failures.append('LAND_WRITER_MUTATED_MAIN')
        world.put('scripts/spawn_agent.sh', '#!/bin/sh\nprintf changed\n')
        world.git('add', '-A')
        world.git('commit', '-qm', 'main change shared mechanism without notice')
        before_done = world.snapshot()
        done = invoke('bash', ROOT / 'scripts/done_contract.sh',
                      '.harness/contracts/761-notice.md', 'fixture note', world.main, env=env)
        if done.returncode != 1 or 'MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh' not in done.stderr:
            failures.append('DONE_WRITER_NOT_GATED: rc=' + str(done.returncode)
                            + ' stderr=' + done.stderr.strip()[:150])
        if world.snapshot() != before_done:
            failures.append('DONE_WRITER_MUTATED_MAIN')
        tag = world.git('tag', '-l', 'done/contracts/761/*')
        if tag.stdout.strip():
            failures.append('DONE_WRITER_CREATED_TAG')
        station_world = World(Path(temp), 'station-writer')
        station_world.put('registry/project-mechanisms.tsv',
                          'projectId\tscript\nnotification-project\tscripts/spawn_agent.sh\n')
        station_world.put('registry/mechanism-changes.tsv',
                          SEED.read_text(encoding='utf-8'))
        station_world.put('scripts/spawn_agent.sh', '#!/bin/sh\nprintf baseline\n')
        station_world.put('.harness/contracts/168-notice.md',
                          '# Контракт 168\n## Предмет\n- test\n'
                          'ЗОНА implementer: scripts/spawn_agent.sh\n'
                          'ПРОВОДКА:\n- guard=scripts/spawn_agent.sh\n'
                          'ПРОВОДКА-ЭНФОРСМЕНТ: механический guard.\n'
                          '## Незаполненные требования:\nнет\n')
        station_world.git('add', '-A')
        station_world.git('commit', '-qm', 'station baseline')
        station_world.git('tag', '-a', 'frozen/contracts/168/1', '-m', 'station frozen')
        station_wt = Path(temp) / 'station-candidate'
        station_world.git('worktree', 'add', '-q', '-b', 'wip/168/implementer', station_wt)
        (station_wt / 'scripts/spawn_agent.sh').write_text(
            '#!/bin/sh\nprintf changed\n', encoding='utf-8')
        station_world.git('add', '-A', where=station_wt)
        candidate_commit = invoke(
            'git', '-C', station_wt, '-c', 'user.name=implementer',
            '-c', 'user.email=implementer@dev-harness.local', 'commit', '-qm',
            'modify shared script without record', env=station_world.env)
        if candidate_commit.returncode:
            failures.append('STATION_CANDIDATE_INVALID: ' + candidate_commit.stderr.strip())
        station_before = station_world.snapshot()
        station_land = invoke('bash', ROOT / 'scripts/land_agent.sh', '--root',
                              station_world.main, '--branch', 'wip/168/implementer',
                              '--worktree', station_wt, env=station_world.env)
        if station_land.returncode != 1 or 'MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh' not in (
                station_land.stderr + station_land.stdout):
            failures.append('STATION_LAND_WRITER_NOT_GATED: rc=' + str(station_land.returncode)
                            + ' stderr=' + station_land.stderr.strip()[:150])
        if station_world.snapshot() != station_before:
            failures.append('STATION_LAND_WRITER_MUTATED_MAIN')
        if station_land.returncode == 1 and (
                'MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh' in (
                    station_land.stderr + station_land.stdout)):
            # Positive twin uses the same Git candidate. Only the new station
            # record changes; no cherry-pick or rewritten candidate can explain green.
            ledger_path = station_world.main / 'registry/mechanism-changes.tsv'
            ledger_path.write_text(
                ledger_path.read_text(encoding='utf-8')
                + '4\t2026-11-08\t168\tscripts/spawn_agent.sh'
                  '\tИзменение общего запуска подтверждено'
                  '\tbash scripts/spawn_agent.sh --root <project-main>\n',
                encoding='utf-8')
            station_world.git('add', 'registry/mechanism-changes.tsv')
            station_world.git('commit', '-qm', 'register mechanism change')
            admitted = invoke('bash', ROOT / 'scripts/land_agent.sh', '--root',
                              station_world.main, '--branch', 'wip/168/implementer',
                              '--worktree', station_wt, env=station_world.env)
            if admitted.returncode != 0 or 'LANDED main=' not in admitted.stdout:
                failures.append('STATION_LAND_RECORDED_REFUSED: rc='
                                + str(admitted.returncode)
                                + ' stderr=' + admitted.stderr.strip()[:150])


def main():
    args = sys.argv[1:]
    if len(args) != 1 or args[0] not in ('--repo', '--model', '--stabs'):
        print('usage: probe.py --repo|--model|--stabs', file=sys.stderr)
        return 2
    ledger = records()
    failures = []
    if args[0] == '--model':
        honest(ledger, failures)
    elif args[0] == '--stabs':
        honest(ledger, failures)
        stabs(ledger, failures)
    else:
        real_world(ledger, failures)
    for message in failures:
        print(message, file=sys.stderr)
    return int(bool(failures))


if __name__ == '__main__':
    sys.exit(main())
