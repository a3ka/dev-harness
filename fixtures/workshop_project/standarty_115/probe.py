#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Батарея контракта 115 (стандарты бэкенда до CMP-BCK-003): перенос выпавших
разделов docs/owner/CODING-STANDARDS.md (снимок 053) в docs/CODING-STANDARDS.md
Complior-back на JavaScript/CommonJS + VM, механизация правил ESLint с КРАСНЫМИ
фикстурами, чеклист ревью и норма судей в AGENTS.md.

Парсер — Python 3 stdlib. Батарея НЕ интерпретирует код: структурный оракул
судит грамматику маркеров (единственный источник — литералы НИЖЕ), живые факты
исполняют предмет (правило 8: ожидания — литералы батареи, не вычисляются кодом
продукта; оракул — в памяти проверяющего). rc: 0 — контроль зелен, все факты
True и каждая клетка отвергнута РОВНО своей причиной; 1 — контроль красен
(честное red на до-предметном B), факт False или клетка не отвергнута; 2 —
UNMEASURABLE / EMPTY_SELECTION / NOOP_MUTATION / NEEDS_ENV.

ГРАММАТИКА МАРКЕРОВ (литералы батареи; смысл доказывают живые факты и судьи):

  docs/CODING-STANDARDS.md — семь разделов-якорей СВОЕЙ строкой (^…$):
    '## 13. Формы объектов и V8'      токены: hidden class, delete,
                                       Object.keys(), дискриминатор
    '## 14. Возвраты и ответственность функций'  токены: consistent-return,
                                       именованными полями, одна задача,
                                       reuse-before-write
    '## 15. Итерация и контекст'      токены: bind, apply, forEach,
                                       complexity, max-depth
    '## 16. Асинхронные паттерны'     токены: async/await, Promise.all,
                                       EventEmitter, AbortSignal, middleware,
                                       RxJS, function*, Deferred, catch {}
    '## 17. Закон Деметры'            токены: Деметр
    '## 18. Conventional Commits'     токены: feat, fix, scope
    '## 19. Чеклист ревью'            токены: параметризованный, PII,
                                       Conventional Commit
    Внутри семи разделов ЗАПРЕЩЕНЫ токены донора (frontend/TS/WorkOS/MetaSQL):
    WorkOS, MetaSQL, Zod, ts-ignore, XState, shadcn, dangerouslySetInnerHTML,
    AISystem.

  eslint.config.js (КОРЕНЬ репозитория, структура по карте консультанта 14:30):
    - `'consistent-return': 'error'`;
    - `complexity: ['error', { max: 40 }]` (40 — забор ИЗМЕРЕН на новой структуре:
      максимум существующего кода 37, server/src/http.js:100; выше забора —
      RULE_FENCE);
    - `'max-depth': ['error', 4]` (4 — измерено: глубже 4 в существующем коде
      нет, на 3 краснеет loader.js);
    - no-restricted-properties с property: 'bind', 'call', 'apply', 'forEach';
    - no-restricted-syntax с селекторами FunctionDeclaration[generator=true],
      FunctionExpression[generator=true], UnaryExpression[operator='delete'];
    - отключение `'no-restricted-properties': 'off'` допустимо ТОЛЬКО в блоке
      `files: ['server/src/logger.js']` (замер: pino logMethod —
      динамический вызов с receiver; все три эквивалента apply/call/
      Reflect.apply под запретом нормы) — шире 15 строк от files-строки
      = OVERRIDE_TOO_WIDE.
    - ОБЛАСТЬ ДЕЙСТВИЯ (v4, блокер критика): глобальный ignores — ЗАКРЫТЫЙ
      литеральный перечень (равенство множеств, лишний/недостающий элемент —
      SCOPE_IGNORE_EXTRA/MISSING): '**/*.obrazec', 'docs/', 'node_modules/',
      'server/infrastructure/', 'tests/historical-server/', 'tests/standards/',
      'tests/structure/fixtures/'. Действие правил на продукте доказывает живой
      факт LINT_SCOPE_COVERED (ниже) — литералы в конфиге не доказывают.

  фикстуры: tests/standards/lint/<имя>/{violation,honest}.js для семи
  имён: consistent-return, complexity, max-depth, no-restricted-syntax-generator,
  no-restricted-syntax-delete, no-restricted-properties-bind-call-apply,
  no-restricted-properties-for-each.

  проводка: раннер tests/tools/check-lint-standards.js; скрипт
  `test:standards-lint` в package.json (КОРЕНЬ); шаг lane `checks` в
  tests/tools/run_backend_ci.py (литерал npm('test:standards-lint')).

  AGENTS.md: строка, содержащая одновременно docs/ARCHITECTURE.md,
  docs/CODING-STANDARDS.md и FAIL (норма судей).

  ЖИВЫЕ ФАКТЫ (правило Ц: вызов командой поставки → суждение по наблюдению):
    BACKEND_LINT_GREEN — `npm run -s lint` в КОРНЕ дерева rc 0:
      новые правила не краснят честный существующий код (замер на новой
      структуре: ровно два действительных нарушения — server/src/logger.js:85
      apply (закрыт узким override) и tests/unit/config.test.js:16
      consistent-return (однострочная честная правка в зоне implementer));
    LINT_FIXTURES_GUARD — три звена:
      (а) команда поставки `npm run -s test:standards-lint` rc 0 и печатает
          `ok <имя>` для всех семи каталогов;
      (б) НЕЗАВИСИМЫЙ прогон eslint самой батареей (--no-ignore --format json):
          violation.js каждого каталога краснеет РОВНО ожидаемым правилом —
          МНОЖЕСТВО ruleIds == {правило} (посторонняя диагностика — тоже
          отказ), honest.js — чист (rc 0);
      (в) проба слепоты: в одноразовой копии вынимается правило
          consistent-return — команда поставки ОБЯЗАНА покраснеть (раннер
          не имеет права молча пропускать фикстуры).
    LINT_SCOPE_CONFIG_EQUAL — ГЕЙТ РАВЕНСТВА ЭФФЕКТИВНОЙ КОНФИГУРАЦИИ (v6,
      Решение 2 арбитража круга 3): область и сила правил судятся не набором
      свидетелей, а РАВЕНСТВОМ: для КАЖДОГО отслеживаемого git .js/.mjs в
      app/, server/, tests/ (минус закрытый перечень ignores) батарея берёт
      ESLint.calculateConfigForFile(файл) настоящего ESLint дерева и
      требует: (1) файл не игнорируется (undefined →
      SCOPE_FILE_IGNORED:<файл>); (2) для каждого правила RULES_115 =
      {consistent-return, complexity, max-depth, no-restricted-properties,
      no-restricted-syntax} нормализованное значение [severity, ...options]
      ДЕСЯТИЧНО-РАВНО каноническому литералу CANON_115[правило] (ключи
      объектов отсортированы, ключ message отброшен — единственное поле без
      поведенческого эффекта; умолчания ESLint 10.13 — часть литерала,
      замерены на модели); (3) linterOptions.noInlineConfig === true,
      processor undefined, plugins == '@', parser espree. Исключения —
      ЗАКРЫТАЯ таблица EXEMPT_115: server/src/logger.js ×
      no-restricted-properties и префикс tests/spec-3.14/ × max-depth —
      severity 0 при ТЕХ ЖЕ опциях; третья пара без нового контракта
      невозможна; включение правила на исключении — SCOPE_EXEMPT_LOST,
      иные опции — DRIFT. ЛЮБОЕ отклонение на любом файле —
      SCOPE_CONFIG_DRIFT:<файл>:<правило|поле> — RED, независимо от формы
      записи (параметры, allow-списки, сужение object, severity warn/off,
      per-file override любого состава, files-сужение, ignores, подмена
      процессора/парсера/плагина); невалидный конфиг (исключение ESLint) —
      SCOPE_CONFIG_INVALID:<файл>.
    LINT_SCOPE_COVERED — свидетели «КАНОН ДЕЙСТВУЕТ» (v6: НЕ ловец
      ослаблений — весь класс ослаблений ловит равенство конфигурации):
      канонический свидетель каждой запрещённой формы (bind/call/apply/
      forEach × идентификатор/Object/this; for..in; генератор-декларация/
      выражение; delete; consistent-return; complexity 41 = max+1, ровно
      40 if; depth 5) линтуется настоящим ESLint (lintText с filePath
      реального файла — конвейер CLI --stdin --stdin-filename) и краснеет
      РОВНО своим правилом severity 2 (без лишних ruleIds); чистый сниппет —
      пусто; /* eslint-disable */ в продуктовом файле — ИНЕРТНА
      (noInlineConfig): доказывает, что КАНОНИЧЕСКАЯ конфигурация на
      настоящем ESLint действительно краснит запрещённые формы и что
      noInlineConfig реально инертизирует директиву. Исключения ровно две
      (см. EXEMPT_115) — свидетели ожидают ИМЕННО молчание своего правила.
      Отказы: SCOPE_FILE_IGNORED, SCOPE_CONFIG_INVALID, SCOPE_BEHAVIOR_
      SILENT/WARN/NOISY, SCOPE_CLEAN_NOISY, SCOPE_INLINE_CONFIG_HONORED,
      SCOPE_EXEMPT_LOST.
    INVALID_MUTANT (rc 2, Решение 3 арбитража круга 3): красная клетка
      обязана исполняться ВАЛИДНО — мутация, после которой ESLint падает на
      валидации конфигурации, не доказывает забор; раннер после мутации
      eslint.config.js валидирует конфиг (calculateConfigForFile одного
      файла области настоящим ESLint дерева) и завершает клетку статусом
      INVALID_MUTANT без права засчитать REJECTED_EXACT.
    NEEDS_ENV (rc 2, честная граница): нет node или node_modules/eslint
    в корне — живые факты не измерены, контроль не зелен.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

