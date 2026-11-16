#!/usr/bin/env python3
"""Toy reference for the public L1 merge-door contract, not production implementation.

Честная дверь по вердикту adversary contracts-186-impl-v1 (вызов 1): ровно один
COMPLIOR-<NNN> в title; логины сравниваются casefold (GitHub-логины регистронезави-
симы) и ТОЛЬКО casefold — любой иной байт (юникод-lookalike, пробел, [bot]) = другой
аккаунт; пустой логин автора — инфраструктурный сбой (rc 2), не слияние; `accept` —
дословно первая строка body; единственная строка `СУД: ` несёт ровно одно поле
`модель-факт=` со значением модели критика и кончается `; SHA=<head>`; check-runs
читаются ВСЕ страницы через `gh api --paginate`, зелёность всех runs, наличие
`architecture` и его происхождение app.slug=github-actions.

Б-1 (ревьюер 186 вызов 1): слияние судит ТО дерево, которое принято. Перед
`npm run check` дверь обязана убедиться, что локальный checkout стоит ровно на
head PR (`git rev-parse HEAD` == headRefOid) и дерево чисто (`git status
--porcelain` пуст): иначе check классифицирует ЧУЖОЕ дерево (main, подменённый
baseline в рабочем дереве), а слит будет PR head. Несовпадение — именованный
отказ CHECKOUT_NOT_AT_PR_HEAD, грязь — CHECKOUT_DIRTY (rc 1, слияния нет);
недоступность Git-метаданных — rc 2 (нечем судить), не слияние. Законно:
detached на head-коммите, иная ветка на том же sha — дверь сравнивает РАЗРЕШЁННЫЙ
sha, не имя ветки.

Честная дверь v+1 (слово владельца 2026-11-16 ~12:20 UTC через консультанта):
ожидаемая модель критика — НАЗНАЧЕНИЕ роли critic в установочном реестре
`config/agent_models.json` дерева харнесса самой двери (цепочка
roles.critic → имя тира → tiers[тир].model «@семейство» → models[семейство]
→ полная строка модели), не семейство GLM, не env-override и не дерево
архитектурного PR. Поле `модель-факт=` сравнивается с ПОЛНОЙ строкой
назначенной модели литерально; fallback тира не расширяет множество
принимаемых значений — дверь принимает ровно одну модель. Отсутствие файла
реестра, неразбор JSON, отсутствие roles.critic/тира, неразрешимый алиас
или пустая строка — именованный отказ CRITIC_MODEL_UNRESOLVED (rc 1,
слияния нет), не молчаливый fallback на GLM.
"""
import json
import os
from pathlib import Path
import re
import subprocess
import sys

REGISTRY = Path(__file__).resolve().parent / 'config' / 'agent_models.json'


def assigned_critic_model():
    """Назначение роли critic из установочного реестра (контракт 186 v+1)."""
    try:
        registry = json.loads(REGISTRY.read_text(encoding='utf-8'))
    except (OSError, ValueError):
        return None
    if not isinstance(registry, dict):
        return None
    roles = registry.get('roles')
    tiers = registry.get('tiers')
    name = roles.get('critic') if isinstance(roles, dict) else None
    tier = tiers.get(name) if isinstance(tiers, dict) and isinstance(name, str) else None
    alias = tier.get('model') if isinstance(tier, dict) else None
    models = registry.get('models')
    model = (models.get(alias[1:])
             if isinstance(models, dict) and isinstance(alias, str) and alias.startswith('@')
             else None)
    return model if isinstance(model, str) and model.strip() else None


def call(args, cwd):
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout or 'command failed')
    return result.stdout


def fail(reason):
    print(reason)
    return 1


