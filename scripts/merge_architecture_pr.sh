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
#   1. заголовок PR несёт РОВНО ОДИН COMPLIOR-<NNN>: грамматика регистрозависима,
#      `complior-186` и `COMPLIOR-186a` идентификатором работы не являются;
#   2. identity сливающего (gh api user) ≠ автору PR: логины сравниваются ТОЛЬКО
#      через casefold (логины GitHub регистронезависимы) — юникод-lookalike, пробел
#      и суффикс `[bot]` дают ДРУГОЙ аккаунт; пустой логин автора — rc 2 (нечем
#      судить), не слияние;
#   3. accept критика на ТОМ ЖЕ head SHA: APPROVED, автор вердикта ≠ автор PR,
#      первая строка body — дословно `accept`, единственная строка `СУД: ` несёт
#      ровно одно поле `модель-факт=<GLM>` (фактическая модель судьи — GLM, а не
#      Sol хранителя) и кончается `; SHA=<head>`;
#   4. check-runs на head: ВСЕ страницы (`gh api --paginate`), все runs
#      completed+success, есть run `architecture`, и его app.slug=github-actions;
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
# Логины GitHub регистронезависимы: единственная допустимая нормализация — casefold.
# Ни NFKC, ни trim, ни срез `[bot]`: иной байт в логине = иной аккаунт.
critics = {name.strip().casefold() for name in critic_logins.split(',') if name.strip()}
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


def gh_pages(args):
    """Страницы ответа `gh api --paginate`: поток JSON-документов одного вывода.

    GitHub отдаёт check-runs постранично, каждая страница — свой JSON-документ,
    поэтому вывод разбирается потоком документов, а не одним json.loads: иначе
    вторая страница (с красным run) осталась бы невидимой.
    """
    raw = call(['gh'] + args, project)
    decoder = json.JSONDecoder()
    pages = []
    index = 0
    while index < len(raw):
        while index < len(raw) and raw[index].isspace():
            index += 1
        if index >= len(raw):
            break
        try:
            page, index = decoder.raw_decode(raw, index)
        except ValueError:
            broken('gh ' + ' '.join(args) + ': вывод не разобран как JSON')
        pages.append(page)
    return pages


def app_slug(run):
    app = run.get('app')
    return app.get('slug') if isinstance(app, dict) else None


pr = gh_json(['pr', 'view', number, '-R', repo,
              '--json', 'title,author,headRefOid,baseRefName'])
if not isinstance(pr, dict):
    broken('gh pr view: ответ не разобран как объект')
title = pr.get('title') or ''
sha = pr.get('headRefOid') or ''
author = ((pr.get('author') or {}).get('login')) or ''
if len(work_item_re.findall(title)) != 1:
    refuse('NO_COMPLIOR_ID')
if not sha_re.fullmatch(sha):
    refuse('HEAD_SHA_INVALID')
if not author:
    broken('в PR нет автора — слияние невозможно судить')

operator_response = gh_json(['api', 'user'])
if not isinstance(operator_response, dict):
    broken('gh api user: ответ не разобран как объект')
operator = operator_response.get('login') or ''
if not operator:
    broken('gh api user: нет login оператора')
if author.casefold() == operator.casefold():
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
    if login.casefold() not in critics:
        continue
    if login.casefold() == author.casefold():
        continue
    # accept — дословно ПЕРВАЯ строка body: без пробелов, без другого регистра.
    lines = body.splitlines()
    if not lines or lines[0] != 'accept':
        continue
    # СУД — ровно одна строка, с ровно одним полем модель-факт=<модель критика>
    # и `; SHA=<head>` в конце.
    sud = [line for line in lines if line.startswith('СУД: ')]
    if len(sud) != 1:
        continue
    fields = sud[0].split('модель-факт=')
    if len(fields) != 2:
        continue
    if fields[1].split(';', 1)[0] != critic_model:
        continue
    if not sud[0].endswith('; SHA=' + sha):
        continue
    accepted = True
    break
if not accepted:
    refuse('NO_CRITIC_ACCEPT_ON_HEAD')

runs = []
for page in gh_pages(['api', '--paginate',
                      'repos/%s/commits/%s/check-runs' % (repo, sha)]):
    chunk = page.get('check_runs') if isinstance(page, dict) else page
    if isinstance(chunk, list):
        runs.extend(run for run in chunk if isinstance(run, dict))
if not runs:
    refuse('CI_NOT_GREEN_ON_HEAD')
if any(run.get('status') != 'completed' or run.get('conclusion') != 'success'
       for run in runs):
    refuse('CI_NOT_GREEN_ON_HEAD')
architecture = [run for run in runs if run.get('name') == 'architecture']
if not architecture:
    refuse('CI_NOT_GREEN_ON_HEAD')
if any(app_slug(run) != 'github-actions' for run in architecture):
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
