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
                     'ops/server/root/orch-peak', 'ops/server/root/systemd', 'ops/server/install.sh'):
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
    'l1': ('L1', 'L1: PR хранителя либо architect предмета → шестой вопрос critic → слияние; check --base PASS.'),
    'l2': ('L2', 'L2: пачка arch/l2-Э → diff → critic → снимок и digest владельца.'),
    'l3': ('L3', 'L3: один файл = один вопрос владельцу + одна рекомендация; решение принимает владелец.'),
    'register': ('Реестр', 'Реестр DRAFT/недостающих контрактов строится из check contractReadiness.unresolved.',
                 'Для каждой операции расставь приоритет по ROADMAP: предмет, Э-этап, срок до контракта X.'),
    'code_debt': ('Граница полномочий', 'Находку, требующую кода, передай проектному оркестратору как B-DEBT/предмет.',
                  'Не пиши код, не суди предметы и не требуй подписи хранителя для freeze/done.'),
    'review': ('Обзор', 'После done последнего предмета каждого Э-этапа делай обзор в CompliorOS-architecture/governance/review/.',
               'При блокирующей находке делай обзор сразу; недельный timer — только страховка.'),
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
    statuses = [line for line in path.read_text().splitlines() if line.startswith('Статус:')]
    if not statuses or not statuses[0].removeprefix('Статус:').strip():
        print('ПРОСРОЧЕНО: ' + name)
        bad = True
sys.exit(int(bad))
'''



def honest(root):
    put(root, 'roles/architecture-steward.md', HONEST_ROLE)
    config = json.loads(get(root, 'config/agent_models.json'))
    config['tiers'][TIER] = {'model': '@gpt-sol', 'fallback': '@gpt-astra',
                             'why': 'слово владельца 2026-11-10 ~19:45 UTC: хранитель Sol'}
    config['roles'][ROLE] = TIER
    config['routing']['rules'].append({'class': 'обзор архитектуры после done этапа и блокирующей находки', 'role': ROLE})
    put(root, 'config/agent_models.json', json.dumps(config, ensure_ascii=False, indent=2) + '\n')
    put(root, 'scripts/findings_status.py', HONEST_STATUS_SCRIPT)
    put(root, 'ops/server/root/systemd/orch-architecture.timer',
        '[Unit]\nDescription=Страховка обзора архитектуры\n[Timer]\nOnCalendar=Mon *-*-* 09:00:00 UTC\nUnit=orch-peak@architecture.service\nPersistent=false\n[Install]\nWantedBy=timers.target\n')
    peak = get(root, 'ops/server/root/orch-peak')
    anchor = '  start)\n'
    if peak.count(anchor) != 1:
        raise RuntimeError('station switch changed')
    arm = ''.join('  ' + event + ')\n    say "' + SIGNAL + ' ' + qualifier + '" || exit 1\n    ;;\n'
                  for event, qualifier in (('architecture-done', 'done Э-этапа'),
                                           ('architecture-blocker', 'блокирующая находка'),
                                           ('architecture', 'страховочный timer')))
    put(root, 'ops/server/root/orch-peak', peak.replace(anchor, arm + anchor))
    installer = get(root, 'ops/server/install.sh')
    anchor = "orch-ctx.timer'\n"
    if installer.count(anchor) != 1:
        raise RuntimeError('installer inventory changed')
    put(root, 'ops/server/install.sh', installer.replace(anchor, "orch-ctx.timer orch-architecture.timer'\n"))
    orchestrator = get(root, 'roles/orchestrator.md')
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
    if case in ('routing', 'tier', 'fallback'):
        path = root / 'config/agent_models.json'
        if not path.is_file():
            return False, 'нет реестра'
        cfg = json.loads(path.read_text(encoding='utf-8'))
        role_tier = cfg.get('roles', {}).get(ROLE)
        tier = cfg.get('tiers', {}).get(TIER, {})
        if case == 'routing':
            ok = role_tier == TIER and any(r.get('role') == ROLE and 'архитектур' in r.get('class', '') for r in cfg.get('routing', {}).get('rules', []))
        elif case == 'tier':
            ok = role_tier == TIER and tier.get('model') == '@gpt-sol' and cfg.get('models', {}).get('gpt-sol') == 'openai-codex/gpt-6-sol'
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
            return ok, 'старый/свежий/разобранный статус' if ok else 'неверная полярность статуса'
    raise ValueError(case)


CASES = ('role', *LINES, 'status_cli', 'routing', 'tier', 'fallback', 'generated', 'done', 'blocker', 'schedule')
MUTANTS = (('no_frontmatter', 'role'), ('calendar_only', 'done'), ('blocker_missing', 'blocker'),
           ('humans_only', 'intake'), ('silent_overdue', 'status_cli'),
           ('l3_no_recommendation', 'l3'), ('writes_code_or_judges', 'code_debt'),
           ('no_roadmap_priority', 'register'), ('plan_astra', 'tier'),
           ('wrong_fallback', 'fallback'), ('no_role_map', 'routing'),
           ('stale_generated', 'generated'), ('no_timer', 'schedule'))
STABS = MUTANTS


def mutate(root, name):
    if name == 'no_frontmatter':
        put(root, 'roles/architecture-steward.md', HONEST_ROLE.split('---\n', 2)[2])
    elif name in ('humans_only', 'l3_no_recommendation', 'writes_code_or_judges', 'no_roadmap_priority'):
        case = dict(MUTANTS)[name]
        row = LINES[case][-1]
        replacements = {
            'humans_only': 'Принимай находки только от человека непрерывно в CompliorOS-architecture/governance/findings/',
            'l3_no_recommendation': 'L3: вопрос владельцу без рекомендации.',
            'writes_code_or_judges': 'Пиши код и суди предметы самостоятельно.',
            'no_roadmap_priority': 'В реестре DRAFT достаточно списка операций без приоритета.',
        }
        role = get(root, 'roles/architecture-steward.md')
        put(root, 'roles/architecture-steward.md', role.replace(row, replacements[name]))
    elif name == 'silent_overdue':
        put(root, 'scripts/findings_status.py', 'import sys\nsys.exit(0)\n')
    elif name in ('calendar_only', 'blocker_missing'):
        peak = get(root, 'ops/server/root/orch-peak')
        event = 'architecture-done' if name == 'calendar_only' else 'architecture-blocker'
        peak, n = re.subn(r'  ' + event + r'\)\n.*?    ;;\n', '', peak, count=1, flags=re.S)
        if n != 1:
            raise RuntimeError('event arm missing: ' + event)
        put(root, 'ops/server/root/orch-peak', peak)
    elif name in ('plan_astra', 'wrong_fallback', 'no_role_map'):
        cfg = json.loads(get(root, 'config/agent_models.json'))
        if name == 'plan_astra':
            cfg['roles'][ROLE] = 'plan'
        elif name == 'wrong_fallback':
            cfg['tiers'][TIER]['fallback'] = '@fable'
        else:
            del cfg['roles'][ROLE]
        put(root, 'config/agent_models.json', json.dumps(cfg, ensure_ascii=False, indent=2) + '\n')
    elif name == 'stale_generated':
        agent = get(root, '.omp/agents/architecture-steward.md')
        put(root, '.omp/agents/architecture-steward.md', agent.replace('model: ["@steward-arch"]', 'model: ["@plan"]'))
    elif name == 'no_timer':
        (root / 'ops/server/root/systemd/orch-architecture.timer').unlink()


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
