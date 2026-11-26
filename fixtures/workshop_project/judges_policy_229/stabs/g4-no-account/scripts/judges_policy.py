#!/usr/bin/env python3
"""Reference implementation, not an oracle: policy validation and CLI adapters.

The lock retains ownership/atomicity/OBJECT checks. This module supplies data and
accounting only. A request for arbitration is not an accept or a model invocation.
"""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys

INSTALL = Path(__file__).resolve().parents[1]


def load_config():
    return json.loads((INSTALL / 'config/judges-policy.json').read_bytes())


def validate(value):
    if value == 'station':
        value = load_config()['defaults']
    from jsonschema import Draft202012Validator
    Draft202012Validator(load_config()['schema']).validate(value)
    return value


def policy(repo):
    if not (repo / 'harness.project.json').exists():
        return None
    result = subprocess.run(['bash', str(INSTALL / 'scripts/profile_resolver.sh'),
                             '--repo', str(repo)], capture_output=True,
                            env={**os.environ, 'HARNESS_PROJECT_LAYER_ROOT':
                                 os.environ.get('HARNESS_PROJECT_LAYER_ROOT', str(repo))})
    if result.returncode:
        raise ValueError(result.stderr.decode(errors='replace'))
    merged = json.loads(result.stdout)
    value = merged.get('judges.policy', {}).get('value')
    return None if value is None else validate(value)


def rounds(ledger, repo_id, subject, role, obj):
    starts = []
    for row in (json.loads(line) for line in ledger.read_bytes().splitlines() if line):
        if row.get('repoId') != repo_id or row.get('subjectId') != subject:
            continue
        if row.get('t') == 'START':
            starts.append({**row, 'state': 'open'})
        elif row.get('t') == 'RELEASE':
            for start in reversed(starts):
                if start['holder'] == row.get('holder') and start['state'] == 'open':
                    start['state'] = row.get('prichina')
                    break
    return [s for s in starts if s.get('klass') == 'sudja' and
            s.get('rol') == role and (obj is None or s.get('object') == obj)]


def accounting(args):
    value = policy(Path(args.repo))
    if value is None:
        print('legacy')
        return 0
    states = rounds(Path(args.ledger), args.repo_id, args.subject, args.role, args.object)
    interruptions = sum(s['state'] == 'obryv_bez_verdikta' for s in states)
    environment = sum(s['state'] == 'blok_sredy' for s in states)
    # Two retries means initial + two subsequent attempts; after three failures,
    # request arbitration. Independent causes do not erase the other counter.
    if args.phase == 'spawn' and (interruptions > value['interruptionRetries'] or environment > value['environmentRetries']):
        print('ARBITRATION_REQUIRED' if value['onExhaustion'] == 'arbiter' else 'BUDGET_EXHAUSTED')
        return 0
    phase = rounds(Path(args.ledger), args.repo_id, args.subject, args.role, None)
    substantive = sum(s['state'] == 'verdikt_zakommiten' for s in phase)
    if args.phase == 'freeze':
        substantive += sum(s['state'] == 'open' for s in phase)
    limit = value.get(args.role + 'Calls')
    if limit is not None and substantive + (args.phase == 'spawn') > limit:
        action = 'ARBITRATION_REQUIRED'
        record = {'t': 'JUDGES_POLICY_WARNING', 'repoId': args.repo_id,
                  'subjectId': args.subject, 'rol': args.role, 'object': args.object,
                  'limit': limit, 'fact': substantive, 'phase': args.phase, 'action': action}
        with Path(args.ledger).open('a') as stream:
            pass
        message = (f'{action} repo={args.repo_id} subject={args.subject} role={args.role} '
                   f'object={args.object} limit={limit} fact={substantive} phase={args.phase}')
        print('ПРЕДУПРЕЖДЕНИЕ: ' + message, file=sys.stderr)
        print('WARNING ' + message)
    else:
        print('retry')
    return 0


def setup(args):
    repo = Path(args.repo).resolve(strict=True)
    value = policy(repo)
    if value is None:
        raise ValueError('JUDGE_POLICY_REQUIRED')
    if not re.fullmatch(r'[0-9]{3}', args.subject) or not re.fullmatch(r'[0-9a-f]{40}', args.object):
        raise ValueError('JUDGE_SETUP_INPUT')
    if args.role not in ('critic', 'adversary', 'reviewer', 'arbiter'):
        raise ValueError('JUDGE_SETUP_INPUT')
    def git(*argv):
        return subprocess.run(['git', '-C', str(repo), *argv], check=True,
                              capture_output=True).stdout.decode().strip()
    if git('rev-parse', 'HEAD') != args.object:
        raise ValueError('JUDGE_OBJECT_MISMATCH')
    if git('symbolic-ref', '--short', 'HEAD') != f'wip/{args.subject}/{args.role}':
        raise ValueError('JUDGE_BRANCH_MISMATCH')
    scratch = repo / 'tmp/j'
    if not scratch.resolve().is_relative_to(repo):
        raise ValueError('JUDGE_SCRATCH_OUTSIDE')
    scratch.mkdir(parents=True, exist_ok=True)
    merged_run = subprocess.run(['bash', str(INSTALL / 'scripts/profile_resolver.sh'),
                                '--repo', str(repo)], capture_output=True,
                               env={**os.environ, 'HARNESS_PROJECT_LAYER_ROOT': str(repo)})
    if merged_run.returncode:
        raise ValueError('JUDGE_PROFILE')
    merged = json.loads(merged_run.stdout)
    hook = merged.get('hooks.judgeSetup', {}).get('value', [])
    env = {**os.environ, 'JUDGE_SCRATCH': str(scratch), 'HARNESS_HEAD': args.object,
           'HARNESS_CONTRACT': args.subject, 'HARNESS_STAGE': 'judgeSetup'}
    if hook:
        done = subprocess.run(hook, cwd=repo, env=env, capture_output=True)
        if done.returncode:
            sys.stderr.buffer.write(done.stderr)
            print(f'БЛОК-СРЕДЫ: hooks.judgeSetup rc={done.returncode}', file=sys.stderr)
            return 2
    print(f'OBJECT={args.object}\nJUDGE_SCRATCH={scratch}\nJUDGE_BRANCH=wip/{args.subject}/{args.role}')
    return 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=('validate', 'resolve', 'accounting', 'setup'))
    parser.add_argument('--repo')
    parser.add_argument('--ledger')
    parser.add_argument('--repo-id')
    parser.add_argument('--subject')
    parser.add_argument('--role')
    parser.add_argument('--object')
    parser.add_argument('--phase', choices=('spawn', 'freeze'), default='spawn')
    args = parser.parse_args()
    try:
        if args.mode == 'validate':
            print(json.dumps(validate(json.load(sys.stdin)), ensure_ascii=False))
        elif args.mode == 'resolve':
            print(json.dumps(policy(Path(args.repo)), ensure_ascii=False))
        elif args.mode == 'accounting':
            return accounting(args)
        else:
            return setup(args)
        return 0
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print('POLICY_INVALID: ' + str(error), file=sys.stderr)
        return 1
    except ImportError as error:
        print('NOT_IMPLEMENTED: ' + str(error), file=sys.stderr)
        return 2
    except Exception as error:
        # jsonschema.ValidationError is deliberately not duplicated as a parser.
        if error.__class__.__module__.startswith('jsonschema'):
            print('POLICY_INVALID: ' + str(error), file=sys.stderr)
            return 1
        raise


if __name__ == '__main__':
    raise SystemExit(main())
