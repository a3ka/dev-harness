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
from live_control import suite as observer_suite
import matrix

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


# Селекторы матрицы (исполнение арбитража 206): neg — строки, обязанные
# краснеть на мутанте, ctl — честный разрешённый контроль ТОГО ЖЕ
# представления, обязанный оставаться зелёным на том же мутанте. Оси строк
# назначает matrix.py миром до вызова субъекта; ответ субъекта ожиданием
# не считается. Значение-кортеж в предикате — принадлежность множеству.
def _S(**spec):
    def pred(axes):
        for key, value in spec.items():
            if isinstance(value, tuple):
                if axes.get(key) not in value:
                    return False
            elif axes.get(key) != value:
                return False
        return True
    return pred

GUARD_CP_NEG = _S(op='cp', sign='neg'), _S(op='cp', sign='pos')
GUARD_BIN_ABS = _S(group='main', bin='abs', sign='neg'), _S(group='main', bin='abs', sign='pos')
GUARD_ALL_NEG = _S(sign='neg'), _S(sign='pos')
VERDICT_OUTSIDE = _S(group='verdict', side='outside'), _S(group='verdict', side='inside')
VERDICT_REL_OUTSIDE = _S(group='verdict', base='rel', side='outside'), _S(group='verdict', base='rel', side='inside')
VERDICT_REL_INSIDE = _S(group='verdict', base='rel', side='inside'), _S(group='verdict', base='abs', side='inside')
_SYMLINK_FORMS = ('dir-symlink', 'file-symlink')
VERDICT_REL_SYMLINK = (_S(group='verdict', base='rel', side='outside', form=_SYMLINK_FORMS),
                       _S(group='verdict', base='rel', side='inside', form=_SYMLINK_FORMS))
VERDICT_ABS_SYMLINK = (_S(group='verdict', base='abs', side='outside', form=_SYMLINK_FORMS),
                       _S(group='verdict', base='abs', side='inside', form=_SYMLINK_FORMS))

