#!/usr/bin/env python3
"""206: параметрическая матрица целей охранных операций (исполнение арбитража
predmet-206-granica-ohrannyh-predikatov).

Оси конечны и структурны (таблица арбитража): операция × basename//bin;
основание цели (абсолютная / относительная от абсолютного cwd своей копии;
относительная без cwd — именованный отрицательный контроль); хвостовой «/»;
лексическое представление (обычное, «//», «./», «existing/../» — операнд
передаётся СЫРЫМ, генератор не нормализует); размещение (своя М1-копия,
scratch-allowlist 025, live-state, чужое неназначенное дерево, явно
назначенный пин); «--» и позиция цели; назначение symlink. Вердиктная
матрица: abs/rel × четыре формы × прямой путь/ссылка-каталог/ссылка-файл ×
внутри/снаружи.

Ожидание каждой строки назначается миром ДО вызова субъекта: своя копия,
scratch и назначенный пин положительны; live-state и чужое дерево
отрицательны; ссылка судится по назначению после обхода. Ожидание НЕ
вычисляется вызовом проверяемого pathAllowed/judge и не копирует ответ
честной модели (арбитраж, требование 2): production и модель — два
проверяемых субъекта.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
DRIVER = HERE / 'guard_driver.mjs'

BINS = (('cp', 'bare'), ('/bin/cp', 'abs'), ('mkdir', 'bare'), ('/bin/mkdir', 'abs'))
BASES = ('abs', 'rel')
TAILS = ('noslash', 'slash')
LEXES = ('plain', 'double', 'dot', 'existing')
PLACEMENTS = ('own', 'scratch', 'state', 'foreign', 'pin')
POSITIONS = ('position-0', 'position-1', 'position-2')
DASHES = ('no-dash', 'dash')
LINK_DESTS = ('own', 'state', 'foreign')
FORMS = ('direct', 'dir-symlink', 'file-symlink')
SIDES = ('inside', 'outside')
LEX_SEPS = {'plain': '/', 'double': '//', 'dot': '/./', 'existing': '/existing/../'}
REVIEWER_BRANCH = 'wip/206/reviewer'


def run(argv, cwd, env, timeout=120):
    p = subprocess.run(argv, cwd=str(cwd), env=env, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, timeout=timeout)
    return p.returncode, p.stdout, p.stderr


def roots(copy, delivery, state, other, verify_base):
    return {
        'own': copy / 'scratch' / 'm206',
        'scratch': verify_base / 'm206',
        'state': state / 'm206',
        'foreign': other / 'm206',
        'pin': delivery / 'm206',
    }


def prepare(copy, delivery, state, other, verify_base, sandbox):
    """Мировая обвязка матрицы: каталоги размещений, symlink-и, читаемые
    источники cp. Ни одна клетка не исполняет системные cp/mkdir — судится
    публичная операция стража, как в штатной батарее."""
    for root in roots(copy, delivery, state, other, verify_base).values():
        (root / 'lex' / 'existing').mkdir(parents=True, exist_ok=True)
    own_root = copy / 'scratch' / 'm206'
    (own_root / 'src.txt').write_text('matrix-source\n')
    for dest, target in (('own', own_root), ('state', state), ('foreign', other)):
        (copy / f'm206lnk-{dest}').symlink_to(target, target_is_directory=True)
    (copy / 'm206flink-inside').symlink_to(own_root / 'src.txt')
    (copy / 'm206flink-outside').symlink_to(state / 'HANDOFF.md')
    (copy / 'existing').mkdir(exist_ok=True)
    (copy / 'verdicts' / 'existing').mkdir(parents=True, exist_ok=True)
    (other / 'existing').mkdir(exist_ok=True)
    (other / 'm206lex' / 'existing').mkdir(parents=True, exist_ok=True)
    (sandbox / 'existing').mkdir(parents=True, exist_ok=True)
    (copy / 'm206dlink-in').symlink_to(copy / 'verdicts', target_is_directory=True)
    (copy / 'm206dlink-out').symlink_to(other, target_is_directory=True)
    (copy / 'm206flink-verdict-in.md').symlink_to(
        copy / 'verdicts' / 'reviewer' / 'contracts-206-v1.md')
    (copy / 'm206flink-verdict-out.md').symlink_to(other / 'verdict.md')


def guard_rows(copy, delivery, state, other, verify_base, hint):
    """Основной guard-продукт арбитража: операция × basename/`/bin` × abs/rel ×
    хвост × четыре лексические формы × пять размещений × «--» × позиции,
    применимые к операции (cp — последняя цель при двух источниках; mkdir —
    выделенная цель на первой/средней/последней позиции среди разрешённых).
    Отдельно: symlink-продукт (три назначения ссылки), ссылка-файл cp,
    контроль symlink+`..`, относительная цель cp без cwd."""
    world = roots(copy, delivery, state, other, verify_base)
    src1 = str(state / 'HANDOFF.md')
    src2 = str(copy / 'scratch' / 'm206' / 'src.txt')
    allowed = [str(copy / 'scratch' / 'm206' / 'ok0'),
               str(copy / 'scratch' / 'm206' / 'ok1')]

    def outside(p):
        return (f'запись вне пина запрещена — Н-85: путь {p} не входит '
                f'в WORKTREE={delivery} и не в allowlist')

    def target_text(placement, base, tail, lex, n):
        root = world[placement]
        leaf = f't{n:04d}' + ('/' if tail == 'slash' else '')
        parent = str(root / 'lex') if base == 'abs' else os.path.relpath(root, copy)
        return parent + LEX_SEPS[lex] + leaf

    rows = []

    def add(name, axes, operand, base, cmd, sign, args=None):
        value = dict(worktree=str(delivery), skipActualCheck=True, sessionCwd=str(copy),
                     sessionName='Judge206', tool='bash',
                     args=args or {'command': cmd, 'cwd': str(copy)})
        if sign == 'pos':
            expect = {'decision': 'pass'}
        else:
            resolved = operand if base == 'abs' else f'{copy}/{operand}'
            expect = {'decision': 'block', 'reason': outside(resolved) + '\n' + hint}
        rows.append({'name': name, 'axes': axes, 'input': value, 'expect': expect})

    n = 0
    for binname, binlabel in BINS:
        op = 'mkdir' if binname.endswith('mkdir') else 'cp'
        for base in BASES:
            for tail in TAILS:
                for lex in LEXES:
                    for placement in PLACEMENTS:
                        sign = 'pos' if placement in ('own', 'scratch', 'pin') else 'neg'
                        for dash in DASHES:
                            sep = ' --' if dash == 'dash' else ''
                            if op == 'cp':
                                n += 1
                                operand = target_text(placement, base, tail, lex, n)
                                cmd = f'{binname}{sep} {src1} {src2} {operand}'
                                add(f'cp/{binlabel}/{base}/{tail}/{lex}/{placement}/{dash}/last',
                                    dict(group='main', op='cp', bin=binlabel, base=base,
                                         tail=tail, lex=lex, placement=placement, dash=dash,
                                         position='last', sign=sign),
                                    operand, base, cmd, sign)
                            else:
                                for pi, position in enumerate(POSITIONS):
                                    n += 1
                                    operand = target_text(placement, base, tail, lex, n)
                                    targets = list(allowed)
                                    targets.insert(pi, operand)
                                    cmd = f'{binname} -p{sep} ' + ' '.join(targets)
                                    add(f'mkdir/{binlabel}/{base}/{tail}/{lex}/{placement}/{dash}/{position}',
                                        dict(group='main', op='mkdir', bin=binlabel, base=base,
                                             tail=tail, lex=lex, placement=placement, dash=dash,
                                             position=position, sign=sign),
                                        operand, base, cmd, sign)

    for op in ('cp', 'mkdir'):
        for base in BASES:
            for tail in TAILS:
                for dest in LINK_DESTS:
                    sign = 'pos' if dest == 'own' else 'neg'
                    for dash in DASHES:
                        sep = ' --' if dash == 'dash' else ''
                        n += 1
                        leaf = f'l{n:04d}' + ('/' if tail == 'slash' else '')
                        prefix = f'{copy}/m206lnk-{dest}/' if base == 'abs' else f'm206lnk-{dest}/'
                        operand = prefix + leaf
                        cmd = (f'cp{sep} {src1} {src2} {operand}' if op == 'cp'
                               else f'mkdir -p{sep} {operand}')
                        add(f'{op}/dirlink/{base}/{tail}/{dest}/{dash}',
                            dict(group='dirlink', op=op, base=base, tail=tail, dest=dest,
                                 dash=dash, sign=sign),
                            operand, base, cmd, sign)

    for base in BASES:
        for side in SIDES:
            link = 'm206flink-inside' if side == 'inside' else 'm206flink-outside'
            operand = f'{copy}/{link}' if base == 'abs' else link
            sign = 'pos' if side == 'inside' else 'neg'
            add(f'cp/filelink/{base}/{side}',
                dict(group='filelink', op='cp', base=base, side=side, sign=sign),
                operand, base, f'cp -- {src1} {src2} {operand}', sign)

    for op in ('cp', 'mkdir'):
        for placement in ('own', 'state'):
            n += 1
            operand = f'{copy}/m206lnk-{placement}/../d{n:04d}'
            cmd = (f'cp -- {src1} {src2} {operand}' if op == 'cp' else f'mkdir -p {operand}')
            sign = 'pos' if placement == 'own' else 'neg'
            add(f'{op}/dirlink-dotdot/{placement}',
                dict(group='dotdot', op=op, placement=placement, sign=sign),
                operand, 'abs', cmd, sign)

    nocwd_cmd = f'cp -- {src1} {src2} scratch/m206/rel-no-cwd.md'
    rows.append({
        'name': 'guard-cp-no-cwd',
        'axes': dict(group='boundary', op='cp', sign='nocwd'),
        'input': dict(worktree=str(delivery), skipActualCheck=True, sessionCwd=str(copy),
                      sessionName='Judge206', tool='bash', args={'command': nocwd_cmd}),
        'expect': {'decision': 'block', 'reason':
                   'запись относительным путём без cwd запрещена — Н-85: используй cwd или абсолютный путь'
                   + '\n' + hint},
    })
    return rows


VERDICT_IN_LEAF = 'reviewer/contracts-206-v1.md'
VERDICT_PARENTS = {
    ('direct', 'inside'): ('verdicts', VERDICT_IN_LEAF),
    ('direct', 'outside'): ('../m206lex', 'outside.md'),
    ('dir-symlink', 'inside'): ('m206dlink-in', VERDICT_IN_LEAF),
    ('dir-symlink', 'outside'): ('m206dlink-out', 'verdict.md'),
    ('file-symlink', 'inside'): ('.', 'm206flink-verdict-in.md'),
    ('file-symlink', 'outside'): ('.', 'm206flink-verdict-out.md'),
}


def verdict_rows(copy, other, sandbox):
    """Вердиктная матрица арбитража: abs/rel × четыре лексические формы ×
    прямой путь/ссылка-каталог/ссылка-файл × внутри/снаружи. Относительная
    форма считается от --repo, не от cwd вызывающего (cwd вызывающего —
    чужой репозиторий)."""
    rows = []
    for base in BASES:
        for lex in LEXES:
            sep = LEX_SEPS[lex]
            for form in FORMS:
                for side in SIDES:
                    if base == 'abs':
                        if form == 'direct':
                            parent = f'{copy}/verdicts' if side == 'inside' else f'{other}/m206lex'
                        elif form == 'dir-symlink':
                            parent = f'{copy}/m206dlink-in' if side == 'inside' else f'{copy}/m206dlink-out'
                        else:
                            parent = str(copy)
                    else:
                        parent = VERDICT_PARENTS[(form, side)][0]
                    leaf = VERDICT_PARENTS[(form, side)][1]
                    vfile = parent + sep + leaf
                    if side == 'inside':
                        expect = (0, f'VERDICT_BRANCH={REVIEWER_BRANCH}\n'.encode(), b'')
                    else:
                        expect = (1, b'', (f'ОТКАЗ: VERDIKT_VNE_REPO\n'
                                           f'файл вердикта вне репозитория: {vfile}\n'
                                           'ФОРМА: --repo <своя-копия> --file <абсолют-вердикта-в-своей-копии>\n'
                                           ).encode())
                    rows.append({'name': f'verdict/{base}/{lex}/{form}/{side}',
                                 'axes': dict(group='verdict', base=base, lex=lex,
                                              form=form, side=side),
                                 'vfile': vfile, 'expect': expect})
    return rows


def run_guard(guard, rows, env, cwd, only=None):
    """Пакетный прогон матрицы через публичный judge предметного файла.
    rc процесса и пустой stderr проверяются отдельно; каждое решение
    сопоставляется ожиданию целиком. Авария — NOT_IMPLEMENTED вызывающего,
    не поимка."""
    selected = [r for r in rows if only is None or r['name'] == only]
    if not selected:
        return {}
    work = Path(tempfile.mkdtemp(dir=env['TMPDIR']))
    inputs = work / 'inputs.json'
    inputs.write_text(json.dumps([{'name': r['name'], 'input': r['input']} for r in selected],
                                 ensure_ascii=False))
    try:
        actual = run(['node', str(DRIVER), guard.resolve().as_uri(), str(inputs)], cwd, env)
    finally:
        inputs.unlink(missing_ok=True)
        work.rmdir()
    if actual[0] != 0 or actual[2] != b'':
        raise RuntimeError(f'MATRIX_GUARD_INFRA: rc={actual[0]} stderr={actual[2]!r}')
    try:
        decisions = json.loads(actual[1])
    except ValueError as error:
        raise RuntimeError(f'MATRIX_GUARD_INFRA: json: {error}') from error
    if not isinstance(decisions, list) or len(decisions) != len(selected):
        got = len(decisions) if isinstance(decisions, list) else type(decisions).__name__
        raise RuntimeError(f'MATRIX_GUARD_INFRA: rows={len(selected)} got={got}')
    results = {}
    for row, got in zip(selected, decisions):
        if got.get('name') != row['name']:
            raise RuntimeError(f'MATRIX_GUARD_INFRA: order {got.get("name")!r} != {row["name"]!r}')
        results[row['name']] = got.get('decision') == row['expect']
    return results


def run_verdict(script, repo, rows, env, cwd, only=None):
    """Каждая вердиктная строка исполняет настоящий pre_judge.sh verdict и
    сравнивает полный (rc, stdout, stderr)."""
    results = {}
    for row in rows:
        if only is not None and row['name'] != only:
            continue
        actual = run(['bash', str(script), 'verdict', '--repo', str(repo), '--file', row['vfile']],
                     cwd, env, timeout=30)
        results[row['name']] = actual == row['expect']
    return results
