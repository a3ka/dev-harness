#!/usr/bin/env python3
"""Батарея 127 (back-http-chislo): тесты HTTP-ядра (T) и smoke:http (S) Complior-back
берут число операций и версию API из производного контракта app/schemas/openapi.json.

Единый источник ожиданий — source.json рядом (память проверяющего): коммиты миров, мутации,
пины миров, ожидания T/S по мирам, обманные стабы и их привязка к миру (поле mir, Н-39).
Закрытая таблица проверок (proverki): каждая проверка T/S, судящая инварианты 1–3, со своим
миром, где краснеет ТОЛЬКО она; стаб «удалена только эта проверка» (bez-<id>) выводится из
таблицы и судится в её мире (контроль: модель там красна; без проверки — зелена).
Пины мира сверяются с построенным миром ДО запуска субъекта; диск кандидата как истина не
читается — из кандидата берутся ТОЛЬКО два судимых файла (T, S).
Переменные близнецы (bliznecy): каждый конформный мир (все ожидания green) получает близнеца
<id><suffix> — тот же мир плюс в корневой YAML добавлены операции, число и имена которых
выбираются ГСЧ при каждом построении (производный пересобран). Счёт близнеца не совпадает ни с
одним пином фиксированных миров и не равен числу добавленных путей, поэтому кандидат, узнающий
известные миры по признакам (путь, хэш, версия, число путей) вместо подсчёта операций, краснеет;
ожидание пина derived_operations близнеца = пин мира + добавлено (память проверяющего).

Режимы:
  (без аргументов)    суд ТЕКУЩЕГО продукта: T/S из коммита current_product (sha256 по пину)
  --candidate <клон>  суд доставленного дерева: из клона берутся только T и S
  --model             честная модель model/ против всех миров
  --stabs             каждый стаб source.json против СВОЕГО мира (control: модель там же)
  --world <id>        модель против одного мира
Коды: 0 — все ожидания сошлись (стабы: 0 непойманных); 1 — именованное расхождение;
      2 — нечем проверить / мир не построен / пин мира не сошёлся (NOT_IMPLEMENTED, МИР-ОТКАЗ).
Окружение: HTTP_CHISLO_127_BACK — клон Complior-back с коммитами миров и node_modules
(умолчание /tmp/dev-harness-verify/Architect127/back); HTTP_CHISLO_127_KEEP=1 — не удалять миры;
HTTP_CHISLO_127_SEED=<целое> — семя ГСЧ близнецов (по умолчанию случайное, печатается в начале прогона).
Миры одноразовые (git archive коммита в mktemp), сеть не используется.
"""
import hashlib
import json
import os
import random
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
BACK = os.environ.get('HTTP_CHISLO_127_BACK', '/tmp/dev-harness-verify/Architect127/back')
KEEP = os.environ.get('HTTP_CHISLO_127_KEEP') == '1'
HTTP_METHODS = ('get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace')
# Методы, которые считает загрузчик продукта (app/schemas/index.js METHODS); добавки близнецов — только из них.
LOADER_METHODS = ('get', 'put', 'post', 'patch', 'delete')
SUBJECTS = ('T', 'S')
VERDICTS = ('green', 'red')
MUTATION_KINDS = ('zamena', 'yaml-udalit-put', 'iz-kommita', 'proizvodnyi-udalit-put', 'yaml-dobavit-operacii')
PIN_KEYS = ('derived_operations', 'api_version', 'gen_check_rc', 'index_operation_count',
            'source_sha256_aktualen', 'derived_sha256_soglasovan')
CHECK_SUBJECTS = SUBJECTS + ('zagruzchik',)
ROOT_YAML = os.path.join('docs', 'contracts', 'BrokerOS_Unified_OpenAPI_v3.yaml')
DERIVED_DOC = os.path.join('app', 'schemas', 'openapi.json')
DERIVED_SRC = os.path.join('app', 'schemas', 'source.json')
RUN_TIMEOUT = 180
RNG = random.Random()


