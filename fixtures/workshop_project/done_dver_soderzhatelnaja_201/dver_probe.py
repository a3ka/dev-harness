#!/usr/bin/env python3
"""Красная батарея 201 — содержательная сверка done-двери (слово владельца
2026-11-17 п.10). Четыре пункта:

(а) accept ревьюера привязан к ПОСЛЕДНЕЙ заморозке: тег frozen/contracts/<NNN>/<vmax>
    обязателен, свежий accept-вердикт несёт строку OBJECT=<40 hex> и закоммичен
    не раньше коммита заморозки (F ⊆ CID, равенство проходит). Боль 141/991/999/109:
    дверь выбирала accept старой версии и ставила done (замер консультанта
    VerifyDone-1117-raw.json: rc 0 при неготовности).
(б) влитость: режим продукта (эффективный repoId ≠ dev-harness) — OBJECT обязан
    разрешаться в репо и быть равным/предком HEAD («SHA ⊂ main» на момент done);
    режим станции с OBJECT вне репо — контракт обязан объявить продукт строкой
    `ПРОДУКТ: <owner>/<repo>`, влитость проверяется GitHub compare API
    (main...OBJECT; identical|behind — влито) приёмом 187а (curl --max-time 30,
    GITHUB_TOKEN/GH_TOKEN). Недоступность API — честный отказ, не пропуск.
(в) рисковым (строка класса в ЗАМОРОЖЕННОМ тексте → registry/risk-legacy.tsv по
    blob → нет записи: рисковый, норма orchestrator) требуется свежий accept
    АДВЕРСАРИЯ на ТОТ ЖЕ OBJECT (литеральное равенство 40-hex). Боль 157/111/123/995.
(г) имя check-run arch: `arch`, `arch (…)`, `arch …` — принимаются;
    archive/architecture/march/arche — нет (боль: зелёный run бэкенда называется
    «arch (пин внешней архитектуры, model fitness + code-ratchet)», дверь искала
    буквальное «arch», done_contract.sh:245).

Миры — одноразовые git-репозитории по строительным приёмам
architecture_process_187/probe.py (toy-профиль, ПРОВОДКА guard, bare origin).
compare/check-runs подаются шимом curl из JSON-файлов ВНЕ мира
(DONE201_COMPARE / DONE201_CHECKRUNS). Ожидания — в памяти раннера
(правило 8), никогда в мире. Каждая клетка — одиночная мутация честного мира;
зелёная обязана закончиться тегом done/contracts/777/1, красная — rc 1 с
дословной причиной и без тега. Стабы — мутанты оракула, привязанные кодом к
клетке своего пункта (Н-39).
"""
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parents[2]

CONTRACT_STATION = 'contracts/777-work.md'
CONTRACT_PROJECT = '.harness/contracts/777-work.md'
EXTERNAL_OBJECT = 'e' * 40
OTHER_OBJECT = 'd' * 40
MISSING_OBJECT = 'f' * 40
PRODUCT_OWNER_REPO = 'a3ka/toy-mob'
SVARKA = 'СВЕРКА-АРХИТЕКТУРЫ: identity.lookup; app/identity; привязки проверены'

PH_A1 = 'done: нет заморозки frozen/contracts/777/* — привязка accept к последней версии невозможна'
PH_A2 = 'done: вердикт {f} без строки OBJECT=<40 hex> — объект реализации не назван'
PH_A3 = 'done: accept ревьюера {f} предшествует последней заморозке {t} — accept старой версии не открывает done новой'
PH_B1 = 'done: OBJECT {o} отсутствует в репо продукта — реализация не влита'
PH_B2 = 'done: OBJECT {o} не предок HEAD — реализация не влита в main продукта'
PH_B3 = 'done: OBJECT {o} вне репо контракта, а строки ПРОДУКТ: в контракте нет — влитость в продукт не проверяется'
PH_B4 = 'done: строка ПРОДУКТ: вне грамматики: {s}'
PH_B5 = 'done: влитость в main продукта {r} не проверена:'
PH_B6 = 'done: OBJECT {o} не в main продукта {r} — реализация не влита'
PH_V1 = 'done: предмет рисковый, accept адверсария не найден:'
PH_V2 = 'done: свежий вердикт адверсария {f} не accept'
PH_V3 = 'done: вердикт адверсария {f} без строки OBJECT=<40 hex> — объект не назван'
PH_V4 = 'done: accept адверсария {f} на объект {x}, ревьюера — на {y}: требуется тот же объект'
PH_V5 = 'done: класс риска контракта неоднозначен — судьи не определены'
PH_ARCH_CI = 'ARCH_CI'

