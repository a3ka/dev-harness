#!/usr/bin/env python3
"""Independent control for the 182 public CLI (v2: project mode); never shipped."""
import argparse
import json
from pathlib import Path
import subprocess
import sys


def git(repo, *args):
    run = subprocess.run(['git', '-C', repo, *args], text=True, capture_output=True)
    if run.returncode:
        raise ValueError(f'PLAN_SOURCE_UNAVAILABLE: git {args[0]}: {run.stderr.strip()}')
    return run.stdout


def has_blob(repo, sha, path):
    return subprocess.run(['git', '-C', repo, 'cat-file', '-e', f'{sha}:{path}'],
                          stdout=subprocess.DEVNULL,
                          stderr=subprocess.DEVNULL).returncode == 0


def parse_rows(plan_text, roadmap_text):
    plan = [r.split('\t') for r in plan_text.splitlines()
            if r and not r.startswith('#') and not r.startswith('id\t')]
    roadmap = roadmap_text.splitlines()
    begin = '<!-- BEGIN GENERATED PLAN -->'
    end = '<!-- END GENERATED PLAN -->'
    if roadmap.count(begin) != 1 or roadmap.count(end) != 1 or roadmap.index(begin) >= roadmap.index(end):
        raise ValueError('PLAN_ROADMAP_RASHOZHDENIE: generated-блок отсутствует или повреждён')
    rows = {}
    for line in roadmap[roadmap.index(begin) + 1:roadmap.index(end)]:
        fields = [field.strip() for field in line.split('|')[1:-1]]
        if len(fields) == 6 and fields[0].isdigit():
            rows[fields[1]] = fields
    return plan, rows


def statuses(repo, sha, plan, rows, pauses, registered):
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
    result = []
    for row in plan:
        if len(row) != 6 or row[0] not in rows or (row[0].isdigit() and row[0] not in registered):
            raise ValueError('PLAN_ROADMAP_RASHOZHDENIE: нет строки ROADMAP/registry')
        num, wave, stage, dependencies, _source, track = row
        roadmap = rows[num]
        if (roadmap[0], roadmap[2], roadmap[3], roadmap[4]) != (wave, stage, track, dependencies):
            raise ValueError(f'PLAN_ROADMAP_RASHOZHDENIE: {num}')
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
    return result


def station_snapshot(repo, sha, mutation):
    def blob(path):
        if mutation == 'local' and path in ('registry/plan.tsv', 'ROADMAP.md'):
            from pathlib import Path
            return (Path(repo) / path).read_text()
        return git(repo, 'show', f'{sha}:{path}')

    plan, rows = parse_rows(blob('registry/plan.tsv'), blob('ROADMAP.md'))
    pauses = {fields[0]: fields for line in blob('registry/pauzy.tsv').splitlines()
              if not line.startswith('#') and len(fields := line.split('\t')) >= 4}
    registered = {line.split(' → ', 1)[0] for line in blob('registry/contracts.tsv').splitlines()
                  if ' → ' in line}
    result = [f'PLAN_SNAPSHOT: origin/main={sha}']
    result += station_statuses(repo, sha, plan, rows, pauses, registered, mutation)
    if mutation == 'handoff':
        from pathlib import Path
        return f'PLAN_SNAPSHOT: origin/main={sha}\n' + (Path(repo) / 'HANDOFF.md').read_text()
    if mutation == 'stale':
        result.append('ЖДЁТ УТРА 147/148/149: /tmp/dev-harness-verify/old-artifact')
    return '\n'.join(result) + '\n'


def station_statuses(repo, sha, plan, rows, pauses, registered, mutation):
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
    out = []
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
        out.append(f'PLAN: {num} | ROADMAP={wave}/{stage} | STATUS={status} | NEXT={nxt}')
    return out


def escape(value):
    return value.startswith('/') or any(seg == '..' for seg in value.split('/'))


