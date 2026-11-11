#!/usr/bin/env python3
"""Contract 186: isolated honest control and one distinguishable mutant per public seam."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve()
DEFAULT_REPO = HERE.parents[3]
ROLE = 'architecture-steward'
TIER = 'steward-arch'


def run(argv, cwd, env=None):
    return subprocess.run(argv, cwd=cwd, env=env, text=True, capture_output=True)


def put(root, name, content):
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding='utf-8')


def get(root, name):
    return (root / name).read_text(encoding='utf-8')


def world(source, tmp):
    root = tmp / 'world'
    root.mkdir()
    for relative in ('roles', '.omp/agents', 'config/agent_models.json', '.omp/config.yml',
                     'scripts/roles.ts', 'scripts/gen-harness.ts', 'scripts/findings_status.py',
                     'scripts/architecture_review.py', 'ops/server/root/orch-peak', 'ops/server/root/systemd', 'ops/server/install.sh'):
        src, dst = source / relative, root / relative
        if src.is_dir():
            shutil.copytree(src, dst)
        elif src.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
    initialized = run(['git', 'init', '-q', '-b', 'main'], root)
    if initialized.returncode:
        raise RuntimeError(initialized.stderr)
    return root


# The oracle is frozen in this process before invoking the candidate. Section lines are
# matched as entire lines, never as accidental substrings in other sections or comments.
LINES = {
    'intake': ('Находки', 'Принимай находки от любой роли и человека непрерывно в CompliorOS-architecture/governance/findings/.'),
    'status': ('Статусы', 'Статус: принята L1/L2/L3 | отклонена: причина | вопрос владельцу.',
               'Файл без статуса старше одного среза назови в отчёте governance/review/; findings_status.py возвращает rc 1.'),
    'l1': ('L1', 'L1: PR хранителя либо architect предмета → шестой вопрос critic → слияние; check --base PASS.',
           'L1: PR в CompliorOS-architecture с отдельным коммитом модели и diff; автор (Астра/хранитель) сам не сливает, назначенный владельцем мейнтейнер сливает без нового слова владельца; до назначения мейнтейнер — владелец.'),
    'l2': ('L2', 'L2: пачка arch/l2-Э → diff → critic → снимок и digest владельца.',
           'L2: автор не сливает PR; слияние только с записью владельца.'),
    'l3': ('L3', 'L3: один файл = один вопрос владельцу + одна рекомендация; решение принимает владелец.',
           'L3: автор не сливает PR; слияние только с записью владельца.'),
    'register': ('Реестр', 'Реестр DRAFT/недостающих контрактов строится из check contractReadiness.unresolved.',
                 'Для каждой операции расставь приоритет по ROADMAP: предмет, Э-этап, срок до контракта X.'),
    'register_ci': ('CI реестра', 'Поручи Астре в CompliorOS-architecture реализовать генерацию governance/REGISTER.md из check contractReadiness.unresolved и проектный CI check: устаревший REGISTER.md возвращает rc 1; харнесс не хранит и не проверяет проектный реестр.'),
    'code_debt': ('Граница полномочий', 'Находку, требующую кода, передай проектному оркестратору как B-DEBT/предмет.',
                  'Не пиши код, не суди предметы и не требуй подписи хранителя для freeze/done.'),
    'review': ('Обзор', 'После done последнего предмета каждого Э-этапа делай обзор в CompliorOS-architecture/governance/review/.',
               'При блокирующей находке делай обзор сразу; недельный timer — только страховка.',
               'Коммит обзора: governance/review/<дата>-<Э>.md, включая пустой срез; после done без файла обзора сообщи оркестратору находку.'),
    'review_check': ('Контроль обзора', 'После обзора среза вызови architecture_review.py <корень-CompliorOS-architecture> <дата> <Э>; при НЕТ ОБЗОРА и rc 1 передай находку оркестратору.'),
}
HONEST_ROLE = ('---\nrole: architecture-steward\ntools: [read, grep, glob, bash, write, edit]\nverdict: null\n---\n\n'
               '# Хранитель архитектуры\n\n' + '\n'.join(
                   '## ' + rows[0] + '\n' + '\n'.join(rows[1:]) + '\n' for rows in LINES.values()))
SIGNAL = 'СТОРОЖ СТАНЦИИ (автоматически, НЕ слово владельца): architecture-steward: обзор архитектуры; при занятом слоте оставь в очереди.'
HONEST_STATUS_SCRIPT = '''#!/usr/bin/env python3
import pathlib
import subprocess
import sys
root, old = pathlib.Path(sys.argv[1]), sys.argv[2]
past = subprocess.run(['git', '-C', str(root), 'ls-tree', '-r', '--name-only', old, '--', 'governance/findings/'],
                      text=True, capture_output=True, check=True).stdout.splitlines()
bad = False
for name in past:
    path = root / name
    if not path.is_file():
        continue
    statuses = [line.removeprefix('Статус:').strip() for line in path.read_text().splitlines()
                if line.startswith('Статус:')]
    status = statuses[0] if len(statuses) == 1 else ''
    valid = status in ('принята L1', 'принята L2', 'принята L3', 'вопрос владельцу') or (
        status.startswith('отклонена: ') and bool(status.removeprefix('отклонена: ').strip()))
    if not valid:
        print('ПРОСРОЧЕНО: ' + name)
        bad = True
sys.exit(int(bad))
'''
HONEST_REVIEW_SCRIPT = '''#!/usr/bin/env python3
import pathlib
import subprocess
import sys
root, date, stage = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
name = 'governance/review/' + date + '-' + stage + '.md'
result = subprocess.run(['git', '-C', str(root), 'show', 'HEAD:' + name],
                        text=True, capture_output=True)
if result.returncode or not result.stdout.strip():
    print('НЕТ ОБЗОРА: ' + name)
    sys.exit(1)
headings = {'## Дельта модели', '## arch:conform на main', '## Находки',
            '## L2-пачка', '## DRAFT-реестр'}
if not headings.issubset(set(result.stdout.splitlines())):
    print('НЕПОЛНЫЙ ОБЗОР: ' + name)
    sys.exit(1)
sys.exit(0)
'''



def honest(root):
    put(root, 'roles/architecture-steward.md', HONEST_ROLE)
    config = json.loads(get(root, 'config/agent_models.json'))
    config['tiers'][TIER] = {'model': '@gpt-sol', 'fallback': '@gpt-astra',
                             'why': 'слово владельца 2026-11-10 ~19:45 UTC: хранитель Sol'}
    config['roles'][ROLE] = TIER
    route = 'приём находок и обзор архитектуры после done этапа и блокирующей находки'
    if not any(r.get('role') == ROLE and r.get('class') == route
               for r in config['routing']['rules']):
        config['routing']['rules'].append({'class': route, 'role': ROLE})
    put(root, 'config/agent_models.json', json.dumps(config, ensure_ascii=False, indent=2) + '\n')
    put(root, 'scripts/findings_status.py', HONEST_STATUS_SCRIPT)
    put(root, 'scripts/architecture_review.py', HONEST_REVIEW_SCRIPT)
    put(root, 'ops/server/root/systemd/orch-architecture.timer',
        '[Unit]\nDescription=Страховка обзора архитектуры\n[Timer]\nOnCalendar=Mon *-*-* 09:00:00 UTC\nUnit=orch-peak@architecture.service\nPersistent=false\n[Install]\nWantedBy=timers.target\n')
    # Честный мир ставит только НЕДОСТАЮЩИЕ артефакты (правка 186-ф): дерево
    # реализации уже несёт свои копии, а дубликат переживал мутацию одного
    # вхождения (ZHIV route_statistics/blocker_missing). Мутанты ниже ломают
    # все вхождения своего класса, поэтому одно вхождение на артефакт.
    peak = get(root, 'ops/server/root/orch-peak')
    anchor = '  start)\n'
    if peak.count(anchor) != 1:
        raise RuntimeError('station switch changed')
    missing = [(event, qualifier) for event, qualifier in
               (('architecture-done', 'done Э-этапа'),
                ('architecture-blocker', 'блокирующая находка'),
                ('architecture', 'страховочный timer'))
               if not re.search(r'(?m)^  ' + re.escape(event) + r'\)$', peak)]
    if missing:
        arm = ''.join('  ' + event + ')\n    say "' + SIGNAL + ' ' + qualifier + '" || exit 1\n    ;;\n'
                      for event, qualifier in missing)
        put(root, 'ops/server/root/orch-peak', peak.replace(anchor, arm + anchor))
    installer = get(root, 'ops/server/install.sh')
    if 'orch-architecture.timer' not in installer:
        anchor = "orch-ctx.timer'\n"
        if installer.count(anchor) != 1:
            raise RuntimeError('installer inventory changed')
        put(root, 'ops/server/install.sh', installer.replace(anchor, "orch-ctx.timer orch-architecture.timer'\n"))
    orchestrator = get(root, 'roles/orchestrator.md')
    if '## Архитектурные события' not in orchestrator:
        put(root, 'roles/orchestrator.md', orchestrator + '\n## Архитектурные события\nПосле done последнего предмета Э-этапа или блокирующей находки вызови architecture-steward; timer — страховка, при занятом слоте оставь событие в очереди.\n')
    gen = run(['node', 'scripts/gen-harness.ts'], root)
    if gen.returncode:
        raise RuntimeError('generator model: ' + gen.stderr)


def sections(text):
    parts = re.split(r'^## (.+)$', text, flags=re.M)
    return {parts[i]: set(parts[i + 1].splitlines()) for i in range(1, len(parts) - 1, 2)}


def signal(root, event, expected):
    with tempfile.TemporaryDirectory(prefix='arch-186-action-') as temp:
        scratch = Path(temp)
        env = dict(os.environ, ORCH_PEAK_TEST=temp, ORCH_STATE=str(scratch / 'state'),
                   ORCH_LOG=str(scratch / 'peak.log'), ORCH_REPO=str(root))
        action = run(['bash', str(root / 'ops/server/root/orch-peak'), event], root, env)
        if action.returncode:
            return False, 'action ' + event + ' rc=' + str(action.returncode)
        path = scratch / 'say.log'
        if not path.is_file():
            return False, 'сигнал не доставлен'
        messages = path.read_text(encoding='utf-8').splitlines()
        ok = len(messages) == 1 and messages[0].startswith(SIGNAL) and expected in messages[0]
        return ok, 'сигнал ' + event if ok else 'неправильный сигнал ' + event


def finding(author, status):
    return ('Компонент/ресурс: api.vehicle\n'
            'Наблюдение: app/vehicle.js:7, отсутствует схема\n'
            'Ожидание модели: contract.api.vehicle schema\n'
            'Предлагаемый уровень: L1\n'
            f'Автор: {author}\n'
            f'Статус: {status}\n')

def judge(root, case):
    if case == 'role' or case in LINES:
        path = root / 'roles' / (ROLE + '.md')
        if not path.is_file():
            return False, 'нет роли'
        role = path.read_text(encoding='utf-8')
        fm = re.match(r'\A---\n(.*?)\n---\n', role, re.S)
        if not fm:
            return False, 'нет frontmatter'
        fields = set(fm.group(1).splitlines())
        if 'role: architecture-steward' not in fields or 'verdict: null' not in fields or not any(x.startswith('tools: [') for x in fields):
            return False, 'неверный инвентарь'
        if case == 'role':
            return True, 'роль зарегистрирована'
        rows = LINES[case]
        block = sections(role[fm.end():]).get(rows[0], set())
        ok = set(rows[1:]).issubset(block)
        return ok, rows[0] if ok else 'нет обязанности ' + rows[0]
    if case in ('routing', 'tier', 'fallback', 'critic_family'):
        path = root / 'config/agent_models.json'
        if not path.is_file():
            return False, 'нет реестра'
        cfg = json.loads(path.read_text(encoding='utf-8'))
        role_tier = cfg.get('roles', {}).get(ROLE)
        tier = cfg.get('tiers', {}).get(TIER, {})
        if case == 'routing':
            route = 'приём находок и обзор архитектуры после done этапа и блокирующей находки'
            ok = role_tier == TIER and any(r.get('role') == ROLE and r.get('class') == route
                                               for r in cfg.get('routing', {}).get('rules', []))
        elif case == 'tier':
            # Инвариант §6 — alias "@gpt-sol", не литерал версии: версия семейства
            # живёт одной строкой в models того же файла (AGENTS.md) и меняется
            # владельцем (6-sol → 6.1-sol, omp 18.18.8). Смена версии — зелёная;
            # подмена alias либо семейство, не разворачиваемое из models, — красные.
            family = tier.get('model')
            resolved = cfg.get('models', {}).get(family[1:]) \
                if isinstance(family, str) and family.startswith('@') else None
            ok = (role_tier == TIER and family == '@gpt-sol'
                  and isinstance(resolved, str) and bool(resolved.strip()))
        elif case == 'critic_family':
            critic_tier = cfg.get('tiers', {}).get(cfg.get('roles', {}).get('critic'), {})
            critic_model = critic_tier.get('model')
            ok = (role_tier == TIER and critic_model == '@glm'
                  and cfg.get('models', {}).get('glm') == 'zai/glm-5.3')
        else:
            ok = role_tier == TIER and tier.get('fallback') == '@gpt-astra'
        return ok, case if ok else 'неверный ' + case
    if case == 'generated':
        check = run(['node', 'scripts/gen-harness.ts', '--check'], root)
        if check.returncode:
            return False, 'генерация расходится rc=' + str(check.returncode)
        path = root / '.omp/agents/architecture-steward.md'
        ok = path.is_file() and 'model: ["@steward-arch"]' in path.read_text(encoding='utf-8').splitlines()
        return ok, 'генерация' if ok else 'нет модели Sol в агенте'
    if case in ('done', 'blocker', 'schedule'):
        if case == 'schedule':
            path = root / 'ops/server/root/systemd/orch-architecture.timer'
            if not path.is_file() or 'orch-architecture.timer' not in get(root, 'ops/server/install.sh'):
                return False, 'нет страховочного timer'
            units = [line for line in path.read_text(encoding='utf-8').splitlines()
                     if line.startswith('Unit=')]
            if units != ['Unit=orch-peak@architecture.service']:
                return False, 'timer не диспатчит architecture'
            return signal(root, 'architecture', 'страховочный timer')
        section = sections(get(root, 'roles/orchestrator.md')).get('Архитектурные события', set())
        if not any('architecture-steward' in line and 'занятом слоте' in line for line in section):
            return False, 'нет потребителя события'
        return signal(root, 'architecture-done' if case == 'done' else 'architecture-blocker',
                      'done Э-этапа' if case == 'done' else 'блокирующая находка')
    if case == 'status_cli':
        path = root / 'scripts/findings_status.py'
        if not path.is_file():
            return False, 'нет исполняемой проверки статусов'
        with tempfile.TemporaryDirectory(prefix='arch-186-findings-') as tmp:
            project = Path(tmp)
            run(['git', 'init', '-q', '-b', 'main'], project)
            put(project, 'governance/findings/001-old.md', finding('implementer', ''))
            run(['git', 'add', '.'], project)
            committed = run(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                             'commit', '-qm', 'prior slice'], project)
            if committed.returncode:
                raise RuntimeError(committed.stderr)
            put(project, 'governance/findings/002-fresh.md', finding('человек', ''))
            old = run(['python3', str(path), str(project), 'HEAD'], root)
            expected = 'ПРОСРОЧЕНО: governance/findings/001-old.md'
            if old.returncode != 1 or old.stdout.splitlines() != [expected]:
                return False, 'просрочка без именованной строки и rc 1'
            put(project, 'governance/findings/001-old.md', finding('implementer', 'принята L1'))
            resolved = run(['python3', str(path), str(project), 'HEAD'], root)
            ok = resolved.returncode == 0 and not resolved.stdout.strip()
            if not ok:
                return False, 'неверная полярность статуса'
            put(project, 'governance/findings/001-old.md', finding('implementer', 'ожидание без решения'))
            invalid = run(['python3', str(path), str(project), 'HEAD'], root)
            ok = invalid.returncode == 1 and invalid.stdout.splitlines() == [expected]
            return ok, 'старый/свежий/разобранный/неконформный статус' if ok else 'неконформный статус скрывает просрочку'
    if case == 'review_file':
        path = root / 'scripts/architecture_review.py'
        if not path.is_file():
            return False, 'нет исполняемой проверки обзора'
        with tempfile.TemporaryDirectory(prefix='arch-186-review-') as tmp:
            project = Path(tmp)
            run(['git', 'init', '-q', '-b', 'main'], project)
            put(project, 'seed.txt', 'slice')
            run(['git', 'add', '.'], project)
            committed = run(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                             'commit', '-qm', 'prior slice'], project)
            if committed.returncode:
                raise RuntimeError(committed.stderr)
            argv = ['python3', str(path), str(project), '2026-11-10', 'Э2']
            missing = run(argv, root)
            expected = 'НЕТ ОБЗОРА: governance/review/2026-11-10-Э2.md'
            if missing.returncode != 1 or missing.stdout.splitlines() != [expected]:
                return False, 'нет отчёта оркестратору при пропуске done'
            put(project, 'governance/review/2026-11-10-Э2.md',
                '## Дельта модели\nбез дельт\n## arch:conform на main\n0 новых\n'
                '## Находки\nнет\n## L2-пачка\nнет\n## DRAFT-реестр\nсрок до контракта X\n')
            uncommitted = run(argv, root)
            if uncommitted.returncode != 1 or uncommitted.stdout.splitlines() != [expected]:
                return False, 'непереданный в PR файл выдаётся за коммит обзора'
            run(['git', 'add', '.'], project)
            committed = run(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                             'commit', '-qm', 'review'], project)
            if committed.returncode:
                raise RuntimeError(committed.stderr)
            put(project, 'governance/review/2026-11-10-Э2.md', 'вроде обзор\n')
            run(['git', 'add', '.'], project)
            incomplete_commit = run(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                                     'commit', '-qm', 'incomplete review'], project)
            if incomplete_commit.returncode:
                raise RuntimeError(incomplete_commit.stderr)
            incomplete = run(argv, root)
            if incomplete.returncode != 1 or incomplete.stdout.splitlines() != [
                    'НЕПОЛНЫЙ ОБЗОР: governance/review/2026-11-10-Э2.md']:
                return False, 'пустое содержание выдаётся за обзор'
            put(project, 'governance/review/2026-11-10-Э2.md',
                '## Дельта модели\nбез дельт\n## arch:conform на main\n0 новых\n'
                '## Находки\nнет\n## L2-пачка\nнет\n## DRAFT-реестр\nсрок до контракта X\n')
            run(['git', 'add', '.'], project)
            restored = run(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                            'commit', '-qm', 'complete review'], project)
            if restored.returncode:
                raise RuntimeError(restored.stderr)
            complete = run(argv, root)
            ok = complete.returncode == 0 and not complete.stdout.strip()
            return ok, 'пропущенный/незакоммиченный/неполный/полный обзор' if ok else 'обзор не признан'
    raise ValueError(case)


CASES = ('role', *LINES, 'status_cli', 'review_file', 'routing', 'tier', 'fallback', 'critic_family', 'generated', 'done', 'blocker', 'schedule')
MUTANTS = (('no_frontmatter', 'role'),
           ('humans_only', 'intake'), ('silent_overdue', 'status_cli'), ('invalid_status', 'status_cli'),
           ('review_without_file', 'review'), ('silent_missing_review', 'review_file'),
           ('uncommitted_review', 'review_file'), ('incomplete_review', 'review_file'),
           ('no_register_ci_task', 'register_ci'),
           ('l1_not_pr', 'l1'), ('l1_self_merge', 'l1'), ('l1_same_commit', 'l1'),
           ('l2_self_merge', 'l2'), ('l3_self_merge', 'l3'),
           ('l3_no_recommendation', 'l3'), ('writes_code_or_judges', 'code_debt'),
           ('no_roadmap_priority', 'register'), ('plan_astra', 'tier'), ('tier_astra', 'tier'),
           ('wrong_fallback', 'fallback'), ('no_role_map', 'routing'),
           ('critic_sol', 'critic_family'), ('route_statistics', 'routing'),
           ('route_rule_deleted', 'routing'),
           ('blocker_missing', 'blocker'), ('blocker_arm_deleted', 'blocker'),
           ('calendar_only', 'done'), ('timer_start', 'schedule'),
           ('stale_generated', 'generated'), ('no_timer', 'schedule'))
STABS = MUTANTS


def mutate(root, name):
    if name == 'no_frontmatter':
        put(root, 'roles/architecture-steward.md', HONEST_ROLE.split('---\n', 2)[2])
    elif name in ('humans_only', 'l3_no_recommendation', 'writes_code_or_judges',
                  'no_roadmap_priority', 'review_without_file', 'no_register_ci_task',
                  'l1_not_pr', 'l1_same_commit', 'l1_self_merge', 'l2_self_merge', 'l3_self_merge'):
        case = dict(MUTANTS)[name]
        row = LINES[case][1 if name in ('humans_only', 'l3_no_recommendation', 'no_register_ci_task') else -1]
        replacements = {
            'humans_only': 'Принимай находки только от человека непрерывно в CompliorOS-architecture/governance/findings/',
            'l3_no_recommendation': 'L3: вопрос владельцу без рекомендации.',
            'writes_code_or_judges': 'Пиши код и суди предметы самостоятельно.',
            'no_roadmap_priority': 'В реестре DRAFT достаточно списка операций без приоритета.',
            'review_without_file': 'После done достаточно устного обзора; файл и находка оркестратору не нужны.',
            'no_register_ci_task': 'Реестр ведётся без сверки; Астру не беспокоить.',
            'l1_not_pr': row.replace('PR в CompliorOS-architecture', 'коммит напрямую в main'),
            'l1_same_commit': row.replace('отдельным коммитом модели и diff', 'одним коммитом вместе с кодом'),
            'l1_self_merge': row.replace('автор (Астра/хранитель) сам не сливает', 'автор сам сливает'),
            'l2_self_merge': 'L2: автор сам сливает PR без записи владельца.',
            'l3_self_merge': 'L3: автор сам сливает PR без записи владельца.',
        }
        role = get(root, 'roles/architecture-steward.md')
        if role.count(row) != 1:
            raise RuntimeError('role mutant anchor missing: ' + name)
        put(root, 'roles/architecture-steward.md', role.replace(row, replacements[name]))
    elif name == 'silent_overdue':
        put(root, 'scripts/findings_status.py', 'import sys\nsys.exit(0)\n')
    elif name == 'invalid_status':
        status = get(root, 'scripts/findings_status.py')
        put(root, 'scripts/findings_status.py', status.replace('if not valid:', 'if not status:'))
    elif name == 'silent_missing_review':
        put(root, 'scripts/architecture_review.py', 'import sys\nsys.exit(0)\n')
    elif name == 'uncommitted_review':
        put(root, 'scripts/architecture_review.py',
            HONEST_REVIEW_SCRIPT.replace("result = subprocess.run(['git', '-C', str(root), 'show', 'HEAD:' + name],\n"
                                         "                        text=True, capture_output=True)",
                                         "result = subprocess.CompletedProcess([], 0, (root / name).read_text() if (root / name).is_file() else '', '')"))
    elif name == 'incomplete_review':
        script = get(root, 'scripts/architecture_review.py')
        put(root, 'scripts/architecture_review.py', script.replace(
            "if not headings.issubset(set(result.stdout.splitlines())):",
            "if not result.stdout.strip():"))
    elif name in ('calendar_only', 'blocker_missing', 'blocker_arm_deleted'):
        # Граница мутанта (правка 186-ф): мутант основного класса ломает ВСЕ
        # вхождения события — обе формы терминатора arm-а (собственная строка
        # "    ;;" и хвостовая "... ;;"), ноль снесённых = отказ батареи;
        # сосед-удаление (blocker_arm_deleted) выносит ровно одно вхождение —
        # при одном вхождении в честном мире этого достаточно для красного.
        peak = get(root, 'ops/server/root/orch-peak')
        event = {'calendar_only': 'architecture-done',
                 'blocker_missing': 'architecture-blocker',
                 'blocker_arm_deleted': 'architecture-blocker'}[name]
        pattern = re.compile(r'(?m)^  ' + re.escape(event) + r'\)\n.*?;;[^\n]*\n', re.S)
        if name == 'blocker_arm_deleted':
            peak, n = pattern.subn('', peak, count=1)
        else:
            n = 0
            while True:
                peak, removed = pattern.subn('', peak, count=1)
                if not removed:
                    break
                n += removed
        if n < 1:
            raise RuntimeError('event arm missing: ' + event)
        put(root, 'ops/server/root/orch-peak', peak)
    elif name in ('plan_astra', 'tier_astra', 'wrong_fallback', 'no_role_map', 'critic_sol',
                  'route_statistics', 'route_rule_deleted'):
        cfg = json.loads(get(root, 'config/agent_models.json'))
        route = 'приём находок и обзор архитектуры после done этапа и блокирующей находки'
        if name == 'plan_astra':
            cfg['roles'][ROLE] = 'plan'
        elif name == 'tier_astra':
            cfg['tiers'][TIER]['model'] = '@gpt-astra'
        elif name == 'wrong_fallback':
            cfg['tiers'][TIER]['fallback'] = '@gpt-sol'
        elif name == 'critic_sol':
            cfg['roles']['critic'] = TIER
        elif name == 'route_statistics':
            hit = 0
            for rule in cfg['routing']['rules']:
                if rule.get('class') == route:
                    rule['class'] = 'архитектурная статистика'
                    hit += 1
            if not hit:
                raise RuntimeError('route rule missing: ' + route)
        elif name == 'route_rule_deleted':
            rules = cfg['routing']['rules']
            index = next((i for i, rule in enumerate(rules) if rule.get('class') == route), None)
            if index is None:
                raise RuntimeError('route rule missing: ' + route)
            del rules[index]
        else:
            del cfg['roles'][ROLE]
        put(root, 'config/agent_models.json', json.dumps(cfg, ensure_ascii=False, indent=2) + '\n')
    elif name == 'stale_generated':
        agent = get(root, '.omp/agents/architecture-steward.md')
        put(root, '.omp/agents/architecture-steward.md', agent.replace('model: ["@steward-arch"]', 'model: ["@plan"]'))
    elif name == 'no_timer':
        (root / 'ops/server/root/systemd/orch-architecture.timer').unlink()
    elif name == 'timer_start':
        timer = 'ops/server/root/systemd/orch-architecture.timer'
        put(root, timer, get(root, timer).replace('Unit=orch-peak@architecture.service',
                                                  'Unit=orch-peak@start.service'))


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', type=Path, default=DEFAULT_REPO)
    args = parser.parse_args()
    source = args.repo.resolve()
    if not (source / '.git').exists():
        parser.error('ожидается корень Git-репозитория')
    failures = 0
    if args.stabs:
        for name, case in STABS:
            with tempfile.TemporaryDirectory(prefix='arch-186-') as tmp:
                root = world(source, Path(tmp))
                honest(root)
                mutate(root, name)
                good, reason = judge(root, case)
                print(f'186 STAB {name} {"ZHIV" if good else "caught"} @ {case}: {reason}')
                failures += good
    else:
        for case in CASES:
            with tempfile.TemporaryDirectory(prefix='arch-186-') as tmp:
                root = world(source, Path(tmp))
                if args.model:
                    honest(root)
                good, reason = judge(root, case)
                print(f'186 {case} {"ok" if good else "KRASNO"}: {reason}')
                failures += not good
    return int(bool(failures))


if __name__ == '__main__':
    raise SystemExit(main())
