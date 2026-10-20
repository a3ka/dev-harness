#!/usr/bin/env python3
"""Общая механика проб 116 (CMP-MOB-005, Complior-mob #9).

Отато семейства first_run_111 (контракт 111): установка эталонной модели
по путям поставки, исполнение настоящего Jest/RNTL на disposable R,
побайтовые мутации с требованием уникальности якоря, восстановление
дерева. Оракул — source.json (снят с read-only docs/ Complior-mob
16eb708a ДО запуска субъекта); ожидания проб несут те же значения
литералами и не читают модули субъекта (Н-351).
"""
from contextlib import contextmanager
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent

# Эталон architect: relpath в продукте → файл модели.
MODEL_FILES = {
    'mobile/src/features/conversation/conversation-screen.tsx':
        'features.conversation.conversation-screen.tsx',
    'mobile/src/ui/conversation-composer/conversation-composer.tsx':
        'ui.conversation-composer.conversation-composer.tsx',
    'mobile/src/api/api-client.ts': 'api.api-client.ts',
    'mobile/src/mocks/runtime.ts': 'mocks.runtime.ts',
    'mobile/src/mocks/conversation-mock.ts': 'mocks.conversation-mock.ts',
    'mobile/src/i18n/ui-copy.ts': 'i18n.ui-copy.ts',
}

TEST_INSTALL = 'mobile/src/features/conversation/__tests__/mission-116.probe.test.tsx'
SCREEN_PATH = 'mobile/src/features/conversation/conversation-screen.tsx'

FAMILY_PREFIX = '116 mission '


def load_source():
    return json.loads((HERE / 'source.json').read_bytes())


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

    case — имя assertion (префикс '116 mission ' отрезает проба).
    """
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
            title = assertion['title']
            cases[title] = assertion['status']
    return cases, proc


def jest_ready(repo_mobile: Path) -> bool:
    return (repo_mobile / 'node_modules/jest/bin/jest.js').exists()
