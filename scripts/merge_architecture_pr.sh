#!/usr/bin/env bash
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh;
# её приёмка — красная проба на сам scripts/merge_architecture_pr.sh (клетки door *, режимы --repo/--stabs), не сам скрипт;
# контракт 186 §Проводка: guard=scripts/merge_architecture_pr.sh (проводка 038 видит подключение по реестру ci-steps).
#
# ДВЕРЬ СЛИЯНИЯ L1 в CompliorOS-architecture (контракт 186, §Предмет 4).
# Запускает ТОЛЬКО станционный оркестратор (мейнтейнер L1 — не автор PR).
#
#   bash scripts/merge_architecture_pr.sh <корень-CompliorOS-architecture> <номер-PR>
#
# Порядок (каждый шаг — именованный отказ БЕЗ слияния):
#   1. заголовок PR несёт COMPLETOR-<NNN>;
#   2. identity сливающего (gh api user) ≠ автору PR;
#   3. accept критика на ТОМ ЖЕ head SHA: APPROVED, автор вердикта ≠ автор PR,
#      строка `accept` и строка `СУД: … модель-факт=<GLM>; SHA=<head>` (фактическая
#      модель судьи — GLM, а не Sol хранителя);
#   4. check-runs на head зелёные И среди них есть `architecture` (CI архитектурного репо);
#   5. `npm run check -- --base governance/baseline/approved.json --report` в корне
#      проекта: baseline PASS (L1 выводится механически), защищённые секции не задеты.
#      Расхождение вне защищённых секций — L2: без записи владельца дверь отказывает
#      L2_OWNER_APPROVAL_REQUIRED; расхождение в защищённой секции — L3:
#      L3_OWNER_APPROVAL_REQUIRED. L2/L3 эта дверь не сливает НИКОГДА: решение и
#      снимок публикует владелец, слияние ведёт его отдельный маршрут;
#   6. `gh pr merge <номер> -R a3ka/CompliorOS-architecture --merge --match-head-commit <head>`
#      — ровно один вызов, и только после всех предыдущих проверок.
#
# Правила слияния самого репозитория (базовая ветка, режим коммита, «designated
# human maintainer») сверяются по его MIGRATION.md, а не угадываются здесь: дверь
# проверяет РЕШЕНИЕ о слиянии (accept на head, CI, baseline, авторство), а не
# настройки репозитория.
#
# Возвращает: 0 — PR слит; 1 — именованный отказ (причина в stdout, слияния нет);
#             2 — нечем проверить (сетевой/инфраструктурный сбой; красным не зачёт).
set -uo pipefail

usage() {
  printf 'использование: merge_architecture_pr.sh <корень-CompliorOS-architecture> <номер-PR>\n' >&2
  exit 2
}

[ "$#" -eq 2 ] || usage
PROJECT="$1"
PR_NUMBER="$2"
ARCH_REPO="${ARCH_REPO:-a3ka/CompliorOS-architecture}"
# Станционные настройки двери: список аккаунтов критика и фактическая модель его суда.
# По умолчанию — станционный critic и семейство GLM (контракт 186 §Предмет 4).
CRITIC_LOGINS="${ARCH_CRITIC_LOGINS:-critic}"
CRITIC_MODEL="${ARCH_CRITIC_MODEL:-zai/glm-5.3}"

exec python3 - "$PROJECT" "$PR_NUMBER" "$ARCH_REPO" "$CRITIC_LOGINS" "$CRITIC_MODEL" <<'PY'
import json
import re
import subprocess
import sys

project, number, repo, critic_logins, critic_model = sys.argv[1:6]
critics = {name.strip() for name in critic_logins.split(',') if name.strip()}
work_item_re = re.compile(r'\bCOMPLIOR-[0-9]+\b')
sha_re = re.compile(r'[0-9a-f]{40}\Z')
protected_sections = ('resources', 'authority', 'policies', 'repositoryLayout',
                      'systemModel', 'changeScenarios')


def refuse(reason):
    """Именованный отказ: слияния нет."""
    print(reason)
    raise SystemExit(1)


