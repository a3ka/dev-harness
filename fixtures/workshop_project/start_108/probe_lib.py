#!/usr/bin/env python3
"""Общая механика проб 108 (CMP-MOB-004 Start F04.01–F04.07).

Отато семейства erstinfo_107 (контракт 107, круг 2): установка эталонной
модели по путям поставки, исполнение настоящего Jest/RNTL на disposable R,
побайтовые мутации с требованием уникальности якоря, восстановление дерева.
Оракул — source.json (снят с Complior-mob 76ac10fa ДО запуска субъекта);
ожидания проб несут те же значения побайтово.
"""
from contextlib import contextmanager
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent

# Эталон architect: relpath в продукте → файл модели.
MODEL_FILES = {
    'mobile/src/api/api-client.ts': 'api.api-client.ts',
    'mobile/src/features/start/start-screen.tsx': 'features.start.start-screen.tsx',
    'mobile/src/ui/agent-presence/agent-presence.tsx': 'ui.agent-presence.tsx',
    'mobile/src/ui/conversation-composer/conversation-composer.tsx': 'ui.conversation-composer.tsx',
    'mobile/src/i18n/ui-copy.ts': 'i18n.ui-copy.ts',
    'mobile/src/mocks/start-mock.ts': 'mocks.start-mock.ts',
    'mobile/src/mocks/runtime.ts': 'mocks.runtime.ts',
}

TEST_INSTALL = 'mobile/src/features/start/__tests__/start-108.probe.test.tsx'
COMPONENT_PATH = 'mobile/src/features/start/start-screen.tsx'

FAMILY_PREFIX = '108 start '


def load_source():
    return json.loads((HERE / 'source.json').read_bytes())


def source_hashes():
    return load_source()['source_sha256']


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


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
    """
    blobs = {}
    for target, fixture in MODEL_FILES.items():
        blobs[target] = (HERE / 'model' / fixture).read_bytes()
    for target, old, new in mutations:
        blob = blobs[target]
        old_b = old.encode() if isinstance(old, str) else old
        new_b = new.encode() if isinstance(new, str) else new
        if blob.count(old_b) != 1:
            raise RuntimeError(
                f'MUTATION_ANCHOR_NOT_UNIQUE: {target}: {old[:60]!r} count={blob.count(old_b)}'
            )
        blobs[target] = blob.replace(old_b, new_b)
    return blobs


def run_jest(repo_mobile: Path, test_path: Path, name_pattern=None, timeout=300):
    """Один процесс Jest; возвращает {case: 'passed'|'failed'}.

    case — имя assertion (префикс '108 start ' отрезает проба).
    """
    import os
    import tempfile
    report = Path(tempfile.mkstemp(suffix='.json')[1])
    report.unlink()
    env = dict(os.environ, EXPO_PUBLIC_API_MODE='mock')
    env.pop('PILOT_DEMO_CODE', None)
    cmd = ['node', str(repo_mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand',
           '--runTestsByPath', str(test_path), '--json', '--outputFile', str(report)]
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
            title = assertion['title']
            cases[title] = assertion['status']
    return cases, proc


def jest_ready(repo_mobile: Path) -> bool:
    return (repo_mobile / 'node_modules/jest/bin/jest.js').exists()