PY = sys.executable

SECTIONS = [
    ('## 13. Формы объектов и V8',
     ['hidden class', 'delete', 'Object.keys()', 'дискриминатор']),
    ('## 14. Возвраты и ответственность функций',
     ['consistent-return', 'именованными полями', 'одна задача', 'reuse-before-write']),
    ('## 15. Итерация и контекст',
     ['bind', 'apply', 'forEach', 'complexity', 'max-depth']),
    ('## 16. Асинхронные паттерны',
     ['async/await', 'Promise.all', 'EventEmitter', 'AbortSignal', 'middleware',
      'RxJS', 'function*', 'Deferred', 'catch {}']),
    ('## 17. Закон Деметры', ['Деметр']),
    ('## 18. Conventional Commits', ['feat', 'fix', 'scope']),
    ('## 19. Чеклист ревью', ['параметризованный', 'PII', 'Conventional Commit']),
]
DONOR_TOKENS = ['WorkOS', 'MetaSQL', 'Zod', 'ts-ignore', 'XState', 'shadcn',
                'dangerouslySetInnerHTML', 'AISystem']

RULE_LITERALS = [
    ("'consistent-return': 'error'", 'RULE_ABSENT:consistent-return'),
    ("complexity: ['error', { max: 40 }]", 'RULE_ABSENT:complexity'),
    ("'max-depth': ['error', 4]", 'RULE_ABSENT:max-depth'),
]
RULE_PARTS = [
    ("property: 'bind'", 'RULE_PART_ABSENT:no-restricted-properties/bind'),
    ("property: 'call'", 'RULE_PART_ABSENT:no-restricted-properties/call'),
    ("property: 'apply'", 'RULE_PART_ABSENT:no-restricted-properties/apply'),
    ("property: 'forEach'", 'RULE_PART_ABSENT:no-restricted-properties/forEach'),
]
SELECTORS = [
    ('FunctionDeclaration[generator=true]', 'SELECTOR_ABSENT:generator'),
    ('FunctionExpression[generator=true]', 'SELECTOR_ABSENT:generator'),
    ("UnaryExpression[operator='delete']", 'SELECTOR_ABSENT:delete'),
]
FENCE_COMPLEXITY = 'RULE_FENCE:complexity≠40'
FENCE_MAX_DEPTH = 'RULE_FENCE:max-depth≠4'
OVERRIDE_FILE = "files: ['server/src/logger.js']"
OVERRIDE_OFF = "'no-restricted-properties': 'off'"
OVERRIDE_TOO_WIDE = 'OVERRIDE_TOO_WIDE'

FIXTURE_DIRS = ['consistent-return', 'complexity', 'max-depth',
                'no-restricted-syntax-generator', 'no-restricted-syntax-delete',
                'no-restricted-properties-bind-call-apply',
                'no-restricted-properties-for-each']
RULE_OF_DIR = {
    'consistent-return': 'consistent-return',
    'complexity': 'complexity',
    'max-depth': 'max-depth',
    'no-restricted-syntax-generator': 'no-restricted-syntax',
    'no-restricted-syntax-delete': 'no-restricted-syntax',
    'no-restricted-properties-bind-call-apply': 'no-restricted-properties',
    'no-restricted-properties-for-each': 'no-restricted-properties',
}
RUNNER_REL = os.path.join('tests', 'tools', 'check-lint-standards.js')
WIRED_SCRIPT = '"test:standards-lint": "node tests/tools/check-lint-standards.js"'
ESLINT_REL = 'eslint.config.js'
PJ_REL = 'package.json'
CI_REL = os.path.join('tests', 'tools', 'run_backend_ci.py')

DOC_REL = os.path.join('docs', 'CODING-STANDARDS.md')
WIRED_REASON = 'WIRED_SCRIPT_ABSENT:test:standards-lint'
LANE_TOKEN = "npm('test:standards-lint')"
LANE_REASON = 'LANE_STEP_ABSENT'
AGENTS_REASON = 'AGENTS_SUD_NORMA_ABSENT'
AGENTS_REL = 'AGENTS.md'

# ——— область действия правил (v4: блокер критика — обход через ignores) ———

ALLOWED_IGNORES = ['**/*.obrazec', 'docs/', 'node_modules/', 'server/infrastructure/',
                   'tests/historical-server/', 'tests/standards/',
                   'tests/structure/fixtures/']
SCOPE_DIRS = ('app/', 'server/', 'tests/')
SCOPE_SUFFIXES = ('.js', '.mjs')
SCOPE_IGNORED_PREFIXES = ('server/infrastructure/', 'tests/structure/fixtures/',
                          'tests/standards/', 'tests/historical-server/')
NRP_EXEMPT_FILE = 'server/src/logger.js'
DEPTH_EXEMPT_PREFIX = 'tests/spec-3.14/'
# Якоря мутаций клеток v5 (литералы честного конфига; NOOP, если якорь ушёл):
ANCHOR_LAYER_CONFIGS = '  ...layerConfigs,'
ANCHOR_NRP_OPTIONS = "'no-restricted-properties': [\n    'error',"
ANCHOR_NO_INLINE_CONFIG = '    linterOptions: { noInlineConfig: true },\n'

# Якорь блока no-restricted-properties (литерал честного конфига модели).
ANCHOR_NRP_BLOCK = (
    "  'no-restricted-properties': [\n"
    "    'error',\n"
    "    {\n"
    "      property: 'bind',\n"
    "      message: 'Контекст — через замыкание/arrow (docs/CODING-STANDARDS.md §15)',\n"
    "    },\n"
    "    {\n"
    "      property: 'call',\n"
    "      message: 'Контекст — через замыкание/arrow (docs/CODING-STANDARDS.md §15)',\n"
    "    },\n"
    "    { property: 'apply', message: 'Список аргументов — spread (docs/CODING-STANDARDS.md §15)' },\n"
    "    {\n"
    "      property: 'forEach',\n"
    "      message: 'map/filter/reduce вместо forEach (docs/CODING-STANDARDS.md §15)',\n"
    "    },\n"
    "  ],")

# Целые записи правил (П-3, круг 4: мутант снимает запрет ВАЛИДНО —
# удаляется вся запись, не строка property; обломок { message } без
# property невалиден схемой ESLint и НЕ доказывает забор). Литералы —
# подстроки ANCHOR_NRP_BLOCK (единственный источник), связка проверена
# assert'ом ниже.
NRP_APPLY_ENTRY = (
    "    { property: 'apply', message: 'Список аргументов — spread "
    "(docs/CODING-STANDARDS.md §15)' },\n")
