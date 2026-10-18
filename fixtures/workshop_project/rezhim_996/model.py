#!/usr/bin/env python3
"""Executable reference for the 996 seams, not a replacement product runner.

The production adapter in probe.py calls public scripts; this model performs the
observable Git/filesystem operations independently. Mutations are selected only
by the matrix, never by expected outputs or case names.
"""
import json
import os
from pathlib import Path
import subprocess
import sys


def git(root, *args, check=True):
    return subprocess.run(['git', '-C', str(root), *args], text=True,
                          capture_output=True, check=check)


def fail(reason):
    print('ОТКАЗ: ' + reason, file=sys.stderr)
    return 1


def profile(root):
    p = json.loads((root / 'harness.project.json').read_text())
    layer = Path(os.environ.get('HARNESS_PROJECT_LAYER_ROOT', str(root)))
    defaults = json.loads((layer / p['projectLayer']['profilePath']).read_text()).get('defaults', {})
    result = dict(defaults)
    for k, v in p.items():
        result[k] = ({**defaults.get(k, {}), **v}
                     if k in ('git', 'workflowPaths') else v)
    return result


def contained(root, value):
    p = Path(value)
    if p.is_absolute() or '..' in p.parts:
        raise ValueError('workflowPaths вне репо')
    resolved = (root / p).resolve()
    if not resolved.is_relative_to(root.resolve()):
        raise ValueError('workflowPaths вне репо')
    return resolved


def layout(root, p, mutant):
    paths = dict(p['workflowPaths'])
    if mutant == 'accept-escape':
        paths = {k: v.replace('../', '') for k, v in paths.items()}
    if mutant == 'root-layout':
        paths = {k: k for k in paths}
    for value in paths.values():
        contained(root, value)
    # One explicit state directory, independent of parents of customizable paths.
    state = paths.get('state', '.harness')
    out = {k: str(contained(root, v)) for k, v in paths.items()}
    for k, v in [('handoff', 'HANDOFF.md'), ('observations', 'NABLIUDENIA.md'),
                 ('architectObservations', 'NABLIUDENIA_ARCHITECT.md'),
                 ('roadmap', 'ROADMAP.md'), ('forks', 'forks')]:
        out[k] = str(contained(root, state) / v)
    return out


def sources(root, p, contract, stage, mutant):
    canon = p.get('sourceCanon')
    if canon is None:
        return fail('SOURCE_CANON_REQUIRED') if mutant == 'require-canon' else 0
    if mutant == 'skip-canon':
        return 0
    if mutant == 'ignore-canon-keys':
        canon = {k: v for k, v in canon.items() if k in ('sources', 'gate')}
    if (not isinstance(canon, dict) or set(canon) != {'sources', 'gate'}
            or not isinstance(canon['sources'], list) or not canon['sources']
            or not isinstance(canon['gate'], list) or not canon['gate']):
        return fail('SOURCE_CANON_INVALID')
    seen = set()
    for row in canon['sources']:
        if (not isinstance(row, dict) or set(row) != {'path', 'priority'}
                or type(row['priority']) is not int or row['priority'] < 0
                or not isinstance(row['path'], str) or not row['path']
                or row['path'] in seen):
            return fail('SOURCE_CANON_INVALID')
        seen.add(row['path'])
        try:
            path = contained(root, row['path'])
        except ValueError:
            return fail('SOURCE_CANON_INVALID')
        if not path.is_file():
            return fail('SOURCE_CANON_MISSING')
    if any(not isinstance(a, str) or not a or '\x00' in a for a in canon['gate']):
        return fail('SOURCE_CANON_INVALID')
    env = dict(os.environ, HARNESS_CONTRACT=contract, HARNESS_STAGE=stage,
               HARNESS_HEAD=git(root, 'rev-parse', 'HEAD').stdout.strip())
    cwd = Path(os.environ['HARNESS_TOOLS_ROOT']) if mutant == 'canon-tools-cwd' else root
    try:
        result = subprocess.run(canon['gate'], cwd=cwd, env=env)
    except OSError:
        return fail('SOURCE_GATE_UNAVAILABLE')
    if result.returncode:
        return fail('SOURCE_GATE_FAILED')
    return 0


