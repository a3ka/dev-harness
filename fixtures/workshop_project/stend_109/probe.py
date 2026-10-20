#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Батарея контракта 109 (CMP-BCK-004): изолированный стенд и сбор HTTP/SQL evidence 5.8.2.
Круг 3 (арбитраж contracts-109-cep-zhivogo-fakta-v1, замкнутый перечень К1–К6):
живые факты судят ВСЮ цепь — правило Ц: вызов точкой входа поставки → запись
субъектом в sink → чтение ожиданий из sink; мутанты-обходы байт-в-байт к
деревьям критика кругов 1–2.

Парсер — Python 3 stdlib. Батарея поднимает НЕ стенд, а ИСПОЛНЯЕТ предмет:
раннер миграций 129 (node), точку входа drill-коллектора (node, команда
scripts['drill:evidence'] из backend/package.json, два различимых входа),
recordInteraction harness (node, три различимые записи — по одной на режим) и
разрешение сетей docker compose config (без подъёма контейнеров). Живой стенд
(docker compose up -d --wait, повтор, повреждённая копия, реальный маршрут
egress из запущенного сервиса; npm test:integration на native PG18) — отдельные
строки приёмки контракта. Структурные проверки — сверх-приближение; измеренный
живой факт раннера: отказ на повреждённой копии db/ и манифесте с пропуском ДО
соединения с БД (rc 1, «SHA256 … не совпадает с манифестом»).

ПРАВИЛО Ц (цепь; арбитраж 109): живой факт зелен только если измерены все три
звена — (1) ВЫЗОВ: субъект запущен командой/точкой входа, которую объявляет
ПОСТАВКА (скрипт backend/package.json, вызов из harness/теста), а не файлом,
который батарея нашла сама; (2) ЗАПИСЬ: субъект сам создал артефакт в sink
(файл evidence), батарея его не подменяет; (3) ЧТЕНИЕ: ожидания сравниваются
со значениями, ПРОЧИТАННЫМИ из sink, по независимым литералам батареи;
возвращённое значение/stdout — дополнительный, не замещающий источник. Вход
факта проходит по заявленному пути: сентинел — в сериализуемом поле наблюдения;
каждое объявленное значение конечной оси mode (FIXTURE_5_8_2 / SYNTHETIC /
RUNTIME) — отдельное наблюдение.

Выход: rc 0 — контроль зелен, все пять фактов True (не None/False) и каждый
мутант отвергнут ровно своей причиной (ожидается на честном C); rc 1 — контроль
красен (честное red на до-предметном B), факт False или мутант не отвергнут /
изоляция нарушена; rc 2 — UNMEASURABLE / EMPTY_SELECTION / NOOP_MUTATION /
NEEDS_ENV (факт None — не измерено, контроль не зелен: гейт не зеленее CI).