PRODUCT_RE = re.compile(r'^ПРОДУКТ: ([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)$')
RISK_RE = re.compile(r'КЛАСС РИСКА:[ \t]*(обычный|рисковый)([ \t.,;]|$)')


def run(*args, cwd=None, env=None):
    p = subprocess.run([str(a) for a in args], cwd=str(cwd) if cwd else None,
                       env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return p.returncode, p.stdout


def git(root, *args):
    rc, out = run('git', '-C', root, *args)
    if rc:
        raise RuntimeError(f'git {args}: rc={rc} {out}')
    return out.strip()


def put(root, name, text):
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def contract_text(risk='обычный', product=None, both_risks=False):
    lines = ['# Work 777', 'КЛАСС ЗАДАЧИ: кодовый.']
    if both_risks:
        lines += ['КЛАСС РИСКА: рисковый.', 'КЛАСС РИСКА: обычный.']
    elif risk is not None:
        lines.append(f'КЛАСС РИСКА: {risk}.')
    if product is not None:
        lines.append(f'ПРОДУКТ: {product}')
    lines += ['КОНТЕКСТ: AGENTS.md', '## Существующее',
              'Дверь done уже существует; предмет — её содержательная сверка.',
              '## Предмет', 'Working code',
              'ЗОНА implementer: app/identity/model.js',
              'ПРОВОДКА:', '- guard=check.sh',
              'ПРОВОДКА-ЭНФОРСМЕНТ: только механизм']
    return '\n'.join(lines) + '\n'


def world(base, name, kind):
    """Одноразовый репозиторий с toy-профилем (канон architecture_process_187/probe.py)."""
    root = base / name
    root.mkdir()
    git(root, 'init', '-q', '-b', 'main')
    git(root, 'config', 'user.name', 'Fixture')
    git(root, 'config', 'user.email', 'fixture@local')
    git(root, 'config', 'commit.gpgsign', 'false')
    git(root, 'config', 'core.hooksPath', '/dev/null')
    remote = base / f'{name}-origin.git'
    git(root, 'init', '--bare', '-q', remote)
    git(root, 'remote', 'add', 'origin', remote)
    repo_id = {'station': 'dev-harness', 'mob': 'Complior-mob', 'back': 'Complior-back'}[kind]
    if kind == 'station':
        contracts_dir, layer_path = CONTRACT_STATION, 'registry/harness-project.json'
        workflow_paths = {'contracts': 'contracts', 'verdicts': 'verdicts',
                          'registry': 'registry', 'fixtures': 'fixtures'}
    else:
        contracts_dir, layer_path = CONTRACT_PROJECT, '.harness/project-layer.json'
        workflow_paths = {'contracts': '.harness/contracts', 'verdicts': '.harness/verdicts',
                          'registry': '.harness/registry', 'fixtures': '.harness/fixtures'}
    profile = {'schemaVersion': 1, 'repoId': repo_id, 'language': 'bash',
               'projectLayer': {'version': '1', 'profilePath': layer_path},
               'workflowPaths': workflow_paths,
               'git': {'canonicalRemote': str(remote)},
               'commands': dict.fromkeys(['test', 'build', 'typecheck', 'lint'], 'true'),
               'ci': {'workflow': '.github/workflows/toy.yml'},
               'barriers': {'mandatory': [], 'optional': []},
               'contextPack': {'rows': [
                   {'kind': 'map', 'path': 'STRUCTURE.md',
                    'roles': 'orchestrator,architect,critic,arbiter,implementer,adversary,reviewer',
                    'mandatory': True, 'why': 'toy structure'}]}}
    put(root, 'harness.project.json', json.dumps(profile))
    put(root, layer_path, json.dumps({'schemaVersion': 1, 'version': '1',
                                      'projectId': 'toy', 'workspaceId': 'toy', 'defaults': {}}))
    put(root, '.github/workflows/toy.yml',
        'name: toy\non: push\njobs:\n  check:\n    runs-on: ubuntu-latest\n    steps:\n      - run: bash check.sh\n')
    put(root, 'package.json', '{"scripts":{"check:toy":"bash check.sh"}}\n')
    put(root, 'check.sh', '#!/usr/bin/env bash\ntest -s AGENTS.md\n')
    put(root, 'AGENTS.md', '# Fixture\n')
    put(root, 'STRUCTURE.md', '# STRUCTURE_TOY_201\n')
    if kind == 'station':
        put(root, 'registry/contracts.tsv', '777 → ' + '0' * 40 + '\n')
    else:
        put(root, '.harness/registry/contracts.tsv', '777 → ' + '0' * 40 + '\n')
    if kind == 'back':
        put(root, 'architecture.lock.json',
            json.dumps({'format': 'toy-pin/1', 'repository': 'a3ka/toy-arch',
                        'commit': '0' * 40, 'status': 'APPROVED'}))
    put(root, 'app/identity/model.js', 'module.exports = 1;\n')
    return root, contracts_dir, ('registry/contracts.tsv' if kind == 'station'
                                 else '.harness/registry/contracts.tsv')


def review_path(kind):
    return ('verdicts/review' if kind == 'station' else '.harness/verdicts/review') + '/contracts-777-impl-v1.md'


def adversary_path(kind, suffix):
    return ('verdicts/adversary' if kind == 'station' else '.harness/verdicts/adversary') + f'/contracts-777-impl-{suffix}.md'


def verdict_text(object_sha, svarka=False):
    lines = ['ACCEPT']
    if object_sha is not None:
        lines.append(f'OBJECT={object_sha}')
    if svarka:
        lines.append(SVARKA)
    lines.append('Проверено батареей 201.')
    return '\n'.join(lines) + '\n'


# ── построение миров: (метка, kind, expect_rc, фраза) ─────────────────────────
CASES = (
    ('a-verdict-posle-zamorozki', 'station', 0, ''),
    ('a-ravenstvo-frozen-verdikt', 'station', 0, ''),
    ('a-accept-staroj-versii', 'station', 1, 'предшествует последней заморозке'),
    ('a-net-zamorozki', 'station', 1, 'нет заморозки frozen/contracts/777/*'),
    ('a-verdikt-bez-object', 'station', 1, 'без строки OBJECT='),
    ('b-produkt-vlito', 'mob', 0, ''),
    ('b-produkt-object-mimo-main', 'mob', 1, 'не предок HEAD — реализация не влита в main продукта'),
    ('b-produkt-object-otsutstvuet', 'mob', 1, 'отсутствует в репо продукта'),
    ('b-vneshnij-produkt-vlit', 'station', 0, ''),
    ('b-vneshnij-ne-vlit', 'station', 1, '— реализация не влита'),
    ('b-vneshnij-bez-stroki', 'station', 1, 'строки ПРОДУКТ: в контракте нет'),
    ('b-vneshnij-stroka-krivaja', 'station', 1, 'ПРОДУКТ: вне грамматики'),
    ('b-vneshnij-api-nedostupen', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена'),
    ('v-riskovyi-sopostavimyj-object', 'station', 0, ''),
    ('v-riskovyi-bez-adversarii', 'station', 1, 'accept адверсария не найден'),
    ('v-riskovyi-drugoj-object', 'station', 1, ', ревьюера — на '),
    ('v-riskovyi-svezhij-fail', 'station', 1, 'вердикт адверсария'),
    ('v-adversarii-bez-object', 'station', 1, 'адверсария'),
    ('v-obychnyj-bez-adversarii', 'station', 0, ''),
    ('v-default-riskovyi-bez-zapisi', 'station', 1, 'accept адверсария не найден'),
    ('v-legacy-obychnyj', 'station', 0, ''),
    ('v-klass-neodnoznachen', 'station', 1, 'класс риска контракта неоднозначен'),
    ('g-arch-tochno-imja', 'back', 0, ''),
    ('g-arch-v-skobkah', 'back', 0, ''),
    ('g-arch-s-probelom', 'back', 0, ''),
    ('g-archive', 'back', 1, PH_ARCH_CI),
    ('g-architecture', 'back', 1, PH_ARCH_CI),
    ('g-march', 'back', 1, PH_ARCH_CI),
)

STABS = {
    's-a-prinimaet-ljubuju-versiju': 'a-accept-staroj-versii',
    's-a-object-ne-nuzhen': 'a-verdikt-bez-object',
    's-b-vlitost-ne-proverjaetsja': 'b-produkt-object-mimo-main',
    's-b-api-vsegda-vlito': 'b-vneshnij-ne-vlit',
    's-v-adversarij-ne-trebuetsja': 'v-riskovyi-bez-adversarii',
    's-v-object-adversarija-ignoriruetsja': 'v-riskovyi-drugoj-object',
    's-g-arch-kak-podstroka': 'g-archive',
    's-g-arch-tolko-literalno': 'g-arch-v-skobkah',
}


def build(base, label, kind, name=None):
    """Строит мир клетки; возвращает (root, contract, facts). Ожидания — в facts,
    мир своего будущего не знает (правило 8). name — имя каталога мира (для
    стаб-копии той же клетки)."""
    if label.startswith('v-'):
        risk = None if label in ('v-default-riskovyi-bez-zapisi', 'v-legacy-obychnyj') \
            else ('оба' if label == 'v-klass-neodnoznachen' else
                  'обычный' if label == 'v-obychnyj-bez-adversarii' else 'рисковый')
    else:
        risk = 'обычный'
    product = PRODUCT_OWNER_REPO if (label.startswith('b-vneshnij-')
                                      and label not in ('b-vneshnij-bez-stroki', 'b-vneshnij-stroka-krivaja')) else None
    if label == 'b-vneshnij-stroka-krivaja':
        product = 'toy-mob'  # без слэша — вне грамматики

    root, contract, registry = world(base, name or label, kind)
    put(root, contract, contract_text(
        risk=None if risk is None else risk,
        product=product,
        both_risks=(risk == 'оба')))
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'baseline')
    b0 = git(root, 'rev-parse', 'HEAD')

    # реализация (коммит в зоне предмета)
    put(root, 'app/identity/model.js', 'module.exports = 2;\n')
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'implementation 777')
    impl = git(root, 'rev-parse', 'HEAD')

    object_sha = impl
    if label.startswith('b-vneshnij-'):
        object_sha = EXTERNAL_OBJECT
    if label == 'b-produkt-object-otsutstvuet':
        object_sha = MISSING_OBJECT
    if label == 'a-verdikt-bez-object':
        object_sha = None

    # вердикт ревьюера
    put(root, review_path(kind), verdict_text(object_sha, svarka=(kind == 'back')))
    if label == 'v-legacy-obychnyj':
        blob = git(root, 'rev-parse', f'{b0}:{contract}')
        legacy = root / registry.replace('contracts.tsv', 'risk-legacy.tsv')
        legacy.parent.mkdir(parents=True, exist_ok=True)
        legacy.write_text(f'{blob}\tобычный\tfixtures 201 — клетка v-legacy-obychnyj\towner\n')
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'verdikt 777')
    cid = git(root, 'rev-parse', 'HEAD')

    # адверсарий (только клетки (в))
    adversary = []
    if label.startswith('v-riskovyi') or label.startswith('v-adversarii'):
        if label == 'v-riskovyi-bez-adversarii':
            pass
        else:
            a_object = OTHER_OBJECT if label == 'v-riskovyi-drugoj-object' else object_sha
            a_text = 'ACCEPT\nПроверено адверсарием 201.\n' if label == 'v-adversarii-bez-object' \
                else verdict_text(a_object)
            put(root, adversary_path(kind, 'a1'), a_text)
            git(root, 'add', '-A')
            git(root, 'commit', '-qm', 'adversary 777 a1')
            adversary.append((git(root, 'rev-parse', 'HEAD'), 'ACCEPT', None if label == 'v-adversarii-bez-object' else a_object))
            if label == 'v-riskovyi-svezhij-fail':
                put(root, adversary_path(kind, 'a2'), 'FAIL\nOBJECT=' + object_sha + '\nПовторный суд нашёл блок.\n')
                git(root, 'add', '-A')
                git(root, 'commit', '-qm', 'adversary 777 a2 fail')
                adversary.append((git(root, 'rev-parse', 'HEAD'), 'FAIL', object_sha))

    # заморозка: где висит тег F — суть клетки (а)
    f_target = b0
    if label == 'a-ravenstvo-frozen-verdikt':
        f_target = cid
    if label == 'a-accept-staroj-versii':
        put(root, 'AGENTS.md', '# Fixture 2\n')
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'post-verdict freeze carrier')
        f_target = git(root, 'rev-parse', 'HEAD')
    if label != 'a-net-zamorozki':
        git(root, 'tag', 'frozen/contracts/777/1', f_target)

    # боковая невлитая ветка (клетка mimo-main)
    side = None
    if label == 'b-produkt-object-mimo-main':
        git(root, 'checkout', '-q', '-b', 'wip-side', impl)
        put(root, 'app/identity/model.js', 'module.exports = 3;\n')
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'side implementation not merged')
        side = git(root, 'rev-parse', 'HEAD')
        git(root, 'checkout', '-q', 'main')
        object_sha = side
        put(root, review_path(kind), verdict_text(side))
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'verdikt 777 na side')
        cid = git(root, 'rev-parse', 'HEAD')

    head = git(root, 'rev-parse', 'HEAD')

    # внешние ответы API — ВНЕ мира (шим curl читает env)
    compare_status = None
    if label.startswith('b-vneshnij-'):
        compare_status = {'b-vneshnij-produkt-vlit': 'behind',
                          'b-vneshnij-ne-vlit': 'ahead',
                          'b-vneshnij-bez-stroki': 'behind',
                          'b-vneshnij-stroka-krivaja': 'behind',
                          'b-vneshnij-api-nedostupen': 'not-found'}.get(label)
    checkrun_name = {'g-arch-tochno-imja': 'arch',
                     'g-arch-v-skobkah': 'arch (пин внешней архитектуры, model fitness + code-ratchet)',
                     'g-arch-s-probelom': 'arch fitness',
                     'g-archive': 'archive',
                     'g-architecture': 'architecture ratchet',
                     'g-march': 'march'}.get(label, 'arch')

    bin_dir = root.parent / (root.name + '-bin')
    bin_dir.mkdir(exist_ok=True)
    fake_curl = bin_dir / 'curl'
    fake_curl.write_text(
        '#!/usr/bin/env bash\n'
        'case "${@: -1}" in\n'
        '  *"/compare/"*) [ -n "$DONE201_COMPARE" ] && cat "$DONE201_COMPARE" || exit 31 ;;\n'
        '  *"/check-runs?"*) [ -n "$DONE201_CHECKRUNS" ] && cat "$DONE201_CHECKRUNS" || exit 31 ;;\n'
        '  *) exit 31 ;;\n'
        'esac\n')
    fake_curl.chmod(0o755)

    compare_file = root.parent / (root.name + '-compare.json')
    if compare_status == 'not-found':
        compare_file.write_text(json.dumps({'message': 'Not Found', 'documentation_url': 'https://docs.github.com'}))
    elif compare_status:
        compare_file.write_text(json.dumps({'status': compare_status, 'commits': []}))
    checkrun_file = root.parent / (root.name + '-checkruns.json')
    if kind == 'back':
        checkrun_file.write_text(json.dumps({'total_count': 1, 'check_runs': [
            {'id': 1, 'name': checkrun_name, 'status': 'completed',
             'conclusion': 'success', 'head_sha': head}]}))

    git(root, 'push', '-q', 'origin', 'main')

    facts = {'kind': kind, 'contract': contract, 'head': head, 'b0': b0,
             'impl': impl, 'cid': cid, 'frozen': None if label == 'a-net-zamorozki' else f_target,
             'object': object_sha, 'adversary': adversary, 'risk': risk,
             'product': product, 'compare_status': compare_status,
             'checkrun_name': checkrun_name,
             'review_file': review_path(kind), 'side': side,
             'compare_file': compare_file, 'checkrun_file': checkrun_file,
             'bin_dir': bin_dir,
             'legacy_obychnyj': label == 'v-legacy-obychnyj',
             'local_objects': set(git(root, 'rev-list', '--all').split())}
    return root, contract, facts


