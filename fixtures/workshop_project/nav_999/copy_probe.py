#!/usr/bin/env python3
"""Copy-пробы 999 (CMP-MOB-002): производные runtime-ключи каталога.

Круг 3, решение арбитража 999 (К4): три статические колонки (тексты,
review_status, deprecated-алиасы) плюс клетки живого RNTL-рендера
TabShell по закрытой грамматике TABS × S × MODES из source.json —
COPY_TABS_<FROM> / COPY_PROFILE_<FROM> / COPY_DEEPLINK_<FROM> в каждом
режиме (reducedMotion × colorScheme): в каждом состоянии ВСЕ строковые
листья дерева сверяются с каталогом source.json (4.1), Back наблюдается
поимённо (global.back) в состояниях, где он видим, и отсутствует после
возврата (4.2). Матрица исполняет ВСЕ колонки на каждом мутанте; побочная
краснота допустна только в объявленном depends, неизмерение — нет.
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

SHELL = 'mobile/src/bootstrap/tab-shell.tsx'

CASES_STATIC = ['COPY_TEXT', 'REVIEW_STATUS', 'DEPRECATED_KEY']

POST_LINE = "  'ia115.nav.POST': { text: 'Post', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },"


def _modes():
    modes = load_source()['modes']
    return [(bool(rm), cs) for rm in modes['reducedMotion'] for cs in modes['colorScheme']]


def _tag(rm, cs):
    return f'RM{int(rm)}_{str(cs).upper()}'


def surface_cases():
    tabs = load_source()['tabs_order']
    cases = []
    for rm, cs in _modes():
        for tab in tabs:
            cases.append(f'COPY_TABS_{tab.upper()}_{_tag(rm, cs)}')
            cases.append(f'COPY_PROFILE_{tab.upper()}_{_tag(rm, cs)}')
            cases.append(f'COPY_DEEPLINK_{tab.upper()}_{_tag(rm, cs)}')
    return cases


CASES = CASES_STATIC + surface_cases()
SURFACE = set(surface_cases())


# Стаб↔ветвь (Н-39); depends измерен прогоном всех колонок матрицы и
# порождается генератором по грамматике (клетки той же оси перечня).
def _cells(pred, skip_named):
    return tuple(c for c in CASES if pred(c) and c != skip_named)


MUTANTS = [
    ('text-drift', 'COPY_TEXT', ((COPY_TS, "text: 'Vorgänge'", "text: 'Vorgaenge'"),),
     _cells(lambda c: c in SURFACE, 'COPY_TEXT')),
    ('status-lost', 'REVIEW_STATUS',
     ((COPY_TS, "'ia115.nav.START': { text: 'Start', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },",
       "'ia115.nav.START': { text: 'Start' },"),), ('COPY_TEXT',)),
    ('heute-alias', 'DEPRECATED_KEY',
     ((COPY_TS, POST_LINE,
       POST_LINE + "\n  'ia115.nav.HEUTE': { text: 'Vorgänge', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },"),), ()),
    ('back-copy-invented', 'COPY_PROFILE_START_RM0_DARK',
     ((SHELL, "<Text style={[styles.backLabel, { color: tokens.ink }]}>{uiCopyDe['global.back'].text}</Text>",
       "<Text style={[styles.backLabel, { color: tokens.ink }]}>{'Falscher Rückweg'}</Text>"),),
     _cells(lambda c: c.startswith(('COPY_PROFILE_', 'COPY_DEEPLINK_')), 'COPY_PROFILE_START_RM0_DARK')),
    ('light-copy-invented', 'COPY_TABS_START_RM0_LIGHT',
     (('mobile/src/bootstrap/tab-shell.tsx', '<View style={styles.header}>', "<View style={styles.header}>\n          {colorScheme === 'light' ? <Text>Falscher Rückweg</Text> : null}"),),
     _cells(lambda c: c.endswith('_LIGHT') and c != 'COPY_TEXT' and str(c).startswith(('COPY_TABS_', 'COPY_PROFILE_', 'COPY_DEEPLINK_')), 'COPY_TABS_START_RM0_LIGHT')),
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


CHECKS = {
    'COPY_TEXT': lambda repo, source: check_copy(repo, source),
    'REVIEW_STATUS': lambda repo, source: check_status(repo, source),
    'DEPRECATED_KEY': lambda repo, source: check_deprecated(repo, source),
}


def check_repo(repo: Path):
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        raise RuntimeError('JEST_ABSENT: node_modules не установлен (npm ci)')
    return mobile


def run_surface(repo: Path, case=None):
    """Живой RNTL-рендер поверхности: клетки состояний × режимов (К4.1/4.2)."""
    mobile = check_repo(repo)
    test_bytes = (HERE / 'copy_surface.test.tsx').read_bytes()
    workspace = Path(tempfile.mkdtemp(prefix='__copy999_', dir=mobile / 'src'))
    try:
        files = {workspace / 'copy_surface.test.tsx': test_bytes,
                 workspace / 'source.json': (HERE / 'source.json').read_bytes(),
                 workspace / 'surface_sweep.ts': (HERE / 'surface_sweep.ts').read_bytes()}
        wanted = [case] if case else sorted(SURFACE)
        with installed(files):
            pattern = f'^999 copy {case}$' if case else None
            got, proc = run_jest(mobile, workspace / 'copy_surface.test.tsx', pattern)
        missing = [name for name in wanted if name not in got]
        if missing:
            raise RuntimeError('SURFACE_CASE_MISSING:' + ','.join(missing) + ':' + proc.stderr[-800:])
        return {name: (0 if got[name] == 'passed' else 1) for name in wanted}
    finally:
        shutil.rmtree(workspace)


def run_cases(repo: Path, cases):
    source = load_source()
    results = {}
    surface_wanted = [c for c in cases if c in SURFACE]
    if surface_wanted:
        results.update(run_surface(repo, surface_wanted[0] if len(surface_wanted) == 1 else None))
    for case in cases:
        if case in SURFACE:
            detail = 'поверхность показывает только тексты каталога' if results[case] == 0 else \
                'SURFACE_TEXT_NOT_IN_CATALOG: есть видимый текст вне каталога (включая global.back)'
        else:
            rc, detail = CHECKS[case](repo, source)
            results[case] = rc
        print(f'999 copy/{case}: rc={results[case]} {detail}', flush=True)
    return (0 if all(rc == 0 for rc in results.values()) else 1), results


def mutant_files(repo: Path, patches, use_model: bool):
    if use_model:
        blobs = model_bytes(list(patches))
        return {repo / t: b for t, b in blobs.items()}
    files = {}
    for target, old, new in patches:
        path = repo / target
        blob = files.get(path, path.read_bytes())
        if blob.count(old.encode()) != 1:
            raise RuntimeError(f'MUTATION_ANCHOR_NOT_UNIQUE: {target}')
        files[path] = blob.replace(old.encode(), new.encode())
    return files


def run_matrix_mutant(repo: Path, name, case, patches, depends, use_model: bool):
    files = mutant_files(repo, patches, use_model)
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
        for name, case, patches, depends in MUTANTS:
            ok &= run_matrix_mutant(repo, name, case, patches, depends, args.model)
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