NRP_FOREACH_ENTRY = (
    "    {\n"
    "      property: 'forEach',\n"
    "      message: 'map/filter/reduce вместо forEach (docs/CODING-STANDARDS.md §15)',\n"
    "    },\n")
assert NRP_APPLY_ENTRY in ANCHOR_NRP_BLOCK and NRP_FOREACH_ENTRY in ANCHOR_NRP_BLOCK, \
    'литералы записей разошлись с ANCHOR_NRP_BLOCK'


def nrp_allow_variant(recv):
    """Валидная парная форма allow-списка (Решение 3в арбитража круга 3):
    allowObjects ВНУТРИ записи с property — голая запись без property
    невалидна схемой ESLint 10.13 (замер арбитра З-2)."""
    text = ANCHOR_NRP_BLOCK
    for prop in ('bind', 'call', 'apply', 'forEach'):
        text = text.replace("property: '%s'," % prop,
                            "property: '%s', allowObjects: ['%s']," % (prop, recv))
    return text


def read(repo, rel):
    path = os.path.join(repo, rel)
    with open(path, encoding='utf-8') as handle:
        return handle.read().splitlines()


# ——— структурный контроль ———

def control_reasons(repo):
    reasons = []
    lines = read(repo, DOC_REL)
    spans = {}
    for heading, _tokens in SECTIONS:
        if not any(line.strip() == heading for line in lines):
            reasons.append('DOC_ANCHOR:' + heading)
        else:
            spans[heading] = span_of(lines, heading)
    for heading, tokens in SECTIONS:
        span = spans.get(heading)
        if span is None:
            continue
        for token in tokens:
            if not any(token in line for line in span):
                reasons.append('DOC_SPAN_TOKEN:' + token)
        for token in DONOR_TOKENS:
            if any(token in line for line in span):
                reasons.append('DOC_DONOR_TOKEN:' + token)
    cfg = read(repo, ESLINT_REL)
    joined = '\n'.join(cfg)
    for literal, reason in RULE_LITERALS:
        if literal not in joined:
            reasons.append(reason)
    if "complexity: ['error', { max: " in joined and \
            "complexity: ['error', { max: 40 }]" not in joined:
        reasons.append(FENCE_COMPLEXITY)
    if "'max-depth': ['error'," in joined and "'max-depth': ['error', 4]" not in joined:
        reasons.append(FENCE_MAX_DEPTH)
    for literal, reason in RULE_PARTS:
        if literal not in joined:
            reasons.append(reason)
    for literal, reason in SELECTORS:
        if literal not in joined:
            reasons.append(reason)
    reasons.extend(override_reasons(cfg))
    for name in FIXTURE_DIRS:
        for kind in ('violation.js', 'honest.js'):
            rel = os.path.join('tests', 'standards', 'lint', name, kind)
            if not os.path.isfile(os.path.join(repo, rel)):
                reasons.append('FIXTURE_DIR_ABSENT:' + name)
                break
    if not os.path.isfile(os.path.join(repo, RUNNER_REL)):
        reasons.append('RUNNER_ABSENT')
    if WIRED_SCRIPT not in '\n'.join(read(repo, PJ_REL)):
        reasons.append(WIRED_REASON)
    if LANE_TOKEN not in '\n'.join(read(repo, CI_REL)):
        reasons.append(LANE_REASON)
    if not any('docs/ARCHITECTURE.md' in line and 'docs/CODING-STANDARDS.md' in line
               and 'FAIL' in line for line in read(repo, AGENTS_REL)):
        reasons.append(AGENTS_REASON)
    entries = extract_ignores(joined) or []
    for miss in sorted(set(ALLOWED_IGNORES) - set(entries)):
        reasons.append('SCOPE_IGNORE_MISSING:' + miss)
    for extra in sorted(set(entries) - set(ALLOWED_IGNORES)):
        reasons.append('SCOPE_IGNORE_EXTRA:' + extra)
    return sorted(set(reasons))


def extract_ignores(text):
    """Литеральный массив ignores: [...] из eslint.config.js (закрытая грамматика
    предмета — плоский список строк в кавычках; неспарсиваемое = пусто = RED)."""
    idx = text.find('ignores')
    if idx == -1:
        return None
    start = text.find('[', idx)
    if start == -1:
        return None
    depth = 0
    for i in range(start, len(text)):
        if text[i] == '[':
            depth += 1
        elif text[i] == ']':
            depth -= 1
            if depth == 0:
                return re.findall(r"'([^']+)'", text[start:i + 1])
    return None


def span_of(lines, heading):
    start = next(i for i, line in enumerate(lines) if line.strip() == heading)
    end = len(lines)
    for i in range(start + 1, len(lines)):
        if lines[i].startswith('## '):
            end = i
            break
    return lines[start:end]


def override_reasons(cfg):
    reasons = []
    file_lines = [i for i, line in enumerate(cfg) if OVERRIDE_FILE in line]
    for i, line in enumerate(cfg):
        if OVERRIDE_OFF not in line:
            continue
        if not any(0 <= i - j <= 15 for j in file_lines):
            reasons.append(OVERRIDE_TOO_WIDE)
    return reasons


# ——— живые факты ———

def env_ready(repo):
    if shutil.which('node') is None:
        return False
    return os.path.isdir(os.path.join(repo, 'node_modules', 'eslint'))


def run_cmd(argv, cwd, timeout=240):
    proc = subprocess.run(argv, cwd=cwd, capture_output=True, text=True, timeout=timeout)
    return proc.returncode, proc.stdout + proc.stderr


def fact_lint_green(repo):
    rc, out = run_cmd(['npm', 'run', '-s', 'lint'], repo)
    return rc == 0, out


def fact_fixtures_guard(repo, workdir):
    """Три звена: (а) команда поставки; (б) независимый eslint; (в) проба слепоты."""
    details = []
    # (а)
    rc, out = run_cmd(['npm', 'run', '-s', 'test:standards-lint'], repo)
    if rc != 0:
        details.append('wired_command_rc=' + str(rc))
    for name in FIXTURE_DIRS:
        if 'ok ' + name + ' ' not in out:
            details.append('wired_command_no_ok:' + name)
    # (б) — независимый оракул в памяти проверяющего (правило 8)
    root = repo  # eslint и фикстуры — от корня (новая структура)
    eslint_bin = os.path.join('node_modules', 'eslint', 'bin', 'eslint.js')
    for name in FIXTURE_DIRS:
        expected = RULE_OF_DIR[name]
        for kind in ('violation.js', 'honest.js'):
            rel = os.path.join('tests', 'standards', 'lint', name, kind)
            rc, out = run_cmd(['node', eslint_bin, '--no-ignore', '--format', 'json', rel],
                              root)
            if kind == 'violation.js':
                if rc != 1:
                    details.append('DECOY:violation_not_red:' + name)
                else:
                    try:
                        rule_ids = [m.get('ruleId') for m in json.loads(out)[0]['messages']]
                    except (ValueError, IndexError, KeyError):
                        rule_ids = []
                    if set(rule_ids) != {expected}:
                        details.append('DECOY:violation_not_red:' + name)
            elif rc != 0:
                details.append('DECOY:honest_not_clean:' + name)
    # (в) — проба слепоты: вынуть consistent-return, команда обязана покраснеть
    copy = os.path.join(workdir, 'blindprobe')
    if os.path.isdir(copy):
        shutil.rmtree(copy)
    shutil.copytree(repo, copy, symlinks=True,
                    ignore=shutil.ignore_patterns('node_modules', '.git'))
    os.symlink(os.path.join(repo, 'node_modules'), os.path.join(copy, 'node_modules'))
    cfg_path = os.path.join(copy, 'eslint.config.js')
    with open(cfg_path, encoding='utf-8') as handle:
        text = handle.read()
    patched = re.sub(r"\n\s*'consistent-return': 'error',", '', text)
    with open(cfg_path, 'w', encoding='utf-8') as handle:
        handle.write(patched)
    rc, out = run_cmd(['npm', 'run', '-s', 'test:standards-lint'], copy)
    if rc == 0:
        details.append('DECOY:runner_blind')
    return (not details), details


