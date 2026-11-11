#!/usr/bin/env bash
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh;
# её приёмка — красная проба на сам scripts/check_architecture_pin.sh (клетки pin *, режимы --repo/--stabs), не сам скрипт;
# контракт 186 §Проводка: guard=scripts/check_architecture_pin.sh (проводка 038 видит подключение по реестру ci-steps).
#
# POST-MERGE PIN (контракт 186, §Предмет 4а) — станционная проверка перед слиянием
# продуктового PR: продукт закрепляет ТОЧНЫЙ коммит слияния архитектуры в
# `architecture.lock.json` (формат 167), и станция не даёт продуктовому PR уйти
# с неверным пином.
#
#   bash scripts/check_architecture_pin.sh <корень-CompliorOS-architecture> <№ архитектурного PR> <корень-Complior-back> <№ продуктового PR>
#
# Проверки (каждая — именованный отказ, rc 1, записи в продукт НЕТ и merge НЕТ):
#   1. архитектурный PR в состоянии MERGED, `mergeCommit.oid` — полный SHA40;
#   2. локальный merge двухродительский, и принятый head PR — второй родитель
#      (слияние ровно того head, который принял critic);
#   3. в заголовках обоих PR — РОВНО один и одинаковый COMPLETOR-<NNN>, и он
#      совпадает с `workItem` пина;
#   4. checkout продукта — ТОЧНО на head продуктового PR (не доверяем текущему HEAD);
#   5. `architecture.lock.json` читается ИЗ КОМИТА head продуктового PR (не
#      незакоммиченный файл): формат 167, `commit` == merge SHA архитектуры
#      (не head PR, не HEAD продукта).
#
# Возвращает: 0 — пин верный; 1 — именованный отказ (причина в stdout);
#             2 — нечем проверить (сетевой/инфраструктурный сбой; красным не зачёт).
set -uo pipefail

usage() {
  printf 'использование: check_architecture_pin.sh <корень-CompliorOS-architecture> <№ архитектурного PR> <корень-Complior-back> <№ продуктового PR>\n' >&2
  exit 2
}

[ "$#" -eq 4 ] || usage
ARCH_ROOT="$1"
ARCH_PR="$2"
PRODUCT_ROOT="$3"
PRODUCT_PR="$4"
ARCH_REPO="${ARCH_REPO:-a3ka/CompliorOS-architecture}"
PRODUCT_REPO="${PRODUCT_REPO:-a3ka/Complior-back}"

exec python3 - "$ARCH_ROOT" "$ARCH_PR" "$PRODUCT_ROOT" "$PRODUCT_PR" "$ARCH_REPO" "$PRODUCT_REPO" <<'PY'
import json
import re
import subprocess
import sys

arch, arch_pr, product, product_pr, arch_repo, product_repo = sys.argv[1:7]
sha_re = re.compile(r'[0-9a-f]{40}\Z')
work_item_re = re.compile(r'\bCOMPLIOR-[0-9]+\b')
LOCK_FORMAT = 'complioros-architecture-pin/1'


def refuse(reason):
    """Именованный отказ: продукт не трогаем, merge не делаем."""
    print(reason)
    raise SystemExit(1)


def broken(message):
    """Инфраструктурный сбой: красным не зачитывается (rc 2)."""
    print('PIN_CHECK_INFRA_ERROR: ' + message, file=sys.stderr)
    raise SystemExit(2)


def call(argv, cwd):
    result = subprocess.run(argv, cwd=cwd, text=True, capture_output=True)
    if result.returncode != 0:
        broken(' '.join(argv) + ': ' + (result.stderr.strip() or result.stdout.strip()))
    return result.stdout


def gh_json(args, cwd):
    raw = call(['gh'] + args, cwd)
    try:
        return json.loads(raw)
    except ValueError:
        broken('gh ' + ' '.join(args) + ': вывод не разобран как JSON')


accepted = gh_json(['pr', 'view', arch_pr, '-R', arch_repo,
                    '--json', 'state,title,headRefOid,mergeCommit'], arch)
merge = accepted.get('mergeCommit') or {}
merge_sha = merge.get('oid')
arch_head = accepted.get('headRefOid')
if accepted.get('state') != 'MERGED' or not isinstance(merge_sha, str) \
        or not sha_re.fullmatch(merge_sha):
    refuse('ARCH_PR_NOT_MERGED')
parents = call(['git', '-C', arch, 'rev-list', '--parents', '-n', '1', merge_sha],
               arch).split()
if len(parents) != 3 or parents[0] != merge_sha or parents[2] != arch_head:
    refuse('ARCH_MERGE_NOT_ACCEPTED_HEAD')
work_items = work_item_re.findall(accepted.get('title') or '')
if len(work_items) != 1:
    refuse('NO_COMPLIOR_ID')

pr = gh_json(['pr', 'view', product_pr, '-R', product_repo, '--json', 'title,headRefOid'],
              product)
if work_item_re.findall(pr.get('title') or '') != work_items:
    refuse('PRODUCT_PR_WORK_ITEM_MISMATCH')
product_head = pr.get('headRefOid')
if not isinstance(product_head, str) or not sha_re.fullmatch(product_head):
    refuse('PRODUCT_PR_HEAD_INVALID')
if call(['git', '-C', product, 'rev-parse', 'HEAD'], product).strip() != product_head:
    refuse('PRODUCT_PR_HEAD_NOT_CHECKED_OUT')

lock = subprocess.run(['git', '-C', product, 'show',
                       product_head + ':architecture.lock.json'],
                      text=True, capture_output=True)
if lock.returncode != 0:
    refuse('ARCHITECTURE_LOCK_MISSING')
try:
    pin = json.loads(lock.stdout)
except ValueError:
    refuse('ARCHITECTURE_LOCK_INVALID')
if not isinstance(pin, dict):
    refuse('ARCHITECTURE_LOCK_INVALID')
if 'commit' not in pin or not pin['commit']:
    refuse('ARCHITECTURE_PIN_MISSING')
if pin['commit'] != merge_sha:
    refuse('ARCHITECTURE_PIN_MISMATCH')
if (pin.get('format') != LOCK_FORMAT or pin.get('repository') != arch_repo
        or pin.get('workItem') != work_items[0]):
    refuse('ARCHITECTURE_LOCK_IDENTITY_MISMATCH')
print('ПИН ВЕРЕН: ' + arch_repo + ' merge ' + merge_sha + ' ← ' + work_items[0])
PY
