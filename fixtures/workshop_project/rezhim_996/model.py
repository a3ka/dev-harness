#!/usr/bin/env python3
"""Executable reference for the 996 seams, not a replacement product runner.

The production adapter in probe.py calls public scripts; this model performs the
observable Git/filesystem operations independently. Mutations are selected only
by the matrix, never by expected outputs or case names.
"""
import json
import os
from pathlib import Path
import re
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
    if mutant == 'accept-symlink':
        paths.pop('state', None)
    for value in paths.values():
        contained(root, value)
    # One explicit state directory, independent of parents of customizable paths.
    state = paths.get('state', '.harness')
    out = {k: str(contained(root, v)) for k, v in paths.items() if k != 'state'}
    for k, v in [('handoff', 'HANDOFF.md'), ('observations', 'NABLIUDENIA.md'),
                 ('architectObservations', 'NABLIUDENIA_ARCHITECT.md'),
                 ('roadmap', 'ROADMAP.md'), ('forks', 'forks')]:
        out[k] = str(contained(root, state) / v)
    return out


def sources(root, p, contract, stage, mutant, door=False):
    canon = p.get('sourceCanon')
    if mutant == 'canon-null-absent' and not canon:
        return 0
    if 'sourceCanon' not in p:
        return fail('SOURCE_CANON_REQUIRED') if mutant == 'require-canon' else 0
    if door and mutant == 'door-refuse':
        return fail('SOURCE_GATE_FAILED')
    if door and mutant == 'door-tools-cwd':
        mutant = 'canon-tools-cwd'
    if door and mutant == 'stale-head-cache' and (root / 'gate-observed.json').exists():
        return 0
    if mutant == 'ignore-canon-grammar':
        return 0
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


def preserved_gates(root, p, target, op, mutant):
    """Execute installed barriers, not their expected answers or probe fixtures."""
    if mutant == 'skip-gates':
        return 0
    tools = Path(os.environ['HARNESS_TOOLS_ROOT'])
    if op in ('freeze', 'done') and mutant != 'skip-committed':
        blob = git(root, 'show', 'HEAD:' + target, check=False)
        if blob.returncode or blob.stdout != (root / target).read_text():
            return fail('контракт не закоммичен на HEAD')
    if op == 'freeze' and mutant != 'skip-plan':
        registry = 'registry' if mutant == 'root-plan' else p['workflowPaths']['registry']
        plan = str(Path(registry) / 'plan.tsv')
        result = subprocess.run(['bash', str(Path(__file__).with_name('plan_adapter.sh')),
                                 str(tools), str(root), plan, Path(target).name[:3]],
                                cwd=root, text=True, capture_output=True)
        if result.returncode:
            return fail(result.stderr)
    gates = {
        'freeze': [('spec', 'check_spec_ready.sh', 'spec-preflight 036'),
                   ('consumers', 'check_consumers.sh', 'потребители 116'),
                   ('precision', 'check_precision_gate.sh', 'precision-гейт 043')],
        'done': [('provodka', 'check_provodka.sh', 'ПРОВОДКА'),
                 ('consumers', 'check_consumers.sh', 'потребители 116')],
        'pre_critic': [('precision', 'check_precision_gate.sh', 'precision-gate'),
                       ('spec', 'check_spec_ready.sh', 'spec-ready')],
    }
    for key, script, reason in gates[op]:
        if mutant == 'skip-' + key:
            continue
        result = subprocess.run(['bash', str(tools / 'scripts' / script), str(root), target],
                                cwd=root, text=True, capture_output=True)
        if result.returncode:
            return fail(reason + ': ' + result.stdout + result.stderr)
    if op == 'freeze' and mutant != 'skip-doc':
        result = subprocess.run(['node', str(tools / 'scripts/doc_contract.ts'),
                                 '--type', str(root / target)], text=True, capture_output=True)
        if result.returncode == 0:
            result = subprocess.run(['node', str(tools / 'scripts/check_document.ts'),
                                     '--root', str(root), '--contract', target, '--preflight'],
                                    cwd=root, text=True, capture_output=True)
            if result.returncode:
                return fail('doc-preflight: ' + result.stdout + result.stderr)
        elif result.returncode != 1:
            return fail('doc-preflight: ' + result.stderr)
    if op == 'pre_critic':
        body = (root / target).read_text()
        if mutant != 'skip-n39':
            lines = [re.sub(r'«[^»]*»|„[^“]*“|"[^"]*"|`[^`]*`', '', line)
                     for line in body.splitlines()]
            for line in lines + [a + ' ' + b for a, b in zip(lines, lines[1:]) if a and b]:
                if (re.search(r's[0-9]+|стаб|обманка', line)
                        and re.search(r'умирает|ловится|краснеет|падает', line)
                        and re.search(r'клетк[а-яё]*|вход|кейс', line)):
                    return fail('Н-39: привязка стаба в прозе')
        registry = root / p['workflowPaths']['registry'] / 'contracts.tsv'
        if mutant != 'skip-form' and registry.is_file():
            if not re.search(r'^КОНТЕКСТ:', body, re.M):
                return fail('форма: контракт без строк КОНТЕКСТ:')
            if not re.search(r'^##\s+Существующее(?:\s.*)?$', body, re.M):
                return fail('форма: контракт без секции ## Существующее')
    return 0