BEHAVIORAL_PROBE_JS = """'use strict';
// Зонд батареи 115 v5 (поведенческий, правило 8): ИСПОЛНЯЕТ свидетелей
// настоящим ESLint — lintText с filePath реального файла области (тот же
// конвейер, что CLI --stdin --stdin-filename: конфиг, overrides, ignores,
// linterOptions). Зонд только записывает наблюдения; ВСЕ ожидания живут в
// памяти проверяющего (probe.py), не здесь. Живёт в каталоге отчёта батареи,
// НЕ в проверяемом дереве; eslint — из node_modules проверяемого дерева
// (NODE_PATH), cwd — корень проверяемого дерева.
const fs = require('node:fs');
const path = require('node:path');
const { ESLint } = require('eslint');
const repo = process.argv[2];
const spec = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
const eslint = new ESLint({ cwd: repo });
(async () => {
  const out = [];
  for (const entry of spec) {
    const abs = path.join(repo, entry.file);
    const rec = { file: entry.file, ignored: false };
    try {
      rec.ignored = await eslint.isPathIgnored(abs);
    } catch (e) {
      rec.probeError = String(e);
    }
    if (!rec.ignored && !rec.probeError) {
      rec.witnesses = [];
      for (const w of entry.witnesses) {
        // Сломанный конфиг (напр. невалидная запись правила) НЕ должен
        // ронять зонд: свидетель фиксирует сентинел ошибки — правило не
        // запретило форму, классифицирует проверяющий.
        try {
          const res = await eslint.lintText(w.code, { filePath: abs });
          rec.witnesses.push([w.id, w.rule,
            res[0].messages.map((m) => [m.ruleId, m.severity])]);
        } catch (e) {
          rec.witnesses.push([w.id, w.rule, [['<eslint-error>', 2]]]);
        }
      }
    } else if (rec.probeError) {
      rec.witnesses = entry.witnesses.map((w) => [w.id, w.rule,
        [['<eslint-error>', 2]]]);
    }
    out.push(rec);
  }
  fs.writeFileSync(process.argv[4], JSON.stringify(out));
})().catch((e) => { console.error(String(e)); process.exit(3); });
"""


def scoped_files(repo):
    """Отслеживаемые .js/.mjs области app/, server/, tests/ минус разрешённые
    игноры. git ls-files — первичный источник; фолбэк — обход диска (копии
    клеток без .git)."""
    rc, out = run_cmd(['git', 'ls-files'], repo)
    if rc == 0 and out.strip():
        candidates = out.splitlines()
    else:
        candidates = []
        for base in SCOPE_DIRS:
            for dirpath, dirnames, filenames in os.walk(os.path.join(repo, base)):
                rel_dir = os.path.relpath(dirpath, repo).replace(os.sep, '/')
                dirnames[:] = [d for d in dirnames
                               if not (rel_dir + '/' + d + '/').startswith(
                                   SCOPE_IGNORED_PREFIXES)]
                for fn in filenames:
                    candidates.append(rel_dir + '/' + fn)
    files = []
    for rel in candidates:
        if not rel.endswith(SCOPE_SUFFIXES):
            continue
        if not rel.startswith(SCOPE_DIRS):
            continue
        if rel.startswith(SCOPE_IGNORED_PREFIXES):
            continue
        files.append(rel)
    return sorted(set(files))


# Граничный свидетель complexity = max+1 = 41 (ровно 40 if; П-4 арбитража
# круга 3: прежние 41 if давали complexity 42 и не различали заборы 40/41).
COMPLEXITY_BODY = '\n'.join('  if (a === %d) { r += %d; }' % (i, i)
                           for i in range(40))
MAX_DEPTH_BODY = (
    '  if (a > 0) {\n    if (a > 1) {\n      if (a > 2) {\n        if (a > 3) {\n'
    '          if (a > 4) {\n            return 1;\n          }\n          return 2;\n'
    '        }\n        return 3;\n      }\n      return 4;\n    }\n    return 5;\n'
    '  }\n  return 6;\n')


def build_witnesses():
    """Единый источник свидетелей области (правило 8: ожидания — литералы
    батареи, не вычисляются кодом продукта). Каждый сниппет спроектирован
    давать РОВНО одну диагностику своего правила severity 2 на честном
    конфиге; чистый сниппет — пусто (замер на модели v5; для .mjs-целей
    пролог 'use strict' не добавляется — правило strict ругается на
    директиву в module-source). Форма: (id, правило, тело, disable-проба)."""
    wits = [('clean', None,
             'function probe(scope) {\n  return scope;\n}\nmodule.exports = probe;\n',
             False)]
    wits.append(('consistent-return', 'consistent-return',
                 'function probe(a) {\n  if (a > 0) {\n    return 1;\n  }\n}\n'
                 'module.exports = probe;\n', False))
    wits.append(('complexity', 'complexity',
                 'function probe(a) {\n  let r = 0;\n%s\n  return r;\n}\n'
                 'module.exports = probe;\n' % COMPLEXITY_BODY, False))
    wits.append(('max-depth', 'max-depth',
                 'function probe(a) {\n%s}\nmodule.exports = probe;\n'
                 % MAX_DEPTH_BODY, False))
    for prop in ('bind', 'call', 'apply'):
        for kind, recv, arg in (('param', 'scope', 'scope'), ('object', 'Object', None),
                                ('this', 'this', None)):
            sig = '(scope)' if arg else '()'
            wits.append(('nrp/%s/%s' % (prop, kind), 'no-restricted-properties',
                         'function probe%s {\n  return %s.%s(null);\n}\n'
                         'module.exports = probe;\n' % (sig, recv, prop), False))
    for kind, recv, arg in (('param', 'scope', True), ('object', 'Object', False),
                            ('this', 'this', False)):
        sig = '(scope)' if arg else '()'
        wits.append(('nrp/forEach/%s' % kind, 'no-restricted-properties',
                     'function probe%s {\n  %s.forEach((_item) => 1);\n  return %s;\n'
                     '}\nmodule.exports = probe;\n' % (sig, recv, recv), False))
    wits.append(('nrs/for-in', 'no-restricted-syntax',
                 'function probe(item) {\n  for (const key in item) {\n    return key;\n'
                 '  }\n  return null;\n}\nmodule.exports = probe;\n', False))
    wits.append(('nrs/gen-decl', 'no-restricted-syntax',
                 'function* genProbe() {\n  yield 1;\n}\nmodule.exports = genProbe;\n',
                 False))
    wits.append(('nrs/gen-expr', 'no-restricted-syntax',
                 'const makeGen = function* () {\n  yield 1;\n};\n'
                 'module.exports = makeGen;\n', False))
    wits.append(('nrs/delete', 'no-restricted-syntax',
                 'function probe(obj) {\n  delete obj.field;\n  return obj;\n}\n'
                 'module.exports = probe;\n', False))
    # disable-пробы: /* eslint-disable <правило> */ в продуктовом файле обязана
    # быть ИНЕРТНОЙ (linterOptions.noInlineConfig) — вердикт не меняется.
    for wid, rule, body, _dis in list(wits):
        if wid in ('consistent-return', 'complexity', 'max-depth',
                   'nrp/bind/param', 'nrs/for-in'):
            wits.append(('dis/' + wid, rule, body, True))
    return wits


def _expect_silent(rel, rule):
    """Два названных честных исключения: свидетели ожидают молчание правила."""
    if rule == 'no-restricted-properties' and rel == NRP_EXEMPT_FILE:
        return True
    if rule == 'max-depth' and rel.startswith(DEPTH_EXEMPT_PREFIX):
        return True
    return False