# ── оракул (в памяти раннера) ────────────────────────────────────────────────
def is_ancestor(root, a, b):
    if a is None or b is None:
        return False
    rc, _ = run('git', '-C', root, 'merge-base', '--is-ancestor', a, b)
    return rc == 0


def model(root, f, mutant=''):
    def skip(name):
        return mutant == name

    # (а)
    if f['frozen'] is None:
        return 1, PH_A1
    if not skip('s-a-object-ne-nuzhen') and not re.fullmatch(r'[0-9a-f]{40}', f['object'] or ''):
        return 1, PH_A2.format(f=f['review_file'])
    if not skip('s-a-prinimaet-ljubuju-versiju') and not is_ancestor(root, f['frozen'], f['cid']):
        return 1, PH_A3.format(f=f['review_file'], t='frozen/contracts/777/1')
    # (б)
    if not skip('s-b-vlitost-ne-proverjaetsja'):
        if f['kind'] != 'station':
            if f['object'] not in f['local_objects']:
                return 1, PH_B1.format(o=f['object'])
            if not is_ancestor(root, f['object'], f['head']):
                return 1, PH_B2.format(o=f['object'])
        elif f['object'] not in f['local_objects']:
            line = f['product']
            if line is None:
                return 1, PH_B3.format(o=f['object'])
            if not PRODUCT_RE.match(f'ПРОДУКТ: {line}' if isinstance(line, str) else ''):
                return 1, PH_B4.format(s=f'ПРОДУКТ: {line}')
            status = f['compare_status']
            if skip('s-b-api-vsegda-vlito'):
                status = 'behind' if status else 'not-found-green'
            if status in ('identical', 'behind', 'not-found-green'):
                pass
            elif status in ('ahead', 'diverged'):
                return 1, PH_B6.format(o=f['object'], r=PRODUCT_OWNER_REPO)
            else:
                return 1, PH_B5.format(r=PRODUCT_OWNER_REPO) + ' API недоступен'
    # (в)
    klass = 'обычный'
    if f['risk'] == 'оба':
        return 1, PH_V5
    if f['risk'] == 'рисковый':
        klass = 'рисковый'
    elif f['risk'] is None:
        klass = 'рисковый'  # нет строки и записи risk-legacy (клетка default; legacy-клетка зелёна без адверсария)
        if f.get('legacy_obychnyj'):
            klass = 'обычный'
    if klass == 'рисковый' and not skip('s-v-adversarij-ne-trebuetsja'):
        if not f['adversary']:
            return 1, PH_V1 + f' {f["review_file"].rsplit("/", 1)[0]}/contracts-777-*.md'
        commit, first, a_object = f['adversary'][-1]
        if first.strip().lower() != 'accept':
            return 1, PH_V2.format(f=adversary_path(f['kind'], 'a2' if len(f['adversary']) > 1 else 'a1'))
        if a_object is None:
            return 1, PH_V3.format(f=adversary_path(f['kind'], 'a1'))
        if not skip('s-v-object-adversarija-ignoriruetsja') and a_object != f['object']:
            return 1, PH_V4.format(f=adversary_path(f['kind'], 'a1'), x=a_object, y=f['object'])
    # (г)
    if f['kind'] == 'back':
        name = f['checkrun_name']
        if skip('s-g-arch-kak-podstroka'):
            ok_name = 'arch' in name
        elif skip('s-g-arch-tolko-literalno'):
            ok_name = name == 'arch'
        else:
            ok_name = name == 'arch' or name.startswith('arch ') or name.startswith('arch (')
        if not ok_name:
            return 1, f'{PH_ARCH_CI}: успешного check-run arch на финальном SHA нет'
    return 0, ''


