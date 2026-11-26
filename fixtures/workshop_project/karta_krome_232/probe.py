#!/usr/bin/env python3
"""232: real Git, installed real doors, pre-call literal map and rc oracles."""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
POLICY = 'registry/karta-exceptions.json'
SCHEMA = 'registry/karta-exceptions.schema.json'
FILES = {'lib_karta_sdachi.sh': 'scripts/lib_karta_sdachi.sh',
         'pre_judge.sh': 'scripts/pre_judge.sh', 'karta_registry.py': 'scripts/karta_registry.py',
         'check_verdict_karta.sh': 'scripts/check_verdict_karta.sh',
         'karta-exceptions.schema.json': SCHEMA, 'karta-exceptions.json': POLICY}
CASES = {
    'live-registered': dict(live=True),
    'live-installed-default': dict(live=True, config='installed'),
    'live-empty': dict(live=True, config='empty', rc=1, reason='К-05: ссылка вне грамматики'),
    'live-absent': dict(live=True, config='absent', rc=1, reason='К-05: ссылка вне грамматики'),
    'foreign-sha': dict(live=True, config='foreign', rc=1, reason='К-05: ссылка вне грамматики'),
    'foreign-sha-prefix': dict(live=True, config='foreign-prefix', rc=1, reason='К-05: ссылка вне грамматики'),
    'changed-blob': dict(live=True, changed=True, rc=1, reason='К-05: ссылка вне грамматики'),
    'changed-other-path': dict(live=True, changed=True, other=True, rc=1, reason='К-05: ссылка вне грамматики'),
    'identical-other-path': dict(live=True, other=True),
    'index-call6': dict(live=True, operation='index'),
    'last-fail6': dict(live=True, operation='last'),
    'config-add-only': dict(live=True, sequence='add'),
    'config-remove-only': dict(live=True, sequence='remove'),
    'config-new-blob-only': dict(live=True, changed=True, new_entry=True, sequence='add'),
    'config-new-map-only': dict(status='чисто в измеренных границах — новый вход', new_entry=True, new_map=True),
    'honest-empty': dict(config='empty'),
    'honest-absent': dict(config='absent'),
    'honest-registry': {},
    'config-equivalent': dict(live=True, config='equivalent'),
    'subject-policy-bait': dict(live=True, config='empty', bait=True, rc=1, reason='К-05: ссылка вне грамматики'),
    'subject-empty-bait': dict(live=True, bait=True),
    'invalid-json': dict(config='invalid', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'unreadable-registry': dict(config='directory', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'schema-missing': dict(config='schema-missing', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'schema-invalid': dict(config='schema-invalid', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'wrong-version': dict(config='version', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'duplicate-sha': dict(live=True, config='duplicate', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'duplicate-json-key': dict(config='duplicate-key', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'prefix-sha': dict(live=True, config='prefix', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'uppercase-sha': dict(live=True, config='uppercase', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'mask-sha': dict(live=True, config='mask', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'repaint-block': dict(live=True, config='block', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'repaint-reference': dict(live=True, config='reference', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'change-reference-target': dict(live=True, config='target', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'change-tail': dict(live=True, config='tail', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'bad-normalized-grammar': dict(live=True, config='grammar', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'missing-normalized-class': dict(live=True, config='class', rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'change-call': dict(config='call', numeric_entry=True, rc=1, reason='KARTA_REGISTRY_INVALID:'),
    'unregistered-comma': dict(status='без изменений с вызова 5, кроме текста.', rc=1, reason='К-05: ссылка вне грамматики'),
    'unregistered-semicolon': dict(status='без изменений с вызова 5; текст.', rc=1, reason='К-05: ссылка вне грамматики'),
    'unregistered-clean-qualifier': dict(status='чисто в измеренных границах — контроль', rc=1, reason='статус вне алфавита'),
    'old-reference': dict(status='без изменений с вызова 5.'),
    'old-reference-dash': dict(status='без изменений с вызова 5 — пояснение'),
    'pj-honest-accept': dict(pj=True, call='1'),
    'pj-honest-fail': dict(pj=True, decision='FAIL', call='2'),
    'pj-invalid-accept': dict(pj=True, status='чисто', call='1', rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-invalid-fail': dict(pj=True, status='чисто', decision='FAIL', call='1', rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-invalid-call2': dict(pj=True, status='чисто', decision='FAIL', call='2', rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-live-registered': dict(pj=True, live=True),
    'pj-live-unregistered': dict(pj=True, live=True, config='empty', rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-local-fake': dict(pj=True, status='чисто', fake=True, rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-no-skip-flag': dict(pj=True, status='чисто', flags=['--skip-karta'], rc=2, reason='использование:'),
    'pj-timeout-not-bypass': dict(pj=True, status='чисто', flags=['--timeout', '0'], rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-role-bypass': dict(pj=True, status='чисто', role='reviewer', rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-other-role-unchanged': dict(pj=True, other_role=True),
    'pj-new-honest': dict(pj=True, call='1', commit_equivalence=True),
    'pj-new-invalid': dict(pj=True, status='чисто', rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-replace-invalid': dict(pj=True, replace=True, staged=True, call='1', status='чисто', rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-replace-honest': dict(pj=True, replace=True, call='1', staged=True, commit_equivalence=True),
    'pj-index-different': dict(pj=True, index_different=True, rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-index-text-normalized': dict(pj=True, call='1', index_bytes='crlf', text=True,
                                    stage_sequence=True, rc=1, reason='KARTA_NE_SHTATNA',
                                    detail='индекс отличается от --file'),
    'pj-index-text-lf': dict(pj=True, call='1', index_bytes='lf', text=True,
                            stage_sequence=True, commit_equivalence=True),
    'pj-index-crlf-raw': dict(pj=True, call='1', index_bytes='crlf',
                             stage_sequence=True, commit_equivalence=True),
    'pj-file-missing': dict(pj=True, missing=True, rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-outside-critic': dict(pj=True, outside=True, rc=1, reason='KARTA_NE_SHTATNA'),
    'pj-nonjudicial-branch': dict(pj=True, role='author', rc=1, reason='NE_SUDJSKAJA_VETKA'),
    'pj-adversary-unchanged': dict(pj=True, other_role=True, role='adversary'),
    'pj-arbiter-unchanged': dict(pj=True, other_role=True, role='arbiter'),
    'content-new-honest': dict(content=True, commit_equivalence=True),
    'content-new-invalid': dict(content=True, status='чисто', rc=1, reason='статус вне алфавита'),
    'content-live-uncommitted': dict(content=True, live=True, commit_equivalence=True),
    'content-changed-byte': dict(content=True, live=True, changed=True, rc=1, reason='К-05: ссылка вне грамматики'),
    'content-replacement-invalid': dict(content=True, replace=True, status='чисто', rc=1, reason='статус вне алфавита'),
}


def run(args, cwd=None):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               PYTHONDONTWRITEBYTECODE='1', SDACHA_OKRUG='1')
    return subprocess.run([str(x) for x in args], cwd=cwd, env=env,
                          capture_output=True, timeout=90)


def checked(args, cwd=None):
    p = run(args, cwd)
    if p.returncode:
        raise RuntimeError('NOT_IMPLEMENTED: ' + repr(args) + ': ' + repr(p.stdout) + ': ' + repr(p.stderr))
    return p.stdout


def git(root, *args):
    return checked(['git', '-C', root, '-c', 'user.name=Fixture', '-c', 'user.email=fixture@local',
                    '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null', *args])


def put(root, path, body):
    p = root / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(body if isinstance(body, bytes) else body.encode())


def verdict(call='6', statuses=None, decision='accept'):
    statuses = statuses or {}
    return (decision + '\nOBJECT=' + 'a' * 40 + '\nСУД: предмет=178; роль=critic; вызов=' + call + ';\n\n'
            '## Карта классов\n' + ''.join('К-%02d: %s\n' %
            (k, statuses.get(k, 'чисто — вход: честный контроль')) for k in range(1, 18))).encode()


def installed(work, tools_repo, overlay):
    tools = work / 'installation'
    shutil.copytree(tools_repo / 'scripts', tools / 'scripts')
    shutil.copytree(tools_repo / 'ops/server', tools / 'ops/server')
    for path in (POLICY, SCHEMA):
        if (tools_repo / path).is_file():
            put(tools, path, (tools_repo / path).read_bytes())
    for name, body in overlay.items():
        put(tools, FILES[name], body)
    return tools


def world(work, spec, tools, saved):
    root = work / 'subject'
    root.mkdir()
    role = spec.get('role', 'reviewer' if spec.get('other_role') else 'critic')
    git(root, 'init', '-q', '-b', 'wip/178/' + role)
    put(root, 'verdicts/critic/contracts-178-v1-source.md', verdict('5'))
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'source call 5')
    target = 'verdicts/critic/contracts-178-v1-krug6-fail.md'
    if spec.get('other'):
        target = 'verdicts/critic/contracts-178-v1-other.md'
    if spec.get('other_role'):
        target = 'verdicts/review/contracts-178-impl-v1.md'
    if spec.get('outside'):
        target = 'verdicts/review/contracts-178-impl-v1.md'
    body = (saved['live178.md'] if spec.get('live') else
            verdict(spec.get('call', '6'), {5: spec.get('status', 'чисто — вход: контроль')},
                    spec.get('decision', 'accept')))
    if spec.get('changed'):
        body += b'\n'
    if spec.get('index_bytes'):
        body = verdict('1') + (b'\n## Other\nline\r\n' if spec['index_bytes'] == 'crlf'
                               else b'\n## Other\nline\n')
    if spec.get('text'):
        put(root, '.gitattributes', 'verdicts/critic/*.md text\n')
    precommit = spec.get('pj') or spec.get('content')
    if spec.get('replace'):
        put(root, target, verdict(spec.get('call', '6')))
        git(root, 'add', target)
        git(root, 'commit', '-qm', 'previous valid target')
    put(root, target, body)
    if not precommit:
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'unchanged historical verdict')
    policy = json.loads(saved['model/karta-exceptions.json'])
    mode = spec.get('config', '')
    if spec.get('numeric_entry'):
        entry = policy['exceptions'][0]
        entry['blob'] = git(root, 'rev-parse', 'HEAD:' + target).decode().strip()
        entry['map'] = verdict().decode().split('## Карта классов\n')[1].splitlines()
        entry['map'][4] = 'К-05: чисто — вход: контроль'
        entry['call'] = '7'
    if spec.get('new_entry'):
        entry = policy['exceptions'][0]
        entry['blob'] = git(root, 'rev-parse', 'HEAD:' + target).decode().strip()
        if spec.get('new_map'):
            entry['map'] = verdict(statuses={5: 'чисто — новый вход'}).decode().split('## Карта классов\n')[1].splitlines()
    entry = policy['exceptions'][0]
    if mode == 'empty': policy['exceptions'] = []
    if mode == 'foreign': entry['blob'] = 'f' * 40
    if mode == 'foreign-prefix': entry['blob'] = entry['blob'][:8] + '1' * 32
    if mode == 'version': policy['version'] = 2
    if mode == 'duplicate': policy['exceptions'].append(copy.deepcopy(entry))
    if mode == 'prefix': entry['blob'] = entry['blob'][:8]
    if mode == 'uppercase': entry['blob'] = entry['blob'].upper()
    if mode == 'mask': entry['blob'] = '*'
    if mode == 'block': entry['map'][1] = entry['map'][1].replace('блок —', 'чисто —')
    if mode == 'reference': entry['map'][4] = 'К-05: чисто — скрытая перекраска'
    if mode == 'target': entry['map'][4] = entry['map'][4].replace('вызова 5', 'вызова 4')
    if mode == 'tail': entry['map'][14] += ' подмена'
    if mode == 'grammar': entry['map'][14] = 'К-15: чисто'
    if mode == 'class': entry['map'].pop()
    if mode == 'schema-missing': (tools / SCHEMA).unlink(missing_ok=True)
    if mode == 'schema-invalid': put(tools, SCHEMA, 'not JSON')
    encoded = json.dumps(policy, ensure_ascii=False, indent=2 if mode != 'equivalent' else None)
    if mode == 'invalid': encoded = '{'
    if mode == 'duplicate-key': encoded = '{"version": 2, "version": 1, "exceptions": []}'
    if mode == 'absent':
        (tools / POLICY).unlink(missing_ok=True)
    elif mode == 'directory':
        (tools / POLICY).unlink(missing_ok=True)
        (tools / POLICY).mkdir(parents=True)
    elif mode != 'installed':
        put(tools, POLICY, encoded)
    if spec.get('bait'):
        put(root, POLICY, saved['model/karta-exceptions.json'] if mode == 'empty' else '{"version":1,"exceptions":[]}')
    if spec.get('fake'):
        put(root, 'scripts/check_verdict_karta.sh', '#!/bin/bash\nexit 0\n')
    if spec.get('operation') == 'index':
        target = 'verdicts/critic/contracts-178-v1-krug7.md'
        body = verdict('7', {k: 'без изменений с вызова 6.' for k in range(1, 18)})
        put(root, target, body)
    if spec.get('operation') == 'last':
        target = 'verdicts/critic/contracts-178-v1-krug7.md'
        body = verdict('7')
        put(root, target, body)
    if precommit:
        git(root, 'add', '-A', '--', '.', ':(exclude)' + target)
    else:
        git(root, 'add', '-A')
    git(root, 'commit', '--allow-empty', '-qm', 'world ready')
    if spec.get('staged'):
        git(root, 'add', target)
    if spec.get('index_different'):
        put(root, target, verdict('6', {5: 'чисто'}))
        git(root, 'add', target)
        put(root, target, body)
    if spec.get('missing'):
        (root / target).unlink()
    expected = ''.join('К-%02d\t%s\n' %
                      (k, 'блок' if spec.get('live') and k in (2, 3, 7) else 'чисто')
                      for k in range(1, 18)).encode()
    return root, target, body, git(root, 'rev-parse', 'HEAD'), expected


def observe(tools, root, target, spec, expected):
    rc = spec.get('rc', 0)
    errors = []
    if spec.get('content'):
        p = run(['bash', tools / 'scripts/check_verdict_karta.sh', root, '--file', target])
        if p.returncode not in (0, 1):
            raise RuntimeError('SUBJECT_ERROR: ' + repr(p.stderr))
        if p.returncode != rc: errors.append('CONTENT_RC')
        if rc == 0:
            if p.stdout != 'КАРТА: 17/17 зелёный\n'.encode() or p.stderr:
                errors.append('CONTENT_OUTPUT')
        elif spec['reason'].encode() not in p.stderr or p.stdout:
            errors.append('CONTENT_REASON')
        return errors, p
    if spec.get('pj'):
        p = run(['bash', tools / 'scripts/pre_judge.sh', 'verdict', '--repo', root,
                 '--file', target, *spec.get('flags', [])])
        if rc != 2 and p.returncode not in (0, 1):
            raise RuntimeError('SUBJECT_ERROR: ' + repr(p.stderr))
        if p.returncode != rc: errors.append('PJ_RC')
        if rc == 0:
            role = spec.get('role', 'reviewer' if spec.get('other_role') else 'critic')
            if p.stdout != ('VERDICT_BRANCH=wip/178/' + role + '\n').encode() or p.stderr:
                errors.append('PJ_OUTPUT')
        elif spec['reason'].encode() not in p.stderr or p.stdout:
            errors.append('PJ_REASON')
        if rc == 1 and spec['reason'] == 'KARTA_NE_SHTATNA':
            if not p.stderr.startswith(b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: KARTA_NE_SHTATNA\n') or 'карта не штатная'.encode() not in p.stderr:
                errors.append('PJ_REFUSAL_FORM')
        if spec.get('detail') and spec['detail'].encode() not in p.stderr:
            errors.append('PJ_DETAIL')
        return errors, p
    operation = 'karta_poslednij_fail "$2" "$3" "$telo"' if spec.get('operation') == 'last' else 'karta_proverit "$telo" "$2" "$3"'
    q = run(['bash', '-c', 'source "$1"; telo="$(git -C "$2" cat-file -p "HEAD:$3")"; ' + operation,
             'probe', tools / 'scripts/lib_karta_sdachi.sh', root, target])
    if q.returncode not in (0, 1):
        raise RuntimeError('SUBJECT_ERROR: ' + repr(q.stderr))
    if q.returncode != rc: errors.append('API_RC')
    if rc == 0:
        if q.stdout != expected or q.stderr: errors.append('RESOLVED_MAP')
    elif spec['reason'].encode() not in q.stdout or q.stderr:
        errors.append('API_REASON')
    if spec.get('operation') != 'last':
        p = run(['bash', tools / 'scripts/check_verdict_karta.sh', root, target])
        if p.returncode not in (0, 1): raise RuntimeError('SUBJECT_ERROR: ' + repr(p.stderr))
        if p.returncode != rc: errors.append('CLI_RC')
        if rc == 0:
            if p.stdout != 'КАРТА: 17/17 зелёный\n'.encode() or p.stderr: errors.append('CLI_OUTPUT')
        elif spec['reason'].encode() not in p.stderr or p.stdout:
            errors.append('CLI_REASON')
    else:
        p = q
    return errors, p


def suite(overlay, names, tools_repo, saved, label):
    red = 0
    for name in names:
        spec = CASES[name]
        with tempfile.TemporaryDirectory(prefix='karta232-', dir=REPO / 'tmp') as temp:
            work = Path(temp)
            tools = installed(work, tools_repo, overlay)
            root, target, body, head, expected = world(work, spec, tools, saved)
            original_file = (root / target).read_bytes() if (root / target).exists() else None
            original_index = git(root, 'ls-files', '--stage', '--', target)
            before = {p.name: p.read_bytes() for p in (tools / 'scripts').iterdir() if p.is_file()}
            if spec.get('stage_sequence'):
                first_errors, first = observe(tools, root, target, dict(spec, rc=0, detail=''), expected)
                if (git(root, 'rev-parse', 'HEAD') != head or
                        (root / target).read_bytes() != original_file or
                        git(root, 'ls-files', '--stage', '--', target) != original_index):
                    first_errors.append('INPUT_MUTATED')
                git(root, 'add', '--', target)
                original_index = git(root, 'ls-files', '--stage', '--', target)
                staged = git(root, 'show', ':' + target)
                if (staged != body) != (spec.get('rc', 0) == 1):
                    raise RuntimeError('WORLD_ERROR: staging did not produce the declared byte relation')
                errors, p = observe(tools, root, target, spec, expected)
                errors += ['FIRST_' + x for x in first_errors]
                if first_errors:
                    print(label, name, 'INITIAL rc=', first.returncode,
                          'stdout=', repr(first.stdout), 'stderr=', repr(first.stderr), flush=True)
            elif spec.get('sequence'):
                policy = (tools / POLICY).read_bytes()
                empty = b'{"version":1,"exceptions":[]}'
                first, last = (empty, policy) if spec['sequence'] == 'add' else (policy, empty)
                put(tools, POLICY, first)
                first_spec = dict(spec, rc=1, reason='К-05: ссылка вне грамматики') if spec['sequence'] == 'add' else dict(spec, rc=0)
                first_errors, _ = observe(tools, root, target, first_spec, expected)
                put(tools, POLICY, last)
                last_spec = dict(spec, rc=0) if spec['sequence'] == 'add' else dict(spec, rc=1, reason='К-05: ссылка вне грамматики')
                errors, p = observe(tools, root, target, last_spec, expected)
                errors += ['FIRST_' + x for x in first_errors]
            else:
                errors, p = observe(tools, root, target, spec, expected)
            if before != {p.name: p.read_bytes() for p in (tools / 'scripts').iterdir() if p.is_file()}:
                errors.append('CODE_MUTATED')
            actual_file = (root / target).read_bytes() if (root / target).exists() else None
            if git(root, 'rev-parse', 'HEAD') != head or actual_file != original_file:
                errors.append('INPUT_MUTATED')
            if git(root, 'ls-files', '--stage', '--', target) != original_index:
                errors.append('INDEX_MUTATED')
            if spec.get('commit_equivalence'):
                # Only the checker commits, after observing no subject mutation.
                raw = run(['bash', tools / 'scripts/check_verdict_karta.sh', root, '--file', target])
                git(root, 'add', target)
                git(root, 'commit', '-qm', 'materialize exactly checked file')
                committed = git(root, 'show', 'HEAD:' + target)
                head_result = run(['bash', tools / 'scripts/check_verdict_karta.sh', root, target])
                if committed != body or (raw.returncode, raw.stdout, raw.stderr) != (head_result.returncode, head_result.stdout, head_result.stderr):
                    errors.append('COMMIT_IDENTITY')
                if head_result.returncode != 0:
                    errors.append('COMMITTED_RC')
            if errors:
                red += 1
                print(label, name, 'RED', ','.join(errors), 'rc=', p.returncode,
                      'stdout=', repr(p.stdout), 'stderr=', repr(p.stderr), flush=True)
    return red


def carriers():
    source = json.loads((HERE / 'source.json').read_text())
    saved = {}
    for path, digest in source['sha256'].items():
        data = (HERE / path).read_bytes()
        if hashlib.sha256(data).hexdigest() != digest:
            raise RuntimeError('ORACLE_TAMPERED: ' + path)
        saved[path] = data
    links = source['stab_vhod']
    canon = ''.join(x['stab'] + '\t' + x['case'] + '\n' for x in links).encode()
    if (HERE / 'stabs.tsv').read_bytes() != canon or any(x['case'] not in CASES for x in links):
        raise RuntimeError('ORACLE_TAMPERED: stabs.tsv/case')
    return source, saved


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--repo', type=Path)
    for mode in ('model', 'stabs', 'sintaksis', 'catalog'):
        group.add_argument('--' + mode, action='store_true')
    args = parser.parse_args()
    (REPO / 'tmp').mkdir(exist_ok=True)
    source, saved = carriers()
    model = {name: saved['model/' + name] for name in FILES}
    names = list(CASES)
    stabs = sorted({x['stab'] for x in source['stab_vhod']})
    if args.catalog:
        print('KLETKI', len(names), 'STABY', len(stabs), 'SVJAZI', len(source['stab_vhod']))
        print('\n'.join(names))
        return 0
    if args.sintaksis:
        shell = [HERE / p for p in saved if p.endswith('.sh')]
        shell.append(HERE / 'red_karta_krome_232.sh')
        for path in shell: checked(['bash', '-n', path])
        for path in [HERE / 'model/lib_karta_sdachi.sh', HERE / 'model/pre_judge.sh', HERE / 'model/check_verdict_karta.sh', HERE / 'red_karta_krome_232.sh']:
            checked(['bash', REPO / 'scripts/validate_std.sh', 'bash', path])
        checked(['bash', REPO / 'scripts/validate_std.sh', 'json', HERE / 'model/karta-exceptions.schema.json', HERE / 'model/karta-exceptions.json'])
        for path in [HERE / 'probe.py', HERE / 'build.py', HERE / 'context.py', HERE / 'verify.py', HERE / 'reproduce.py', HERE / 'index_filter.py', *[HERE / p for p in saved if p.endswith('.py')]]:
            compile(path.read_bytes(), str(path), 'exec')
        print('SINTAKSIS', len(shell), 'SHELLCHECK', 4, 'JSON_SCHEMA', 1)
        return 0
    tools_repo = (args.repo or REPO).resolve()
    if args.stabs:
        if suite(model, names, tools_repo, saved, 'CONTROL'): return 1
        alive = 0
        for link in source['stab_vhod']:
            candidate = dict(model)
            for name in FILES:
                path = 'stabs/' + link['stab'] + '/' + name
                if path in saved: candidate[name] = saved[path]
            alive += suite(candidate, [link['case']], tools_repo, saved, link['stab']) == 0
        print('STABY', len(stabs), 'SVJAZI', len(source['stab_vhod']), 'ZHIVYH', alive)
        return int(alive != 0)
    overlay = model if args.model else {}
    red = suite(overlay, names, tools_repo, saved, 'MODEL' if args.model else 'REPO')
    print('KLETKI', len(names), 'KRASNYH', red)
    return int(red != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, subprocess.TimeoutExpired) as e:
        print('NOT_IMPLEMENTED:', e, file=sys.stderr)
        sys.exit(2)
