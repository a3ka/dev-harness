#!/usr/bin/env python3
"""206 (Adv206c-4): систематический обход мутаций охранных предикатов.

«Поиск по одному» (один мутант — одна ручная клетка) ломается конечным
автоматом: sweep порождает ОДНОСТРОЧНЫЕ мутанты КАЖДОГО объявленного
охранного предиката path-guard.ts и pre_judge.sh — удаление/инверсия условия
if, замена &&<->||, удаление ветви continue/return/exit/refuse/skip/
case-альтернативы, замена сравнения — каждый на копии настоящего
subject-файла, и прогоняет батарею 206 пакетными драйверами одной сессией
(как matrix.py).

Объём мутации ограничен охранными предикатами пути допуска записи предмета
206: грамматика извлечения целей cp/mkdir, разрешение операнда в judgeBash,
ветви допуска pathAllowed/realAncestorWithin/isWithin/lexNormalize, граница
вердикта pre_judge (VFILE, нормализация, path_inside, main, судейская
ветка). Токенизатор, CLI, фабричная регистрация и диагностика — не предикаты
и не мутируются.

Эквивалентность прогонов полному `--repo <мутант>`: guard-мутант судится
всеми guard-зависимыми клетками батареи (статические guard-клетки + фабрика
+ матрица guard) одним пакетным вызовом; pre_judge-мутант — всеми
вердикт-зависимыми клетками (статические вердикт-клетки на тех же ветках +
матрица вердиктов). Семейства, не зависящие от мутанта по построению —
observer по НЕмутируемому live.py, identity/текстовые клетки ролей по
немутируемым roles/*.md, state-unchanged/foreign-unchanged при неисполняемых
батарея записях — не прогоняются: их исход совпадает с честным прогоном.

Выживший (батарея зелёная на мутанте) — либо эквивалент (EQUIVALENTS с
обоснованием по коду), либо дыра батареи → клетка + адресный стаб в
MUTATIONS (probe.py). `sweep.py --check` даёт rc 0 только при пустых списках
необъяснённых выживших и устаревших EQUIVALENTS. Авария синтаксиса мутанта — отдельный класс AVARIA:
не выживший и не поимка (норма арбитража 206: rc2/авария — не поимка).
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile
import time
from pathlib import Path

import matrix
import probe

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
TS_PATH = '.omp/extensions/path-guard.ts'
SH_PATH = 'scripts/pre_judge.sh'

# Охранные предикаты path-guard.ts (якорь = полная строка, кратность 1).
TS_PREDICATES = [
    # грамматика извлечения целей cp/mkdir (extractExtraWriteOperands)
    "if (head === 'cp' || head === 'mkdir') {",
    "if (options && arg === '--') { options = false; continue; }",
    "if (options && arg.startsWith('-')) continue;",
    "if (head === 'cp') {",
    "if (paths.length >= 2) pushOp(paths[paths.length - 1]);",
    "if (head === 'mkdir') {",
    # isWriteCommand: квалифицированное имя не превращает запись в чтение
    "if (['cp', 'mkdir'].includes(first.split('/').pop() ?? '')) return true;",
    # judgeBash: пустая команда, NUL, форма записи, URI-ветви, rel-без-cwd, общий суд
    "if (!cmd) return { decision: 'pass' };",
    "if (cmd.includes('\\0')) return { decision: 'block', reason: 'Н-85: NUL в команде' };",
    "if (!isWriteCommand(cmd)) return { decision: 'pass' };",
    "if (operands.length === 0) {",
    "if (canonicalWt !== null) continue;",
    "if (op === 'xd://report_issue') continue;",
    "if (op.startsWith('artifact://')) continue;",
    "if (op.startsWith('/')) {",
    "if (!cwd) {",
    "if (!pathAllowed(resolved, canonicalWt, canonicalActual, worktree, sessionName, canonicalSessionCwd)) {",
    # judgeEditWrite: относительный путь, URI-ветви pinned/unpinned, общий суд
    "if (!path.startsWith('/')) {",
    "if (canonicalWt !== null) return { decision: 'pass' };",
    "if (path === 'xd://report_issue') return { decision: 'pass' };",
    "if (path.startsWith('artifact://')) return { decision: 'pass' };",
    "if (pathAllowed(path, canonicalWt, canonicalActual, worktree, sessionName, canonicalSessionCwd)) return { decision: 'pass' };",
    # pathAllowed: ветви допуска (scratch, пин, unpinned-M1, своя копия)
    "if (isAllowedURI(resolved)) return true;",
    "if (isWithin(getVerifyBase(), normalized)) return true;",
    "if (canonicalWt !== null && isWithin(canonicalWt, normalized)) return true;",
    "worktree === null &&",
    "canonicalActual !== null &&",
    "canonicalSessionCwd !== null &&",
    # realAncestorWithin / isWithin / lexNormalize — границы разрешения
    "if (real !== null) return isWithin(base, real);",
    "if (slash <= 0) return false;",
    "return child === parent || child.startsWith(`${parent}/`);",
    "if (seg === '..') {",
    "if (seg === '' || seg === '.') continue;",
]

# Охранные предикаты pre_judge.sh на пути режима verdict (якорь = полная строка).
SH_PREDICATES = [
    "[ -n \"$VFILE\" ] || refuse NE_POLNYJ_VHOD",
    "command -v realpath >/dev/null 2>&1 || skip 'нет realpath'",
    "vcanon=\"$(realpath -m -- \"$vcandidate\")\" || skip 'не канонизирован --file'",
    "if path_inside \"$vcanon\" \"$R\" && [ \"$vcanon\" != \"$R\" ]; then",
    "refuse VERDIKT_VNE_REPO \"файл вердикта вне репозитория: $VFILE\"",
    "if [ \"$head_branch\" = 'main' ]; then",
    "if [ -n \"$staged\" ] || [ -n \"$committed\" ]; then",
    "refuse VERDIKT_V_MAIN \"вердикт $VREL уже в main (staged/committed)\"",
    "    || refuse NE_SUDJSKAJA_VETKA \"ветка '${head_branch:-отсоединённый HEAD}' не судейская\"",
    "[ \"$1\" = \"$2\" ] && return 0",
    "    \"$2\"/*) return 0 ;;",
    "  exit 1",
    "    /*) vcandidate=\"$VFILE\" ;;",
    "    *) vcandidate=\"$R/$VFILE\" ;;",
]

# Эквиваленты по коду: мутант меняет недостижимое/ненаблюдаемое в каноне
# батареи 206. Ключ — (файл, якорь, оператор): читаем и стабилен к сдвигу
# строк. Заполняется architect'ом по результатам прогона с обоснованием по
# коду и ловцом вне канона 206 либо явным отсутствием ловца.
TS = TS_PATH
SH = SH_PATH
EQUIVALENTS = {
    (TS, "if (!cmd) return { decision: 'pass' };", 'if-false'):
        'пустая команда не является формой записи: следующий предикат !isWriteCommand(\'\')=false возвращает тот же pass',
    (TS, 'if (operands.length === 0) {', 'if-false'):
        'ранний return pass при пустых операндах эквивалентен for-of по пустому массиву — тот же pass',
    (TS, 'if (!path.startsWith(\'/\')) {', 'if-false'):
        'относительный путь ИНСТРУМЕНТА записи блокируется дальше pathAllowed с иной причиной; ловца нет: инв. 1–6 не нарушены, все восемь регресс-батарей reviewer зелёные',
    (TS, 'if (slash <= 0) return false;', 'if-false'):
        'ветвь достижима через write /nonexist206/../<своя-копия>/x.md: честный guard блокирует, мутант зависает при поиске предка без «/»; pass не возникает, инв. 1–6 не нарушены, ловца зависания в каноне нет',
    (TS, 'if (isAllowedURI(resolved)) return true;', 'if-false'):
        'URI-операнды вне канона 206 (матрица и клетки несут только пути); ловец — батареи 025/030 (allowlist URI)',
    (TS, 'if (canonicalWt !== null) continue;', 'if-false'):
        'пиннованный bash-URI становится block (строже); ловца нет: URI вне канона 206, инв. 1–6 не нарушены, все восемь регресс-батарей reviewer зелёные',
    (TS, 'if (canonicalWt !== null) continue;', 'if-invert'):
        'ветвь внутри isAllowedURI(op); в каноне 206 нет URI-операндов — ловец батареи 025/030',
    (TS, 'if (canonicalWt !== null) continue;', 'del-continue'):
        'пиннованный bash-URI становится block (строже); ловца нет: URI вне канона 206, инв. 1–6 не нарушены, все восемь регресс-батарей reviewer зелёные',
    (TS, 'if (canonicalWt !== null) continue;', 'cmp-!=='):
        'ветвь внутри isAllowedURI(op); в каноне 206 нет URI-операндов — ловец батареи 025/030',
    (TS, "if (op === 'xd://report_issue') continue;", 'if-false'):
        'xd://report_issue не входит в канон входов 206; ловец — батарея 030 (Н-106)',
    (TS, "if (op === 'xd://report_issue') continue;", 'if-invert'):
        'xd://report_issue не входит в канон входов 206; ловец — батарея 030 (Н-106)',
    (TS, "if (op === 'xd://report_issue') continue;", 'del-continue'):
        'xd://report_issue не входит в канон входов 206; ловец — батарея 030 (Н-106)',
    (TS, "if (op === 'xd://report_issue') continue;", 'cmp-==='):
        'xd://report_issue не входит в канон входов 206; ловец — батарея 030 (Н-106)',
    (TS, "if (op.startsWith('artifact://')) continue;", 'if-false'):
        'artifact://-операнды вне канона 206; ловец — батарея 025 (artifact-allowlist)',
    (TS, "if (op.startsWith('artifact://')) continue;", 'if-invert'):
        'artifact://-операнды вне канона 206; ловец — батарея 025 (artifact-allowlist)',
    (TS, "if (op.startsWith('artifact://')) continue;", 'del-continue'):
        'artifact://-операнды вне канона 206; ловец — батарея 025 (artifact-allowlist)',
    (TS, "if (canonicalWt !== null) return { decision: 'pass' };", 'if-false'):
        'URI-ветвь judgeEditWrite; в каноне 206 нет URI-путей — ловец батарея 030',
    (TS, "if (canonicalWt !== null) return { decision: 'pass' };", 'if-invert'):
        'URI-ветвь judgeEditWrite; в каноне 206 нет URI-путей — ловец батарея 030',
    (TS, "if (canonicalWt !== null) return { decision: 'pass' };", 'cmp-!=='):
        'URI-ветвь judgeEditWrite; в каноне 206 нет URI-путей — ловец батарея 030',
    (TS, "if (path === 'xd://report_issue') return { decision: 'pass' };", 'if-false'):
        'xd-путь judgeEditWrite вне канона 206; ловец — батарея 030 (Н-106)',
    (TS, "if (path === 'xd://report_issue') return { decision: 'pass' };", 'if-invert'):
        'xd-путь judgeEditWrite вне канона 206; ловец — батарея 030 (Н-106)',
    (TS, "if (path === 'xd://report_issue') return { decision: 'pass' };", 'cmp-==='):
        'xd-путь judgeEditWrite вне канона 206; ловец — батарея 030 (Н-106)',
    (TS, "if (path.startsWith('artifact://')) return { decision: 'pass' };", 'if-false'):
        'artifact-путь judgeEditWrite вне канона 206; ловец — батарея 025',
    (TS, "if (path.startsWith('artifact://')) return { decision: 'pass' };", 'if-invert'):
        'artifact-путь judgeEditWrite вне канона 206; ловец — батарея 025',
    (TS, 'worktree === null &&', 'cmp-==='):
        'unpinned-ветка требует ещё canonicalActual!==null — во всех клетках 206 canonicalActual===null (skipActualCheck), а unpinned-клетки блокируются той же причиной; ловец — батарея 037 (М1 actual)',
    (TS, 'canonicalActual !== null &&', 'cmp-!=='):
        'при canonicalActual===null (весь канон 206) isSelfContainedCwdEligible(null) даёт false (statSync null/.git ENOENT) — ветка недостижима; ловец — батарея 037 (М1 actual)',
    (SH, '[ "$1" = "$2" ] && return 0', 'del-branch'):
        'равенство аргументов path_inside различимо только на VFILE==R, который отвергается отдельным неравенством [ vcanon != R ] до использования результата; второе использование (SOSTOJANIE, режим prepare) вне вердиктного канона 206',
}


def _if_span(line):
    """Индексы (start, end) условия первого `if (` в строке по балансу скобок."""
    i = line.find('if (')
    if i < 0:
        return None
    j = i + 3  # позиция '('; условие начинается строго после неё
    depth = 0
    for k in range(j, len(line)):
        if line[k] == '(':
            depth += 1
        elif line[k] == ')':
            depth -= 1
            if depth == 0:
                return (j + 1, k)
    return None


TS_COMPARE = [('cmp-===', r'(?<![!=])===(?!=)', '!=='), ('cmp-!==', r'(?<![=!])!==(?!=)', '==='),
              ('cmp->=', r'(?<![<>=!])>=(?!=)', '<'), ('cmp-<=', r'(?<![<>=!])<=(?!=)', '>'),
              ('cmp->', r'(?<![<>=!-])>(?![=>])', '<='), ('cmp-<', r'(?<![<>=!])<(?![<=])', '>=')]
SH_COMPARE = [('cmp--eq', ' -eq ', ' -ne '), ('cmp--ne', ' -ne ', ' -eq '),
              ('cmp--gt', ' -gt ', ' -le '), ('cmp--le', ' -le ', ' -gt '),
              ('cmp--ge', ' -ge ', ' -lt '), ('cmp--lt', ' -lt ', ' -ge '),
              ('cmp-=', ' = ', ' != '), ('cmp-!=', ' != ', ' = ')]


def ts_mutants(anchor):
    out = []
    span = _if_span(anchor)
    if span is not None:
        cond = anchor[span[0]:span[1]]
        out.append(('if-false', anchor[:span[0]] + 'false' + anchor[span[1]:]))
        out.append(('if-invert', anchor[:span[0]] + '!(' + cond + ')' + anchor[span[1]:]))
        rest = anchor[span[1]:].strip()
        if rest.startswith('return') and rest.endswith(';'):
            out.append(('del-return', anchor[:span[1]] + ' ;'))
    if 'continue;' in anchor:
        out.append(('del-continue', anchor.replace('continue;', ';', 1)))
    if ' && ' in anchor:
        out.append(('and-to-or', anchor.replace(' && ', ' || ', 1)))
    if ' || ' in anchor:
        out.append(('or-to-and', anchor.replace(' || ', ' && ', 1)))
    for label, pattern, new in TS_COMPARE:
        if re.search(pattern, anchor):
            out.append((label, re.sub(pattern, new, anchor, count=1)))
    return out


def sh_mutants(anchor):
    out = []
    m = re.match(r'^(\s*)if (.*); then$', anchor)
    if m is not None:
        out.append(('if-false', f'{m.group(1)}if false; then'))
        out.append(('if-invert', f'{m.group(1)}if ! ( {m.group(2)} ); then'))
    stripped = anchor.strip()
    if stripped.startswith('refuse ') or stripped.startswith('skip '):
        # no-op вместо удаления: пустая ветвь if/else и висячая continuation
        # «\» — синтаксическая ошибка bash, а не мутация поведения.
        out.append(('del-branch', '  :'))
    if re.match(r'^.*\)\s+[^)]*;;$', stripped):
        out.append(('del-case-alt', None))
    if stripped == 'exit 1':
        out.append(('del-exit', None))
    if re.match(r'^\[ .*\] && return [0-9]+$', stripped):
        out.append(('del-branch', None))
    if ' && ' in anchor:
        out.append(('and-to-or', anchor.replace(' && ', ' || ', 1)))
    if ' || ' in anchor:
        out.append(('or-to-and', anchor.replace(' || ', ' && ', 1)))
    for label, old, new in SH_COMPARE:
        if old in anchor:
            out.append((label, anchor.replace(old, new, 1)))
    return out


def build_mutants():
    """[(id, path, anchor, op, new-line|None)] по реальным subject-файлам."""
    out = []
    for path, anchors, gen in ((TS_PATH, TS_PREDICATES, ts_mutants),
                               (SH_PATH, SH_PREDICATES, sh_mutants)):
        text = (ROOT / path).read_text()
        for anchor in anchors:
            count = text.count(anchor)
            if count != 1:
                raise RuntimeError(f'SWEEP_ANCHOR: {path}: count={count}: {anchor!r}')
            for op, newline in gen(anchor):
                mid = hashlib.sha1(f'{path}|{anchor}|{op}'.encode()).hexdigest()[:12]
                out.append((mid, path, anchor, op, newline))
    return out


def materialize_mutant(scratch, mid, path, anchor, op, newline):
    dest = scratch / f'mut-{mid}' / path
    dest.parent.mkdir(parents=True)
    text = (ROOT / path).read_text()
    if newline is None:
        mutated = text.replace(anchor + '\n', '', 1)
    else:
        mutated = text.replace(anchor, newline, 1)
    if mutated == text:
        raise RuntimeError(f'SWEEP_APPLY: {mid} {op}')
    dest.write_text(mutated)
    return dest


FACTORY_DRIVER = '''import register from %s;
const handlers = new Map(); register({on:(name, fn)=>handlers.set(name, fn)});
const data=JSON.parse(process.argv[2]);
const ctx={cwd:data.copy,sessionManager:{getSessionId:()=>"206-factory",getSessionFile:()=>data.copy+"/Judge206.jsonl",getBranch:()=>[{type:"message",message:{role:"user",content:[{type:"text",text:data.task}]}}]}};
handlers.get('session_start')({},ctx);
const result=handlers.get('tool_call')({toolName:'write',input:{path:data.copy+'/verdict.md'}},ctx);
process.stdout.write(JSON.stringify(result??null)+'\\n');
'''


def build_world(sandbox):
    """Один мир на всех мутантов: ветки с закоммиченными вердиктами, матричный
    мир prepare, фабричный шаблон. Вердикт-клетки не пишут в git — смена ветки
    между клетками возвращает требуемое состояние HEAD детерминированно."""
    home = sandbox / 'home'
    copy = home / 'wt/owner/m'
    probe.init(copy)
    (copy.parent / '.omp-isolation-owner.json').write_text(json.dumps({'id': 'Judge206'}))
    (copy / 'scratch').mkdir()
    other = sandbox / 'foreign'
    probe.init(other)
    state = sandbox / 'live-state'
    state.mkdir()
    (state / 'HANDOFF.md').write_text('sweep-world\n')
    (copy / 'escape').symlink_to(other, target_is_directory=True)
    delivery = sandbox / 'wip-206-critic'
    probe.git(other, 'worktree', 'add', '-q', '-b', 'wip/206/critic', str(delivery))
    env = dict(os.environ, HOME=str(home), TMPDIR=str(sandbox / 'tmp'),
               GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
    env.pop('WORKTREE', None)
    verify = Path(env['TMPDIR']) / 'dev-harness-verify'
    matrix.prepare(copy, delivery, state, other, verify, sandbox)
    for role in probe.model.ROLES:
        branch = f'wip/206/{role}'
        probe.git(copy, 'switch', '-q', '-C', branch)
        verdict = copy / f'verdicts/{role}/contracts-206-v1.md'
        verdict.parent.mkdir(parents=True, exist_ok=True)
        verdict.write_text(f'206 {role}: environment verdict\n')
        probe.git(copy, 'add', str(verdict))
        probe.git(copy, '-c', f'user.name={role}', '-c', f'user.email={role}@dev-harness.local',
                  'commit', '-q', '-m', 'verdict')
    probe.git(copy, 'switch', '-q', '-C', 'wip/206/reviewer')
    return {'copy': copy, 'other': other, 'state': state, 'delivery': delivery,
            'env': env, 'verify': verify, 'sandbox': sandbox}


def _switch(copy, branch):
    if branch == 'detach':
        probe.git(copy, 'switch', '-q', '--detach')
    else:
        probe.git(copy, 'switch', '-q', '-C', branch if branch == 'main' else f'wip/206/{branch}')


def stage1_guard(guard, static_rows, world, scratch, mid):
    """Ступень 1: статические guard-клетки батареи + фабрика одним пакетным
    вызовом. Красное уже доказывает «батарея заметила»; пустой список
    передаёт мутант на ступень 2 (полная матрица)."""
    red = [name for name, ok in
           matrix.run_guard(guard, static_rows, world['env'], world['copy']).items() if not ok]
    driver = scratch / f'mut-{mid}' / 'factory.mjs'
    driver.write_text(FACTORY_DRIVER % json.dumps(guard.resolve().as_uri()))
    task = f"WORKTREE={world['delivery']}\nBRANCH=wip/206/critic\n"
    actual = probe.run(['node', str(driver), json.dumps({'copy': str(world['copy']), 'task': task})],
                       world['other'], world['env'])
    if actual != (0, b'null\n', b''):
        red.append('factory-own-copy')
    return red


def stage2_guard(guard, mrows, world):
    """Ступень 2: полная guard-матрица. Мир только читается, входы лежат в
    собственном mkdtemp — вызовы независимы и исполняются пулом."""
    return [name for name, ok in
            matrix.run_guard(guard, mrows, world['env'], world['copy']).items() if not ok]


def check_sh_mutant(script, world, vrows, static_cells):
    """Все вердикт-зависимые клетки батареи на общем мире (смена веток).
    Синтаксически сломанный мутант — AVARIA, не поимка (норма арбитража).
    Первый красный ответ останавливает перебор: «батарея заметила» уже
    доказано, полное число красных не является предметом sweep."""
    if probe.run(['bash', '-n', str(script)], world['other'], world['env'])[0] != 0:
        raise RuntimeError('BASH_SYNTAX')
    copy, other, env = world['copy'], world['other'], world['env']
    for name, branch, tail, expected in static_cells:
        _switch(copy, branch)
        actual = probe.run(['bash', str(script), 'verdict', '--repo', str(copy), *tail], other, env)
        if actual != expected:
            return [name]
    _switch(copy, 'reviewer')
    for row in vrows:
        actual = probe.run(['bash', str(script), 'verdict', '--repo', str(copy), '--file', row['vfile']],
                           other, env)
        if actual != row['expect']:
            return [row['name']]
    return []

def run(check=False, verbose=False):
    started = time.monotonic()
    scratch_base = Path(os.environ.get('TMPDIR') or (ROOT / '.scratch-206'))
    scratch_base.mkdir(parents=True, exist_ok=True)
    scratch = Path(tempfile.mkdtemp(prefix='sweep.', dir=scratch_base))
    try:
        mutants = build_mutants()
        world = build_world(scratch / 'world')
        static_guard = [{'name': n, 'input': v, 'expect': e}
                        for n, v, e in probe.guard_static_cells(world['copy'], world['delivery'],
                                                                world['state'], world['other'],
                                                                world['sandbox'])]
        mrows = matrix.guard_rows(world['copy'], world['delivery'], world['state'],
                                  world['other'], world['verify'], probe.model.HINT)
        vrows = matrix.verdict_rows(world['copy'], world['other'], world['sandbox'])
        static_verdict = probe.verdict_static_cells(world['copy'], world['other'])
        survivors, killed, avaria = [], 0, 0
        pending2 = []

        def classify(mid, path, anchor, op, red):
            nonlocal killed
            if red:
                killed += 1
                if verbose:
                    print(f'{mid} {path} {op}: POIMAN krasnyh={len(red)} ({red[0]})')
            else:
                survivors.append((mid, path, anchor, op))
                note = 'EKVIVALENT' if (path, anchor, op) in EQUIVALENTS else 'ZHIV'
                print(f'{mid} {path} {op}: {note}')

        for mid, path, anchor, op, newline in mutants:
            subject = materialize_mutant(scratch, mid, path, anchor, op, newline)
            try:
                if path == TS_PATH:
                    red = stage1_guard(subject, static_guard, world, scratch, mid)
                    if not red:
                        pending2.append((mid, path, anchor, op, subject))
                        continue
                else:
                    red = check_sh_mutant(subject, world, vrows, static_verdict)
            except RuntimeError as error:
                avaria += 1
                print(f'{mid} {path} {op}: AVARIA ({error})')
                shutil.rmtree(scratch / f'mut-{mid}', ignore_errors=True)
                continue
            shutil.rmtree(scratch / f'mut-{mid}')
            classify(mid, path, anchor, op, red)

        if pending2:
            with ThreadPoolExecutor(max_workers=3) as pool:
                futures = {pool.submit(stage2_guard, item[4], mrows, world): item
                           for item in pending2}
                for future in as_completed(futures):
                    mid, path, anchor, op, subject = futures[future]
                    try:
                        red = future.result()
                    except RuntimeError as error:
                        avaria += 1
                        print(f'{mid} {path} {op}: AVARIA ({error})')
                    else:
                        classify(mid, path, anchor, op, red)
                    shutil.rmtree(scratch / f'mut-{mid}')
        unexplained = [s for s in survivors if (s[1], s[2], s[3]) not in EQUIVALENTS]
        stale = sorted(set(EQUIVALENTS) - {(s[1], s[2], s[3]) for s in survivors})
        print(f'MUTANTOV={len(mutants)} POIMANY={killed} ZHIVYH={len(survivors)} '
              f'EKVIVALENTOV={len(survivors) - len(unexplained)} AVARII={avaria} '
              f'SEKUND={time.monotonic() - started:.1f}')
        for mid, path, anchor, op in unexplained:
            print(f'NEOBYASNENNYJ_VYZHIVSHIJ: {mid} {path} {op}: {anchor!r}')
        for key in stale:
            print(f'EKVIVALENT_POIMAN (запись устарела): {key}')
        if check:
            return 1 if unexplained or stale else 0
        return 0
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--verbose', action='store_true')
    args = parser.parse_args()
    return run(check=args.check, verbose=args.verbose)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError) as error:
        print(f'NOT_IMPLEMENTED: {error}', file=sys.stderr)
        sys.exit(2)