def main():
    op, root, *args = sys.argv[1:]
    root = Path(root).resolve()
    mutant = os.environ.get('MUTANT_996', '')
    if op == 'self_canonical':
        value = 'ssh://git@example.invalid/dev-harness.git' if mutant == 'old-self-canon' else 'ssh://git@github.com/a3ka/dev-harness.git'
        print(json.dumps({'git': {'value': {'canonicalRemote': value}}}))
        return 0
    try:
        p = profile(root)
    except json.JSONDecodeError:
        if mutant == 'broken-profile-fallback' and op == 'gitw':
            return git(root, *args, check=False).returncode
        raise
    paths = layout(root, p, mutant)
    if op == 'paths':
        print(json.dumps(paths))
        return 0
    if op in ('workshop', 'make_task'):
        role = args[0] if args else 'orchestrator'
        context = dict(paths)
        if mutant == 'root-context':
            tools = Path(os.environ['HARNESS_TOOLS_ROOT'])
            context = {key: str(tools / Path(value).name) for key, value in paths.items()}
        suffix = {'critic': 'critic', 'adversary': 'adversary', 'reviewer': 'review',
                  'arbiter': 'arbitration'}.get(role)
        verdict = str(Path(context['verdicts']) / suffix) if suffix else None
        if mutant == 'root-verdict-context' and suffix:
            verdict = str(root / 'verdicts' / suffix)
        startup = [context[key] for key in ('handoff', 'contracts', 'verdicts', 'observations', 'roadmap')]
        if mutant == 'root-startup':
            startup[0] = str(Path(os.environ['HARNESS_TOOLS_ROOT']) / 'HANDOFF.md')
        print(json.dumps({'workflow': context, 'sourceCanon': None if mutant == 'drop-context-canon' else p.get('sourceCanon'),
                          'verdict': verdict, 'startup': startup}))
        return 0
    if op in ('zones', 'staged', 'lib_zones'):
        if mutant == 'root-contracts-only':
            return 0
        # This model reads the frozen blob, not mutable contract bytes.
        tags = git(root, 'tag', '-l', 'frozen/contracts/*').stdout.splitlines()
        rows = []
        for tag in tags:
            for path in git(root, 'ls-tree', '-r', '--name-only', tag, '--', p['workflowPaths']['contracts']).stdout.splitlines():
                for line in git(root, 'show', tag + ':' + path).stdout.splitlines():
                    if line.startswith('ЗОНА '):
                        author, zones = line[5:].split(': ', 1)
                        rows.extend((author, z, tag.split('/')[2]) for z in zones.split())
        if op == 'lib_zones':
            for row in rows:
                print('\t'.join(row))
            return 0
        if op == 'staged':
            author = os.environ.get('GIT_AUTHOR_NAME', '')
            changed = git(root, 'diff', '--cached', '--name-only').stdout.splitlines()
            # Existing mint door: only an issued remote annotated id admits registry.
            registry = str(Path(p['workflowPaths']['registry']) / 'contracts.tsv')
            if author == 'orchestrator' and changed == [registry]:
                return 0
        else:
            author = git(root, 'log', '-1', '--format=%an').stdout.strip()
            changed = git(root, 'diff', '--name-only', tags[0], 'HEAD').stdout.splitlines()
        zones = [z for a, z, _ in rows if a == author]
        if mutant == 'reject-all-zones':
            return fail('вне зоны')
        for path in changed:
            if zones and not any(path.startswith(z) for z in zones):
                return fail('вне зоны: ' + path)
        return 0
    if op == 'mint':
        n = args[0]
        tag = 'refs/tags/id/CONTRACT/' + n
        sha = git(root, 'rev-parse', tag).stdout.strip()
        remote = git(root, 'ls-remote', 'origin', tag).stdout.split()
        if mutant != 'mint-self-authority' and (not remote or remote[0] != sha):
            return fail('не выдан авторитетом')
        registry = root / 'registry' if mutant == 'mint-root-registry' else Path(paths['registry'])
        registry.mkdir(parents=True, exist_ok=True)
        file = registry / 'contracts.tsv'
        file.write_text(n + ' → ' + sha + '\n')
        git(root, 'add', str(file))
        r = git(root, '-c', 'user.name=orchestrator', '-c', 'user.email=o@x',
                'commit', '-qm', 'mint', check=False)
        if r.returncode:
            return fail('mint hook refused: ' + r.stderr)
        print('MINTED nnn=' + n + ' sha=' + sha)
        return 0
    if op == 'gitw':
        env = dict(os.environ)
        canonical = p['git']['canonicalRemote']
        if mutant == 'trust-origin-url':
            canonical = git(root, 'remote', 'get-url', 'origin').stdout.strip()
        if mutant == 'hardcoded-origin':
            canonical = 'ssh://git@github.com/a3ka/dev-harness.git'
        if mutant == 'trust-target':
            canonical = args[1]
        env['GIT_EXCHANGE_GUARD_CANONICAL'] = (canonical if mutant == 'profile-over-override'
                                               else env.get('GIT_EXCHANGE_GUARD_CANONICAL', canonical))
        return subprocess.run(['bash', str(Path(env['HARNESS_TOOLS_ROOT']) / 'scripts/gitw'),
                               '-C', str(root), *args], env=env).returncode
    if op in ('sources', 'pre_critic'):
        if op == 'pre_critic' and preserved_gates(root, p, args[0], op, mutant):
            return 1
        return sources(root, p, args[0], 'pre_critic', mutant, door=(op == 'pre_critic'))
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
        if mutant == 'lightweight-reservation':
            head = git(root, 'rev-parse', tag + '^{}').stdout.strip()
            git(root, 'update-ref', tag, head)
        if mutant != 'local-reservation':
            env['GIT_EXCHANGE_GUARD_CANONICAL'] = p['git']['canonicalRemote']
            r = subprocess.run(['bash', str(tools / 'scripts/gitw'), '-C', str(root),
                                'push', 'origin', ('+' if mutant == 'reserve-force' else '') + tag + ':' + tag], env=env)
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
            if mutant == 'fallback-root' and body.returncode:
                body = git(root, 'show', 'HEAD:verdicts/critic/' + f'contracts-{n}-v1.md', check=False)
            first = '' if body.returncode else (body.stdout.splitlines() or [''])[0].strip()
            if mutant == 'critic-not-fail-is-accept':
                refused = body.returncode or first == 'FAIL'
            else:
                refused = body.returncode or first != 'accept'
            if mutant != 'ignore-critic' and refused:
                if not body.returncode and first == 'FAIL':
                    return fail('критик заморозку не разрешил: FAIL')
                if not body.returncode and first == 'ESCALATE':
                    return fail('критик передал вопрос владельцу: ESCALATE')
                if not body.returncode:
                    return fail('вердикт вне объявленной грамматики: ' + first)
                return fail('критик заморозку не разрешил')
            events = []
            commits = git(root, 'log', '--reverse', '--format=%H', '--',
                          str(verdict_root / 'critic')).stdout.splitlines()
            for rev in commits:
                event = git(root, 'show', rev + ':' + str(verdict), check=False).stdout.splitlines()
                if event and (not events or event[0] != events[-1]):
                    events.append(event[0])
            arbroot = root / ('verdicts' if mutant == 'root-arbitration' else verdict_root) / 'arbitration'
            arbiters = list(arbroot.glob('*.md')) if arbroot.exists() else []
            permitted = any('(контракт ' + n + ')' in f.read_text().splitlines()[0] for f in arbiters)
            if len(events) >= 3 and not permitted and mutant != 'ignore-project-cap':
                return fail('кап кругов')
            tag = f'frozen/contracts/{n}/1'
        else:
            rows = git(root, 'log', '--format=', '--name-only', '--',
                       str(verdict_root / 'review' / f'contracts-{n}-*.md')).stdout.splitlines()
            rows = [s for s in rows if s]
            if mutant == 'fallback-root' and not rows:
                rows = [s for s in git(root, 'log', '--format=', '--name-only', '--',
                        f'verdicts/review/contracts-{n}-*.md').stdout.splitlines() if s]
            if not rows:
                return fail('done: вердикт ревьюера не найден')
            verdict = rows[-1] if mutant == 'old-review' else rows[0]
            body = git(root, 'show', 'HEAD:' + verdict).stdout.splitlines()[0]
            norm = body.strip().lower()
            if mutant == 'review-grammar':
                refused = norm == 'fail'
            else:
                refused = norm != 'accept'
            if mutant != 'ignore-review' and refused:
                if norm == 'fail':
                    return fail('done: вердикт ревьюера FAIL')
                if norm == 'escalate':
                    return fail('done: вердикт ревьюера ESCALATE')
                return fail('done: вердикт вне грамматики: ' + body)
            if sources(root, p, target, 'done', mutant, door=True):
                return 1
            tag = f'done/contracts/{n}/1'
        if preserved_gates(root, p, target, op, mutant):
            return 1
        git(root, 'tag', '-a', tag, '-m', '996 model')
        if op == 'freeze':
            reg = Path(paths['registry']) / 'contracts.tsv'
            reg.parent.mkdir(parents=True, exist_ok=True)
            reg.write_text(n + ' → ' + git(root, 'rev-parse', tag).stdout.strip() + '\n')
            git(root, 'add', str(reg))
            # The product commits the registry atomically under orchestrator
            # (freeze_contract.sh:456-458, Н-132 class); the model must not diverge.
            if mutant != 'registry-uncommitted':
                identity = (['architect', 'architect@dev-harness.local']
                            if mutant == 'registry-author-architect'
                            else ['orchestrator', 'orchestrator@dev-harness.local'])
                r = git(root, '-c', 'user.name=' + identity[0],
                        '-c', 'user.email=' + identity[1],
                        'commit', '-qm', 'model freeze registry', '--', str(reg), check=False)
                if r.returncode:
                    return fail('реестр не закоммичен: ' + r.stderr)
        if mutant == 'done-leak' and op == 'done':
            with (Path(os.environ['HARNESS_TOOLS_ROOT']) / 'HANDOFF.md').open('a') as f:
                f.write('done leaked\n')
        if mutant in ('station-writes-tools', 'tools-leak'):
            tools = Path(os.environ['HARNESS_TOOLS_ROOT'])
            with (tools / 'HANDOFF.md').open('a') as f:
                f.write('project state leaked\n')
            with (tools / 'registry/contracts.tsv').open('a') as f:
                f.write(n + ' leaked from project\n')
        return 0
    return fail('MODEL_OPERATION')


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, KeyError, json.JSONDecodeError) as error:
        sys.exit(fail(str(error)))
