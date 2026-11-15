#!/usr/bin/env python3
"""Public-door probes for 187/1; synthetic projects own their .git.

locate uses the captured CompliorOS-architecture JSON protocol, not an echo of an ID.
The existing no-local brief pair uses 180's inline code-class metadata and a large
contract body outside context sections; missing-line must still refuse without a pack.
An explicit document brief is a separate case.

Граница JSON проверяется публичным make_task: обрезанный ответ и одна группа
status (отсутствующий/неизвестный при rc 0 и пустых matches[].components)
дают ARCH_LOCATE_GRAMMAR rc 1 без stdout-пака. Это неконформные ответы CLI,
а не новые варианты допустимой грамматики; task-valid остаётся парным контролем.
187а-ремонт (узкий, слово владельца 2026-11-15 ~10:45 UTC; приведение к frozen
187/1, не ослабление и не v+1): the rc grammar of the REAL check tool decides
the door — rc 0 with requiredModelGate PASS is GREEN even when the overall
status is NOT_EVALUATED over a NON-EMPTY unresolved latency.* (the live pin
907e9e80 shape: budgetMs null, latency.* ids in unresolved); rc 2 →
ARCH_NOT_EVALUATED with the door's OWN rc 2; rc 1 → ARCH_CHECK rc 1; a body
whose requiredModelGate != PASS at rc 0 (never emitted by the real tool) is
refused ARCH_NOT_EVALUATED — rc alone is never trusted. The substring hunt
for NOT_EVALUATED anywhere in the output (the current door) is a caught stub,
not a verdict.
187а-ремонт-2 (второй дефект той же двери, слово владельца 2026-11-15 ~13:00 UTC
через консультанта; приведение к frozen 187/1, не ослабление и не v+1): model
907e9e80 places components BY FILES inside a container module — locate
server/infrastructure/email/ → module.email with EMPTY components, locate
server/infrastructure/email/worker.js → module.email.dispatcher with
[api.email-current] (matched = the file itself). The current door demands the
DIRECTORY carry the SAME component set as the path, refusing the DECLARED-empty
container directory PATH_WITHOUT_COMPONENT «размещён моделью, но компонент не
назван» (measured /tmp/dev-harness-verify/door185-1115.sh run on the text of
185). Frozen 187/1 judges the path by its OWN placement: a file the model
places in the component named by the line PASSES (rc 0); a directory with a
DIFFERENT non-empty component set is a boundary escape — ARCH_ZONE stays; an
unambiguously unplaced path — PATH_WITHOUT_COMPONENT stays.
187а-ремонт-3 (третий дефект той же двери, слово владельца 2026-11-15 через
консультанта; приведение к frozen 187/1, не ослабление и не v+1): non-product
runtime is a MODEL attribute — the match module of tests/** at pin 907e9e80
carries outsideProductRuntime: true with emptyComponentsReason «outside the
product C4 runtime view»; the door READS THE FLAG of the match module and
passes such a path (rc 0 with conform product paths — the 181 pain:
PATH_WITHOUT_COMPONENT «компонент не назван» on tests/auth/; tests/** sits in
the implementer zones of backend contracts 001-008/152-179), while an EXPLICIT
false (server/ops/, a module NOT under tests/) and a MISSING flag with EMPTY
components keep the refusal, as did an UNRESOLVED zero-match path with no
file (the Д4 class at that moment — superseded by 187а-ремонт-4 below). The
flag is never guessed from the tests/ prefix: a tests/ path whose module
carries NO flag still refuses.
187а-ремонт-4 (Д4 той же двери, слово владельца 2026-11-15 ~13:15 UTC «в — да»
по Д4, через консультанта; приведение к frozen 187/1, НЕ v+1): the
door judges placement ONLY where the model claims the path. UNRESOLVED with
EMPTY matches — the path lies outside every model area (FILES.sha256,
provenance.json, package.json, .github/**, docs/**, .harness/**, корневой
migrations/) — is NOT judged: rc 0 with the line «вне модели: <путь>» in the
door message, disk existence irrelevant; UNRESOLVED with NON-EMPTY matches (a
model area without a component: server/newdir/x.js → [module.server,
module.entrypoints]) keeps the PATH_WITHOUT_COMPONENT refusal (protection,
green before and after); a foreign component keeps ARCH_ZONE (already covered
by freeze-foreign/locate-union-foreign — not duplicated). The trait is the
EMPTINESS OF matches in the model's own answer, never a path prefix, never
the disk.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

from probe import world, put, git, run, CONTRACT, REVIEW, TOOLS
from ci_wiring import BATTERY, DIRECT

# Expected answers are immutable tuples in the verifier, never read back from the subject.
# Mutation is one named coordinate at a time; each mutant is paired with its OWN red case.
CASES = (
    ('task-valid', 'task', '', 0, '', 'task'),
    ('task-line-missing', 'task', 'line-missing', 1, 'ARCH_LINE_MISSING', 'task'),
    ('task-line-blank', 'task', 'line-blank', 1, 'ARCH_LINE_MISSING', 'task'),
    ('task-l3', 'task', 'l3', 1, 'ARCH_OWNER', 'task'),
    ('task-unmapped', 'task', 'unmapped', 1, 'PATH_WITHOUT_COMPONENT', 'task'),
    ('task-foreign', 'task', 'task-foreign', 1, 'ARCH_ZONE', 'task'),
    ('task-locate-json-malformed', 'task', 'locate-malformed', 1, 'ARCH_LOCATE_GRAMMAR', 'task'),
    *((f'task-locate-status-{status}', 'task', f'locate-status-{status}',
       1, 'ARCH_LOCATE_GRAMMAR', 'task') for status in ('missing', 'unknown')),
    ('brief-lock', 'task', 'brief-lock', 0, 'PINNED_BRIEF_187', 'task'),
    ('brief-no-local-copy', 'task', 'no-local', 0, 'PINNED_BRIEF_187', 'task'),
    ('brief-inline-line-missing', 'task', 'inline-line-missing', 1, 'ARCH_LINE_MISSING', 'task'),
    ('brief-document-no-local', 'task', 'document-no-local', 0, 'PINNED_BRIEF_187', 'task'),
    ('brief-with-rules', 'task', 'with-rules', 0, 'RULES_FROM_PIN_187', 'task'),
    ('brief-no-rules', 'task', 'no-rules', 0, 'PINNED_BRIEF_187', 'task'),
    ('freeze-valid', 'freeze', '', 0, '', 'freeze'),
    ('freeze-no-line', 'freeze', 'freeze-no-line', 1, 'ARCH_LINE_MISSING', 'freeze'),
    ('freeze-foreign', 'freeze', 'foreign', 1, 'ARCH_ZONE', 'freeze'),
    ('freeze-unmapped', 'freeze', 'unmapped', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
    ('freeze-draft', 'freeze', 'draft', 1, 'ARCH_DRAFT', 'freeze'),
    ('freeze-draft-marker', 'freeze', 'draft-marker', 1, 'ARCH_DRAFT', 'freeze'),
    ('freeze-draft-schema', 'freeze', 'draft-schema', 1, 'ARCH_DRAFT', 'freeze'),
    ('check-valid', 'precritic', '', 0, '', 'precritic'),
    ('check-failure', 'precritic', 'check-1', 1, 'ARCH_CHECK', 'precritic'),
    ('check-not-evaluated', 'precritic', 'check-2', 1, 'ARCH_NOT_EVALUATED', 'precritic'),
    ('check-digest-mismatch', 'precritic', 'digest-mismatch', 1, 'ARCH_CHECK', 'precritic'),
    ('done-valid', 'done', '', 0, '', 'done'),
    ('done-review-missing', 'done', 'review-missing', 1, 'ARCH_REVIEW', 'done'),
    ('done-ci-missing', 'done', 'ci-missing', 1, 'ARCH_CI', 'done'),
    ('done-ci-other-sha', 'done', 'ci-other-sha', 1, 'ARCH_CI', 'done'),
    ('done-ci-red', 'done', 'ci-red', 1, 'ARCH_CI', 'done'),
    ('done-ci-skipped', 'done', 'ci-skipped', 1, 'ARCH_CI', 'done'),
    ('done-ci-head-ahead', 'done', 'ci-head-ahead', 1, 'ARCH_CI', 'done'),
    ('legacy-mob', 'freeze', 'mobile', 0, '', 'freeze'),
    ('legacy-harness', 'freeze', 'harness', 0, '', 'freeze'),
    ('wiring-valid', 'wiring', 'wiring-valid', 0, '', 'wiring'),
    ('wiring-omitted', 'wiring', 'wiring-omitted', 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT', 'wiring'),
    ('wiring-no-repo', 'wiring', 'wiring-no-repo', 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT', 'wiring'),
    ('wiring-python', 'wiring', 'wiring-python', 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT', 'wiring'),
    ('wiring-direct-missing', 'wiring', 'wiring-direct-missing', 1, 'CI_DIRECT_ARCH_187_MISSING', 'wiring'),
    # ── 187а-ремонт (узкий, слово владельца 2026-11-15 ~10:45): rc-грамматика
    # check настоящей модели решает дверь: rc 0 + requiredModelGate PASS при
    # общем status NOT_EVALUATED с непустым unresolved latency.* → rc 0 двери
    # (frozen 187/1: «при rc 0 модели и зелёных прочих ногах дверь rc 0»);
    # rc 2 → ARCH_NOT_EVALUATED rc 2 двери; rc 1 → ARCH_CHECK rc 1;
    # requiredModelGate != PASS при rc 0 → ARCH_NOT_EVALUATED (защита) ─────
    ('check-green-latency-unresolved', 'precritic', 'real-latency', 0, '', 'precritic'),
    ('check-rc2-real-gate', 'door', 'real-gate-ne', 2, 'ARCH_NOT_EVALUATED', 'door'),
    ('check-rc1-real-gate', 'door', 'real-gate-fail', 1, 'ARCH_CHECK', 'door'),
    ('check-rc0-gate-lie', 'door', 'real-gate-lie', 2, 'ARCH_NOT_EVALUATED', 'door'),
    # ── 187а-ремонт-2 (второй дефект двери, слово владельца 2026-11-15 ~13:00):
    # размещение компонентов ПО ФАЙЛАМ в модуле-контейнере (пин 907e9e80):
    # каталог-контейнер — DECLARED с ПУСТЫМИ components, файл внутри — свой
    # компонент; файл в заявленном строкой компоненте → rc 0 (красна сегодня:
    # PATH_WITHOUT_COMPONENT «…компонент не назван» на каталоге); каталог с
    # ДРУГИМ непустым набором → ARCH_ZONE (защита ремонта, зелена до/после);
    # неоднозначно неразмещённый путь без файла в продукте → защита
    # PATH_WITHOUT_COMPONENT (зелена до/после) ─────────────────────────────
    ('zone-container-file', 'freeze', 'container-file', 0, '', 'freeze'),
    ('zone-container-escape', 'freeze', 'container-escape', 1, 'ARCH_ZONE', 'freeze'),
    ('path-unplaced-absent', 'freeze', 'container-unplaced', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
    # ── 187а-ремонт-3 (третий дефект двери, слово владельца 2026-11-15):
    # непродуктовость — ПРИЗНАК МОДЕЛИ (outsideProductRuntime матча), не
    # префикс пути: тестовый шов tests/auth/ (module.tests пина 907e9e80:
    # true + emptyComponentsReason) рядом с продуктовым путём → rc 0 (красна
    # сегодня: PATH_WITHOUT_COMPONENT «компонент не назван» на шве — боль
    # 181, tests/** в зонах 001-008/152-179); ЯВНЫЙ false вне tests/ и
    # ОТСУТСТВУЮЩИЙ флаг при ПУСТЫХ components — прежний отказ (защиты,
    # зелены до/после) ─────────────────────────────────────────────────────
    ('zone-outside-runtime', 'freeze', 'outside-runtime', 0, '', 'freeze'),
    ('zone-outside-false-refused', 'freeze', 'outside-false', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
    ('zone-outside-noflag-refused', 'freeze', 'outside-noflag', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
    # ── 187а-ремонт-4 (Д4 той же двери, слово владельца 2026-11-15 ~13:15
    # «в — да»): путь ВНЕ всех областей модели (UNRESOLVED, matches ПУСТ —
    # признак ИЗ ОТВЕТА МОДЕЛИ, не префикс пути и не диск) — дверь НЕ судит
    # размещение: rc 0 со строкой «вне модели: <путь>» в сообщении; обе
    # клетки красны сегодня (файла нет — rc 1 PATH_WITHOUT_COMPONENT, файл
    # есть — rc 0 без строки); путь В ОБЛАСТИ модели без компонента
    # (НЕПУСТЫЕ matches: server/newdir/x.js → [module.server,
    # module.entrypoints]) — прежний отказ PATH_WITHOUT_COMPONENT (защита,
    # зелена до/после); чужой компонент → ARCH_ZONE — уже покрыто
    # (freeze-foreign/locate-union-foreign), не дублируется ────────────────
    ('path-unresolved-zero-absent', 'freeze', 'unresolved-zero-absent', 0, 'вне модели: scripts/ci-helper.sh', 'freeze'),
    ('path-unresolved-zero-present', 'freeze', 'unresolved-zero-present', 0, 'вне модели: provenance.json', 'freeze'),
    ('path-area-without-component', 'freeze', 'area-without-component', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
)
STABS = {
    'task-no-line': ('task-line-missing', 'allow-line'),
    'task-blank-accepted': ('task-line-blank', 'allow-line'),
    'structure-dropped': ('task-valid', 'omit-structure'),
    'obsolete-doc-reintroduced': ('task-valid', 'include-old-doc'),
    'task-l3-auto': ('task-l3', 'allow-l3'),
    'task-unmapped-path': ('task-unmapped', 'allow-unmapped'),
    'brief-from-head': ('brief-lock', 'use-head'),
    'brief-requires-local-copy': ('brief-no-local-copy', 'requires-local'),
    'locate-first-line-json': ('task-valid', 'locate-first-line'),
    'inline-code-local-fallback': ('brief-no-local-copy', 'anchored-class'),
    'inline-code-gate-skipped': ('brief-inline-line-missing', 'anchored-class'),
    'document-brief-requires-local': ('brief-document-no-local', 'requires-local'),
    'task-foreign-accepted': ('task-foreign', 'allow-zone'),
    'task-pack-before-refusal': ('brief-inline-line-missing', 'pack-then-refuse'),
    'locate-malformed-first-line': ('task-locate-json-malformed', 'locate-first-line'),
    **{f'locate-status-{status}-guessed':
       (f'task-locate-status-{status}', 'guess-locate-status')
       for status in ('missing', 'unknown')},
    'locate-status-pack-before-refusal': ('task-locate-status-missing', 'pack-then-refuse'),
    'brief-rules-omitted': ('brief-with-rules', 'omit-rules'),
    'brief-rules-leaked': ('brief-no-rules', 'leak-rules'),
    'zone-foreign': ('freeze-foreign', 'allow-zone'),
    'zone-unmapped': ('freeze-unmapped', 'allow-zone'),
    'freeze-line-ignored': ('freeze-no-line', 'allow-zone'),
    'draft-operation': ('freeze-draft', 'allow-draft'),
    'draft-spaced-token-only': ('freeze-draft-marker', 'draft-spaced-only'),
    'draft-schemas-ignored': ('freeze-draft-schema', 'draft-id-only'),
    'check-not-called': ('check-failure', 'skip-check'),
    'check-rc-ignored': ('check-not-evaluated', 'rc2-green'),
    'check-base-without-snapshot': ('check-valid', 'bare-base'),
    'check-digest-omitted': ('check-valid', 'omit-digest'),
    'check-digest-self-computed': ('check-digest-mismatch', 'self-digest'),
    'reviewer-line-ignored': ('done-review-missing', 'ignore-review'),
    'ci-not-read': ('done-ci-missing', 'ignore-ci'),
    'ci-sha-ignored': ('done-ci-other-sha', 'ignore-ci'),
    'ci-conclusion-ignored': ('done-ci-red', 'ignore-ci'),
    'ci-skipped-green': ('done-ci-skipped', 'ignore-ci'),
    'ci-sha-from-origin-ref': ('done-ci-head-ahead', 'sha-from-origin-ref'),
    'mob-required': ('legacy-mob', 'require-all'),
    'harness-required': ('legacy-harness', 'require-all'),
    'ci-step-omitted': ('wiring-omitted', 'ignore-wiring'),
    'ci-step-without-repo': ('wiring-no-repo', 'ignore-wiring'),
    'ci-step-python-instead': ('wiring-python', 'ignore-wiring'),
    'ci-direct-replaced-by-battery': ('wiring-direct-missing', 'ignore-wiring'),
    # ── 187а-ремонт стабы: «подстрочный NOT_EVALUATED во всём выводе
    # отказывает» (текущая дверь) — ловится зелёной latency-клеткой rc 0;
    # «пропускает rc 2» — rc2-клеткой; защита «gate != PASS → NOT_EVALUATED»
    # съедает ARCH_CHECK у rc 1 и «игнор поля шлюза при rc 0» — каждая своей
    # клеткой, различающий вход — свой (Н-39) ──────────────────────────────
    'latency-not-evaluated-substring': ('check-green-latency-unresolved', 'status-substring'),
    'model-rc2-passed-green': ('check-rc2-real-gate', 'rc2-green'),
    'gate-fail-named-not-evaluated': ('check-rc1-real-gate', 'gate-fail-not-evaluated'),
    'gate-field-ignored': ('check-rc0-gate-lie', 'gate-ignored'),
    # ── 187а-ремонт-2 стабы: «каталог обязан нести тот же набор компонентов,
    # что и путь» (текущая дверь — отказ на пустом каталоге-контейнере) —
    # ловится клеткой файла в контейнере; «всё моделью размещённое проходит
    # без проверки компонента» — клеткой выхода за границу; каждая ветвь
    # своей клетке, различающий вход — свой (Н-39) ─────────────────────────
    'zone-dir-same-set-required': ('zone-container-file', 'dir-same-set-required'),
    'zone-placed-no-component-check': ('zone-container-escape', 'boundary-skipped'),
    # ── 187а-ремонт-3 стабы: «признак по префиксу tests/» (пропуск без
    # чтения флага — ловится клеткой noflag: префикс тот же, флага нет) и
    # «всё без компонентов проходит» (значение флага не читается вовсе —
    # ловится клеткой ЯВНОГО false); каждая ветвь своей клетке, различающий
    # вход — свой (Н-39) ────────────────────────────────────────────────
    'outside-by-tests-prefix': ('zone-outside-noflag-refused', 'tests-prefix-skip'),
    'outside-empty-green': ('zone-outside-false-refused', 'empty-any-green'),
    # ── 187а-ремонт-4 стабы: «судит ноль-матчей как неразмещённый» (текущая
    # дверь — PATH_WITHOUT_COMPONENT «не размещён ни в модели, ни в продукте»
    # без различения областей модели) — краснеет на ОБОИХ ноль-матчевых
    # входах: файла нет (scripts/ci-helper.sh) и файл есть (provenance.json);
    # «всё безкомпонентное проходит» — на пути В ОБЛАСТИ модели без
    # компонента; каждая ветвь своей клетке, различающий вход — свой (Н-39) ──
    'unresolved-zero-refused-absent': ('path-unresolved-zero-absent', 'zero-refused'),
    'unresolved-zero-refused-present': ('path-unresolved-zero-present', 'zero-refused'),
    'area-without-component-green': ('path-area-without-component', 'empty-any-green'),
}

# Approved snapshot inside the pinned tree (2.5.x layout of the real model, as run-arch.js
# and verify-pin.js read it); the lock names it by canonical digest, format 167.
SNAPSHOT = 'governance/baseline/approved.json'
CHECK_OPTIONS = ('model', 'report', 'strict', 'base', 'base-digest')

# Real stdout channel of make_task, also forbidden on a named task refusal.
PACK_MARKER = '=== make_task contract='

# 187а-ремонт: токен файла check-rc закреплённого дерева задаёт форму ответа
# check. Исходные миры неизменны байтами: 'check-1' → '1', 'check-2' → '2',
# прочее → '0' (как до ремонта); новые токены — формы rc-грамматики
# настоящего CLI (см. ветви TOY_CLI и вердикты verdict).
CHECK_RC_TOKENS = {'check-1': '1', 'check-2': '2',
                   'real-latency': 'latency', 'real-gate-ne': 'gate-ne',
                   'real-gate-fail': 'gate-fail', 'real-gate-lie': 'gate-lie'}

# 187а-ремонт: зелёный rc-0 ответ настоящего CLI несёт общий status
# NOT_EVALUATED с НЕПУСТЫМ unresolved — latency-требования с budgetMs null
# (пин 907e9e80: system/fitness.js latencyRequirements; system.js:703-719
# отдаёт NOT_EVALUATED, cli.js:221-223/268-270 выносят их в unresolved).
# Единый источник: toy-CLI и честный контроль читают этот кортеж.
LATENCY_UNRESOLVED = ('latency.command-acceptance', 'latency.first-agent-event',
                      'latency.agent-completion')

# 187а-ремонт-2: форма модели 907e9e80 — модуль-контейнер размещает компоненты
# ПО ФАЙЛАМ: сам каталог — DECLARED с ПУСТЫМИ components (module.email), файл
# внутри — свой компонент (worker.js → api.email-current при matched = сам
# файл; synthetic.js → api.synthetic-email — второе значение той же формы).
# Единственный источник: toy-CLI и честный контроль читают эти константы.
CONTAINER_PREFIX = 'server/infrastructure/email/'
CONTAINER_DIR_MATCH = {'module': 'module.email', 'components': [],
                       'specification': 'server/infrastructure/email/module.js',
                       'explicit': False, 'matched': 'server/infrastructure/email/'}
CONTAINER_FILE_MATCHES = {
    'worker.js': {'module': 'module.email.dispatcher',
                  'components': ['api.email-current'],
                  'specification': 'server/infrastructure/email/worker.js',
                  'explicit': True, 'matched': 'server/infrastructure/email/worker.js'},
    'synthetic.js': {'module': 'module.email.synthetic',
                     'components': ['api.synthetic-email'],
                     'specification': 'server/infrastructure/email/synthetic.js',
                     'explicit': True, 'matched': 'server/infrastructure/email/synthetic.js'},
}
# Защита границы (frozen 187/1: «граница компонента, не строковый prefix»):
# каталог с ДРУГИМ непустым набором компонентов — выход файла за границу
# компонента каталога. Единый источник с toy-CLI.
ESCAPE_PREFIX = 'app/escape/'
ESCAPE_DIR_MATCH = {'module': 'module.escape', 'components': ['api.billing'],
                    'specification': 'app/escape/module.js', 'explicit': False,
                    'matched': 'app/escape/'}
ESCAPE_FILE_MATCH = {'module': 'module.escape-model', 'components': ['api.identity'],
                     'specification': 'app/escape/model.js', 'explicit': True,
                     'matched': 'app/escape/model.js'}
# 187а-ремонт-2 (принесено минимально из v+1): неоднозначное размещение —
# два претендента на 'app/dual/' — различающий вход клетки чистой
# неразмещённости (container-unplaced): kind 'unresolved-multi'. Единый
# источник с toy-CLI.
DUAL_PREFIX = 'app/dual/'
DUAL_MATCHES = (
    {'module': 'module.dual-gateway', 'components': ['api.hub'],
     'specification': 'app/dual/gateway.js', 'explicit': False, 'matched': 'app/dual/'},
    {'module': 'module.dual-entrypoints', 'components': ['api.documents'],
     'specification': 'app/dual/entrypoints.js', 'explicit': False, 'matched': 'app/dual/'},
)

# 187а-ремонт-3 (третий дефект той же двери, слово владельца 2026-11-15
# через консультанта; приведение к frozen 187/1, не ослабление и не v+1):
# непродуктовость пути — ПРИЗНАК МОДЕЛИ, не префикс пути и не id модуля.
# module.tests пина 907e9e80 несёт outsideProductRuntime: true и
# emptyComponentsReason «outside the product C4 runtime view» — путь такого
# модуля дверь ПРОПУСКАЕТ (rc 0 при конформных прочих путях зоны); ЯВНЫЙ
# false (server/ops/, модуль НЕ от tests/) и ОТСУТСТВУЮЩИЙ флаг
# (tests/unit.js — общий вид tests/ этой toy-модели, TESTS_MATCH) при ПУСТЫХ
# components — прежний отказ PATH_WITHOUT_COMPONENT. Единственный источник:
# toy-CLI и честный контроль читают эти константы.
OUTSIDE_TESTS_PREFIX = 'tests/auth/'
OUTSIDE_TESTS_MATCH = {'module': 'module.tests', 'components': [],
                       'outsideProductRuntime': True,
                       'emptyComponentsReason': 'Development verification and workflow artifacts are outside the product C4 runtime view.',
                       'specification': 'tests/module.js', 'explicit': False,
                       'matched': 'tests/'}
TESTS_PREFIX = 'tests/'
TESTS_MATCH = {'module': 'module.tests', 'components': [],
               'specification': 'tests/module.js', 'explicit': False,
               'matched': 'tests/'}
OPS_PREFIX = 'server/ops/'
OPS_MATCH = {'module': 'module.ops', 'components': [],
             'outsideProductRuntime': False,
             'specification': 'server/ops/module.js', 'explicit': False,
             'matched': 'server/ops/'}

# 187а-ремонт-4 (принесено минимально из v+1): 'server/' — область,
# на которую притязают ДВА модуля с ПУСТЫМИ компонентами (наблюдённая на
# пине форма server/index.js: module.server + module.entrypoints) —
# НЕПУСТЫЕ matches при ПУСТЫХ components, различающий вход клетки
# area-without-component (server/newdir/x.js). Единый источник с toy-CLI;
# судится ПОСЛЕ контейнера и ops, лежащих внутри 'server/'.
AMBIG_PREFIX = 'server/'
AMBIG_MATCHES = (
    {'module': 'module.server', 'components': [],
     'specification': 'server/module.js', 'explicit': False, 'matched': 'server/'},
    {'module': 'module.entrypoints', 'components': [],
     'specification': 'server/entrypoints.js', 'explicit': False, 'matched': 'server/'},
)

def digest(value):
    """Canonical SHA-256 of the real model: sorted keys, JSON.stringify bytes."""
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'),
                                     ensure_ascii=False).encode()).hexdigest()

def snapshot(number):
    return {'format': 'toy-architecture-baseline/1', 'snapshot': number,
            'components': ['api.identity'] + (['api.billing'] if number > 1 else [])}

def toy_check(arch, revision, args):
    """Verifier's own reading of the real CLI `check` grammar (cli.js parseArguments,
    baseline.js inspectBaseline): a flag without value is MISSING_OPTION_VALUE rc 1,
    no snapshot or digest is NOT_EVALUATED rc 2, a foreign digest is rc 1."""
    options, i = {}, 0
    while i < len(args):
        key = args[i][2:] if args[i].startswith('--') else ''
        if key not in CHECK_OPTIONS:
            return 1, 'UNSUPPORTED_OPTION'
        if key == 'strict':
            options[key], i = True, i + 1
            continue
        value = args[i + 1] if i + 1 < len(args) else ''
        if not value or value.startswith('--'):
            return 1, 'MISSING_OPTION_VALUE'
        options[key], i = value, i + 2
    if not options.get('base') or not options.get('base-digest'):
        return 2, 'NOT_EVALUATED'
    if digest(json.loads(git(arch, 'show', f'{revision}:{options["base"]}'))) != options['base-digest']:
        return 1, 'BASELINE_DIGEST_MISMATCH'
    status = int(git(arch, 'show', revision + ':check-rc'))
    return status, 'NOT_EVALUATED' if status == 2 else ''

def drafted(line, mutant):
    """DRAFT is the case-insensitive token `draft` at a word boundary anywhere in the
    operation line: id, input schema, output schema, or an annotation."""
    if mutant == 'draft-spaced-only':
        op_id = line[len('ОПЕРАЦИЯ:'):].split(';')[0].strip().lower()
        return op_id == 'draft' or op_id.endswith('.draft') or ' DRAFT ' in f' {line} '
    field = line.split(';')[0] if mutant == 'draft-id-only' else line
    return re.search(r'(?<!\w)draft(?!\w)', field, re.I) is not None

def line_components(text):
    """Component ids of the «АРХИТЕКТУРА:» line, split by commas. None — no line;
    [] — empty list."""
    for line in text.splitlines():
        if line.startswith('АРХИТЕКТУРА: L'):
            rest = line[len('АРХИТЕКТУРА:'):].strip()
            ids = rest.split(' ', 1)[1] if ' ' in rest else ''
            return [i for i in ids.split(',') if i]
    return None

def parent_dir(path):
    """Каталог продуктового пути в форме двери: dirname с конечным «/»."""
    return path[:path.rfind('/') + 1] if '/' in path else ''

def union_components(matches):
    """Набор компонентов матчей ответа locate: без повторов, по порядку."""
    union = []
    for match in matches:
        for component in match['components']:
            if component not in union:
                union.append(component)
    return union

def locate_answer(path):
    """Честный контроль ответа locate toy-модели (перенос 187а-ремонта на
    батарею main; единственный источник с toy-CLI): ('declared', matches) —
    rc 0, путь размещён (components могут быть ПУСТЫ — решение самой модели);
    ('unresolved-zero', []) — rc 1, ни один модуль не притязает;
    ('unresolved-multi', matches) — rc 1, несколько претендентов."""
    if path.startswith(CONTAINER_PREFIX):
        # 187а-ремонт-2: контейнер судится ДО AMBIG — 'server/infrastructure/'
        # лежит внутри амбигуального префикса 'server/' этой toy-модели.
        rest = path[len(CONTAINER_PREFIX):]
        if rest == '':
            return 'declared', [CONTAINER_DIR_MATCH]
        if rest in CONTAINER_FILE_MATCHES:
            return 'declared', [CONTAINER_FILE_MATCHES[rest]]
        return 'unresolved-zero', []
    if path.startswith(ESCAPE_PREFIX):
        rest = path[len(ESCAPE_PREFIX):]
        if rest == '':
            return 'declared', [ESCAPE_DIR_MATCH]
        if rest == 'model.js':
            return 'declared', [ESCAPE_FILE_MATCH]
        return 'unresolved-zero', []
    if path.startswith(OUTSIDE_TESTS_PREFIX):
        # 187а-ремонт-3: тестовый шов пина 907e9e80 — module.tests с ПРИЗНАКОМ
        # МОДЕЛИ outsideProductRuntime: true (судится ДО общих tests/: у более
        # глубокой ветви приоритет, как у контейнера перед AMBIG).
        return 'declared', [OUTSIDE_TESTS_MATCH]
    if path.startswith(TESTS_PREFIX):
        return 'declared', [TESTS_MATCH]
    if path.startswith(OPS_PREFIX):
        # 187а-ремонт-3: ЯВНЫЙ outsideProductRuntime: false — прежний отказ
        # (судится ДО AMBIG 'server/', внутри которого лежит 'server/ops/').
        return 'declared', [OPS_MATCH]
    if path.startswith(AMBIG_PREFIX):
        # 187а-ремонт-4: область модели без компонента — НЕПУСТЫЕ matches
        # с ПУСТЫМИ components (после контейнера и ops внутри 'server/').
        return 'unresolved-multi', list(AMBIG_MATCHES)
    if path.startswith(DUAL_PREFIX):
        return 'unresolved-multi', list(DUAL_MATCHES)
    if path.startswith('app/identity/') or path.startswith('app/billing/'):
        prefix = 'app/identity/' if path.startswith('app/identity/') else 'app/billing/'
        return 'declared', [{'module': 'module.' + prefix.split('/')[1],
                             'components': ['api.identity' if prefix == 'app/identity/'
                                            else 'api.billing'],
                             'specification': prefix + 'module.js', 'explicit': False,
                             'matched': prefix}]
    return 'unresolved-zero', []

# Toy CLI закреплённого дерева. 187а-ремонт: плейсхолдеры шаблона разрешаются
# ДО записи — toy-CLI и константы батареи читают единый источник.
TOY_CLI = '''const fs=require('fs');
const a=process.argv.slice(2); const name=a[0];
if (name==='brief') {
 const id=a[a.indexOf('--component')+1];
 if(id!=='api.identity') process.exit(1);
 console.log('PINNED_BRIEF_187 '+id);
 if(a.includes('--with-rules')) console.log('RULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed');
} else if(name==='locate') {
 const p=a[a.indexOf('--path')+1];
 const one=(status,matches,rc)=>{console.log(JSON.stringify({scope:'DECLARED_PLACEMENT_ONLY',path:p,status:status,matches:matches,implementationEvidence:'NOT_ASSESSED'},null,2)); if(rc)process.exit(rc);};
 if(p.startsWith('__CONTAINER_PREFIX__')){
  const crest=p.slice(__CONTAINER_LEN__);
  if(crest==='') one('DECLARED',[__CONTAINER_DIR_MATCH__],0);
  else if(crest==='worker.js') one('DECLARED',[__CONTAINER_WORKER_MATCH__],0);
  else if(crest==='synthetic.js') one('DECLARED',[__CONTAINER_SYNTHETIC_MATCH__],0);
  else { console.log(JSON.stringify({scope:'DECLARED_PLACEMENT_ONLY',path:p,status:'UNRESOLVED',matches:[],implementationEvidence:'NOT_ASSESSED'},null,2)); process.exit(1); }
 } else if(p.startsWith('__ESCAPE_PREFIX__')){
  const erest=p.slice(__ESCAPE_LEN__);
  if(erest==='') one('DECLARED',[__ESCAPE_DIR_MATCH__],0);
  else if(erest==='model.js') one('DECLARED',[__ESCAPE_FILE_MATCH__],0);
  else { console.log(JSON.stringify({scope:'DECLARED_PLACEMENT_ONLY',path:p,status:'UNRESOLVED',matches:[],implementationEvidence:'NOT_ASSESSED'},null,2)); process.exit(1); }
 } else if(p.startsWith('__OUTSIDE_TESTS_PREFIX__')){
  one('DECLARED',[__OUTSIDE_TESTS_MATCH__],0);
 } else if(p.startsWith('__TESTS_PREFIX__')){
  one('DECLARED',[__TESTS_MATCH__],0);
 } else if(p.startsWith('__OPS_PREFIX__')){
  one('DECLARED',[__OPS_MATCH__],0);
 } else if(p.startsWith('__AMBIG_PREFIX__')){
  one('UNRESOLVED',__AMBIG_MATCHES__,1);
 } else if(p.startsWith('__DUAL_PREFIX__')){
  one('UNRESOLVED',__DUAL_MATCHES__,1);
 } else {
  const prefix=p.startsWith('app/identity/')?'app/identity/':p.startsWith('app/billing/')?'app/billing/':'';
  const components=prefix?[prefix==='app/identity/'?'api.identity':'api.billing']:[];
  const matches=prefix?[{module:'module.'+prefix.split('/')[1],components,
    specification:prefix+'module.js',explicit:false,matched:prefix}]:[];
 // Same fields as ACTUAL-LOCATE-007-1113.json, pretty-printed as the real CLI.
 const response={scope:'DECLARED_PLACEMENT_ONLY',path:p,
   status:matches.length?'DECLARED':'UNRESOLVED',matches,
   implementationEvidence:'NOT_ASSESSED'};
 const boundary=fs.readFileSync('locate-boundary','utf8').trim();
 if(boundary==='locate-malformed') {
   console.log(JSON.stringify(response,null,2).slice(0,-1));
   process.exit(0);
 }
 if(boundary==='locate-status-missing'||boundary==='locate-status-unknown') {
   response.matches=matches.map(match=>({...match,components:[]}));
   delete response.status;
   if(boundary==='locate-status-unknown') response.status='UNKNOWN';
   console.log(JSON.stringify(response,null,2));
   process.exit(0);
 }
 console.log(JSON.stringify(response,null,2));
 if(!matches.length) process.exit(1);
 }
} else if(name==='check') {
 const allowed=['model','report','strict','base','base-digest']; const o={};
 const out=(status,code,rc)=>{console.log(JSON.stringify({status,findings:code?[{code}]:[]}));process.exit(rc);};
 for(let i=1;i<a.length;i++){
  const f=a[i]; const k=f.startsWith('--')?f.slice(2):'';
  if(!allowed.includes(k)) out('FAIL','UNSUPPORTED_OPTION',1);
  if(k==='strict'){o[k]=true;continue;}
  const v=a[++i]; if(!v||v.startsWith('--')) out('FAIL','MISSING_OPTION_VALUE',1);
  o[k]=v;
 }
 if(!o.base||!o['base-digest']) out('NOT_EVALUATED','',2);
 const canon=v=>Array.isArray(v)?v.map(canon):(!v||typeof v!=='object')?v:Object.fromEntries(Object.keys(v).sort().map(k=>[k,canon(v[k])]));
 const d=require('crypto').createHash('sha256').update(JSON.stringify(canon(JSON.parse(fs.readFileSync(o.base,'utf8'))))).digest('hex');
 if(d!==o['base-digest']) out('FAIL','BASELINE_DIGEST_MISMATCH',1);
 const status=fs.readFileSync('check-rc','utf8').trim();
 if(status==='2') console.log('NOT_EVALUATED');
 if(status==='latency'){
  console.log(JSON.stringify({status:'NOT_EVALUATED',requiredModelGate:'PASS',baselineStatus:'PASS',implementationEvidence:'NOT_ASSESSED',unresolved:__LATENCY_UNRESOLVED__,findings:[],draftContracts:[]},null,2));
  process.exit(0);
 }
 if(status==='gate-ne') { console.log(JSON.stringify({status:'NOT_EVALUATED',requiredModelGate:'NOT_EVALUATED',baselineStatus:'PASS',implementationEvidence:'NOT_ASSESSED',unresolved:[],findings:[],draftContracts:[]},null,2)); process.exit(2); }
 if(status==='gate-fail') { console.log(JSON.stringify({status:'FAIL',requiredModelGate:'FAIL',baselineStatus:'PASS',implementationEvidence:'NOT_ASSESSED',unresolved:[],findings:[{code:'STRUCTURAL_INVARIANT'}],draftContracts:[]},null,2)); process.exit(1); }
 if(status==='gate-lie') { console.log(JSON.stringify({status:'NOT_EVALUATED',requiredModelGate:'NOT_EVALUATED',baselineStatus:'PASS',implementationEvidence:'NOT_ASSESSED',unresolved:[],findings:[],draftContracts:[]},null,2)); process.exit(0); }
 process.exit(Number(status));
} else process.exit(2);
'''
TOY_CLI = (TOY_CLI
           .replace('__LATENCY_UNRESOLVED__', json.dumps(LATENCY_UNRESOLVED, separators=(',', ':')))
           .replace('__CONTAINER_PREFIX__', CONTAINER_PREFIX)
           .replace('__CONTAINER_LEN__', str(len(CONTAINER_PREFIX)))
           .replace('__CONTAINER_DIR_MATCH__', json.dumps(CONTAINER_DIR_MATCH, separators=(',', ':')))
           .replace('__CONTAINER_WORKER_MATCH__', json.dumps(CONTAINER_FILE_MATCHES['worker.js'], separators=(',', ':')))
           .replace('__CONTAINER_SYNTHETIC_MATCH__', json.dumps(CONTAINER_FILE_MATCHES['synthetic.js'], separators=(',', ':')))
           .replace('__ESCAPE_PREFIX__', ESCAPE_PREFIX)
           .replace('__ESCAPE_LEN__', str(len(ESCAPE_PREFIX)))
           .replace('__ESCAPE_DIR_MATCH__', json.dumps(ESCAPE_DIR_MATCH, separators=(',', ':')))
           .replace('__ESCAPE_FILE_MATCH__', json.dumps(ESCAPE_FILE_MATCH, separators=(',', ':')))
           .replace('__DUAL_PREFIX__', DUAL_PREFIX)
           .replace('__DUAL_MATCHES__', json.dumps(DUAL_MATCHES, separators=(',', ':')))
           .replace('__OUTSIDE_TESTS_PREFIX__', OUTSIDE_TESTS_PREFIX)
           .replace('__OUTSIDE_TESTS_MATCH__', json.dumps(OUTSIDE_TESTS_MATCH, separators=(',', ':')))
           .replace('__TESTS_PREFIX__', TESTS_PREFIX)
           .replace('__TESTS_MATCH__', json.dumps(TESTS_MATCH, separators=(',', ':')))
           .replace('__OPS_PREFIX__', OPS_PREFIX)
           .replace('__OPS_MATCH__', json.dumps(OPS_MATCH, separators=(',', ':')))
           .replace('__AMBIG_PREFIX__', AMBIG_PREFIX)
           .replace('__AMBIG_MATCHES__', json.dumps(AMBIG_MATCHES, separators=(',', ':'))))
assert '__CONTAINER' not in TOY_CLI and '__ESCAPE' not in TOY_CLI and '__DUAL' not in TOY_CLI \
    and '__OUTSIDE_TESTS' not in TOY_CLI and '__TESTS' not in TOY_CLI and '__OPS' not in TOY_CLI \
    and '__AMBIG' not in TOY_CLI, \
    'шаблон TOY_CLI не разрешён (плейсхолдеры контейнера/выхода/дуала/признака/области)'
# Ветвь обязана быть в канонической форме из константы (одиночные кавычки
# шаблона): двойное закавычивание плейсхолдера префикса (json.dumps внутрь
# готовых кавычек startsWith) молча роняет контейнерные пути в generic-ветку —
# ловится здесь, на импорте.
for _prefix in (CONTAINER_PREFIX, ESCAPE_PREFIX, DUAL_PREFIX, OUTSIDE_TESTS_PREFIX,
                TESTS_PREFIX, OPS_PREFIX, AMBIG_PREFIX):
    assert f"p.startsWith('{_prefix}')" in TOY_CLI, \
        f'ветвь префикса {_prefix!r} не в канонической форме'

def architecture(base, root, variation):
    """A separate git repository with A pinned and a later, deliberately different B HEAD."""
    arch = base / (root.name + '-model')
    arch.mkdir()
    git(arch, 'init', '-q', '-b', 'main')
    git(arch, 'config', 'user.name', 'Fixture')
    git(arch, 'config', 'user.email', 'fixture@local')
    git(arch, 'config', 'commit.gpgsign', 'false')
    put(arch, 'package.json', json.dumps({'scripts': {'brief': 'node tooling/checks/cli.js brief',
                                                       'check': 'node tooling/checks/cli.js check'}}))
    put(arch, 'tooling/checks/cli.js', TOY_CLI)
    put(arch, 'check-rc', CHECK_RC_TOKENS.get(variation, '0') + '\n')
    put(arch, 'locate-boundary', variation + '\n')
    put(arch, SNAPSHOT, json.dumps(snapshot(1)))
    git(arch, 'add', '-A')
    git(arch, 'commit', '-qm', 'published architecture')
    pinned = git(arch, 'rev-parse', 'HEAD')
    put(arch, 'tooling/checks/cli.js', (arch / 'tooling/checks/cli.js').read_text().replace('PINNED_BRIEF_187', 'WRONG_HEAD_BRIEF_187').replace('RULES_FROM_PIN_187', 'WRONG_HEAD_RULES_187'))
    put(arch, SNAPSHOT, json.dumps(snapshot(2)))
    git(arch, 'add', '-A')
    git(arch, 'commit', '-qm', 'unpublished later architecture')
    # Lock format of backend 167: the digest names the approved snapshot, not the commit's
    # HEAD; digest-mismatch names B's snapshot while the commit stays A.
    put(root, 'architecture.lock.json', json.dumps({
        'format': 'complioros-architecture-pin/1', 'repository': 'a3ka/CompliorOS-architecture',
        'commit': pinned, 'snapshot': 1, 'status': 'APPROVED',
        'snapshotDigest': digest(snapshot(2 if variation == 'digest-mismatch' else 1)),
        'workItem': 'COMPLIOR-777'}))
    return arch, pinned

def ci_bin(root):
    return root.parent / (root.name + '-bin')

def ci_record(root):
    return root.parent / (root.name + '-ci-187.json')

def prepare(root, arch, pinned, variation):
    if variation.startswith('wiring-'):
        commands = [BATTERY, DIRECT]
        if variation == 'wiring-omitted': commands.remove(BATTERY)
        if variation == 'wiring-no-repo': commands[0] = BATTERY.removesuffix(' --repo .')
        if variation == 'wiring-python': commands[0] = BATTERY.replace('bash fixtures/', 'python3 fixtures/', 1)
        if variation == 'wiring-direct-missing': commands.remove(DIRECT)
        put(root, 'registry/ci-steps.tsv', ''.join(
            f'step\tarch-187-{i}\t1\t{command}\n' for i, command in enumerate(commands)))
    role = 'implementer' if variation == 'no-rules' else 'architect'
    task = root / 'task-187.md'
    task.write_text('SUBJECT=777\nАРХИТЕКТУРА: L2 api.identity\nЗОНА implementer: app/identity/\n')
    if variation in ('mobile', 'harness'):
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    trace = root / 'trace-187.tsv'
    trace.write_text(role + '\tzai/glm-5.3\tallowed\n')
    # The check-run report is external to the subject repo and names the final SHA.
    record = {'total_count': 1, 'check_runs': [
        {'id': 187, 'name': 'arch', 'status': 'completed', 'conclusion': 'success'}]}
    if variation in ('line-missing', 'inline-line-missing', 'document-no-local'):
        task.write_text(task.read_text().replace('АРХИТЕКТУРА: L2 api.identity\n', ''))
    elif variation == 'line-blank':
        task.write_text(task.read_text().replace('АРХИТЕКТУРА: L2 api.identity', 'АРХИТЕКТУРА: '))
    if variation in ('no-local', 'inline-line-missing'):
        # Real 180 is 94,015 bytes with its code class near the start. Amplify its
        # supported large-contract path beyond a 1 MiB Linux pipe capacity so an
        # early-exiting class predicate cannot hide behind a small buffered write.
        # This ordinary Markdown appendix is outside the selected context sections:
        # full CBYTES reaches the public door while the valid pair's pack stays small.
        contract = (root / CONTRACT).read_text().replace(
            'КЛАСС ЗАДАЧИ: кодовый.',
            'Идентификатор: `id/CONTRACT/777`. КЛАСС ЗАДАЧИ: кодовый (реализация).')
        example = '| identity.lookup | schema.query | schema.record | app/identity/model.js |\n'
        appendix = '\n## Примеры реализации\n\n| Операция | Вход | Выход | Путь |\n| --- | --- | --- | --- |\n'
        appendix += example * (94_015 * 16 // len(example.encode()) + 1)
        put(root, CONTRACT, contract + appendix)
    elif variation == 'document-no-local':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'КЛАСС ЗАДАЧИ: кодовый.', 'КЛАСС ЗАДАЧИ: документальный.'))
    if variation in ('no-local', 'inline-line-missing', 'document-no-local'):
        for file in (root / 'architecture').rglob('*'):
            if file.is_file(): file.unlink()
        for directory in sorted((root / 'architecture').rglob('*'), reverse=True):
            if directory.is_dir(): directory.rmdir()
        (root / 'architecture').rmdir()
    elif variation == 'freeze-no-line':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    elif variation == 'l3':
        task.write_text(task.read_text().replace('L2 api.identity', 'L3 api.identity'))
    elif variation == 'unmapped':
        task.write_text(task.read_text().replace('app/identity/', 'server/src/auth/'))
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'server/src/auth/evil.js'))
    elif variation == 'task-foreign':
        task.write_text(task.read_text().replace('app/identity/', 'app/billing/'))
    elif variation == 'foreign':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'app/billing/evil.js'))
        put(root, 'app/billing/evil.js', 'module.exports=2;\n')
    elif variation == 'draft':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('identity.lookup', 'identity.draft'))
    elif variation == 'draft-marker':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'ОПЕРАЦИЯ: identity.lookup;', 'ОПЕРАЦИЯ: identity.lookup (DRAFT);'))
    elif variation == 'draft-schema':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('вход schema.query', 'вход schema.draft'))
    elif variation == 'review-missing':
        put(root, REVIEW, 'ACCEPT\nNote: СВЕРКА-АРХИТЕКТУРЫ: mentioned in a quote, not reported by reviewer\n')
    elif variation == 'container-file':
        # 187а-ремонт-2: зона — ФАЙЛ в модуле-контейнере: locate каталога —
        # module.email с ПУСТЫМИ components, locate файла — [api.email-current]
        # (matched = сам файл); строка называет этот компонент.
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: L1 api.email-current'
        ).replace('app/identity/model.js', CONTAINER_PREFIX + 'worker.js'))
        put(root, CONTAINER_PREFIX + 'worker.js', 'module.exports=16;\n')
    elif variation == 'container-escape':
        # Защита границы: каталог — ДРУГОЙ непустой набор (api.billing), файл —
        # api.identity, строка называет ОБА — отказ только по границе компонента.
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: L1 api.identity,api.billing'
        ).replace('app/identity/model.js', ESCAPE_PREFIX + 'model.js'))
        put(root, ESCAPE_PREFIX + 'model.js', 'module.exports=17;\n')
    elif variation == 'container-unplaced':
        # Защита отказа: путь неоднозначно неразмещён (два претендента
        # app/dual/) и в продукте НЕ существует — существующий файл вход
        # ДРУГОЙ клетки (real-unplaced); здесь чистая неразмещённость.
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'app/identity/model.js', DUAL_PREFIX + 'absent.js'))
    elif variation == 'outside-runtime':
        # 187а-ремонт-3: зона как у контрактов бэкенда (001-008, 152-179):
        # продуктовый путь (DECLARED, [api.identity]) + тестовый шов tests/auth/
        # (module.tests пина 907e9e80: outsideProductRuntime: true,
        # emptyComponentsReason) — боль: текущая дверь отказывает
        # PATH_WITHOUT_COMPONENT «компонент не назван» на тестовом шве.
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'ЗОНА implementer: app/identity/model.js',
            'ЗОНА implementer: app/identity/model.js ' + OUTSIDE_TESTS_PREFIX + 'login.js'))
        put(root, OUTSIDE_TESTS_PREFIX + 'login.js', 'module.exports=18;\n')
    elif variation == 'outside-false':
        # Защита: признак из МОДЕЛИ, не из префикса — модуль НЕ от tests/
        # (server/ops/) с ЯВНЫМ outsideProductRuntime: false и ПУСТЫМИ
        # components — прежний отказ PATH_WITHOUT_COMPONENT (зелена до/после).
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'app/identity/model.js', OPS_PREFIX + 'maintenance.js'))
        put(root, OPS_PREFIX + 'maintenance.js', 'module.exports=19;\n')
    elif variation == 'outside-noflag':
        # Защита «не из префикса»: префикс tests/ ПОХОЖ (общий вид tests/ этой
        # toy-модели — TESTS_MATCH без флага), но признака в модели НЕТ — отказ
        # сохраняется (зелена до/после; стаб «признак по префиксу tests/»
        # ловится здесь).
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'app/identity/model.js', 'tests/unit.js'))
        put(root, 'tests/unit.js', 'module.exports=20;\n')
    elif variation == 'unresolved-zero-absent':
        # 187а-ремонт-4, правило (ii): путь ВНЕ всех областей модели (ноль
        # матчей), файла в продукте НЕТ — дверь НЕ судит размещение: rc 0 со
        # строкой «вне модели: <путь>» (красна сегодня: rc 1
        # PATH_WITHOUT_COMPONENT «не размещён ни в модели, ни в продукте»).
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'app/identity/model.js', 'scripts/ci-helper.sh'))
    elif variation == 'unresolved-zero-present':
        # 187а-ремонт-4, правило (ii), второе значение: файл СУЩЕСТВУЕТ в
        # продукте (provenance.json назван §«Существующее»), но ни один модуль
        # модели не притязает на путь (matches ПУСТ) — rc 0 со строкой «вне
        # модели: <путь>» (красна сегодня: rc 0 без строки); суждение по диску
        # («файл есть — судим размещение») запрещено: признак — пустота
        # matches ответа модели.
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'provenance.json'))
        put(root, 'provenance.json', '{"schema": "toy-pin"}\n')
    elif variation == 'area-without-component':
        # 187а-ремонт-4, правило (i) — защита: путь ВНУТРИ области модели без
        # компонента — НЕПУСТЫЕ matches [module.server, module.entrypoints] с
        # ПУСТЫМИ components; файла в продукте нет (новый файл области, боль
        # 185) — прежний отказ PATH_WITHOUT_COMPONENT (зелена до/после; стаб
        # «всё безкомпонентное проходит» ловится здесь).
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'server/newdir/x.js'))
    # CI report mutations happen after commit: the report must reference the final SHA.
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'isolated scenario ' + (variation or 'valid'))
    if variation == 'no-rules':
        git(root, 'tag', 'frozen/contracts/777/1')
    record['check_runs'][0]['head_sha'] = git(root, 'rev-parse', 'HEAD')
    if variation == 'ci-missing': record = {'total_count': 0, 'check_runs': []}
    if variation == 'ci-other-sha': record['check_runs'][0]['head_sha'] = 'f' * 40
    if variation == 'ci-red': record['check_runs'][0]['conclusion'] = 'failure'
    if variation == 'ci-skipped': record['check_runs'][0]['conclusion'] = 'skipped'
    ci_record(root).write_text(json.dumps(record))
    git(root, 'push', '-q', 'origin', 'main')
    if variation == 'ci-head-ahead':
        # Local HEAD moves past origin/main after push; the green arch run stays on the old SHA.
        put(root, 'app/identity/model.js', 'module.exports = 3;\n')
        git(root, 'commit', '-qam', 'unpushed change after green arch')
    bin_dir = ci_bin(root)
    bin_dir.mkdir()
    fake_curl = bin_dir / 'curl'
    fake_curl.write_text('#!/usr/bin/env bash\n'
                         'case \"${@: -1}\" in *\"/commits/\"*\"/check-runs?\"*) cat \"$ARCH187_CURL_RESPONSE\" ;; *) exit 31 ;; esac\n')
    fake_curl.chmod(0o755)
    return task, trace, role

def verdict(root, arch, pinned, action, task, role, mutant='', variation=''):
    if action == 'wiring':
        if mutant == 'ignore-wiring':
            return 0, ''
        if variation == 'wiring-omitted' or variation in ('wiring-no-repo', 'wiring-python'):
            return 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT'
        if variation == 'wiring-direct-missing':
            return 1, 'CI_DIRECT_ARCH_187_MISSING'
        return 0, ''
    profile = json.loads((root / 'harness.project.json').read_text())
    if profile['repoId'] != 'Complior-back' and mutant != 'require-all':
        return 0, ''
    contract = (root / CONTRACT).read_text()
    if action == 'task':
        text = task.read_text()
        if mutant == 'anchored-class' and variation in ('no-local', 'inline-line-missing'):
            if variation == 'no-local':
                return 1, 'ARCHITECTURE_NET'
            return 0, 'PINNED_BRIEF_187 api.identity\nRULES_FROM_PIN_187\nSTRUCTURE.md'
        if mutant == 'pack-then-refuse':
            reason = 'ARCH_LOCATE_GRAMMAR' if variation.startswith('locate-') else 'ARCH_LINE_MISSING'
            return 1, PACK_MARKER + '777 role=architect kind=task ===\n' + reason
        if (not any(line.startswith('АРХИТЕКТУРА: L1 ') or line.startswith('АРХИТЕКТУРА: L2 ')
                    or line.startswith('АРХИТЕКТУРА: L3 ') for line in text.splitlines())) and mutant != 'allow-line' and variation != 'document-no-local':
            return 1, 'ARCH_LINE_MISSING'
        if 'АРХИТЕКТУРА: L3 ' in text and mutant != 'allow-l3':
            return 1, 'ARCH_OWNER'
        if 'server/src/auth/' in text and mutant != 'allow-unmapped':
            return 1, 'PATH_WITHOUT_COMPONENT'
        if 'app/billing/' in text and mutant != 'allow-zone':
            return 1, 'ARCH_ZONE'
        if mutant == 'locate-first-line':
            return 1, 'ARCH_ZONE: компонент { не объявлен'
        if variation.startswith('locate-') and mutant != 'guess-locate-status':
            return 1, 'ARCH_LOCATE_GRAMMAR'
        revision = git(arch, 'rev-parse', 'HEAD') if mutant == 'use-head' else pinned
        if mutant == 'requires-local' and not (root / 'architecture').exists():
            return 1, 'ARCHITECTURE_NET'
        model = git(arch, 'show', revision + ':tooling/checks/cli.js')
        banner = 'PINNED_BRIEF_187' if 'PINNED_BRIEF_187' in model else 'WRONG_HEAD_BRIEF_187'
        result = banner + ' api.identity'
        needs_rules = role in ('architect', 'critic', 'arbiter')
        if mutant == 'omit-rules': needs_rules = False
        if mutant == 'leak-rules': needs_rules = True
        if needs_rules:
            result += '\\nRULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed'
        if mutant != 'omit-structure': result += '\nSTRUCTURE.md'
        if mutant == 'include-old-doc': result += '\ndocs/ARCHITECTURE.md'
        return 0, result
    if action == 'freeze':
        if not any(line.startswith('АРХИТЕКТУРА: L1 ') for line in contract.splitlines()) and mutant not in ('allow-zone', 'require-all'):
            return 1, 'ARCH_LINE_MISSING'
        if any(drafted(line, mutant) for line in contract.splitlines()
               if line.startswith('ОПЕРАЦИЯ:')) and mutant != 'allow-draft':
            return 1, 'ARCH_DRAFT'
        if variation in ('container-file', 'container-escape', 'container-unplaced'):
            # 187а-ремонт-2 (второй дефект двери): честный контроль читает
            # размещение СТРУКТУРНО через locate_answer — единый источник с
            # toy-CLI. Граница компонента судится по НЕПУСТОМУ набору каталога:
            # пустой набор каталога-контейнера — не претензия (frozen 187/1
            # судит путь СВОИМ размещением, не набором каталога); ДРУГОЙ
            # непустой набор — выход за границу; неоднозначный путь — не размещён.
            path = next(line[len('ЗОНА implementer:'):].strip()
                        for line in contract.splitlines()
                        if line.startswith('ЗОНА implementer:'))
            dkind, dmatches = locate_answer(parent_dir(path))
            dcomps = union_components(dmatches) if dkind == 'declared' else []
            kind, matches = locate_answer(path)
            fcomps = union_components(matches) if kind == 'declared' else []
            if mutant == 'dir-same-set-required' and fcomps and dkind == 'declared' \
                    and not dcomps:
                # обман (текущая дверь): каталог-контейнер без компонентов —
                # PATH_WITHOUT_COMPONENT «компонент не назван» на каталоге
                return 1, (f'PATH_WITHOUT_COMPONENT: путь {parent_dir(path)} '
                           'размещён моделью, но компонент не назван')
            if mutant == 'boundary-skipped':
                dcomps = []  # обман: всё размещённое проходит без проверки компонента
            if kind == 'unresolved-multi':
                return 1, (f'PATH_WITHOUT_COMPONENT: путь {path} не размещён однозначно '
                           'в закреплённой модели (несколько претендентов)')
            if fcomps and dcomps and set(dcomps) != set(fcomps):
                return 1, f'ARCH_ZONE: путь {path} вне границы компонента'
            ids = line_components(contract)
            if not (set(fcomps) & set(ids)):
                return 1, (f'ARCH_ZONE: путь {path} отнесён моделью к компоненту '
                           f'{fcomps[0]}, а строка «АРХИТЕКТУРА:» называет {",".join(ids)}')
            return 0, ''
        if variation in ('outside-runtime', 'outside-false', 'outside-noflag',
                         'unresolved-zero-absent', 'unresolved-zero-present',
                         'area-without-component'):
            # 187а-ремонт-3 + ремонт-4: честный контроль читает ответ
            # СТРУКТУРНО через locate_answer — единый источник с toy-CLI.
            # Непродуктовость — ПРИЗНАК МОДЕЛИ (outsideProductRuntime матча,
            # не префикс пути и не id модуля): путь модуля с true пропущен,
            # ЯВНЫЙ false или ОТСУТСТВУЮЩИЙ флаг при ПУСТЫХ components —
            # прежний отказ frozen 187/1. Д4: суждение размещения — только
            # там, где модель ПРИТЯЗАЕТ на путь: UNRESOLVED с ПУСТЫМИ
            # matches (вне всех областей модели) — не судить, строка «вне
            # модели: <путь>» в сообщении rc 0 (диск не участвует);
            # UNRESOLVED с НЕПУСТЫМИ matches (область модели без компонента)
            # — прежний отказ. Стабы: «признак по префиксу tests/», «всё
            # безкомпонентное проходит», «судит ноль-матчей как неразмещённый»
            # — каждая ветвь своей клетке (Н-39).
            ids = line_components(contract)
            paths = [token for line in contract.splitlines()
                     if line.startswith('ЗОНА implementer:')
                     for token in line[len('ЗОНА implementer:'):].split()]
            notes = []
            for path in paths:
                kind, matches = locate_answer(path)
                comps = union_components(matches) if kind == 'declared' else []
                outside = matches[0].get('outsideProductRuntime') \
                    if kind == 'declared' and matches else None
                if kind == 'unresolved-zero':
                    if mutant == 'zero-refused':
                        # обман (текущая дверь): ноль матчей = «неразмещён»,
                        # отказ без различения областей модели и без строки
                        return 1, (f'PATH_WITHOUT_COMPONENT: путь {path} не размещён '
                                   'ни в модели, ни в продукте')
                    notes.append(f'вне модели: {path}')
                    continue
                if not comps:
                    if kind == 'declared' and outside is True:
                        continue  # признак из модели: вне продуктового runtime
                    if mutant == 'tests-prefix-skip' and path.startswith(TESTS_PREFIX):
                        continue  # обман: пропуск по префиксу tests/, флаг не читается
                    if mutant == 'empty-any-green':
                        continue  # обман: всё безкомпонентное проходит (и в области модели)
                    if kind == 'declared':
                        return 1, (f'PATH_WITHOUT_COMPONENT: путь {path} размещён '
                                   'моделью, но компонент не назван')
                    return 1, (f'PATH_WITHOUT_COMPONENT: путь {path} не размещён однозначно '
                               'в закреплённой модели (несколько претендентов)')
                if not set(comps) & set(ids):
                    return 1, (f'ARCH_ZONE: путь {path} отнесён моделью к компоненту '
                               f'{comps[0]}, а строка «АРХИТЕКТУРА:» называет {",".join(ids)}')
            return 0, '\n'.join(notes)
        if 'server/src/auth/' in contract and mutant != 'allow-zone':
            return 1, 'PATH_WITHOUT_COMPONENT'
        if 'app/billing/' in contract and mutant != 'allow-zone':
            return 1, 'ARCH_ZONE'
        return (1, 'ARCH_LINE_MISSING') if mutant == 'require-all' else (0, '')
    if action == 'precritic':
        if variation == 'real-latency':
            # 187а-ремонт: зелёный rc 0 с НЕПУСТЫМ unresolved latency.* (живая
            # форма пина 907e9e80: rc=0, requiredModelGate PASS, findings [],
            # общий status NOT_EVALUATED только из-за latency.*) — конформ;
            # подстрочный поиск NOT_EVALUATED во всём выводе — обман (текущая
            # дверь), стаб status-substring.
            if mutant == 'status-substring':
                return 1, 'ARCH_NOT_EVALUATED: check --base модели не вынес вердикта (rc=0)'
            return 0, ''
        lock = json.loads((root / 'architecture.lock.json').read_text())
        args = ['--base', SNAPSHOT, '--base-digest', lock['snapshotDigest']]
        if mutant == 'bare-base': args = ['--base']
        if mutant == 'omit-digest': args = ['--base', SNAPSHOT]
        if mutant == 'self-digest':
            args = ['--base', SNAPSHOT, '--base-digest',
                    digest(json.loads(git(arch, 'show', f'{pinned}:{SNAPSHOT}')))]
        check_rc, _ = toy_check(arch, pinned, args)
        if check_rc == 2 and mutant != 'rc2-green': return 1, 'ARCH_NOT_EVALUATED'
        if check_rc and mutant != 'skip-check': return 1, 'ARCH_CHECK'
        return 0, ''
    if action == 'done':
        if not any(line.startswith('СВЕРКА-АРХИТЕКТУРЫ:') and
                   line[len('СВЕРКА-АРХИТЕКТУРЫ:'):].strip()
                   for line in (root / REVIEW).read_text().splitlines()) and mutant != 'ignore-review':
            return 1, 'ARCH_REVIEW'
        response = json.loads(ci_record(root).read_text())
        runs = response['check_runs']
        arch_runs = [r for r in runs if r.get('name') == 'arch']
        final = git(root, 'rev-parse', 'refs/remotes/origin/main' if mutant == 'sha-from-origin-ref' else 'HEAD')
        if mutant != 'ignore-ci' and (not arch_runs or
                                      arch_runs[-1].get('head_sha') != final or
                                      arch_runs[-1].get('status') != 'completed' or
                                      arch_runs[-1].get('conclusion') != 'success'):
            return 1, 'ARCH_CI'
        return 0, ''
    if action == 'door':
        if variation == 'real-gate-ne':
            # 187а-ремонт: rc 2 инструмента — requiredModelGate NOT_EVALUATED
            # (форма пина, cli.js:305): ARCH_NOT_EVALUATED СВОИМ rc 2 двери,
            # не схлопнутым в rc 1; стаб «пропускает rc 2» — зелёный.
            if mutant == 'rc2-green':
                return 0, 'ARCH_187A_OK: архитектура сходится с закреплённой моделью'
            return 2, 'ARCH_NOT_EVALUATED: check --base модели не вынес вердикта (rc=2)'
        if variation == 'real-gate-fail':
            # 187а-ремонт: rc 1 инструмента — requiredModelGate FAIL (cli.js:304):
            # ARCH_CHECK rc 1; защита «gate != PASS → ARCH_NOT_EVALUATED»
            # красный вердикт модели не съедает (стаб gate-fail-not-evaluated).
            if mutant == 'gate-fail-not-evaluated':
                return 2, 'ARCH_NOT_EVALUATED: check --base модели не вынес вердикта (rc=1)'
            return 1, 'ARCH_CHECK: check --base модели красный (rc=1)'
        if variation == 'real-gate-lie':
            # 187а-ремонт, защита: requiredModelGate != PASS при rc 0 — тело,
            # которого настоящий инструмент не излучает (cli.js:304-306); дверь
            # не доверяет одному rc — именованный ARCH_NOT_EVALUATED (стаб
            # gate-ignored).
            if mutant == 'gate-ignored':
                return 0, 'ARCH_187A_OK: архитектура сходится с закреплённой моделью'
            return 2, 'ARCH_NOT_EVALUATED: requiredModelGate не PASS (rc=0)'
    raise RuntimeError('unknown action')

def live(tools, root, arch, pinned, action, task, trace, role):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(root), ARCHITECTURE_ROOT=str(arch))
    if action == 'done':
        env['ARCH187_CURL_RESPONSE'] = str(ci_record(root))
        env['PATH'] = str(ci_bin(root)) + os.pathsep + env.get('PATH', '')
    if action == 'wiring':
        return run('bash', TOOLS / 'fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh',
                   '--wiring', root, cwd=root, env=env)
    if action == 'door':
        return run('bash', tools / 'scripts/check_architecture_contract.sh', '--repo', root,
                   CONTRACT, cwd=root, env=env)
    if action == 'task':
        command = ['bash', tools / 'scripts/make_task.sh', '--repo', root, '--role', role,
                   '--kind', 'task', '--contract', '777', '--task-file', task,
                   '--model-trace', trace, '--arch-component', 'api.identity']
    else:
        command = {'freeze': ['bash', tools / 'scripts/freeze_contract.sh', CONTRACT, 'toy reason', root],
                   'precritic': ['bash', tools / 'scripts/pre_critic.sh', '--repo', root, CONTRACT],
                   'done': ['bash', tools / 'scripts/done_contract.sh', CONTRACT, 'toy reason', root]}[action]
    return run(*command, cwd=root, env=env)

def main():
    import argparse
    p = argparse.ArgumentParser()
    modes = p.add_mutually_exclusive_group()
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--repo', type=Path)
    args = p.parse_args()
    tools = args.repo.resolve() if args.repo else TOOLS
    failures = []
    with tempfile.TemporaryDirectory(prefix='workflow-187-') as temp:
        base = Path(temp)
        for label, action, variation, expected, reason, _ in CASES:
            kind = 'mobile' if variation == 'mobile' else 'harness' if variation == 'harness' else 'backend'
            root = world(base, label, kind)
            arch, pinned = architecture(base, root, variation)
            task, trace, role = prepare(root, arch, pinned, variation)
            honest_rc, honest_out = verdict(root, arch, pinned, action, task, role, variation=variation)
            if honest_rc != expected or (reason and reason not in honest_out):
                raise RuntimeError(f'broken fixture: {label} expected {expected}/{reason}, got {honest_rc}/{honest_out}')
            if args.model or args.stabs:
                rc, output = honest_rc, honest_out
            else:
                result = live(tools, root, arch, pinned, action, task, trace, role)
                rc, output = result.returncode, result.stdout + result.stderr
            ok = (rc == expected and (not reason or reason in output))
            if action == 'task' and expected and PACK_MARKER in output:
                ok = False
            if action == 'task' and not expected:
                if 'PINNED_BRIEF_187' not in output or 'WRONG_HEAD_BRIEF_187' in output:
                    ok = False
                if 'STRUCTURE.md' not in output or 'docs/ARCHITECTURE.md' in output:
                    ok = False
                if role == 'implementer' and 'RULES_FROM_PIN_187' in output:
                    ok = False
                if role in ('architect', 'critic', 'arbiter') and 'RULES_FROM_PIN_187' not in output:
                    ok = False
            if not args.model and not args.stabs and expected and action in ('freeze', 'done'):
                marker = 'frozen' if action == 'freeze' else 'done'
                if git(root, 'tag', '-l', marker + '/contracts/777/*'): ok = False
            if not ok: failures.append(label)
            print(f'{"GREEN" if ok else "RED"} {label}: rc={rc} expected={expected}' +
                  (f' reason={reason}' if reason else '') + (f' output={output[:350]!r}' if not ok else ''))
            if args.stabs:
                for name, (case, mutant) in STABS.items():
                    if case != label: continue
                    fake_rc, fake_out = verdict(root, arch, pinned, action, task, role, mutant, variation=variation)
                    caught = fake_rc != expected or (reason and reason not in fake_out)
                    if action == 'task' and expected and PACK_MARKER in fake_out:
                        caught = True
                    if not expected and action == 'task':
                        caught = caught or ('PINNED_BRIEF_187' not in fake_out or
                            'WRONG_HEAD_BRIEF_187' in fake_out or
                            'STRUCTURE.md' not in fake_out or
                            'docs/ARCHITECTURE.md' in fake_out or
                            (role == 'implementer' and 'RULES_FROM_PIN_187' in fake_out) or
                            (role in ('architect', 'critic', 'arbiter') and 'RULES_FROM_PIN_187' not in fake_out))
                    print(f'STAB {name} {"caught" if caught else "ZHIV"} @ {label}')
                    if not caught: failures.append(name)
        print(f'CELLS={len(CASES)} STABS={len(STABS) if args.stabs else 0} FAILURES={len(failures)}')
    return int(bool(failures))

if __name__ == '__main__':
    raise SystemExit(main())
