#!/usr/bin/env python3
"""Run the 184/M-0 acceptance commands once and retain unfiltered streams and raw rc."""
import json
import os
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def main():
    scratch = ROOT / '.scratch-m0a'
    scratch.mkdir(exist_ok=True)
    env = dict(os.environ, TMPDIR=str(scratch), PYTHONDONTWRITEBYTECODE='1')
    wrapper = str(HERE / 'red_external_connection_184.sh')
    commands = [['bash', wrapper, *args] for args in
                ([], ['--model'], ['--stabs'], ['--repo', '/home/harness/projects/Complior-back'],
                 ['--repo', '/home/harness/projects/Complior-mob'], ['--m0'],
                 ['--m0', '--model'], ['--m0', '--stabs'])]
    commands += [['python3', str(HERE / 'probe.py'), mode] for mode in ('--model', '--stabs')]
    measurements = []
    for command in commands:
        result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, text=True)
        lines = result.stdout.splitlines()
        cells = [line for line in lines if line.startswith('CELL ')]
        red = [line.split(':', 1)[0].removeprefix('CELL ') for line in cells if ': RED' in line]
        entry = dict(command=command, rc=result.returncode, cells=len(cells), red=red,
                     stdout=result.stdout, stderr=result.stderr)
        measurements.append(entry)
        print(json.dumps({key: entry[key] for key in ('command', 'rc', 'cells', 'red')}, ensure_ascii=False), flush=True)
    (HERE / 'm0_measurements.json').write_text(json.dumps(measurements, ensure_ascii=False, indent=2) + '\n')
    before = json.loads((HERE / 'm0_before.json').read_text())
    for item in before:
        lines = item['stdout'].splitlines()
        cells = [line for line in lines if line.startswith('CELL ')]
        red = [line.split(':', 1)[0].removeprefix('CELL ') for line in cells if ': RED' in line]
        print('BEFORE ' + json.dumps(dict(command=item['command'], rc=item['rc'], cells=len(cells), red=red), ensure_ascii=False))
    # A census may be red before the implementation; its own exit is not a test verdict.
    print('MEASUREMENT_RECORDED; consult each command rc above')


if __name__ == '__main__':
    main()