class Unverifiable(Exception):
    """rc 2: нечем проверить / мир не построен / пин мира не сошёлся."""


def clean_env():
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env['NO_COLOR'] = '1'
    return env


def git(*args, binary=False):
    res = subprocess.run(['git', '-C', BACK, *args], capture_output=True, env=clean_env())
    if res.returncode != 0:
        raise Unverifiable(f"NOT_IMPLEMENTED: git {' '.join(args[:2])} в клоне продукта: rc {res.returncode}")
    return res.stdout if binary else res.stdout.decode('utf-8')


def load_source():
    with open(os.path.join(HERE, 'source.json'), encoding='utf-8') as fh:
        src = json.load(fh)
    ids = [w['id'] for w in src['worlds']]
    if len(ids) != len(set(ids)):
        raise Unverifiable('source.json: повтор id мира')
    for w in src['worlds']:
        if w['commit'] not in src['commits']:
            raise Unverifiable(f"source.json: мир {w['id']}: неизвестный коммит {w['commit']}")
        if not w['expect'] or any(k not in SUBJECTS or v not in VERDICTS for k, v in w['expect'].items()):
            raise Unverifiable(f"source.json: мир {w['id']}: ожидание вне алфавита")
        if any(k not in PIN_KEYS for k in w['pin']):
            raise Unverifiable(f"source.json: мир {w['id']}: ключ пина вне алфавита")
        for m in w['mutations']:
            if m['kind'] not in MUTATION_KINDS:
                raise Unverifiable(f"source.json: мир {w['id']}: мутация вне алфавита: {m['kind']}")
    src['worlds'] += twin_worlds(src)
    ids = [w['id'] for w in src['worlds']]
    if len(ids) != len(set(ids)):
        raise Unverifiable('source.json: id близнеца совпал с id мира')
    sids = [s['id'] for s in src['stubs']]
    if len(sids) != len(set(sids)):
        raise Unverifiable('source.json: повтор id стаба')
    for s in src['stubs']:
        if s['mir'] not in ids:
            raise Unverifiable(f"source.json: стаб {s['id']}: неизвестный мир {s['mir']}")
        if not s['edits'] or any(e['file'] not in SUBJECTS for e in s['edits']):
            raise Unverifiable(f"source.json: стаб {s['id']}: правка вне алфавита файлов")
    src['stubs'] = removal_stubs(src, ids) + src['stubs']
    sids = [s['id'] for s in src['stubs']]
    if len(sids) != len(set(sids)):
        raise Unverifiable('source.json: id стаба таблицы проверок совпал с ручным стабом')
    return src


def twin_worlds(src):
    """Конформный мир → переменный близнец: те же мутации + yaml-dobavit-operacii, пересборка."""
    cfg = src['bliznecy']
    lo, hi = cfg['putei']
    if not (isinstance(lo, int) and isinstance(hi, int) and 1 <= lo <= hi) or not cfg['suffix']:
        raise Unverifiable('source.json: bliznecy: putei [lo, hi] вне 1 <= lo <= hi или пустой suffix')
    known = sorted({w['pin']['derived_operations'] for w in src['worlds']})
    twins = []
    for w in src['worlds']:
        if set(w['expect'].values()) != {'green'}:
            continue
        add = {'kind': 'yaml-dobavit-operacii', 'putei': [lo, hi], 'baza': w['pin']['derived_operations'],
               'izbegat': known}
        twins.append({'id': f"{w['id']}{cfg['suffix']}", 'intent': f"переменный близнец {w['id']}",
                      'commit': w['commit'], 'mutations': w['mutations'] + [add], 'regen': True,
                      'pin': dict(w['pin']), 'expect': dict(w['expect'])})
    if not twins:
        raise Unverifiable('source.json: нет конформного мира — близнецов нет')
    return twins


