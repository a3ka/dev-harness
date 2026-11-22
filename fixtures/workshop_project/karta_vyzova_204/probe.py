#!/usr/bin/env python3
"""204: реальные двери 193, git-миры и фазовый ключ вызова.

--repo ROOT не достраивает библиотеку; --model заменяет только библиотеку.
--stabs проверяет адресные мутации модели: честный контроль, затем точный
наблюдаемый результат мутации (не любой ненулевой rc). Привязки — stabs.tsv.
--regress193 [--model] запускает прежний раннер 193 на реальных скриптах,
во втором случае с единственной заменой lib на модель 204 в scratch.
Оракул и реальные blob-данные снимаются в память до вызова субъекта.
"""
import argparse
from dataclasses import dataclass, replace
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
MODEL = HERE / 'model/lib_karta_sdachi.sh'
CONTRACT = 'contracts/777-toy.md'
PREFIX = 'verdicts/critic/'
KARTA_OK = 'КАРТА: 17/17 зелёный'
PHASE_FILTER = '[ "$(karta_faza_puti "$f")" = "$faza" ] || continue'
OBJECTS = 'objects="$(git -C "$root" rev-list --objects --full-history HEAD -- "${puti[@]}")" || return 1'
REAL197 = (
    ('contracts-197-v1-vyzov1-fail.md', '9c36edff260e4255eb820776353fdd92cb73a3a0'),
    ('contracts-197-v1-vyzov2-fail.md', 'cb931378894237877ade09d91f3de682de4bf0a9'),
    ('contracts-197-v1-vyzov3-fail.md', 'b2bb643c3bef930cce9ec7000603c9d1ae2ae358'),
    ('contracts-197-v1.md', '2ad9976c401dffb7342734ecaa21c3a0769f6c6a'),
    ('contracts-197-v2.md', '92577057fd02f348aa7aeee31c71dc0f7cdb6c13'),
    ('contracts-197-v3.md', '5fdea2719223b23882aebf3e7d1457268b8fcdce'),
)

# Мутации меняют операции модели. Для каждой замены якорь ровно один.
# Составная мутация переносит выбор фазы ПОСЛЕ дедупликации объектов git.
MUTATIONS = {
    'PATERN:BEZ-FAZY': ((PHASE_FILTER, ':'),),
    'PATERN:PERVYJ-BLOB': (("printf 'неоднозначный вызов %s' \"$nom\"; return 1", 'continue'),),
    'PATERN:PO-OBHODU': ((PHASE_FILTER, '[ "$(( ${#puti[@]} + 1 ))" = "$faza" ] || continue'),),
    'PATERN:IZ-SUD': ((PHASE_FILTER,
        '[ "$(git -C "$root" cat-file -p "HEAD:$f" | sed -n \'s/^СУД:.*фаза=\\([^;]*\\);.*/\\1/p\')" = '
        '"$(printf \'%s\\n\' "$3" | sed -n \'s/^СУД:.*фаза=\\([^;]*\\);.*/\\1/p\')" ] || continue'),),
    'PATERN:BEZ-VERSII-0': (('local imja="${1##*/}" faza=1', 'local imja="${1##*/}" faza=0'),),
    'PATERN:POSLE-OBEKTOV': (
        (OBJECTS, 'objects="$(git -C "$root" rev-list --objects --full-history HEAD -- "${put%/*}/")" || return 1'),
        ('[ "$blob" != "$f" ] || continue', '[ "$blob" != "$f" ] || continue\n        ' + PHASE_FILTER),
    ),
    'PATERN:PERVAJA-CIFRA': (("printf '%s' \"$faza\"", "printf '%s' \"${faza:0:1}\""),),
    'PATERN:CUT-C1': (("printf '%s' \"$faza\"", "printf '%s' \"$faza\" | cut -c1"),),
}


class Prerequisite(RuntimeError):
    pass


def environment():
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    for name in ('SDACHA_OKRUG', 'HARNESS_PROJECT_LAYER_ROOT', 'HARNESS_WORKFLOW_ROOT'):
        env.pop(name, None)
    env['GIT_CONFIG_GLOBAL'] = '/dev/null'
    env['GIT_CONFIG_SYSTEM'] = '/dev/null'
    return env


