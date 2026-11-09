#!/usr/bin/env python3
"""Execute inventory and second-writer regressions against a pinned product copy.

The product stays read-only; each copied workflow has one targeted mutation.
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
    parser.add_argument('--second-writer', action='store_true')
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
        if args.second_writer:
            anchor = '            echo "SELECTION_KONEC"\n          } >> "$GITHUB_OUTPUT"\n'
            if source.count(anchor) != 1:
                print('MATRIX_MUTANT_INFRASTRUCTURE: sel output anchor absent', file=sys.stderr)
                return 2
            path.write_text(source.replace(anchor, anchor +
                '          echo \'matrix={"include":[{"screen":{"id":"podmena"}}]}\' >> "$GITHUB_OUTPUT"\n'))
        else:
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
        if args.second_writer:
            if 'КЛЕТКА selector-output КРАСНА: MATRIX_OUTPUT_WRITERS: 2' not in lines:
                print('MATRIX_MUTANT_NOT_RED: selector-output', file=sys.stderr)
                return 1
        else:
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
