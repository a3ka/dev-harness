#!/usr/bin/env python3
# Батарея контракта 110 «Done волны» — fixtures/workshop_project/done_volny_110/.
# Круг 3 (арбитраж contracts-110-kvantor-v1, Решение 2): правила К/H/М —
# квантор множественных осей замкнут произведением «класс отказа × позиция ≥ 2»,
# каждый HEAD-источник — клеткой «красный HEAD / зелёное дерево», каждый
# именованный отказ манифеста — клеткой; в матрицу добавлены десять декоев
# критика круга 2 байт-в-байт; круг 2 РЕАЛИЗАЦИИ (вердикты impl-v1: Adv110
# §2/§3 + Rev110 Б1) — 19 клеток: 13 заглушек D* + A1/A1b/A2/A3/A4/Б1 и
# столько же мутантов (модель чинится под них: pin HEAD, корень-репозиторий,
# профиль на HEAD, грязное дерево, cleanup=verbatim). Круг 3 РЕАЛИЗАЦИИ
# (вердикты impl-v2: Adv110r2 N2/N11b/N1/E1/E3/E5/E6/E10/E11 + Rev110r2 Б3,
# решения оркестратора 2026-10-20) — 13 клеток и 12 мутантов: N1 закрыт
# вариантом (a) («команда не на HEAD», флаг клетки d2 вынесен за пределы
# корня), N2 — «не удалось определить состояние рабочего дерева», N3 —
# porcelain -z (кириллица/пробелы в пути грязного файла), N11b — слой по
# profilePath из HEAD-блоба harness.project.json, Б3 — причина из одних
# «#»-строк ЛЕГАЛЬНА (ok-клетка; клетки E4 НЕТ — после решения Б3 заглушка
# E4 совпадает с честным поведением). Три режима:
#   (по умолчанию)  субъект scripts/done_wave.sh; до реализации — КРАСНАЯ с
#                    именованным отказом «110: дверь done_wave не существует»;
#   --model         честная модель model/done_wave_model.sh: все 84 случая;
#   --matrix        мутанты модели (62): каждый обязан быть различим ≥1 случаем;
#   --case ИМЯ      один случай (неизвестное имя — rc 2, не-плацебо диспетчер);
#   --mutant ИМЯ    один мутант (отладка матрицы).
# Ожидания — ЛИТЕРАЛЫ ниже (Н-351): не вычисляются ни моделью, ни субъектом.
# Оракул refs снимается в память ДО вызова субъекта (правило 8); оракул тега
# (Б6) проверяет ТИП (аннотированный), peeled-цель == HEAD до вызова и причину
# в аннотации — независимо от stdout субъекта. Мир строит проверяющий;
# одноразовые git-каталоги удаляются после прогона.
import copy
import json
import os
import shutil
import subprocess
import sys
import tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
MODEL = os.path.join(HERE, 'model', 'done_wave_model.sh')
SUBJECT = os.path.join(TOOLS, 'scripts', 'done_wave.sh')
# Мутант-копии модели живут вне дерева — модель берёт каталог инструментов
# из WAVE110_TOOLS (fallback после собственного относительного подъёма).
os.environ.setdefault('WAVE110_TOOLS', TOOLS)

W = '3'
REASON = 'волна 3 принята уровнем Б'
REASON_OWNER = 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: повторный приём волны 3'

PLAN_HEADER = 'id\tпара\tэтап\tзависит\tисточник\tтрек'

# ── честная композиция (значения по умолчанию мира) ───────────────────────────
# Источник строк плана — 'abc1234' (hex-7): настоящая грамматика lib_plan/084
# (Б8: миры круга 1 несли 'src', который канонический plan_parse отвергает).
NFR_OK_CMD = "printf 'zamer: ci-legkij 95 s\\n'"
NFR_OK_RE = r'zamer: ci-legkij ([0-9]+) s'

