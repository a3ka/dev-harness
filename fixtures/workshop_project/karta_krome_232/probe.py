#!/usr/bin/env python3
"""232: real committed maps, real verdict CLI, literal pre-call expectations."""
import argparse
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
LIB = 'scripts/lib_karta_sdachi.sh'
EXPLICIT = 'без изменений с вызова 5'
PREVIOUS = 'без изменений с предыдущего вызова'
# Expectations are data, not a second parser of the subject's grammar.
TAILS = {
    'except': ', кроме команды зависимости 152, приведённой в блоке.',
    'semicolon-command': '; --stabs rc 0.',
    'semicolon-prose': '; новая граница Ф3 и зависимость 152 отражены в блоке К-03.',
    'old-empty': '', 'old-dot': '.', 'old-dash': ' — тот же класс',
    'old-dash-dot': ' — тот же класс.',
    'single-character': '; x.', 'except-character': ', кроме x.',
    'long': '; ' + 'доказательство ' * 6000 + 'x.',
}
BAD = {
    'arbitrary': ', потому что проверено.',
    'except-no-text': ', кроме',
    'no-comma-space': ',кроме текста.',
    'uppercase': ', КРОМЕ текста.',
    'double-space': ', кроме  текста.',
    'semicolon-double-space': ';  текст.',
    'except-empty': ', кроме .',
    'semicolon-empty': '; .',
    'except-no-dot': ', кроме текста',
    'semicolon-no-dot': '; текст',
    'newline': '; начало\nпродолжение.',
    'except-newline': ', кроме начала\nпродолжение.',
    'dot-except': '. кроме текста.',
    'missing-comma': ' кроме текста.',
    'dash-empty': ' — ',
    'semicolon-no-space': ';текст.',
    'except-trailing-space': ', кроме текста. ',
    'semicolon-tab': '; \t.',
}
CASES = {}
for form, prefix in (('number', EXPLICIT), ('previous', PREVIOUS)):
    for name, tail in TAILS.items():
        CASES[form + '-' + name] = dict(status=prefix + tail, rc=0)
    for name, tail in BAD.items():
        CASES[form + '-' + name] = dict(status=prefix + tail, rc=1,
                                      reason='К-05: ссылка вне грамматики')
CASES.update({
    'number-zero': dict(status='без изменений с вызова 000; текст.', rc=1,
                        reason='К-05: номер вызова вне грамматики'),
    'number-leading-zero': dict(status='без изменений с вызова 0005, кроме текста.', rc=0),
    'number-huge': dict(status='без изменений с вызова 100000000000000000000; текст.',
                        source='100000000000000000000', rc=0),
    'previous-leading-zero': dict(status=PREVIOUS + ', кроме текста.', current='0006', rc=0),
    'previous-huge': dict(status=PREVIOUS + '; текст.', current='100000000000000000001',
                          source='100000000000000000000', rc=0),
    'missing-number': dict(status='без изменений с вызова 99, кроме текста.', rc=1,
                          reason='отсутствует вызов 99 (К-05)'),
    'missing-previous': dict(status=PREVIOUS + '; текст.', source='4', rc=1,
                            reason='отсутствует вызов 5 (К-05)'),
    'inherit-same-class': dict(status=EXPLICIT + '; текст.', source_status='блок', resolved='блок', rc=0),
    'direct-except': dict(status='чисто — без изменений с вызова 99, кроме текста.', direct=True, rc=0),
    'direct-semicolon': dict(status='чисто — без изменений с вызова 5; текст.', direct=True,
                             source_status='блок', rc=0),
    'direct-empty': dict(status='чисто — ', rc=1, reason='К-05: чисто без команды или входа'),
    'unknown-status': dict(status='чисто в измеренных границах — вход: контроль', rc=1,
                           reason='статус вне алфавита'),
    # Raw live artifact is deliberately NOT repaired. See contract conflict.
    'live178-as-is': dict(live=True, rc=0),
})


def run(args, cwd=None):
    env = os.environ.copy()
    for key in tuple(env):
        if key.startswith('GIT_'):
            del env[key]
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
    return subprocess.run([str(x) for x in args], cwd=cwd, env=env,
                          capture_output=True, timeout=90)


def checked(args, cwd=None):
    p = run(args, cwd)
    if p.returncode:
        raise RuntimeError('NOT_IMPLEMENTED: ' + repr(args) + ': ' + repr(p.stderr))
    return p.stdout


def git(root, *args):
    return checked(['git', '-C', root, '-c', 'user.name=Fixture', '-c', 'user.email=fixture@local',
                    '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null', *args])


def put(root, path, data):
    file = root / path
    file.parent.mkdir(parents=True, exist_ok=True)
    file.write_bytes(data if isinstance(data, bytes) else data.encode())


def verdict(call, statuses=None, tema='777'):
    statuses = statuses or {}
    return ('accept\nOBJECT=' + 'a' * 40 + '\nСУД: предмет=' + tema +
            '; роль=critic; вызов=' + call + '/9;\n\n## Карта классов\n' +
            ''.join('К-%02d: %s\n' % (k, statuses.get(k, 'чисто — вход: честный контроль'))
                    for k in range(1, 18)))