# Mutations remove/replace reference operations. Each binding names a distinguishable input;
# шестое поле — селектор матрицы (kind, neg, ctl) или None: строки, обязанные краснеть
# на мутанте, и честный разрешённый контроль того же представления, обязанный
# оставаться зелёным на нём (арбитраж 206; привязка по позициям кода, Н-39).
MUTATIONS = [
    ('cp-source-is-write', 'guard-cp-read-state', '.omp/extensions/path-guard.ts', "if (paths.length >= 2) pushOp(paths[paths.length - 1]);", 'for (const path of paths) pushOp(path);', None),
    ('cp-no-destination', 'guard-cp-outside', '.omp/extensions/path-guard.ts', "if (paths.length >= 2) pushOp(paths[paths.length - 1]);", '/* destination forgotten */', ('guard',) + GUARD_CP_NEG),
    ('mkdir-no-operands', 'guard-mkdir-outside', '.omp/extensions/path-guard.ts', "if (head === 'mkdir') {", "if (head === 'mkdir-disabled') {", None),
    ('absolute-cp-ignored', 'guard-cp-absolute-outside', '.omp/extensions/path-guard.ts', "const head = argv[0].split('/').pop() ?? argv[0];", 'const head = argv[0];', ('guard', _S(group='main', op='cp', bin='abs', sign='neg'), _S(group='main', op='cp', bin='abs', sign='pos'))),
    ('absolute-mkdir-ignored', 'guard-mkdir-absolute-outside', '.omp/extensions/path-guard.ts', "const head = argv[0].split('/').pop() ?? argv[0];", 'const head = argv[0];', ('guard', _S(group='main', op='mkdir', bin='abs', sign='neg'), _S(group='main', op='mkdir', bin='abs', sign='pos'))),
    ('own-copy-removed', 'guard-write-own', '.omp/extensions/path-guard.ts', 'canonicalSessionCwd !== null &&', 'false && canonicalSessionCwd !== null &&', None),
    ('owner-not-compared', 'guard-owner-foreign', '.omp/extensions/path-guard.ts', 'if (ownerId !== sessionName) return false;', '/* owner comparison omitted */', None),
    ('ancestor-not-checked', 'guard-symlink-outside', '.omp/extensions/path-guard.ts', 'realAncestorWithin(canonicalSessionCwd, resolved)', 'true', None),
    ('cwd-not-required', 'guard-mkdir-no-cwd', '.omp/extensions/path-guard.ts', 'if (!cwd) {', "if (!cwd) return {decision:'pass'}; if (!cwd) {", None),
    ('quoted-text-is-write', 'guard-quoted-greater', '.omp/extensions/path-guard.ts', "if (!isWriteCommand(cmd)) return { decision: 'pass' };", "if (!isWriteCommand(cmd)) return {decision:'block',reason:'text treated as write'};", None),
    ('diagnostic-hint-lost', 'guard-mkdir-no-cwd', '.omp/extensions/path-guard.ts', "reason: result.reason + '\\n' +", 'reason: result.reason +', None),
    ('nul-ignored', 'guard-nul', '.omp/extensions/path-guard.ts', "if (cmd.includes('\\0'))", 'if (false)', None),
    ('verdict-branch-ignored', 'verdict-author', 'scripts/pre_judge.sh', "'^wip/[0-9]{3}/(critic|adversary|reviewer|arbiter)$'", "'.*'", None),
    ('verdict-hint-lost', 'verdict-detached', 'scripts/pre_judge.sh', "NE_SUDJSKAJA_VETKA) printf 'ФОРМА:", "UNREACHABLE) printf 'ФОРМА:", None),
    ('verdict-main-ignored', 'verdict-main', 'scripts/pre_judge.sh', 'refuse VERDIKT_V_MAIN', ': VERDIKT_V_MAIN', None),
    ('verdict-outside-ignored', 'verdict-outside', 'scripts/pre_judge.sh', 'refuse VERDIKT_VNE_REPO "файл вердикта вне репозитория: $VFILE"', 'VREL=verdicts/fake.md', ('verdict',) + VERDICT_OUTSIDE),
    *[(f'role-{role}-no-rule', f'role-{role}', f'roles/{role}.md', model.NORM, 'Судья пишет в WORKTREE задания.', None) for role in model.ROLES],
    ('hint-refuse', 'guard-pin-mismatch', '.omp/extensions/path-guard.ts', "  if (result.decision === 'pass') return result;", "  if (result.decision === 'pass' || result.decision === 'refuse') return result;", None),
    ('boundary-no-inside', 'verdict-outside', 'scripts/pre_judge.sh', 'if path_inside "$vcanon" "$R" && [ "$vcanon" != "$R" ]; then', 'if [ "$vcanon" != "$R" ]; then', ('verdict',) + VERDICT_OUTSIDE),
    ('observer-no-sequence', 'observer-overlapping-judges', 'fixtures/workshop_project/sreda_sudji_206/live.py', 'if i <= previous or len(releases) != 1', 'if len(releases) != 1', None),
    ('options-after-separator', 'guard-cp-dash-outside', '.omp/extensions/path-guard.ts', "if (options && arg.startsWith('-')) continue;", "if (arg.startsWith('-')) continue;", None),
    ('mkdir-options-after-separator', 'guard-mkdir-dash-outside', '.omp/extensions/path-guard.ts', "if (options && arg.startsWith('-')) continue;", "if (arg.startsWith('-')) continue;", None),
    ('options-before-separator', 'guard-mkdir-flag-before-separator', '.omp/extensions/path-guard.ts', "if (options && arg.startsWith('-')) continue;", "/* options become operands */", None),
    ('mkdir-only-first-operand', 'guard-mkdir-multiple-outside', '.omp/extensions/path-guard.ts', 'for (const path of paths) pushOp(path);', 'if (paths.length) pushOp(paths[0]);', ('guard', _S(group='main', op='mkdir', position=('position-1', 'position-2'), sign='neg'), _S(op='mkdir', sign='pos'))),
    ('relative-boundary-ignored', 'verdict-relative-outside', 'scripts/pre_judge.sh', 'if path_inside "$vcanon" "$R" && [ "$vcanon" != "$R" ]; then', 'if { [[ "$VFILE" != /* ]] || path_inside "$vcanon" "$R"; } && [ "$vcanon" != "$R" ]; then', ('verdict',) + VERDICT_REL_OUTSIDE),
    ('relative-normalization-ignored', 'verdict-relative-parent-outside', 'scripts/pre_judge.sh', 'vcanon="$(realpath -m -- "$vcandidate")"', 'vcanon="$vcandidate"', ('verdict',) + VERDICT_REL_OUTSIDE),
    ('relative-symlink-ignored', 'verdict-relative-symlink-outside', 'scripts/pre_judge.sh', 'realpath -m -- "$vcandidate"', 'realpath -ms -- "$vcandidate"', ('verdict',) + VERDICT_REL_SYMLINK),
    ('observer-object-ignored', 'observer-different-objects', 'fixtures/workshop_project/sreda_sudji_206/live.py', "if any(start.get('object') != object_id for start in starts):", 'if False:', None),
    ('observer-object-not-assigned', 'observer-unassigned-object', 'fixtures/workshop_project/sreda_sudji_206/live.py', "if any(start.get('object') != object_id for start in starts):", "if len({start.get('object') for start in starts}) != 1:", None),
    ('observer-invalid-is-incomplete', 'observer-null', 'fixtures/workshop_project/sreda_sudji_206/live.py', "raise ValueError('NEVALIDNYJ_ZHURNAL')", "return 1, 'TRI_SUDA_NE_PREDJAVLENY'", None),
    ('observer-invalid-array-is-incomplete', 'observer-array', 'fixtures/workshop_project/sreda_sudji_206/live.py', "raise ValueError('NEVALIDNYJ_ZHURNAL')", "return 1, 'TRI_SUDA_NE_PREDJAVLENY'", None),
    ('observer-bom-accepted', 'observer-bom', 'fixtures/workshop_project/sreda_sudji_206/live.py', ".decode('utf-8').splitlines()", ".decode('utf-8-sig').splitlines()", None),
    ('absolute-symlink-ignored', 'verdict-absolute-file-symlink-outside', 'scripts/pre_judge.sh',
     '''  case "$VFILE" in
    /*) vcandidate="$VFILE" ;;
    *) vcandidate="$R/$VFILE" ;;
  esac
  vcanon="$(realpath -m -- "$vcandidate")" || skip 'не канонизирован --file'
''', '''  case "$VFILE" in
    /*) vcandidate="$VFILE" ;;
    *) vcandidate="$R/$VFILE" ;;
  esac
  case "$VFILE" in
    /*) vcanon="$(realpath -ms -- "$vcandidate")" || skip 'не канонизирован --file' ;;
    *) vcanon="$(realpath -m -- "$vcandidate")" || skip 'не канонизирован --file' ;;
  esac
''', ('verdict',) + VERDICT_ABS_SYMLINK),
    ('cp-trailing-slash-ignored', 'guard-cp-trailing-slash-live-state', '.omp/extensions/path-guard.ts',
     "if (paths.length >= 2) pushOp(paths[paths.length - 1]);",
     "if (paths.length >= 2) { const t = paths[paths.length - 1]; if (!t.endsWith('/')) pushOp(t); }",
     ('guard', _S(op='cp', tail='slash', sign='neg'), _S(op='cp', tail='slash', sign='pos'))),
    ('mkdir-absolute-slash-ignored', 'mkdir/bare/abs/slash/plain/state/no-dash/position-0', '.omp/extensions/path-guard.ts',
     'for (const path of paths) pushOp(path);',
     "for (const path of paths) if (!(path.startsWith('/') && path.endsWith('/'))) pushOp(path);",
     ('guard', _S(op='mkdir', base='abs', tail='slash', sign='neg'), _S(op='mkdir', base='abs', tail='slash', sign='pos'))),
    ('write-command-basename-ignored', 'cp/abs/abs/noslash/plain/state/no-dash/last', '.omp/extensions/path-guard.ts',
     "if (['cp', 'mkdir'].includes(first.split('/').pop() ?? '')) return true;",
     "if (['cp', 'mkdir'].includes(first)) return true;",
     ('guard',) + GUARD_BIN_ABS),
    ('mkdir-last-operand-only', 'mkdir/bare/abs/noslash/plain/state/no-dash/position-1', '.omp/extensions/path-guard.ts',
     'for (const path of paths) pushOp(path);',
     'if (paths.length) pushOp(paths[paths.length - 1]);',
     ('guard', _S(group='main', op='mkdir', position=('position-0', 'position-1'), sign='neg'), _S(group='main', op='mkdir', sign='pos'))),
    ('target-not-passed-to-judge', 'mkdir/bare/abs/noslash/plain/foreign/no-dash/position-0', '.omp/extensions/path-guard.ts',
     'if (!pathAllowed(resolved, canonicalWt, canonicalActual, worktree, sessionName, canonicalSessionCwd)) {',
     'if (false) {',
     ('guard',) + GUARD_ALL_NEG),
    ('verdict-relative-base-ignored', 'verdict/rel/plain/direct/inside', 'scripts/pre_judge.sh',
     '    *) vcandidate="$R/$VFILE" ;;',
     '    *) vcandidate="$VFILE" ;;',
     ('verdict',) + VERDICT_REL_INSIDE),
]

