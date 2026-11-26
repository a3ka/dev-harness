#!/usr/bin/env python3
"""Красная батарея 201 — содержательная сверка done-двери (слово владельца
2026-11-17 п.10; решения 1–2 арбитража 1, verdicts/arbitration/
201-granica-done-dveri.md). Четыре пункта:

(а) accept ревьюера привязан к ПОСЛЕДНЕЙ заморозке: оракул САМ выбирает vmax из
    тегов frozen/contracts/<NNN>/* мира (не из фактов сборки), свежий
    accept-вердикт несёт строку OBJECT=<40 hex>, закоммичен не раньше F и СВЯЗАН
    с F самим объектом: при F ⊊ CID — F ⊆ OBJECT; при F == CID — одновременно
    OBJECT ⊆ F И тождество Git-деревьев OBJECT и F за вычетом только точных
    файлов судебных свидетельств (выбранный reviewer-файл; для рискового — ещё
    выбранный accept-файл адверсария; решение 1: ancestry недостаточен — мир
    B→I→F с OBJECT=B проходит родословную, но не содержит реализации; сам F,
    добавляющий реализацию, тоже отказывается). Канон — git diff-tree -r --raw
    --no-renames (пути, моды, OID, удаления, gitlinks). Для OBJECT вне репо
    доказательство переноса — влитость в main продукта (пункт б).
(б) влитость: режим продукта (эффективный repoId ≠ dev-harness) — OBJECT обязан
    разрешаться в репо и быть равным/предком HEAD. Режим станции — ТРИ состояния
    (решение 2): объявленная строка `ПРОДУКТ: станция` (OBJECT обязан быть
    локальным); объявленный `ПРОДУКТ: <owner>/<repo>` (OBJECT обязан быть
    внешним, влитость — GitHub compare API, main...OBJECT,
    identical|behind — влито); место НЕ установлено — отказ fail-closed,
    независимо от локальной разрешимости OBJECT (ни пустое поле, ни отсутствие
    строки не означают «станция»). Для замороженных БЕЗ объявления — реестр
    классификации registry/mesto-legacy.tsv по ключу (NNN, blob замороженного
    текста): применимая запись даёт место; нет записи / конфликт / вне
    грамматики — отказ. Запись от другого blob не действует; источник записи —
    закоммиченный на HEAD файл (git show; рабочая копия и индекс — не
    свидетельство; блок К-10 krug 3).
(в) рисковым (строка класса в ЗАМОРОЖЕННОМ тексте выбранной заморозки →
    registry/risk-legacy.tsv по blob, тоже только с HEAD → нет записи: рисковый,
    норма orchestrator) требуется свежий accept АДВЕРСАРИЯ на ТОТ ЖЕ OBJECT
    (литеральное равенство 40-hex). Боль 157/111/123/995.
(г) имя check-run arch: `arch`, `arch (…)`, `arch …` — принимаются;
    archive/architecture/march/arche — нет (боль: зелёный run бэкенда называется
    «arch (пин внешней архитектуры, model fitness + code-ratchet)», дверь искала
    буквальное «arch», done_contract.sh:245).
(д) полный разбор ровно ОДНОГО JSON-документа (РЕШЕНИЯ 1–3 арбитража 2,
    verdicts/arbitration/201-granica-done-dveri-2.md; блок Adv201b
    1fe7004d63): свидетельство compare/check-runs принимается только после
    успешного ПОЛНОГО разбора ответа каноническим jq -s (length == 1,
    тип-объект ДО извлечения поля, rc jq ДО использования результата):
    повреждённый хвост при успешном префиксе, второй документ (включая
    {}), ошибка jq — НЕ свидетельство; сырые NUL-байты ответа (хвост,
    внутри значения, внутри ключа — Adv201c блок 1) — тот же класс:
    канонический jq эти байты отвергает (rc≠0), а bash-транспорт "$(curl …)"
    двери теряет NUL ДО jq и мутирует ответ; допустимый внешний whitespace
    вокруг единственного документа отказом не является (парные
    положительные контроли behind/identical и arch-имена). Поле status
    со значением вне словаря — отказ с правдивой причиной «неподдерживаемое
    значение status», а не «без поля» (Adv201c блок 2); честное отсутствие
    поля — отдельная ветвь, с этим входом не смешивается. Профиль мира —
    тот же механизм: пути/repoId/canonicalRemote не продолжают работу на
    повреждённом/многодокументном профиле (без fallback), а штатное
    ОТСУТСТВИЕ необязательного git.canonicalRemote — прежний допустимый
    fallback. Карта jq-вызовов живой двери (весь разбор недоверенного
    JSON — через _json_one_object) проверяется в live-режимах батареи.

Миры — одноразовые git-репозитории по строительным приёмам
architecture_process_187/probe.py (toy-профиль, ПРОВОДКА guard, bare origin);
станционные миры несут явное объявление `ПРОДУКТ: станция` (норма новых
текстов), клетки места реализации его снимают. compare/check-runs подаются
шимом curl из JSON-файлов ВНЕ мира (DONE201_COMPARE / DONE201_CHECKRUNS).
Ожидания — в памяти раннера (правило 8), никогда в мире. Каждая клетка —
одиночная мутация честного мира; зелёная обязана закончиться тегом
done/contracts/777/1, красная — rc 1 с дословной причиной и без тега. Стабы —
мутанты оракула, привязанные кодом к клетке своего пункта (Н-39).
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

NN = '777'
CONTRACT_STATION = 'contracts/777-work.md'
CONTRACT_PROJECT = '.harness/contracts/777-work.md'
EXTERNAL_OBJECT = 'e' * 40
OTHER_OBJECT = 'd' * 40
MISSING_OBJECT = 'f' * 40
PRODUCT_OWNER_REPO = 'a3ka/toy-mob'
STATION_DECL = 'ПРОДУКТ: станция'
SVARKA = 'СВЕРКА-АРХИТЕКТУРЫ: identity.lookup; app/identity; привязки проверены'

PH_A1 = 'done: нет заморозки frozen/contracts/777/* — привязка accept к последней версии невозможна'
PH_A2 = 'done: вердикт {f} без строки OBJECT=<40 hex> — объект реализации не назван'
PH_A3 = 'done: accept ревьюера {f} предшествует последней заморозке {t} — accept старой версии не открывает done новой'
PH_A4 = 'done: OBJECT {o} не связан с последней заморозкой {t} — вердикт судит объект старой версии'
PH_B1 = 'done: OBJECT {o} отсутствует в репо продукта — реализация не влита'
PH_B2 = 'done: OBJECT {o} не предок HEAD — реализация не влита в main продукта'
PH_B4 = 'done: строка ПРОДУКТ: вне грамматики: {s}'
PH_B5 = 'done: влитость в main продукта {r} не проверена:'
PH_B6 = 'done: OBJECT {o} не в main продукта {r} — реализация не влита'
PH_B7 = 'done: OBJECT {o} разрешается в репо станции, а контракт объявил продукт {r} — OBJECT внешнего предмета обязан быть SHA продукта'
PH_B7DUP = 'done: строка ПРОДУКТ: неоднозначна: {v}'
PH_B8 = 'done: место реализации предмета {n} не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv'
PH_B8K = 'done: классификация места предмета {n} в registry/mesto-legacy.tsv неоднозначна или вне грамматики — отказ до исправления записи'
PH_B9 = 'done: OBJECT {o} вне репо станции, а контракт объявил станционную реализацию — OBJECT обязан быть SHA станции'
PH_V1 = 'done: предмет рисковый, accept адверсария не найден:'
PH_V2 = 'done: свежий вердикт адверсария {f} не accept'
PH_V3 = 'done: вердикт адверсария {f} без строки OBJECT=<40 hex> — объект не назван'
PH_V4 = 'done: accept адверсария {f} на объект {x}, ревьюера — на {y}: требуется тот же объект'
PH_V5 = 'done: класс риска контракта неоднозначен — судьи не определены'
PH_ARCH_CI = 'ARCH_CI'

PRODUCT_RE = re.compile(r'^ПРОДУКТ: ([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)$')
MESTO_RE = re.compile(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$')
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
    if kind == 'back':
        profile['hooks'] = {'archBrief': 'a3ka/Complior-back'}
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
    ('a-object-do-zamorozki', 'station', 1, 'не связан с последней заморозкой'),
    ('a-dve-zamorozki', 'station', 1, 'предшествует последней заморозке'),
    ('a-drevo-object-do-realizacii', 'station', 1, 'не связан с последней заморозкой'),
    ('a-drevo-realizacija-v-f', 'station', 1, 'не связан с последней заморозкой'),
    ('b-produkt-vlito', 'mob', 0, ''),
    ('b-produkt-object-mimo-main', 'mob', 1, 'не предок HEAD — реализация не влита в main продукта'),
    ('b-produkt-object-otsutstvuet', 'mob', 1, 'отсутствует в репо продукта'),
    ('b-vneshnij-produkt-vlit', 'station', 0, ''),
    ('b-vneshnij-curl-s-oshibkoj', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена: curl rc=1'),
    ('b-vneshnij-json-povrezhdjon-hvost', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON'),
    ('b-vneshnij-dva-dokumenta', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (в ответе несколько JSON-документов'),
    ('b-vneshnij-nul-hvost', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON'),
    ('b-vneshnij-nul-v-znachenii', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON'),
    ('b-vneshnij-nul-v-klyuche', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена: ответ API не разобран (синтаксическая ошибка JSON'),
    ('b-vneshnij-status-chislo', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена: неподдерживаемое значение status'),
    ('b-vneshnij-ne-vlit', 'station', 1, '— реализация не влита'),
    ('b-vneshnij-identical', 'station', 0, ''),
    ('b-vneshnij-bez-stroki', 'station', 1, 'место реализации предмета 777 не установлено'),
    ('b-vneshnij-stroka-krivaja', 'station', 1, 'ПРОДУКТ: вне грамматики'),
    ('b-vneshnij-api-nedostupen', 'station', 1, 'влитость в main продукта a3ka/toy-mob не проверена'),
    ('b-vneshnij-object-stancionnyj', 'station', 1, 'обязан быть SHA продукта'),
    ('b-vneshnij-dublikat-stroki', 'station', 1, 'строка ПРОДУКТ: неоднозначна'),
    ('b-stancionnyj-objavlennyj', 'station', 0, ''),
    ('b-stancionnyj-object-vneshnij', 'station', 1, 'вне репо станции, а контракт объявил станционную реализацию'),
    ('b-mesto-neizvestno', 'station', 1, 'место реализации предмета 777 не установлено'),
    ('b-legacy-stancionnyj', 'station', 0, ''),
    ('b-legacy-vneshnij-vlit', 'station', 0, ''),
    ('b-legacy-vneshnij-ne-vlit', 'station', 1, '— реализация не влита'),
    ('b-legacy-chuzhoj-blob', 'station', 1, 'место реализации предмета 777 не установлено'),
    ('b-legacy-rabochaja-zapis', 'station', 1, 'место реализации предмета 777 не установлено'),
    ('b-legacy-staged-zapis', 'station', 1, 'место реализации предмета 777 не установлено'),
    ('b-legacy-zakomchennaja-zapis', 'station', 0, ''),
    ('v-riskovyi-sopostavimyj-object', 'station', 0, ''),
    ('v-riskovyi-bez-adversarii', 'station', 1, 'accept адверсария не найден'),
    ('v-riskovyi-head-obychnyj', 'station', 1, 'accept адверсария не найден'),
    ('v-riskovyi-drugoj-object', 'station', 1, ', ревьюера — на '),
    ('v-riskovyi-svezhij-fail', 'station', 1, 'вердикт адверсария'),
    ('v-adversarii-bez-object', 'station', 1, 'адверсария'),
    ('v-obychnyj-bez-adversarii', 'station', 0, ''),
    ('v-default-riskovyi-bez-zapisi', 'station', 1, 'accept адверсария не найден'),
    ('v-legacy-obychnyj', 'station', 0, ''),
    ('v-legacy-rabochaja-zapis', 'station', 1, 'accept адверсария не найден'),
    ('v-klass-neodnoznachen', 'station', 1, 'класс риска контракта неоднозначен'),
    ('g-arch-tochno-imja', 'back', 0, ''),
    ('g-arch-v-skobkah', 'back', 0, ''),
    ('g-arch-s-probelom', 'back', 0, ''),
    ('g-profil-povrezhdyon-fajl', 'back', 1, 'ОТКАЗ: профиль битый или workflowPaths вне репо'),
    ('g-profil-dva-dokumenta', 'back', 1, 'ОТКАЗ: профиль битый или workflowPaths вне репо'),
    ('g-profil-bez-canonical-remote', 'back', 0, ''),
    ('g-arch-curl-s-oshibkoj', 'back', 1, PH_ARCH_CI),
    ('g-arch-json-povrezhdjon-hvost', 'back', 1, 'ARCH_CI: ответ check-runs не разобран (синтаксическая ошибка JSON'),
    ('g-arch-dva-dokumenta', 'back', 1, 'ARCH_CI: ответ check-runs не разобран (в ответе несколько JSON-документов'),
    ('g-archive', 'back', 1, PH_ARCH_CI),
    ('g-architecture', 'back', 1, PH_ARCH_CI),
    ('g-arche', 'back', 1, PH_ARCH_CI),
    ('g-march', 'back', 1, PH_ARCH_CI),
    ('g-arch-nul-hvost', 'back', 1, 'ARCH_CI: ответ check-runs не разобран (синтаксическая ошибка JSON'),
)

STABS = {
    's-a-prinimaet-ljubuju-versiju': 'a-accept-staroj-versii',
    's-a-object-bez-svjazi': 'a-object-do-zamorozki',
    's-a-staraja-zamorozka': 'a-dve-zamorozki',
    's-a-tolko-rodoslovnaja': 'a-drevo-object-do-realizacii',
    's-b-stancionnyj-object-prohodit': 'b-vneshnij-object-stancionnyj',
    's-a-object-ne-nuzhen': 'a-verdikt-bez-object',
    's-b-vlitost-ne-proverjaetsja': 'b-produkt-object-mimo-main',
    's-b-api-vsegda-vlito': 'b-vneshnij-ne-vlit',
    's-b-curl-rc-tolko-default': 'b-vneshnij-curl-s-oshibkoj',
    's-b-mesto-po-umolchaniju-stancija': 'b-mesto-neizvestno',
    's-b-mesto-iz-rabochego-fajla': 'b-legacy-rabochaja-zapis',
    's-v-adversarij-ne-trebuetsja': 'v-riskovyi-bez-adversarii',
    's-v-risk-iz-rabochego-fajla': 'v-legacy-rabochaja-zapis',
    's-v-risk-iz-head': 'v-riskovyi-head-obychnyj',
    's-v-object-adversarija-ignoriruetsja': 'v-riskovyi-drugoj-object',
    's-g-arch-kak-podstroka': 'g-archive',
    's-g-arch-tolko-literalno': 'g-arch-v-skobkah',
    's-g-curl-rc-ignoriruetsja': 'g-arch-curl-s-oshibkoj',
    's-b-json-hvost-ignoriruetsja': 'b-vneshnij-json-povrezhdjon-hvost',
    's-b-potok-dokumentov-dopushhen': 'b-vneshnij-dva-dokumenta',
    's-b-nul-transport-terjaet-bajty': 'b-vneshnij-nul-hvost',
    's-b-status-vne-slovarya-kak-otsutstvie': 'b-vneshnij-status-chislo',
    's-g-arche-razresheno': 'g-arche',
    's-g-json-hvost-ignoriruetsja': 'g-arch-json-povrezhdjon-hvost',
    's-g-potok-dokumentov-dopushhen': 'g-arch-dva-dokumenta',
    's-g-profil-potok-dopushhen': 'g-profil-dva-dokumenta',
    's-g-nul-transport-terjaet-bajty': 'g-arch-nul-hvost',
}


def build(base, label, kind, name=None):
    """Строит мир клетки; возвращает (root, contract, facts). Ожидания — в facts,
    мир своего будущего не знает (правило 8). name — имя каталога мира (для
    стаб-копии той же клетки)."""
    if label.startswith('v-'):
        risk = None if label in ('v-default-riskovyi-bez-zapisi', 'v-legacy-obychnyj',
                                 'v-legacy-rabochaja-zapis') \
            else ('оба' if label == 'v-klass-neodnoznachen' else
                  'обычный' if label == 'v-obychnyj-bez-adversarii' else 'рисковый')
    else:
        risk = 'обычный'
    # место реализации: станционные миры несут явное объявление (решение 2);
    # клетки места/legacy-классификации его снимают или подменяют
    product = 'станция' if kind == 'station' else None
    if label.startswith('b-vneshnij-') and label not in ('b-vneshnij-bez-stroki', 'b-vneshnij-stroka-krivaja'):
        product = PRODUCT_OWNER_REPO
    if label == 'b-vneshnij-stroka-krivaja':
        product = 'toy-mob'  # без слэша — вне грамматики
    if label in ('b-vneshnij-bez-stroki', 'b-mesto-neizvestno') or label.startswith('b-legacy-'):
        product = None  # замороженный текст без объявления — классифицирует реестр/отказ
    root, contract, registry = world(base, name or label, kind)
    # профиль мира (РЕШЕНИЕ 3 Arb201V2): клетки профильного маршрута портят
    # harness.project.json ДО базового коммита — дверь читает файл с диска;
    # положительный профильный контроль снимает НЕобязательный ключ git
    # (штатное отсутствие canonicalRemote ≠ ошибка разбора)
    if label in ('g-profil-povrezhdyon-fajl', 'g-profil-dva-dokumenta'):
        prof = root / 'harness.project.json'
        prof.write_text(prof.read_text() + '\n'
                        + ('{broken' if label == 'g-profil-povrezhdyon-fajl' else '{}') + '\n')
    if label == 'g-profil-bez-canonical-remote':
        prof = root / 'harness.project.json'
        prof.write_text(json.dumps({k: v for k, v in json.loads(prof.read_text()).items()
                                    if k != 'git'}))
    text = contract_text(
        risk=None if risk is None else risk,
        product=product,
        both_risks=(risk == 'оба'))
    if label == 'b-vneshnij-dublikat-stroki':
        text += 'ПРОДУКТ: a3ka/toy-back\n'  # вторая строка с другим значением — объявление неразборчиво
    put(root, contract, text)
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
    if label in ('b-legacy-vneshnij-vlit', 'b-legacy-vneshnij-ne-vlit'):
        object_sha = EXTERNAL_OBJECT  # внешний OBJECT без объявления — место даёт legacy-запись
    if label == 'b-produkt-object-otsutstvuet':
        object_sha = MISSING_OBJECT
    if label == 'a-verdikt-bez-object':
        object_sha = None
    if label == 'b-vneshnij-object-stancionnyj':
        object_sha = impl  # свежий accept на ЛОКАЛЬНЫЙ станционный OBJECT объявленного внешнего предмета (класс 163)
    if label == 'b-stancionnyj-object-vneshnij':
        object_sha = EXTERNAL_OBJECT  # объявлена станция, а OBJECT внешний
    if label == 'a-drevo-object-do-realizacii':
        object_sha = b0  # мир B→I→F: вердикт в коммите заморозки называет ДО-реализационный объект (решение 1)

    # вердикт ревьюера
    put(root, review_path(kind), verdict_text(object_sha, svarka=(kind == 'back')))
    if label == 'a-drevo-realizacija-v-f':
        put(root, 'app/identity/model.js', 'module.exports = 3;\n')  # реализация изменена в самом коммите F (решение 1)
    if label in ('v-legacy-obychnyj', 'v-legacy-rabochaja-zapis'):
        blob = '1' * 40 if label == 'v-legacy-rabochaja-zapis' \
            else git(root, 'rev-parse', f'{b0}:{contract}')
        legacy = root / registry.replace('contracts.tsv', 'risk-legacy.tsv')
        legacy.parent.mkdir(parents=True, exist_ok=True)
        legacy.write_text(f'{blob}\tобычный\tfixtures 201 — клетка {label}\towner\n')
    if label.startswith('b-legacy-'):
        chuzhoj = label in ('b-legacy-chuzhoj-blob', 'b-legacy-rabochaja-zapis',
                            'b-legacy-staged-zapis', 'b-legacy-zakomchennaja-zapis')
        key_blob = '1' * 40 if chuzhoj else git(root, 'rev-parse', f'{b0}:{contract}')
        place = 'станция' if label == 'b-legacy-stancionnyj' else PRODUCT_OWNER_REPO
        mesto = root / registry.replace('contracts.tsv', 'mesto-legacy.tsv')
        mesto.parent.mkdir(parents=True, exist_ok=True)
        mesto.write_text('номер_предмета\tblob_контракта\tместо_реализации\tоснование\tзаписал\n'
                         f'{NN}\t{key_blob}\t{place}\tfixtures 201 — клетка {label}\tarchitect\n')
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'verdikt 777')
    cid = git(root, 'rev-parse', 'HEAD')

    # адверсарий (только клетки (в))
    adversary = []
    if label.startswith('v-riskovyi') or label.startswith('v-adversarii'):
        if label in ('v-riskovyi-bez-adversarii', 'v-riskovyi-head-obychnyj'):
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
    if label in ('a-ravenstvo-frozen-verdikt', 'a-drevo-object-do-realizacii', 'a-drevo-realizacija-v-f'):
        f_target = cid  # F == коммит вердикта: доказательство — тождество деревьев (решение 1)
    if label == 'a-object-do-zamorozki':
        f_target = impl  # заморозка на реализации
    if label in ('a-accept-staroj-versii', 'a-dve-zamorozki'):
        put(root, 'AGENTS.md', '# Fixture 2\n')
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'post-verdict freeze carrier')
        f_target = git(root, 'rev-parse', 'HEAD')
    if label == 'a-dve-zamorozki':
        # две версии: /1 ДО вердикта (старая), /2 ПОСЛЕ — судить обязана последняя /2
        git(root, 'tag', 'frozen/contracts/777/1', b0)
        git(root, 'tag', 'frozen/contracts/777/2', f_target)
    elif label != 'a-net-zamorozki':
        git(root, 'tag', 'frozen/contracts/777/1', f_target)
    if label == 'a-object-do-zamorozki':
        # пост-фактум вердикт (строго после заморозки) на СТАРЫЙ объект — атака 201-v1 блок 1
        put(root, review_path(kind), verdict_text(b0))
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'post-freeze verdikt na staryj object')
        cid = git(root, 'rev-parse', 'HEAD')
        object_sha = b0
    if label in ('v-riskovyi-head-obychnyj', 'v-obychnyj-bez-adversarii'):
        # Adv201: frozen-класс и HEAD различаются; тег остаётся на прежнем blob.
        # Обратный честный контроль: frozen обычный, HEAD рисковый, адверсарий не нужен.
        head_risk = 'обычный' if label == 'v-riskovyi-head-obychnyj' else 'рисковый'
        put(root, contract, contract_text(risk=head_risk, product=product))
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'post-freeze change risk only in HEAD')

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

    # К-10 krug 3 (Crit201V3): запись реестра места/класса — свидетельство
    # ТОЛЬКО с HEAD; та же запись в рабочей копии или индексе не свидетельство
    if label in ('b-legacy-rabochaja-zapis', 'b-legacy-staged-zapis',
                 'b-legacy-zakomchennaja-zapis'):
        key_blob = git(root, 'rev-parse', f'{b0}:{contract}')
        mesto = root / registry.replace('contracts.tsv', 'mesto-legacy.tsv')
        with mesto.open('a') as fh:
            fh.write(f'{NN}\t{key_blob}\tстанция\tfixtures 201 — клетка {label}\tarchitect\n')
        if label != 'b-legacy-rabochaja-zapis':
            git(root, 'add', '-A')  # staged-запись: индекс тоже не свидетельство
        if label == 'b-legacy-zakomchennaja-zapis':
            git(root, 'commit', '-qm', 'mesto: zapis nastojashchego bloba stancija')
    if label == 'v-legacy-rabochaja-zapis':
        key_blob = git(root, 'rev-parse', f'{b0}:{contract}')
        legacy = root / registry.replace('contracts.tsv', 'risk-legacy.tsv')
        with legacy.open('a') as fh:
            fh.write(f'{key_blob}\tобычный\tfixtures 201 — клетка {label}\towner\n')

    head = git(root, 'rev-parse', 'HEAD')

    # внешние ответы API — ВНЕ мира (шим curl читает env)
    compare_status = None
    if label.startswith('b-'):
        compare_status = {'b-vneshnij-produkt-vlit': 'behind',
                          'b-vneshnij-curl-s-oshibkoj': 'behind',
                          'b-vneshnij-json-povrezhdjon-hvost': 'behind',
                          'b-vneshnij-dva-dokumenta': 'behind',
                          'b-vneshnij-identical': 'identical',
                          'b-vneshnij-ne-vlit': 'ahead',
                          'b-vneshnij-bez-stroki': 'behind',
                          'b-vneshnij-stroka-krivaja': 'behind',
                          'b-vneshnij-api-nedostupen': 'not-found',
                          'b-legacy-vneshnij-vlit': 'behind',
                          'b-legacy-vneshnij-ne-vlit': 'ahead'}.get(label)
    checkrun_name = {'g-arch-tochno-imja': 'arch',
                     'g-arch-v-skobkah': 'arch (пин внешней архитектуры, model fitness + code-ratchet)',
                     'g-arch-s-probelom': 'arch fitness',
                     'g-archive': 'archive',
                     'g-arche': 'arche',
                     'g-architecture': 'architecture ratchet',
                     'g-march': 'march'}.get(label, 'arch')
    compare_rc = int(label == 'b-vneshnij-curl-s-oshibkoj')
    checkrun_rc = int(label == 'g-arch-curl-s-oshibkoj')

    bin_dir = root.parent / (root.name + '-bin')
    bin_dir.mkdir(exist_ok=True)
    fake_curl = bin_dir / 'curl'
    fake_curl.write_text(
        '#!/usr/bin/env bash\n'
        'case "${@: -1}" in\n'
        '  *"/compare/"*)\n'
        '    [ -n "$DONE201_COMPARE" ] && cat "$DONE201_COMPARE" || exit 31\n'
        '    exit "$DONE201_COMPARE_RC" ;;\n'
        '  *"/check-runs?"*)\n'
        '    [ -n "$DONE201_CHECKRUNS" ] && cat "$DONE201_CHECKRUNS" || exit 31\n'
        '    exit "$DONE201_CHECKRUNS_RC" ;;\n'
        '  *) exit 31 ;;\n'
        'esac\n')
    fake_curl.chmod(0o755)

    # тело compare (РЕШЕНИЕ 3): повреждённый хвост/второй документ при
    # положительном префиксе; положительные ответы — с допустимым внешним
    # whitespace/переводом строки вокруг ЕДИНСТВЕННОГО документа
    compare_file = root.parent / (root.name + '-compare.json')
    if compare_status == 'not-found':
        compare_file.write_text(json.dumps({'message': 'Not Found', 'documentation_url': 'https://docs.github.com'}))
    elif compare_status:
        body = json.dumps({'status': compare_status, 'commits': []})
        if label == 'b-vneshnij-json-povrezhdjon-hvost':
            body += '\n{broken'
        elif label == 'b-vneshnij-dva-dokumenta':
            body += '\n{}'
        elif label == 'b-vneshnij-identical':
            body = '\n  ' + body + '\n\n'
        elif label == 'b-vneshnij-produkt-vlit':
            body = '\n' + body + '\n'
        compare_file.write_text(body)
    # Adv201c блок 1 (маршрут compare) и блок 2: исходные БАЙТЫ ответа —
    # write_bytes, канонический jq модели получает именно их (NUL-байты
    # хвоста/значения/ключа jq отвергает rc 5; status-число разбирается
    # в один объект с полем нестрокового типа); дверь читает их шимом curl
    RAW_COMPARE = {
        'b-vneshnij-nul-hvost': b'{"status":"behind"}\n\x00\x00',
        'b-vneshnij-nul-v-znachenii': b'{"status": "beh\x00ind"}',
        'b-vneshnij-nul-v-klyuche': b'{"sta\x00tus":"behind"}',
        'b-vneshnij-status-chislo': b'{"status":5}',
    }
    if label in RAW_COMPARE:
        compare_file.write_bytes(RAW_COMPARE[label])
    # тело check-runs: тот же класс входов; положительные arch-имена — с
    # внешним whitespace/переводом строки
    checkrun_file = root.parent / (root.name + '-checkruns.json')
    if kind == 'back':
        cr = json.dumps({'total_count': 1, 'check_runs': [
            {'id': 1, 'name': checkrun_name, 'status': 'completed',
             'conclusion': 'success', 'head_sha': head}]})
        if label == 'g-arch-json-povrezhdjon-hvost':
            cr += '\n{broken'
        elif label == 'g-arch-dva-dokumenta':
            cr += '\n{}'
        elif label in ('g-arch-tochno-imja', 'g-arch-v-skobkah', 'g-arch-s-probelom'):
            cr = '\n' + cr + '\n  '
        if label == 'g-arch-nul-hvost':
            # Adv201c блок 1 (маршрут check-runs): успешный arch на точном
            # HEAD + исходный NUL-хвост — "$(curl …)" теряет NUL ДО jq
            checkrun_file.write_bytes(cr.encode() + b'\n\x00\x00')
        else:
            checkrun_file.write_text(cr)

    git(root, 'push', '-q', 'origin', 'main')

    facts = {'kind': kind, 'contract': contract, 'head': head, 'b0': b0,
             'impl': impl, 'cid': cid, 'frozen': None if label == 'a-net-zamorozki' else f_target,
             'object': object_sha, 'adversary': adversary, 'risk': risk,
             'product': product, 'compare_status': compare_status,
             'compare_rc': compare_rc, 'checkrun_rc': checkrun_rc,
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


def mesto_lookup(root, kind, blob, mutant=''):
    """Классификация места по (NNN, blob) из закоммиченного на HEAD реестра
    (канон risk-legacy): `git show HEAD:<реестр>`; рабочая копия и индекс —
    НЕ свидетельство (п.8 AGENTS.md; блок К-10 krug 3 критика). Нет файла
    на HEAD — нет записи. None — применимой записи нет; 'BAD' — конфликт
    дублей или значение вне грамматики (решение 2: отказ, не fallback)."""
    rel = ('registry/mesto-legacy.tsv' if kind == 'station'
           else '.harness/registry/mesto-legacy.tsv')
    if mutant == 's-b-mesto-iz-rabochego-fajla':
        path = root / rel  # обманный стаб: читает РАБОЧУЮ копию (дефект К-10)
        if not path.is_file():
            return None
        rc, text = 0, path.read_text()
    else:
        rc, text = run('git', '-C', root, 'show', f'HEAD:{rel}')
    if rc:
        return None
    hits = []
    for row in text.splitlines():
        cols = row.split('\t')
        if len(cols) >= 3 and cols[0] == NN and cols[1] == blob:
            hits.append(cols[2])
    if not hits:
        return None
    if len(hits) > 1:
        return 'BAD'
    place = hits[0]
    if place == 'станция' or MESTO_RE.fullmatch(place):
        return place
    return 'BAD'

CHECKRUN_COUNT = ('[.check_runs[]? | select((((.name // "") == "arch") '
                  'or ((.name // "") | startswith("arch ")) '
                  'or ((.name // "") | startswith("arch ("))) and (.head_sha == $sha) '
                  'and (.status == "completed") and (.conclusion == "success"))] | length')


def json_one_object(text):
    """Канонический полный разбор ровно ОДНОГО JSON-документа-объекта — тот
    же инструмент и грамматика, что у двери (jq -s; length == 1; тип
    объекта ДО извлечения поля; rc ДО использования; РЕШЕНИЕ 1 Arb201V2).
    Возвращает (объект, None) или (None, причина). Диагностика — второй
    вызов jq, как у двери; никакой особой обработки строки «{broken»."""
    p = subprocess.run(
        ['jq', '-s', '-c', 'if (length == 1 and (.[0] | type) == "object") '
         'then .[0] else error("ожидался ровно один JSON-документ-объект") end'],
        input=text, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    if p.returncode == 0:
        return json.loads(p.stdout), None
    d = subprocess.run(
        ['jq', '-s', '-r', 'if length == 0 then "empty" elif length != 1 '
         'then "multiple" else "not-object" end'],
        input=text, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    diag = d.stdout.strip()
    if diag == 'empty':
        return None, 'пустой ввод: JSON-документов нет'
    if diag == 'multiple':
        return None, 'в ответе несколько JSON-документов (ожидался ровно один)'
    if diag == 'not-object':
        return None, 'ответ не JSON-объект'
    return None, f'синтаксическая ошибка JSON (jq rc={p.returncode})'


def json_stream(text, flt, **args):
    """Потоковый прогон jq БЕЗ slurp — форма ПРЕЖНЕЙ, додверной ошибки
    (успешный префикс печатается ДО отказа разбора). Только обманные
    стабы (Н-39); честный путь модели — json_one_object."""
    cmd = ['jq', '-r']
    for k, v in args.items():
        cmd += ['--arg', k, str(v)]
    p = subprocess.run(cmd + [flt], input=text, stdout=subprocess.PIPE,
                       stderr=subprocess.DEVNULL, text=True)
    return p.stdout


def arch_name_ok(name, mutant=''):
    """Предикат имени check-run arch (г) — как у двери; мутации имён —
    обманные стабы s-g-arch-*."""
    if mutant == 's-g-arch-kak-podstroka':
        return 'arch' in name
    if mutant == 's-g-arch-tolko-literalno':
        return name == 'arch'
    if mutant == 's-g-arche-razresheno':
        return name == 'arch' or name.startswith('arch ') or name == 'arche'
    return name == 'arch' or name.startswith('arch ') or name.startswith('arch (')


def model(root, f, mutant=''):
    def skip(name):
        return mutant == name

    # (а): заморозку оракул выбирает САМ из тегов мира — vmax, а не старейшая
    # (вердикт 201-v1 блок 3: мутант «первый тег» не должен проходить батарею)
    tags = sorted(git(root, 'tag', '-l', 'frozen/contracts/777/*').splitlines())
    if not tags:
        return 1, PH_A1

    def ver(t):
        return int(t.rsplit('/', 1)[1])

    if skip('s-a-staraja-zamorozka'):
        ftag = min(tags, key=ver)   # мутант «старейшая заморозка вместо последней»
    else:
        ftag = max(tags, key=ver)
    frozen = git(root, 'rev-parse', ftag + '^{commit}')
    obj = f['object']
    obj_local = bool(re.fullmatch(r'[0-9a-f]{40}', obj or '')) and obj in f['local_objects']
    ext = bool(re.fullmatch(r'[0-9a-f]{40}', obj or '')) and obj not in f['local_objects']
    frozen_text = git(root, 'show', f'{ftag}:{f["contract"]}')
    if not skip('s-a-object-ne-nuzhen') and not re.fullmatch(r'[0-9a-f]{40}', obj or ''):
        return 1, PH_A2.format(f=f['review_file'])
    if not skip('s-a-prinimaet-ljubuju-versiju'):
        if not is_ancestor(root, frozen, f['cid']):
            return 1, PH_A3.format(f=f['review_file'], t=ftag)
        # связь ОБЪЕКТА с последней заморозкой (блок 1: датирование файла не доказывает)
        if not skip('s-a-object-bez-svjazi') and obj_local:
            bound = (is_ancestor(root, obj, frozen) if frozen == f['cid']
                     else is_ancestor(root, frozen, obj))
            if not bound:
                return 1, PH_A4.format(o=obj, t=ftag)
    # (б)
    if not skip('s-b-vlitost-ne-proverjaetsja'):
        if f['kind'] != 'station':
            if f['object'] not in f['local_objects']:
                return 1, PH_B1.format(o=f['object'])
            if not is_ancestor(root, f['object'], f['head']):
                return 1, PH_B2.format(o=f['object'])
        else:
            # три состояния станции (решение 2 арбитража): объявленная станция,
            # объявленный продукт, место не установлено — fail-closed
            plines = [ln for ln in frozen_text.splitlines() if ln.startswith('ПРОДУКТ:')]
            declared = None
            if len(plines) > 1:
                return 1, PH_B7DUP.format(v='; '.join(plines))
            if plines:
                if plines[0] == STATION_DECL:
                    declared = 'станция'
                else:
                    m = PRODUCT_RE.match(plines[0])
                    if not m:
                        return 1, PH_B4.format(s=plines[0])
                    declared = m.group(1)
            if declared is None and skip('s-b-mesto-po-umolchaniju-stancija'):
                declared = 'станция'  # мутант «место по умолчанию станция» (решение 2)
            if declared is None:
                mesto = mesto_lookup(root, f['kind'], git(root, 'rev-parse', f'{ftag}:{f["contract"]}'), mutant)
                if mesto == 'BAD':
                    return 1, PH_B8K.format(n=NN)
                if mesto is None:
                    return 1, PH_B8.format(n=NN)
                declared = mesto
            if declared == 'станция':
                if ext:
                    return 1, PH_B9.format(o=f['object'])
            elif obj_local:
                if not skip('s-b-stancionnyj-object-prohodit'):
                    return 1, PH_B7.format(o=f['object'], r=declared)
            else:
                if f['compare_rc'] and not skip('s-b-curl-rc-tolko-default'):
                    return 1, PH_B5.format(r=declared) + f' curl rc={f["compare_rc"]}'
                # полный разбор ровно одного JSON-документа (РЕШЕНИЕ 3):
                # факты — каноническим jq из тела ответа ВНЕ мира; успешный
                # префикс при повреждённом теле свидетельством не является
                body = f['compare_file'].read_text()
                status_present = False
                if skip('s-b-json-hvost-ignoriruetsja'):
                    # стаб A: игнорирование rc/хвоста — успешный префикс
                    status = f['compare_status'] or ''
                elif skip('s-b-potok-dokumentov-dopushhen'):
                    # стаб B: без length==1/slurp — первый документ потока
                    status = json_stream(
                        body, 'if type == "object" then (.status // empty) else empty end').strip()
                elif not body:
                    status = ''
                else:
                    # стаб-двойник bash-транспорта "$(curl …)" живой двери
                    # (Adv201c блок 1): NUL-байты теряются ДО jq — хвост,
                    # значение и ключ становятся валидным JSON
                    src = body.replace('\x00', '') \
                        if skip('s-b-nul-transport-terjaet-bajty') else body
                    cmp_obj, cmp_err = json_one_object(src)
                    if cmp_obj is None:
                        return 1, PH_B5.format(r=declared) + f' ответ API не разобран ({cmp_err})'
                    status = cmp_obj.get('status') or ''
                    status_present = isinstance(cmp_obj, dict) and 'status' in cmp_obj
                if skip('s-b-api-vsegda-vlito'):
                    status = 'behind' if status else 'not-found-green'
                if status in ('identical', 'behind', 'not-found-green'):
                    pass
                elif status in ('ahead', 'diverged'):
                    return 1, PH_B6.format(o=f['object'], r=declared)
                elif status_present and not skip('s-b-status-vne-slovarya-kak-otsutstvie'):
                    # Adv201c блок 2: поле status ПРИСУТСТВУЕТ, значение вне
                    # словаря {identical, behind, ahead, diverged} — причина
                    # обязана называть фактическое состояние, а не «без поля»
                    return 1, PH_B5.format(r=declared) + ' неподдерживаемое значение status'
                elif status_present:
                    # стаб-двойник ветки :559-565 двери: присутствующее поле
                    # с вне-словарным значением объявляется отсутствующим
                    return 1, PH_B5.format(r=declared) + ' ответ API без поля status'
                else:
                    reason = f' curl rc={f["compare_rc"]}' if f['compare_rc'] else ' API недоступен'
                    return 1, PH_B5.format(r=declared) + reason
    # (в): класс риска — из ЗАМОРОЖЕННОГО текста выбранной заморозки, как у двери
    risk_text = git(root, 'show', f'HEAD:{f["contract"]}') if skip('s-v-risk-iz-head') else frozen_text
    risks = {m.group(1) for m in RISK_RE.finditer(risk_text)}
    if len(risks) > 1:
        return 1, PH_V5
    klass = next(iter(risks)) if risks else None
    if klass is None:
        blob = git(root, 'rev-parse', f'{ftag}:{f["contract"]}')
        legacy = ('registry/risk-legacy.tsv' if f['kind'] == 'station'
                  else '.harness/registry/risk-legacy.tsv')
        klass = 'рисковый'  # нет строки и записи — рисковый (норма orchestrator)
        if skip('s-v-risk-iz-rabochego-fajla'):
            lp = root / legacy  # обманный стаб: читает РАБОЧУЮ копию (класс К-10)
            if lp.is_file():
                for row in lp.read_text().splitlines():
                    cols = row.split('\t')
                    if len(cols) > 1 and cols[0] == blob:
                        klass = cols[1]
                        break
        else:
            # запись — только из закоммиченного на HEAD файла: рабочая копия и
            # индекс не свидетельство (п.8 AGENTS.md; блок К-10 krug 3)
            lr, ltext = run('git', '-C', root, 'show', f'HEAD:{legacy}')
            if not lr:
                for row in ltext.splitlines():
                    cols = row.split('\t')
                    if len(cols) > 1 and cols[0] == blob:
                        klass = cols[1]
                        break
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
    # (а²) тождество деревьев при F == CID — решение 1 арбитража: родословной
    # недостаточно (мир B→I→F проходит OBJECT ⊆ F без реализации). Вычет —
    # только точные файлы судебных свидетельств; вычет адверсария возможен
    # после его выбора в (в), поэтому проверка замыкает 6б. Канон —
    # git diff-tree -r --raw --no-renames: пути, моды, OID, удаления, gitlinks.
    if frozen == f['cid'] and obj_local and not skip('s-a-tolko-rodoslovnaja'):
        exempt = {f['review_file']}
        if klass == 'рисковый' and f['adversary']:
            exempt.add(adversary_path(f['kind'], 'a2' if len(f['adversary']) > 1 else 'a1'))
        dt_rc, dt_out = run('git', '-C', root, '-c', 'diff.renames=false',
                            'diff-tree', '-r', '--raw', '--no-renames', obj, frozen)
        residue = [ln.split('\t', 1)[1] for ln in dt_out.splitlines()
                   if ln.startswith(':') and '\t' in ln]
        if dt_rc or [p for p in residue if p not in exempt]:
            return 1, PH_A4.format(o=obj, t=ftag)
    # (г) профиль мира (229/389, РЕШЕНИЕ 2–3 Arb201V2): полный разбор ровно
    # одного JSON-документа; повреждённый/многодокументный профиль НЕ
    # продолжает работу (именованный отказ до тега, без fallback); штатное
    # отсутствие необязательного git.canonicalRemote — прежний fallback
    # (положительный профильный контроль g-profil-bez-canonical-remote)
    if f['kind'] == 'back':
        prof_obj, prof_err = json_one_object((root / 'harness.project.json').read_text())
        if prof_obj is None and not skip('s-g-profil-potok-dopushhen'):
            what = 'многодокументный' if 'несколько' in prof_err else 'повреждённый'
            return 1, (f'ОТКАЗ: профиль битый или workflowPaths вне репо: {what} '
                       f'harness.project.json ({prof_err})')
        if f['checkrun_rc'] and not skip('s-g-curl-rc-ignoriruetsja'):
            return 1, f'{PH_ARCH_CI}: успешного check-run arch на финальном SHA нет (curl rc={f["checkrun_rc"]})'
        # полный разбор ровно одного JSON-документа ответа check-runs
        # (РЕШЕНИЕ 3): факты — каноническим jq из тела ВНЕ мира
        body = f['checkrun_file'].read_text()
        n = 0
        if body:
            if skip('s-g-json-hvost-ignoriruetsja'):
                # стаб A: счёт по успешному префиксу, rc jq игнорируется
                lines = json_stream(body, CHECKRUN_COUNT, sha=f['head']).splitlines()
                n = int(lines[0] or 0) if lines else 0
            elif skip('s-g-potok-dokumentov-dopushhen'):
                # стаб B: без slurp — счёт по КАЖДОМУ документу потока
                n = sum(int(x or 0)
                        for x in json_stream(body, CHECKRUN_COUNT, sha=f['head']).split())
            else:
                # стаб-двойник bash-транспорта "$(curl …)" маршрута check-runs
                # (Adv201c блок 1): NUL-байты теряются ДО jq
                src = body.replace('\x00', '') \
                    if skip('s-g-nul-transport-terjaet-bajty') else body
                cr_obj, cr_err = json_one_object(src)
                if cr_obj is None:
                    return 1, (f'{PH_ARCH_CI}: ответ check-runs не разобран ({cr_err}): '
                               'ожидался ровно один JSON-документ — успешного '
                               'check-run arch на финальном SHA нет')
                n = sum(1 for r in cr_obj.get('check_runs') or []
                        if isinstance(r, dict)
                        and r.get('status') == 'completed'
                        and r.get('conclusion') == 'success'
                        and r.get('head_sha') == f['head']
                        and arch_name_ok(r.get('name') or '', mutant))
        if n <= 0:
            return 1, f'{PH_ARCH_CI}: успешного check-run arch на финальном SHA нет (curl rc={f["checkrun_rc"]})'
    return 0, ''

def live(tools, root, contract, facts):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(root), HARNESS_WORKFLOW_ROOT=str(root),
               DONE201_COMPARE=str(facts['compare_file']),
               DONE201_CHECKRUNS=str(facts['checkrun_file']),
               DONE201_COMPARE_RC=str(facts['compare_rc']),
               DONE201_CHECKRUNS_RC=str(facts['checkrun_rc']),
               PATH=str(facts['bin_dir']) + os.pathsep + env.get('PATH', ''))
    return run('bash', tools / 'scripts/done_contract.sh', contract, 'батарея 201: клетка', root,
               cwd=root, env=env)

VALIDATED_OBJ = ('_pr_paths_obj', '_a187_profile', '_a187_obj',
                 '_merged_profile_obj', '_cmp_obj')


def jq_callsite_map(tools):
    """Проверяемая карта jq-вызовов ЖИВОЙ двери (РЕШЕНИЕ 3 Arb201V2,
    разрешение «общая проверка механизма плюс карта всех вызовов»):
    (1) механизм _json_one_object (полный slurp, ровно один документ)
    вызывается на всех пяти недоверенных входах — пути/профиль/check-runs/
    repoId/compare; (2) ни один jq-вызов ВНЕ механизма не читает
    недоверенные байты: каждому разрешено потреблять только уже разобранные
    канонические объекты. Возвращает список нарушений (пусто — карта чиста).
    """
    door = Path(tools) / 'scripts' / 'done_contract.sh'
    lines = door.read_text().splitlines()
    bad = []
    n_mech = 0
    inside = False
    for i, ln in enumerate(lines, 1):
        if ln.startswith('_json_one_object()'):
            inside = True
            continue
        if inside and ln == '}':
            inside = False
            continue
        if re.search(r'_json_one_object\s+\w', ln):
            n_mech += 1
            continue
        if inside:
            continue
        if ln.lstrip().startswith('#'):
            continue  # комментарии — не вызовы
        if (' jq ' not in ln and not ln.lstrip().startswith('jq ')):
            continue
        if not any(v in ln for v in VALIDATED_OBJ):
            bad.append(f'строка {i}: jq вне механизма полного разбора: {ln.strip()[:90]}')
    if n_mech != len(VALIDATED_OBJ):
        bad.append(f'механизм _json_one_object вызван {n_mech} раз '
                   f'(ожидалось {len(VALIDATED_OBJ)}: пути/профиль/check-runs/repoId/compare)')
    return bad


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
        # карта jq-вызовов — только live-режимы (голый/--repo): судится ДВЕРЬ,
        # не модель (--model/--stabs дверь не вызывают)
        if not (mode and mode[0] in ('--model', '--stabs')):
            problems = jq_callsite_map(tools)
            if problems:
                failures.append('karta-jq-vyzovov')
                for p in problems:
                    print(f'RED karta-jq-vyzovov: {p}')
            else:
                print(f'GREEN karta-jq-vyzovov: механизм _json_one_object × {len(VALIDATED_OBJ)}, '
                      'jq вне механизма не читает недоверенные байты')
    print(f'CELLS={len(CASES)} STABS={len(STABS) if mode and mode[0] == "--stabs" else 0} FAILURES={len(failures)}')
    return int(bool(failures))


if __name__ == '__main__':
    raise SystemExit(main())