DEFAULT_MANIFEST = [
    ['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE, 'le', '120'],
    ['e2e', 'exit 0'],
    ['review', '.review/volna.md'],
    ['otkat', 'docs/otkat-volny.md'],
]
OTKAT_OK = ('риск: рискованное изменение волны\n'
            'sha: abc123def\n'
            'команда-отката: git revert abc123def\n'
            'команда-проверки: bash fixtures/proverka.sh\n')
LAYER_DECO = json.dumps(
    {'schemaVersion': 1, 'version': '1', 'projectId': 'p', 'workspaceId': 'w',
     'defaults': {'workflowPaths': {'contracts': 'contracts',
                                    'verdicts': 'verdicts',
                                    'registry': 'registry',
                                    'fixtures': 'fixtures'}}})


def git(root, *args, rc_ok=(0,)):
    r = subprocess.run(['git', '-C', root] + list(args),
                       capture_output=True, text=True, timeout=60)
    if r.returncode not in rc_ok:
        raise RuntimeError('git %s: rc=%d %s' % (args, r.returncode, r.stderr))
    return r


def plan_file(rows):
    return PLAN_HEADER + '\n' + \
        ''.join('%s\t%s\tдо V-2\t-\tabc1234\ttrack\n' % (i, p) for i, p in rows)


def build_world(spec):
    root = tempfile.mkdtemp(prefix='wave110-')
    ident = ['-c', 'user.name=Proba', '-c', 'user.email=proba@local']
    subprocess.run(['git'] + ident + ['init', '-q', '-b', 'main', root],
                   check=True, capture_output=True)

    def put(rel, content):
        path = os.path.join(root, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)

    reg = spec.get('registry_dir', 'registry')
    if spec.get('profile'):
        # Б9: валидный профиль проекта (грамматика 996, как toy-мир rezhim_996):
        # резолвер обязан выбрать профильный реестр, корневой registry/ — деко.
        origin = root + '.origin.git'
        subprocess.run(['git', 'init', '--bare', '-q', origin],
                       check=True, capture_output=True)
        git(root, 'remote', 'add', 'origin', origin)
        layer_rel = spec.get('profile_path', 'project-layer.json')
        prof = {'schemaVersion': 1, 'repoId': 'wave110-toy', 'language': 'typescript',
                'projectLayer': {'version': '1', 'profilePath': layer_rel},
                'git': {'canonicalRemote': origin},
                'commands': dict.fromkeys(['test', 'lint', 'typecheck', 'build'],
                                          'bash check.sh'),
                'ci': {'workflow': '.github/workflows/toy.yml'},
                'barriers': {'mandatory': [], 'optional': []}}
        if spec.get('repo_wf', True):
            # E3/N11b: репо-слой БЕЗ workflowPaths — реестр несёт слой
            # (defaults.workflowPaths), как в мирах адверсария (attack6).
            prof['workflowPaths'] = {'contracts': '.harness/tasks',
                                     'verdicts': '.harness/judgements',
                                     'registry': reg,
                                     'fixtures': '.harness/probes'}
        put('harness.project.json', json.dumps(prof))
        if not spec.get('no_layer_commit'):
            put(layer_rel, json.dumps({'schemaVersion': 1, 'version': '1',
                                       'projectId': 'p', 'workspaceId': 'w',
                                       'defaults': {}}))
        put('check.sh', '#!/bin/sh\ntrue\n')
        put('AGENTS.md', '# Toy project\n')
        put('.github/workflows/toy.yml',
            'name: toy\non: push\njobs:\n  check:\n    runs-on: ubuntu-latest\n'
            '    steps:\n      - run: bash check.sh\n')
        put('package.json', json.dumps({'private': True}))

    plan_rows = spec.get('plan_rows', [('111', W), ('sim-a', W)])
    put('%s/plan.tsv' % reg, spec.get('plan_content') or plan_file(plan_rows))
    closed = spec.get('closed', ['sim-a'])
    if closed:
        put('%s/closed-without-done.tsv' % reg,
            ''.join('%s\tрешение владельца\n' % c for c in closed))
    manifest = spec.get('manifest', DEFAULT_MANIFEST)
    # outside_files (решение N1 (a)): файлы ВНЕ корня (root+'.out'); плейсхолдер
    # @W110_OUT@ в значениях манифеста раскрывается абсолютным путём каталога.
    outdir = root + '.out'
    if spec.get('outside_files'):
        os.makedirs(outdir, exist_ok=True)
        for orel, ocontent in spec['outside_files'].items():
            with open(os.path.join(outdir, orel), 'w', encoding='utf-8') as f:
                f.write(ocontent)
    if manifest is not None:
        put('%s/waves/%s.tsv' % (reg, W),
            ''.join('\t'.join(r) + '\n' for r in manifest).replace(
                '@W110_OUT@', outdir))
    if 'root_decoy' in spec:
        # Б9: корневой деко — завершённая волна 111 + честный манифест:
        # мутант, читающий корень вместо профиля, уходит в зелёный ложный done.
        put('registry/plan.tsv', plan_file(spec['root_decoy'].get('plan_rows',
                                                                  [('111', W)])))
        put('registry/waves/%s.tsv' % W,
            ''.join('\t'.join(r) + '\n' for r in spec['root_decoy'].get(
                'manifest', DEFAULT_MANIFEST)))
    review = spec.get('review', {'.review/volna.md': 'status: done\nнаходка волны\n'})
    for rel, content in review.items():
        put(rel, content)
    put(spec.get('otkat_path', 'docs/otkat-volny.md'),
        spec.get('otkat_content', OTKAT_OK))
    # extra_files — части мира, коммитимые ДО тегов (e2e.sh, sub/registry).
    for rel, content in spec.get('extra_files', {}).items():
        put(rel, content)
    git(root, 'add', '-A')
    git(root, *ident, 'commit', '-q', '-m', 'мир волны')
    for num in spec.get('done_ids', ['111']):
        git(root, *ident, 'tag', '-a', 'done/contracts/%s/1' % num, '-m', 'done')
    for tag in spec.get('other_tags', []):
        git(root, *ident, 'tag', '-a', tag, '-m', 'pre')
    # Правило H (круг 3): незакоммиченная правка ПРОИЗВОЛЬНОГО пути после
    # коммита и тегов — обобщённый механизм (замена частного plan_worktree):
    # каждый HEAD-источник получает клетку «на HEAD красно, в дереве зелено».
    for rel, content in spec.get('worktree_files', {}).items():
        put(rel, content)
    # rm_files — удаление отслеживаемых файлов ПОСЛЕ коммита (A2: профиль).
    for rel in spec.get('rm_files', []):
        os.remove(os.path.join(root, rel))
    # stage_files (E1): правка, ПОСТАВЛЕННАЯ В ИНДЕКС (git add) без коммита —
    # видна status --porcelain, невидима git diff --name-only.
    for rel, content in spec.get('stage_files', {}).items():
        put(rel, content)
        git(root, 'add', '--', rel)
    # corrupt_index (N2): испорченный .git/index — git status обязан упасть,
    # а не читаться как «дерево чисто».
    if spec.get('corrupt_index'):
        with open(os.path.join(root, '.git', 'index'), 'wb') as f:
            f.write(b'garbage')
    # linked_worktree (E6): честный мир в linked worktree (.git — файл).
    if spec.get('linked_worktree'):
        git(root, 'worktree', 'add', '--detach', '-q', root + '.wt')
    return root


def refs_snapshot(root):
    return git(root, 'for-each-ref', '--format=%(refname) %(objectname)').stdout


def wave_tags(root, wave):
    return git(root, 'tag', '-l', 'done/waves/%s/*' % wave).stdout.split()


def check_ok(root, wave, want_v, head_before, reason, rc, out, err,
             tags, before, after, refnames_only=False):
    # Оракул положительной ветви (Б6): принимаемый HEAD снят ДО вызова; тег
    # обязан быть АННОТИРОВАННЫМ (objecttype=tag), указывать peeled-целью на
    # сохранённый КОММИТ и нести причину в аннотации; новых refs — ровно один
    # (Б1: внешняя команда e2e может двигать ветки — тогда сравниваются только
    # ИМЕНА refs: новые имена = ровно сам тег волны).
    tag = 'done/waves/%s/%d' % (wave, want_v)
    info = git(root, 'for-each-ref',
               '--format=%(objecttype) %(*objecttype) %(*objectname)',
               'refs/tags/' + tag).stdout.strip()
    ann = git(root, 'tag', '-l', '--format=%(contents)', tag).stdout
    if refnames_only:
        new_names = sorted(set(l.split()[0] for l in after.splitlines())
                           - set(l.split()[0] for l in before.splitlines()))
        refs_ok = new_names == ['refs/tags/%s' % tag]
        refs_detail = 'new_refnames=%s' % new_names
    else:
        new_lines = [l for l in after.splitlines() if l not in before.splitlines()]
        refs_ok = len(new_lines) == 1 and new_lines[0].startswith('refs/tags/%s ' % tag)
        refs_detail = 'new_refs=%d' % len(new_lines)
    good = (rc == 0 and out.strip() == 'v%d' % want_v
            and tag in tags
            and info == 'tag commit %s' % head_before
            and reason in ann
            and refs_ok)
    return good, ('rc=%s out=%r tag=%r info=%r ann_has_reason=%s %s'
                  % (rc, out.strip(), tag in tags, info, reason in ann,
                     refs_detail))


def run_subject(subject, root, wave, reason):
    try:
        r = subprocess.run(['bash', subject, root, wave, reason],
                           capture_output=True, text=True, timeout=120)
        return r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        return 124, '', 'таймаут субъекта'


# ── закрытый перечень случаев (произведение осей контракта §Приёмка) ─────────
# Круг 3, правила К/H/М арбитража: каждый класс отказа множественной оси — в
# позиции 1 И позиции ≥ 2 + положительный контроль ≥ 2 честных элементов;
# каждый HEAD-источник — клеткой «красный HEAD / зелёное дерево»; именованные
# отказы манифеста — клетками; тег — разрыв версий; NFR — граница равенства.
CASES = [
    ('wave_done_all', {}, ('ok', 1)),
    ('wave_row_frozen', {'done_ids': [], 'other_tags': ['frozen/contracts/111/1']},
     ('refuse', 'строка волны не терминальна: 111 (нет done-тега)')),
    ('wave_row_issued', {'done_ids': [], 'other_tags': ['id/CONTRACT/111']},
     ('refuse', 'строка волны не терминальна: 111 (нет done-тега)')),
    ('wave_symbol_open', {'plan_rows': [('sim-a', W)], 'closed': []},
     ('refuse', 'символьная строка без закрытия владельца')),
    ('wave_empty', {'wave': '77'}, ('refuse', 'волна 77 пуста')),
    ('wave_plan_dirty', {'plan_rows': [('111', W), ('sim-b', W)], 'closed': [],
                         'worktree_files': {'registry/plan.tsv':
                                            PLAN_HEADER + '\n111\t3\tдо V-2\t-\tabc1234\ttrack\n'}},
     ('refuse', 'строка волны не терминальна: sim-b не начат')),
    # Б2: вторая числовая задача волны не терминальна + положительный контроль
    ('wave_second_numeric_open', {'plan_rows': [('111', W), ('112', W)],
                                  'closed': [], 'done_ids': ['111']},
     ('refuse', 'строка волны не терминальна: 112 (нет done-тега)')),
    ('wave_two_numeric_done', {'plan_rows': [('111', W), ('112', W)],
                               'closed': [], 'done_ids': ['111', '112']},
     ('ok', 1)),
    ('nfr_ge_ok', {'manifest': [['nfr', 'glubina', "printf 'zamer: glubina 5\\n'",
                                 r'zamer: glubina ([0-9]+)', 'ge', '3'],
                                ['e2e', 'exit 0'],
                                ['review', '.review/volna.md'],
                                ['otkat', 'docs/otkat-volny.md']]}, ('ok', 1)),
    ('nfr_over_le', {'manifest': [['nfr', 'ci-legkij', "printf 'zamer: ci-legkij 121 s\\n'",
                                   NFR_OK_RE, 'le', '120'],
                                  ['e2e', 'exit 0'],
                                  ['review', '.review/volna.md'],
                                  ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR ci-legkij: 121 не le 120')),
    # Б3: первая метрика зелёная, ВТОРАЯ вне порога — квантор по всем nfr-строкам
    ('nfr_second_over', {'manifest': [['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE,
                                       'le', '120'],
                                      ['nfr', 'second', "printf 'metric 121\\n'",
                                       r'metric ([0-9]+)', 'le', '120'],
                                      ['e2e', 'exit 0'],
                                      ['review', '.review/volna.md'],
                                      ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR second: 121 не le 120')),
    ('nfr_no_metric', {'manifest': [['nfr', 'ci-legkij', "printf 'vse horosho\\n'",
                                     NFR_OK_RE, 'le', '120'],
                                    ['e2e', 'exit 0'],
                                    ['review', '.review/volna.md'],
                                    ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR ci-legkij: метрика не найдена')),
    ('nfr_cmd_fail', {'manifest': [['nfr', 'ci-legkij', 'exit 3', NFR_OK_RE, 'le', '120'],
                                   ['e2e', 'exit 0'],
                                   ['review', '.review/volna.md'],
                                   ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR ci-legkij: команда rc=3')),
    ('nfr_ge_below', {'manifest': [['nfr', 'glubina', "printf 'zamer: glubina 2\\n'",
                                    r'zamer: glubina ([0-9]+)', 'ge', '3'],
                                   ['e2e', 'exit 0'],
                                   ['review', '.review/volna.md'],
                                   ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR glubina: 2 не ge 3')),
    # Б1: манифест без единой nfr-строки — уровень Б без чисел не существует
    ('nfr_none', {'manifest': [['e2e', 'exit 0'],
                               ['review', '.review/volna.md'],
                               ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'манифест волны не объявил численных NFR')),
    ('e2e_red', {'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'exit 1'],
                              DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]]},
     ('refuse', 'сквозной запуск волны красный: rc=1')),
    # Б7: ОДИН мир, ДВЕ двери: зелёная e2e → тег v1; манифест починен в красную
    # (коммит) → повторная дверь с РАЗРЕШИЛ-ВЛАДЕЛЕЦ обязана отказать, refs те же.
    ('e2e_fresh_rerun', {'flow': {
        'manifest2': [['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE, 'le', '120'],
                      ['e2e', 'exit 1'],
                      ['review', '.review/volna.md'],
                      ['otkat', 'docs/otkat-volny.md']],
        'reason2': REASON_OWNER,
        'expect2': ('refuse', 'сквозной запуск волны красный: rc=1')}},
     ('ok', 1)),
    ('review_ready', {'review': {'.review/volna.md': 'status: ready\nнаходка волны\n'}},
     ('refuse', 'находка владельца открыта: .review/volna.md status=ready')),
    # Б4: первая находка закрыта, ВТОРАЯ открыта + положительный контроль
    ('review_second_ready', {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                                          ['review', '.review/volna.md'],
                                          ['review', '.review/second.md'],
                                          DEFAULT_MANIFEST[3]],
                             'review': {'.review/volna.md': 'status: done\nнаходка волны\n',
                                        '.review/second.md': 'status: ready\nвторая находка\n'}},
     ('refuse', 'находка владельца открыта: .review/second.md status=ready')),
    ('review_two_done', {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                                      ['review', '.review/volna.md'],
                                      ['review', '.review/second.md'],
                                      DEFAULT_MANIFEST[3]],
                         'review': {'.review/volna.md': 'status: done\nнаходка волны\n',
                                    '.review/second.md': 'status: done\nвторая находка\n'}},
     ('ok', 1)),
    # Б5: внутренние пробелы в статусе — вне литеральной грамматики, находка открыта
    ('review_status_spaces', {'review': {'.review/volna.md':
                                         'status: d o n e\nнаходка волны\n'}},
     ('refuse', 'находка владельца открыта: .review/volna.md status=d o n e')),
    ('review_missing', {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                                     ['review', '.review/net.md'], DEFAULT_MANIFEST[3]]},
     ('refuse', 'находка владельца отсутствует на HEAD: .review/net.md')),
    ('otkat_missing', {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                                    DEFAULT_MANIFEST[2], ['otkat', 'docs/net-otkat.md']]},
     ('refuse', 'план отката отсутствует: docs/net-otkat.md')),
    ('otkat_no_field', {'otkat_content': 'риск: есть\nкоманда-отката: git revert abc\n'
                                         'команда-проверки: bash x\n'},
     ('refuse', 'план отката без поля: sha')),
    ('manifest_missing', {'manifest': None}, ('refuse', 'манифест волны отсутствует')),
    ('manifest_unknown', {'manifest': DEFAULT_MANIFEST + [['audit', 'chto-to']]},
     ('refuse', 'строка манифеста вне алфавита: audit')),
    ('manifest_dup_e2e', {'manifest': DEFAULT_MANIFEST + [['e2e', 'exit 0']]},
     ('refuse', 'e2e строка не одна')),
    ('manifest_no_e2e', {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[2],
                                      DEFAULT_MANIFEST[3]]},
     ('refuse', 'манифест волны не объявил сквозной запуск')),
    # Б8: план без заголовка — канонический plan_parse отказывает; второй
    # парсер «NR>1» молча съедает первую задачу и должен быть пойман
    ('plan_no_header', {'plan_content':
                        '111\t3\tдо V-2\t-\tabc1234\ttrack\n'
                        '112\t3\tдо V-2\t-\tabc1234\ttrack\n',
                        'done_ids': ['111']},
     ('refuse', 'план не разбирается: строка 1:')),
    # Б9: профильный реестр (.harness/ledger) с незавершённой 112; корневой
    # registry/ — деко с завершённой волной и честным манифестом
    ('profile_registry', {'profile': True, 'registry_dir': '.harness/ledger',
                          'plan_rows': [('111', W), ('112', W)], 'closed': [],
                          'done_ids': ['111'],
                          'root_decoy': {'plan_rows': [('111', W)]}},
     ('refuse', 'строка волны не терминальна: 112 (нет done-тега)')),
    ('tag_v2_valve', {'other_tags': ['done/waves/3/1']},
     ('refuse', 'требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ')),
    ('tag_v2_allowed', {'other_tags': ['done/waves/3/1'], 'reason': REASON_OWNER},
     ('ok', 2)),
    ('refuse_no_mutation', {'manifest': [['nfr', 'ci-legkij',
                                          "printf 'zamer: ci-legkij 121 s\\n'",
                                          NFR_OK_RE, 'le', '120'],
                                         ['e2e', 'exit 0'],
                                         ['review', '.review/volna.md'],
                                         ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR ci-legkij: 121 не le 120')),
    ('reason_empty', {'reason': ''}, ('refuse', 'причина пуста')),
    # ── круг 3: правила К/H/М арбитража contracts-110-kvantor-v1 (Решение 2) ───
    # Правило К, членство (И-2): класс «символьная без закрытия» в позиции ≥ 2
    # (первая символьная закрыта) + положительный контроль двух символьных.
    ('wave_second_symbolic_open',
     {'plan_rows': [('111', W), ('sim-a', W), ('sim-b', W)], 'closed': ['sim-a']},
     ('refuse', 'строка волны не терминальна: sim-b не начат')),
    ('wave_two_symbolic_closed',
     {'plan_rows': [('111', W), ('sim-a', W), ('sim-b', W)],
      'closed': ['sim-a', 'sim-b']},
     ('ok', 1)),
    # Правило К, NFR (И-4): rc≠0 и «метрика не найдена» в позиции 2 — число
    # второй команды в пороге, чтобы отказ не получался по другой оси;
    # контроль двух строк в пороге.
    ('nfr_second_cmd_fail',
     {'manifest': [['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE, 'le', '120'],
                   ['nfr', 'second', "printf 'metric 95\\n'; exit 3",
                    r'metric ([0-9]+)', 'le', '120'],
                   ['e2e', 'exit 0'],
                   ['review', '.review/volna.md'],
                   ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR second: команда rc=3')),
    ('nfr_second_no_metric',
     {'manifest': [['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE, 'le', '120'],
                   ['nfr', 'second', "printf 'vse horosho\\n'",
                    r'metric ([0-9]+)', 'le', '120'],
                   ['e2e', 'exit 0'],
                   ['review', '.review/volna.md'],
                   ['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'NFR second: метрика не найдена')),
    ('nfr_two_ok',
     {'manifest': [['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE, 'le', '120'],
                   ['nfr', 'glubina', "printf 'zamer: glubina 5\\n'",
                    r'zamer: glubina ([0-9]+)', 'ge', '3'],
                   ['e2e', 'exit 0'],
                   ['review', '.review/volna.md'],
                   ['otkat', 'docs/otkat-volny.md']]},
     ('ok', 1)),
    # Правило К, review (И-6): «файла нет» в позиции 2 при честной первой;
    # класс «нет строки status» в обеих позициях.
    ('review_second_missing',
     {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                   ['review', '.review/volna.md'], ['review', '.review/second.md'],
                   DEFAULT_MANIFEST[3]],
      'review': {'.review/volna.md': 'status: done\nнаходка волны\n'}},
     ('refuse', 'находка владельца отсутствует на HEAD: .review/second.md')),
    ('review_no_status_line',
     {'review': {'.review/volna.md': 'находка волны без строки статуса\n'}},
     ('refuse', '.review/volna.md status=нет_строки_status')),
    ('review_second_no_status_line',
     {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                   ['review', '.review/volna.md'], ['review', '.review/second.md'],
                   DEFAULT_MANIFEST[3]],
      'review': {'.review/volna.md': 'status: done\nнаходка волны\n',
                 '.review/second.md': 'вторая находка без строки статуса\n'}},
     ('refuse', '.review/second.md status=нет_строки_status')),
    # Правило H: красный HEAD / зелёное рабочее дерево → отказ по HEAD;
    # правка каждого источника — общий механизм worktree_files build_world.
    ('closed_dirty',
     {'plan_rows': [('111', W), ('sim-a', W)], 'closed': [],
      'worktree_files': {'registry/closed-without-done.tsv':
                         'sim-a\tрешение владельца\n'}},
     ('refuse', 'строка волны не терминальна: sim-a не начат')),
    ('manifest_dirty',
     {'manifest': [['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE, 'le', '120'],
                   ['e2e', 'exit 1'],
                   ['review', '.review/volna.md'],
                   ['otkat', 'docs/otkat-volny.md']],
      'worktree_files': {'registry/waves/3.tsv':
                         ''.join('\t'.join(r) + '\n' for r in DEFAULT_MANIFEST)}},
     ('refuse', 'сквозной запуск волны красный: rc=1')),
    ('review_dirty',
     {'review': {'.review/volna.md': 'status: ready\nнаходка волны\n'},
      'worktree_files': {'.review/volna.md': 'status: done\nнаходка волны\n'}},
     ('refuse', '.review/volna.md status=ready')),
    ('otkat_dirty',
     {'otkat_content': 'риск: есть\n',
      'worktree_files': {'docs/otkat-volny.md': OTKAT_OK}},
     ('refuse', 'план отката без поля: sha')),
    # Правило М: каждый именованный отказ И-3 — клеткой.
    ('manifest_dup_otkat',
     {'manifest': DEFAULT_MANIFEST + [['otkat', 'docs/otkat-volny.md']]},
     ('refuse', 'otkat строка не одна')),
    ('manifest_no_otkat',
     {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                   DEFAULT_MANIFEST[2]]},
     ('refuse', 'манифест волны не объявил план отката')),
    ('manifest_empty', {'manifest': []},
     ('refuse', 'манифест волны пуст')),
    # Тег (И-8): разреженная история — v = max(существующих)+1, не count+1.
    ('tag_gap_max_plus_one',
     {'other_tags': ['done/waves/3/7'], 'reason': REASON_OWNER},
     ('ok', 8)),
    # Граница NFR (И-4): равенство порогу для каждого оператора (le/ge).
    ('nfr_edge_le_ok',
     {'manifest': [['nfr', 'edge', "printf 'metric 120\\n'",
                    r'metric ([0-9]+)', 'le', '120'],
                   ['e2e', 'exit 0'],
                   ['review', '.review/volna.md'],
                   ['otkat', 'docs/otkat-volny.md']]},
     ('ok', 1)),
    ('nfr_edge_ge_ok',
     {'manifest': [['nfr', 'edge', "printf 'metric 120\\n'",
                    r'metric ([0-9]+)', 'ge', '120'],
                   ['e2e', 'exit 0'],
                   ['review', '.review/volna.md'],
                   ['otkat', 'docs/otkat-volny.md']]},
     ('ok', 1)),
    # ── круг 2 реализации: 13 заглушек Adv110 (§3) + A1–A4 (§2) + Б1 Rev110 ────
    # A1: e2e-код зелёный только в рабочем дереве (на HEAD красный) — грязное
    # отслеживаемое дерево не доказывает принятый HEAD (решение: ОТКАЗ).
    ('a1_e2e_worktree_green',
     {'extra_files': {'e2e.sh': 'exit 1\n'},
      'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'bash e2e.sh'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'e2e.sh': 'exit 0\n'}},
     ('refuse', 'рабочее дерево расходится с HEAD')),
    # A1b: NFR-код в пороге только в рабочем дереве (на HEAD 500 вне порога).
    ('a1b_nfr_worktree_green',
     {'extra_files': {'nfr.sh': "printf 'zamer: ci-legkij 500 s\\n'\n"},
      'manifest': [['nfr', 'ci-legkij', 'bash nfr.sh', NFR_OK_RE, 'le', '120'],
                   DEFAULT_MANIFEST[1], DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'nfr.sh': "printf 'zamer: ci-legkij 95 s\\n'\n"}},
     ('refuse', 'рабочее дерево расходится с HEAD')),
    # A2: профильный реестр на HEAD не терминален (112), корневой — зелёный
    # деко; профиль удалён ТОЛЬКО в рабочем дереве — резолвер ушёл бы в деко.
    ('a2_profile_deleted_worktree',
     {'profile': True, 'registry_dir': '.harness/ledger',
      'plan_rows': [('111', W), ('112', W)], 'closed': [], 'done_ids': ['111'],
      'root_decoy': {'plan_rows': [('111', W)]},
      'rm_files': ['harness.project.json']},
     ('refuse', 'профиль проекта расходится с HEAD')),
    # A3: корень = подкаталог репозитория: cat-file-пути уходят к верхушке
    # репо (чужой зелёный реестр) — дверь обязана отказать «не корень».
    ('a3_root_not_toplevel',
     {'root_suffix': '/sub',
      'extra_files': {'sub/registry/plan.tsv': plan_file([('112', W)]),
                      'sub/registry/waves/%s.tsv' % W:
                          ''.join('\t'.join(r) + '\n' for r in DEFAULT_MANIFEST)}},
     ('refuse', 'корень не корень репозитория')),
    # A4: строка владельца начинается с '#' — cleanup=strip срезает её из
    # аннотации тега; аннотация обязана нести причину дословно.
    ('a4_tag_owner_line_hash',
     {'other_tags': ['done/waves/3/1'],
      'reason': 'повторный приём волны 3\n# РАЗРЕШИЛ-ВЛАДЕЛЕЦ: да'},
     ('ok', 2)),
    # Б1: e2e сдвигает HEAD во время работы двери — тег обязан встать на
    # HEAD, снятый ДО вызова (peeled == H0, источники — от него).
    ('b1_head_pinned_tag',
     {'manifest': [DEFAULT_MANIFEST[0],
                   ['e2e', 'git -c user.name=E2e -c user.email=e2e@local '
                           'commit --allow-empty -qm sdvig'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'allow_moved_branch': True},
     ('ok', 1)),
    # D2: кеш e2e по sha HEAD — флаг снят между дверьми того же мира;
    # повторная дверь обязана исполнить e2e заново и отказать. Круг 3 (N1,
    # решение (a)): флаг ВНЕ корня (@W110_OUT@), чтобы ok-клетка осталась
    # законной при отказе «команда не на HEAD» для корневых скриптов.
    ('d2_e2e_cache_head',
     {'manifest': [DEFAULT_MANIFEST[0], ['e2e', '[ -f @W110_OUT@/flag ]'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'outside_files': {'flag': ''},
      'flow': {'rm_files': ['@W110_OUT@/flag'], 'reason2': REASON_OWNER,
               'expect2': ('refuse', 'сквозной запуск волны красный: rc=1')}},
     ('ok', 1)),
    # D3: число — из ПЕРВОЙ подходящей строки вывода (500 вне порога, 95 в).
    ('d3_nfr_first_match_wins',
     {'manifest': [['nfr', 'ci-legkij',
                    "printf 'zamer: ci-legkij 500 s\\nzamer: ci-legkij 95 s\\n'",
                    NFR_OK_RE, 'le', '120'],
                   DEFAULT_MANIFEST[1], DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]]},
     ('refuse', 'NFR ci-legkij: 500 не le 120')),
    # D7: находка отсутствует на HEAD, есть только в рабочем дереве.
    ('d7_review_absent_on_head',
     {'manifest': [DEFAULT_MANIFEST[0], DEFAULT_MANIFEST[1],
                   ['review', '.review/new.md'], DEFAULT_MANIFEST[3]],
      'worktree_files': {'.review/new.md': 'status: done\nновая находка\n'}},
     ('refuse', 'находка владельца отсутствует на HEAD: .review/new.md')),
    # D12: закрытие по префиксу id (закрыт ci-proekta, строка волны ci).
    ('d12_closure_exact_id',
     {'plan_rows': [('111', W), ('ci', W)], 'closed': ['ci-proekta']},
     ('refuse', 'строка волны не терминальна: ci не начат')),
    # D13: хвостовая точка статуса — вне литеральной грамматики.
    ('d13_status_trailing_dot',
     {'review': {'.review/volna.md': 'status: done.\nнаходка волны\n'}},
     ('refuse', '.review/volna.md status=done.')),
    # D14: регистр статуса не сворачивается.
    ('d14_status_uppercase',
     {'review': {'.review/volna.md': 'status: DONE\nнаходка волны\n'}},
     ('refuse', '.review/volna.md status=DONE')),
    # D15: поле отката без якоря начала строки («см. sha: позже»).
    ('d15_otkat_field_anchor',
     {'otkat_content': 'риск: есть\nсм. sha: позже\n'
                       'команда-отката: git revert abc\n'
                       'команда-проверки: bash x\n'},
     ('refuse', 'план отката без поля: sha')),
    # D16: пустое значение поля отката («sha:» без значения).
    ('d16_otkat_empty_value',
     {'otkat_content': 'риск: есть\nsha:\nкоманда-отката: git revert abc\n'
                       'команда-проверки: bash x\n'},
     ('refuse', 'план отката без поля: sha')),
    # D22: e2e rc=2 — отказ обязан назвать фактический rc (не зашитый 1).
    ('d22_e2e_rc2',
     {'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'exit 2'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]]},
     ('refuse', 'сквозной запуск волны красный: rc=2')),
    # D23: NFR-команда rc=1 при числе в пороге (не зашитый 3).
    ('d23_nfr_rc1',
     {'manifest': [['nfr', 'ci-legkij',
                    "printf 'zamer: ci-legkij 95 s\\n'; exit 1",
                    NFR_OK_RE, 'le', '120'],
                   DEFAULT_MANIFEST[1], DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]]},
     ('refuse', 'NFR ci-legkij: команда rc=1')),
    # D25: клапан владельца — на ЛЮБОЙ v>1 (существуют v1 и v2 → v3).
    ('d25_valve_v3',
     {'other_tags': ['done/waves/3/1', 'done/waves/3/2']},
     ('refuse', 'требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ')),
    # D29: команды e2e/NFR исполняются в корне волны (e2e.sh в корне красный;
    # rc=21: фраза не префикс «rc=127» запуска не в корне — substring-ловушка).
    ('d29_commands_in_root',
     {'extra_files': {'e2e.sh': 'exit 21\n'},
      'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'bash e2e.sh'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]]},
     ('refuse', 'сквозной запуск волны красный: rc=21')),
    # D31: оператор/порог — ИЗ СВОЕЙ nfr-строки (вторая ge 3, метрика 1).
    ('d31_nfr_ops_per_row',
     {'manifest': [['nfr', 'ci-legkij', NFR_OK_CMD, NFR_OK_RE, 'le', '120'],
                   ['nfr', 'glubina', "printf 'metric 1\\n'",
                    r'metric ([0-9]+)', 'ge', '3'],
                   DEFAULT_MANIFEST[1], DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]]},
     ('refuse', 'NFR glubina: 1 не ge 3')),
    # ── круг 3 реализации: Adv110r2 (N2/N11b/N1/E1/E3/E5/E6/E10/E11, N3) ─────
    # E1: застейдженная (git add) правка e2e.sh — грязь и против индекса, не
    # только worktree-vs-index; заглушка «git diff --name-only» её не видит.
    ('e1_staged_edit',
     {'extra_files': {'e2e.sh': 'exit 1\n'},
      'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'bash e2e.sh'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'stage_files': {'e2e.sh': 'exit 0\n'}},
     ('refuse', 'рабочее дерево расходится с HEAD')),
    # E3: слой профиля с ЗАШИТЫМ именем project-layer.json не на HEAD, в дереве
    # неотслеживаемый и ведёт в корневой деко-реестр (зелёная подмена).
    ('e3_layer_untracked_deco',
     {'profile': True, 'registry_dir': '.harness/ledger',
      'repo_wf': False, 'no_layer_commit': True,
      'plan_rows': [('111', W), ('112', W)], 'closed': [], 'done_ids': ['111'],
      'root_decoy': {'plan_rows': [('111', W)]},
      'worktree_files': {'project-layer.json': LAYER_DECO}},
     ('refuse', 'профиль проекта расходится с HEAD')),
    # E5: честный мир, корень передан двери через символическую ссылку —
    # сравнение топлевела с ЛОГИЧЕСКИМ путём ложно отказывает (ok-клетка).
    ('e5_root_symlink_ok', {'root_symlink': True}, ('ok', 1)),
    # E6: честный мир в linked worktree (.git — файл): «корень = каталог .git»
    # ложно отказывает; refs общие, тег виден из главного чекаута (ok-клетка).
    ('e6_linked_worktree_ok', {'linked_worktree': True}, ('ok', 1)),
    # E10: грязь под префиксом реестра ($REG_REL/) не освобождается от проверки
    # — исключение источников по ТОЧНЫМ путям, не по каталогу реестра.
    ('e10_registry_prefix_dirty',
     {'extra_files': {'registry/e2e.sh': 'exit 1\n'},
      'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'bash registry/e2e.sh'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'registry/e2e.sh': 'exit 0\n'}},
     ('refuse', 'рабочее дерево расходится с HEAD')),
    # E11: грязь проверяется ДО исполнения команд e2e/NFR — e2e.sh,
    # восстанавливающий себя в дереве (git checkout --), не уходит молча.
    ('e11_dirty_before_commands',
     {'extra_files': {'e2e.sh': 'exit 1\n'},
      'manifest': [DEFAULT_MANIFEST[0],
                   ['e2e', 'git checkout -- e2e.sh; exit 0'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'e2e.sh': 'git checkout -- e2e.sh\nexit 0\n'}},
     ('refuse', 'рабочее дерево расходится с HEAD')),
    # N2: упавший git status (испорченный .git/index) — не «дерево чисто»:
    # имя отказа «не удалось определить состояние рабочего дерева».
    ('n2_status_unreadable',
     {'extra_files': {'e2e.sh': 'exit 1\n'},
      'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'bash e2e.sh'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'e2e.sh': 'exit 0\n'},
      'corrupt_index': True},
     ('refuse', 'не удалось определить состояние рабочего дерева')),
    # N11b: путь слоя — из HEAD-блоба harness.project.json (profilePath), не
    # зашитое имя: слой layer/p.json не на HEAD + деко-реестр из дерева.
    ('n11b_layer_profile_path',
     {'profile': True, 'registry_dir': '.harness/ledger',
      'profile_path': 'layer/p.json', 'repo_wf': False, 'no_layer_commit': True,
      'plan_rows': [('111', W), ('112', W)], 'closed': [], 'done_ids': ['111'],
      'root_decoy': {'plan_rows': [('111', W)]},
      'worktree_files': {'layer/p.json': LAYER_DECO}},
     ('refuse', 'профиль проекта расходится с HEAD')),
    # Б3 (Rev110r2): причина из одних «#»-строк НЕ пуста — при
    # --cleanup=verbatim аннотация несёт её дословно (ok-клетка).
    ('b3_reason_hash_only', {'reason': '#42 волна 3 принята'}, ('ok', 1)),
    # N3a: путь грязного НЕ-источника с кириллицей — отказ называет путь
    # неискажённым (porcelain -z, не awk по закавыченному v1-выводу).
    ('n3a_dirty_cyrillic_path',
     {'extra_files': {'скрипты/e2e-скрипт.sh': 'exit 1\n'},
      'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'bash скрипты/e2e-скрипт.sh'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'скрипты/e2e-скрипт.sh': 'exit 0\n'}},
     ('refuse', 'рабочее дерево расходится с HEAD: скрипты/e2e-скрипт.sh')),
    # N3b: путь грязного НЕ-источника с ПРОБЕЛОМ — отказ называет путь целиком.
    ('n3b_dirty_space_path',
     {'extra_files': {'e2e skript.sh': 'exit 1\n'},
      'manifest': [DEFAULT_MANIFEST[0], ['e2e', "bash 'e2e skript.sh'"],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'e2e skript.sh': 'exit 0\n'}},
     ('refuse', 'рабочее дерево расходится с HEAD: e2e skript.sh')),
    # N1 (решение (a)): файл-скрипт команды e2e (первый токен после
    # интерпретатора, существующий в корне) не отслеживается на HEAD_SHA.
    ('n1_e2e_untracked_script',
     {'manifest': [DEFAULT_MANIFEST[0], ['e2e', 'bash e2e.sh'],
                   DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'e2e.sh': 'exit 0\n'}},
     ('refuse', 'команда не на HEAD: e2e.sh')),
    # N1 (решение (a)), NFR-ветвь: nfr.sh не на HEAD, в дереве печатает метрику.
    ('n1b_nfr_untracked_script',
     {'manifest': [['nfr', 'ci-legkij', 'bash nfr.sh', NFR_OK_RE, 'le', '120'],
                   DEFAULT_MANIFEST[1], DEFAULT_MANIFEST[2], DEFAULT_MANIFEST[3]],
      'worktree_files': {'nfr.sh': "printf 'zamer: ci-legkij 95 s\\n'\n"}},
     ('refuse', 'команда не на HEAD: nfr.sh')),
]

# ── матрица: замены литеральных участков модели; привязка к случаям — ЗДЕСЬ ──
MUTANTS = [
    ('m1_review_done_anything', '[ "$st" = "done" ]', '[ -n "$st" ]'),
    ('m2_nfr_invert', '(o=="le" ? (a<=b) : (a>=b))', '(o=="le" ? (a>=b) : (a<=b))'),
    ('m3_nfr_missing_green', '[ -n "$num" ] || die "NFR $name: метрика не найдена"', ':'),
    ('m4_symbolic_skip',
     '|| die "строка волны не терминальна: $id не начат (символьная строка без закрытия владельца)"',
     '|| :'),
    ('m5_empty_wave_green',
     '[ "$wave_n" -gt 0 ] || die "волна $W пуста: нет строк плана с этой парой"',
     ':'),
    ('m6_plan_from_worktree',
     'git -C "$ROOT" cat-file blob "${HEAD_SHA}:${REG_REL}/plan.tsv" >"$PLAN_TMP" 2>/dev/null',
     'cat "$ROOT/${REG_REL}/plan.tsv" >"$PLAN_TMP" 2>/dev/null'),
    ('m7_refuse_as_success', 'exit 1; }', 'exit 0; }'),
    ('m8_tag_always_v1', 'v=$((vmax + 1))', 'v=1'),
    ('m9_unknown_kind_ignored', '*) die "строка манифеста вне алфавита: $kind"', '*) :'),
    ('m10_dup_e2e_allowed', '[ "$e2e_n" -le 1 ] || die "e2e строка не одна"', ':'),
    ('m11_otkat_fields_skipped', '|| die "план отката без поля: $fld"', '|| :'),
    ('m12_review_missing_ok', '|| die "находка владельца отсутствует на HEAD: $p"',
     '|| blob=""'),
    # ── круг 2: по одному на каждый обход Б1–Б9 вердикта круга 1 ──────────────
    ('m13_nfr_zero_ok',
     '[ "$nfr_n" -ge 1 ] || die "манифест волны не объявил численных NFR: нет nfr строк"',
     ':'),
    ('m14_numeric_first_only',
     'git -C "$ROOT" for-each-ref --format=\'%(refname)\' "refs/tags/done/contracts/${id}/" 2>/dev/null | grep -q . \\\n'
     '      || die "строка волны не терминальна: $id (нет done-тега)"',
     'if [ "${wave110_num_seen:-0}" -eq 0 ]; then\n'
     '  git -C "$ROOT" for-each-ref --format=\'%(refname)\' "refs/tags/done/contracts/${id}/" 2>/dev/null | grep -q . \\\n'
     '    || die "строка волны не терминальна: $id (нет done-тега)"\n'
     '  wave110_num_seen=1\n'
     'fi'),
    ('m15_nfr_first_only',
     '[ "$ok" = "1" ] || die "NFR $name: $num не $op $porog"\ndone <<< "$NFR_ROWS"',
     '[ "$ok" = "1" ] || die "NFR $name: $num не $op $porog"\n  break\ndone <<< "$NFR_ROWS"'),
    ('m16_review_first_only',
     '# MUT-REVIEW\ndone <<< "$REVIEW_PATHS"',
     '# MUT-REVIEW\n  break\ndone <<< "$REVIEW_PATHS"'),
    ('m17_status_inner_spaces',
     'st="$(printf \'%s\' "$st" | sed -E \'s/[[:space:]]+$//\')"',
     'st="$(printf \'%s\' "$st" | tr -d \'[:space:]\')"'),
    ('m18_tag_on_tree',
     'tag --cleanup=verbatim -a "$tag" -m "$REASON" "$HEAD_SHA" >/dev/null 2>&1',
     'tag "$tag" "HEAD^{tree}" >/dev/null 2>&1'),
    ('m19_e2e_cached',
     '( cd "$ROOT" && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?',
     'if [ -f "$ROOT/.wave110-e2e-ok" ]; then\n'
     '  :\n'
     'else\n'
     '  ( cd "$ROOT" && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?\n'
     '  [ "$e2e_rc" -eq 0 ] && : > "$ROOT/.wave110-e2e-ok" || true\n'
     'fi'),
    ('m20_plan_own_parser',
     'plan_parse "$PLAN_TMP" || { rm -f "$PLAN_TMP"; die "$P84_PLAN_ERR"; }',
     '{ mapfile -t _m20 < "$PLAN_TMP"; for (( _m20i = 1; _m20i < ${#_m20[@]}; _m20i++ )); do '
     'IFS=$\'\\t\' read -r _m20id _m20pair _m20rest <<< "${_m20[$_m20i]}"; '
     'if [ "$_m20pair" = "$W" ]; then P84_ID+=("$_m20id"); P84_PAIR+=("$_m20pair"); fi; done; }'),
    ('m21_root_registry',
     'export LIB_PLAN_REGISTRY="$REG_REL"',
     'REG_REL="registry"; export LIB_PLAN_REGISTRY="$REG_REL"'),
    # ── круг 3: десять декоев критика (krug2-fail) байт-в-байт — каждая замена
    # воспроизводит файл критика в точности (дифф к модели — одна замена).
    ('m22_symbolic_first_only',
     '  if [ -n "${id//[0-9]/}" ]; then',
     '  if [ -n "${id//[0-9]/}" ]; then\n'
     '    [ "${sym_seen:-0}" = 0 ] || continue\n'
     '    sym_seen=1'),
    ('m23_second_nfr_rc_skipped',
     '  [ "$out_rc" -eq 0 ] || die "NFR $name: команда rc=$out_rc"   # MUT-CMDRC',
     '  if [ "${nfr_seen:-0}" = 0 ]; then\n'
     '    [ "$out_rc" -eq 0 ] || die "NFR $name: команда rc=$out_rc"\n'
     '  fi\n'
     '  nfr_seen=1   # MUT-CMDRC'),
    ('m24_second_review_missing_skipped',
     '  [ -n "$p" ] || continue',
     '  [ -n "$p" ] || continue\n'
     '  if [ "${review_seen:-0}" = 1 ]; then\n'
     '    git -C "$ROOT" cat-file -e "HEAD:$p" 2>/dev/null || continue\n'
     '  fi\n'
     '  review_seen=1'),
    ('m25_manifest_worktree',
     'MANIFEST="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:${REG_REL}/waves/${W}.tsv" 2>/dev/null)"',
     'MANIFEST="$(cat "$ROOT/${REG_REL}/waves/${W}.tsv" 2>/dev/null)"'),
    ('m26_closed_worktree',
     'CLOSED="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:${REG_REL}/closed-without-done.tsv" 2>/dev/null || true)"',
     'CLOSED="$(cat "$ROOT/${REG_REL}/closed-without-done.tsv" 2>/dev/null || true)"'),
    ('m27_review_worktree',
     'blob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$p" 2>/dev/null)"',
     'blob="$(cat "$ROOT/$p" 2>/dev/null)"'),
    ('m28_otkat_worktree',
     'oblob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$OTKAT_PATH" 2>/dev/null)"',
     'oblob="$(cat "$ROOT/$OTKAT_PATH" 2>/dev/null)"'),
    ('m29_duplicate_otkat',
     '[ "$otkat_n" -le 1 ] || die "otkat строка не одна"',
     ':'),
    ('m30_version_count',
     'v=$((vmax + 1))',
     'v=$(( $(git -C "$ROOT" tag -l "done/waves/$W/*" | wc -l) + 1 ))'),
    ('m31_strict_threshold',
     '(o=="le" ? (a<=b) : (a>=b))',
     '(o=="le" ? (a<b) : (a>b))'),
    # ── круг 2 реализации: 13 заглушек Adv110 (§3 вердикта impl-v1) + A1–A4/Б1 ──
    ('md2_e2e_cache_head',
     '( cd "$ROOT" && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?',
     '_hc="$ROOT/.git/wave110-e2e-$(git -C "$ROOT" rev-parse HEAD)"\n'
     'if [ -f "$_hc" ]; then e2e_rc=0\n'
     'else\n'
     '  ( cd "$ROOT" && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?\n'
     '  [ "$e2e_rc" -eq 0 ] && : >"$_hc"\n'
     'fi'),
    ('md3_nfr_last_match',
     'num="${BASH_REMATCH[1]}"; break; fi',
     'num="${BASH_REMATCH[1]}"; fi'),
    ('md7_review_head_absent_worktree',
     'blob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$p" 2>/dev/null)"',
     'blob="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:$p" 2>/dev/null || cat "$ROOT/$p" 2>/dev/null)"'),
    ('md12_closure_prefix',
     "awk -F'\\t' -v x=\"$id\" '$1==x {f=1} END {exit !f}'",
     "awk -F'\\t' -v x=\"$id\" 'index($1,x)==1 {f=1} END {exit !f}'"),
    ('md13_status_trailing_dots',
     '  [ "$st" = "done" ] || die "находка владельца открыта: $p status=${st:-нет_строки_status}"',
     '  st="${st%%.}"; st="${st%%.}"\n'
     '  [ "$st" = "done" ] || die "находка владельца открыта: $p status=${st:-нет_строки_status}"'),
    ('md14_status_case_insensitive',
     '  [ "$st" = "done" ] || die "находка владельца открыта: $p status=${st:-нет_строки_status}"',
     '  [ "${st,,}" = "done" ] || die "находка владельца открыта: $p status=${st:-нет_строки_status}"'),
    ('md15_otkat_field_unanchored',
     'grep -E "^${fld}:[[:space:]]*[^[:space:]]" >/dev/null',
     'grep -E "${fld}:[[:space:]]*[^[:space:]]" >/dev/null'),
    ('md16_otkat_empty_value_ok',
     'grep -E "^${fld}:[[:space:]]*[^[:space:]]" >/dev/null',
     'grep -E "^${fld}:" >/dev/null'),
    ('md22_e2e_rc_hardcoded_1',
     '[ "$e2e_rc" -eq 0 ] || die "сквозной запуск волны красный: rc=$e2e_rc"',
     '[ "$e2e_rc" -ne 1 ] || die "сквозной запуск волны красный: rc=$e2e_rc"'),
    ('md23_nfr_rc_hardcoded_3',
     '[ "$out_rc" -eq 0 ] || die "NFR $name: команда rc=$out_rc"   # MUT-CMDRC',
     '[ "$out_rc" -ne 3 ] || die "NFR $name: команда rc=$out_rc"   # MUT-CMDRC'),
    ('md25_valve_only_v2',
     'if [ "$v" -gt 1 ]; then',
     'if [ "$v" -eq 2 ]; then'),
    ('md29_e2e_not_in_root',
     '( cd "$ROOT" && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?',
     '( cd / && timeout 600 bash -c "$E2E_CMD" ) >/dev/null 2>&1 || e2e_rc=$?'),
    ('md31_first_nfr_op_porog_for_all',
     'IFS=$\'\\t\' read -r kind name cmd regex op porog <<< "$nfr"',
     'IFS=$\'\\t\' read -r kind name cmd regex op porog <<< "$nfr"; '
     'if [ -z "${wave110_op0:-}" ]; then wave110_op0="$op"; wave110_porog0="$porog"; fi; '
     'op="$wave110_op0"; porog="$wave110_porog0"'),
    ('ma1_dirty_tree_ok',
     '[ -z "$DIRTY" ] || die "рабочее дерево расходится с HEAD: $DIRTY (не HEAD-источник)"   # MUT-A1',
     ':   # MUT-A1'),
    ('ma1b_dirty_scope_manifest_only',
     'STATUS_TMP="$(mktemp)"\n'
     'git -C "$ROOT" status --porcelain=v1 -z --no-renames --untracked-files=no >"$STATUS_TMP" 2>/dev/null \\\n'
     '  || { rm -f "$STATUS_TMP"; die "не удалось определить состояние рабочего дерева"; }   # MUT-N2\n'
     'DIRTY=""\n'
     'while IFS= read -r -d \'\' rec <&3; do   # MUT-N3: запись «XY <путь>», путь = ${rec:3}\n'
     '  p="${rec:3}"\n'
     '  case " $SRC_SKIP " in *" $p "*) continue ;; esac   # MUT-E10\n'
     '  DIRTY+="${DIRTY:+ }$p"\n'
     'done 3< "$STATUS_TMP"\n'
     'rm -f "$STATUS_TMP"\n'
     '[ -z "$DIRTY" ] || die "рабочее дерево расходится с HEAD: $DIRTY (не HEAD-источник)"   # MUT-A1',
     'git -C "$ROOT" diff --quiet "$HEAD_SHA" -- "${REG_REL}/waves/${W}.tsv" 2>/dev/null \\\n'
     '  || die "рабочее дерево расходится с HEAD: ${REG_REL}/waves/${W}.tsv"'),
    ('ma2_profile_unchecked',
     'if [ -f "$ROOT/harness.project.json" ]; then\n'
     '  git -C "$ROOT" cat-file -e "${HEAD_SHA}:harness.project.json" 2>/dev/null \\\n'
     '    || die "профиль проекта не на HEAD: harness.project.json"\n'
     '  git -C "$ROOT" diff --quiet "$HEAD_SHA" -- harness.project.json 2>/dev/null \\\n'
     '    || die "профиль проекта расходится с HEAD: harness.project.json"\n'
     'else\n'
     '  git -C "$ROOT" cat-file -e "${HEAD_SHA}:harness.project.json" 2>/dev/null \\\n'
     '    && die "профиль проекта расходится с HEAD: harness.project.json"\n'
     'fi',
     ':'),
    ('ma3_subdir_root_ok',
     'TOP_ABS="$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null)" \\\n'
     '  || die "корень не git-репозиторий: $ROOT"\n'
     '[ "$(cd "$TOP_ABS" 2>/dev/null && pwd -P)" = "$ROOT_ABS" ] \\\n'
     '  || die "корень не корень репозитория: $ROOT_ABS"',
     ':'),
    ('ma4_tag_cleanup_strip',
     'tag --cleanup=verbatim -a "$tag" -m "$REASON" "$HEAD_SHA" >/dev/null 2>&1',
     'tag -a "$tag" -m "$REASON" "$HEAD_SHA" >/dev/null 2>&1'),
    ('mb1_tag_on_moved_head',
     'tag --cleanup=verbatim -a "$tag" -m "$REASON" "$HEAD_SHA" >/dev/null 2>&1',
     'tag --cleanup=verbatim -a "$tag" -m "$REASON" "HEAD" >/dev/null 2>&1'),
    # ── круг 3 реализации: заглушки Adv110r2 (E1/E3/E5/E6/E10/E11) + N2/N3/
    # N11b/Б3/N1 — каждый убит своей клеткой (Н-39: привязка здесь, не в прозе).
    ('me1_dirty_unstaged_only',
     'STATUS_TMP="$(mktemp)"\n'
     'git -C "$ROOT" status --porcelain=v1 -z --no-renames --untracked-files=no >"$STATUS_TMP" 2>/dev/null \\\n'
     '  || { rm -f "$STATUS_TMP"; die "не удалось определить состояние рабочего дерева"; }   # MUT-N2\n'
     'DIRTY=""\n'
     'while IFS= read -r -d \'\' rec <&3; do   # MUT-N3: запись «XY <путь>», путь = ${rec:3}\n'
     '  p="${rec:3}"',
     'STATUS_TMP="$(mktemp)"\n'
     'git -C "$ROOT" diff --name-only -z >"$STATUS_TMP" 2>/dev/null || true   # MUT-E1: только unstaged\n'
     'DIRTY=""\n'
     'while IFS= read -r -d \'\' rec <&3; do\n'
     '  p="$rec"'),
    ('me3_layer_guard_skipped',
     'if [ -n "$LAYER_REL" ] && { [ -e "$ROOT/$LAYER_REL" ] \\\n'
     '    || git -C "$ROOT" cat-file -e "${HEAD_SHA}:${LAYER_REL}" 2>/dev/null; }; then\n'
     '  git -C "$ROOT" cat-file -e "${HEAD_SHA}:${LAYER_REL}" 2>/dev/null \\\n'
     '    || die "профиль проекта расходится с HEAD: ${LAYER_REL} (не на HEAD)"   # MUT-E3\n'
     '  git -C "$ROOT" diff --quiet "$HEAD_SHA" -- "$LAYER_REL" 2>/dev/null \\\n'
     '    || die "профиль проекта расходится с HEAD: ${LAYER_REL}"\n'
     'fi',
     ':   # MUT-E3: слой профиля не охраняется'),
    ('mn11b_layer_hardcoded_name',
     'LAYER_REL="$(git -C "$ROOT" cat-file -p "${HEAD_SHA}:harness.project.json" 2>/dev/null \\\n'
     '  | jq -r \'.projectLayer.profilePath // "registry/harness-project.json"\' 2>/dev/null)"\n'
     '[ -n "$LAYER_REL" ] || LAYER_REL=""',
     'LAYER_REL="project-layer.json"   # MUT-N11b: зашитое имя слоя'),
    ('me5_toplevel_logical_pwd',
     '[ "$(cd "$TOP_ABS" 2>/dev/null && pwd -P)" = "$ROOT_ABS" ] \\\n'
     '  || die "корень не корень репозитория: $ROOT_ABS"',
     '[ "$TOP_ABS" = "$(cd "$ROOT" && pwd -L)" ] \\\n'
     '  || die "корень не корень репозитория: $ROOT_ABS"'),
    ('me6_root_requires_dotgit_dir',
     '[ "$(cd "$TOP_ABS" 2>/dev/null && pwd -P)" = "$ROOT_ABS" ] \\\n'
     '  || die "корень не корень репозитория: $ROOT_ABS"',
     '[ -d "$ROOT/.git" ] \\\n'
     '  || die "корень не корень репозитория: $ROOT_ABS"'),
    ('me10_dirty_exempt_registry_prefix',
     '  case " $SRC_SKIP " in *" $p "*) continue ;; esac   # MUT-E10',
     '  case "$p" in "$REG_REL"/*) continue ;; esac\n'
     '  case " $SRC_SKIP " in *" $p "*) continue ;; esac   # MUT-E10'),
    ('me11_dirty_check_after_commands',
     '[ -z "$DIRTY" ] || die "рабочее дерево расходится с HEAD: $DIRTY (не HEAD-источник)"   # MUT-A1',
     ':   # MUT-E11: грязь проверяется после команд — e2e успел себя восстановить'),
    ('mn2_status_blind',
     '  || { rm -f "$STATUS_TMP"; die "не удалось определить состояние рабочего дерева"; }   # MUT-N2',
     '  || true   # MUT-N2: rc потерян, упавший status читается как «дерево чисто»'),
    ('mn3_porcelain_awk_v1',
     'git -C "$ROOT" status --porcelain=v1 -z --no-renames --untracked-files=no >"$STATUS_TMP" 2>/dev/null \\\n'
     '  || { rm -f "$STATUS_TMP"; die "не удалось определить состояние рабочего дерева"; }   # MUT-N2\n'
     'DIRTY=""\n'
     'while IFS= read -r -d \'\' rec <&3; do   # MUT-N3: запись «XY <путь>», путь = ${rec:3}\n'
     '  p="${rec:3}"',
     'git -C "$ROOT" status --porcelain --untracked-files=no >"$STATUS_TMP" 2>/dev/null || true\n'
     'DIRTY=""\n'
     'while IFS= read -r rec <&3; do   # MUT-N3: v1-вывод, awk режет кавычки и пробелы\n'
     '  p="$(printf \'%s\' "$rec" | awk \'{print $2}\')"\n'
     '  [ -n "$p" ] || continue'),
    ('mb3_noncomment_reason_refuse',
     '[ -n "${REASON//[[:space:]]/}" ] || die "причина пуста"',
     '[ -n "${REASON//[[:space:]]/}" ] || die "причина пуста"\n'
     'NON_COMMENT="$(printf \'%s\\n\' "$REASON" | grep -v \'^[[:space:]]*#\' || true)"   # MUT-Б3\n'
     '[ -n "$NON_COMMENT" ] || die "причина пуста (только комментарные строки)"   # MUT-Б3'),
    ('mn1_cmd_head_skipped',
     'wave110_cmd_on_head "$E2E_CMD"   # MUT-N1',
     ':   # MUT-N1'),
    ('mn1b_nfr_cmd_unchecked',
     '  wave110_cmd_on_head "$cmd"   # MUT-N1b',
     '  :   # MUT-N1b'),
]


def read_model():
    with open(MODEL, encoding='utf-8') as f:
        return f.read()


def write_mutant(src, old, new):
    if src.count(old) != 1:
        sys.stderr.write('мутант: участок не уникален или отсутствует: %r (count=%d)\n'
                         % (old[:60], src.count(old)))
        return None
    path = os.path.join(tempfile.mkdtemp(prefix='wave110mut-'), 'model.sh')
    with open(path, 'w', encoding='utf-8') as f:
        f.write(src.replace(old, new))
    os.chmod(path, 0o755)
    return path


def battery(subject, cases, verbose=True):
    results = []
    for case in cases:
        spec = copy.deepcopy(case[1])
        good, detail = run_subject_case(subject, case[0], spec, case[2])
        results.append((case[0], good, detail))
        if verbose:
            print('СЛУЧАЙ %-24s %s %s' % (case[0], 'ok' if good else 'РАЗНОГЛАСИЕ',
                                          '' if good else detail))
    return results


def run_flow_phase2(subject, subject_root, root, wave, reg, flow, phase1):
    # Б7/D2: вторая дверь в ТОМ ЖЕ мире. Фаза 2 опционально чинит манифест
    # коммитом (Б7: e2e починена в красную) и/или снимает файлы (D2: флаг
    # e2e); оракул снимает refs/теги ЗАНОВО после первой двери: тег v1
    # первой фазы законен и не считается «новым».
    if 'manifest2' in flow:
        path = os.path.join(root, reg, 'waves', '%s.tsv' % wave)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(''.join('\t'.join(r) + '\n' for r in flow['manifest2']))
        git(root, 'add', '-A')
        git(root, '-c', 'user.name=Proba', '-c', 'user.email=proba@local',
            'commit', '-q', '-m', 'e2e починена в красную')
    for rel in flow.get('rm_files', []):
        target = (os.path.join(root + '.out', rel[len('@W110_OUT@/'):])
                  if rel.startswith('@W110_OUT@/')
                  else os.path.join(root, rel))
        try:
            os.remove(target)
        except FileNotFoundError:
            pass
    before = refs_snapshot(root)
    before_tags = set(wave_tags(root, wave))
    rc, out, err = run_subject(subject, subject_root, wave, flow['reason2'])
    after = refs_snapshot(root)
    tags = wave_tags(root, wave)
    new_tags = [t for t in tags if t not in before_tags]
    phrase = flow['expect2'][1]
    good = (rc == 1 and phrase in err and before == after and not new_tags)
    return good, '%s; фаза2 rc=%s err=%r new_tags=%s' % (
        phase1, rc, err.strip()[:200], new_tags)

def run_subject_case(subject, name, spec, expect):
    wave = spec.pop('wave', W)
    reason = spec.pop('reason', REASON)
    flow = spec.pop('flow', None)
    root_suffix = spec.pop('root_suffix', '')
    allow_moved_branch = spec.pop('allow_moved_branch', False)
    reg = spec.get('registry_dir', 'registry')
    root = build_world(spec)
    subject_root = root + root_suffix
    link = None
    if spec.get('root_symlink'):
        # E5: честный корень, переданный двери через символическую ссылку.
        link = root + '.lnk'
        os.symlink(root, link)
        subject_root = link
    if spec.get('linked_worktree'):
        # E6: честный мир в linked worktree (.git — файл), refs общие.
        subject_root = root + '.wt'
    try:
        before = refs_snapshot(root)
        before_tags = set(wave_tags(root, wave))
        head_before = git(root, 'rev-parse', 'HEAD').stdout.strip()
        rc, out, err = run_subject(subject, subject_root, wave, reason)
        after = refs_snapshot(root)
        tags = wave_tags(root, wave)
        if expect[0] == 'ok':
            want_v = expect[1]
            good, detail = check_ok(root, wave, want_v, head_before, reason,
                                    rc, out, err, tags, before, after,
                                    refnames_only=allow_moved_branch)
            if good and flow is not None:
                good2, detail2 = run_flow_phase2(
                    subject, subject_root, root, wave, reg, flow, detail)
                return good2, detail2
            return good, detail
        phrase = expect[1]
        new_tags = [t for t in tags if t not in before_tags]
        good = (rc == 1 and phrase in err and before == after and not new_tags)
        return good, 'rc=%s err=%r new_tags=%s' % (rc, err.strip()[:200], new_tags)
    finally:
        shutil.rmtree(root, ignore_errors=True)
        if root.endswith('.origin.git') or os.path.exists(root + '.origin.git'):
            shutil.rmtree(root + '.origin.git', ignore_errors=True)
    finally_cleanup(link, root)


def finally_cleanup(link, root):
    # side-артефакты миров (E5/E6/N1-a): симлинк, linked worktree, outside-каталог.
    if link is not None:
        try:
            os.remove(link)
        except FileNotFoundError:
            pass
    shutil.rmtree(root + '.wt', ignore_errors=True)
    shutil.rmtree(root + '.out', ignore_errors=True)


def main():
    argv = sys.argv[1:]
    only_case = None
    only_mutant = None
    mode = 'subject'
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--case':
            i += 1
            only_case = argv[i] if i < len(argv) else ''
        elif a == '--model':
            mode = 'model'
        elif a == '--matrix':
            mode = 'matrix'
        elif a == '--mutant':
            i += 1
            only_mutant = argv[i] if i < len(argv) else ''
        else:
            sys.stderr.write('неизвестный флаг: %s\n' % a)
            return 2
        i += 1

    if only_case is not None:
        names = [c[0] for c in CASES]
        if only_case not in names:
            sys.stderr.write('неизвестный case: %s (известны: %s)\n' % (only_case, ' '.join(names)))
            return 2
        subject = MODEL if mode in ('model',) or only_mutant else SUBJECT
        if only_mutant:
            src = read_model()
            m = [x for x in MUTANTS if x[0] == only_mutant]
            if not m:
                sys.stderr.write('неизвестный мутант: %s\n' % only_mutant)
                return 2
            p = write_mutant(src, m[0][1], m[0][2])
            if p is None:
                return 2
            subject = p
        good, detail = run_subject_case(subject, only_case,
                                        dict(CASES[names.index(only_case)][1]),
                                        CASES[names.index(only_case)][2])
        print('СЛУЧАЙ %s %s %s' % (only_case, 'ok' if good else 'РАЗНОГЛАСИЕ', detail))
        return 0 if good else 1

    if mode == 'subject':
        if not (os.path.isfile(SUBJECT) and os.access(SUBJECT, os.X_OK)):
            sys.stderr.write('110: дверь done_wave не существует '
                             '(до-предметное дерево): %s\n' % SUBJECT)
            return 1
        subject = SUBJECT
    else:
        subject = MODEL

    results = battery(subject, CASES)
    ok_n = sum(1 for _, g, _ in results if g)
    ref_names = [c[0] for c in CASES if c[2][0] == 'refuse']
    ok_names = [c[0] for c in CASES if c[2][0] == 'ok']
    ok_ok = sum(1 for n, g, _ in results if g and n in ok_names)
    ref_ok = sum(1 for n, g, _ in results if g and n in ref_names)
    print('ИТОГ: случаев %d, зелёных честных %d/%d, отказных с именованной причиной %d/%d'
          % (len(results), ok_ok, len(ok_names), ref_ok, len(ref_names)))
    if mode != 'matrix':
        return 0 if ok_n == len(results) else 1

    # ── матрица ──
    mismatches = 0 if ok_n == len(results) else 1
    if ok_n != len(results):
        print('МАТРИЦА: эталон не зелёный — %d разногласий' % (len(results) - ok_n))
    src = read_model()
    for mname, old, new in MUTANTS:
        p = write_mutant(src, old, new)
        if p is None:
            mismatches += 1
            print('МУТАНТ %-26s участок не найден' % mname)
            continue
        mres = battery(p, CASES, verbose=False)
        catching = [n for n, g, _ in mres if not g]
        shutil.rmtree(os.path.dirname(p), ignore_errors=True)
        print('МУТАНТ %-26s различающих случаев: %d %s'
              % (mname, len(catching), ' '.join(catching) if catching else ''))
        if not catching:
            mismatches += 1
    print(' mismatches=%d' % mismatches)
    return 0 if mismatches == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