def broken(message):
    """Инфраструктурный сбой: красным не зачитывается (rc 2)."""
    print('DOOR_INFRA_ERROR: ' + message, file=sys.stderr)
    raise SystemExit(2)


def call(argv, cwd):
    result = subprocess.run(argv, cwd=cwd, text=True, capture_output=True)
    if result.returncode != 0:
        broken(' '.join(argv) + ': ' + (result.stderr.strip() or result.stdout.strip()))
    return result.stdout


def gh_json(args):
    raw = call(['gh'] + args, project)
    try:
        return json.loads(raw)
    except ValueError:
        broken('gh ' + ' '.join(args) + ': вывод не разобран как JSON')


pr = gh_json(['pr', 'view', number, '-R', repo,
              '--json', 'title,author,headRefOid,baseRefName'])
title = pr.get('title') or ''
sha = pr.get('headRefOid') or ''
author = ((pr.get('author') or {}).get('login')) or ''
if not work_item_re.search(title):
    refuse('NO_COMPLIOR_ID')
if not sha_re.fullmatch(sha):
    refuse('HEAD_SHA_INVALID')
if not author:
    broken('в PR нет автора — слияние невозможно судить')

operator = (gh_json(['api', 'user']) or {}).get('login') or ''
if not operator:
    broken('gh api user: нет login оператора')
if author == operator:
    refuse('AUTHOR_IS_MERGER')

reviews = gh_json(['api', 'repos/%s/pulls/%s/reviews' % (repo, number)])
if not isinstance(reviews, list):
    broken('список review PR не разобран как массив')
accepted = False
for review in reviews:
    if not isinstance(review, dict):
        continue
    body = review.get('body') or ''
    login = ((review.get('user') or {}).get('login')) or ''
    if review.get('state') != 'APPROVED':
        continue
    if review.get('commit_id') != sha:
        continue
    if login not in critics:
        continue
    if login == author:
        continue
    if not re.search(r'^accept$', body, re.M):
        continue
    if not re.search(r'^СУД: .*модель-факт=' + re.escape(critic_model) +
                     r'; SHA=' + re.escape(sha) + r'$', body, re.M):
        continue
    accepted = True
    break
if not accepted:
    refuse('NO_CRITIC_ACCEPT_ON_HEAD')

checks = gh_json(['api', 'repos/%s/commits/%s/check-runs' % (repo, sha)])
runs = checks.get('check_runs') if isinstance(checks, dict) else None
if not isinstance(runs, list) or not runs:
    refuse('CI_NOT_GREEN_ON_HEAD')
if not any(run.get('name') == 'architecture' for run in runs):
    refuse('CI_NOT_GREEN_ON_HEAD')
if any(run.get('status') != 'completed' or run.get('conclusion') != 'success'
       for run in runs):
    refuse('CI_NOT_GREEN_ON_HEAD')

check = subprocess.run(['npm', 'run', 'check', '--', '--base',
                         'governance/baseline/approved.json', '--report'],
                        cwd=project, text=True, capture_output=True)
if check.returncode not in (0, 2):
    broken('npm run check: ' + (check.stderr.strip() or check.stdout.strip()))
try:
    status = json.loads(check.stdout)
except ValueError:
    broken('npm run check: вывод не разобран как JSON')
findings = status.get('findings') or []
mismatches = [finding.get('section') for finding in findings
              if isinstance(finding, dict) and finding.get('code') == 'BASELINE_MISMATCH']
if mismatches:
    if any(section in protected_sections for section in mismatches):
        refuse('L3_OWNER_APPROVAL_REQUIRED')
    refuse('L2_OWNER_APPROVAL_REQUIRED')
if status.get('baselineStatus') != 'PASS':
    refuse('BASELINE_NOT_PASS')
if (status.get('contractReadiness') or {}).get('incompatibleContracts'):
    refuse('BASELINE_NOT_PASS')

call(['gh', 'pr', 'merge', number, '-R', repo, '--merge', '--match-head-commit', sha],
     project)
print('СЛИТО: ' + repo + ' PR ' + number + ' head ' + sha)
PY