def world(work, name, spec):
    root = work / name
    root.mkdir()
    git(root, 'init', '-q')
    source = spec.get('source', '5')
    tema = '178' if spec.get('live') else '777'
    put(root, 'verdicts/critic/contracts-' + tema + '-v1-source.md',
        verdict(source, {5: spec.get('source_status', 'чисто') + ' — вход: источник'}, tema))
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'independent historical source')
    target = 'verdicts/critic/contracts-' + tema + '-v1-krug6-fail.md'
    body = ((HERE / 'live178.md').read_bytes() if spec.get('live') else
            verdict(spec.get('current', '6'), {5: spec['status']}).encode())
    put(root, target, body)
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'committed verdict under test')
    head = git(root, 'rev-parse', 'HEAD')
    # Independent literal oracle is captured BEFORE invoking any subject.
    resolved = {5: spec.get('resolved', 'чисто')}
    if spec.get('live'):
        resolved = {2: 'блок', 3: 'блок', 7: 'блок'}
    expected_map = ''.join('К-%02d\t%s\n' % (k, resolved.get(k, 'чисто'))
                           for k in range(1, 18)).encode()
    return root, target, body, head, expected_map


def suite(candidate, names, tools_repo, label):
    red = 0
    with tempfile.TemporaryDirectory(prefix='karta232-', dir=REPO / 'tmp') as temp:
        work = Path(temp)
        tools = work / 'tools'
        shutil.copytree(tools_repo / 'scripts', tools / 'scripts')
        put(tools, LIB, candidate)
        checked(['bash', '-n', tools / LIB])
        for name in names:
            spec = CASES[name]
            root, target, body, head, expected_map = world(work, name, spec)
            p = run(['bash', tools / 'scripts/check_verdict_karta.sh', root, target])
            q = run(['bash', '-c',
                     'source "$1"; telo="$(git -C "$2" cat-file -p "HEAD:$3")"; '
                     'karta_proverit "$telo" "$2" "$3"', 'probe', tools / LIB, root, target])
            errors = []
            for tag, result in (('CLI', p), ('API', q)):
                if result.returncode not in (0, 1):
                    raise RuntimeError('SUBJECT_ERROR ' + name + ' ' + repr(result.stderr))
                if result.returncode != spec['rc']:
                    errors.append(tag + '_RC')
            if spec['rc'] == 0:
                if p.stdout != 'КАРТА: 17/17 зелёный\n'.encode() or p.stderr:
                    errors.append('CLI_OUTPUT')
                if q.stdout != expected_map or q.stderr:
                    errors.append('RESOLVED_MAP')
            else:
                reason = spec['reason'].encode()
                if reason not in p.stderr or p.stdout:
                    errors.append('CLI_REASON')
                if reason not in q.stdout or q.stderr:
                    errors.append('API_REASON')
            if git(root, 'rev-parse', 'HEAD') != head or git(root, 'show', 'HEAD:' + target) != body:
                errors.append('MUTATED_INPUT')
            if errors:
                red += 1
                print(label, name, 'RED', ','.join(errors), 'rc=', p.returncode,
                      'stderr=', repr(p.stderr), flush=True)
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
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--repo', type=Path)
    for mode in ('model', 'stabs', 'sintaksis', 'catalog', 'reachable'):
        group.add_argument('--' + mode, action='store_true')
    args = parser.parse_args()
    (REPO / 'tmp').mkdir(exist_ok=True)
    source, saved = carriers()
    model = saved['model/lib_karta_sdachi.sh']
    names = list(CASES)
    if args.catalog:
        print('KLETKI', len(names), 'STABY', len({x['stab'] for x in source['stab_vhod']}),
              'SVJAZI', len(source['stab_vhod']))
        print('\n'.join(names))
        return 0
    if args.sintaksis:
        shell = [HERE / p for p in saved if p.endswith('.sh')]
        shell.append(HERE / 'red_karta_krome_232.sh')
        for path in shell:
            checked(['bash', '-n', path])
        for path in (HERE / 'model/lib_karta_sdachi.sh', HERE / 'red_karta_krome_232.sh'):
            checked(['bash', REPO / 'scripts/validate_std.sh', 'bash', path])
        for path in (HERE / 'probe.py', HERE / 'build.py', HERE / 'context.py'):
            compile(path.read_bytes(), str(path), 'exec')
        print('SINTAKSIS', len(shell), 'SHELLCHECK', 2)
        return 0
    tools_repo = (args.repo or REPO).resolve()
    if args.stabs:
        # An explicit unresolved input is not silently declared green.
        reachable = [n for n in names if n != 'live178-as-is']
        if suite(model, reachable, tools_repo, 'CONTROL'):
            return 1
        alive = 0
        for link in source['stab_vhod']:
            alive += suite(saved[link['stab']], [link['case']], tools_repo, link['stab']) == 0
        print('STABY', len({x['stab'] for x in source['stab_vhod']}), 'SVJAZI', len(source['stab_vhod']),
              'ZHIVYH', alive, 'LIVE178_BLOCKED_BY_FROZEN193')
        return int(alive != 0)
    candidate = model if (args.model or args.reachable) else (tools_repo / LIB).read_bytes()
    if args.reachable:
        names.remove('live178-as-is')
        print('SCOPED_CONTROL_ONLY: live178-as-is remains mandatory and blocked')
    red = suite(candidate, names, tools_repo, 'MODEL' if args.model or args.reachable else 'REPO')
    print('KLETKI', len(names), 'KRASNYH', red)
    return int(red != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(2)
