#!/usr/bin/env python3
"""Execute the 143 inventory regression against an unchanged product and a copy.

The copied workflow alone loses its matrix output; the product stays read-only.
"""
import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
WORKFLOW = '.github/workflows/mobile.yml'
SUBJECT_FILES = (WORKFLOW, 'mobile/ci-screens.json',
                 'mobile/scripts/select-ci-screens.cjs',
                 'mobile/scripts/ci-aggregate.cjs',
                 'mobile/scripts/run-ci-screen.cjs')
BRANCHES = ('y01-nabor-jobs', 'y02-agregat-needs',
            'i02-jobs-iz-karty', 'i04-agregaty-iz-karty')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--product', type=Path, required=True)
    args = parser.parse_args()
    product = args.product.resolve()
    revision = subprocess.run(['git', '-C', str(product), 'rev-parse', '--short=7', 'HEAD'],
                              capture_output=True, text=True, check=True).stdout.strip()
    if revision != '88e9cc8':
        print('PRODUCT_REVISION_UNEXPECTED: ' + revision, file=sys.stderr)
        return 2
    with tempfile.TemporaryDirectory(prefix='.matrix-inventory-v4-', dir=HERE) as temp:
        root = Path(temp)
        for rel in SUBJECT_FILES:
            target = root / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(product / rel, target)
        path = root / WORKFLOW
        source = path.read_text()
        output = '      matrix: ${{ steps.sel.outputs.matrix }}\n'
        if source.count(output) != 1:
            print('MATRIX_MUTANT_INFRASTRUCTURE: output anchor absent', file=sys.stderr)
            return 2
        path.write_text(source.replace(output, ''))
        proc = subprocess.run(['bash', str(HERE / 'red_mob_ci_143.sh'), '--repo', str(root)],
                              capture_output=True, text=True, timeout=180)
        print(proc.stdout, end='')
        if proc.stderr:
            print(proc.stderr, end='', file=sys.stderr)
        if proc.returncode != 1:
            print('MATRIX_MUTANT_NOT_RED: rc=' + str(proc.returncode), file=sys.stderr)
            return 1
        lines = proc.stdout.splitlines()
        for branch in BRANCHES:
            expected = ('КЛЕТКА ' + branch +
                        ': MATRIX_OUTPUT_REQUIRED: e2e-screen без вывода селектора КРАСНА')
            if expected not in lines:
                print('MATRIX_MUTANT_NOT_RED: ' + branch, file=sys.stderr)
                return 1
        return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, subprocess.CalledProcessError, subprocess.TimeoutExpired, KeyError, ValueError) as exc:
        print('MATRIX_MUTANT_INFRASTRUCTURE: ' + str(exc), file=sys.stderr)
        sys.exit(2)
