#!/usr/bin/env python3
"""Copy-пробы 999 (CMP-MOB-002): производные runtime-ключи каталога.

i18n/ui-copy.ts — verbatim-подмножество BrokerOS_UI_Copy_DE.json: точные
ключи, точные тексты, review_status сохранён; deprecated-алиас
ia115.nav.HEUTE (do_not_use) не используется. Оракул — source.json.
"""
import argparse
import re
from pathlib import Path
import sys

from probe_lib import HERE, installed, load_source, model_bytes

COPY_TS = 'mobile/src/i18n/ui-copy.ts'
KEY_RE = re.compile(r"'([^']+)':\s*\{\s*text:\s*'([^']*)'\s*,\s*review_status:\s*'([^']*)'\s*,?\s*\}")

CASES = ['COPY_TEXT', 'REVIEW_STATUS', 'DEPRECATED_KEY']

POST_LINE = "  'ia115.nav.POST': { text: 'Post', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },"

# Стаб↔ветвь (Н-39).
MUTANTS = [
    ('text-drift', 'COPY_TEXT', (COPY_TS, "text: 'Vorgänge'", "text: 'Vorgaenge'")),
    ('status-lost', 'REVIEW_STATUS',
     (COPY_TS, "'ia115.nav.START': { text: 'Start', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },",
      "'ia115.nav.START': { text: 'Start' },")),
    ('heute-alias', 'DEPRECATED_KEY',
     (COPY_TS, POST_LINE,
      POST_LINE + "\n  'ia115.nav.HEUTE': { text: 'Vorgänge', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },")),
]


def parse_entries(repo: Path):
    path = repo / COPY_TS
    if not path.exists():
        return None
    return {key: {'text': text, 'review_status': status} for key, text, status in KEY_RE.findall(path.read_text())}


def check_copy(repo: Path, source):
    entries = parse_entries(repo)
    if entries is None:
        return 1, 'COPY_MODULE_ABSENT: mobile/src/i18n/ui-copy.ts'
    for key, expected in source['copy'].items():
        if key not in entries:
            return 1, f'COPY_KEY_ABSENT: {key}'
        if entries[key]['text'] != expected['text']:
            return 1, f"COPY_TEXT_DRIFT: {key}: {entries[key]['text']!r} != {expected['text']!r}"
    return 0, f'keys={len(source["copy"])} тексты совпали побайтово'


def check_status(repo: Path, source):
    entries = parse_entries(repo)
    if entries is None:
        return 1, 'COPY_MODULE_ABSENT: mobile/src/i18n/ui-copy.ts'
    for key, expected in source['copy'].items():
        if key not in entries:
            return 1, f'COPY_KEY_ABSENT: {key}'
        if entries[key]['review_status'] != expected['review_status']:
            return 1, (f"REVIEW_STATUS_LOST: {key}: "
                       f"{entries[key]['review_status']!r} != {expected['review_status']!r}")
    return 0, 'review_status сохранён у каждого ключа'


def check_deprecated(repo: Path, source):
    path = repo / COPY_TS
    if not path.exists():
        return 1, 'COPY_MODULE_ABSENT: mobile/src/i18n/ui-copy.ts'
    text = path.read_text()
    used = [key for key in source['deprecated_keys'] if f"'{key}'" in text]
    if used:
        return 1, 'DEPRECATED_KEY_USED: ' + ','.join(used)
    return 0, 'deprecated-алиасы не используются'


CHECKS = {
    'COPY_TEXT': lambda repo, source: check_copy(repo, source),
    'REVIEW_STATUS': lambda repo, source: check_status(repo, source),
    'DEPRECATED_KEY': lambda repo, source: check_deprecated(repo, source),
}


def run_cases(repo: Path, cases):
    source = load_source()
    results = {}
    for case in cases:
        rc, detail = CHECKS[case](repo, source)
        results[case] = rc
        print(f'999 copy/{case}: rc={rc} {detail}', flush=True)
    return (0 if all(rc == 0 for rc in results.values()) else 1), results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', action='store_true')
    args = parser.parse_args()
    repo = args.repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        print('999 INFRASTRUCTURE: DISPOSABLE_REQUIRED', file=sys.stderr)
        return 2
    cases = [args.case] if args.case else CASES
    if args.matrix:
        ok = True
        print('MATRIX honest:', flush=True)
        rc, _ = run_cases(repo, cases)
        ok &= rc == 0
        for name, case, (target, old, new) in MUTANTS:
            files = {}
            if args.model:
                blobs = model_bytes([(target, old, new)])
                files.update({repo / t: b for t, b in blobs.items()})
            else:
                path = repo / target
                blob = path.read_bytes()
                if blob.count(old.encode()) != 1:
                    raise RuntimeError(f'MUTATION_ANCHOR_NOT_UNIQUE: {target}')
                files[path] = blob.replace(old.encode(), new.encode())
            with installed(files):
                rc, results = run_cases(repo, [case])
            named_red = results.get(case) == 1
            others = {c: v for c, v in results.items() if c != case}
            verdict = named_red and not others
            ok &= verdict
            print(f'MUTANT {name}: named={case} {"RED" if named_red else "GREEN"} -> {"OK" if verdict else "BROKEN"}', flush=True)
        return 0 if ok else 1
    if not (repo / COPY_TS).exists() and not args.model:
        print('999 COPY_MODULE_ABSENT')
        return 1
    if args.model:
        blobs = model_bytes()
        with installed({repo / t: b for t, b in blobs.items()}):
            rc, _ = run_cases(repo, cases)
        return rc
    rc, _ = run_cases(repo, cases)
    return rc


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError) as error:
        print('999 INFRASTRUCTURE:', error, file=sys.stderr)
        sys.exit(2)