def fact_scope_covered(repo, workdir):
    """LINT_SCOPE_COVERED (v6, Решение 2 арбитража круга 3): свидетели
    «КАНОН ДЕЙСТВУЕТ» — НЕ ловец ослаблений (ослабления ловит
    LINT_SCOPE_CONFIG_EQUAL). Каждый файл области НЕ игнорируется, и
    настоящий ESLint краснеет на каждом свидетеле РОВНО его правилом
    severity 2; чистый сниппет пуст; eslint-disable-директива инертна.
    Исключения ровно две: logger.js — no-restricted-properties,
    tests/spec-3.14/** — max-depth."""
    files = scoped_files(repo)
    if not files:
        return False, ['SCOPE_EMPTY_FILESET']
    spec = []
    for rel in files:
        mjs = rel.endswith('.mjs')
        entry = {'file': rel, 'witnesses': []}
        for wid, rule, body, dis in build_witnesses():
            code = body if mjs else "'use strict';\n" + body
            if dis:
                code = '/* eslint-disable %s */\n%s' % (rule, code)
            entry['witnesses'].append({'id': wid, 'rule': rule, 'code': code})
        spec.append(entry)
    probe = os.path.join(workdir, 'scope_probe.js')
    with open(probe, 'w', encoding='utf-8') as handle:
        handle.write(BEHAVIORAL_PROBE_JS)
    spec_json = os.path.join(workdir, 'scope_spec.json')
    with open(spec_json, 'w', encoding='utf-8') as handle:
        json.dump(spec, handle)
    out_json = os.path.join(workdir, 'scope_out.json')
    env = dict(os.environ)
    env['NODE_PATH'] = os.path.join(repo, 'node_modules')
    proc = subprocess.run(['node', probe, os.path.abspath(repo), spec_json, out_json],
                          cwd=repo, capture_output=True, text=True, timeout=600,
                          env=env)
    if proc.returncode != 0 or not os.path.isfile(out_json):
        return False, ['SCOPE_PROBE_FAILED:rc=' + str(proc.returncode)]
    with open(out_json, encoding='utf-8') as handle:
        records = json.load(handle)
    details = []
    fail_log = []
    ignored = [r['file'] for r in records if r.get('ignored')]
    for f in ignored[:5]:
        details.append('SCOPE_FILE_IGNORED:' + f)
    for rec in records:
        rel = rec['file']
        if rec.get('ignored'):
            continue
        for wid, rule, msgs in rec.get('witnesses', []):
            if any(m[0] == '<eslint-error>' for m in msgs):
                # Решение 3а: сломанный конфиг — ОТДЕЛЬНЫЙ токен, не SILENT
                fail_log.append([rel, wid, msgs])
                details.append('SCOPE_CONFIG_INVALID:' + rel)
                continue
            dis = wid.startswith('dis/')
            if rule is None:  # чистый сниппет: пусто на любом файле области
                if msgs:
                    fail_log.append([rel, wid, msgs])
                    extra = next((m[0] for m in msgs if m[0] is not None), 'null')
                    details.append('SCOPE_CLEAN_NOISY:' + str(extra))
                continue
            if _expect_silent(rel, rule):
                if dis:
                    continue  # исключение + директива: не наблюдаемо
                if msgs:
                    fail_log.append([rel, wid, msgs])
                    details.append('SCOPE_EXEMPT_LOST:' + rule)
                continue
            # Своё правило судят ЕГО сообщения; null-ruleId сообщения на
            # dis-пробах — ожидаемый артефакт noInlineConfig (ESLint 10
            # репортит проигнорированные директивы предупреждением).
            named = [m for m in msgs if m[0] is not None]
            rule_ids = sorted({m[0] for m in named}, key=str)
            own = [m for m in named if m[0] == rule]
            others = [m for m in named if m[0] != rule]
            if not own:
                fail_log.append([rel, wid, msgs])
                details.append(
                    ('SCOPE_INLINE_CONFIG_HONORED:' if dis
                     else 'SCOPE_BEHAVIOR_SILENT:') + rule)
            elif any(m[1] != 2 for m in own):
                fail_log.append([rel, wid, msgs])
                details.append('SCOPE_BEHAVIOR_WARN:' + rule)
            elif others or (not dis and len(named) != len(msgs)):
                fail_log.append([rel, wid, msgs])
                details.append('SCOPE_BEHAVIOR_NOISY:' + rule)
    with open(os.path.join(workdir, 'scope_fail_log.json'), 'w',
              encoding='utf-8') as handle:
        json.dump(fail_log, handle, ensure_ascii=False)
    return (not details), sorted(set(details))

# ——— гейт равенства эффективной конфигурации (v6, Решение 2) ———

CFG_EQUAL_PROBE_JS = """'use strict';
// Зонд батареи 115 v6 (гейт равенства конфигурации, Решение 2 арбитража
// круга 3): ESLint.calculateConfigForFile настоящего ESLint дерева на
// КАЖДОМ файле области против канонических литералов батареи (CANON_115 /
// EXEMPT_115 ниже — правило 8: ожидания в коде батареи, не в проверяемом
// дереве). Зонд печатает JSON {files, ok, details}; суждение — probe.py.
const fs = require('node:fs');
const { ESLint } = require('eslint');
const repo = process.argv[2];
const files = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
const RULES_115 = ['consistent-return', 'complexity', 'max-depth',
  'no-restricted-properties', 'no-restricted-syntax'];
const CANON_115 = {
  'consistent-return': [2, { treatUndefinedAsUnspecified: false }],
  complexity: [2, { max: 40 }],
  'max-depth': [2, 4],
  'no-restricted-properties': [2, { property: 'bind' }, { property: 'call' },
    { property: 'apply' }, { property: 'forEach' }],
  'no-restricted-syntax': [2, { selector: 'ForInStatement' },
    { selector: 'FunctionDeclaration[generator=true]' },
    { selector: 'FunctionExpression[generator=true]' },
    { selector: "UnaryExpression[operator='delete']" }],
};
// Закрытая таблица исключений: пара (файл|префикс, правило) -> severity 0
// при ТЕХ ЖЕ опциях; третья пара без нового контракта невозможна.
const EXEMPT_115 = [
  { file: 'server/src/logger.js', prefix: false, rule: 'no-restricted-properties' },
  { file: 'tests/spec-3.14/', prefix: true, rule: 'max-depth' },
];
function exemptOf(file, rule) {
  return EXEMPT_115.some((e) => e.rule === rule
    && (e.prefix ? file.startsWith(e.file) : file === e.file));
}
// Стабильное представление: ключи объектов отсортированы, ключ message
// отброшен (единственное поле без поведенческого эффекта).
function stable(v, dropMessage) {
  if (Array.isArray(v)) return '[' + v.map((x) => stable(x, dropMessage)).join(',') + ']';
  if (v && typeof v === 'object') {
    return '{' + Object.keys(v).sort().filter((k) => !(dropMessage && k === 'message'))
      .map((k) => JSON.stringify(k) + ':' + stable(v[k], dropMessage)).join(',') + '}';
  }
  return JSON.stringify(v);
}
const canonOf = (rule) => stable(CANON_115[rule], true);
(async () => {
  const details = [];
  for (const f of files) {
    let c;
    try {
      c = await new ESLint({ cwd: repo }).calculateConfigForFile(f);
    } catch (e) {
      details.push('SCOPE_CONFIG_INVALID:' + f + ':' + String(e).split('\\n')[0].slice(0, 100));
      continue;
    }
    if (!c) { details.push('SCOPE_FILE_IGNORED:' + f); continue; }
    for (const rule of RULES_115) {
      const actual = stable(c.rules[rule], true);
      if (exemptOf(f, rule)) {
        const sev = Array.isArray(c.rules[rule]) ? c.rules[rule][0] : undefined;
        if (sev !== 0) { details.push('SCOPE_EXEMPT_LOST:' + rule + ':' + f); continue; }
        const want = '[0' + canonOf(rule).slice(2);
        if (actual !== want) details.push('SCOPE_CONFIG_DRIFT:' + f + ':' + rule);
        continue;
      }
      if (actual !== canonOf(rule)) details.push('SCOPE_CONFIG_DRIFT:' + f + ':' + rule);
    }
    if (!c.linterOptions || c.linterOptions.noInlineConfig !== true)
      details.push('SCOPE_CONFIG_DRIFT:' + f + ':linterOptions.noInlineConfig');
    if (c.processor !== undefined) details.push('SCOPE_CONFIG_DRIFT:' + f + ':processor');
    const plugins = Object.keys(c.plugins || {}).sort().join(',');
    if (plugins !== '@') details.push('SCOPE_CONFIG_DRIFT:' + f + ':plugins=' + plugins);
    const pn = c.languageOptions && c.languageOptions.parser
      && (c.languageOptions.parser.name || (c.languageOptions.parser.meta || {}).name);
    if (pn !== 'espree') details.push('SCOPE_CONFIG_DRIFT:' + f + ':languageOptions.parser=' + pn);
  }
  console.log(JSON.stringify({ files: files.length, ok: details.length === 0,
    details: [...new Set(details)].sort() }));
  process.exit(details.length === 0 ? 0 : 1);
})();
"""


