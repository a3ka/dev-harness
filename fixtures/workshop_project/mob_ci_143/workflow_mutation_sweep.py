#!/usr/bin/env python3
"""One independent candidate copy and one named --repo cell per workflow field.

The model is loaded before copying any subject content. Each disposable copy
is destroyed after its single mutation; no subject file is used as the oracle.
"""
import argparse
import copy
from pathlib import Path
import subprocess
import sys
import tempfile

import yaml

from matrix_v3 import model_workflow
from workflow_sweep_v3 import (controls, match, mutate, name_of, root_controls,
                               root_match, root_name, mutate_root)


def main():
    ap = argparse.ArgumentParser()
    group = ap.add_mutually_exclusive_group(required=True)
    group.add_argument('--repo', type=Path)
    group.add_argument('--model', action='store_true')
    ap.add_argument('--verify-dir', type=Path, default=Path('/tmp/dev-harness-verify'))
    args = ap.parse_args()
    model = model_workflow()
    source = (Path(__file__).resolve().parent / 'model') if args.model else args.repo.resolve()
    workflow = model if args.model else yaml.safe_load((source / '.github/workflows/mobile.yml').read_text())
    rows = tuple((row, root_name, root_match, mutate_root)
                 for row in root_controls(model, workflow))
    rows += tuple((row, name_of, match, mutate) for row in controls(model, workflow))
    for row, label, verify, _ in rows:
        if not verify(workflow, model, row):
            print('HONEST_CONTROL_RED: ' + label(row), file=sys.stderr)
            return 2
    print('ПОЛЕ\tКЛЕТКА\tМУТАНТ', flush=True)
    for row, label, verify, alter in rows:
        name = label(row)
        # A fresh *whole* candidate copy, not a fabricated partial workflow.
        with tempfile.TemporaryDirectory(prefix='architect143-wf-', dir=args.verify_dir) as folder:
            target = Path(folder) / 'candidate'
            subprocess.run(['cp', '-a', '--reflink=auto', str(source), str(target)], check=True)
            candidate = alter(copy.deepcopy(workflow), model, row)
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
