#!/usr/bin/env python3
"""Independent control for the 182 public CLI; never shipped as the implementation."""
import argparse
import subprocess
import sys


def git(repo, *args):
    run = subprocess.run(['git', '-C', repo, *args], text=True, capture_output=True)
    if run.returncode:
        raise ValueError(f'PLAN_SOURCE_UNAVAILABLE: git {args[0]}: {run.stderr.strip()}')
    return run.stdout


def snapshot(repo, mutation=None):
    sha = git(repo, 'rev-parse', '--verify', 'origin/main').strip()
    def blob(path):
        if mutation == 'local' and path in ('registry/plan.tsv', 'ROADMAP.md'):
            from pathlib import Path
            return (Path(repo) / path).read_text()
        return git(repo, 'show', f'{sha}:{path}')

    plan = [r.split('\t') for r in blob('registry/plan.tsv').splitlines()
            if r and not r.startswith('#') and not r.startswith('id\t')]
    rows = {}
    for line in blob('ROADMAP.md').splitlines():
        fields = [field.strip() for field in line.split('|')[1:-1]]
        if len(fields) == 6 and fields[0].isdigit():
            rows[fields[1]] = fields
    pauses = {fields[0]: fields for line in blob('registry/pauzy.tsv').splitlines()
              if not line.startswith('#') and len(fields := line.split('\t')) >= 4}
    registered = {line.split(' → ', 1)[0] for line in blob('registry/contracts.tsv').splitlines()
                  if ' → ' in line}
    tags = git(repo, 'ls-remote', '--tags', 'origin',
               'refs/tags/frozen/contracts/*', 'refs/tags/done/contracts/*')
    published = set()
    for line in tags.splitlines():
        target, ref = line.split('\t')
        if ref.endswith('^{}'):
            ref = ref[:-3]
        if subprocess.run(['git', '-C', repo, 'merge-base', '--is-ancestor', target, sha],
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
            published.add(ref)
    result = [f'PLAN_SNAPSHOT: origin/main={sha}']
    for row in plan:
        if len(row) != 6 or row[0] not in rows or (row[0].isdigit() and row[0] not in registered):
            raise ValueError('PLAN_ROADMAP_RASHOZHDENIE: нет строки ROADMAP/registry')
        num, wave, stage, dependencies, _source, track = row
        roadmap = rows[num]
        if (roadmap[0], roadmap[2], roadmap[3], roadmap[4]) != (wave, stage, track, dependencies):
            raise ValueError(f'PLAN_ROADMAP_RASHOZHDENIE: {num}')
        if mutation == 'no-roadmap':
            wave, stage = '?', '?'
        done = any(ref.startswith(f'refs/tags/done/contracts/{num}/') for ref in published)
        frozen = any(ref.startswith(f'refs/tags/frozen/contracts/{num}/') for ref in published)
        if done:
            status, nxt = 'done', 'закрыто'
        elif num in pauses:
            status, nxt = 'ПАУЗА', pauses[num][3]
        elif frozen:
            status, nxt = 'frozen', 'сверить PR/вердикт, затем done'
        else:
            status, nxt = 'черновик', 'контракт → critic → freeze'
        result.append(f'PLAN: {num} | ROADMAP={wave}/{stage} | STATUS={status} | NEXT={nxt}')
    if mutation == 'handoff':
        from pathlib import Path
        return f'PLAN_SNAPSHOT: origin/main={sha}\n' + (Path(repo) / 'HANDOFF.md').read_text()
    if mutation == 'stale':
        result.append('ЖДЁТ УТРА 147/148/149: /tmp/dev-harness-verify/old-artifact')
    return '\n'.join(result) + '\n'


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', required=True)
    parser.add_argument('--mutation', choices=['local', 'no-roadmap', 'stale', 'handoff'])
    args = parser.parse_args()
    try:
        sys.stdout.write(snapshot(args.repo, args.mutation))
    except (ValueError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
