#!/usr/bin/env python3
"""Frozen-pin static probes (995, круг 1 ревьюера B3/B5).

B5 — §Пины контракта 995: rehearsal.yaml сохраняет имя testcase 991
`991 start action and new-launch reset`.
B3 — §Шов/инвариант 1: release CI явно задаёт API mode для сборки release-APK —
EXPO_PUBLIC_API_MODE в шаге с assembleRelease либо в env уровня job, содержащего
этот шаг. Обе проверки читают только текст R и печатают построчный rc.
"""
import argparse
from pathlib import Path
import re
import sys

REHEARSAL_NAME = '991 start action and new-launch reset'


def check_rehearsal_name(repo):
    path = repo / 'mobile/.maestro/rehearsal.yaml'
    if not path.exists(): return 1, 'REHEARSAL_FILE_ABSENT'
    for line in path.read_text().splitlines():
        if line.startswith('name:'):
            actual = line.split(':', 1)[1].strip()
            if actual == REHEARSAL_NAME: return 0, 'name=' + actual
            return 1, f'REHEARSAL_NAME_CHANGED: {actual!r} != {REHEARSAL_NAME!r}'
    return 1, 'REHEARSAL_NAME_ABSENT'


def release_mode_bounds(lines, anchor):
    step = next((i for i in range(anchor, -1, -1) if re.match(r'^\s*-\s+\S', lines[i])), None)
    if step is None: raise RuntimeError('RELEASE_STEP_BOUND_NOT_FOUND')
    indent = re.match(r'^(\s*)-', lines[step]).group(1)
    end = len(lines)
    for j in range(anchor + 1, len(lines)):
        if re.match(r'^\s*-\s+\S', lines[j]) and re.match(r'^(\s*)-', lines[j]).group(1) == indent:
            end = j; break
    job = next((i for i in range(step, -1, -1) if re.match(r'^  \S.*:$', lines[i])), None)
    if job is None: raise RuntimeError('RELEASE_JOB_BOUND_NOT_FOUND')
    return step, end, job


def check_release_mode(repo):
    path = repo / '.github/workflows/mobile.yml'
    if not path.exists(): return 1, 'WORKFLOW_FILE_ABSENT'
    lines = path.read_text().splitlines()
    anchor = next((i for i, line in enumerate(lines) if 'assembleRelease' in line), None)
    if anchor is None: return 1, 'RELEASE_STEP_ABSENT'
    step, end, job = release_mode_bounds(lines, anchor)
    if 'EXPO_PUBLIC_API_MODE' in '\n'.join(lines[step:end]): return 0, 'release step задаёт mode явно'
    env_block = []
    in_env = False
    for line in lines[job:step]:
        if re.match(r'^    env:\s*$', line): in_env = True; continue
        if in_env:
            if line.strip() and not line.startswith('      '): in_env = False
            else: env_block.append(line)
    if 'EXPO_PUBLIC_API_MODE' in '\n'.join(env_block): return 0, 'job env задаёт mode явно'
    return 1, 'RELEASE_MODE_UNSET: шаг assembleRelease не задаёт EXPO_PUBLIC_API_MODE'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    args = parser.parse_args()
    checks = [('B5', check_rehearsal_name), ('B3', check_release_mode)]
    results = []
    for name, check in checks:
        rc, reason = check(args.repo)
        print(f'995 pins/{name}: rc={rc} {reason}')
        results.append(rc)
    return int(any(results))


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