def removal_stubs(src, ids):
    """Таблица proverki → стабы «удалена только эта проверка»; загрузчик (вне T/S) стаба не даёт."""
    worlds = {w['id']: w for w in src['worlds']}
    model = model_files(src)
    cids = [c['id'] for c in src['proverki']]
    if not cids or len(cids) != len(set(cids)):
        raise Unverifiable('source.json: таблица proverki пуста или с повтором id')
    stubs = []
    for c in src['proverki']:
        if c['subject'] not in CHECK_SUBJECTS or c['mir'] not in ids:
            raise Unverifiable(f"source.json: проверка {c['id']}: субъект или мир вне алфавита")
        judged = 'T' if c['subject'] == 'zagruzchik' else c['subject']
        if worlds[c['mir']]['expect'].get(judged) != 'red':
            raise Unverifiable(f"source.json: проверка {c['id']}: мир {c['mir']} не ждёт red от {judged}")
        if c['subject'] == 'zagruzchik':
            if c['anchor'] is not None:
                raise Unverifiable(f"source.json: проверка {c['id']}: у проверки загрузчика нет якоря в T/S")
            continue
        found = model[c['subject']].count(c['anchor'])
        if found != 1:
            raise Unverifiable(f"source.json: проверка {c['id']}: якорь в модели {c['subject']}: вхождений {found}, нужно 1")
        stubs.append({'id': f"bez-{c['id']}", 'mir': c['mir'],
                      'edits': [{'file': c['subject'], 'old': c['anchor'], 'new': ''}]})
    return stubs


def check_back(src):
    if not os.path.isdir(os.path.join(BACK, '.git')):
        raise Unverifiable(f'NOT_IMPLEMENTED: нет клона продукта со своим .git: {BACK}')
    if not os.path.isdir(os.path.join(BACK, 'node_modules')):
        raise Unverifiable(f'NOT_IMPLEMENTED: в клоне продукта нет node_modules (npm ci): {BACK}')
    for name, sha in src['commits'].items():
        res = subprocess.run(['git', '-C', BACK, 'cat-file', '-e', f'{sha}^{{commit}}'],
                             capture_output=True, env=clean_env())
        if res.returncode != 0:
            raise Unverifiable(f'NOT_IMPLEMENTED: в клоне продукта нет коммита {name}={sha} (fetch main/cmp-bck-315/import)')


def count_operations(doc):
    return sum(1 for item in doc.get('paths', {}).values() if isinstance(item, dict)
               for m in HTTP_METHODS if isinstance(item.get(m), dict) and 'operationId' in item[m])


def read_text(path):
    with open(path, encoding='utf-8') as fh:
        return fh.read()


def read_bytes(path):
    with open(path, 'rb') as fh:
        return fh.read()


def write_text(path, text):
    with open(path, 'w', encoding='utf-8') as fh:
        fh.write(text)


def additions_block(m):
    """Случайные пути с непустым набором методов загрузчика: (строки YAML, добавлено операций, путей)."""
    lo, hi = m['putei']
    while True:
        methods = [RNG.sample(LOADER_METHODS, RNG.randint(1, len(LOADER_METHODS)))
                   for _ in range(RNG.randint(lo, hi))]
        added = sum(len(ms) for ms in methods)
        if added != len(methods) and m['baza'] + added not in m['izbegat']:
            break
    tag = f'{RNG.getrandbits(48):012x}'
    lines = []
    for i, ms in enumerate(methods):
        lines.append(f'  /v1/zz127-{tag}-{i}:')
        for meth in ms:
            lines += [f'    {meth}:', f'      operationId: zz127x{tag}x{i}{meth}', '      responses:',
                      "        '204':", '          description: zz127']
    return lines, added, len(methods)


