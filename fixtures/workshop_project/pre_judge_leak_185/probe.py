#!/usr/bin/env python3
"""185: real pre_judge prepare against independent project and harness Git trees."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BRANCH = 'wip/185/architect'
OLD = '''  # Детектор утечки — ДЕЙСТВУЮЩИЙ scripts/check_no_leak.sh репозитория R
  # (второго детектора не заводим). Отсутствие детектора — rc 2, не зелёный.
  DETECTOR="$R/scripts/check_no_leak.sh"
  [ -f "$DETECTOR" ] || skip "нет детектора утечки: scripts/check_no_leak.sh"'''
NEW = '''  # Применяем детектор установленного харнесса к переданному корню проекта.
  HARNESS_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || skip "нет каталога скриптов харнесса"
  DETECTOR="$HARNESS_SCRIPTS/check_no_leak.sh"
  [ -f "$DETECTOR" ] || skip "нет детектора утечки харнесса: scripts/check_no_leak.sh"'''


def substitute(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('mutation site count != 1: ' + old[:90])
    return text.replace(old, new, 1)


def git(root, *args):
    result = subprocess.run(['git', '-C', str(root), *args], capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError('git failed: ' + str(args) + ': ' + result.stderr)
    return result.stdout.strip()


class World:
    def __init__(self, base, script):
        self.base = base
        self.harness = base / 'harness'
        self.project = base / 'project'
        self.state = base / 'state'
        self.tmp = base / 'snapshots'
        self.state.mkdir()
        self.tmp.mkdir()
        (self.harness / 'scripts').mkdir(parents=True)
        self.project.mkdir()
        (self.harness / 'scripts/pre_judge.sh').write_text(script, encoding='utf-8')
        (self.harness / 'scripts/check_no_leak.sh').write_bytes(
            (ROOT / 'scripts/check_no_leak.sh').read_bytes())
        for root in (self.harness, self.project):
            git(root, 'init', '-q', '-b', 'main')
            (root / 'tracked.txt').write_text('clean\n', encoding='utf-8')
            git(root, 'add', '.')
            git(root, '-c', 'user.name=fixture', '-c', 'user.email=fixture@example.invalid',
                'commit', '-q', '-m', 'baseline')
        git(self.project, 'branch', BRANCH)
        self.oid = git(self.project, 'rev-parse', BRANCH)
        git(self.project, 'update-ref', 'refs/remotes/origin/' + BRANCH, self.oid)
        self.env = {**os.environ, 'TMPDIR': str(self.tmp)}
        self.detector = self.harness / 'scripts/check_no_leak.sh'
        for root in (self.project, self.harness):
            snap = subprocess.run(['bash', str(self.detector), '--snapshot', str(root)],
                                  env=self.env, capture_output=True, text=True)
            if snap.returncode != 0:
                raise RuntimeError('snapshot failure: ' + snap.stderr)

    def invoke(self):
        return subprocess.run(['bash', str(self.harness / 'scripts/pre_judge.sh'),
                               'prepare', '--repo', str(self.project), '--branch', BRANCH,
                               '--sostojanie', str(self.state), '--timeout', '0'],
                              env=self.env, capture_output=True, text=True)


def check(label, script, variant):
    with tempfile.TemporaryDirectory(prefix='pre-judge-185-') as temp:
        world = World(Path(temp), script)
        if variant in ('dirty', 'local_fake'):
            (world.project / 'tracked.txt').write_text('changed after snapshot\n', encoding='utf-8')
        if variant == 'local_fake':
            (world.project / 'scripts').mkdir()
            (world.project / 'scripts/check_no_leak.sh').write_text('#!/bin/sh\nexit 0\n', encoding='utf-8')
        if variant == 'missing_harness':
            world.detector.unlink()
        got = world.invoke()
        if variant in ('dirty', 'local_fake'):
            expected_rc, reason = 1, 'ОТКАЗ: CHECK_NO_LEAK_KRASEN\n'
        elif variant == 'missing_harness':
            expected_rc, reason = 2, 'NOT_IMPLEMENTED: нет детектора утечки харнесса:'
        else:
            expected_rc, reason = 0, ''
        expected_out = (f'OBJECT={world.oid}\nSOSTOJANIE={world.state}\n'
                        if expected_rc == 0 else '')
        # Oracle is captured before invoking the subject, never from project files afterward.
        reason_ok = (not got.stderr if not reason else
                     (got.stderr.startswith(reason) if expected_rc == 2 else
                      got.stderr.startswith('ОТКАЗ: основной чекаут загрязнён: ') and
                      reason in got.stderr.splitlines(keepends=True)))
        ok = (got.returncode == expected_rc and got.stdout == expected_out and reason_ok)
        print(f'185 {label} {"ZELENO" if ok else "KRASNO"} '
              f'rc={got.returncode} stdout={got.stdout!r} stderr={got.stderr!r}', flush=True)
        return ok


def source(mode):
    actual = (ROOT / 'scripts/pre_judge.sh').read_text(encoding='utf-8')
    return actual if mode == '--repo' else substitute(actual, OLD, NEW)


def main(mode):
    if mode in ('--model', '--repo'):
        script = source(mode)
        results = [check(name, script, name) for name in
                   ('clean', 'dirty', 'local_fake', 'missing_harness')]
        return 0 if all(results) else 1
    honest = source('--model')
    # Each mutant is attached to the sole public input on which it differs.
    mutants = {
        'no_call': (substitute(honest, 'leak_out="$(bash "$DETECTOR" --check "$R" 2>&1)"; leak_rc=$?',
                               'leak_out=""; leak_rc=0'), 'dirty'),
        'ignore_rc': (substitute(honest, 'if [ "$leak_rc" -ne 0 ]; then',
                                 'if [ 0 -ne 0 ]; then'), 'dirty'),
        'copy_in_project': (substitute(honest, 'DETECTOR="$HARNESS_SCRIPTS/check_no_leak.sh"',
                                       'DETECTOR="$R/scripts/check_no_leak.sh"'), 'local_fake'),
        'wrong_root': (substitute(honest, 'bash "$DETECTOR" --check "$R"',
                                  'bash "$DETECTOR" --check "$HARNESS_SCRIPTS/.."'), 'dirty'),
        'red_as_green': (substitute(honest, 'if [ "$leak_rc" -ne 0 ]; then',
                                     'if [ "$leak_rc" -ne 1 ] && [ "$leak_rc" -ne 0 ]; then'), 'dirty'),
        'missing_as_green': (substitute(honest, '[ -f "$DETECTOR" ] || skip "нет детектора утечки харнесса: scripts/check_no_leak.sh"',
                                         '[ -f "$DETECTOR" ] || { printf "OBJECT=%s\\nSOSTOJANIE=%s\\n" "$remote_tip" "$S_CANON"; exit 0; }'), 'missing_harness'),
    }
    errors = 0
    for name, (mutant, variant) in mutants.items():
        if not check('control_' + name, honest, variant):
            errors += 1
            continue
        if check('mutant_' + name, mutant, variant):
            print('185 STAB ' + name + ' ZHIV', flush=True)
            errors += 1
        else:
            print('185 STAB ' + name + ' caught', flush=True)
    return 1 if errors else 0


if __name__ == '__main__':
    if len(sys.argv) > 2 or (len(sys.argv) == 2 and sys.argv[1] not in
                             ('--model', '--repo', '--stabs')):
        sys.exit('usage: probe.py [--repo|--model|--stabs]')
    try:
        sys.exit(main(sys.argv[1] if len(sys.argv) == 2 else '--repo'))
    except (OSError, RuntimeError) as exc:
        print('NOT_IMPLEMENTED: fixture: ' + str(exc), file=sys.stderr)
        sys.exit(2)
