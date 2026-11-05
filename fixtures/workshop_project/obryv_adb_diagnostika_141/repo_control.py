#!/usr/bin/env python3
"""Independent --repo control: copies pinned fixture scripts as product-owned files."""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
WRAPPER = HERE / 'red_obryv_adb_diagnostika_141.sh'
SCRIPTS = ('ci-first-run-135.sh', 'ci-erstinformation-118.sh', 'ci-pilot-995.sh')


def run(root):
    return subprocess.run(['bash', str(WRAPPER), '--repo', str(root)],
                          text=True, capture_output=True)


def main():
    with tempfile.TemporaryDirectory(prefix='control141-') as d:
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
        target = scripts / SCRIPTS[0]
        target.write_text(target.read_text() + '# не меняет исполнение, меняет байты\n')
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
