#!/usr/bin/env python3
"""205: четвёртая признанная локация guard — gate профиля проекта.

--repo ROOT судит реальный scripts/check_provodka.sh выбранного дерева без
достройки (умолчание — дерево батареи); --model заменяет только дверь
моделью (скретч-копия: модель + настоящий profile_resolver.sh, байты сняты
в память до вызова субъекта); --stabs прогоняет адресные мутации модели:
сначала честный контроль клетки, затем точный наблюдаемый результат мутации
(не любой ненулевой rc); --attack <MUTATION> прогоняет мутацию по ВСЕЙ
батарее (атака критика: rc 1, красные клетки названы поимённо). Привязки
мутаций к клеткам — stabs.tsv и этот файл (Н-39), не проза контракта.
Ожидания — литералы в памяти до запуска субъекта. Сравниваются rc и ПОЛНЫЙ
наблюдаемый вывод (stdout+stderr в порядке снятия probe) байт-в-байт:
лишняя строка перед/после/внутри и непустой успешный выход — красное
(К-10 Δ1); ожидания выведены из честной модели, не из головы.
"""
import argparse
from dataclasses import dataclass
import os
from pathlib import Path
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
MODEL = HERE / 'model/check_provodka_model.sh'
STABS = HERE / 'stabs.tsv'
CONTRACT = 'contracts/001-x.md'
GUARD = 'scripts/red_gate_205.sh'
PY_GUARD = 'tools/check_source_trace.py'
ROLE = 'roles/fixer.md'
NORMA = 'Norma stroki roli v igrushke R.'
LAYER_REL = 'registry/harness-project.json'


def old_refusal(guard):
    return 'проводка: guard не подключён: %s не вызывается в .githooks/ или .github/workflows/' % guard


def new_refusal(reason):
    return 'проводка: профиль проекта не распознан: %s' % reason


# ── миры: каждый вход строится заново в одноразовом скратче ───────────────────
def put(root, rel, text):
    target = root / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding='utf-8')


def base_world(root, guard=GUARD, with_guard=True):
    put(root, CONTRACT,
        '# kontrakt 001\n\n## Predmet\npodstavnoj predmet\n\n## Norma-provodka\n'
        'ПРОВОДКА:\n- guard=%s\n- role=%s «%s»\n' % (guard, ROLE, NORMA))
    put(root, ROLE, '# role fixture\n\n%s\n' % NORMA)
    if with_guard:
        shebang = '#!/usr/bin/env python3\n' if guard.endswith('.py') else '#!/usr/bin/env bash\n'
        put(root, guard, shebang + 'exit 0\n')


def repo_profile(canon=True, gate=None, extra=None, sources=None, profile_path=LAYER_REL):
    prof = {
        'schemaVersion': 1, 'repoId': 'toy', 'language': 'bash',
        'projectLayer': {'version': '1', 'profilePath': profile_path},
    }
    if canon:
        prof['sourceCanon'] = {
            'sources': sources if sources is not None else [{'path': 'AGENTS.md', 'priority': 0}],
            'gate': gate if gate is not None else ['bash', GUARD],
        }
        if extra:
            prof['sourceCanon'].update(extra)
    return prof


def layer_profile(defaults_canon=None):
    prof = {'schemaVersion': 1, 'version': '1', 'projectId': 'toy', 'workspaceId': 'main'}
    if defaults_canon is not None:
        prof['defaults'] = {'sourceCanon': defaults_canon}
    return prof


def wire_githooks(root, guard=GUARD):
    put(root, '.githooks/pre-commit', 'bash %s\n' % guard)


def wire_workflow(root, guard=GUARD):
    put(root, '.github/workflows/check.yml',
        'jobs:\n  test:\n    steps:\n      - run: bash %s\n' % guard)


def wire_registry(root, guard=GUARD):
    put(root, 'registry/ci-steps.tsv', 'lanes\t7\nstep\tcheck:fixture\t1\tbash %s\n' % guard)


@dataclass(frozen=True)
class Cell:
    name: str
    build: object          # callable(root) -> None
    expect: object         # callable(world) -> (rc, точный полный вывод)


def exp_ok():
    return lambda world: (0, '')


def exp_old(guard=GUARD):
    return lambda world: (1, old_refusal(guard) + '\n')