def command(argv, *, cwd=None, timeout=15):
    proc = subprocess.Popen(argv, cwd=cwd, env=environment(), stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    try:
        out, err = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        os.killpg(proc.pid, signal.SIGKILL)
        proc.communicate()
        raise Prerequisite('TIMEOUT: ' + ' '.join(map(str, argv))) from exc
    return proc.returncode, out, err


def git(root, *args):
    rc, out, err = command(['git', '-C', str(root), '-c', 'user.name=architect',
                            '-c', 'user.email=architect@dev-harness.local', *args])
    if rc:
        raise Prerequisite('git %s: rc=%s %s' % (' '.join(args), rc, err.decode().strip()))
    return out


def verdict(call, result='accept', changes=None, theme='777', role='critic',
            phase='контракт (до заморозки)', note='честный контроль'):
    lines = [result, 'OBJECT=' + 'a' * 40,
             'СУД: repo=toy; предмет=%s; фаза=%s; роль=%s; вызов=%s/9;' %
             (theme, phase, role, call), '', '## Карта классов', '']
    for k in range(1, 18):
        lines.append('К-%02d: %s' % (k, (changes or {}).get(k, 'чисто — вход: ' + note)))
    return ('\n'.join(lines) + '\n').encode()


def green_sheet(closed=()):
    return 'СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=%d)' % len(closed)


def sheet(path, closed):
    lines = ['ПРЕДЫДУЩИЙ ВЕРДИКТ: ' + path, '', '## Двери', '',
             '- честная-команда · bash scripts/progiban_ok.sh · 0 · 0', '',
             '## Карта классов', '']
    lines += ['- К-%02d · чисто · вход: конформная карта батареи 204 · - · -' % k
              for k in range(1, 18)]
    lines += ['', '## Дельта', '']
    lines += ['- К-%02d · клетка · bash scripts/progiban_ok.sh · 0 · 0' % k for k in closed]
    return ('\n'.join(lines) + '\n').encode()


@dataclass(frozen=True)
class Cell:
    name: str
    door: str
    path: str
    current: bytes
    history: tuple
    closed: tuple = ()
    rc: int = 0
    output: str = ''


def cells(real197):
    p = lambda name: PREFIX + name
    v1 = p('contracts-777-v1-call-01.md')
    v2 = p('contracts-777-v2.md')
    v3 = p('contracts-777-v3.md')
    cur1 = p('contracts-777-v1-call-02.md')
    cur3 = p('contracts-777-v3-call-02.md')
    block2 = verdict('1', 'FAIL', {2: 'блок — вход: свой блок'})
    nover = p('contracts-777-krug2.md')
    common_blob = verdict('1')
    cases = [
        Cell('a1-tri-fazy-sdacha', 'sdacha', v3, verdict('1'),
             ((v1, verdict('1', 'FAIL', {5: 'блок — вход: старая фаза'})),
              (v2, verdict('1', note='вторая фаза')))),
        Cell('a2-ssylka-svoej-fazy', 'karta', cur3,
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((v1, block2), (v2, verdict('1', note='вторая фаза')),
              (v3, verdict('1', note='третья фаза')))),
        Cell('b1-dva-bloba-v-faze', 'sdacha', cur1, verdict('2'),
             ((v1, verdict('1', note='первый blob')),
              (p('contracts-777-v1-drugoj.md'), verdict('1', note='другой blob'))),
             rc=1, output='ОТКАЗ: последний FAIL: неоднозначный вызов 1'),
        Cell('v1-fail-tolko-svoej-fazy', 'sdacha', cur1, verdict('2'),
             ((v1, verdict('1', 'FAIL', {5: 'блок — вход: свой FAIL'})),
              (p('contracts-777-v2-call-09.md'),
               verdict('9', 'FAIL', {9: 'блок — вход: чужой FAIL'}))), (5,)),
        Cell('v2-svoj-fail-obyazatelen', 'sdacha', cur1, verdict('2'),
             ((v1, verdict('1', 'FAIL', {5: 'блок — вход: свой FAIL'})),
              (p('contracts-777-v2-call-09.md'), verdict('9'))),
             rc=1, output='ОТКАЗ: блок К-05 предыдущего вердикта не закрыт в «## Дельта»'),
        Cell('g1-bez-versii-kak-v1', 'sdacha', cur1, verdict('2'),
             ((p('contracts-777-krug1.md'), verdict('1', note='без версии')),
              (v1, verdict('1', phase='контракт v+1 (до заморозки v2)', note='явная v1'))),
             rc=1, output='ОТКАЗ: последний FAIL: неоднозначный вызов 1'),
        Cell('g2-bez-versii-i-v2', 'sdacha', p('contracts-777-krug1-fail.md'),
             verdict('1', 'FAIL', {9: 'блок — вход: исторический FAIL'}),
             ((v2, verdict('1', note='вторая фаза')),), (9,)),
        Cell('g3-bez-versii-ssylka', 'sdacha', nover,
             verdict('2', changes={2: 'без изменений с вызова 1.'}), ((v1, block2),), (2,)),
        Cell('c1-porjadok-ne-faza', 'karta', cur1,
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((v3, verdict('1', note='v3 закоммичена раньше v1')), (v1, block2))),
        Cell('f1-odna-faza-ssylka', 'sdacha', cur1,
             verdict('2', changes={2: 'без изменений с предыдущего вызова.'}),
             ((v1, block2),), (2,)),
        Cell('f3-chuzhoj-predmet', 'sdacha', cur1, verdict('2'),
             ((p('contracts-888-v1.md'), verdict('1', 'FAIL', theme='888')),
              (p('contracts-888-v1-drugoj.md'), verdict('1', theme='888')))),
        Cell('f4-vedushchie-nuli', 'sdacha', cur1, verdict('2'),
             ((p('contracts-777-v01.md'), verdict('1', note='v01')),
              (v1, verdict('1', note='v1'))),
             rc=1, output='ОТКАЗ: последний FAIL: неоднозначный вызов 1'),
        Cell('f5-nechislo-ne-vyzov', 'sdacha', cur1, verdict('2'),
             ((p('contracts-777-v1-nechislo.md'), verdict('ОДИН узкий')),
              (v1, verdict('1', 'FAIL', {5: 'блок — вход: свой FAIL'}))), (5,)),
        Cell('f6-chuzhaja-rol', 'sdacha', cur1, verdict('2'),
             ((p('contracts-777-v1-review.md'), verdict('2', 'FAIL', role='reviewer')),)),
        Cell('f7-ssylka-ne-iz-chuzhoj-fazy', 'karta', v3,
             verdict('5', changes={2: 'без изменений с вызова 2.'}),
             ((p('contracts-777-v1-call-02.md'), verdict('2')),),
             rc=1, output='ОТКАЗ: ' + v3 + ': отсутствует вызов 2 (К-02)'),
        Cell('f8-suffiks-versii', 'karta', p('contracts-777-v2-call-02.md'),
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((p('contracts-777-v2d-call-01.md'), verdict('1')),)),
        Cell('f9-nulevaja-versija', 'karta', p('contracts-777-v0-call-02.md'),
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((p('contracts-777-v000-call-01.md'), verdict('1')),)),
        Cell('v10-otdelno-ot-v1', 'karta', p('contracts-777-v10-call-02.md'),
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((v1, verdict('1')),),
             rc=1, output='ОТКАЗ: ' + p('contracts-777-v10-call-02.md')
             + ': отсутствует вызов 1 (К-02)'),
        Cell('v11-otdelno-ot-v1', 'karta', p('contracts-777-v11-call-02.md'),
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((v1, verdict('1')),),
             rc=1, output='ОТКАЗ: ' + p('contracts-777-v11-call-02.md')
             + ': отсутствует вызов 1 (К-02)'),
        Cell('v10-ssylka-svoej-fazy', 'karta', p('contracts-777-v10-call-02.md'),
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((p('contracts-777-v10-call-01.md'), verdict('1')),)),
        Cell('h1-odin-blob-dve-fazy', 'karta', cur3,
             verdict('2', changes={2: 'без изменений с вызова 1.'}),
             ((v1, common_blob), (v3, common_blob))),
        Cell('e1-realnaja-istorija-197', 'sdacha', p('contracts-197-v3.md'),
             dict(real197)[p('contracts-197-v3.md')], real197),
    ]
    if len({c.name for c in cases}) != len(cases) or not cases:
        raise Prerequisite('ORACLE_TAMPERED: пустой/неуникальный набор клеток')
    return [replace(c, output=c.output or (KARTA_OK if c.door == 'karta'
                    else green_sheet(c.closed))) for c in cases]


def sources(root):
    names = ('check_sdacha.sh', 'check_verdict_karta.sh', 'next_id.sh', 'profile_resolver.sh')
    result = {}
    for name in names:
        path = root / 'scripts' / name
        if not path.is_file():
            raise Prerequisite('SUBJECT_ABSENT: ' + str(path))
        result[name] = path.read_bytes()
    return result


def snapshot(root):
    files = tuple((str(p.relative_to(root)), p.read_bytes()) for p in sorted(root.rglob('*'))
                  if p.is_file() and '.git' not in p.relative_to(root).parts)
    return files, git(root, 'rev-parse', 'HEAD'), (root / '.git/index').read_bytes()


def observe(cell, deps, library, scratch):
    with tempfile.TemporaryDirectory(prefix=cell.name + '-', dir=scratch) as directory:
        root = Path(directory)
        for sub in ('scripts', 'contracts', 'verdicts/critic'):
            (root / sub).mkdir(parents=True)
        for name, data in deps.items():
            (root / 'scripts' / name).write_bytes(data)
        (root / 'scripts/lib_karta_sdachi.sh').write_bytes(library)
        (root / 'scripts/progiban_ok.sh').write_text('#!/usr/bin/env bash\nexit 0\n')
        (root / CONTRACT).write_text('# Контракт 777 — конформный мир 204\n\nСДАЧА: sdacha.md\n')
        git(root, 'init', '-q', '-b', 'main')
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', '204: чистый мир')
        for path, data in cell.history:
            (root / path).write_bytes(data)
            git(root, 'add', '-A')
            git(root, 'commit', '--allow-empty', '-qm', '204: исторический артефакт')
        (root / cell.path).write_bytes(cell.current)
        (root / 'sdacha.md').write_bytes(sheet(cell.path, cell.closed))
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', '204: предъявленный вердикт и лист')
        before = snapshot(root)
        script = 'check_sdacha.sh' if cell.door == 'sdacha' else 'check_verdict_karta.sh'
        argv = ['bash', str(root / 'scripts' / script), str(root)]
        argv += [CONTRACT, '--run'] if cell.door == 'sdacha' else [cell.path]
        rc, out, err = command(argv)
        if rc not in (0, 1):
            raise Prerequisite('SUBJECT_ENVIRONMENT: %s rc=%s %s' %
                               (cell.name, rc, (out + err).decode(errors='replace').strip()))
        if snapshot(root) != before:
            raise Prerequisite('ORACLE_TAMPERED: субъект изменил мир ' + cell.name)
        return rc, (out + err).decode().rstrip('\n')


def judge(cell, deps, library, scratch):
    actual = observe(cell, deps, library, scratch)
    ok = actual == (cell.rc, cell.output)
    print('204 %s %s rc=%s %s' % (cell.name, 'ok' if ok else 'KRASNO', *actual), flush=True)
    if not ok:
        print('204 ожидалось rc=%s %s' % (cell.rc, cell.output), flush=True)
    return ok


def mutate(text, name):
    for anchor, replacement in MUTATIONS[name]:
        if text.count(anchor) != 1:
            raise Prerequisite('ORACLE_TAMPERED: якорь не единственный: ' + name)
        text = text.replace(anchor, replacement, 1)
    return text.encode()


def mutant_expected(name, cell):
    if name == 'PATERN:BEZ-FAZY':
        return {
            'a1-tri-fazy-sdacha': (1, 'ОТКАЗ: последний FAIL: неоднозначный вызов 1'),
            'v1-fail-tolko-svoej-fazy': (1, 'ОТКАЗ: блок К-09 предыдущего вердикта не закрыт в «## Дельта»'),
            'f7-ssylka-ne-iz-chuzhoj-fazy': (0, KARTA_OK),
        }[cell.name]
    if name in ('PATERN:PERVYJ-BLOB', 'PATERN:IZ-SUD'):
        return 0, green_sheet()
    if name == 'PATERN:BEZ-VERSII-0':
        return 1, 'ОТКАЗ: предыдущий вердикт: отсутствует вызов 1 (К-02)'
    if name in ('PATERN:PERVAJA-CIFRA', 'PATERN:CUT-C1'):
        return 0, KARTA_OK
    return 1, 'ОТКАЗ: ' + cell.path + ': отсутствует вызов 1 (К-02)'


def stabs(cases, deps, honest, scratch):
    bindings = []
    for line in (HERE / 'stabs.tsv').read_text().splitlines():
        if not line or line.startswith('#'):
            continue
        parts = line.split('\t')
        if len(parts) != 2 or parts[0] not in MUTATIONS:
            raise Prerequisite('ORACLE_TAMPERED: привязка вне алфавита: ' + line)
        bindings.append(tuple(parts))
    if not bindings or len(set(bindings)) != len(bindings):
        raise Prerequisite('ORACLE_TAMPERED: пустые/дублированные привязки')
    if set(MUTATIONS) != {name for name, _ in bindings}:
        raise Prerequisite('ORACLE_TAMPERED: мутация без потребителя')
    by_name = {c.name: c for c in cases}
    caught = 0
    for name, cell_name in bindings:
        if cell_name not in by_name:
            raise Prerequisite('ORACLE_TAMPERED: клетка отсутствует: ' + cell_name)
        cell = by_name[cell_name]
        if not judge(cell, deps, honest, scratch):
            raise Prerequisite('ORACLE_TAMPERED: красен честный контроль ' + cell_name)
        mutant = mutate(honest.decode(), name)
        path = Path(scratch) / 'mutant-lib.sh'
        path.write_bytes(mutant)
        if command(['bash', '-n', str(path)])[0]:
            raise Prerequisite('ORACLE_TAMPERED: мутация сломала синтаксис ' + name)
        actual = observe(cell, deps, mutant, scratch)
        expected = mutant_expected(name, cell)
        discriminates = actual != (cell.rc, cell.output)
        ok = discriminates and actual == expected
        caught += int(ok)
        print('204 %s -> %s %s rc=%s %s' %
              (name, cell_name, 'POIMAN' if ok else 'ZHIV', *actual), flush=True)
        if not ok:
            print('204 мутация ожидалась rc=%s %s' % expected, flush=True)
    alive = len(bindings) - caught
    print('ИТОГ 204: rc=%d MUTACII=%d SVJAZI=%d POIMANY=%d ZHIVYH=%d' %
          (int(alive != 0), len(MUTATIONS), len(bindings), caught, alive), flush=True)
    return int(alive != 0)


def regress193(root, use_model, scratch):
    runner = TREE / 'fixtures/workshop_project/sdacha_193/red_sdacha_193.sh'
    selected = root
    if use_model:
        selected = Path(scratch) / 'source-193'
        shutil.copytree(root / 'scripts', selected / 'scripts')
        (selected / 'scripts/lib_karta_sdachi.sh').write_bytes(MODEL.read_bytes())
    # Прежний раннер запускается без подмены его кода/ожиданий/данных.
    return subprocess.run(['bash', str(runner), '--repo', str(selected)],
                          env=environment(), cwd=root).returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=TREE)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    parser.add_argument('--regress193', action='store_true')
    args = parser.parse_args()
    try:
        for binary in ('bash', 'git', 'python3', 'jq', 'sed', 'awk', 'timeout'):
            if not shutil.which(binary):
                raise Prerequisite('LIVE_PREDPOSYLKA: нет ' + binary)
        root = args.repo.resolve()
        if args.regress193 and args.stabs:
            raise Prerequisite('--regress193 несовместим с --stabs')
        with tempfile.TemporaryDirectory(prefix='batareja-204-') as scratch:
            if args.regress193:
                return regress193(root, args.model, scratch)
            deps = sources(root)
            library_path = MODEL if args.model or args.stabs else root / 'scripts/lib_karta_sdachi.sh'
            if not library_path.is_file():
                raise Prerequisite('SUBJECT_ABSENT: ' + str(library_path))
            library = library_path.read_bytes()
            # Настоящие blob-ы истории 197, не переписанные миниатюры вердиктов.
            real197 = tuple((PREFIX + name, git(TREE, 'cat-file', '-p', sha))
                            for name, sha in REAL197)
            cases = cells(real197)
            if args.stabs:
                return stabs(cases, deps, library, scratch)
            green = sum(judge(c, deps, library, scratch) for c in cases)
            red = len(cases) - green
            print('ИТОГ 204: rc=%d KLETKI=%d ZELENYE=%d KRASNYE=%d' %
                  (int(red != 0), len(cases), green, red), flush=True)
            return int(red != 0)
    except (OSError, Prerequisite) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
