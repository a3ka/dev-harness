#!/usr/bin/env python3
"""186: one independent Git world per assertion/mutant; owner decision is the oracle."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve()
DEFAULT_REPO = HERE.parents[3]
ROLE = 'architecture-steward'


def run(argv, cwd, env=None):
    return subprocess.run(argv, cwd=cwd, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def put(root, relative, text):
    dest = root / relative
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(text, encoding='utf-8')


def get(root, relative):
    return (root / relative).read_text(encoding='utf-8')


def world(source, parent):
    root = parent / 'world'
    root.mkdir()
    for relative in ('roles', '.omp/agents', 'config/agent_models.json', '.omp/config.yml',
                     'scripts/roles.ts', 'scripts/gen-harness.ts', 'scripts/check_sud_model.sh',
                     'ops/server/root/orch-peak', 'ops/server/root/systemd',
                     'ops/server/install.sh', 'roles/orchestrator.md'):
        src, dst = source / relative, root / relative
        if src.is_dir():
            shutil.copytree(src, dst)
        elif src.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
    result = run(['git', 'init', '-q', '-b', 'main'], root)
    if result.returncode:
        raise RuntimeError(result.stderr)
    return root


# Honest candidate is constructed independently of the subject's data; no expectations
# are ever recomputed by reading candidate-owned files after the call under test.
HONEST_ROLE = '''---
role: architecture-steward
tools: [read, grep, glob, bash, write, edit]
verdict: null
---

# Architecture Steward — хранитель архитектуры

Субагент по расписанию: за архитектурой наблюдает между срезами, а не ждёт случайной задачи.

## Находки
Читай CompliorOS-architecture/governance/findings/; сверяй незакрытые находки с изменениями продукта. Записывай новое наблюдение с доказательством и адресатом в журнал архитектуры, не объявляй закрытым без свидетельства.

## Правки L1
Исправляй L1 в архитектурном репозитории с проверкой и отдельным коммитом. L2 собирай в пачку для владельца; не меняй L2 единолично.

## Обзор среза
После каждого среза сверяй архитектурный снимок с результатом и зафиксируй один снимок среза. Отклонения и незакрытые DRAFT называй отдельно.

## Схемы операций впрок
Готовь схемы операций В7 до заморозки контракта; недостающие схемы и контракты модулей заводи механизмом, а не по случаю. Код по DRAFT-операции не выпускай; модули общаются только через контракты.

## Граница полномочий
Архитектурные артефакты проекта пишутся в проектном workflow/architecture, не в репозиторий харнесса. На решения L2 и заморозку без подписи владельца не претендуй.
'''


def honest(root):
    put(root, 'roles/architecture-steward.md', HONEST_ROLE)
    conf = json.loads(get(root, 'config/agent_models.json'))
    conf['roles'][ROLE] = 'plan'
    conf['routing']['rules'].append({'class': 'плановый обзор архитектуры, находки и схемы операций', 'role': ROLE})
    put(root, 'config/agent_models.json', json.dumps(conf, ensure_ascii=False, indent=2) + '\n')
    put(root, 'ops/server/root/systemd/orch-architecture.timer',
        '[Unit]\nDescription=Плановый обзор архитектуры\n[Timer]\nOnCalendar=Mon *-*-* 09:00:00 UTC\nUnit=orch-peak@architecture.service\nPersistent=false\n[Install]\nWantedBy=timers.target\n')
    peak = get(root, 'ops/server/root/orch-peak')
    anchor = '  start)\n'
    if peak.count(anchor) != 1:
        raise RuntimeError('station switch changed')
    put(root, 'ops/server/root/orch-peak', peak.replace(anchor,
        '  architecture)\n    say "СТОРОЖ СТАНЦИИ (автоматически, НЕ слово владельца): плановый обзор архитектуры — вызови субагента architecture-steward с тиром plan и запиши результат в проектный журнал архитектуры; при занятом слоте перенеси запись в очередь." || exit 1\n    ;;\n' + anchor))
    installer = get(root, 'ops/server/install.sh')
    old = 'orch-ctx.timer\'\n'
    if installer.count(old) != 1:
        raise RuntimeError('installer inventory changed')
    put(root, 'ops/server/install.sh', installer.replace(old, 'orch-ctx.timer orch-architecture.timer\'\n'))
    role = get(root, 'roles/orchestrator.md')
    put(root, 'roles/orchestrator.md', role + '\n## Сигнал планового обзора архитектуры\nПо сообщению планового обзора от сторожа станции вызови субагента architecture-steward; при занятом слоте сохрани задание в очередь, исполнение подтверждай следом в проектном журнале архитектуры.\n')
    generated = run(['node', 'scripts/gen-harness.ts'], root)
    if generated.returncode:
        raise RuntimeError(f'generator model failed: {generated.stderr}')


def sections(body):
    chunks = re.split(r'^## (.+)$', body, flags=re.M)
    return {chunks[n]: chunks[n+1] for n in range(1, len(chunks) - 1, 2)}


def judge(root, case):
    if case == 'role':
        path = root / 'roles' / (ROLE + '.md')
        if not path.is_file():
            return False, 'нет роли'
        text = path.read_text(encoding='utf-8')
        fm = re.match(r'\A---\n(.*?)\n---\n', text, flags=re.S)
        if not fm:
            return False, 'нет frontmatter'
        fields = fm.group(1).splitlines()
        if 'role: architecture-steward' not in fields or 'verdict: null' not in fields or not any(line.startswith('tools: [') for line in fields):
            return False, 'неверный инвентарь роли'
        blocks = sections(text[fm.end():])
        promises = {
            'Находки': ('governance/findings/', 'наблюдение', 'адресатом'),
            'Правки L1': ('L1', 'L2', 'коммит'),
            'Обзор среза': ('среза', 'снимок', 'отклонения'),
            'Схемы операций впрок': ('схемы операций', 'В7', 'контракты модулей', 'DRAFT'),
            'Граница полномочий': ('проект', 'владельца'),
        }
        for name, words in promises.items():
            if name not in blocks or any(word.casefold() not in blocks[name].casefold() for word in words):
                return False, f'отсутствует обязанность: {name}'
        return True, 'обязанности и границы роли'
    if case in ('routing', 'tier', 'fallback'):
        path = root / 'config/agent_models.json'
        if not path.is_file():
            return False, 'нет реестра моделей'
        config = json.loads(path.read_text(encoding='utf-8'))
        if case == 'routing':
            good = config['roles'].get(ROLE) == 'plan' and any(
                r.get('role') == ROLE and 'архитектур' in r.get('class', '') for r in config.get('routing', {}).get('rules', []))
            return good, 'маршрут роли' if good else 'нет маршрута роли'
        if case == 'tier':
            good = config['roles'].get(ROLE) == 'plan' and config['tiers']['plan']['model'] == '@gpt-astra'
            return good, 'тир plan/Astra' if good else 'тир не plan/Astra'
        good = config['tiers']['plan']['fallback'] == '@fable'
        return good, 'fallback @fable' if good else 'fallback не @fable'
    if case == 'generated':
        result = run(['node', 'scripts/gen-harness.ts', '--check'], root)
        if result.returncode != 0:
            return False, f'gen:harness --check rc={result.returncode}: {result.stderr.strip()[:120]}'
        if not (root / '.omp/agents/architecture-steward.md').is_file():
            return False, 'нет сгенерированного агента'
        generated = get(root, '.omp/agents/architecture-steward.md')
        good = 'name: architecture-steward' in generated.splitlines() and 'model: ["@plan"]' in generated.splitlines()
        return good, 'генерация совпала' if good else 'нет сгенерированного агента @plan'
    if case == 'schedule':
        timer = root / 'ops/server/root/systemd/orch-architecture.timer'
        if not timer.is_file():
            return False, 'нет timer'
        lines = timer.read_text(encoding='utf-8').splitlines()
        if 'OnCalendar=Mon *-*-* 09:00:00 UTC' not in lines or 'Unit=orch-peak@architecture.service' not in lines or 'Persistent=false' not in lines:
            return False, 'timer не задаёт еженедельный запуск'
        if 'orch-architecture.timer' not in get(root, 'ops/server/install.sh').split("UNITS='", 1)[-1].split("'", 1)[0].split():
            return False, 'timer не установлен'
        role = sections(get(root, 'roles/orchestrator.md')).get('Сигнал планового обзора архитектуры', '')
        if 'architecture-steward' not in role or 'проектном журнале' not in role:
            return False, 'нет потребителя сигнала'
        with tempfile.TemporaryDirectory(prefix='arch-186-action-') as tmp:
            scratch = Path(tmp)
            env = dict(os.environ, ORCH_PEAK_TEST=tmp, ORCH_STATE=str(scratch / 'state'),
                       ORCH_LOG=str(scratch / 'peak.log'), ORCH_REPO=str(root))
            action = run(['bash', str(root / 'ops/server/root/orch-peak'), 'architecture'], root, env)
            if action.returncode:
                return False, f'action rc={action.returncode}: {action.stderr.strip()[:120]}'
            message = scratch / 'say.log'
            if not message.is_file():
                return False, 'сигнал не доставлен'
            notice = message.read_text(encoding='utf-8').splitlines()
            good = len(notice) == 1 and 'architecture-steward' in notice[0] and 'НЕ слово владельца' in notice[0]
            return good, 'реальный сигнал расписания' if good else 'неправильный сигнал расписания'
    raise ValueError(case)


CASES = ('role', 'routing', 'tier', 'fallback', 'generated', 'schedule')


def mutate(root, kind):
    if kind == 'no_frontmatter':
        put(root, 'roles/architecture-steward.md', HONEST_ROLE.split('---\n', 2)[2])
    elif kind == 'no_duties':
        put(root, 'roles/architecture-steward.md', HONEST_ROLE.replace('## Схемы операций впрок', '## Частные советы'))
    elif kind == 'steward_copy':
        put(root, 'roles/architecture-steward.md', get(root, 'roles/steward.md').replace('role: steward', 'role: architecture-steward'))
    elif kind in ('no_role_map', 'wrong_tier', 'wrong_fallback'):
        conf = json.loads(get(root, 'config/agent_models.json'))
        if kind == 'no_role_map':
            del conf['roles'][ROLE]
        elif kind == 'wrong_tier':
            conf['roles'][ROLE] = 'steward'
        else:
            conf['tiers']['plan']['fallback'] = '@opus'
        put(root, 'config/agent_models.json', json.dumps(conf, ensure_ascii=False, indent=2) + '\n')
    elif kind == 'stale_generated':
        agent = get(root, '.omp/agents/architecture-steward.md')
        put(root, '.omp/agents/architecture-steward.md', agent.replace('model: ["@plan"]', 'model: ["@steward"]'))
    elif kind == 'no_schedule':
        (root / 'ops/server/root/systemd/orch-architecture.timer').unlink()
    elif kind == 'no_dispatch':
        peak = get(root, 'ops/server/root/orch-peak')
        put(root, 'ops/server/root/orch-peak', re.sub(r'  architecture\)\n.*?    ;;\n', '', peak, count=1, flags=re.S))


STABS = (('no_frontmatter', 'role'), ('no_duties', 'role'), ('steward_copy', 'role'),
         ('no_role_map', 'routing'), ('wrong_tier', 'tier'), ('wrong_fallback', 'fallback'),
         ('stale_generated', 'generated'), ('no_schedule', 'schedule'), ('no_dispatch', 'schedule'))


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
                if good:
                    print(f'186 STAB {name} ZHIV @ {case}')
                    failures += 1
                else:
                    print(f'186 STAB {name} caught @ {case}: {reason}')
    else:
        for case in CASES:
            with tempfile.TemporaryDirectory(prefix='arch-186-') as tmp:
                root = world(source, Path(tmp))
                if args.model:
                    honest(root)
                good, reason = judge(root, case)
                print(f'186 {case} {"ok" if good else "KRASNO"}: {reason}')
                failures += not good
    return bool(failures)


if __name__ == '__main__':
    sys.exit(main())
