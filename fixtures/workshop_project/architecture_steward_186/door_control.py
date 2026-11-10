#!/usr/bin/env python3
"""Toy reference for the public L1 merge-door contract, not production implementation."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys


def call(args, cwd):
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout or 'command failed')
    return result.stdout


def fail(reason):
    print(reason)
    return 1


def main():
    project, number = Path(sys.argv[1]), sys.argv[2]
    repo = 'a3ka/CompliorOS-architecture'
    pr = json.loads(call(['gh', 'pr', 'view', number, '-R', repo,
                          '--json', 'title,author,headRefOid,baseRefName'], project))
    sha = pr['headRefOid']
    if not re.search(r'\bCOMPLIOR-[0-9]+\b', pr['title']):
        return fail('NO_COMPLIOR_ID')
    operator = json.loads(call(['gh', 'api', 'user'], project))['login']
    if pr['author']['login'] == operator:
        return fail('AUTHOR_IS_MERGER')
    reviews = json.loads(call(['gh', 'api', f'repos/{repo}/pulls/{number}/reviews'], project))
    accepted = any(r['state'] == 'APPROVED' and r['commit_id'] == sha
                   and r['user']['login'] == 'critic' and r['user']['login'] != pr['author']['login']
                   and re.search(r'^accept$', r['body'], re.M)
                   and re.search(r'^СУД: .*модель-факт=zai/glm-5\.3; SHA=' + re.escape(sha) + r'$', r['body'], re.M)
                   for r in reviews)
    if not accepted:
        return fail('NO_CRITIC_ACCEPT_ON_HEAD')
    checks = json.loads(call(['gh', 'api', f'repos/{repo}/commits/{sha}/check-runs'], project))
    if not any(c['name'] == 'architecture' for c in checks['check_runs']) or any(
            c['status'] != 'completed' or c['conclusion'] != 'success' for c in checks['check_runs']):
        return fail('CI_NOT_GREEN_ON_HEAD')
    check = subprocess.run(['npm', 'run', 'check', '--', '--base',
                            'governance/baseline/approved.json', '--report'],
                           cwd=project, text=True, capture_output=True)
    if check.returncode not in (0, 2):
        raise RuntimeError(check.stderr or check.stdout or 'check failed')
    status = json.loads(check.stdout)
    mismatches = [finding['section'] for finding in status['findings']
                  if finding['code'] == 'BASELINE_MISMATCH']
    if mismatches:
        if any(section in ('resources', 'authority', 'policies', 'repositoryLayout', 'systemModel', 'changeScenarios')
               for section in mismatches):
            return fail('L3_OWNER_APPROVAL_REQUIRED')
        return fail('L2_OWNER_APPROVAL_REQUIRED')
    if status['baselineStatus'] != 'PASS' or status['contractReadiness']['incompatibleContracts']:
        return fail('BASELINE_NOT_PASS')
    call(['gh', 'pr', 'merge', number, '-R', repo, '--merge', '--match-head-commit', sha], project)
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (RuntimeError, KeyError, ValueError, IndexError) as exc:
        print('DOOR_INFRA_ERROR: ' + str(exc), file=sys.stderr)
        raise SystemExit(2)