def cells():
    rows = []

    def add(name, build, expect):
        rows.append(Cell(name=name, build=build, expect=expect))

    def gate_world(gate):
        return lambda w: (base_world(w), put(w, 'harness.project.json',
                          jdump(repo_profile(gate=gate))),
                          put(w, LAYER_REL, jdump(layer_profile())), put(w, 'AGENTS.md', '# toy\n'))

    # ── четвёртая локация: guard, вызываемый gate профиля (красные до ремонта)
    add('a1-gate-profilja', gate_world(['bash', GUARD]), exp_ok())
    add('a2-gate-v-defoltsah',
        lambda w: (base_world(w, PY_GUARD), put(w, 'harness.project.json',
                   jdump(repo_profile(canon=False))), put(w, LAYER_REL,
                   jdump(layer_profile(defaults_canon={'sources': [{'path': 'AGENTS.md', 'priority': 0}],
                                                   'gate': ['python3', PY_GUARD]}))),
                   put(w, 'AGENTS.md', '# toy\n')),
        exp_ok())
    add('a3-absoljutnyj-token',
        lambda w: (base_world(w), put(w, 'harness.project.json',
                   jdump(repo_profile(gate=[str(w / GUARD)]))),
                   put(w, LAYER_REL, jdump(layer_profile())), put(w, 'AGENTS.md', '# toy\n')),
        exp_ok())
    add('a4-gate-argv0', gate_world([GUARD]), exp_ok())
    add('a5-gate-py',
        lambda w: (base_world(w, PY_GUARD), put(w, 'harness.project.json',
                   jdump(repo_profile(gate=['python3', PY_GUARD]))),
                   put(w, LAYER_REL, jdump(layer_profile())), put(w, 'AGENTS.md', '# toy\n')),
        exp_ok())
    # ── К-09 Δ1: границы элементов argv — LF ВНУТРИ токена не режет его
    add('a6-lf-vnutri-tokena', gate_world(['bash', 'not-the-guard\n' + GUARD]), exp_old())
    add('a6b-chestnyj-sosed', gate_world(['bash', GUARD]), exp_ok())
    add('a6c-lf-posle-guarda', gate_world(['bash', GUARD + '\nx']), exp_old())
    # ── К-08 Δ1: подстрока и регистр подключением не считаются (И1/И4)
    add('a7-suffiks-bak', gate_world(['bash', GUARD + '.bak']), exp_old())
    add('a8-registr', gate_world(['bash', 'scripts/RED_GATE_205.SH']), exp_old())
    # ── профиль есть, но guard не вызывается (прежние клетки, зелёные всегда)
    add('b1-gate-chuzhoj', gate_world(['bash', 'scripts/other_check.sh']), exp_old())
    add('b2-bez-kanona',
        lambda w: (base_world(w), put(w, 'harness.project.json', jdump(repo_profile(canon=False))),
                   put(w, LAYER_REL, jdump(layer_profile()))),
        exp_old())
    add('b3-bez-profilya',
        lambda w: base_world(w),
        exp_old())
    # ── двойники имени не считаются подключением (по образцу прежних локаций)
    add('c1-podstroka-xred', gate_world(['bash', 'scripts/xred_gate_205.sh']), exp_old())
    add('c2-suffiks-old', gate_world(['bash', 'scripts/red_gate_205-old.sh']), exp_old())
    add('c3-imja-vne-gate',
        lambda w: (base_world(w), put(w, 'harness.project.json',
                   jdump(repo_profile(sources=[{'path': GUARD, 'priority': 0}],
                                      gate=['bash', 'scripts/other_check.sh']))),
                   put(w, LAYER_REL, jdump(layer_profile()))),
        exp_old())
    # ── существование guard-файла судится ДО подключения (инвариант 4, порядок)
    add('d1-fajl-net',
        lambda w: (base_world(w, with_guard=False), put(w, 'harness.project.json',
                   jdump(repo_profile())), put(w, LAYER_REL, jdump(layer_profile())),
                   put(w, 'AGENTS.md', '# toy\n')),
        lambda w: (1, 'проводка: guard-файл не существует: %s\n' % GUARD))
    # ── нераспознанный формат профиля — именованный отказ с местом (правило 7)
    add('e1-ne-json',
        lambda w: (base_world(w), put(w, 'harness.project.json', '{ "schemaVersion": 1,\n')),
        lambda w: (1, new_refusal('файл не JSON: %s' % (w / 'harness.project.json')) + '\n'))
    add('e2-sloj-net',
        lambda w: (base_world(w), put(w, 'harness.project.json',
                   jdump(repo_profile(profile_path='registry/net-takogo-sloja.json')))),
        lambda w: (1, new_refusal('нет файла слоя проекта: %s' % (w / 'registry/net-takogo-sloja.json')) + '\n'))
    add('e3-kanon-vne-alfavita',
        lambda w: (base_world(w), put(w, 'harness.project.json',
                   jdump(repo_profile(extra={'extra': 1}))),
                   put(w, LAYER_REL, jdump(layer_profile())), put(w, 'AGENTS.md', '# toy\n')),
        lambda w: (1, new_refusal('SOURCE_CANON_INVALID: репо-слой.sourceCanon: неизвестный ключ: extra') + '\n'))
    # ── прежние три локации признаются как прежде
    add('f1-githooks', lambda w: (base_world(w), wire_githooks(w)), exp_ok())
    add('f2-workflows', lambda w: (base_world(w), wire_workflow(w)), exp_ok())
    add('f3-reestr', lambda w: (base_world(w), wire_registry(w)), exp_ok())
    add('f4-githooks-pri-kanone',
        lambda w: (base_world(w), put(w, 'harness.project.json', jdump(repo_profile(gate=['bash', 'scripts/other_check.sh']))),
                   put(w, LAYER_REL, jdump(layer_profile())), put(w, 'AGENTS.md', '# toy\n'),
                   wire_githooks(w)),
        exp_ok())
    return rows


