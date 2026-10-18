#!/usr/bin/env python3
"""Обобщённая проба допуска (995, круг 2 адверсария): СЕМЕЙСТВО, не перечень.

Два независимых звена:
- СТАТИЧЕСКОЕ: в shipped mock runtime (`src/mocks/runtime.ts`) ровно ОДНА
  ветвь допуска и сравнение строгое — ровно одно сравнение с LHS `code`
  во всём файле, и это `code === PILOT_DEMO_CODE`; никаких вызовов методов
  на `code` (trim/normalize/toLowerCase/startsWith/…) и на константе.
  Ловит вторую разрешающую константу (mut-backdoor) и любые
  нормализующие/ослабленные варианты (mut-unicode), независимо от того,
  какие литералы выбрал обходчик.
- ДИНАМИЧЕСКОЕ: ОДИН jest-запуск table-driven по сгенерированному
  замкнутому семейству мутаций эталонного кода (удаление/замена/вставка в
  каждой позиции из замкнутого алфавита классов, все префиксные усечения,
  регистр, NFC/NFD, пустая/однобуквенная, иной код той же длины) на
  настоящем root route без props. Инвариант: authenticated iff
  code === PILOT_DEMO_CODE. Живой контроль LIVE_TRUE_CODE исключает
  вечно-красноту.

Источники и байты теста снимаются в память ДО запуска субъекта; множество
assertions сверяется с независимо вычисленным семейством
(ASSERTION_SET_MISMATCH). Полное значение кода в вывод редактируется.
"""
import argparse
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from runtime_probe import installed

HERE = Path(__file__).resolve().parent

CODE = 'synthetic-verification-value'
REPS = [
    ('ASCII_UPPER', 'X'), ('ASCII_PUNCT', '%'), ('SPACE', ' '), ('TAB', '\t'),
    ('NEWLINE', '\n'), ('CONTROL', '\x00'), ('ZWSP', '\u200b'), ('ZWNJ', '\u200c'),
    ('ZWJ', '\u200d'), ('WJ', '\u2060'), ('BOM', '\ufeff'), ('NBSP', '\xa0'),
    ('COMBINING', '\u0301'), ('FULLWIDTH', '\uff41'),
]


def family_counts():
    """Независимое зеркало генератора admission_family.test.tsx."""
    groups = [
        ('DELETE', len(CODE)),
        ('SUBSTITUTE', len(CODE) * len(REPS)),
        ('INSERT', (len(CODE) + 1) * len(REPS)),
        ('TRUNCATE', len(CODE) - 1),
        ('CASE', 2),
        ('EDGE', 3),
        ('NORMALIZE', 2),
    ]
    if len(CODE) < 8 or 'a' not in CODE:
        raise RuntimeError('FAMILY_MIRROR_BROKEN')  # генератор опирается на длину и позицию 'a'
    counts = dict(groups)
    return [f'995 family {name}[{count}]' for name, count in groups] + \
        ['995 family LIVE_TRUE_CODE[1]'], sum(counts.values())


def static_problems(runtime_src):
    problems = []
    strict = re.findall(r'\bcode\s*===\s*PILOT_DEMO_CODE\b', runtime_src)
    comparisons = re.findall(r'\bcode\s*(?:===|!==|==|!=)', runtime_src)
    on_code = re.findall(r'\bcode\s*\.\s*\w+\s*\(', runtime_src)
    on_const = re.findall(r'\bPILOT_DEMO_CODE\s*\.\s*\w+\s*\(', runtime_src)
    if len(strict) != 1:
        problems.append(f'ADMISSION_BRANCH_COUNT:{len(strict)}')
    if len(comparisons) != 1:
        problems.append(f'ADMISSION_EXTRA_COMPARISON:{len(comparisons)}')
    if on_code:
        problems.append('ADMISSION_METHOD_ON_CODE:' + ','.join(on_code))
    if on_const:
        problems.append('ADMISSION_METHOD_ON_CONSTANT:' + ','.join(on_const))
    return problems


def run(repo, only=None):
    repo = repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'): raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    bootstrap = mobile / 'src/bootstrap'
    runtime_src_path = mobile / 'src/mocks/runtime.ts'
    if not (bootstrap / 'pilot-app.tsx').exists() or not runtime_src_path.exists():
        print('995 PILOT_ABSENT'); return 1, 'PILOT_ABSENT'
    # Снимок источника ДО исполнения субъекта.
    runtime_src = runtime_src_path.read_bytes().decode()
    test_bytes = (HERE / 'admission_family.test.tsx').read_bytes()
    expected, total = family_counts()
    static = [] if only == 'dynamic' else static_problems(runtime_src)
    print(f'995 admission-family/static: rc={int(bool(static))}'
          + (' ' + ';'.join(static) if static else ''), flush=True)
    dynamic_rc = 0
    failures = list(static)
    if only != 'static':
        existed = bootstrap.exists()
        bootstrap.mkdir(parents=True, exist_ok=True)
        workspace = Path(tempfile.mkdtemp(prefix='__admfamily995_', dir=bootstrap))
        try:
            with installed({workspace / 'admission_family.test.tsx': test_bytes}):
                report = workspace / 'report.json'
                report.unlink(missing_ok=True)
                env = dict(os.environ, EXPO_PUBLIC_API_MODE='mock', PILOT_995_MODEL='actual')
                env.pop('PILOT_DEMO_CODE', None)
                cmd = ['node', str(mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand',
                       '--runTestsByPath', str(workspace / 'admission_family.test.tsx'),
                       '--json', '--outputFile', str(report)]
                proc = subprocess.run(cmd, cwd=mobile, env=env, capture_output=True, text=True, timeout=480)
                if not report.exists(): raise RuntimeError('JEST_REPORT_MISSING:' + proc.stderr[-1500:])
                payload = json.loads(report.read_text())
                assertions = [a for suite in payload['testResults'] for a in suite['assertionResults'] if a['status'] != 'pending']
                titles = sorted(a['title'] for a in assertions)
                if titles != sorted(expected) or len(titles) != len(assertions):
                    missing = sorted(set(expected) - set(titles)); extra = sorted(set(titles) - set(expected))
                    raise RuntimeError(f'ASSERTION_SET_MISMATCH: missing={missing} extra={extra} stderr=' + proc.stderr[-1200:])
                results = []
                for result in assertions:
                    rc = int(result['status'] == 'failed')
                    results.append(rc)
                    messages = '\n'.join(result['failureMessages']).replace(CODE, '[REDACTED]')
                    failures.append(messages)
                    print(f"995 admission-family/{result['title']}: rc={rc}", flush=True)
                    if rc: print(messages, file=sys.stderr)
                dynamic_rc = int(any(results))
                if proc.returncode not in (0, 1) or proc.returncode != dynamic_rc:
                    raise RuntimeError('RC_ASSERTION_MISMATCH')
        finally:
            shutil.rmtree(workspace)
            if not existed: bootstrap.rmdir()
    overall = int(bool(static) or bool(dynamic_rc))
    print(f'995 admission-family: rc={overall} family_size={total} '
          f'static={int(bool(static))} dynamic={dynamic_rc}', flush=True)
    return overall, '\n'.join(f for f in failures if f)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--only', choices=['static', 'dynamic'])
    args = parser.parse_args()
    rc, _ = run(args.repo, args.only)
    return rc


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