def main():
    project, number = Path(sys.argv[1]), sys.argv[2]
    repo = 'a3ka/CompliorOS-architecture'
    # v+1: ожидаемая модель критика — назначение роли critic в реестре
    # харнесса двери; сломанная конфигурация даёт именованный отказ, не
    # fallback-значение.
    critic_model = assigned_critic_model()
    if critic_model is None:
        return fail('CRITIC_MODEL_UNRESOLVED')
    pr = json.loads(call(['gh', 'pr', 'view', number, '-R', repo,
                          '--json', 'title,author,headRefOid,baseRefName'], project))
    sha = pr['headRefOid']
    if len(re.findall(r'\bCOMPLIOR-[0-9]+\b', pr['title'])) != 1:
        return fail('NO_COMPLIOR_ID')
    if not pr['author']['login']:
        raise RuntimeError('в PR нет автора — слияние невозможно судить')
    operator = json.loads(call(['gh', 'api', 'user'], project))['login']
    if pr['author']['login'].casefold() == operator.casefold():
        return fail('AUTHOR_IS_MERGER')
    reviews = json.loads(call(['gh', 'api', f'repos/{repo}/pulls/{number}/reviews'], project))
    accepted = False
    for r in reviews:
        if r['state'] != 'APPROVED' or r['commit_id'] != sha:
            continue
        if r['user']['login'] != 'critic' or r['user']['login'] == pr['author']['login']:
            continue
        lines = r['body'].splitlines()
        sud = [line for line in lines if line.startswith('СУД: ')]
        fields = sud[0].split('модель-факт=') if len(sud) == 1 else []
        if (not lines or lines[0] != 'accept' or len(fields) != 2
                or fields[1].split(';', 1)[0] != critic_model
                or not sud[0].endswith('; SHA=' + sha)):
            continue
        accepted = True
        break
    if not accepted:
        return fail('NO_CRITIC_ACCEPT_ON_HEAD')
    raw = call(['gh', 'api', '--paginate', f'repos/{repo}/commits/{sha}/check-runs'], project)
    runs = [c for line in raw.splitlines() if line.strip()
            for c in json.loads(line).get('check_runs') or []]
    if any(c['status'] != 'completed' or c['conclusion'] != 'success' for c in runs):
        return fail('CI_NOT_GREEN_ON_HEAD')
    if not runs or not any(c.get('name') == 'architecture' for c in runs):
        return fail('CI_NOT_GREEN_ON_HEAD')
    if any(c.get('app', {}).get('slug') != 'github-actions'
           for c in runs if c['name'] == 'architecture'):
        return fail('CI_FOREIGN_ARCHITECTURE_APP')
    head = call(['git', 'rev-parse', 'HEAD'], project).strip()
    if head != sha:
        return fail('CHECKOUT_NOT_AT_PR_HEAD')
    if call(['git', 'status', '--porcelain'], project).strip():
        return fail('CHECKOUT_DIRTY')
    check = subprocess.run(['npm', 'run', 'check', '--', '--base',
                            'governance/baseline/approved.json', '--report'],
                           cwd=project, text=True, capture_output=True)
    if check.returncode not in (0, 2):
        raise RuntimeError(check.stderr or check.stdout or 'check failed')
    status = json.loads(check.stdout)
    mismatches = [finding['section'] for finding in status['findings']
                  if finding['code'] == 'BASELINE_MISMATCH']
    if mismatches:
        if any(section in ('resources', 'authority', 'policies', 'repositoryLayout', 'systemModel', 'changeScenarios')
               for section in mismatches):
            return fail('L3_OWNER_APPROVAL_REQUIRED')
        return fail('L2_OWNER_APPROVAL_REQUIRED')
    if status['baselineStatus'] != 'PASS' or status['contractReadiness']['incompatibleContracts']:
        return fail('BASELINE_NOT_PASS')
    call(['gh', 'pr', 'merge', number, '-R', repo, '--merge', '--match-head-commit', sha], project)
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (RuntimeError, KeyError, ValueError, IndexError) as exc:
        print('DOOR_INFRA_ERROR: ' + str(exc), file=sys.stderr)
        raise SystemExit(2)
