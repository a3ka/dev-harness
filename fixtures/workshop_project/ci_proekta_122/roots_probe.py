#!/usr/bin/env python3
"""122/6: actual freeze CLI + real git; unrelated pre-freeze gates isolated.

The explicit context is a subject-bound project_workflow transport, not a root
argument: contract path/blob and station origin bind it to this subject; product
identity and canonical origin are checked against the real profile resolver.
Oracle snapshots are taken before calling freeze, retained only in memory.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
TARGET = 'contracts/731-roots.md'
TAG = 'frozen/contracts/731/1'
# Н-39: executable binding; each mutant is checked ONLY at its observable input.
STABS = {
    'station-inventory': 'project-secret',
    'missing-secret-ignored': 'missing-secret',
    'unchecked-context': 'wrong-origin',
    'missing-context-ignored': 'no-context',
    'ambiguous-context-first': 'ambiguous-context',
    'gh-error-ignored': 'gh-error',
    'project-writer': 'station-writes',
    'mono-rejected': 'mono',
}
CASES = {
    'project-secret': (0, None),
    'missing-secret': (1, 'sekrety-ne-zavedeny: PILOT_DEMO_CODE'),
    'wrong-origin': (1, 'project-workflow-rashozhdenie'),
    'wrong-project': (1, 'project-workflow-rashozhdenie'),
    'wrong-subject': (1, 'project-workflow-rashozhdenie'),
    'no-context': (1, 'project-workflow-otsutstvuet'),
    'ambiguous-context': (1, 'project-workflow-neodnoznachen'),
    'gh-error': (1, 'gh-nedostupen'),
    'mono': (0, None),
    'station-writes': (0, None),
}


def run(args, **kwargs):
    return subprocess.run([str(x) for x in args], text=True, capture_output=True,
                          timeout=30, **kwargs)


def git(root, *args):
    p = run(['git', '-C', root, '-c', 'user.name=fixture122', '-c',
             'user.email=fixture122@local', '-c', 'commit.gpgsign=false',
             '-c', 'core.hooksPath=/dev/null', *args])
    if p.returncode:
        raise RuntimeError(p.stderr)
    return p.stdout.strip()


def put(root, name, text):
    p = root / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text)
    return p


def init(root):
    root.mkdir()
    git(root, 'init', '-q', '-b', 'main')
    git(root, 'config', 'user.name', 'fixture122')
    git(root, 'config', 'user.email', 'fixture122@local')
    git(root, 'config', 'core.hooksPath', '/dev/null')
    put(root, 'seed', 'fixture122\n')


def commit(root):
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'fixture122')


def profile(root, remote):
    put(root, 'harness.project.json', json.dumps({
        'schemaVersion': 1, 'repoId': 'toy-product', 'language': 'typescript',
        'projectLayer': {'version': '1', 'profilePath': 'registry/project.json'},
        'git': {'canonicalRemote': str(remote)}}))
    put(root, 'registry/project.json', json.dumps({
        'schemaVersion': 1, 'version': '1', 'projectId': 'toy-project',
        'workspaceId': 'toy-workspace', 'defaults': {}}))


def snapshot(root):
    paths = ('registry/contracts.tsv', 'verdicts/critic/contracts-731-v1.md', TARGET)
    return (git(root, 'rev-parse', 'HEAD'),
            git(root, 'for-each-ref', '--format=%(refname) %(objectname)', 'refs/tags/'),
            {p: (root / p).read_bytes() if (root / p).exists() else None for p in paths})


def world(base, repo, case):
    station, product = base / 'station', base / 'product'
    init(station)
    init(product)
    # An existing local bare origin gives registry_state a real reachable authority.
    # No git shim, rewritten origin, fake tag, or missing freeze leg.
    for r in (station, product):
        remote = base / (r.name + '-origin.git')
        git(base, 'init', '--bare', '-q', str(remote))
        git(r, 'remote', 'add', 'origin', str(remote))
    profile(product, base / 'product-origin.git')
    put(station, TARGET, '# Toy CI subject\nЗОНА implementer: .github/workflows/mobile.yml\n'
        'ПРЕДПОСЫЛКИ:\n- secret PILOT_DEMO_CODE\n')
    put(station, 'verdicts/critic/contracts-731-v1.md', 'accept\nfixture122\n')
    # Established seam pattern: fixtures/freeze_contract/fail_closed_992.py.
    # Only unrelated prerequisites are isolated; freeze, libs, resolver and Г3
    # are the named candidate's real tools. No model fallback in --repo mode.
    scripts = station / 'scripts'
    scripts.mkdir()
    for name in ('freeze_contract.sh', 'next_id.sh', 'lib_registry.sh',
                 'profile_resolver.sh', 'project_workflow.sh', 'check_predposylki.sh'):
        shutil.copy2(repo / 'scripts' / name, scripts / name)
    put(station, 'scripts/check_spec_ready.sh', '#!/bin/bash\nexit 0\n')
    put(station, 'scripts/doc_contract.ts', 'process.exit(1);\n')
    # gh is a fixture inventory keyed by the ACTUAL -R argument, not cwd or
    # an env-selected success. No secret values; gh call provenance is observable.
    gh = put(base, 'bin/gh', '''#!/usr/bin/env python3
import json, pathlib, sys
base = pathlib.Path(__file__).resolve().parents[1]
args = sys.argv[1:]
with (base / 'calls.jsonl').open('a') as out:
    out.write(json.dumps(args) + '\\n')
if len(args) != 4 or args[:3] != ['secret', 'list', '-R']:
    sys.exit(7)
data = json.loads((base / 'inventory.json').read_text())
entry = data.get(args[3], {'rc': 0, 'names': []})
for name in entry['names']:
    print(name + '\\t2026-11-18T00:00:00Z')
sys.exit(entry['rc'])
''')
    gh.chmod(0o755)
    if case == 'mono':
        product = station
        profile(station, base / 'station-origin.git')
    for r in {station, product}:
        commit(r)
    for r in {station, product}:
        # Use real ref plumbing, not an exchange with a self-referential origin.
        remote = Path(git(r, 'remote', 'get-url', 'origin'))
        git(remote, 'fetch', '-q', str(r), 'main:refs/heads/main')
    origin = git(product, 'remote', 'get-url', 'origin')
    ctx = {'schemaVersion': 1, 'subject': {
        'root': str(station), 'path': TARGET,
        'blob': git(station, 'rev-parse', 'HEAD:' + TARGET),
        'origin': git(station, 'remote', 'get-url', 'origin')},
        'project': {'root': str(product), 'projectId': 'toy-project',
                    'repoId': 'toy-product', 'canonicalRemote': origin}}
    if case == 'wrong-origin':
        git(product, 'remote', 'set-url', 'origin', str(base / 'station-origin.git'))
    if case == 'wrong-project':
        ctx['project']['projectId'] = 'other-project'
    if case == 'wrong-subject':
        ctx['subject']['blob'] = '0' * 40
    context = put(base, 'context.json', json.dumps([ctx, ctx] if case == 'ambiguous-context' else ctx))
    if case == 'no-context':
        context.unlink()
    inventory = {origin: {'rc': 7 if case == 'gh-error' else 0,
                         'names': [] if case == 'missing-secret' else ['PILOT_DEMO_CODE']}}
    # A same-named secret at station cannot conceal its absence at product.
    if product != station:
        inventory[git(station, 'remote', 'get-url', 'origin')] = {
            'rc': 0, 'names': ['PILOT_DEMO_CODE'] if case == 'missing-secret' else []}
    put(base, 'inventory.json', json.dumps(inventory))
    return station, product, context, origin


def observe(repo, case, mode='repo', mutant=None):
    with tempfile.TemporaryDirectory(prefix='roots122-') as tmp:
        base = Path(tmp)
        station, product, context, origin = world(base, repo, case)
        before = {r: snapshot(r) for r in {station, product}}
        env = dict(os.environ, PATH=str(base / 'bin') + ':' + os.environ['PATH'],
                   GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
        # No inherited product-layer override can change the context's identity.
        env.pop('HARNESS_PROJECT_LAYER_ROOT', None)
        if mode == 'model':
            cmd = ['python3', HERE / 'roots_model.py', station, TARGET]
            if case != 'mono':
                cmd += [context]
            if mutant:
                cmd += ['--mutant', mutant]
        else:
            cmd = ['bash', station / 'scripts/freeze_contract.sh', TARGET,
                   'fixture122 roots', station]
            if case != 'mono':
                cmd += ['--project-workflow', context]
        result = run(cmd, env=env)
        after = {r: snapshot(r) for r in before}
        calls_path = base / 'calls.jsonl'
        calls = [json.loads(s) for s in calls_path.read_text().splitlines()] if calls_path.exists() else []
        want, reason = CASES[case]
        output = result.stdout + result.stderr
        problems = []
        if result.returncode != want:
            problems.append(f'rc={result.returncode} want={want}')
        if reason and not any(reason in line for line in output.splitlines()):
            problems.append('нет причины ' + reason)
        if want == 1:
            if after != before:
                problems.append('отказ изменил HEAD/теги/контракт/вердикт/реестр')
            if case in ('no-context', 'wrong-origin', 'wrong-project', 'wrong-subject', 'ambiguous-context') and calls:
                problems.append('gh вызван до валидации контекста')
        else:
            tag = run(['git', '-C', station, 'rev-parse', '--verify', TAG + '^{commit}'])
            if tag.returncode or tag.stdout.strip() != before[station][0]:
                problems.append('тег не на исходном HEAD станции')
            registry = station / 'registry/contracts.tsv'
            tag_sha = git(station, 'rev-parse', '--verify', TAG) if not tag.returncode else ''
            if not registry.exists() or registry.read_text() != f'731 → {tag_sha}\n':
                problems.append('реестр не в станции/не совпал с tag-object')
            if after[station][2][TARGET] != before[station][2][TARGET] or after[station][2]['verdicts/critic/contracts-731-v1.md'] != before[station][2]['verdicts/critic/contracts-731-v1.md']:
                problems.append('контракт/вердикт станции изменён')
            if product != station and after[product] != before[product]:
                problems.append('запись ушла в проект')
        if case not in ('no-context', 'wrong-origin', 'wrong-project', 'wrong-subject', 'ambiguous-context'):
            if not calls or any(c != ['secret', 'list', '-R', origin] for c in calls):
                problems.append('инвентарь не из project origin: ' + repr(calls))
        return not problems, result.returncode, problems, output


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--repo', type=Path, default=TREE)
    p.add_argument('--model', action='store_true')
    p.add_argument('--stabs', action='store_true')
    args = p.parse_args()
    if args.stabs:
        caught = 0
        for mutant, case in STABS.items():
            control, _, errors, output = observe(args.repo.resolve(), case, 'model')
            if not control:
                print('NOT_IMPLEMENTED: негодный честный контроль ' + case, errors, output)
                return 2
            ok, rc, problems, _ = observe(args.repo.resolve(), case, 'model', mutant)
            caught += not ok
            print(f'STAB {mutant} CELL {case}: rc={rc} ' + ('ПОЙМАН' if not ok else 'ЖИВ'))
        print(f'ROOTS122 STABS={len(STABS)} CAUGHT={caught}')
        return int(caught != len(STABS))
    green = 0
    for case in CASES:
        ok, rc, problems, output = observe(args.repo.resolve(), case, 'model' if args.model else 'repo')
        green += ok
        print(f'ROOTS122 {case}: rc={rc} ' + ('ЗЕЛЁНАЯ' if ok else 'КРАСНАЯ ' + '; '.join(problems)))
        if not ok:
            print(output)
    print(f'ROOTS122 TOTAL={len(CASES)} GREEN={green} RED={len(CASES)-green}')
    return int(green != len(CASES))


if __name__ == '__main__':
    raise SystemExit(main())