def live(tools, root, contract, facts):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(root), HARNESS_WORKFLOW_ROOT=str(root),
               DONE201_COMPARE=str(facts['compare_file']),
               DONE201_CHECKRUNS=str(facts['checkrun_file']),
               PATH=str(facts['bin_dir']) + os.pathsep + env.get('PATH', ''))
    return run('bash', tools / 'scripts/done_contract.sh', contract, 'батарея 201: клетка', root,
               cwd=root, env=env)


def main():
    mode = sys.argv[1:2]
    tools = TOOLS
    if mode and mode[0] == '--repo':
        tools = Path(sys.argv[2]).resolve()
        mode = sys.argv[3:4]
    failures = []
    with tempfile.TemporaryDirectory(prefix='dver-201-') as temp:
        base = Path(temp)
        for label, kind, expected, phrase in CASES:
            root, contract, facts = build(base, label, kind)
            m_rc, m_out = model(root, facts)
            if m_rc != expected or (phrase and phrase not in m_out):
                raise RuntimeError(f'сломанная фикстура: {label} ожидалось {expected}/{phrase!r}, модель дала {m_rc}/{m_out!r}')
            if mode and mode[0] in ('--model', '--stabs'):
                rc, output = m_rc, m_out
            else:
                rc, output = live(tools, root, contract, facts)
            live_mode = not (mode and mode[0] in ('--model', '--stabs'))
            tags = git(root, 'tag', '-l', 'done/contracts/777/*') if live_mode else ''
            ok = rc == expected and (not phrase or phrase in output)
            if live_mode and expected == 0 and not tags:
                ok = False
            if live_mode and expected and tags:
                ok = False
            if not ok:
                failures.append(label)
            print(f'{"GREEN" if ok else "RED"} {label}: rc={rc} expected={expected}'
                  + (f' reason={phrase}' if phrase else '')
                  + ('' if ok else f' output={output[:400]!r}'))
            if mode and mode[0] == '--stabs':
                for name, cell in STABS.items():
                    if cell != label:
                        continue
                    fake_root, _, fake_facts = build(base, label, kind, name=label + '-stub')
                    f_rc, f_out = model(fake_root, fake_facts, name)
                    caught = f_rc != expected or (phrase and phrase not in f_out)
                    print(f'STAB {name} {"caught" if caught else "ZHIV"} @ {label}')
                    if not caught:
                        failures.append(name)
    print(f'CELLS={len(CASES)} STABS={len(STABS) if mode and mode[0] == "--stabs" else 0} FAILURES={len(failures)}')
    return int(bool(failures))


if __name__ == '__main__':
    raise SystemExit(main())
