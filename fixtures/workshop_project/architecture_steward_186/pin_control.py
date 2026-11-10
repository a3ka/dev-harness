#!/usr/bin/env python3
"""Reference post-merge station check: the product PR, not the station, writes its lock."""
import json
from pathlib import Path
import re
import subprocess
import sys

ARCH_REPO = 'a3ka/CompliorOS-architecture'
PRODUCT_REPO = 'a3ka/Complior-back'
SHA = re.compile(r'[0-9a-f]{40}\Z')
WORK_ITEM = re.compile(r'\bCOMPLIOR-[0-9]+\b')


def call(args, cwd):
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or repr(args))
    return result.stdout.strip()


def fail(reason):
    print(reason)
    return 1


def main():
    arch, arch_pr, product, product_pr = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3]), sys.argv[4]
    accepted = json.loads(call(['gh', 'pr', 'view', arch_pr, '-R', ARCH_REPO,
                                '--json', 'state,title,headRefOid,mergeCommit'], arch))
    merged = accepted.get('mergeCommit') or {}
    merge_sha = merged.get('oid')
    arch_head = accepted.get('headRefOid')
    if accepted.get('state') != 'MERGED' or not isinstance(merge_sha, str) or not SHA.fullmatch(merge_sha):
        return fail('ARCH_PR_NOT_MERGED')
    parents = call(['git', 'rev-list', '--parents', '-n', '1', merge_sha], arch).split()
    if len(parents) != 3 or parents[0] != merge_sha or parents[2] != arch_head:
        return fail('ARCH_MERGE_NOT_ACCEPTED_HEAD')
    work_items = WORK_ITEM.findall(accepted.get('title', ''))
    if len(work_items) != 1:
        return fail('NO_COMPLIOR_ID')
    pr = json.loads(call(['gh', 'pr', 'view', product_pr, '-R', PRODUCT_REPO,
                          '--json', 'title,headRefOid'], product))
    if WORK_ITEM.findall(pr.get('title', '')) != work_items:
        return fail('PRODUCT_PR_WORK_ITEM_MISMATCH')
    product_head = pr.get('headRefOid')
    if not isinstance(product_head, str) or not SHA.fullmatch(product_head):
        return fail('PRODUCT_PR_HEAD_INVALID')
    if call(['git', 'rev-parse', 'HEAD'], product) != product_head:
        return fail('PRODUCT_PR_HEAD_NOT_CHECKED_OUT')
    lock = subprocess.run(['git', 'show', product_head + ':architecture.lock.json'],
                          cwd=product, text=True, capture_output=True)
    if lock.returncode:
        return fail('ARCHITECTURE_LOCK_MISSING')
    try:
        pin = json.loads(lock.stdout)
    except (ValueError, TypeError):
        return fail('ARCHITECTURE_LOCK_INVALID')
    if not isinstance(pin, dict):
        return fail('ARCHITECTURE_LOCK_INVALID')
    if 'commit' not in pin or not pin['commit']:
        return fail('ARCHITECTURE_PIN_MISSING')
    if pin['commit'] != merge_sha:
        return fail('ARCHITECTURE_PIN_MISMATCH')
    if (pin.get('format') != 'complioros-architecture-pin/1'
            or pin.get('repository') != ARCH_REPO or pin.get('workItem') != work_items[0]):
        return fail('ARCHITECTURE_LOCK_IDENTITY_MISMATCH')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (RuntimeError, IndexError, KeyError) as exc:
        print('PIN_CHECK_INFRA_ERROR: ' + str(exc), file=sys.stderr)
        raise SystemExit(2)
