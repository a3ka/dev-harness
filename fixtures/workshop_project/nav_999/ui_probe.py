#!/usr/bin/env python3
"""UI-примитивы и контейнеры 999 (CMP-MOB-002) на токенах D2.2.5.1.

Button/Notice/TextField + safe-area/keyboard контейнеры; accent — заливка
с тёмным текстом, лаймовый текст на светлом фоне красен. Каждый стаб
различим ровно на своём входе (Н-39).
"""
import argparse
from pathlib import Path
import shutil
import sys
import tempfile

from probe_lib import HERE, installed, jest_ready, model_bytes, run_jest

CASES = ['BUTTON_ROLE_VARIANTS', 'BUTTON_ROLE_LIGHT_SECONDARY', 'BUTTON_DISABLED_STATE', 'NOTICE_ROLE',
         'TEXTFIELD_LABEL_SECURE', 'SAFE_KEYBOARD_CONTAINER', 'ACCENT_NOT_TEXT_ON_LIGHT']


BUTTON = 'mobile/src/ui/button.tsx'
NOTICE = 'mobile/src/ui/notice.tsx'
TEXTFIELD = 'mobile/src/ui/text-field.tsx'
SHELL = 'mobile/src/bootstrap/tab-shell.tsx'

# Стаб↔ветвь (Н-39).
MUTANTS = [
    ('button-no-role', 'BUTTON_ROLE_VARIANTS', (BUTTON, 'accessibilityRole="button"\n', ''), ('BUTTON_ROLE_LIGHT_SECONDARY',)),
    ('notice-plain', 'NOTICE_ROLE', (NOTICE, 'accessibilityRole="alert"\n', ''), ()),
    ('textfield-no-label', 'TEXTFIELD_LABEL_SECURE',
     (TEXTFIELD, '<Text style={[styles.label, { color: tokens.ink }]}>{label}</Text>\n', ''), ()),
    ('no-keyboard-container', 'SAFE_KEYBOARD_CONTAINER', (SHELL, 'testID="shell-keyboard-container"\n', ''), ()),
    ('lime-text-light', 'ACCENT_NOT_TEXT_ON_LIGHT',
     (SHELL, "{ color: section === id ? tokens['on-card'] : tokens.ink }", '{ color: tokens.accent }'), ()),
]


def check_repo(repo: Path):
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        raise RuntimeError('JEST_ABSENT: node_modules не установлен (npm ci)')
    return mobile


def run(repo: Path, case=None, model=False):
    mobile = check_repo(repo)
    test_bytes = (HERE / 'ui.test.tsx').read_bytes()
    blobs = model_bytes() if model else None
    workspace = Path(tempfile.mkdtemp(prefix='__ui999_', dir=mobile / 'src'))
    results = {}
    try:
        files = {workspace / 'ui.test.tsx': test_bytes,
                 workspace / 'source.json': (HERE / 'source.json').read_bytes()}
        if blobs:
            files.update({repo / t: b for t, b in blobs.items()})
        with installed(files):
            pattern = f'^999 {FAMILY} {case}$' if case else None
            got, proc = run_jest(mobile, workspace / 'ui.test.tsx', pattern)
            wanted = [case] if case else CASES
            missing = [name for name in wanted if name not in got]
            if missing:
                raise RuntimeError('ASSERTION_SET_MISSING:' + ','.join(missing) + ':' + proc.stderr[-800:])
            results = {title: status for title, status in got.items() if title in wanted}
            for name, status in sorted(results.items()):
                print(f'999 ui/{name}: {"rc=0" if status == "passed" else "rc=1"}', flush=True)
    finally:
        shutil.rmtree(workspace)
    return (0 if all(s == 'passed' for s in results.values()) else 1), results


def matrix(repo: Path):
    ok = True
    print('MATRIX honest:', flush=True)
    rc, _ = run(repo)
    ok &= rc == 0
    for name, case, mutation, depends in MUTANTS:
        blobs = model_bytes([mutation])
        mobile = check_repo(repo)
        test_bytes = (HERE / 'ui.test.tsx').read_bytes()
        workspace = Path(tempfile.mkdtemp(prefix='__ui999m_', dir=mobile / 'src'))
        try:
            files = {workspace / 'ui.test.tsx': test_bytes,
                     workspace / 'source.json': (HERE / 'source.json').read_bytes()}
            files.update({repo / t: b for t, b in blobs.items()})
            with installed(files):
                got, proc = run_jest(mobile, workspace / 'ui.test.tsx')
            named = case
            if named not in got:
                raise RuntimeError('MUTANT_CASE_MISSING:' + named)
            unexpected_red = [t for t, s in got.items() if s == 'failed' and t not in depends and t != named]
            depends_missed = [t for t in depends if got.get(t) != 'failed']
            verdict = got[named] == 'failed' and not unexpected_red and not depends_missed
            ok &= verdict
            print(f'MUTANT {name}: named={case} {"RED" if got[named] == "failed" else "GREEN"}'
                  f' depends_red={[t for t in depends if got.get(t) == "failed"] or "none"}'
                  f' unexpected_red={unexpected_red or "none"} -> {"OK" if verdict else "BROKEN"}', flush=True)
        finally:
            shutil.rmtree(workspace)
    return 0 if ok else 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', action='store_true')
    args = parser.parse_args()
    repo = args.repo.resolve()
    if not (repo / 'mobile/src/ui/button.tsx').exists() and not args.model:
        print('999 UI_PRIMITIVES_ABSENT')
        return 1
    if args.matrix:
        return matrix(repo)
    rc, _ = run(repo, args.case, model=args.model)
    return rc


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError) as error:
        print('999 INFRASTRUCTURE:', error, file=sys.stderr)
        sys.exit(2)
