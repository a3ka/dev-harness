#!/usr/bin/env python3
"""Общая механика проб 117 (CMP-MOB-006: вход F03.01/F03.02 + НАШ splash).

Семейство first_run_111: установка эталонной модели по путям поставки,
исполнение настоящего Jest/RNTL на disposable R, побайтовые мутации с
требованием уникальности якоря, восстановление дерева. Оракул —
source.json (снят с read-only docs/ Complior-mob 8748a7a335 ДО запуска
субъекта); ожидания проб несут те же значения литералами и не читают
модули субъекта (Н-351).
"""
from contextlib import contextmanager
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent

# Эталон architect: relpath в продукте → файл модели.
MODEL_FILES = {
    'mobile/app.json': 'app.json',
    'mobile/assets/images/splash-sign-dark.png': 'splash-sign-dark.png',
    'mobile/assets/images/splash-sign-light.png': 'splash-sign-light.png',
    'mobile/src/bootstrap/pilot-app.tsx': 'bootstrap.pilot-app.tsx',
    'mobile/src/features/auth/auth-screen.tsx': 'features.auth.auth-screen.tsx',
    'mobile/assets/images/icon.png': 'icon.png',
    'mobile/assets/images/splash-composite-dark.png': 'splash-composite-dark.png',
    'mobile/assets/images/splash-composite-light.png': 'splash-composite-light.png',
    'mobile/assets/images/android-icon-foreground.png': 'android-icon-foreground.png',
    'mobile/assets/images/android-icon-background.png': 'android-icon-background.png',
    'mobile/assets/images/android-icon-monochrome.png': 'android-icon-monochrome.png',
    'mobile/assets/images/favicon.png': 'favicon.png',
    'mobile/.maestro/vkhod-117-splash-vhod.yaml': 'vkhod-117-splash-vhod.yaml',
    # 117 v2 (First-Run по First-Run.png, инв. 6 accent-text): экран
    # First-Run и аддитивный токен accent-text — в границах слова владельца
    # (Button 999 и ink-muted не трогаются, круг 2 v2, Б3).
    'mobile/src/features/auth/first-run-screen.tsx': 'features.auth.first-run-screen.tsx',
    'mobile/src/theme/tokens.ts': 'theme.tokens.ts',
}

TEST_INSTALL = 'mobile/src/bootstrap/__tests__/vkhod-117.probe.test.tsx'

FAMILY_PREFIX = '117 vkhod '


def load_source():
    return json.loads((HERE / 'source.json').read_bytes())


@contextmanager
def installed(files):
    """Восстанавливает только тронутые файлы/каталоги данного вызова.

    files: {Path: bytes | None}; None означает «удалить на время вызова».
    """
    before = {p: p.read_bytes() if p.exists() else None for p in files}
    created = set()
    try:
        for path, content in files.items():
            parent = path.parent
            while not parent.exists():
                created.add(parent)
                parent = parent.parent
            path.parent.mkdir(parents=True, exist_ok=True)
            if content is None:
                path.unlink(missing_ok=True)
            else:
                path.write_bytes(content)
        yield
    finally:
        for path, content in before.items():
            if content is None:
                path.unlink(missing_ok=True)
            else:
                path.write_bytes(content)
        for path in sorted(created, key=lambda p: len(p.parts), reverse=True):
            path.rmdir()


def model_bytes(mutations=()):
    """Байты эталона; mutations — [(relpath, old, new)] побайтовые замены.

    Каждая замена обязана находиться ровно один раз — иначе мутант не тот.
    old=None — стаб целым файлом по пути вне эталона (байты new; путь
    восстанавливается installed как любой другой).
    """
    blobs = {}
    for target, fixture in MODEL_FILES.items():
        blobs[target] = (HERE / 'model' / fixture).read_bytes()
    for target, old, new in mutations:
        new_b = new.encode() if isinstance(new, str) else new
        if old is None:
            blobs[target] = new_b
            continue
        blob = blobs[target]
        old_b = old.encode() if isinstance(old, str) else old
        if blob.count(old_b) != 1:
            raise RuntimeError(
                f'MUTATION_ANCHOR_NOT_UNIQUE: {target}: {old[:60]!r} count={blob.count(old_b)}'
            )
        blobs[target] = blob.replace(old_b, new_b)
    return blobs


def run_jest(repo_mobile: Path, test_path: Path, name_pattern=None, timeout=300):
    """Один процесс Jest; возвращает {case: 'passed'|'failed'}."""
    import os
    import tempfile
    report = Path(tempfile.mkstemp(suffix='.json')[1])
    report.unlink()
    env = dict(os.environ, EXPO_PUBLIC_API_MODE='mock')
    env.pop('PILOT_DEMO_CODE', None)
    paths = test_path if isinstance(test_path, list) else [test_path]
    cmd = ['node', str(repo_mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand',
           '--runTestsByPath', *[str(p) for p in paths], '--json', '--outputFile', str(report)]
    if name_pattern:
        cmd += ['--testNamePattern', name_pattern]
    proc = subprocess.run(cmd, cwd=repo_mobile, env=env, capture_output=True, text=True, timeout=timeout)
    if not report.exists():
        raise RuntimeError('JEST_REPORT_MISSING:' + proc.stderr[-1500:])
    payload = json.loads(report.read_text())
    report.unlink(missing_ok=True)
    cases = {}
    for suite in payload['testResults']:
        for assertion in suite['assertionResults']:
            if assertion['status'] == 'pending':
                continue
            cases[assertion['title']] = assertion['status']
    return cases, proc


def jest_ready(repo_mobile: Path) -> bool:
    return (repo_mobile / 'node_modules/jest/bin/jest.js').exists()