CONFIG_VALIDATE_JS = """'use strict';
// Валидация мутанта (Решение 3б): calculateConfigForFile одного файла
// области настоящим ESLint дерева; исключение = конфиг невалиден.
const { ESLint } = require('eslint');
new ESLint({ cwd: process.argv[2] })
  .calculateConfigForFile(process.argv[3])
  .then(() => process.exit(0))
  .catch(() => process.exit(1));
"""


def fact_scope_config_equal(repo, workdir):
    """LINT_SCOPE_CONFIG_EQUAL (v6, Решение 2 арбитража круга 3): равенство
    эффективной конфигурации ESLint каноническому литералу на КАЖДОМ файле
    области — дедуктивный ловец класса «валидное ослабление любой формы»."""
    files = scoped_files(repo)
    if not files:
        return False, ['SCOPE_EMPTY_FILESET']
    probe = os.path.join(workdir, 'cfg_probe.js')
    with open(probe, 'w', encoding='utf-8') as handle:
        handle.write(CFG_EQUAL_PROBE_JS)
    files_json = os.path.join(workdir, 'cfg_files.json')
    with open(files_json, 'w', encoding='utf-8') as handle:
        json.dump(files, handle)
    env = dict(os.environ)
    env['NODE_PATH'] = os.path.join(repo, 'node_modules')
    proc = subprocess.run(['node', probe, os.path.abspath(repo), files_json],
                          cwd=repo, capture_output=True, text=True, timeout=300,
                          env=env)
    try:
        payload = json.loads(proc.stdout.strip().splitlines()[-1])
        details = sorted(set(str(d) for d in payload.get('details', [])))
    except (ValueError, IndexError):
        return False, ['SCOPE_CFG_PROBE_FAILED:rc=' + str(proc.returncode)]
    return (not details), details


def validate_config(repo, workdir):
    """(invalid, msg): конфиг дерева после мутации невалиден для ESLint."""
    files = scoped_files(repo)
    if not files:
        return False, ''
    probe = os.path.join(workdir, 'cfg_validate.js')
    with open(probe, 'w', encoding='utf-8') as handle:
        handle.write(CONFIG_VALIDATE_JS)
    env = dict(os.environ)
    env['NODE_PATH'] = os.path.join(repo, 'node_modules')
    proc = subprocess.run(['node', probe, os.path.abspath(repo), files[0]],
                          cwd=repo, capture_output=True, text=True, timeout=120,
                          env=env)
    return proc.returncode != 0, 'eslint config invalid (Решение 3)'


def mutation_touches_config(spec):
    kind = spec[0]
    rel_at = {'replace': 1, 're_sub': 1, 'drop_line_with': 1,
              'append': 1, 'overwrite': 1}.get(kind)
    return rel_at is not None and spec[rel_at] == ESLINT_REL


# ——— клетки ———

