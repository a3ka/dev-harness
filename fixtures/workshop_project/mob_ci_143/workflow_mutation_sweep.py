#!/usr/bin/env python3
"""One independent product copy and one named --repo cell per workflow field.

Run after the honest full --repo control; the model is loaded before copying
any product content. Each disposable copy is destroyed immediately after its
single mutation. No subject-controlled file is used as the expected value.
"""
import argparse
import copy
from pathlib import Path
import subprocess
import sys
import tempfile

import yaml

from matrix_v3 import model_workflow
from workflow_sweep_v3 import controls, match, mutate, name_of


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True, type=Path)
    ap.add_argument('--verify-dir', type=Path, default=Path('/tmp/dev-harness-verify'))
    args = ap.parse_args()
    model = model_workflow()
    source = args.repo.resolve()
    workflow = yaml.safe_load((source / '.github/workflows/mobile.yml').read_text())
    rows = controls(model, workflow)
    for row in rows:
        if not match(workflow, model, row):
            print('HONEST_CONTROL_RED: ' + name_of(row), file=sys.stderr)
            return 2
    print('ПОЛЕ\tКЛЕТКА\tМУТАНТ', flush=True)
    for row in rows:
        name = name_of(row)
        # A fresh *whole* candidate copy, not a fabricated partial workflow.
        with tempfile.TemporaryDirectory(prefix='architect143-wf-', dir=args.verify_dir) as folder:
            target = Path(folder) / 'candidate'
            subprocess.run(['cp', '-a', '--reflink=auto', str(source), str(target)], check=True)
            candidate = mutate(copy.deepcopy(workflow), model, row)
            (target / '.github/workflows/mobile.yml').write_text(yaml.safe_dump(candidate,
                sort_keys=False, allow_unicode=True))
            call = subprocess.run([sys.executable, str(Path(__file__).resolve().parent / 'matrix_v3.py'),
                                   '--repo', str(target), '--workflow-cell', name],
                                  text=True, capture_output=True, timeout=30)
            expected = 'КЛЕТКА %s КРАСНА: WORKFLOW_CONTROL_%s' % (name, name)
            if call.returncode != 1 or call.stdout.strip() != expected:
                print('MUTANT_NOT_CAUGHT: %s rc=%d stdout=%r stderr=%r' %
                      (name, call.returncode, call.stdout, call.stderr), file=sys.stderr)
                return 1
            print('%s\t%s\tКРАСЕН rc 1' % ('.'.join(str(x) for x in row if x is not None), name), flush=True)
    print('полей %d, мутантов %d, поймано %d, живых 0' % (len(rows), len(rows), len(rows)))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.SubprocessError, yaml.YAMLError) as exc:
        print('WORKFLOW_SWEEP_INFRASTRUCTURE: ' + str(exc), file=sys.stderr)
        sys.exit(2)