def apply_mutation(world_dir, wid, m, src):
    """Применяет мутацию мира; возвращает число добавленных операций (0 — кроме yaml-dobavit-operacii)."""
    if m['kind'] == 'yaml-dobavit-operacii':
        path = os.path.join(world_dir, ROOT_YAML)
        lines = read_text(path).split('\n')
        at = [i for i, line in enumerate(lines) if line == 'paths:']
        if len(at) != 1:
            raise Unverifiable(f"МИР-ОТКАЗ {wid}: ключ 'paths:' в корневом YAML: вхождений {len(at)}, нужно 1")
        block, added, paths = additions_block(m)
        write_text(path, '\n'.join(lines[:at[0] + 1] + block + lines[at[0] + 1:]))
        print(f'  МИР {wid}: добавлено операций {added} на {paths} путях')
        return added
    if m['kind'] == 'iz-kommita':
        sha = src['commits'][m['from']]
        for rel in m['files']:
            data = git('show', f'{sha}:{rel}', binary=True)
            with open(os.path.join(world_dir, rel), 'wb') as fh:
                fh.write(data)
        return 0
    if m['kind'] == 'proizvodnyi-udalit-put':
        doc_path = os.path.join(world_dir, DERIVED_DOC)
        src_path = os.path.join(world_dir, DERIVED_SRC)
        old_bytes = read_bytes(doc_path)
        doc = json.loads(old_bytes)
        if m['path'] not in doc.get('paths', {}):
            raise Unverifiable(f"МИР-ОТКАЗ {wid}: в производном нет пути {m['path']!r}")
        del doc['paths'][m['path']]
        new_bytes = (json.dumps(doc, ensure_ascii=False, separators=(',', ':')) + '\n').encode('utf-8')
        with open(doc_path, 'wb') as fh:
            fh.write(new_bytes)
        if m['derived_sha256'] == 'obnovit':
            text = read_text(src_path)
            old_sha = hashlib.sha256(old_bytes).hexdigest()
            if text.count(old_sha) != 1:
                raise Unverifiable(f'МИР-ОТКАЗ {wid}: derived_sha256 в source.json: вхождений {text.count(old_sha)}, нужно 1')
            write_text(src_path, text.replace(old_sha, hashlib.sha256(new_bytes).hexdigest()))
        elif m['derived_sha256'] != 'ostavit':
            raise Unverifiable(f"МИР-ОТКАЗ {wid}: derived_sha256 вне алфавита obnovit|ostavit: {m['derived_sha256']!r}")
        return 0
    path = os.path.join(world_dir, m['file'])
    text = read_text(path)
    if m['kind'] == 'zamena':
        found = text.count(m['old'])
        if found != m['count']:
            raise Unverifiable(f"МИР-ОТКАЗ {wid}: замена в {m['file']}: вхождений {found}, по пину {m['count']}")
        write_text(path, text.replace(m['old'], m['new']))
        return 0
    lines = text.split('\n')
    starts = [i for i, line in enumerate(lines) if line == m['path_key']]
    if len(starts) != 1:
        raise Unverifiable(f"МИР-ОТКАЗ {wid}: ключ пути {m['path_key']!r}: вхождений {len(starts)}, нужно 1")
    start = starts[0]
    indent = len(lines[start]) - len(lines[start].lstrip(' '))
    end = start + 1
    while end < len(lines) and (lines[end].strip() == '' or len(lines[end]) - len(lines[end].lstrip(' ')) > indent):
        end += 1
    write_text(path, '\n'.join(lines[:start] + lines[end:]))
    return 0


def node(world_dir, *args):
    try:
        res = subprocess.run(['node', *args], cwd=world_dir, capture_output=True, env=clean_env(),
                             timeout=RUN_TIMEOUT)
    except subprocess.TimeoutExpired:
        return 124, f'таймаут {RUN_TIMEOUT} с'
    out = (res.stdout + res.stderr).decode('utf-8', 'replace')
    return res.returncode, out