def cases():
    return [
        ('doc_anchor_drop_13', 'control', ('doc', SECTIONS[0][0],
                                            'DOC_ANCHOR:' + SECTIONS[0][0])),
        ('doc_anchor_drop_14', 'control', ('doc', SECTIONS[1][0],
                                            'DOC_ANCHOR:' + SECTIONS[1][0])),
        ('doc_anchor_drop_15', 'control', ('doc', SECTIONS[2][0],
                                            'DOC_ANCHOR:' + SECTIONS[2][0])),
        ('doc_anchor_drop_16', 'control', ('doc', SECTIONS[3][0],
                                            'DOC_ANCHOR:' + SECTIONS[3][0])),
        ('doc_anchor_drop_17', 'control', ('doc', SECTIONS[4][0],
                                            'DOC_ANCHOR:' + SECTIONS[4][0])),
        ('doc_anchor_drop_18', 'control', ('doc', SECTIONS[5][0],
                                            'DOC_ANCHOR:' + SECTIONS[5][0])),
        ('doc_anchor_drop_19', 'control', ('doc', SECTIONS[6][0],
                                            'DOC_ANCHOR:' + SECTIONS[6][0])),
        ('doc_span_token_gut', 'control', ('replace', DOC_REL, 'async/await', 'async await',
                                            'DOC_SPAN_TOKEN:async/await')),
        ('doc_donor_token', 'control', ('append', DOC_REL,
                                        '\nИнтеграция WorkOS и Zod не переносится.\n',
                                        'DOC_DONOR_TOKEN:WorkOS')),
        ('rule_drop_consistent_return', 'control',
         ('re_sub', ESLINT_REL, r"\n\s*'consistent-return': 'error',",
          'RULE_ABSENT:consistent-return')),
        ('rule_drop_complexity', 'control',
         ('replace', ESLINT_REL, "complexity: ['error', { max: 40 }],", '',
          'RULE_ABSENT:complexity')),
        ('rule_drop_max_depth', 'control',
         ('replace', ESLINT_REL, "'max-depth': ['error', 4],", '',
          'RULE_ABSENT:max-depth')),
        ('rule_drop_nrp_apply', 'control',
         ('replace', ESLINT_REL, NRP_APPLY_ENTRY, '',
          'RULE_PART_ABSENT:no-restricted-properties/apply')),
        ('rule_drop_nrp_foreach', 'control',
         ('replace', ESLINT_REL, NRP_FOREACH_ENTRY, '',
          'RULE_PART_ABSENT:no-restricted-properties/forEach')),
        ('rule_selector_drop_generator', 'control',
         ('replace', ESLINT_REL, 'FunctionDeclaration[generator=true]',
          'FunctionDeclaration[generator=false]', 'SELECTOR_ABSENT:generator')),
        ('rule_selector_drop_delete', 'control',
         ('replace', ESLINT_REL, "UnaryExpression[operator='delete']",
          "UnaryExpression[operator='delete2']", 'SELECTOR_ABSENT:delete')),
        ('rule_fence_complexity', 'control',
         ('replace', ESLINT_REL, 'max: 40', 'max: 400', FENCE_COMPLEXITY)),
        ('rule_fence_max_depth', 'control',
         ('replace', ESLINT_REL, "'max-depth': ['error', 4]",
          "'max-depth': ['error', 40]", FENCE_MAX_DEPTH)),
        ('fixture_dir_delete', 'control',
         ('rmtree', os.path.join('tests', 'standards', 'lint',
                                 'no-restricted-properties-for-each'),
          'FIXTURE_DIR_ABSENT:no-restricted-properties-for-each')),
        ('runner_delete', 'control', ('unlink', RUNNER_REL, 'RUNNER_ABSENT')),
        ('script_unwire', 'control',
         ('drop_line_with', PJ_REL, 'test:standards-lint', WIRED_REASON)),
        ('lane_step_remove', 'control',
         ('drop_line_with', CI_REL, "npm('test:standards-lint')", LANE_REASON)),
        ('agents_norm_remove', 'control',
         ('drop_line_with', AGENTS_REL, 'docs/CODING-STANDARDS.md', AGENTS_REASON)),
        ('override_widen', 'control',
         ('replace', ESLINT_REL, OVERRIDE_FILE, "files: ['**/*.js']",
          OVERRIDE_TOO_WIDE)),
        ('decoy_violation_tamed', 'LINT_FIXTURES_GUARD',
         ('overwrite', os.path.join('tests', 'standards', 'lint',
                                    'consistent-return', 'violation.js'),
          HONEST_CONSISTENT, 'DECOY:violation_not_red:consistent-return')),
        ('decoy_honest_dirty', 'LINT_FIXTURES_GUARD',
         ('overwrite', os.path.join('tests', 'standards', 'lint',
                                    'consistent-return', 'honest.js'),
          VIOLATING_CONSISTENT, 'DECOY:honest_not_clean:consistent-return')),
        ('runner_blind', 'LINT_FIXTURES_GUARD',
         ('replace', RUNNER_REL, '!isExactly(ruleIds, expected)', 'false',
          'DECOY:runner_blind')),
        ('scope_ignore_add_server', 'control',
         ('replace', ESLINT_REL, "'server/infrastructure/',",
          "'server/infrastructure/',\n      'server/',",
          'SCOPE_IGNORE_EXTRA:server/')),
        ('scope_ignore_add_app', 'control',
         ('replace', ESLINT_REL, "'server/infrastructure/',",
          "'server/infrastructure/',\n      'app/',",
          'SCOPE_IGNORE_EXTRA:app/')),
        ('scope_ignore_add_tests', 'control',
         ('replace', ESLINT_REL, "'server/infrastructure/',",
          "'server/infrastructure/',\n      'tests/',",
          'SCOPE_IGNORE_EXTRA:tests/')),
        ('scope_ignore_add_server_src', 'control',
         ('replace', ESLINT_REL, "'server/infrastructure/',",
          "'server/infrastructure/',\n      'server/src/',",
          'SCOPE_IGNORE_EXTRA:server/src/')),
        ('scope_override_rules_off', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, OVERRIDE_FILE + ',',
          "files: ['server/src/**'],\n"
          "      rules: { 'consistent-return': 'off', complexity: 'off', "
          "'max-depth': 'off', 'no-restricted-properties': 'off', "
          "'no-restricted-syntax': 'off' },\n"
          "    },\n"
          "    {\n"
          "      " + OVERRIDE_FILE + ',',
          'SCOPE_CONFIG_DRIFT:server/src/http.js:complexity')),
        ('scope_files_narrow', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, "files: ['**/*.js'],", "files: ['app/**/*.js'],",
          'SCOPE_CONFIG_DRIFT:server/src/http.js:consistent-return')),
        ('scope_param_weaken', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, OVERRIDE_FILE + ',',
          "files: ['server/**/*.js', 'server/**/*.mjs'],\n"
          "      rules: { complexity: ['error', { max: 400 }] },\n"
          "    },\n"
          "    {\n"
          "      " + OVERRIDE_FILE + ',',
          'SCOPE_CONFIG_DRIFT:server/src/http.js:complexity')),
        ('scope_override_rules_off_tests_unit', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, ANCHOR_LAYER_CONFIGS,
          "  {\n"
          "    files: ['tests/unit/**/*.js'],\n"
          "    rules: { 'consistent-return': 'off', complexity: 'off', "
          "'max-depth': 'off', 'no-restricted-properties': 'off', "
          "'no-restricted-syntax': 'off' },\n"
          "  },\n"
          + ANCHOR_LAYER_CONFIGS,
          'SCOPE_CONFIG_DRIFT:tests/unit/config.test.js:consistent-return')),
        ('scope_bypass_object', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, ANCHOR_LAYER_CONFIGS,
          "  {\n"
          "    files: ['app/**/*.js', 'server/**/*.js', 'tests/unit/**/*.js'],\n"
          "    rules: {\n"
          "      'no-restricted-properties': ['error',\n"
          "        { object: 'Object', property: 'bind' },\n"
          "        { object: 'Object', property: 'call' },\n"
          "        { object: 'Object', property: 'apply' },\n"
          "        { object: 'Object', property: 'forEach' }],\n"
          "    },\n"
          "  },\n"
          + ANCHOR_LAYER_CONFIGS,
          'SCOPE_CONFIG_DRIFT:app/config/database.js:no-restricted-properties')),
        ('scope_allow_objects', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, ANCHOR_NRP_BLOCK, nrp_allow_variant('scope'),
          'SCOPE_CONFIG_DRIFT:app/config/database.js:no-restricted-properties')),
        ('scope_severity_warn', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, ANCHOR_LAYER_CONFIGS,
          "  {\n"
          "    files: ['app/**/*.js', 'server/**/*.js', 'tests/unit/**/*.js'],\n"
          "    rules: { 'no-restricted-properties': 'warn' },\n"
          "  },\n"
          + ANCHOR_LAYER_CONFIGS,
          'SCOPE_CONFIG_DRIFT:app/config/database.js:no-restricted-properties')),
        ('scope_inline_config', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, ANCHOR_NO_INLINE_CONFIG, '',
          'SCOPE_CONFIG_DRIFT:app/config/database.js:linterOptions.noInlineConfig')),
        ('scope_boundary41', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, ANCHOR_LAYER_CONFIGS,
          "  {\n    files: ['server/src/http.js'],\n"
          "    rules: { complexity: ['error', { max: 41 }] },\n"
          "  },\n" + ANCHOR_LAYER_CONFIGS,
          'SCOPE_CONFIG_DRIFT:server/src/http.js:complexity')),
        ('scope_allow_objects_client', 'LINT_SCOPE_CONFIG_EQUAL',
         ('replace', ESLINT_REL, ANCHOR_NRP_BLOCK, nrp_allow_variant('client'),
          'SCOPE_CONFIG_DRIFT:app/config/database.js:no-restricted-properties')),
    ]


HONEST_CONSISTENT = """'use strict';

// Честно: каждая ветвь возвращает объект одной формы.
const statusOf = (score) => {
  if (score >= 100) {
    return { ok: true };
  }
  return { ok: false };
};

module.exports = { statusOf };
"""

VIOLATING_CONSISTENT = """'use strict';

// Нарушение: на одном пути — объект, на другом — возврата нет (consistent-return).
const statusOf = (score) => {
  if (score >= 100) {
    return { ok: true };
  }
};

module.exports = { statusOf };
"""


def apply_mutation(repo, spec):
    """Возвращает (ok, msg): ok=False — якорь мутации не найден (NOOP)."""
    kind = spec[0]
    if kind == 'doc':
        rel, heading = DOC_REL, spec[1]
        path = os.path.join(repo, rel)
        with open(path, encoding='utf-8') as handle:
            lines = handle.read().splitlines()
        if not any(line.strip() == heading for line in lines):
            return False, 'нет якоря ' + heading
        out = [line for line in lines if line.strip() != heading]
        with open(path, 'w', encoding='utf-8') as handle:
            handle.write('\n'.join(out) + '\n')
        return True, ''
    if kind == 'replace':
        _, rel, old, new, _reason = spec
        path = os.path.join(repo, rel)
        with open(path, encoding='utf-8') as handle:
            text = handle.read()
        if old not in text:
            return False, 'нет якоря ' + old
        with open(path, 'w', encoding='utf-8') as handle:
            handle.write(text.replace(old, new))
        return True, ''
    if kind == 're_sub':
        _, rel, pattern, _reason = spec
        path = os.path.join(repo, rel)
        with open(path, encoding='utf-8') as handle:
            text = handle.read()
        patched = re.sub(pattern, '', text)
        if patched == text:
            return False, 'нет якоря ' + pattern
        with open(path, 'w', encoding='utf-8') as handle:
            handle.write(patched)
        return True, ''
    if kind == 'drop_line_with':
        _, rel, needle, _reason = spec
        path = os.path.join(repo, rel)
        with open(path, encoding='utf-8') as handle:
            lines = handle.read().splitlines()
        kept = [line for line in lines if needle not in line]
        if len(kept) == len(lines):
            return False, 'нет якоря ' + needle
        with open(path, 'w', encoding='utf-8') as handle:
            handle.write('\n'.join(kept) + '\n')
        return True, ''
    if kind == 'append':
        _, rel, tail, _reason = spec
        path = os.path.join(repo, rel)
        with open(path, encoding='utf-8') as handle:
            text = handle.read()
        with open(path, 'w', encoding='utf-8') as handle:
            handle.write(text + tail)
        return True, ''
    if kind == 'rmtree':
        _, rel, _reason = spec
        path = os.path.join(repo, rel)
        if not os.path.isdir(path):
            return False, 'нет каталога ' + rel
        shutil.rmtree(path)
        return True, ''
    if kind == 'unlink':
        _, rel, _reason = spec
        path = os.path.join(repo, rel)
        if not os.path.isfile(path):
            return False, 'нет файла ' + rel
        os.unlink(path)
        return True, ''
    if kind == 'overwrite':
        _, rel, content, _reason = spec
        path = os.path.join(repo, rel)
        with open(path, 'w', encoding='utf-8') as handle:
            handle.write(content)
        return True, ''
    return False, 'неизвестная мутация ' + kind