ГРАММАТИКА МАРКЕРОВ (что ищет батарея; смысл доказывают живые строки приёмки и
судьи — батарея сверх-приближение по правилу 7 AGENTS, не интерпретатор):

  compose (backend/compose.dev.yml; текстовые якоря, не YAML-парсер):
    - сервис миграций '^  migrat…:' и сервис '^  api:';
    - migrate-before-API: literal 'service_completed_successfully' в файле и
      зависимость api от сервиса миграций;
    - образы: каждая строка 'image:' несёт тег (не ':latest'); PG-образ содержит
      ':18' или '@sha256:';
    - volume-строка с prod|dump|medical в хостевом пути — запрещена;
    - блоку api запрещены env MIGRATION_DATABASE_URL и переменные
      ^(MIGRATION|DDL|GATEWAY);
    - сервисы worker|sandbox|document: сети, ПЕРЕЧИСЛЕННЫЕ в их блоке networks:,
      существуют и ВСЕ internal: true (верхний раздел networks:); «internal: true
      где-то в файле» недостаточно — оракул судит назначенные сервисам сети;
    - опубликованный порт СЕРВИСА PG — только '127.0.0.1:';
    - данные PG — именованный volume ('- имя:/…') и верхний раздел volumes:.

  harness (backend/tests/helpers/harness.js, CommonJS):
    - append-only: флаг 'wx' (или O_EXCL / flag 'x') при создании файлов evidence;
    - scrubber: вызов scrub*/redact*/sanitiz* над сериализованным текстом
      (аргумент содержит JSON.stringify);
    - SQL before/after: литералы 'sql_before' и 'sql_after';
    - runtime role: литералы 'current_user' и 'runtime_role';
    - provider-call count: литерал 'provider_call';
    - hash manifest: литералы 'sha256' и 'input_hashes';
    - честность: литерал 'NOT_RUN' (недоступная БД — не успех);
    - различение режимов: литералы 'FIXTURE_5_8_2', 'SYNTHETIC', 'RUNTIME';
    - ЗАМКНУТЫЙ КОРТЕЖ ОСЕЙ: один массив шести токенов по порядку
      http_request … http_response … sql_before … sql_after … runtime_role …
      provider_calls — произведение осей на каждую запись взаимодействия.

  drill-коллектор (точка входа поставки — backend/package.json
  scripts['drill:evidence']; имя скрипта — единый источник ЗДЕСЬ; команда
  вызывает коллектор backend/scripts/*.js с литералами drill+rpo+rto в одном
  файле; упоминание basename коллектора в description/комментарии проводом
  НЕ считается):
    - грамматика CLI: `node <коллектор> --out DIR [--input FILE]`; без входа
      пишет DIR/drill-evidence.json со status NOT_RUN и целевыми константами
      target_rpo_minutes=15, target_originals_within_minutes=60,
      target_rto_minutes=240; со входом — status MEASURED, db_hash/object_hash/
      key_hash = sha256 полей db_dump/objects_dump/keys_dump входа, измеренные
      measured_rpo_minutes/measured_rto_minutes/measured_at ИЗ входа (не цели),
      целевые константы рядом и отдельно.

  проводка:
    - файл в backend/tests/integration/**, содержащий 'helpers/harness';
    - package.json: скрипт test:integration покрывает этот файл своим glob.

  факты (зелены и на B, и на C; красный факт = UNMEASURABLE, не мок-зелёный;
  None = NEEDS_ENV — честный NOT_RUN с границей «что именно не проверено»):
    - ROOT_SERVER_PRESENT: server/test/harness.ts и server/src/app.ts на месте
      И байты совпадают с закреплёнными sha256 пина B (пустышка не проходит);
    - RUNNER_DAMAGE_GUARD: раннер 129 отказывает на повреждённой копии db/ и на
      манифесте с пропуском. NEEDS_ENV, если нет node или backend/node_modules/pg;
    - EGRESS_GUARD (живой): docker compose config по РАЗРЕШЁННОЙ конфигурации —
      сети, реально назначенные worker/sandbox/document, существуют и все
      internal; NEEDS_ENV без docker compose (граница: назначение сетей и живой
      маршрут egress НЕ проверены);
    - DRILL_EVIDENCE_GUARD (живой; правило Ц): КОМАНДА поставки
      scripts['drill:evidence'] ИСПОЛНЯЕТСЯ в disposable-копии backend — без
      входа NOT_RUN, с двумя различимыми входами точные sha256-хэши и
      измеренные значения каждого входа, sink читается из DIR/drill-evidence.json
      самой команды; чужой snapshot и константа не проходят; команда, не
      указывающая на коллектор backend/scripts, — красна;
    - HARNESS_TUPLE_GUARD (живой; правило Ц): recordInteraction(observation,
      dir) — синхронная функция harness.js; ТРИ различимые записи — по одной на
      каждый режим FIXTURE_5_8_2 / SYNTHETIC / RUNTIME; из СОХРАНЁННОГО файла,
      сопоставленного наблюдению по порядку создания, читаются mode (седьмое
      сверяемое поле), шесть осей (сентинел-несущее значение поля: присутствует,
      непусто, сентинела нет; прочие — точно равны наблюдению) и
      input_hashes[name] = sha256 каждого observation.inputs; возвращённый
      кортеж — дополнительная, не замещающая сверка; после трёх вызовов ровно
      три файла, прежние неизменны (append-only); строки observation.secrets
      (сентинел помещён в сериализуемое поле — сверка не вакуумна) отсутствуют
      в файлах evidence.
  НОВЫЕ ФАКТЫ КРУГА 2 (пост-заморозочное усиление гейта по вердиктам судей
  реализации — F1–F5/Б1–Б3; frozen-контракт не меняется, мутанты — байт-в-байт
  к дефектным ветвям коммита C a9569176c):
    - DRILL_INPUT_GUARD (живой; правило Ц): команда scripts['drill:evidence'] в
      disposable-копии: вход с measured_* null ИЛИ не-числом/не-ISO-строкой
      («ok»/«fine»/«never») → rc ≠ 0 и sink без MEASURED; валидный вход →
      MEASURED; повторный прогон без входа в ТОТ ЖЕ --out — файл
      drill-evidence.json байтово неизменен (append-only, не перезапись);
    - HARNESS_HONESTY_GUARD (живой): captureBeforeAfter экспортирован;
      наблюдение БЕЗ mode → отказ (throw), не «mode: RUNTIME» по умолчанию;
      mode вне трёх литералов (MOCK_SUCCESS) → throw; валидный mode при
      недоступной БД (COMPLIOR_HARNESS_DATABASE_URL на закрытый порт
      127.0.0.1:1) → throw ИЛИ статус NOT_RUN, никогда MEASURED/успех;
    - HARNESS_PII_GUARD (живой; правило Ц, чтение из sink): recordInteraction
      с НЕОБЪЯВЛЕННЫМИ Bearer-токеном/cookie/email/телефоном и объявленным
      секретом, содержащим кавычку и обратный слеш: в сохранённом файле нет ни
      raw-, ни JSON-экранированной формы каждого; запись не вакуумна
      (authorization непуст, «patient» в теле сохранён, mode из файла
      равен наблюдению);
    - STEND_UP_GUARD (живой): docker compose -p <уникальный> -f
      backend/compose.dev.yml up -d --wait → rc 0; SELECT count(*) из
      control.schema_migration = 14; повторный up rc 0 и ledger прежний;
      после прогона — down -v. Ловит том PG18 вне /var/lib/postgresql
      (образ 18+ отказывается от data-подпути) и migrator на образе без node
      (postgres:18 + command node → exit 127). NEEDS_ENV без docker compose
      (граница: живой подъём стенда, миграция до API и ledger НЕ проверены);
    - FILES_SHA256_GUARD: каждая непустая строка FILES.sha256 (<sha256>␣␣<путь>)
      — путь ЕСТЬ в коммите (git cat-file -e HEAD:<путь>) и sha256 blob из
      HEAD совпадает с строкой. NEEDS_ENV без FILES.sha256 или без .git
      (граница: соответствие производных коммиту НЕ проверено).
"""

import argparse
import fnmatch
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path

UNMEASURABLE = '109 UNMEASURABLE'


# ---------------------------------------------------------------- tree overlay

class Tree:
    """Чтение репо R с поверх мутированного оверлея (байты только в памяти)."""

    def __init__(self, repo, overlay=None):
        self.repo = Path(repo)
        self.overlay = overlay or {}

    def get(self, rel):
        if rel in self.overlay:
            return self.overlay[rel]
        try:
            return (self.repo / rel).read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            return None

def code_only(text):
    """JS без блочных и строчных комментариев: маркер в комментарии не считается
    (замер: защита «строки нет» однажды прошла из-за комментария)."""
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    return re.sub(r'//[^\n]*', '', text)

def services_section(text):
    """Часть файла до первого верхнего раздела вне services: (networks/volumes/…)."""
    m = re.search(r'^(networks|volumes|configs|secrets):\s*$', text, re.M)
    return text[:m.start()] if m else text


# ---------------------------------------------------------------- compose ctrl

def service_blocks(text):
    """{'api': 'тело', …} по строкам '^  имя:' (уровень сервисов)."""
    blocks, cur, buf = {}, None, []
    for line in text.splitlines():
        m = re.match(r'^  ([A-Za-z0-9_-]+):\s*$', line)
        if m:
            if cur is not None:
                blocks[cur] = '\n'.join(buf)
            cur, buf = m.group(1), []
        elif cur is not None:
            if line.startswith(' '):
                buf.append(line)
            else:
                blocks[cur] = '\n'.join(buf)
                cur, buf = None, []
    if cur is not None:
        blocks[cur] = '\n'.join(buf)
    return blocks
def internal_networks(text):
    """Имена сетей с internal: true из верхнего раздела networks:."""
    nets, cur = set(), None
    for line in text.splitlines():
        if cur == 'net':
            m = re.match(r'^  ([A-Za-z0-9_-]+):\s*$', line)
            if m:
                cur = m.group(1)
            elif line.strip() and not line.startswith('  '):
                cur = None
        elif isinstance(cur, str):
            if re.match(r'^\s{4,}internal:\s*true\s*$', line):
                nets.add(cur)
            m = re.match(r'^  ([A-Za-z0-9_-]+):', line)
            if m or (line.strip() and not line.startswith('  ')):
                cur = m.group(1) if m else None
        elif re.match(r'^networks:\s*$', line):
            cur = 'net'
    return nets


def service_network_names(block):
    """Сети, перечисленные в networks: блока сервиса (список или отображение)."""
    names, in_nets = [], False
    for line in block.splitlines():
        if in_nets:
            m = re.match(r'^\s+-\s+([A-Za-z0-9_-]+)\s*$', line)
            k = re.match(r'^\s{4,}([A-Za-z0-9_-]+):\s*$', line)
            if m:
                names.append(m.group(1))
            elif k:
                names.append(k.group(1))
            elif line.strip() and not line.startswith('      '):
                in_nets = False
        elif re.match(r'^\s+networks:\s*$', line):
            in_nets = True
    return names


def check_compose(tree):
    """(fired, blocked) группы стенда."""
    text = tree.get('backend/compose.dev.yml')
    if text is None:
        return {'COMPOSE_MISSING'}, set()
    fired = set()
    blocks = service_blocks(text)
    mig = [n for n in blocks if re.match(r'migrat', n)]
    api = blocks.get('api', '')
    gate = ('service_completed_successfully' in text
            and bool(mig)
            and any(re.search(r'\b%s\b' % re.escape(n), api) for n in mig))
    if not gate:
        fired.add('COMPOSE_API_BEFORE_MIGRATION')
    images = re.findall(r'image:\s*(\S+)', text)
    untagged = [i for i in images if ':' not in i or i.endswith(':latest')]
    pg = [i for i in images if 'postgres' in i]
    if untagged or not pg or not all((':18' in i or '@sha256:' in i) for i in pg):
        fired.add('COMPOSE_IMAGE_UNPINNED')
    for line in text.splitlines():
        if re.match(r'^\s*-\s*(\./)?\S*(prod|dump|medical)\S*\s*:', line, re.I):
            fired.add('COMPOSE_PROD_DUMP_MOUNTED')
            break
    api_envs = re.findall(r'^\s+-?\s*([A-Z0-9_]+)\s*[:=]', api, re.M)
    if any(re.match(r'MIGRATION|DDL|GATEWAY', v) for v in api_envs) or 'MIGRATION_DATABASE_URL' in api:
        fired.add('COMPOSE_DDL_SECRETS_TO_API')
    internal_nets = internal_networks(text)
    svcs = service_blocks(services_section(text))
    for name in svcs:
        if re.search(r'worker|sandbox|document', name):
            attached = service_network_names(svcs[name])
            if not attached or not all(n in internal_nets for n in attached):
                fired.add('COMPOSE_EGRESS_OPEN')
    pgsvc = blocks.get(next((n for n in blocks if 'postgres' in n or n == 'db'), ''), '')
    for m in re.finditer(r'^\s*-\s*["\']?([0-9.]+:)?\d+:\d+["\']?', pgsvc, re.M):
        if not (m.group(1) or '').startswith(('127.0.0.1:', 'localhost:')):
            fired.add('COMPOSE_DB_EXPOSED_UNRESTRICTED')
            break
    named = re.search(r'^\s*-\s+[A-Za-z_][A-Za-z0-9_-]*:/\S', pgsvc, re.M)
    if not (named and re.search(r'^volumes:\s*$', text, re.M)):
        fired.add('COMPOSE_EPHEMERAL_DB')
    return fired, set()


# ---------------------------------------------------------------- harness ctrl

HARNESS = 'backend/tests/helpers/harness.js'


def check_harness(tree):
    text = tree.get(HARNESS)
    if text is None:
        return {'HARNESS_MISSING'}, set()
    text = code_only(text)
    fired = set()
    if HARNESS not in tree.overlay:  # синтаксис — только на живом файле
        pkg = tree.get('backend/package.json') or ''
        chk = subprocess.run(['node', '--check', str(tree.repo / HARNESS)],
                             capture_output=True)
        if chk.returncode != 0 or '"type"' in pkg and '"module"' in pkg:
            fired.add('HARNESS_NOT_CJS')
    m = re.search(r"\[[^\]\n]*http_request[^\]\n]*http_response[^\]\n]*sql_before"
                  r"[^\]\n]*sql_after[^\]\n]*runtime_role[^\]\n]*provider_calls[^\]\n]*\]", text)
    axis_line = m.group(0) if m else ''
    if not axis_line:
        fired.add('HARNESS_RECORD_AXIS_TUPLE')
    rest = text.replace(axis_line, '') if axis_line else text
    if not re.search(r"['\"]wx['\"]|O_EXCL|flag:\s*['\"]x['\"]", text):
        fired.add('HARNESS_EVIDENCE_OVERWRITES')
    if not re.search(r'(scrub|redact|sanitiz)\w*\(\s*[^)]*JSON\.stringify', text, re.I):
        fired.add('HARNESS_NO_SCRUBBER')
    for lit, reason, scope in [('sql_before', 'HARNESS_NO_SQL_BEFORE_AFTER', rest),
                               ('sql_after', 'HARNESS_NO_SQL_BEFORE_AFTER', rest),
                               ('current_user', 'HARNESS_NO_RUNTIME_ROLE', rest),
                               ('runtime_role', 'HARNESS_NO_RUNTIME_ROLE', rest),
                               ('provider_call', 'HARNESS_NO_PROVIDER_COUNT', rest),
                               ('sha256', 'HARNESS_NO_MANIFEST_HASHES', text),
                               ('input_hashes', 'HARNESS_NO_MANIFEST_HASHES', text),
                               ('NOT_RUN', 'HARNESS_DB_DOWN_MOCK_SUCCESS', text),
                               ('FIXTURE_5_8_2', 'HARNESS_NO_MODE_LABEL', text),
                               ('SYNTHETIC', 'HARNESS_NO_MODE_LABEL', text),
                               ('RUNTIME', 'HARNESS_NO_MODE_LABEL', text)]:
        if lit not in scope:
            fired.add(reason)
    return fired, set()


# ---------------------------------------------------------------- wiring ctrl

def script_candidates(tree):
    """[(rel, тело)] backend/scripts/*.js с литералами drill+rpo+rto (коллектор)."""
    out = []
    for n in scripts_names(tree):
        rel = 'backend/scripts/%s' % n
        body = tree.get(rel)
        if body and all(l in code_only(body).lower() for l in ('drill', 'rpo', 'rto')):
            out.append((rel, body))
    return out

def scripts_names(tree):
    d = tree.repo / 'backend' / 'scripts'
    return sorted(p.name for p in d.glob('*.js')) if d.is_dir() else []



def find_harness_tests(tree):
    out = []
    d = tree.repo / 'backend' / 'tests' / 'integration'
    for p in sorted(d.rglob('*.test.js')) if d.is_dir() else []:
        rel = str(p.relative_to(tree.repo))
        if rel in tree.overlay:
            body = tree.overlay[rel]
            if body is None:
                continue
        else:
            body = None
            try:
                body = p.read_text(encoding='utf-8')
            except OSError:
                continue
        if 'helpers/harness' in body:
            out.append(rel)
    return out


DRILL_SCRIPT = 'drill:evidence'  # единый источник имени — докстринг грамматики (К2)


def drill_entry_command(tree):
    """Команда точки входа поставки: scripts['drill:evidence'] (правило Ц, звено 1)."""
    pkg = tree.get('backend/package.json')
    if pkg is None:
        return None
    try:
        cmd = json.loads(pkg)['scripts'][DRILL_SCRIPT]
    except (ValueError, KeyError, TypeError):
        return None
    return cmd if isinstance(cmd, str) and cmd.strip() else None


def check_wiring(tree):
    fired = set()
    tests = find_harness_tests(tree)
    cmd = drill_entry_command(tree)
    cands = script_candidates(tree)
    wired = cmd is not None and any(rel.split('/')[-1] in cmd for rel, _ in cands)
    if not wired:
        fired.add('DRILL_MEASUREMENTS_ABSENT')
    if not tests:
        return fired | {'HARNESS_INTEGRATION_TEST_MISSING'}, {'TEST_INTEGRATION_NOT_WIRED'}
    pkg = tree.get('backend/package.json') or ''
    try:
        script = json.loads(pkg)['scripts']['test:integration']
    except (ValueError, KeyError, TypeError):
        script = ''
    covered = False
    for t in tests:
        base = t.split('backend/', 1)[-1]
        for pat in re.findall(r'"([^"]+)"', script):
            p2 = pat.replace('**/', '').replace('**', '*')
            if fnmatch.fnmatch(base, p2) or fnmatch.fnmatch(base, p2.replace('tests/', '')):
                covered = True
    if not covered:
        fired.add('TEST_INTEGRATION_NOT_WIRED')
    return fired, set()
CHECKS = [check_compose, check_harness, check_wiring]
def subject_control(tree):
    fired, blocked = set(), set()
    for fn in CHECKS:
        f, b = fn(tree)
        fired |= f
        blocked |= b
    return fired, {b for b in blocked if b not in fired}


# ---------------------------------------------------------------- факты

ROOT_SERVER_SHA = {
    'server/test/harness.ts': '8c1922c34d5deb9249c18288f8cee3380ca2d285217eed2303b4143db190b7cf',
    'server/src/app.ts': 'b852e8427cfc49b8c772b2835b619931b4dae2ee4b891474a80965f8d026b02e',
}


def sha256_text(s):
    return hashlib.sha256(s.encode('utf-8')).hexdigest()


def runner_damage_fact(r, node):
    if not node or not (r / 'backend/node_modules/pg/package.json').is_file():
        return (None, 'NEEDS_ENV: node=%s, backend/node_modules/pg=%s (npm ci в backend)' % (
            bool(node), (r / 'backend/node_modules/pg/package.json').is_file()))
    with tempfile.TemporaryDirectory(prefix='stend109-') as tmp:
        dbdir = Path(tmp) / 'db'
        shutil.copytree(r / 'db', dbdir)
        dmg = dbdir / '013_profile_release_permissions.sql'
        dmg.write_bytes(dmg.read_bytes() + b'\n-- damaged\n')
        env = dict(os.environ, MIGRATION_DATABASE_URL='postgres://u:p@127.0.0.1:1/none')

        def run(*a):
            return subprocess.run([node, str(r / 'infra/migrations/run.js'), *a],
                                  env=env, capture_output=True, text=True, timeout=120)
        res1 = run('--db-dir', str(dbdir))
        manifest = json.loads((r / 'infra/migrations/manifest.json').read_text())
        entries = manifest.get('migrations') if isinstance(manifest, dict) else manifest
        res2 = None
        if isinstance(entries, list) and entries:
            man = json.loads(json.dumps(manifest))
            (man.get('migrations') if isinstance(manifest, dict) else man).pop()
            mpath = Path(tmp) / 'manifest.json'
            mpath.write_text(json.dumps(man))
            res2 = run('--db-dir', str(r / 'db'), '--manifest', str(mpath))
        ok1 = res1.returncode != 0 and 'манифест' in (res1.stderr or '')
        ok2 = res2 is None or res2.returncode != 0
        return (ok1 and ok2,
                'повреждённый файл rc=%d «%s»; пропуск в манифесте rc=%s' % (
                    res1.returncode, (res1.stderr or '').strip()[:100],
                    'n/a' if res2 is None else res2.returncode))


def egress_fact(repo, tree=None):
    """Живой разбор сетей docker compose config: worker/sandbox/document только internal."""
    tree = tree or Tree(repo)
    compose = tree.get('backend/compose.dev.yml')
    if compose is None:
        return (None, 'NEEDS_ENV: compose.dev.yml отсутствует (контроль судит COMPOSE_MISSING); '
                      'живой маршрут document-worker НЕ проверен')
    try:
        dc = subprocess.run(['docker', 'compose', 'version'], capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.TimeoutExpired):
        dc = None
    if dc is None or dc.returncode != 0:
        return (None, 'NEEDS_ENV: docker compose недоступен — назначенные сервисам сети '
                      'и живой маршрут egress НЕ проверены')
    with tempfile.TemporaryDirectory(prefix='stend109-eg-') as tmp:
        cf = Path(tmp) / 'compose.dev.yml'
        cf.write_text(compose, encoding='utf-8')
        try:
            r = subprocess.run(['docker', 'compose', '-f', str(cf), 'config', '--format', 'json'],
                               capture_output=True, text=True, timeout=60)
        except subprocess.TimeoutExpired:
            return (False, 'docker compose config: таймаут')
    if r.returncode != 0:
        return (False, 'docker compose config rc=%d: %s' % (r.returncode, (r.stderr or '')[:150]))
    try:
        cfg = json.loads(r.stdout)
    except ValueError:
        return (False, 'docker compose config: вывод не JSON')
    nets = {k: bool(v.get('internal')) for k, v in (cfg.get('networks') or {}).items()}
    bad = []
    for name, svc in (cfg.get('services') or {}).items():
        if re.search(r'worker|sandbox|document', name):
            attached = list((svc.get('networks') or {}).keys())
            if not attached or not all(nets.get(n) for n in attached):
                bad.append('%s→%s' % (name, ','.join(attached) or 'default'))
    if bad:
        return (False, 'сервисы вне internal-сетей (живой разбор): %s' % '; '.join(bad))
    return (True, 'живой разбор compose: worker/sandbox/document только в internal-сетях')


DRILL_INPUTS = (
    {'db_dump': 'db-dump-one', 'objects_dump': 'obj-dump-one', 'keys_dump': 'key-dump-one',
     'measured_rpo_minutes': 17, 'measured_rto_minutes': 253, 'measured_at': '2026-10-19T09:30:00Z'},
    {'db_dump': 'db-dump-two', 'objects_dump': 'obj-dump-two', 'keys_dump': 'key-dump-two',
     'measured_rpo_minutes': 23, 'measured_rto_minutes': 311, 'measured_at': '2026-10-19T11:00:00Z'},
)
DRILL_TARGETS = {'target_rpo_minutes': 15, 'target_originals_within_minutes': 60,
                 'target_rto_minutes': 240}


def drill_fact(repo, tree=None):
    """Живой вызов ТОЧКИ ВХОДА ПОСТАВКИ (правило Ц, К2): команда
    scripts['drill:evidence'] исполняется в disposable-копии backend, sink
    читается из DIR/drill-evidence.json самой команды."""
    tree = tree or Tree(repo)
    cmd = drill_entry_command(tree)
    if cmd is None:
        return (None, 'NEEDS_ENV: scripts[%r] в backend/package.json отсутствует '
                      '(контроль судит DRILL_MEASUREMENTS_ABSENT); живой вызов '
                      'коллектора командой поставки НЕ проверен' % DRILL_SCRIPT)
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    cands = script_candidates(tree)
    coll = next(((rel, body) for rel, body in cands
                 if rel.split('/')[-1] in cmd), None)
    if coll is None:
        return (False, 'scripts[%s] не указывает на коллектор backend/scripts '
                       '(drill+rpo+rto): %r' % (DRILL_SCRIPT, cmd[:100]))
    rel = coll[0]
    notes, oks = [], []
    with tempfile.TemporaryDirectory(prefix='stend109-drill-') as tmp:
        be = Path(tmp) / 'backend'
        shutil.copytree(tree.repo / 'backend', be,
                        ignore=shutil.ignore_patterns('node_modules'))
        for orel, obody in (tree.overlay or {}).items():  # оверлей мутанта — в копию
            dest = Path(tmp) / orel
            if obody is None:
                if dest.is_file():
                    dest.unlink()
            else:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(obody, encoding='utf-8')

        def run(tag, input_path=None):
            c = re.sub(r'(--out[ =])\S+', lambda m: m.group(1) + tag, cmd, count=1)
            if c == cmd and '--out' not in cmd:
                c = '%s --out %s' % (cmd, tag)
            if input_path is not None:
                c = '%s --input %s' % (c, input_path)
            return subprocess.run(['/bin/sh', '-c', c], capture_output=True,
                                  text=True, timeout=60, cwd=str(be))

        def read_ev(tag):
            try:
                return json.loads((be / tag / 'drill-evidence.json')
                                  .read_text(encoding='utf-8'))
            except (OSError, ValueError):
                return {}
        r0 = run('A')
        ev = read_ev('A')
        ok0 = (r0.returncode == 0 and ev.get('status') == 'NOT_RUN'
               and all(ev.get(k) == v for k, v in DRILL_TARGETS.items())
               and not ev.get('measured_rpo_minutes'))
        oks.append(ok0)
        notes.append('команда поставки без входа: rc=%d status=%r' % (
            r0.returncode, ev.get('status')))
        for i, inp in enumerate(DRILL_INPUTS):
            ipath = Path(tmp) / ('in%d.json' % i)
            ipath.write_text(json.dumps(inp), encoding='utf-8')
            ri = run('B%d' % i, str(ipath))
            evi = read_ev('B%d' % i)
            want = {'status': 'MEASURED', 'db_hash': sha256_text(inp['db_dump']),
                    'object_hash': sha256_text(inp['objects_dump']),
                    'key_hash': sha256_text(inp['keys_dump']),
                    'measured_rpo_minutes': inp['measured_rpo_minutes'],
                    'measured_rto_minutes': inp['measured_rto_minutes'],
                    'measured_at': inp['measured_at']}
            want.update(DRILL_TARGETS)
            bad = ['%s=%r≠%r' % (k, evi.get(k), v) for k, v in want.items() if evi.get(k) != v]
            oks.append(ri.returncode == 0 and not bad)
            notes.append('вход%d: rc=%d status=%r %s' % (
                i, ri.returncode, evi.get('status'), '; '.join(bad[:3]) or 'ок'))
    return (all(oks), 'команда поставки scripts[%s] → %s: %s' % (
        DRILL_SCRIPT, rel, ' | '.join(notes)))


HARNESS_OBS = (
    {'mode': 'FIXTURE_5_8_2',
     'http_request': {'method': 'POST', 'url': '/api/v1/documents/one',
                      'headers': {'authorization': 'tok_SENTINEL_A1'}},
     'http_response': {'status': 201, 'body': 'created-one'},
     'sql_before': 'SELECT count(*) FROM documents /* BEFORE-ONE */',
     'sql_after': 'SELECT count(*) FROM documents /* AFTER-ONE */',
     'runtime_role': 'hc_api_role_one', 'provider_calls': 2,
     'inputs': {'payload_one': 'omega-bytes-one', 'meta_one': '111'},
     'secrets': ['tok_SENTINEL_A1']},
    {'mode': 'SYNTHETIC',
     'http_request': {'method': 'GET', 'url': '/api/v1/documents/two'},
     'http_response': {'status': 200, 'body': 'fetched-two for sentinel-two@example.com'},
     'sql_before': 'SELECT id FROM documents /* BEFORE-TWO */',
     'sql_after': 'SELECT id FROM documents /* AFTER-TWO */',
     'runtime_role': 'hc_api_role_two', 'provider_calls': 5,
     'inputs': {'payload_two': 'sigma-bytes-two'},
     'secrets': ['sentinel-two@example.com']},
    {'mode': 'RUNTIME',
     'http_request': {'method': 'PUT', 'url': '/api/v1/documents/three',
                      'headers': {'authorization': 'tok_SENTINEL_B2'}},
     'http_response': {'status': 200, 'body': 'updated-three'},
     'sql_before': 'SELECT id FROM documents /* BEFORE-THREE */',
     'sql_after': 'SELECT id FROM documents /* AFTER-THREE */',
     'runtime_role': 'hc_api_role_three', 'provider_calls': 7,
     'inputs': {'payload_three': 'theta-bytes-three'},
     'secrets': ['tok_SENTINEL_B2']},
)

HARNESS_DRIVER = """
'use strict';
const fs = require('fs'), path = require('path');
const harness = require(process.argv[2]);
const dir = process.argv[3], obsList = JSON.parse(fs.readFileSync(process.argv[4], 'utf8'));
const list = () => fs.readdirSync(dir).sort().map(n => [n, fs.readFileSync(path.join(dir, n), 'utf8')]);
try {
  fs.mkdirSync(dir, { recursive: true });
  const before = list();
  const entries = [], afters = [];
  for (const obs of obsList) {
    entries.push(harness.recordInteraction(JSON.parse(JSON.stringify(obs)), dir));
    afters.push(list());
  }
  console.log(JSON.stringify({ entries, before, afters }));
} catch (e) {
  console.log(JSON.stringify({ error: String((e && e.message) || e) }));
}
"""


HARNESS_AXES = ('http_request', 'http_response', 'sql_before', 'sql_after',
                'runtime_role', 'provider_calls')


def leaf_match(exp, act, secrets):
    """Сверка значения оси (правило Ц, звено 3 — чтение из sink): строка,
    несущая сентинел, обязана в файле присутствовать, быть непустой и без
    сентинела (форма К4 «не равно сентинелу и не пусто»); прочее — exact."""
    if isinstance(exp, dict):
        if not isinstance(act, dict) or set(exp) != set(act):
            return False
        return all(leaf_match(exp[k], act[k], secrets) for k in exp)
    if isinstance(exp, list):
        if not isinstance(act, list) or len(exp) != len(act):
            return False
        return all(leaf_match(x, y, secrets) for x, y in zip(exp, act))
    if isinstance(exp, str) and any(s in exp for s in secrets):
        return (isinstance(act, str) and act != ''
                and not any(s in act for s in secrets))
    return exp == act


def harness_fact(repo, tree=None):
    """Живое исполнение recordInteraction (правило Ц): mode, шесть осей и
    input_hashes читаются из СОХРАНЁННЫХ файлов, сопоставленных наблюдениям
    по порядку создания; return — дополнительная сверка; append-only — ровно
    три файла, прежние неизменны; сентинелы в файлах отсутствуют."""
    tree = tree or Tree(repo)
    body = tree.get(HARNESS)
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    with tempfile.TemporaryDirectory(prefix='stend109-h-') as tmp:
        h = Path(tmp) / 'harness.js'
        h.write_text(body, encoding='utf-8')
        driver = Path(tmp) / 'driver.js'
        driver.write_text(HARNESS_DRIVER, encoding='utf-8')
        obs = Path(tmp) / 'obs.json'
        obs.write_text(json.dumps(HARNESS_OBS), encoding='utf-8')
        try:
            r = subprocess.run([node, str(driver), str(h), str(Path(tmp) / 'ev'), str(obs)],
                               capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return (False, 'драйвер recordInteraction: таймаут')
        try:
            out = json.loads(r.stdout)
        except ValueError:
            return (False, 'драйвер rc=%d: stdout=%r stderr=%r' % (
                r.returncode, r.stdout[:120], r.stderr[:200]))
    if 'error' in out:
        return (False, 'recordInteraction: %s' % out['error'][:200])
    entries, notes = out.get('entries') or [], []
    afters = [out.get('before') or []] + list(out.get('afters') or [])
    ok = len(entries) == len(HARNESS_OBS) and len(afters) == len(HARNESS_OBS) + 1
    if not ok:
        notes.append('записей %d (ожидалось %d)' % (len(entries), len(HARNESS_OBS)))
    # сопоставление файлов наблюдениям по порядку создания (звено 2: субъект
    # сам создаёт sink; батарея его не подменяет)
    prev, files_by_obs = {}, []
    for i, step in enumerate(afters[1:]):
        cur = {n: c for n, c in step}
        for n, c in prev.items():
            if cur.get(n) != c:
                ok = False
                notes.append('append-only: %s изменён после записи %d' % (n, i))
        new = [n for n in cur if n not in prev]
        if len(new) != 1:
            ok = False
            notes.append('запись %d: новых файлов %d (ожидался 1)' % (i, len(new)))
            files_by_obs.append(None)
        else:
            files_by_obs.append(new[0])
        prev = cur
    final_map = {n: c for n, c in afters[-1]} if afters else {}
    for i, obs_i in enumerate(HARNESS_OBS):
        # звено 3: ожидания сравниваются со значениями, ПРОЧИТАННЫМИ из файла
        if i < len(files_by_obs) and files_by_obs[i] is not None:
            name = files_by_obs[i]
            raw = final_map.get(name)
            try:
                f = json.loads(raw)
            except ValueError:
                ok = False
                notes.append('запись %d: %s не JSON' % (i, name))
                f = None
            if f is not None:
                if f.get('mode') != obs_i['mode']:
                    ok = False
                    notes.append('запись %d: mode из файла %r≠%r' % (
                        i, f.get('mode'), obs_i['mode']))
                for axis in HARNESS_AXES:
                    if not leaf_match(obs_i[axis], f.get(axis), obs_i['secrets']):
                        ok = False
                        notes.append('запись %d: ось %s из файла ≠ наблюдению' % (i, axis))
                want_hashes = {k: sha256_text(v) for k, v in obs_i['inputs'].items()}
                if f.get('input_hashes') != want_hashes:
                    ok = False
                    notes.append('запись %d: input_hashes из файла ≠ sha256 входов' % i)
                for s in obs_i['secrets']:
                    if s in (raw or ''):
                        ok = False
                        notes.append('scrubber: %s в %s' % (s, name))
        # возвращённый кортеж — дополнительная, не замещающая сверка
        if i < len(entries):
            e = entries[i] or {}
            for axis in HARNESS_AXES:
                if e.get(axis) != obs_i[axis]:
                    ok = False
                    notes.append('взаимодействие%d: ось %s (return)=%r≠%r' % (
                        i, axis, e.get(axis), obs_i[axis]))
            for k, v in obs_i['inputs'].items():
                if (e.get('input_hashes') or {}).get(k) != sha256_text(v):
                    ok = False
                    notes.append('взаимодействие%d: input_hashes[%s] (return)≠%s' % (
                        i, k, sha256_text(v)))
    all_secrets = [s for o in HARNESS_OBS for s in o['secrets']]
    for name, text_file in (afters[-1] if afters else []):
        for s in all_secrets:
            if s in text_file:
                ok = False
                notes.append('scrubber: %s в %s' % (s, name))
    return (ok, 'живое recordInteraction: %s' % (
        '; '.join(notes[:6]) or 'режимы/оси/хэши из файла, append-only, scrubber ок'))


# ---------------------------------------------------------------- факты круга 2

def drill_input_fact(repo, tree=None):
    """Живая честность входов drill-коллектора (F2): measured_* null/строка —
    отказ rc≠0 без MEASURED; повторный прогон в тот же --out не перезаписывает
    измеренный evidence (байты файла неизменны)."""
    tree = tree or Tree(repo)
    cmd = drill_entry_command(tree)
    if cmd is None:
        return (None, 'NEEDS_ENV: scripts[%r] в backend/package.json отсутствует '
                      '(контроль судит DRILL_MEASUREMENTS_ABSENT); валидация входов '
                      'и append-only drill-evidence НЕ проверены' % DRILL_SCRIPT)
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    cands = script_candidates(tree)
    coll = next(((rel, body) for rel, body in cands
                 if rel.split('/')[-1] in cmd), None)
    if coll is None:
        return (False, 'scripts[%s] не указывает на коллектор backend/scripts '
                       '(drill+rpo+rto): %r' % (DRILL_SCRIPT, cmd[:100]))
    notes, oks = [], []
    with tempfile.TemporaryDirectory(prefix='stend109-drillin-') as tmp:
        be = Path(tmp) / 'backend'
        shutil.copytree(tree.repo / 'backend', be,
                        ignore=shutil.ignore_patterns('node_modules'))
        for orel, obody in (tree.overlay or {}).items():
            dest = Path(tmp) / orel
            if obody is None:
                if dest.is_file():
                    dest.unlink()
            else:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(obody, encoding='utf-8')

        def run(tag, input_path=None):
            c = re.sub(r'(--out[ =])\S+', lambda m: m.group(1) + tag, cmd, count=1)
            if c == cmd and '--out' not in cmd:
                c = '%s --out %s' % (cmd, tag)
            if input_path is not None:
                c = '%s --input %s' % (c, input_path)
            return subprocess.run(['/bin/sh', '-c', c], capture_output=True,
                                  text=True, timeout=60, cwd=str(be))

        def ev(tag):
            try:
                return (be / tag / 'drill-evidence.json').read_text(encoding='utf-8')
            except OSError:
                return None
        badnull = {'db_dump': 'DB', 'objects_dump': 'OBJ', 'keys_dump': 'KEYS',
                   'measured_rpo_minutes': None, 'measured_rto_minutes': None,
                   'measured_at': None}
        badstr = {'db_dump': 'DB', 'objects_dump': 'OBJ', 'keys_dump': 'KEYS',
                  'measured_rpo_minutes': 'ok', 'measured_rto_minutes': 'fine',
                  'measured_at': 'never'}
        good = {'db_dump': 'DB-REAL', 'objects_dump': 'OBJ', 'keys_dump': 'KEYS',
                'measured_rpo_minutes': 7, 'measured_rto_minutes': 90,
                'measured_at': '2026-10-20T00:00:00Z'}
        for fname, payload in (('badnull', badnull), ('badstr', badstr)):
            ip = Path(tmp) / ('%s.json' % fname)
            ip.write_text(json.dumps(payload), encoding='utf-8')
            r = run('D_' + fname, str(ip))
            text = ev('D_' + fname)
            leaked = bool(text and 'MEASURED' in text)
            oks.append(r.returncode != 0 and not leaked)
            notes.append('%s: rc=%d MEASURED-в-файле=%s' % (
                fname, r.returncode, leaked))
        ip = Path(tmp) / 'good.json'
        ip.write_text(json.dumps(good), encoding='utf-8')
        r1 = run('KEEP', str(ip))
        first = ev('KEEP')
        ok1 = r1.returncode == 0 and first is not None and '"MEASURED"' in first
        oks.append(ok1)
        notes.append('измеренный: rc=%d MEASURED=%s' % (
            r1.returncode, bool(first and '"MEASURED"' in first)))
        r2 = run('KEEP')
        second = ev('KEEP')
        oks.append(ok1 and second == first)
        notes.append('повтор в тот же --out: rc=%d файл-неизменен=%s' % (
            r2.returncode, second == first))
    return (all(oks), 'drill входы/append-only: %s' % ' | '.join(notes))


HARNESS_HONESTY_DRIVER = """
'use strict';
const fs = require('fs'), path = require('path');
const harness = require(process.argv[2]);
const base = process.argv[3];
process.env.COMPLIOR_HARNESS_DATABASE_URL = 'postgres://x:y@127.0.0.1:1/z';
const attempt = (fn) => Promise.resolve()
  .then(fn)
  .then((r) => ({ threw: false, result: r }))
  .catch((e) => ({ threw: true, err: String((e && e.message) || e) }));
const obsBase = { http_request: { method: 'GET', url: '/fixture' },
  http_response: { status: 200 }, sql_before: 'S1', sql_after: 'S2',
  runtime_role: 'hc_fixture', provider_calls: 0, inputs: {} };
(async () => {
  const out = { has_cba: typeof harness.captureBeforeAfter === 'function' };
  out.no_mode = await attempt(() => harness.captureBeforeAfter(
    Object.assign({}, obsBase), path.join(base, 'h1')));
  out.mock_mode = await attempt(() => harness.captureBeforeAfter(
    Object.assign({}, obsBase, { mode: 'MOCK_SUCCESS' }), path.join(base, 'h4')));
  out.db_down = await attempt(() => harness.captureBeforeAfter(
    Object.assign({}, obsBase, { mode: 'RUNTIME' }), path.join(base, 'h3')));
  out.files = {};
  for (const d of ['h1', 'h4', 'h3']) {
    try {
      out.files[d] = fs.readdirSync(path.join(base, d))
        .map((n) => fs.readFileSync(path.join(base, d, n), 'utf8'));
    } catch (e) { out.files[d] = null; }
  }
  console.log(JSON.stringify(out));
})().catch((e) => console.log(JSON.stringify({ fatal: String((e && e.message) || e) })));
"""


def harness_honesty_fact(repo, tree=None):
    """Живая честность captureBeforeAfter (F3): без mode → отказ; mode только из
    трёх литералов; недоступная БД → не успех (throw ИЛИ NOT_RUN)."""
    tree = tree or Tree(repo)
    body = tree.get(HARNESS)
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    with tempfile.TemporaryDirectory(prefix='stend109-hon-') as tmp:
        h = Path(tmp) / 'harness.js'
        h.write_text(body, encoding='utf-8')
        d = Path(tmp) / 'driver.js'
        d.write_text(HARNESS_HONESTY_DRIVER, encoding='utf-8')
        ev = Path(tmp) / 'ev'
        try:
            r = subprocess.run([node, str(d), str(h), str(ev)],
                               capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return (False, 'драйвер честности: таймаут')
        try:
            out = json.loads(r.stdout)
        except ValueError:
            return (False, 'драйвер честности rc=%d: stdout=%r stderr=%r' % (
                r.returncode, r.stdout[:100], (r.stderr or '')[:150]))
    if 'fatal' in out:
        return (False, 'captureBeforeAfter: %s' % out['fatal'][:200])
    if not out.get('has_cba'):
        return (False, 'captureBeforeAfter не экспортирован — поверхность '
                       'честности (mode/NOT_RUN) недоступна вызывающему')
    notes, ok = [], True
    if not (out.get('no_mode') or {}).get('threw'):
        ok = False
        notes.append('без mode: отказа нет (mode выдуман RUNTIME)')
    if not (out.get('mock_mode') or {}).get('threw'):
        ok = False
        notes.append('mode MOCK_SUCCESS принят вне трёх литералов')
    dd = out.get('db_down') or {}
    honest_down = dd.get('threw') or (isinstance(dd.get('result'), dict) and (
        (dd['result'].get('db_snapshot') or {}).get('status') == 'NOT_RUN'
        or dd['result'].get('status') == 'NOT_RUN'))
    if not honest_down:
        ok = False
        notes.append('БД недоступна: не отказ и не NOT_RUN')
    for dname, texts in (out.get('files') or {}).items():
        for t in texts or []:
            if 'MEASURED' in t:
                ok = False
                notes.append('MEASURED в файле %s при недоступной БД' % dname)
    return (ok, 'честность captureBeforeAfter: %s' % (
        '; '.join(notes[:5]) or 'без mode → отказ; литералы; БД недоступна → NOT_RUN'))


HARNESS_PII_OBS = {
    'mode': 'RUNTIME',
    'http_request': {'method': 'GET', 'url': '/api/v1/patients/1',
                     'headers': {'authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.REAL.TOKEN',
                                 'cookie': 'session=SECRETSESSION',
                                 'x-doc-token': 'tok"Q\\Z'}},
    'http_response': {'status': 200,
                      'body': 'patient ivan.petrov@clinic.ru, phone +7 916 000-00-00'},
    'sql_before': 'SELECT 1 /* PII-B */',
    'sql_after': 'SELECT 2 /* PII-A */',
    'runtime_role': 'hc_api_role_pii', 'provider_calls': 1,
    'inputs': {'note': 'kappa-bytes-pii'},
    'secrets': ['tok"Q\\Z'],
}

PII_FORBIDDEN = ['eyJhbGciOiJIUzI1NiJ9.REAL.TOKEN', 'SECRETSESSION',
                 'ivan.petrov@clinic.ru', '+7 916 000-00-00', 'tok"Q\\Z']

HARNESS_PII_DRIVER = """
'use strict';
const fs = require('fs'), path = require('path');
const harness = require(process.argv[2]);
const dir = process.argv[3], obs = JSON.parse(fs.readFileSync(process.argv[4], 'utf8'));
const rec = harness.recordInteraction(obs, dir);
const files = fs.readdirSync(dir).sort()
  .map((n) => [n, fs.readFileSync(path.join(dir, n), 'utf8')]);
console.log(JSON.stringify({ rec, files }));
"""


def harness_pii_fact(repo, tree=None):
    """Живой scrubber PII (F4): необъявленные Bearer/cookie/email/phone и
    объявленный секрет с "/\\ не попадают в sink ни raw-, ни JSON-экранированной
    формой; запись не вакуумна (правило Ц, звено 3 — чтение из файла)."""
    tree = tree or Tree(repo)
    body = tree.get(HARNESS)
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    with tempfile.TemporaryDirectory(prefix='stend109-pii-') as tmp:
        h = Path(tmp) / 'harness.js'
        h.write_text(body, encoding='utf-8')
        d = Path(tmp) / 'driver.js'
        d.write_text(HARNESS_PII_DRIVER, encoding='utf-8')
        o = Path(tmp) / 'obs.json'
        o.write_text(json.dumps(HARNESS_PII_OBS), encoding='utf-8')
        ev = Path(tmp) / 'ev'
        try:
            r = subprocess.run([node, str(d), str(h), str(ev), str(o)],
                               capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return (False, 'драйвер PII: таймаут')
        try:
            out = json.loads(r.stdout)
        except ValueError:
            return (False, 'драйвер PII rc=%d: stdout=%r stderr=%r' % (
                r.returncode, r.stdout[:100], (r.stderr or '')[:150]))
    files = out.get('files') or []
    if not files:
        return (False, 'recordInteraction не создал файл evidence')
    forbidden = []
    for v in PII_FORBIDDEN:
        forbidden.append(v)
        esc = json.dumps(v)[1:-1]
        if esc != v:
            forbidden.append(esc)
    notes, ok = [], True
    for name, text_file in files:
        for v in forbidden:
            if v in text_file:
                ok = False
                notes.append('утечка %r в %s' % (v[:26], name))
    try:
        rec = json.loads(files[0][1])
    except ValueError:
        return (False, 'файл evidence не JSON')
    headers = (rec.get('http_request') or {}).get('headers') or {}
    if not isinstance(headers.get('authorization'), str) or not headers.get('authorization'):
        ok = False
        notes.append('authorization выпадена (вакуумная вырезка)')
    resp_body = (rec.get('http_response') or {}).get('body')
    if not isinstance(resp_body, str) or 'patient' not in resp_body:
        ok = False
        notes.append('тело ответа потеряно (вакуумная вырезка)')
    if rec.get('mode') != HARNESS_PII_OBS['mode']:
        ok = False
        notes.append('mode из файла %r' % rec.get('mode'))
    return (ok, 'PII/scrubber: %s' % ('; '.join(notes[:5]) or
            'Bearer/cookie/email/phone/экранированный секрет отсутствуют в sink'))


def stend_up_fact(repo, tree=None):
    """Живой подъём стенда одной командой (F1/Б1): up -d --wait rc 0,
    ledger control.schema_migration = 14, повтор rc 0 и ledger прежний;
    down -v после прогона; уникальный -p, published-портов не занимается."""
    tree = tree or Tree(repo)
    compose = tree.get('backend/compose.dev.yml')
    if compose is None:
        return (None, 'NEEDS_ENV: compose.dev.yml отсутствует (контроль судит '
                      'COMPOSE_MISSING); живой подъём стенда НЕ проверен')
    try:
        dc = subprocess.run(['docker', 'compose', 'version'],
                            capture_output=True, text=True, timeout=30)
        if dc.returncode != 0:
            dc = None
    except (OSError, subprocess.TimeoutExpired):
        dc = None
    if dc is None:
        return (None, 'NEEDS_ENV: docker compose недоступен — живой подъём стенда '
                      '(миграция до API, ledger=14, повтор, том PG18) НЕ проверен')
    project = 'stend109up%s' % uuid.uuid4().hex[:8]
    repo_p = Path(repo)
    cwd = repo_p
    cf = repo_p / 'backend' / 'compose.dev.yml'
    tmpdir = None
    if tree.overlay:
        # релоцированная копия: относительные bind-пути → абсолютные от корня R
        text = re.sub(r'^(\s*-\s*)\.\./([^:\s]+):',
                      lambda m: '%s%s:' % (m.group(1), (repo_p / m.group(2)).resolve()),
                      compose, flags=re.M)
        text = re.sub(r'context:\s*\.\s*$', 'context: %s' % (repo_p / 'backend'),
                      text, flags=re.M)
        tmpdir = tempfile.mkdtemp(prefix='stend109-up-')
        cf = Path(tmpdir) / 'compose.dev.yml'
        cf.write_text(text, encoding='utf-8')
        cwd = Path(tmpdir)
    notes, oks = [], []
    try:
        def dcompose(*a, timeout=420):
            return subprocess.run(['docker', 'compose', '-p', project, '-f', str(cf), *a],
                                  capture_output=True, text=True, timeout=timeout,
                                  cwd=str(cwd))
        ledger_sql = ('psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" '
                      '-tAc "SELECT count(*) FROM control.schema_migration"')
        blocks = service_blocks(services_section(compose))
        pgsvc = next((n for n, blk in blocks.items()
                      if re.search(r'image:\s*\S*postgres', blk or '')), None)
        r1 = dcompose('up', '-d', '--wait')
        oks.append(r1.returncode == 0)
        notes.append('up -d --wait: rc=%d %s' % (
            r1.returncode, (r1.stderr or '').strip()[:110]))
        if r1.returncode == 0:
            if pgsvc is None:
                oks.append(False)
                notes.append('сервис PG не найден для ledger-проверки')
            else:
                q = dcompose('exec', '-T', pgsvc, 'sh', '-lc', ledger_sql, timeout=60)
                led = (q.stdout or '').strip()
                oks.append(q.returncode == 0 and led == '14')
                notes.append('ledger=%r rc=%d' % (led, q.returncode))
            r2 = dcompose('up', '-d', '--wait')
            led2 = None
            if pgsvc is not None:
                q2 = dcompose('exec', '-T', pgsvc, 'sh', '-lc', ledger_sql, timeout=60)
                led2 = (q2.stdout or '').strip()
                ok3 = r2.returncode == 0 and q2.returncode == 0 and led2 == '14'
            else:
                ok3 = False
            oks.append(ok3)
            notes.append('повтор: rc=%d ledger=%r' % (r2.returncode, led2))
    finally:
        try:
            subprocess.run(['docker', 'compose', '-p', project, '-f', str(cf),
                            'down', '-v', '--remove-orphans'],
                           capture_output=True, text=True, timeout=120, cwd=str(cwd))
        except (OSError, subprocess.TimeoutExpired):
            pass
        if tmpdir:
            shutil.rmtree(tmpdir, ignore_errors=True)
    return (all(oks), 'живой стенд (проект %s): %s' % (
        project, ' | '.join(notes)))


def files_sha_fact(repo, tree=None):
    """Производные FILES.sha256 (F5/Б3): каждая строка — файл ЕСТЬ в коммите и
    sha256 blob из HEAD совпадает (оракул независим: git + hashlib, не
    tools/verify_handoff.py)."""
    tree = tree or Tree(repo)
    text = tree.get('FILES.sha256')
    if text is None:
        return (None, 'NEEDS_ENV: FILES.sha256 отсутствует — соответствие '
                      'производных коммиту НЕ проверено')
    if not (Path(repo) / '.git').exists():
        return (None, 'NEEDS_ENV: нет .git — соответствие FILES.sha256 коммиту '
                      'НЕ проверено')
    bad = []
    lines = [ln for ln in text.splitlines() if ln.strip()]
    for ln in lines:
        m = re.match(r'^([0-9a-f]{64})  (.+)$', ln)
        if not m:
            bad.append('формат строки: %s' % ln[:60])
            continue
        want, rel = m.groups()
        e = subprocess.run(['git', '-C', str(repo), 'cat-file', '-e',
                            'HEAD:%s' % rel], capture_output=True)
        if e.returncode != 0:
            bad.append('нет в коммите: %s' % rel)
            continue
        blob = subprocess.run(['git', '-C', str(repo), 'show', 'HEAD:%s' % rel],
                              capture_output=True)
        if hashlib.sha256(blob.stdout).hexdigest() != want:
            bad.append('sha256 расходится: %s' % rel)
    return (not bad, '%d строк; %s' % (len(lines), '; '.join(bad[:4])
            or 'все строки — файлы коммита, sha256 сходится'))

def check_facts(repo, tree=None):
    """{имя: (True|False|None, пояс)}; None = NEEDS_ENV (честный NOT_RUN)."""
    facts = {}
    r = Path(repo)
    tree = tree or Tree(repo)
    root_ok, root_notes = True, []
    for rel, want_sha in ROOT_SERVER_SHA.items():
        body = tree.get(rel)
        sha = sha256_text(body) if body is not None else None
        if sha != want_sha:
            root_ok = False
            root_notes.append('%s sha=%s' % (rel, (sha or 'нет')[:12]))
    facts['ROOT_SERVER_PRESENT'] = (
        root_ok, 'historical SYNTHETIC bytes по sha256: %s' % ('ок' if root_ok else '; '.join(root_notes)))
    node = shutil.which('node')
    facts['RUNNER_DAMAGE_GUARD'] = runner_damage_fact(r, node)
    facts['EGRESS_GUARD'] = egress_fact(repo, tree)
    facts['DRILL_EVIDENCE_GUARD'] = drill_fact(repo, tree)
    facts['HARNESS_TUPLE_GUARD'] = harness_fact(repo, tree)
    facts['DRILL_INPUT_GUARD'] = drill_input_fact(repo, tree)
    facts['HARNESS_HONESTY_GUARD'] = harness_honesty_fact(repo, tree)
    facts['HARNESS_PII_GUARD'] = harness_pii_fact(repo, tree)
    facts['STEND_UP_GUARD'] = stend_up_fact(repo, tree)
    facts['FILES_SHA256_GUARD'] = files_sha_fact(repo, tree)
    return facts


# ---------------------------------------------------------------- мутанты

def need(text):
    return text is not None

def mut_compose_delete(t):
    return {'backend/compose.dev.yml': None} if t.get('backend/compose.dev.yml') is not None else None



def mut_api_before_migration(t):
    b = t.get('backend/compose.dev.yml')
    return {'backend/compose.dev.yml': b.replace('service_completed_successfully', 'service_started')} if need(b) else None


def mut_image_unpinned(t):
    b = t.get('backend/compose.dev.yml')
    return {'backend/compose.dev.yml': re.sub(r'postgres:18\S*', 'postgres:latest', b)} if need(b) else None


def mut_prod_dump(t):
    b = t.get('backend/compose.dev.yml')
    return {'backend/compose.dev.yml': b + '\n      - ./data/prod_dump:/var/lib/postgresql/dump:ro\n'} if need(b) else None


def mut_ddl_secrets(t):
    b = t.get('backend/compose.dev.yml')
    if not need(b):
        return None
    lines = b.split('\n')
    for i, line in enumerate(lines):
        if line.rstrip() == '  api:':
            lines.insert(i + 1, '      MIGRATION_DATABASE_URL: postgres://m:m@db:5432/app')
            break
    else:
        return None
    return {'backend/compose.dev.yml': '\n'.join(lines)}


def mut_harness_delete(t):
    return {HARNESS: None} if t.get(HARNESS) is not None else None


def mut_egress_open(t):
    b = t.get('backend/compose.dev.yml')
    return {'backend/compose.dev.yml': b.replace('internal: true', 'internal: false')} if need(b) else None


def mut_db_exposed(t):
    b = t.get('backend/compose.dev.yml')
    return {'backend/compose.dev.yml': b.replace('127.0.0.1:5432', '0.0.0.0:5432')} if need(b) else None


def mut_ephemeral_db(t):
    b = t.get('backend/compose.dev.yml')
    return {'backend/compose.dev.yml': re.sub(r'^(\s*)- [A-Za-z_][A-Za-z0-9_-]*:(/\S*)$',
                                              r'\1- /tmp/pg\2', b, flags=re.M)} if need(b) else None



def mut_harness_overwrite(t):
    b = t.get(HARNESS)
    return {HARNESS: b.replace("'wx'", "'w'").replace('"wx"', '"w"')} if need(b) else None


def mut_no_scrubber(t):
    b = t.get(HARNESS)
    return {HARNESS: re.sub(r'(scrub|redact|sanitiz)\w*\(', 'identity(', b)} if need(b) else None


def mut_no_sql(t):
    b = t.get(HARNESS)
    if not need(b):
        return None
    return {HARNESS: '\n'.join(
        line if 'RECORD_AXES' in line
        else line.replace('sql_before', 'sql').replace('sql_after', 'sql')
        for line in b.split('\n'))}


def mut_no_role(t):
    b = t.get(HARNESS)
    return {HARNESS: b.replace('current_user', 'session_user')} if need(b) else None


def mut_no_provider(t):
    b = t.get(HARNESS)
    if not need(b):
        return None
    return {HARNESS: '\n'.join(
        line if 'RECORD_AXES' in line else line.replace('provider_call', 'provider')
        for line in b.split('\n'))}


def mut_no_hashes(t):
    b = t.get(HARNESS)
    return {HARNESS: b.replace('input_hashes', 'inputs')} if need(b) else None


def mut_mock_success(t):
    b = t.get(HARNESS)
    return {HARNESS: b.replace("'NOT_RUN'", "'SUCCESS'").replace('"NOT_RUN"', '"SUCCESS"')} if need(b) else None


def mut_no_mode_label(t):
    b = t.get(HARNESS)
    return {HARNESS: b.replace('FIXTURE_5_8_2', 'FIXTURE')} if need(b) else None


def mut_axis_drop(t):
    b = t.get(HARNESS)
    return {HARNESS: re.sub(r",\s*['\"]provider_calls['\"]", '', b)} if need(b) else None


def mut_integ_delete(t):
    tests = find_harness_tests(t)
    return {tests[0]: None} if tests else None


def mut_script_unwire(t):
    b = t.get('backend/package.json')
    if not need(b):
        return None
    return {'backend/package.json': b.replace('tests/integration/**/*.test.js',
                                              'tests/integration/migrations/**/*.test.js')}


def mut_drill_absent(t):
    for rel in [HARNESS] + ['backend/scripts/%s' % n for n in scripts_names(t)]:
        b = t.get(rel)
        if b and 'drill' in b.lower():
            return {rel: re.sub(r'drill', 'restor', b, flags=re.I)}
    return None


def mut_root_server_delete(_t):
    return {'server/test/harness.ts': None}

DRILL_DEAD = "const drill = {rpo: 15, rto: 240, state: 'NOT_RUN'};"


def mut_drill_dead_file(t):
    """Обход Б2 круга 1: файл с литералами drill/rpo/rto/NOT_RUN, ничего не исполняет."""
    for rel, _body in script_candidates(t):
        return {rel: DRILL_DEAD + '\n'}
    return None


HARNESS_DECOY = ("module.exports = {recordInteraction: () => "
                 "({mode: 'RUNTIME', http_response: {status: 200}})};")


def mut_harness_decoy(t):
    """Обход Б3 круга 1: record возвращает декой без кортежа/хэшей/provider count."""
    return {HARNESS: HARNESS_DECOY} if t.get(HARNESS) is not None else None


def mut_egress_unused_net(t):
    """Обход Б1 круга 1: unused-сеть с internal:true, document-worker на default."""
    b = t.get('backend/compose.dev.yml')
    if not need(b):
        return None
    lines, out, svc, i = b.split('\n'), [], None, 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r'^  ([A-Za-z0-9_-]+):\s*$', line)
        if m:
            svc = m.group(1)
        if svc and re.search(r'worker|sandbox|document', svc) and re.match(r'^\s+networks:\s*$', line):
            i += 1
            while i < len(lines) and (re.match(r'^\s+-\s+[A-Za-z0-9_-]+\s*$', lines[i])
                                      or re.match(r'^\s{6,}[A-Za-z0-9_-]+:', lines[i])):
                i += 1
            continue
        out.append(line)
        i += 1
    text = '\n'.join(out)
    if re.search(r'^networks:\s*$', text, re.M):
        text = re.sub(r'^networks:\s*$', 'networks:\n  unused_guard:\n    internal: true',
                      text, count=1, flags=re.M)
    else:
        text += '\nnetworks:\n  unused_guard:\n    internal: true\n'
    return {'backend/compose.dev.yml': text}

def mut_harness_sink_decoy(t):
    """Обход Б1 круга 2: честный return, в sink пишется '{}' — чтение из sink
    (К1) ловит; дельта критика байт-в-байт (writeSync(fd, '{}'))."""
    b = t.get(HARNESS)
    if not need(b):
        return None
    return {HARNESS: b.replace('fs.writeSync(fd, text);', "fs.writeSync(fd, '{}');")}


def mut_drill_unwired(t):
    """Обход Б2 круга 2: живой коллектор отвязан от поставки — scripts['drill:evidence']
    удалён, require/тест drill удалены, basename только в description; дельта
    критика байт-в-байт."""
    pkg = t.get('backend/package.json')
    if not need(pkg) or '"%s"' % DRILL_SCRIPT not in pkg:
        return None
    out = []
    for ln in pkg.split('\n'):
        if '"%s"' % DRILL_SCRIPT in ln:
            if out and out[-1].rstrip().endswith(','):
                out[-1] = out[-1].rstrip()[:-1]
            continue
        out.append(ln)
    pkg2 = re.sub(r'"description": "[^"]*"',
                  '"description": "drill-measure.js"', '\n'.join(out), count=1)
    overlay = {'backend/package.json': pkg2}
    for rel in find_harness_tests(t):
        body = t.get(rel)
        if not body or 'drill-measure' not in body:
            continue
        keep = [ln for ln in body.splitlines(keepends=True)
                if ln.strip() == "'use strict';" or 'helpers/harness' in ln]
        overlay[rel] = ''.join(keep)
        break
    return overlay


def mut_harness_mode_collapse(t):
    """Обход Б3 круга 2: все режимы пишутся RUNTIME; mode из sink (К3) ловит;
    дельта критика байт-в-байт (mode: 'RUNTIME')."""
    b = t.get(HARNESS)
    if not need(b):
        return None
    return {HARNESS: b.replace("mode: rec.mode || 'RUNTIME',", "mode: 'RUNTIME',")}


def mut_scrubber_identity(t):
    """Обход К4 круга 2: scrubSecrets вырожден в identity — сентинел из
    сериализуемого поля остаётся в sink; дельта критика байт-в-байт."""
    b = t.get(HARNESS)
    if not need(b):
        return None
    honest = ("function scrubSecrets(text, secrets) {\n"
              "  let out = text;\n"
              "  for (const s of secrets || []) out = out.split(String(s)).join('[REDACTED]');\n"
              "  return out;\n"
              "}")
    decoy = "function scrubSecrets(text, secrets) { return text; }"
    if honest in b:
        return {HARNESS: b.replace(honest, decoy)}
    if MODEL_SCRUB in b:  # круг 2: честный scrubber модели расширен паттернами
        return {HARNESS: b.replace(MODEL_SCRUB, decoy)}
    return None

# ------------------------------------------------- мутанты круга 2 (байт-в-байт
# к дефектным ветвям коммита C a9569176c; на дереве без честного входа мутант
# возвращает None → BLOCKED_BY_RED_CONTROL, не NOOP)

DRILL_REL = 'backend/scripts/drill-measure.js'

# честная валидация measured_* (модель) — мутант удаляет её (в C нет проверки)
DRILL_HONEST_VALIDATION = """  for (const k of ['measured_rpo_minutes', 'measured_rto_minutes']) {
    if (!Number.isFinite(parsed[k])) {
      process.stderr.write(`drill: измерение ${k} не число: ${JSON.stringify(parsed[k])}\\n`);
      process.exit(2);
    }
  }
  if (typeof parsed.measured_at !== 'string' || !/^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}/.test(parsed.measured_at)) {
    process.stderr.write(`drill: measured_at не ISO-метка времени: ${JSON.stringify(parsed.measured_at)}\\n`);
    process.exit(2);
  }
"""

# честная запись append-only 'wx' (модель) → C пишет writeFileSync-перезаписью
DRILL_WX_WRITE = """  let fd;
  try {
    fd = fs.openSync(file, 'wx');
  } catch (e) {
    if (e.code === 'EEXIST') {
      process.stderr.write(`drill: ${file} уже существует — evidence append-only, перезапись запрещена\\n`);
      process.exit(1);
    }
    throw e;
  }
  try {
    fs.writeSync(fd, JSON.stringify(payload, null, 2));
  } finally {
    fs.closeSync(fd);
  }"""
DRILL_C_WRITE = "  fs.writeFileSync(file, JSON.stringify(payload, null, 2));"

# валидация mode в captureBeforeAfter (модель) — мутант удаляет её (в C нет)
CBA_MODE_CHECK = """  if (!MODE_LABELS.includes(observation.mode)) {
    throw new Error(
      `mode обязан быть одним из ${MODE_LABELS.join('/')}; получено ${JSON.stringify(observation.mode)}`,
    );
  }
"""

C_CBA_MODE = "    mode: observation.mode || 'RUNTIME',"
MODEL_CBA_MODE = "    mode: observation.mode,"

C_PG18_IMAGE = ('postgres:18@sha256:74935e72241653ca55e0414067e6d8763aceb'
                '8a810eb51b452253ec3dcfc4336')
C_PGDATA_SUBPATH = '      - pgdata:/var/lib/postgresql/data\n'
MODEL_PGDATA = '      - pgdata:/var/lib/postgresql\n'

C_PHANTOM_LINES = (
    '3097d4d3d5722554f171e6b0b09e039c1d2fe5fe07d25b6c5264b8850138a083  '
    'evidence/ux175/20261020T013957.891448Z/results.json',
    '3097d4d3d5722554f171e6b0b09e039c1d2fe5fe07d25b6c5264b8850138a083  '
    'evidence/ux175/20261020T014056.435629Z/results.json',
)

# честный scrubber модели: объявленные секреты raw+JSON-экранированно и паттерны
# Bearer/cookie/email/phone; мутант подменяет функцию целиком на ветвь C.
MODEL_SCRUB = r"""function scrubSecrets(text, secrets) {
  let out = text;
  for (const s of secrets || []) {
    const raw = String(s);
    if (raw.length === 0) continue;
    out = out.split(raw).join('[REDACTED]');
    const escaped = raw
      .replace(/\\/g, '\\\\')
      .replace(/"/g, '\\"')
      .replace(/\n/g, '\\n')
      .replace(/\r/g, '\\r')
      .replace(/\t/g, '\\t');
    out = out.split(escaped).join('[REDACTED]');
  }
  out = out
    .replace(/Bearer\s+[A-Za-z0-9\-._~+/]+=*/g, 'Bearer [REDACTED]')
    .replace(/(cookie"\s*:\s*")([^"]*)(")/g, '$1[REDACTED]$3')
    .replace(/[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}/g, '[REDACTED_EMAIL]')
    .replace(/\+\d[\d\s().\-]{6,}\d/g, '[REDACTED_PHONE]');
  return out;
}"""
C_SCRUB = """function scrubSecrets(text, secrets) {
  let out = text;
  for (const s of secrets || []) out = out.split(String(s)).join('[REDACTED]');
  return out;
}"""


def mut_drill_invalid_input(t):
    """F2: measured_* null/строка принимаются (ветвь C — проверки нет)."""
    b = t.get(DRILL_REL)
    if not need(b) or DRILL_HONEST_VALIDATION not in b:
        return None
    return {DRILL_REL: b.replace(DRILL_HONEST_VALIDATION, '', 1)}


def mut_drill_overwrite(t):
    """F2: повторный прогон перезаписывает измеренный evidence (writeFileSync)."""
    b = t.get(DRILL_REL)
    if not need(b) or DRILL_WX_WRITE not in b:
        return None
    return {DRILL_REL: b.replace(DRILL_WX_WRITE, DRILL_C_WRITE, 1)}


def mut_harness_mode_fabricated(t):
    """F3: вход captureBeforeAfter как в коммите C — валидации mode нет И есть
    фольбэк || 'RUNTIME' (пара ветвей байт-в-байт): без mode пишется RUNTIME."""
    b = t.get(HARNESS)
    if not need(b) or CBA_MODE_CHECK not in b or MODEL_CBA_MODE not in b:
        return None
    b2 = b.replace(CBA_MODE_CHECK, '', 1).replace(MODEL_CBA_MODE, C_CBA_MODE, 1)
    return {HARNESS: b2}


def mut_harness_mock_mode(t):
    """F3: произвольный mode (MOCK_SUCCESS) принимается — валидации нет (C)."""
    b = t.get(HARNESS)
    if not need(b) or CBA_MODE_CHECK not in b:
        return None
    return {HARNESS: b.replace(CBA_MODE_CHECK, '', 1)}


def mut_harness_pii_leak(t):
    """F4: scrubber чистит только объявленные secrets (split/join из C)."""
    b = t.get(HARNESS)
    if not need(b) or MODEL_SCRUB not in b:
        return None
    return {HARNESS: b.replace(MODEL_SCRUB, C_SCRUB, 1)}


def mut_compose_pg18_volume_subpath(t):
    """F1/Б1: том pgdata смонтирован в data-подпуть — PG18 отказывается."""
    b = t.get('backend/compose.dev.yml')
    if not need(b) or MODEL_PGDATA not in b:
        return None
    return {'backend/compose.dev.yml': b.replace(MODEL_PGDATA, C_PGDATA_SUBPATH, 1)}


def mut_compose_migrator_pg_image(t):
    """F1/Б1: migrator на образе postgres:18 без node → exec node exit 127."""
    b = t.get('backend/compose.dev.yml')
    if not need(b):
        return None
    blocks = service_blocks(services_section(b))
    mig = next((n for n in blocks if re.match(r'migrat', n)), None)
    if mig is None:
        return None
    blk = blocks[mig]
    m = re.search(r'^(\s*)image:\s*\S+\s*$', blk, re.M)
    if m is None or 'postgres' in m.group(0):
        return None
    new_blk = blk[:m.start()] + '%simage: %s' % (m.group(1), C_PG18_IMAGE) + blk[m.end():]
    return {'backend/compose.dev.yml': b.replace(blk, new_blk, 1)}


def mut_files_sha256_phantom(t):
    """F5/Б3: строки FILES.sha256 ссылаются на файлы вне коммита."""
    b = t.get('FILES.sha256')
    if not need(b) or C_PHANTOM_LINES[0] in b:
        return None
    sep = '' if b.endswith('\n') else '\n'
    return {'FILES.sha256': b + sep + '\n'.join(C_PHANTOM_LINES) + '\n'}


CASES = [
    ('compose_delete', 'COMPOSE_MISSING', mut_compose_delete),
    ('compose_api_before_migration', 'COMPOSE_API_BEFORE_MIGRATION', mut_api_before_migration),
    ('compose_image_unpinned', 'COMPOSE_IMAGE_UNPINNED', mut_image_unpinned),
    ('compose_prod_dump', 'COMPOSE_PROD_DUMP_MOUNTED', mut_prod_dump),
    ('compose_ddl_secrets', 'COMPOSE_DDL_SECRETS_TO_API', mut_ddl_secrets),
    ('compose_egress_open', 'COMPOSE_EGRESS_OPEN', mut_egress_open),
    ('compose_db_exposed', 'COMPOSE_DB_EXPOSED_UNRESTRICTED', mut_db_exposed),
    ('compose_ephemeral_db', 'COMPOSE_EPHEMERAL_DB', mut_ephemeral_db),
    ('harness_delete', 'HARNESS_MISSING', mut_harness_delete),
    ('harness_overwrite', 'HARNESS_EVIDENCE_OVERWRITES', mut_harness_overwrite),
    ('harness_no_scrubber', 'HARNESS_NO_SCRUBBER', mut_no_scrubber),
    ('harness_no_sql', 'HARNESS_NO_SQL_BEFORE_AFTER', mut_no_sql),
    ('harness_no_role', 'HARNESS_NO_RUNTIME_ROLE', mut_no_role),
    ('harness_no_provider', 'HARNESS_NO_PROVIDER_COUNT', mut_no_provider),
    ('harness_no_hashes', 'HARNESS_NO_MANIFEST_HASHES', mut_no_hashes),
    ('harness_mock_success', 'HARNESS_DB_DOWN_MOCK_SUCCESS', mut_mock_success),
    ('harness_no_mode_label', 'HARNESS_NO_MODE_LABEL', mut_no_mode_label),
    ('harness_axis_drop', 'HARNESS_RECORD_AXIS_TUPLE', mut_axis_drop),
    ('integ_test_delete', 'HARNESS_INTEGRATION_TEST_MISSING', mut_integ_delete),
    ('script_unwire', 'TEST_INTEGRATION_NOT_WIRED', mut_script_unwire),
    ('drill_absent', 'DRILL_MEASUREMENTS_ABSENT', mut_drill_absent),
    ('root_server_delete', 'ROOT_SERVER_PRESENT', mut_root_server_delete),
    ('compose_egress_unused_net', 'COMPOSE_EGRESS_OPEN', mut_egress_unused_net),
    ('drill_dead_file', 'DRILL_EVIDENCE_GUARD', mut_drill_dead_file),
    ('harness_tuple_decoy', 'HARNESS_TUPLE_GUARD', mut_harness_decoy),
    ('harness_sink_decoy', 'HARNESS_TUPLE_GUARD', mut_harness_sink_decoy),
    ('drill_unwired', 'DRILL_MEASUREMENTS_ABSENT', mut_drill_unwired),
    ('harness_mode_collapse', 'HARNESS_TUPLE_GUARD', mut_harness_mode_collapse),
    ('harness_scrubber_identity', 'HARNESS_TUPLE_GUARD', mut_scrubber_identity),
    ('drill_invalid_input', 'DRILL_INPUT_GUARD', mut_drill_invalid_input),
    ('drill_overwrite_evidence', 'DRILL_INPUT_GUARD', mut_drill_overwrite),
    ('harness_mode_fabricated', 'HARNESS_HONESTY_GUARD', mut_harness_mode_fabricated),
    ('harness_mock_mode_accepted', 'HARNESS_HONESTY_GUARD', mut_harness_mock_mode),
    ('harness_pii_leak', 'HARNESS_PII_GUARD', mut_harness_pii_leak),
    ('compose_pg18_volume_subpath', 'STEND_UP_GUARD', mut_compose_pg18_volume_subpath),
    ('compose_migrator_pg_image', 'STEND_UP_GUARD', mut_compose_migrator_pg_image),
    ('files_sha256_phantom', 'FILES_SHA256_GUARD', mut_files_sha256_phantom),
]

# фактов стало десять (круг 2): run_case вызывает ТОЛЬКО целевой факт мутанта,
# не пересчитывая все (живой docker-факт дорогой); семантика прежних целей
# не меняется — те же функции с теми же аргументами.
FACT_FUNCS = {
    'RUNNER_DAMAGE_GUARD': lambda repo, tree: runner_damage_fact(repo, shutil.which('node')),
    'EGRESS_GUARD': egress_fact,
    'DRILL_EVIDENCE_GUARD': drill_fact,
    'HARNESS_TUPLE_GUARD': harness_fact,
    'DRILL_INPUT_GUARD': drill_input_fact,
    'HARNESS_HONESTY_GUARD': harness_honesty_fact,
    'HARNESS_PII_GUARD': harness_pii_fact,
    'STEND_UP_GUARD': stend_up_fact,
    'FILES_SHA256_GUARD': files_sha_fact,
}


def run_case(repo, name, base_fired, base_facts_red):
    entry = next((c for c in CASES if c[0] == name), None)
    if entry is None:
        return {'error': 'EMPTY_SELECTION'}
    _, target, mut = entry
    overlay = mut(Tree(repo))
    if overlay is None:
        return {'name': name, 'target': target, 'applied': False,
                'verdict': 'BLOCKED_BY_RED_CONTROL', 'depends': [],
                'note': 'вход мутации отсутствует (база красна)'}
    tree = Tree(repo, overlay)
    if target == 'ROOT_SERVER_PRESENT':
        newly = {'ROOT_SERVER_PRESENT'} if tree.get('server/test/harness.ts') is None else set()
        newly -= base_facts_red
        return {'name': name, 'target': target, 'applied': True,
                'verdict': 'REJECTED_EXACT' if newly == {'ROOT_SERVER_PRESENT'} else 'NOT_REJECTED',
                'depends': sorted(newly)}
    if target in FACT_FUNCS:
        mut_v = FACT_FUNCS[target](repo, tree)[0]
        newly = {target} if (mut_v is False and target not in base_facts_red) else set()
        return {'name': name, 'target': target, 'applied': True,
                'verdict': 'REJECTED_EXACT' if newly == {target} else 'NOT_REJECTED',
                'depends': sorted(newly)}
    before = {rel: Tree(repo).get(rel) for rel in overlay}
    if all(tree.get(rel) == before[rel] for rel in overlay):
        return {'name': name, 'target': target, 'applied': False,
                'verdict': 'NOOP_MUTATION', 'depends': []}
    fired, _ = subject_control(tree)
    newly = fired - base_fired
    if newly == {target}:
        verdict = 'REJECTED_EXACT'
    elif not newly:
        verdict = 'BLOCKED_BY_RED_CONTROL'
    else:
        verdict = 'NOT_REJECTED'
    return {'name': name, 'target': target, 'applied': True, 'verdict': verdict,
            'depends': sorted(newly)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--out')
    ap.add_argument('--case')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()
    if not (repo / 'backend/package.json').is_file():
        print('%s: REPO_NOT_RESOLVED: нет backend/package.json' % UNMEASURABLE)
        return 2
    base_fired, base_blocked = subject_control(Tree(repo))
    facts = check_facts(repo)
    facts_red = {k for k, (v, _) in facts.items() if v is False}
    facts_none = {k for k, (v, _) in facts.items() if v is None}

    if args.case:
        res = run_case(repo, args.case, base_fired, facts_red)
        if 'error' in res:
            print('%s: EMPTY_SELECTION' % UNMEASURABLE)
            return 2
        out = {'case': res, 'base_fired': sorted(base_fired)}
        print(json.dumps(out, ensure_ascii=False, indent=1))
        if res['verdict'] == 'NOOP_MUTATION':
            print('%s: NOOP_MUTATION' % UNMEASURABLE)
            return 2
        if res['verdict'] not in ('REJECTED_EXACT', 'BLOCKED_BY_RED_CONTROL'):
            return 1
        if facts_none:  # К5: факт None ⇒ rc ≠ 0 (NEEDS_ENV, не зелёный)
            for k in sorted(facts_none):
                print('%s: NEEDS_ENV: %s' % (UNMEASURABLE, facts[k][1]))
            return 2
        return 0

    results = [run_case(repo, n, base_fired, facts_red) for n, _, _ in CASES]
    not_rejected = [r for r in results if r['verdict'] == 'NOT_REJECTED']
    noop = [r for r in results if r['verdict'] == 'NOOP_MUTATION']
    report = {
        'contract': '109',
        'repo': str(repo),
        'control_green': not base_fired and not facts_red and not facts_none,
        'control_red': sorted(base_fired),
        'control_blocked': sorted(base_blocked),
        'facts': {k: {'green': v, 'note': m} for k, (v, m) in facts.items()},
        'cases_total': len(CASES),
        'rejected_exact': sum(r['verdict'] == 'REJECTED_EXACT' for r in results),
        'blocked_by_red_control': sum(r['verdict'] == 'BLOCKED_BY_RED_CONTROL' for r in results),
        'not_rejected': len(not_rejected),
        'cases': results,
    }
    if args.out:
        outdir = Path(args.out)
        outdir.mkdir(parents=True, exist_ok=True)
        (outdir / 'raw.json').write_text(
            json.dumps(report, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    if args.matrix:
        for r in results:
            print('%-28s -> %-24s depends=%s' % (
                r['name'], r['verdict'], ','.join(r.get('depends') or []) or '-'))
    else:
        print(json.dumps({k: v for k, v in report.items() if k != 'cases'},
                         ensure_ascii=False, indent=1))
        print('cases: %d (%d rejected_exact, %d blocked, %d not_rejected)' % (
            len(CASES), report['rejected_exact'], report['blocked_by_red_control'],
            len(not_rejected)))
    if noop:
        print('%s: NOOP_MUTATION: %s' % (UNMEASURABLE, ','.join(r['name'] for r in noop)))
        return 2
    if facts_none:
        for k in sorted(facts_none):
            print('NEEDS_ENV: %s: %s' % (k, facts[k][1]))
    if base_fired:
        print('109 RED: контроль красен: %s' % ','.join(sorted(base_fired)))
        return 1
    if facts_red or not_rejected:
        return 1
    if facts_none:  # К5: контроль не зелен, пока хоть один факт не измерен
        print('%s: NEEDS_ENV: факты не измерены: %s' % (
            UNMEASURABLE, ','.join(sorted(facts_none))))
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
