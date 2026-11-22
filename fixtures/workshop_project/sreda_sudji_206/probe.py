#!/usr/bin/env python3
"""206: real git/Node guard and pre_judge seams; byte oracles held in memory."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('reference206', HERE / 'model/build.py')
model = importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)


def run(argv, cwd, env=None):
    p = subprocess.run(argv, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    return p.returncode, p.stdout, p.stderr


def git(repo, *args):
    result = run(['git', '-C', str(repo), *args], ROOT)
    if result[0]:
        raise RuntimeError(f'GIT_INFRA: {args}: {result!r}')
    return result[1]


def init(repo):
    repo.mkdir(parents=True)
    git(repo, 'init', '-q', '-b', 'main')
    git(repo, '-c', 'user.name=fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-q', '--allow-empty', '-m', 'initial')


def jbytes(value):
    return (json.dumps(value, ensure_ascii=False, separators=(',', ':')) + '\n').encode()


# Mutations remove/replace reference operations. Each binding names a distinguishable input.
MUTATIONS = [
    ('cp-source-is-write', 'guard-cp-read-state', '.omp/extensions/path-guard.ts', "if (paths.length >= 2) pushOp(paths[paths.length - 1]);", 'for (const path of paths) pushOp(path);'),
    ('cp-no-destination', 'guard-cp-outside', '.omp/extensions/path-guard.ts', "if (paths.length >= 2) pushOp(paths[paths.length - 1]);", '/* destination forgotten */'),
    ('mkdir-no-operands', 'guard-mkdir-outside', '.omp/extensions/path-guard.ts', "if (head === 'mkdir') {", "if (head === 'mkdir-disabled') {"),
    ('absolute-cp-ignored', 'guard-cp-absolute-outside', '.omp/extensions/path-guard.ts', "const head = argv[0].split('/').pop() ?? argv[0];", 'const head = argv[0];'),
    ('absolute-mkdir-ignored', 'guard-mkdir-absolute-outside', '.omp/extensions/path-guard.ts', "const head = argv[0].split('/').pop() ?? argv[0];", 'const head = argv[0];'),
    ('own-copy-removed', 'guard-write-own', '.omp/extensions/path-guard.ts', 'canonicalSessionCwd !== null &&', 'false && canonicalSessionCwd !== null &&'),
    ('owner-not-compared', 'guard-owner-foreign', '.omp/extensions/path-guard.ts', 'if (ownerId !== sessionName) return false;', '/* owner comparison omitted */'),
    ('ancestor-not-checked', 'guard-symlink-outside', '.omp/extensions/path-guard.ts', 'realAncestorWithin(canonicalSessionCwd, resolved)', 'true'),
    ('cwd-not-required', 'guard-mkdir-no-cwd', '.omp/extensions/path-guard.ts', 'if (!cwd) {', "if (!cwd) return {decision:'pass'}; if (!cwd) {"),
    ('quoted-text-is-write', 'guard-quoted-greater', '.omp/extensions/path-guard.ts', "if (!isWriteCommand(cmd)) return { decision: 'pass' };", "if (!isWriteCommand(cmd)) return {decision:'block',reason:'text treated as write'};"),
    ('diagnostic-hint-lost', 'guard-mkdir-no-cwd', '.omp/extensions/path-guard.ts', "reason: result.reason + '\\n' +", 'reason: result.reason +'),
    ('nul-ignored', 'guard-nul', '.omp/extensions/path-guard.ts', "if (cmd.includes('\\0'))", 'if (false)'),
    ('verdict-branch-ignored', 'verdict-author', 'scripts/pre_judge.sh', "'^wip/[0-9]{3}/(critic|adversary|reviewer|arbiter)$'", "'.*'"),
    ('verdict-hint-lost', 'verdict-detached', 'scripts/pre_judge.sh', "NE_SUDJSKAJA_VETKA) printf 'ФОРМА:", "UNREACHABLE) printf 'ФОРМА:"),
    ('verdict-main-ignored', 'verdict-main', 'scripts/pre_judge.sh', 'refuse VERDIKT_V_MAIN', ': VERDIKT_V_MAIN'),
    ('verdict-outside-ignored', 'verdict-outside', 'scripts/pre_judge.sh', 'refuse VERDIKT_VNE_REPO "файл вердикта вне репозитория: $VFILE"', 'VREL=verdicts/fake.md'),
    *[(f'role-{role}-no-rule', f'role-{role}', f'roles/{role}.md', model.NORM, 'Судья пишет в WORKTREE задания.') for role in model.ROLES],
]

def suite(subject, sandbox, verbose=True):
    home = sandbox / 'home'
    copy = home / 'wt/owner/m'
    init(copy)
    ownerfile = copy.parent / '.omp-isolation-owner.json'
    ownerfile.write_text(json.dumps({'id': 'Judge206'}))
    (copy / 'scratch').mkdir()
    other = sandbox / 'foreign'
    init(other)
    state = sandbox / 'live-state'
    state.mkdir()
    (state / 'HANDOFF.md').write_text('live-state-bytes\n')
    (copy / 'escape').symlink_to(other, target_is_directory=True)
    delivery = sandbox / 'wip-206-critic'
    git(other, 'worktree', 'add', '-q', '-b', 'wip/206/critic', str(delivery))
    env = dict(os.environ, HOME=str(home), TMPDIR=str(sandbox / 'tmp'), GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
    env.pop('WORKTREE', None)
    results = {}
    guard = subject / '.omp/extensions/path-guard.ts'
    before_state = (state / 'HANDOFF.md').read_bytes()
    before_foreign = git(other, 'rev-parse', 'HEAD')

    def check(name, actual, expected):
        results[name] = actual == expected
        if verbose:
            print(f'{name}: {"ZELEN" if results[name] else "KRASEN"}')
            if not results[name]:
                print(f'  expected={expected!r}\n  actual={actual!r}')

    base = dict(worktree=str(delivery), skipActualCheck=True, sessionCwd=str(copy), sessionName='Judge206')

    def guard_case(name, tool, args, decision='pass', reason=None, extra=None):
        value = dict(base, tool=tool, args=args)
        value.update(extra or {})
        expected = {'decision': decision}
        if reason is not None:
            expected['reason'] = reason + '\n' + model.HINT
        actual = run(['node', str(guard), '--judge', json.dumps(value)], copy, env)
        if actual[0] != 0:
            raise RuntimeError(f'GUARD_INFRA: {name}: {actual!r}')
        check(name, actual, (0, jbytes(expected), b''))

    def outside(path):
        return f'запись вне пина запрещена — Н-85: путь {path} не входит в WORKTREE={delivery} и не в allowlist'

    guard_case('guard-write-own', 'write', {'path': str(copy / 'verdict.md')})
    guard_case('guard-edit-own', 'edit', {'path': str(copy / 'verdict.md')})
    guard_case('guard-mkdir-absolute', 'bash', {'command': f'mkdir -p {copy}/scratch/new'})
    guard_case('guard-mkdir-cwd', 'bash', {'command': 'mkdir -p scratch/new', 'cwd': str(copy)})
    guard_case('guard-mkdir-quoted', 'bash', {'command': f'mkdir -p "{copy}/scratch/space dir"', 'cwd': str(copy)})
    guard_case('guard-quoted-greater', 'bash', {'command': "printf '%s' 'report > result'"})
    guard_case('guard-empty-command', 'bash', {'command': ''})
    guard_case('guard-one-character', 'bash', {'command': 'mkdir -p x', 'cwd': str(copy)})
    guard_case('guard-lf-token', 'bash', {'command': f'mkdir -p "{copy}/scratch/line\nname"', 'cwd': str(copy)})
    guard_case('guard-nul', 'bash', {'command': 'mkdir -p a\0b', 'cwd': str(copy)}, 'block', 'Н-85: NUL в команде')
    for command, suffix in [('cp', ''), ('/bin/cp', '-absolute')]:
        guard_case('guard-cp-read-state' + suffix, 'bash', {'command': f'{command} -- {state}/HANDOFF.md {copy}/scratch/state.md', 'cwd': str(copy)})
        guard_case('guard-cp-outside' if not suffix else 'guard-cp-absolute-outside', 'bash', {'command': f'{command} -- {state}/HANDOFF.md {other}/leak.md', 'cwd': str(copy)}, 'block', outside(other / 'leak.md'))
    guard_case('guard-cp-quoted-outside', 'bash', {'command': f'cp "{state}/HANDOFF.md" "{other}/space name"', 'cwd': str(copy)}, 'block', outside(other / 'space name'))
    guard_case('guard-mkdir-outside', 'bash', {'command': f'mkdir -p {other}/new', 'cwd': str(copy)}, 'block', outside(other / 'new'))
    guard_case('guard-mkdir-absolute-outside', 'bash', {'command': f'/bin/mkdir -p {other}/new', 'cwd': str(copy)}, 'block', outside(other / 'new'))
    guard_case('guard-mkdir-no-cwd', 'bash', {'command': 'mkdir -p scratch/new'}, 'block', 'запись относительным путём без cwd запрещена — Н-85: используй cwd или абсолютный путь')
    guard_case('guard-state-write', 'write', {'path': str(state / 'HANDOFF.md')}, 'block', outside(state / 'HANDOFF.md'))
    guard_case('guard-foreign-worktree', 'write', {'path': str(other / 'bad')}, 'block', outside(other / 'bad'))
    guard_case('guard-owner-foreign', 'write', {'path': str(copy / 'bad')}, 'block', outside(copy / 'bad'), {'sessionName': 'OtherJudge'})
    guard_case('guard-owner-empty', 'write', {'path': str(copy / 'bad')}, 'block', outside(copy / 'bad'), {'sessionName': ''})
    guard_case('guard-symlink-outside', 'write', {'path': str(copy / 'escape/bad')}, 'block', outside(copy / 'escape/bad'))
    guard_case('guard-parent-outside', 'write', {'path': str(copy / '../bad')}, 'block', outside(copy / '../bad'))
    guard_case('guard-pin-mismatch', 'write', {'path': str(copy / 'bad')}, 'refuse', f'пинн WORKTREE не совпадает с фактическим рабочим деревом сессии (пин={delivery}, факт={copy})', {'skipActualCheck': False, 'actual': str(copy)})
    guard_case('guard-scratch-allowed', 'write', {'path': str(sandbox / 'tmp/dev-harness-verify/probe')})

    # Factory: real extension registration + actual lifecycle context; not a double of judge().
    driver = sandbox / 'factory.mjs'
    driver.write_text('''import register from %s;
const handlers = new Map(); register({on:(name, fn)=>handlers.set(name, fn)});
const data=JSON.parse(process.argv[2]);
const ctx={cwd:data.copy,sessionManager:{getSessionId:()=>"206-factory",getSessionFile:()=>data.copy+"/Judge206.jsonl",getBranch:()=>[{type:"message",message:{role:"user",content:[{type:"text",text:data.task}]}}]}};
handlers.get('session_start')({},ctx);
const result=handlers.get('tool_call')({toolName:'write',input:{path:data.copy+'/verdict.md'}},ctx);
process.stdout.write(JSON.stringify(result??null)+'\\n');
''' % json.dumps(guard.as_uri()))
    task = f'WORKTREE={delivery}\nBRANCH=wip/206/critic\n'
    check('factory-own-copy', run(['node', str(driver), json.dumps({'copy': str(copy), 'task': task})], other, env), (0, b'null\n', b''))

    script = subject / 'scripts/pre_judge.sh'
    for role in model.ROLES:
        branch = f'wip/206/{role}'
        git(copy, 'switch', '-q', '-C', branch)
        verdict = copy / f'verdicts/{role}/contracts-206-v1.md'
        verdict.parent.mkdir(parents=True, exist_ok=True)
        verdict.write_text(f'206 {role}: environment verdict\n')
        git(copy, 'add', str(verdict))
        git(copy, '-c', f'user.name={role}', '-c', f'user.email={role}@dev-harness.local', 'commit', '-q', '-m', 'verdict')
        expected = (0, f'VERDICT_BRANCH={branch}\n'.encode(), b'')
        check(f'verdict-{role}-committed', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(verdict)], other, env), expected)
        actual_author = git(copy, 'show', '-s', '--format=%an').decode().strip()
        check(f'identity-{role}', actual_author, role)
        text = (subject / f'roles/{role}.md').read_text()
        check(f'role-{role}', text.splitlines().count(model.NORM), 1)
    git(copy, 'switch', '-q', '-C', 'wip/206/architect')
    check('verdict-author', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(verdict)], other, env), (1, b'', ("ОТКАЗ: NE_SUDJSKAJA_VETKA\nветка 'wip/206/architect' не судейская\nФОРМА: в своей копии git switch -c wip/<NNN>/<роль>; не коммить в detached runtime-checkout\n").encode()))
    git(copy, 'switch', '-q', '--detach')
    check('verdict-detached', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(verdict)], other, env), (1, b'', ('ОТКАЗ: NE_SUDJSKAJA_VETKA\nветка \'отсоединённый HEAD\' не судейская\nФОРМА: в своей копии git switch -c wip/<NNN>/<роль>; не коммить в detached runtime-checkout\n').encode()))
    git(copy, 'switch', '-q', 'wip/206/reviewer')
    check('verdict-outside', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(other / 'verdict.md')], other, env), (1, b'', (f'ОТКАЗ: VERDIKT_VNE_REPO\nфайл вердикта вне репозитория: {other}/verdict.md\nФОРМА: --repo <своя-копия> --file <абсолют-вердикта-в-своей-копии>\n').encode()))
    git(copy, 'switch', '-q', '-C', 'main')
    vrel = verdict.relative_to(copy)
    check('verdict-main', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(verdict)], other, env), (1, b'', f'ОТКАЗ: VERDIKT_V_MAIN\nвердикт {vrel} уже в main (staged/committed)\n'.encode()))
    check('state-unchanged', (state / 'HANDOFF.md').read_bytes(), before_state)
    check('foreign-unchanged', git(other, 'rev-parse', 'HEAD'), before_foreign)
    return results


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--repo', type=Path)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    scratch = ROOT / '.scratch-206'
    scratch.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='probe.', dir=scratch) as tmp:
        tmp = Path(tmp)
        subject = args.repo.resolve() if args.repo else tmp / 'model'
        if not args.repo:
            model.materialize(ROOT, subject)
        if args.stabs:
            honest = suite(subject, tmp / 'honest', False)
            if not all(honest.values()):
                print('HONEST_CONTROL_RED', [k for k, v in honest.items() if not v])
                return 2
            caught = 0
            for n, (name, cell, path, old, new) in enumerate(MUTATIONS):
                mutant = tmp / f'mutant-{n}'
                shutil.copytree(subject, mutant)
                target = mutant / path
                target.write_text(model.replace(target.read_text(), old, new))
                result = suite(mutant, tmp / f'world-{n}', False)
                killed = not result[cell]
                caught += killed
                print(f'{name}: {cell}: {"POIMAN" if killed else "ZHIV"}')
            print(f'OBMANOK={len(MUTATIONS)} POIMANY={caught} ZHIVYH={len(MUTATIONS)-caught}')
            return int(caught != len(MUTATIONS))
        result = suite(subject, tmp / 'world')
        print(f'KLETKI={len(result)} ZELENYE={sum(result.values())} KRASNYE={len(result)-sum(result.values())}')
        return int(not all(result.values()))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'NOT_IMPLEMENTED: {error}', file=sys.stderr)
        sys.exit(2)
