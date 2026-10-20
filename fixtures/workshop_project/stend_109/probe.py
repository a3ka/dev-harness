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
    return {HARNESS: b.replace(honest, decoy)} if honest in b else None


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
]


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
    if target in ('DRILL_EVIDENCE_GUARD', 'HARNESS_TUPLE_GUARD'):
        mut_v = check_facts(repo, tree)[target][0]
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