def suite(subject, sandbox, verbose=True, only=None):
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
        if only is not None and name != only:
            return
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
    guard_case('guard-cp-trailing-slash-live-state', 'bash', {'command': f'cp -- {state}/HANDOFF.md {state}/', 'cwd': str(copy)}, 'block', outside(f'{state}/'))
    guard_case('guard-cp-trailing-slash-scratch', 'bash', {'command': f'cp -- {state}/HANDOFF.md {copy}/scratch/', 'cwd': str(copy)})
    guard_case('guard-mkdir-outside', 'bash', {'command': f'mkdir -p {other}/new', 'cwd': str(copy)}, 'block', outside(other / 'new'))
    guard_case('guard-mkdir-absolute-outside', 'bash', {'command': f'/bin/mkdir -p {other}/new', 'cwd': str(copy)}, 'block', outside(other / 'new'))
    for command, label in [('cp', 'cp'), ('/bin/cp', 'absolute-cp')]:
        guard_case(f'guard-{label}-dash-outside', 'bash', {'command': f'{command} -- {state}/HANDOFF.md -outside', 'cwd': str(other)},
                   'block', f'запись в чекаут из непиннованной сессии запрещена — Н-85/А-122: путь {other}/-outside не в null-allowlist ({sandbox}/tmp/dev-harness-verify/**, artifact://)', {'worktree': None})
        guard_case(f'guard-{label}-dash-inside', 'bash', {'command': f'{command} -- {state}/HANDOFF.md -inside-ok', 'cwd': str(copy)})
    guard_case('guard-cp-flag-before-separator', 'bash', {'command': f'cp -x -- {state}/HANDOFF.md {copy}/scratch/dst', 'cwd': str(copy)})
    guard_case('guard-mkdir-flag-before-separator', 'bash', {'command': f'mkdir -p -- {copy}/scratch/flag-ok', 'cwd': str(other)})
    guard_case('guard-cp-multiple-sources', 'bash', {'command': 'cp -p -- -source other-source -inside-ok', 'cwd': str(copy)})
    for command, label in [('mkdir', 'mkdir'), ('/bin/mkdir', 'absolute-mkdir')]:
        guard_case(f'guard-{label}-dash-outside', 'bash', {'command': f'{command} -- -outside', 'cwd': str(other)},
                   'block', f'запись в чекаут из непиннованной сессии запрещена — Н-85/А-122: путь {other}/-outside не в null-allowlist ({sandbox}/tmp/dev-harness-verify/**, artifact://)', {'worktree': None})
        guard_case(f'guard-{label}-dash-inside', 'bash', {'command': f'{command} -p -- -inside-ok -another', 'cwd': str(copy)})
    guard_case('guard-mkdir-multiple-outside', 'bash', {'command': f'mkdir -- {copy}/scratch/allowed -outside', 'cwd': str(other)}, 'block', outside(other / '-outside'))
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
    (copy / 'filelink-abs.md').symlink_to(other / 'verdict.md')
    check('verdict-absolute-file-symlink-outside', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(copy / 'filelink-abs.md')], other, env),
          (1, b'', (f'ОТКАЗ: VERDIKT_VNE_REPO\nфайл вердикта вне репозитория: {copy}/filelink-abs.md\nФОРМА: --repo <своя-копия> --file <абсолют-вердикта-в-своей-копии>\n').encode()))
    check('verdict-absolute-inside', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(verdict)], other, env),
          (0, b'VERDICT_BRANCH=wip/206/reviewer\n', b''))
    for name, vfile in [('relative-outside', '../outside.md'),
                        ('relative-parent-outside', 'a/../../outside.md'),
                        ('relative-symlink-outside', 'escape/verdict.md'),
                        ('relative-file-symlink-outside', 'verdict-link.md')]:
        if name == 'relative-file-symlink-outside':
            (copy / vfile).symlink_to(other / 'verdict.md')
        check('verdict-' + name, run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', vfile], other, env),
              (1, b'', (f'ОТКАЗ: VERDIKT_VNE_REPO\nфайл вердикта вне репозитория: {vfile}\nФОРМА: --repo <своя-копия> --file <абсолют-вердикта-в-своей-копии>\n').encode()))
    (copy / 'verdict-link-inside.md').symlink_to(verdict)
    for name, vfile in [('relative-inside', str(verdict.relative_to(copy))),
                        ('relative-symlink-inside', 'verdict-link-inside.md'),
                        ('relative-normalized-inside', 'missing/../' + str(verdict.relative_to(copy)))]:
        check('verdict-' + name, run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', vfile], other, env),
              (0, b'VERDICT_BRANCH=wip/206/reviewer\n', b''))
    git(copy, 'switch', '-q', '-C', 'main')
    vrel = verdict.relative_to(copy)
    check('verdict-main', run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', str(verdict)], other, env), (1, b'', f'ОТКАЗ: VERDIKT_V_MAIN\nвердикт {vrel} уже в main (staged/committed)\n'.encode()))
    # Параметрическая матрица арбитража 206: настоящий --repo/--model/--stabs,
    # не отдельная демонстрация. Вердиктные строки идут на судейской ветке
    # (verdict-main выше уже отработал на main); ожидания назначены миром.
    git(copy, 'switch', '-q', '-C', 'wip/206/reviewer')
    verify = Path(env['TMPDIR']) / 'dev-harness-verify'
    matrix.prepare(copy, delivery, state, other, verify, sandbox)
    mrows = matrix.guard_rows(copy, delivery, state, other, verify, model.HINT)
    for name, ok in matrix.run_guard(guard, mrows, env, copy, only).items():
        check(name, ok, True)
    for name, ok in matrix.run_verdict(script, copy, matrix.verdict_rows(copy, other, sandbox),
                                       env, other, only).items():
        check(name, ok, True)
    check('state-unchanged', (state / 'HANDOFF.md').read_bytes(), before_state)
    check('foreign-unchanged', git(other, 'rev-parse', 'HEAD'), before_foreign)
    observer = subject / 'fixtures/workshop_project/sreda_sudji_206/live.py'
    for name, ok in observer_suite(observer, sandbox / 'observer', only).items():
        results[name] = ok
        if verbose:
            print(f'{name}: {"ZELEN" if ok else "KRASEN"}')
    if only is not None:
        if only not in results:
            raise RuntimeError(f'MUTATION_CELL_MISSING: {only}')
        return {only: results[only]}
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
            grows, vrows, selcopy, selother, selenv = _selector_world(tmp / 'selworld')
            caught = 0
            for n, (name, cell, path, old, new, selector) in enumerate(MUTATIONS):
                mutant = tmp / f'mutant-{n}'
                shutil.copytree(subject, mutant)
                target = mutant / path
                target.write_text(model.replace(target.read_text(), old, new))
                result = suite(mutant, tmp / f'world-{n}', False, cell)
                killed = not result[cell]
                note = ''
                if selector is not None:
                    kind, negpred, ctlpred = selector
                    rows = grows if kind == 'guard' else vrows
                    if kind == 'guard':
                        outcomes = matrix.run_guard(mutant / '.omp/extensions/path-guard.ts', rows, selenv, selcopy)
                    else:
                        subrows = [r for r in rows if negpred(r['axes']) or ctlpred(r['axes'])]
                        outcomes = matrix.run_verdict(mutant / 'scripts/pre_judge.sh', selcopy, subrows, selenv, selother)
                    neg = [r for r in rows if negpred(r['axes'])]
                    ctl = [r for r in rows if ctlpred(r['axes'])]
                    ok = (all(not outcomes[r['name']] for r in neg)
                          and all(outcomes[r['name']] for r in ctl))
                    note = (f' SELEKTOR neg={len(neg)} ctl={len(ctl)} '
                            f'krasnyh={sum(1 for v in outcomes.values() if not v)}:'
                            f'{"POIMAN" if ok else "ZHIV"}')
                    killed = killed and ok
                caught += killed
                print(f'{name}: {cell}: {"POIMAN" if killed else "ZHIV"}{note}')
            print(f'OBMANOK={len(MUTATIONS)} POIMANY={caught} ZHIVYH={len(MUTATIONS)-caught}')
            return int(caught != len(MUTATIONS))
        result = suite(subject, tmp / 'world')
        print(f'KLETKI={len(result)} ZELENYE={sum(result.values())} KRASNYE={len(result)-sum(result.values())}')
        return int(not all(result.values()))


def _selector_world(sandbox):
    """Общий мир селекторов --stabs: суд verdict не пишет, guard — чистая
    функция, поэтому один мир обслуживает всех мутантов. Судейская ветка
    wip/206/reviewer с закоммиченным вердиктом создана до прогонов."""
    home = sandbox / 'home'
    copy = home / 'wt/owner/m'
    init(copy)
    (copy.parent / '.omp-isolation-owner.json').write_text(json.dumps({'id': 'Judge206'}))
    (copy / 'scratch').mkdir()
    other = sandbox / 'foreign'
    init(other)
    state = sandbox / 'live-state'
    state.mkdir()
    (state / 'HANDOFF.md').write_text('selector-world\n')
    delivery = sandbox / 'wip-206-critic'
    git(other, 'worktree', 'add', '-q', '-b', 'wip/206/critic', str(delivery))
    verdict = copy / 'verdicts/reviewer/contracts-206-v1.md'
    verdict.parent.mkdir(parents=True)
    verdict.write_text('206 selector world verdict\n')
    git(copy, 'switch', '-q', '-C', 'wip/206/reviewer')
    git(copy, 'add', str(verdict))
    git(copy, '-c', 'user.name=reviewer', '-c', 'user.email=reviewer@dev-harness.local',
        'commit', '-q', '-m', 'verdict')
    (sandbox / 'tmp').mkdir(parents=True)
    env = dict(os.environ, HOME=str(home), TMPDIR=str(sandbox / 'tmp'),
               GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
    env.pop('WORKTREE', None)
    verify = Path(env['TMPDIR']) / 'dev-harness-verify'
    matrix.prepare(copy, delivery, state, other, verify, sandbox)
    return (matrix.guard_rows(copy, delivery, state, other, verify, model.HINT),
            matrix.verdict_rows(copy, other, sandbox), copy, other, env)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'NOT_IMPLEMENTED: {error}', file=sys.stderr)
        sys.exit(2)
