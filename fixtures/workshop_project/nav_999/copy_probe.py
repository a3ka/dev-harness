#!/usr/bin/env python3
"""Copy-пробы 999 (CMP-MOB-002): производные runtime-ключи каталога.

Три статические колонки (тексты, review_status, deprecated-алиасы) плюс
колонка COPY_SURFACE_CATALOG: живой Jest-рендер TabShell по закрытому
перечню состояний (каждая вкладка, профиль, deep link) — каждый видимый
текст поверхности сверен с каталогом source.json, включая global.back
(Н-324/Н-325: перечень состояний порождает клетки, не список обходов).
Матрица исполняет ВСЕ колонки на каждом мутанте; побочная краснота
допустима только в объявленном depends, неизмерение — нет.
"""
import argparse
from pathlib import Path
import re
import shutil
import sys
import tempfile

from probe_lib import HERE, installed, jest_ready, load_source, model_bytes, run_jest

COPY_TS = 'mobile/src/i18n/ui-copy.ts'
KEY_RE = re.compile(r"'([^']+)':\s*\{\s*text:\s*'([^']*)'\s*,\s*review_status:\s*'([^']*)'\s*,?\s*\}")

CASES = ['COPY_TEXT', 'REVIEW_STATUS', 'DEPRECATED_KEY', 'COPY_SURFACE_CATALOG']

POST_LINE = "  'ia115.nav.POST': { text: 'Post', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },"

SHELL = 'mobile/src/bootstrap/tab-shell.tsx'

# Стаб↔ветвь (Н-39); depends измерен прогоном всех колонок матрицы.
MUTANTS = [
    ('text-drift', 'COPY_TEXT', (COPY_TS, "text: 'Vorgänge'", "text: 'Vorgaenge'"), ('COPY_SURFACE_CATALOG',)),
    ('status-lost', 'REVIEW_STATUS',
     (COPY_TS, "'ia115.nav.START': { text: 'Start', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },",
      "'ia115.nav.START': { text: 'Start' },"), ('COPY_TEXT',)),
    ('heute-alias', 'DEPRECATED_KEY',
     (COPY_TS, POST_LINE,
      POST_LINE + "\n  'ia115.nav.HEUTE': { text: 'Vorgänge', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },"), ()),
    ('back-copy-invented', 'COPY_SURFACE_CATALOG',
     (SHELL, "<Text style={[styles.backLabel, { color: tokens.ink }]}>{uiCopyDe['global.back'].text}</Text>",
      "<Text style={[styles.backLabel, { color: tokens.ink }]}>{'Falscher Rückweg'}</Text>"), ()),
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
    return 0, f'keys={len(source['copy'])} тексты совпали побайтово'


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


def check_surface(repo: Path):
    """Живой RNTL-рендер поверхности shell: все видимые тексты — из каталога."""
    mobile = repo / 'mobile'
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        return 1, 'DISPOSABLE_REQUIRED'
    if not jest_ready(mobile):
        return 1, 'JEST_ABSENT: node_modules не установлен (npm ci)'
    test_bytes = (HERE / 'copy_surface.test.tsx').read_bytes()
    workspace = Path(tempfile.mkdtemp(prefix='__copy999_', dir=mobile / 'src'))
    try:
        files = {workspace / 'copy_surface.test.tsx': test_bytes,
                 workspace / 'source.json': (HERE / 'source.json').read_bytes()}
        with installed(files):
            got, proc = run_jest(mobile, workspace / 'copy_surface.test.tsx')
        if 'COPY_SURFACE_CATALOG' not in got:
            return 1, 'SURFACE_CASE_MISSING:' + proc.stderr[-400:]
        if got['COPY_SURFACE_CATALOG'] != 'passed':
            return 1, 'SURFACE_TEXT_NOT_IN_CATALOG: есть видимый текст вне каталога (включая global.back)'
        return 0, 'поверхность (вкладки/профиль/deep link) показывает только тексты каталога'
    finally:
        shutil.rmtree(workspace)


CHECKS = {
    'COPY_TEXT': lambda repo, source: check_copy(repo, source),
    'REVIEW_STATUS': lambda repo, source: check_status(repo, source),
    'DEPRECATED_KEY': lambda repo, source: check_deprecated(repo, source),
}


def run_cases(repo: Path, cases):
    source = load_source()
    results = {}
    for case in cases:
        if case == 'COPY_SURFACE_CATALOG':
            rc, detail = check_surface(repo)
        else:
            rc, detail = CHECKS[case](repo, source)
        results[case] = rc
        print(f'999 copy/{case}: rc={rc} {detail}', flush=True)
    return (0 if all(rc == 0 for rc in results.values()) else 1), results


def mutant_files(repo: Path, mutation, use_model: bool):
    target, old, new = mutation
    if use_model:
        blobs = model_bytes([mutation])
        return {repo / t: b for t, b in blobs.items()}
    path = repo / target
    blob = path.read_bytes()
    if blob.count(old.encode()) != 1:
        raise RuntimeError(f'MUTATION_ANCHOR_NOT_UNIQUE: {target}')
    return {path: blob.replace(old.encode(), new.encode())}


def run_matrix_mutant(repo: Path, name, case, mutation, depends, use_model: bool):
    files = mutant_files(repo, mutation, use_model)
    with installed(files):
        _, results = run_cases(repo, CASES)
    named_red = results.get(case) == 1
    others = {c: v for c, v in results.items() if c != case}
    unexpected_red = [c for c, v in others.items() if v == 1 and c not in depends]
    depends_missed = [c for c in depends if others.get(c) != 1]
    verdict = named_red and not unexpected_red and not depends_missed
    print(f'MUTANT {name}: named={case} {"RED" if named_red else "GREEN"}'
          f' depends_red={[c for c in depends if others.get(c) == 1] or "none"}'
          f' unexpected_red={unexpected_red or "none"} -> {"OK" if verdict else "BROKEN"}', flush=True)
    return verdict


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
        for name, case, mutation, depends in MUTANTS:
            ok &= run_matrix_mutant(repo, name, case, mutation, depends, args.model)
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