def build_world(world, src, scratch):
    wid = world['id']
    d = tempfile.mkdtemp(prefix=f'w127-{wid}-', dir=scratch)
    archive = git('archive', src['commits'][world['commit']], binary=True)
    res = subprocess.run(['tar', '-x', '-C', d], input=archive, capture_output=True)
    if res.returncode != 0:
        raise Unverifiable(f'МИР-ОТКАЗ {wid}: tar rc {res.returncode}')
    os.symlink(os.path.join(BACK, 'node_modules'), os.path.join(d, 'node_modules'))
    added = 0
    for m in world['mutations']:
        added += apply_mutation(d, wid, m, src)
    if world['regen']:
        rc, out = node(d, 'tests/tools/gen-contracts.js')
        if rc != 0:
            raise Unverifiable(f'МИР-ОТКАЗ {wid}: gen:contracts rc {rc}: {out.strip()[-300:]}')
    derived = json.loads(read_text(os.path.join(d, 'app', 'schemas', 'openapi.json')))
    fact = {
        'derived_operations': count_operations(derived),
        'api_version': derived.get('info', {}).get('version'),
        'gen_check_rc': node(d, 'tests/tools/gen-contracts.js', '--check')[0],
    }
    if 'index_operation_count' in world['pin']:
        index = json.loads(read_text(os.path.join(d, 'docs', 'contracts', 'operation-index.json')))
        fact['index_operation_count'] = index.get('operation_count')
    # Независимость дефектного входа: source_sha256 актуален к корневому YAML, derived_sha256
    # согласован с байтами производного документа — пересчёт хэшей не отличает такой мир.
    meta = json.loads(read_text(os.path.join(d, DERIVED_SRC)))
    fact['source_sha256_aktualen'] = meta.get('source_sha256') == hashlib.sha256(read_bytes(os.path.join(d, ROOT_YAML))).hexdigest()
    fact['derived_sha256_soglasovan'] = meta.get('derived_sha256') == hashlib.sha256(read_bytes(os.path.join(d, DERIVED_DOC))).hexdigest()
    for key, want in world['pin'].items():
        if key == 'derived_operations':
            want += added
        if fact[key] != want:
            raise Unverifiable(f'МИР-ОТКАЗ {wid}: пин {key}: ожидался {want!r}, факт {fact[key]!r}')
    return d


def first_failure_lines(out):
    keep = [line.strip() for line in out.split('\n')
            if line.lstrip().startswith(('not ok', '✖')) or 'отказ' in line or 'AssertionError' in line]
    return ' | '.join(keep[:3])[:400]


def judge(world, src, scratch, files, label):
    """Кандидат files (T/S → текст) в мире world; возвращает список расхождений (пуст = сошлось)."""
    d = build_world(world, src, scratch)
    try:
        mismatches = []
        parts = []
        for subj in SUBJECTS:
            if subj not in world['expect']:
                continue
            write_text(os.path.join(d, src['subject'][subj]), files[subj])
            args = ('--test', src['subject'][subj]) if subj == 'T' else (src['subject'][subj],)
            rc, out = node(d, *args)
            fact = 'green' if rc == 0 else 'red'
            want = world['expect'][subj]
            parts.append(f'{subj}={fact}(ожидалось {want})')
            if fact != want:
                reason = f"{subj}:{world['id']}:ozhidalsya-{want}-fakt-{fact}"
                mismatches.append(reason)
                detail = first_failure_lines(out) if fact == 'red' else ''
                print(f"  РАСХОЖДЕНИЕ {reason}" + (f' — {detail}' if detail else ''))
        print(f"{label} МИР {world['id']}: {' '.join(parts)} — {'СОШЛОСЬ' if not mismatches else 'РАСХОЖДЕНИЕ'}")
        return mismatches
    finally:
        if not KEEP:
            shutil.rmtree(d, ignore_errors=True)


def model_files(src):
    return {s: read_text(os.path.join(HERE, 'model', os.path.basename(src['subject'][s]))) for s in SUBJECTS}


def stub_files(src, stub):
    files = dict(model_files(src))
    for e in stub['edits']:
        text = files[e['file']]
        found = text.count(e['old'])
        if found != 1:
            raise Unverifiable(f"стаб {stub['id']}: якорь правки {e['file']}: вхождений {found}, нужно 1")
        files[e['file']] = text.replace(e['old'], e['new'])
    if files == model_files(src):
        raise Unverifiable(f"стаб {stub['id']}: правки не меняют модель")
    return files


