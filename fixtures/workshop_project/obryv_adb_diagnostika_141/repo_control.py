#!/usr/bin/env python3
"""Independent --repo controls over disposable product-owned files.

Each pinned LF script is green; changing only its line endings to CRLF must
produce its exact named pin refusal. Replay is also compared with the original
bytes held in memory using real cmp, independently of script execution or pins.
"""
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile

import probe

HERE = Path(__file__).resolve().parent
WRAPPER = HERE / 'red_obryv_adb_diagnostika_141.sh'
SCRIPTS = ('ci-first-run-135.sh', 'ci-erstinformation-118.sh', 'ci-pilot-995.sh')


def run(root):
    return subprocess.run(['bash', str(WRAPPER), '--repo', str(root)],
                          text=True, capture_output=True)


def main():
    src = probe.load_source()
    model_text, _, model_steps, model_scripts = probe.zagruzit_model(src)
    with tempfile.TemporaryDirectory(prefix='control141-', dir=HERE) as d:
        root = Path(d)
        workflow = root / '.github/workflows/mobile.yml'
        workflow.parent.mkdir(parents=True)
        shutil.copyfile(HERE / 'model/mobile.yml', workflow)
        scripts = root / 'mobile/scripts'
        scripts.mkdir(parents=True)
        for name in SCRIPTS:
            shutil.copyfile(HERE / 'model/mobile/scripts' / name, scripts / name)
        green = run(root)
        if green.returncode != 0 or green.stdout.count(' ok\n') != 46:
            print('CONTROL_REPO_RED: rc=%d\n%s\n%s' %
                  (green.returncode, green.stdout, green.stderr), file=sys.stderr)
            return 1
        print('CONTROL_REPO_GREEN rc=0 cases=46')
        for number, path in src['skripty'].items():
            original = model_scripts[number]
            green_line = 'CASE struktura-shag%s ok' % number
            if (not original or b'\r' in original or b'\n' not in original
                    or green.stdout.splitlines().count(green_line) != 1):
                print('CONTROL_LF_NOT_GREEN %s' % number, file=sys.stderr)
                return 1
            print('CONTROL_LF_GREEN %s rc=0' % number)
            crlf = original.replace(b'\n', b'\r\n')
            target = root / path
            target.write_bytes(crlf)
            red = run(root)
            target.write_bytes(original)
            expected = ('CASE struktura-shag%s KRASNO '
                        '(SKRIPT_PIN_RASHOZHDENIE: %s)' % (number, number))
            if red.returncode != 1 or red.stdout.splitlines().count(expected) != 1:
                print('CONTROL_CRLF_NOT_RED %s: rc=%d\n%s\n%s' %
                      (number, red.returncode, red.stdout, red.stderr),
                      file=sys.stderr)
                return 1
            print('CONTROL_CRLF_RED %s rc=1 SKRIPT_PIN_RASHOZHDENIE: %s' %
                  (number, number))
            # Expected bytes are embedded from memory before invoking replay;
            # neither the sandbox file nor the product file is our oracle.
            for label, script in (('LF', original), ('CRLF', crlf)):
                compare = "cmp -- %s <(printf '%%s' %s)" % (
                    shlex.quote(path), shlex.quote(script.decode('utf-8')))
                for environment in ('CHISTYJ', 'ACTIONS'):
                    actual, error = probe.ispolnit_replay(
                        compare, number, {}, environment, root, path, script)
                    reason = error or probe.sravnit_replay(actual, {'rc': 0})
                    if reason:
                        print('CONTROL_REPLAY_BYTES_RED %s %s %s: %s' %
                              (number, label, environment, reason), file=sys.stderr)
                        return 1
                    print('CONTROL_REPLAY_BYTES_GREEN %s %s %s rc=0' %
                          (number, label, environment))
        # Replay the mutated product script directly: no structural case and no
        # SHA pin can account for a missing DeviceServerDiedException here.
        _, mutant_scripts = probe.sdelat_stab(
            's-podmena-signatury-diag-118', model_text, model_scripts,
            src['signatury_regex'])
        case = src['kejsy']['118-devserverdied-povtor-spas']
        marker = next(m for m in case['ozhidanie']['vyvod']
                      if 'DeviceServerDiedException' in m)
        for environment in ('CHISTYJ', 'ACTIONS'):
            for script, expected_reason in (
                    (model_scripts['118'], None),
                    (mutant_scripts['118'], 'нет маркера вывода: %r' % marker)):
                actual, error = probe.ispolnit_replay(
                    model_steps['118'], '118', case['scena'], environment,
                    root, src['skripty']['118'], script)
                reason = error or probe.sravnit_replay(actual, case['ozhidanie'])
                if reason != expected_reason:
                    print('CONTROL_DIAG118_REPLAY_UNEXPECTED %s: %r != %r' %
                          (environment, reason, expected_reason), file=sys.stderr)
                    return 1
            print('CONTROL_DIAG118_REPLAY_RED %s: нет маркера вывода: %r' %
                  (environment, marker))
        target = scripts / SCRIPTS[0]
        target.write_bytes(target.read_bytes() + '# не меняет исполнение, меняет байты\n'.encode('utf-8'))
        red = run(root)
        if red.returncode != 1 or 'CASE struktura-shag135 KRASNO (SKRIPT_PIN_RASHOZHDENIE' not in red.stdout:
            print('CONTROL_PIN_NOT_RED: rc=%d\n%s\n%s' %
                  (red.returncode, red.stdout, red.stderr), file=sys.stderr)
            return 1
        print('CONTROL_PIN_RED rc=1 SKRIPT_PIN_RASHOZHDENIE')
        shutil.copyfile(HERE / 'model/mobile/scripts' / SCRIPTS[0], target)
        workflow.write_text(workflow.read_text().replace(
            'run: bash mobile/scripts/ci-first-run-135.sh', 'run: "true"', 1))
        red = run(root)
        if red.returncode != 1 or 'CASE struktura-shag135 KRASNO (VYZOV_SKRIPTA' not in red.stdout:
            print('CONTROL_CALL_NOT_RED: rc=%d\n%s\n%s' %
                  (red.returncode, red.stdout, red.stderr), file=sys.stderr)
            return 1
        print('CONTROL_CALL_RED rc=1 VYZOV_SKRIPTA')
    return 0


if __name__ == '__main__':
    sys.exit(main())
