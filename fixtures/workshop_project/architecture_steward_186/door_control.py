#!/usr/bin/env python3
"""Toy reference for the public L1 merge-door contract, not production implementation.

Честная дверь по вердикту adversary contracts-186-impl-v1 (вызов 1): ровно один
COMPLIOR-<NNN> в title; логины сравниваются casefold (GitHub-логины регистронезави-
симы) и ТОЛЬКО casefold — любой иной байт (юникод-lookalike, пробел, [bot]) = другой
аккаунт; пустой логин автора — инфраструктурный сбой (rc 2), не слияние; `accept` —
дословно первая строка body; единственная строка `СУД: ` несёт ровно одно поле
`модель-факт=` со значением модели критика и кончается `; SHA=<head>`; check-runs
читаются ВСЕ страницы через `gh api --paginate`, зелёность всех runs, наличие
`architecture` и его происхождение app.slug=github-actions.
"""
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
    if len(re.findall(r'\bCOMPLIOR-[0-9]+\b', pr['title'])) != 1:
        return fail('NO_COMPLIOR_ID')
    if not pr['author']['login']:
        raise RuntimeError('в PR нет автора — слияние невозможно судить')
    operator = json.loads(call(['gh', 'api', 'user'], project))['login']
    if pr['author']['login'].casefold() == operator.casefold():
        return fail('AUTHOR_IS_MERGER')
    reviews = json.loads(call(['gh', 'api', f'repos/{repo}/pulls/{number}/reviews'], project))
    accepted = False
    for r in reviews:
        if r['state'] != 'APPROVED' or r['commit_id'] != sha:
            continue
        if r['user']['login'] != 'critic' or r['user']['login'] == pr['author']['login']:
            continue
        lines = r['body'].splitlines()
        sud = [line for line in lines if line.startswith('СУД: ')]
        fields = sud[0].split('модель-факт=') if len(sud) == 1 else []
        if (not lines or lines[0] != 'accept' or len(fields) != 2
                or fields[1].split(';', 1)[0] != 'zai/glm-5.3'
                or not sud[0].endswith('; SHA=' + sha)):
            continue
        accepted = True
        break
    if not accepted:
        return fail('NO_CRITIC_ACCEPT_ON_HEAD')
    raw = call(['gh', 'api', '--paginate', f'repos/{repo}/commits/{sha}/check-runs'], project)
    runs = [c for line in raw.splitlines() if line.strip()
            for c in json.loads(line).get('check_runs') or []]
    if any(c['status'] != 'completed' or c['conclusion'] != 'success' for c in runs):
        return fail('CI_NOT_GREEN_ON_HEAD')
    if not runs or not any(c.get('name') == 'architecture' for c in runs):
        return fail('CI_NOT_GREEN_ON_HEAD')
    if any(c.get('app', {}).get('slug') != 'github-actions'
           for c in runs if c['name'] == 'architecture'):
        return fail('CI_FOREIGN_ARCHITECTURE_APP')
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