def product_files(src):
    cur = src['current_product']
    files = {}
    for s in SUBJECTS:
        data = git('show', f"{cur['commit']}:{src['subject'][s]}", binary=True)
        sha = hashlib.sha256(data).hexdigest()
        if sha != cur['sha256'][s]:
            raise Unverifiable(f"NOT_IMPLEMENTED: {src['subject'][s]} текущего продукта: sha256 {sha} ≠ пин")
        files[s] = data.decode('utf-8')
    return files


def candidate_files(src, clone):
    files = {}
    for s in SUBJECTS:
        path = os.path.join(clone, src['subject'][s])
        if not os.path.isfile(path):
            raise Unverifiable(f"NOT_IMPLEMENTED: в кандидате нет {src['subject'][s]}: {clone}")
        files[s] = read_text(path)
    return files


def run_worlds(src, scratch, files, label, worlds):
    bad = 0
    for w in worlds:
        if judge(w, src, scratch, files, label):
            bad += 1
    print(f'ИТОГ 127 ({label}): миров {len(worlds)}, сошлось {len(worlds) - bad}, расхождений {bad}')
    return 0 if bad == 0 else 1


def run_stubs(src, scratch):
    worlds = {w['id']: w for w in src['worlds']}
    model = model_files(src)
    caught = 0
    uncaught = []
    for stub in src['stubs']:
        files = stub_files(src, stub)
        world = worlds[stub['mir']]
        if judge(world, src, scratch, model, f"КОНТРОЛЬ[{stub['id']}]"):
            raise Unverifiable(f"контроль: модель не сошлась в мире {world['id']} — стаб {stub['id']} не судим")
        if judge(world, src, scratch, files, f"СТАБ[{stub['id']}]"):
            caught += 1
            print(f"СТАБ {stub['id']} @ {world['id']}: ПОЙМАН")
        else:
            uncaught.append(stub['id'])
            print(f"СТАБ {stub['id']} @ {world['id']}: НЕ ПОЙМАН")
    total = len(src['stubs'])
    print(f'ИТОГ 127 (стабы): стабов {total}, поймано {caught}, непойманных {len(uncaught)}'
          + (f" ({', '.join(uncaught)})" if uncaught else ''))
    return 0 if not uncaught and total > 0 else 1


def main(argv):
    src = load_source()
    check_back(src)
    seed_env = os.environ.get('HTTP_CHISLO_127_SEED')
    if seed_env is not None and not (seed_env.isascii() and seed_env.isdigit()):
        raise Unverifiable(f'HTTP_CHISLO_127_SEED вне алфавита [0-9]+: {seed_env!r}')
    seed = int(seed_env) if seed_env is not None else random.SystemRandom().randrange(2 ** 32)
    RNG.seed(seed)
    print(f'СЕМЯ 127: {seed} (повтор: HTTP_CHISLO_127_SEED={seed})')
    scratch = tempfile.mkdtemp(prefix='http127-', dir=os.environ.get('TMPDIR') or '/tmp')
    try:
        if not argv:
            return run_worlds(src, scratch, product_files(src), 'продукт', src['worlds'])
        if argv == ['--model']:
            return run_worlds(src, scratch, model_files(src), 'модель', src['worlds'])
        if argv == ['--stabs']:
            return run_stubs(src, scratch)
        if len(argv) == 2 and argv[0] == '--candidate':
            return run_worlds(src, scratch, candidate_files(src, argv[1]), 'кандидат', src['worlds'])
        if len(argv) == 2 and argv[0] == '--world':
            worlds = [w for w in src['worlds'] if w['id'] == argv[1]]
            if not worlds:
                raise Unverifiable(f'нет такого мира: {argv[1]}')
            return run_worlds(src, scratch, model_files(src), 'модель', worlds)
        print('использование: red_http_chislo_127.sh [--model | --stabs | --candidate <клон> | --world <id>]',
              file=sys.stderr)
        return 2
    finally:
        if not KEEP:
            shutil.rmtree(scratch, ignore_errors=True)


if __name__ == '__main__':
    try:
        sys.exit(main(sys.argv[1:]))
    except Unverifiable as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(2)
