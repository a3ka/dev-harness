#!/usr/bin/env python3
"""Общая механика проб 999 (CMP-MOB-002).

MODEL_FILES — карта «путь в R» → «эталон architect»; эталон — honest-модель
для красных тестов, в PR Complior-mob не копируется. Привязка стаб↔ветвь
живёт ТОЛЬКО здесь, в коде проб (Н-39), не в прозе контракта. Ожидания
снимаются в память (source.json, байты тестов) до запуска субъекта.
"""
from contextlib import contextmanager
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent

# Эталон 999: install-карта честной модели (нужна матрице и красному прогону
# на до-предметном дереве). Реализация implementer живёт по тем же путям.
MODEL_FILES = {
    'mobile/src/theme/tokens.ts': 'theme.tokens.ts',
    'mobile/src/theme/context.ts': 'theme.context.ts',
    'mobile/src/i18n/ui-copy.ts': 'i18n.ui-copy.ts',
    'mobile/src/ui/button.tsx': 'ui.button.tsx',
    'mobile/src/ui/notice.tsx': 'ui.notice.tsx',
    'mobile/src/ui/text-field.tsx': 'ui.text-field.tsx',
    'mobile/src/bootstrap/tab-shell.tsx': 'bootstrap.tab-shell.tsx',
    'mobile/src/features/start/start-screen.tsx': 'features.start-screen.tsx',
}


def load_source():
    return json.loads((HERE / 'source.json').read_bytes())


def source_hashes():
    return json.loads((HERE / 'source.json').read_bytes())['source_sha256']


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
            raise RuntimeError(f'MUTATION_ANCHOR_NOT_UNIQUE: {target}: {old[:60]!r} count={blob.count(old_b)}')
        blobs[target] = blob.replace(old_b, new_b)
    return blobs

def run_jest(repo_mobile: Path, test_path: Path, name_pattern=None, env_extra=None, timeout=300):
    """Один процесс Jest; возвращает {case: 'passed'|'failed'}.

    case — суффикс имени assertion после '999 <family> '.
    """
    import os
    import tempfile
    paths = [test_path] if isinstance(test_path, (str, Path)) else list(test_path)

    report = Path(tempfile.mkstemp(suffix='.json')[1])
    report.unlink()
    env = dict(os.environ, EXPO_PUBLIC_API_MODE='mock')
    env.pop('PILOT_DEMO_CODE', None)
    if env_extra:
        env.update(env_extra)
    cmd = ['node', str(repo_mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand',
           '--runTestsByPath', *map(str, paths), '--json', '--outputFile', str(report)]
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


def jest_ready(repo_mobile: Path):
    return (repo_mobile / 'node_modules/jest/bin/jest.js').exists()