def judge_cell(base_repo, workdir, name, depends, spec):
    copy = os.path.join(workdir, 'case-' + name)
    if os.path.isdir(copy):
        shutil.rmtree(copy)
    ignored = shutil.ignore_patterns('node_modules')
    shutil.copytree(base_repo, copy, symlinks=True, ignore=ignored)
    src_nm = os.path.join(base_repo, 'node_modules')
    if os.path.isdir(src_nm):
        os.symlink(src_nm, os.path.join(copy, 'node_modules'))
    ok, msg = apply_mutation(copy, spec)
    if not ok:
        return 'NOOP', msg
    # П-3 (класс; круг 4, вердикт критика): клетка, чья мутация правит
    # eslint.config.js, обязана валидно исполняться ДО ЛЮБОГО зачёта —
    # структурного в том числе: невалидный конфиг даёт INVALID_MUTANT (rc 2)
    # без права REJECTED_EXACT (Решение 3б арбитража круга 3).
    if mutation_touches_config(spec):
        if not env_ready(base_repo):
            return 'BLOCKED_ENV', 'NEEDS_ENV'
        invalid, _msg = validate_config(copy, workdir)
        if invalid:
            # Решение 3б: невалидный мутант не доказывает забор — rc 2
            return 'INVALID_MUTANT', 'eslint config invalid (Решение 3)'
    reason = spec[-1]
    red = control_reasons(copy)
    if reason in red:
        return 'REJECTED_EXACT', reason
    fact_of = {'LINT_FIXTURES_GUARD': fact_fixtures_guard,
               'LINT_SCOPE_COVERED': fact_scope_covered,
               'LINT_SCOPE_CONFIG_EQUAL': fact_scope_config_equal}
    if depends in fact_of:
        ok_fact, details = fact_of[depends](copy, workdir)
        if not ok_fact and reason in details:
            return 'REJECTED_EXACT', reason
        return 'NOT_REJECTED', 'live:' + ';'.join(details[:4])
    return 'NOT_REJECTED', 'red=' + ','.join(red[:4])


def case_names():
    return [name for name, _depends, _spec in cases()]


def main():
    ap = argparse.ArgumentParser(description='Батарея контракта 115 (стандарты бэкенда)')
    ap.add_argument('--repo', required=True, help='checkout Complior-back (B или C)')
    ap.add_argument('--out', required=True, help='каталог отчёта')
    ap.add_argument('--case', help='имя одной клетки (из cases())')
    ap.add_argument('--matrix', action='store_true', help='построчный depends всех клеток')
    args = ap.parse_args()
    repo = os.path.abspath(args.repo)
    out = os.path.abspath(args.out)
    os.makedirs(out, exist_ok=True)
    workdir = tempfile.mkdtemp(prefix='standarty115-', dir=out)
    summary = {'repo': repo, 'control_green': None, 'control_red': [], 'facts': {},
               'cases': {}}

    if args.matrix:
        rows = []
        for name, depends, _spec in cases():
            verdict, detail = judge_cell(repo, workdir, name, depends,
                                         [s for s in cases() if s[0] == name][0][2])
            rows.append('\t'.join([name, depends, verdict, detail]))
        print('\n'.join(rows))
        with open(os.path.join(out, 'matrix.tsv'), 'w', encoding='utf-8') as handle:
            handle.write('\n'.join(rows) + '\n')
        rc = 0 if all('\tREJECTED_EXACT\t' in row for row in rows) else 1
        sys.exit(rc)

    if args.case is not None:
        matched = [c for c in cases() if c[0] == args.case]
        if not matched:
            print('115 UNMEASURABLE: EMPTY_SELECTION')
            sys.exit(2)
        name, depends, spec = matched[0]
        verdict, detail = judge_cell(repo, workdir, name, depends, spec)
        print(name, verdict, detail)
        if verdict == 'NOOP':
            print('115 UNMEASURABLE: NOOP_MUTATION')
            sys.exit(2)
        if verdict == 'INVALID_MUTANT':
            print('115 UNMEASURABLE: INVALID_MUTANT')
            sys.exit(2)
        sys.exit(0 if verdict == 'REJECTED_EXACT' else 1)

    red = control_reasons(repo)
    summary['control_red'] = red
    if red:
        print('control_green=false')
        for reason in red:
            print('FAIL', reason)
    facts = {}
    if env_ready(repo):
        green, out_lint = fact_lint_green(repo)
        facts['BACKEND_LINT_GREEN'] = green
        if not green:
            print('FACT BACKEND_LINT_GREEN: False')
            print(out_lint[-2000:])
        ok_fix, details = fact_fixtures_guard(repo, workdir)
        facts['LINT_FIXTURES_GUARD'] = ok_fix
        if not ok_fix:
            print('FACT LINT_FIXTURES_GUARD: False')
            for detail in details:
                print('  ', detail)
        ok_scope, scope_details = fact_scope_covered(repo, workdir)
        facts['LINT_SCOPE_COVERED'] = ok_scope
        if not ok_scope:
            print('FACT LINT_SCOPE_COVERED: False')
            for detail in scope_details:
                print('  ', detail)
        ok_cfg, cfg_details = fact_scope_config_equal(repo, workdir)
        facts['LINT_SCOPE_CONFIG_EQUAL'] = ok_cfg
        if not ok_cfg:
            print('FACT LINT_SCOPE_CONFIG_EQUAL: False')
            for detail in cfg_details:
                print('  ', detail)
    else:
        facts['BACKEND_LINT_GREEN'] = None
        facts['LINT_FIXTURES_GUARD'] = None
        facts['LINT_SCOPE_COVERED'] = None
        facts['LINT_SCOPE_CONFIG_EQUAL'] = None
        print('NEEDS_ENV: нет node или node_modules/eslint в корне — живые факты не измерены')
    summary['facts'] = facts

    if red:
        summary['control_green'] = False
        with open(os.path.join(out, 'summary.json'), 'w', encoding='utf-8') as handle:
            json.dump(summary, handle, ensure_ascii=False, indent=1)
        sys.exit(1)
    if any(value is None for value in facts.values()):
        summary['control_green'] = None
        with open(os.path.join(out, 'summary.json'), 'w', encoding='utf-8') as handle:
            json.dump(summary, handle, ensure_ascii=False, indent=1)
        print('115 UNMEASURABLE: NEEDS_ENV')
        sys.exit(2)
    if not all(facts.values()):
        summary['control_green'] = False
        with open(os.path.join(out, 'summary.json'), 'w', encoding='utf-8') as handle:
            json.dump(summary, handle, ensure_ascii=False, indent=1)
        sys.exit(1)

    verdicts = {}
    for name, depends, spec in cases():
        verdict, detail = judge_cell(repo, workdir, name, depends, spec)
        verdicts[name] = [verdict, detail]
    summary['cases'] = verdicts
    rejected = sum(1 for v in verdicts.values() if v[0] == 'REJECTED_EXACT')
    total = len(verdicts)
    summary['control_green'] = True
    with open(os.path.join(out, 'summary.json'), 'w', encoding='utf-8') as handle:
        json.dump(summary, handle, ensure_ascii=False, indent=1)
    print('control_green=true; facts: {} True; клетки: {}/{} REJECTED_EXACT'.format(
        sum(1 for v in facts.values() if v), rejected, total))
    for name, (verdict, detail) in verdicts.items():
        if verdict != 'REJECTED_EXACT':
            print('NOT_REJECTED', name, verdict, detail)
    invalid = sorted(n for n, v in verdicts.items() if v[0] == 'INVALID_MUTANT')
    if invalid:
        print('115 UNMEASURABLE: INVALID_MUTANT:', ','.join(invalid))
        sys.exit(2)
    sys.exit(0 if rejected == total else 1)


if __name__ == '__main__':
    main()