def jdump(obj):
    import json
    return json.dumps(obj, ensure_ascii=False, indent=2) + '\n'


class Prerequisite(RuntimeError):
    pass


def environment():
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    for name in ('SDACHA_OKRUG', 'HARNESS_PROJECT_LAYER_ROOT', 'HARNESS_WORKFLOW_ROOT'):
        env.pop(name, None)
    env['GIT_CONFIG_GLOBAL'] = '/dev/null'
    env['GIT_CONFIG_SYSTEM'] = '/dev/null'
    return env


def command(argv, *, cwd=None, timeout=30):
    proc = subprocess.Popen(argv, cwd=cwd, env=environment(), stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    try:
        out, err = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        os.killpg(proc.pid, signal.SIGKILL)
        proc.communicate()
        raise Prerequisite('TIMEOUT: ' + ' '.join(map(str, argv))) from exc
    return proc.returncode, out, err


def invoke(subject, world):
    rc, out, err = command(['bash', str(subject), str(world), CONTRACT])
    return rc, (out + err).decode('utf-8', 'replace')


def observe_cell(subject, scratch, cell, mutation=None):
    world = Path(tempfile.mkdtemp(dir=str(scratch), prefix=cell.name + '.'))
    try:
        cell.build(world)
        honest_expected = cell.expect(world)
        mutant_expected = (MUTANT_EXPECTED[mutation](cell, honest_expected)
                           if mutation is not None else None)
        observed = invoke(subject, world)
        return honest_expected, mutant_expected, observed
    finally:
        shutil.rmtree(world, ignore_errors=True)


def run_cells(subject, scratch, names=None):
    import json
    selected = [c for c in CELLS if names is None or c.name in names]
    if not selected:
        raise Prerequisite('EMPTY_SELECTION')
    mismatches = []
    for cell in selected:
        (want_rc, want_text), _, (rc, output) = observe_cell(subject, scratch, cell)
        matched = rc == want_rc and output == want_text
        if not matched:
            mismatches.append(cell.name)
        print('CELL ' + json.dumps(dict(name=cell.name, rc=rc, expected=want_rc,
                                        matched=matched, output=output), ensure_ascii=False))
    print('KLETKI=%d ZELENYE=%d KRASNYE=%d' % (len(selected), len(selected) - len(mismatches), len(mismatches)))
    return mismatches


# ── мутации модели: якорь ровно один, замены — по коду модели (Н-39) ─────────
ANCH_RESOLVER = ('prof_out="$(HARNESS_PROJECT_LAYER_ROOT="$root" '
                 'bash "$SELF_DIR/profile_resolver.sh" --repo "$root" 2>&1)"')
ANCH_ARM = '[ -f "$root/harness.project.json" ]'
ANCH_DIE = 'die "проводка: профиль проекта не распознан: $prof_reason"'
ANCH_EQUAL = 'if [ "$tok" = "$guard" ]; then found=1; break; fi'
ANCH_READ_NUL = 'while IFS= read -r -d \'\' tok; do'
ANCH_JQ = ('jq -j \'if has("sourceCanon") and (.sourceCanon.value != null) '
           'then (.sourceCanon.value.gate[]? | . + "\\u0000") else empty end\'')
ANCH_RESOLVER_ERROR = 'if [ $? -ne 0 ]; then'
ANCH_SUFFIX = ('if [ "${#tok}" -ge "${#suf}" ] && '
               '[ "${tok:$((${#tok} - ${#suf}))}" = "$suf" ]; then')
ANCH_GUARD_EXISTS = '[ -f "$ROOT/$guard" ] || die "проводка: guard-файл не существует: $guard"'
ANCH_DIE_FUNCTION = 'die()  { printf \'%s\\n\' "$*" >&2; exit 1; }'
JQ_LINES = ('jq -r \'if has("sourceCanon") and (.sourceCanon.value != null) '
            'then .sourceCanon.value.gate[]? else empty end\'')

MUTATIONS = {
    'VETKA-NET': ((ANCH_ARM, '[ -f "/net-takogo-profilya-205" ]'),),
    'PODSTROKA-BAZY': ((ANCH_EQUAL, 'case "$tok" in *"${guard##*/}"*) found=1; break ;; esac'),),
    'SLOVO-ERE': ((ANCH_EQUAL,
                   'if printf \'%s\' "$tok" | grep -Eq "(^|[^[:alnum:]_])$(b="${guard##*/}"; printf \'%s\' "${b%.sh}")([^[:alnum:]_]|$)"; then found=1; break; fi'),),
    'SYROJ-JSON': ((ANCH_RESOLVER,
                    'prof_out="$(jq -r \'.sourceCanon.gate[]?\' "$root/harness.project.json" 2>&1)"'),),
    'TIHO': ((ANCH_DIE, 'prof_reason=""'),),
    'ARGV0': ((ANCH_JQ, ANCH_JQ.replace('gate[]?', 'gate[0]?')),),
    # К-08 Δ1: обманки сравнения токена из вердикта критика
    'PODSTROKA-TOKENA': ((ANCH_EQUAL, 'if [[ "$tok" == *"$guard"* ]]; then found=1; break; fi'),),
    'REGISTR-TOKENA': ((ANCH_EQUAL, 'if [ "${tok,,}" = "${guard,,}" ]; then found=1; break; fi'),),
    # эквивалентные мутанты критика (правило суффикса И1) — ожидание EKVIVALENT
    'STRIP-RELATIVE': ((ANCH_EQUAL, 'if [ "${tok#./}" = "$guard" ]; then found=1; break; fi'),),
    'STRIP-DOTDOT': ((ANCH_EQUAL, 'if [ "${tok#../}" = "$guard" ]; then found=1; break; fi'),),
    # К-10 Δ1: лишняя диагностическая строка перед именованным отказом
    'LISHNJAJA-STROKA': ((ANCH_DIE,
                          'printf \'extraneous diagnostic\\n\' >&2; die "проводка: профиль проекта не распознан: $prof_reason"'),),
    # К-09 Δ1: прежнее построчное чтение — границы argv теряются на LF
    'LF-GRANITSY': ((ANCH_READ_NUL, 'while IFS= read -r tok; do'),
                    (ANCH_JQ, JQ_LINES)),
    # К-01 Δ2: все четыре исполненные мутации вердикта v1 — отдельными стабами.
    'ANY-FIELD': ((ANCH_JQ,
                   'jq -j \'if has("sourceCanon") and (.sourceCanon.value != null) then (.sourceCanon.value | .. | strings | . + "\\u0000") else empty end\''),),
    'IGNORE-ERRORS': ((ANCH_RESOLVER_ERROR, 'if false; then'),),
    # GATE-FIRST и ARGV0 воспроизводят один дефект: судится только gate[0].
    # Имя критика сохранено отдельным исполняемым стабом, не только упоминанием.
    'GATE-FIRST': ((ANCH_JQ, ANCH_JQ.replace('gate[]?', 'gate[0]?')),),
    'OMIT-SUFFIX': ((ANCH_SUFFIX, 'if false; then'),),
    'OTSUTSTVIE-GUARD': ((ANCH_GUARD_EXISTS, ':'),),
    # К-10 Δ2: вывод, ошибочно принимаемый сравнением strip(), но не точным.
    'STRIP-VYVODA': ((ANCH_DIE,
                      'printf \' \\n\' >&2; die "проводка: профиль проекта не распознан: $prof_reason"'),),
    'DIE-ECHO': ((ANCH_DIE,
                  'echo "проводка: профиль проекта не распознан: $prof_reason"'),),
    # Реальная мутация v2: разные строки в stdout/stderr перед отказом.
    'STDOUT-STDERR-RAZDEL': ((ANCH_DIE,
                             'printf \'stdout-first\\n\'; printf \'stderr-second\\n\' >&2; die "проводка: профиль проекта не распознан: $prof_reason"'),),
    # Честный die уже несёт LF; отсутствие этого байта отличает printf '%s'.
    'LF-V-KONCE': ((ANCH_DIE_FUNCTION,
                    'die()  { printf \'%s\' "$*" >&2; exit 1; }'),),
}


# Точные результаты сняты с адресных предъявлений на настоящих bash/jq/resolver.
# Ожидания вычисляются в памяти ДО invoke; неожиданный rc/вывод — не поимка.
JQ_ERROR_PROFILE = 'jq: parse error: Invalid numeric literal at line 1, column 8\n'
JQ_ERROR_RAW = 'jq: parse error: Invalid numeric literal at line 2, column 0\n'
MUTANT_EXPECTED = {
    'VETKA-NET': lambda cell, honest: (1, old_refusal(GUARD) + '\n'),
    'PODSTROKA-BAZY': lambda cell, honest: (0, ''),
    'SLOVO-ERE': lambda cell, honest: (0, ''),
    'SYROJ-JSON': lambda cell, honest: {
        'a2-gate-v-defoltsah': (1, old_refusal(PY_GUARD) + '\n'),
        'e3-kanon-vne-alfavita': (1, JQ_ERROR_RAW + old_refusal(GUARD) + '\n'),
    }[cell.name],
    'TIHO': lambda cell, honest: (1, JQ_ERROR_PROFILE + old_refusal(GUARD) + '\n'),
    'ARGV0': lambda cell, honest: (1, old_refusal(PY_GUARD) + '\n'),
    'PODSTROKA-TOKENA': lambda cell, honest: (0, ''),
    'REGISTR-TOKENA': lambda cell, honest: (0, ''),
    'STRIP-RELATIVE': lambda cell, honest: honest,
    'STRIP-DOTDOT': lambda cell, honest: honest,
    'LISHNJAJA-STROKA': lambda cell, honest: (1, 'extraneous diagnostic\n' + honest[1]),
    'LF-GRANITSY': lambda cell, honest: (0, ''),
    'ANY-FIELD': lambda cell, honest: (0, ''),
    'IGNORE-ERRORS': lambda cell, honest: (1, JQ_ERROR_PROFILE + old_refusal(GUARD) + '\n'),
    'GATE-FIRST': lambda cell, honest: (1, old_refusal(PY_GUARD) + '\n'),
    'OMIT-SUFFIX': lambda cell, honest: (1, old_refusal(GUARD) + '\n'),
    'OTSUTSTVIE-GUARD': lambda cell, honest: (0, ''),
    'STRIP-VYVODA': lambda cell, honest: (1, ' \n' + honest[1]),
    'DIE-ECHO': lambda cell, honest: (1, honest[1] + JQ_ERROR_PROFILE + old_refusal(GUARD) + '\n'),
    'STDOUT-STDERR-RAZDEL': lambda cell, honest: (1, 'stdout-first\nstderr-second\n' + honest[1]),
    'LF-V-KONCE': lambda cell, honest: (1, honest[1][:-1]),
}


def mutated_model(name):
    text = MODEL.read_text(encoding='utf-8')
    for old, new in MUTATIONS[name]:
        print('ANCHOR mutation=%s occurrences=%d' % (name, text.count(old)))
        if text.count(old) != 1:
            raise Prerequisite('ANCHOR %s: найдено %d вхождений' % (name, text.count(old)))
        text = text.replace(old, new)
    return text


def scratch_subject(scratch, model_text=None):
    resolver = (TREE / 'scripts/profile_resolver.sh').read_bytes()
    scripts = scratch / 'scripts'
    scripts.mkdir(parents=True, exist_ok=True)
    (scripts / 'profile_resolver.sh').write_bytes(resolver)
    text = model_text if model_text is not None else MODEL.read_text(encoding='utf-8')
    subject = scripts / 'check_provodka.sh'
    subject.write_text(text, encoding='utf-8')
    return subject


def read_bindings():
    rows = []
    for line in STABS.read_text(encoding='utf-8').splitlines():
        if not line or line.startswith('#'):
            continue
        parts = line.split('\t')
        if len(parts) != 3:
            raise Prerequisite('STABS ROW GRAMMAR (3 поля Мутация/клетка/ожидание): %r' % line)
        mutation, cell, expectation = parts
        if expectation not in ('POIMAN', 'EKVIVALENT'):
            raise Prerequisite('STABS OZHIDANIE (POIMAN|EKVIVALENT): %r' % line)
        rows.append((mutation, cell, expectation))
    if not rows:
        raise Prerequisite('EMPTY_STABS')
    return rows


def run_stabs(scratch):
    import json
    bindings = read_bindings()
    names = {cell for _, cell, _ in bindings}
    known = {cell.name: cell for cell in CELLS}
    unknown = names - known.keys()
    if unknown:
        raise Prerequisite('STABS UNKNOWN CELLS: %s' % sorted(unknown))
    subject = scratch_subject(scratch)
    poimany = ekvivalentnyh = 0
    zhivye = []
    used = set()
    for mutation, cell, expectation in bindings:
        used.add(mutation)
        honest = run_cells(subject, scratch, names={cell})
        if honest:
            print('STABS HONEST_CONTROL RED: %s' % honest)
            return 1
        mut_subject = scratch_subject(Path(tempfile.mkdtemp(dir=str(scratch), prefix='mut.')),
                                      mutated_model(mutation))
        honest_expected, mutant_expected, observed = observe_cell(
            mut_subject, scratch, known[cell], mutation=mutation)
        caught = observed != honest_expected
        exact = observed == mutant_expected
        if exact and caught == (expectation == 'POIMAN'):
            poimany += expectation == 'POIMAN'
            ekvivalentnyh += expectation == 'EKVIVALENT'
        else:
            zhivye.append('%s/%s' % (mutation, cell))
        print('STAB ' + json.dumps(dict(mutation=mutation, cell=cell, expectation=expectation,
                                        caught=caught, exact=exact, mutant_expected=mutant_expected,
                                        observed=observed), ensure_ascii=False))
    print('HONEST_CONTROLS=%d ZELENYE=%d KRASNYE=0' % (len(bindings), len(bindings)))
    print('MUTACII=%d SVJAZI=%d POIMANY=%d EKVIVALENT=%d ZHIVYH=%d'
          % (len(used), len(bindings), poimany, ekvivalentnyh, len(zhivye)))
    if zhivye:
        print('ZHIVYE: %s' % ' '.join(zhivye))
    return 0 if not zhivye else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', nargs='?', const=str(TREE), default=None, metavar='ROOT')
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--stabs', action='store_true')
    parser.add_argument('--attack', metavar='MUTATION')
    args = parser.parse_args()
    if (args.repo is not None) + args.model + args.stabs + (args.attack is not None) != 1:
        parser.error('ровно один режим: --repo [ROOT] | --model | --stabs | --attack <MUTATION>')
    try:
        scratch = Path(tempfile.mkdtemp(prefix='provodka_gate_205.'))
        try:
            if args.repo is not None:
                root = Path(args.repo).resolve()
                subject = root / 'scripts/check_provodka.sh'
                if not subject.is_file():
                    raise Prerequisite('НЕТ СУБЪЕКТА: %s' % subject)
                mism = run_cells(subject, scratch)
                print('REPO %s' % subject)
                return 1 if mism else 0
            if args.model:
                subject = scratch_subject(scratch)
                mism = run_cells(subject, scratch)
                return 1 if mism else 0
            if args.attack is not None:
                if args.attack not in MUTATIONS:
                    raise Prerequisite('НЕИЗВЕСТНАЯ МУТАЦИЯ: %s (есть: %s)'
                                       % (args.attack, ' '.join(sorted(MUTATIONS))))
                subject = scratch_subject(scratch, mutated_model(args.attack))
                mism = run_cells(subject, scratch)
                print('ATTACK %s' % args.attack)
                return 1 if mism else 0
            return run_stabs(scratch)
        finally:
            shutil.rmtree(scratch, ignore_errors=True)
    except Prerequisite as exc:
        print('NOT_IMPLEMENTED: %s' % exc, file=sys.stderr)
        return 2


CELLS = cells()
if __name__ == '__main__':
    sys.exit(main())