def main():
    op, root, *args = sys.argv[1:]
    root = Path(root).resolve()
    mutant = os.environ.get('MUTANT_996', '')
    p = profile(root)
    paths = layout(root, p, mutant)
    if op == 'paths':
        print(json.dumps(paths))
        return 0
    if op == 'gitw':
        env = dict(os.environ)
        canonical = p['git']['canonicalRemote']
        if mutant == 'hardcoded-origin':
            canonical = 'ssh://git@github.com/a3ka/dev-harness.git'
        if mutant == 'trust-target':
            canonical = args[1]
        env['GIT_EXCHANGE_GUARD_CANONICAL'] = env.get('GIT_EXCHANGE_GUARD_CANONICAL', canonical)
        return subprocess.run(['bash', str(Path(env['HARNESS_TOOLS_ROOT']) / 'scripts/gitw'),
                               '-C', str(root), *args], env=env).returncode
    if op in ('sources', 'pre_critic'):
        return sources(root, p, args[0], 'pre_critic', mutant)
    if op == 'reserve':
        # Existing next_id supplies the number; reservation is complete only
        # after atomic non-force publication and an origin tag-object match.
        env = dict(os.environ, HARNESS_WORKFLOW_ROOT=str(root))
        tools = Path(env['HARNESS_TOOLS_ROOT'])
        r = subprocess.run(['bash', str(tools / 'scripts/next_id.sh'), str(root), 'CONTRACT'],
                           env=env, text=True, capture_output=True)
        if r.returncode:
            print(r.stderr, file=sys.stderr)
            return r.returncode
        n = r.stdout.strip()
        tag = 'refs/tags/id/CONTRACT/' + n
        if mutant != 'local-reservation':
            env['GIT_EXCHANGE_GUARD_CANONICAL'] = p['git']['canonicalRemote']
            r = subprocess.run(['bash', str(tools / 'scripts/gitw'), '-C', str(root),
                                'push', 'origin', tag + ':' + tag], env=env)
            if r.returncode:
                return r.returncode
        print(n)
        return 0
    if op in ('freeze', 'done'):
        target = args[0]
        if Path(target).parent != Path(p['workflowPaths']['contracts']):
            return fail('CONTRACT_PATH')
        n = Path(target).name[:3]
        verdict_root = Path(paths['verdicts']).relative_to(root)
        if mutant == 'root-verdict':
            verdict_root = Path('verdicts')
        if op == 'freeze':
            verdict = verdict_root / 'critic' / f'contracts-{n}-v1.md'
            body = git(root, 'show', 'HEAD:' + str(verdict), check=False)
            if mutant != 'ignore-critic' and (body.returncode or body.stdout.splitlines()[0] != 'accept'):
                return fail('критик заморозку не разрешил')
            tag = f'frozen/contracts/{n}/1'
        else:
            rows = git(root, 'log', '--format=', '--name-only', '--',
                       str(verdict_root / 'review' / f'contracts-{n}-*.md')).stdout.splitlines()
            rows = [s for s in rows if s]
            if not rows:
                return fail('done: вердикт ревьюера не найден')
            verdict = rows[-1] if mutant == 'old-review' else rows[0]
            body = git(root, 'show', 'HEAD:' + verdict).stdout.splitlines()[0]
            if mutant != 'ignore-review' and body.strip().lower() != 'accept':
                return fail('done: вердикт ревьюера FAIL')
            if sources(root, p, target, 'done', mutant):
                return 1
            tag = f'done/contracts/{n}/1'
        git(root, 'tag', '-a', tag, '-m', '996 model')
        if op == 'freeze':
            reg = Path(paths['registry']) / 'contracts.tsv'
            reg.parent.mkdir(parents=True, exist_ok=True)
            reg.write_text(n + ' → ' + git(root, 'rev-parse', tag).stdout.strip() + '\n')
            git(root, 'add', str(reg))
            git(root, 'commit', '-qm', 'model freeze registry')
        if mutant == 'station-writes-tools':
            (root.parent / 'install' / 'HANDOFF.md').write_text('project state leaked\n')
        return 0
    return fail('MODEL_OPERATION')


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, KeyError, json.JSONDecodeError) as error:
        sys.exit(fail(str(error)))