def project_snapshot(repo, sha, mutation):
    prefix = f'PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main={sha})'
    live = Path(repo) / 'harness.project.json'
    if not live.exists() and mutation != 'legacy-fallback':
        raise ValueError(
            prefix + ': живой корень без harness.project.json — опубликованный и живой '
                     'профиль расходятся; выход: синхронизировать корень (fetch/checkout), '
                     'станционная раскладка не подменяется')
    if live.exists():
        profile = json.loads(live.read_text())
        wp = profile.get('workflowPaths') or {}
        if wp:
            registry = wp['registry']
            state = wp.get('state') or '.harness'
        else:
            registry, state = 'registry', '.'
        if escape(registry) or escape(state):
            if mutation != 'resolver-fallback':
                raise ValueError(
                    prefix + ': профиль не разрешается (workflowPaths вне репо); '
                             'выход: починить профиль проекта (996)')
            registry, state = 'registry', '.'
    else:
        registry, state = 'registry', '.'
    if mutation == 'registry-hardcode':
        # Адресный стаб (мутация критика К-08): результат резолвера отброшен
        # в пользу захардкоженного стандартного пути.
        registry = '.harness/registry'
    roadmap = 'ROADMAP.md' if state == '.' else f'{state}/ROADMAP.md'
    if mutation == 'root-decoy' and has_blob(repo, sha, 'registry/plan.tsv'):
        registry, roadmap = 'registry', 'ROADMAP.md'

    def blob(path, required=True):
        run = subprocess.run(['git', '-C', repo, 'show', f'{sha}:{path}'],
                             text=True, capture_output=True)
        if run.returncode:
            if required:
                raise ValueError(
                    f'{prefix}: нет {path} на origin/main={sha}; станционная корневая '
                    f'раскладка не читается; выход: источник заводится владельцем проекта '
                    f'коммитом в профильном реестре (996)')
            return None
        return run.stdout

    plan_rel = f'{registry}/plan.tsv'
    plan_text = blob(plan_rel, required=False)
    if plan_text is None:
        if mutation == 'silent-empty':
            return f'PLAN_SNAPSHOT: origin/main={sha}\nPLAN: нет пунктов\n'
        if mutation == 'station-fallback' and has_blob(repo, sha, 'registry/plan.tsv'):
            registry, roadmap = 'registry', 'ROADMAP.md'
            plan_text = blob('registry/plan.tsv')
        else:
            if mutation == 'vague-refusal':
                raise ValueError(f'PLAN_SOURCE_UNAVAILABLE: нет плана ({plan_rel})')
            tail = ('' if mutation == 'no-exit' else
                    f'; выход: план проекта заводит владелец коммитом в {plan_rel} (996)')
            raise ValueError(
                f'{prefix}: нет {plan_rel} на origin/main={sha}; станционный корневой реестр '
                f'не подменяет{tail}')
    roadmap_text = blob(roadmap)
    contracts_text = blob(f'{registry}/contracts.tsv')
    pauzy_text = blob(f'{registry}/pauzy.tsv', required=False)
    if pauzy_text is None and mutation == 'pauzy-required':
        raise ValueError(
            f'{prefix}: нет {registry}/pauzy.tsv на origin/main={sha}; '
            f'выход: завести паузы проекта в профильном реестре')
    if mutation == 'local-profile-plan':
        plan_text = (Path(repo) / plan_rel).read_text()
        roadmap_text = (Path(repo) / roadmap).read_text()
    plan, rows = parse_rows(plan_text, roadmap_text)
    if mutation == 'project-no-crosscheck':
        rows = {row[0]: [row[1], row[0], row[2], row[5], row[3], row[4]] for row in plan}
    pauses = {} if pauzy_text is None else {
        fields[0]: fields for line in pauzy_text.splitlines()
        if not line.startswith('#') and len(fields := line.split('\t')) >= 4}
    registered = {line.split(' → ', 1)[0] for line in contracts_text.splitlines()
                  if ' → ' in line}
    result = [f'PLAN_SNAPSHOT: origin/main={sha}']
    result += statuses(repo, sha, plan, rows, pauses, registered)
    return '\n'.join(result) + '\n'


def snapshot(repo, mutation=None):
    sha = git(repo, 'rev-parse', '--verify',
              'HEAD' if mutation == 'head' else 'origin/main').strip()
    if has_blob(repo, sha, 'harness.project.json') and mutation != 'no-project-mode':
        return project_snapshot(repo, sha, mutation)
    return station_snapshot(repo, sha, mutation)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', required=True)
    parser.add_argument('--mutation', choices=[
        'local', 'no-roadmap', 'stale', 'handoff', 'head',
        'no-project-mode', 'root-decoy', 'local-profile-plan', 'pauzy-required',
        'silent-empty', 'station-fallback', 'project-no-crosscheck',
        'resolver-fallback', 'legacy-fallback',
        'registry-hardcode', 'vague-refusal', 'no-exit'])
    args = parser.parse_args()
    try:
        sys.stdout.write(snapshot(args.repo, args.mutation))
    except (ValueError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
