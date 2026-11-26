#!/usr/bin/env python3
"""Run the assigned 231 acceptance commands sequentially and retain raw evidence."""
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
FAMILY = 'fixtures/workshop_project/done_round_compat_231/'
CONTRACT = 'contracts/231-sovmestimost-doski-224.md'
B = ['bash', FAMILY + 'red_done_round_compat_231.sh']
COMMANDS = [(mode, B + ['--' + mode], 0) for mode in ('model', 'stabs', 'sintaksis', 'catalog')]
COMMANDS += [
    ('repo', B + ['--repo', '.'], 1),
    ('regression224', B + ['--regression224'], 0),
    ('context', ['python3', '-B', FAMILY + 'context.py'], 0),
    ('schema', ['bash', 'scripts/validate_std.sh', 'json', 'config/done_forms.schema.json', 'config/done_forms.json'], 0),
    ('precritic', ['bash', 'scripts/pre_critic.sh', CONTRACT], 0),
    ('sdacha', ['bash', 'scripts/check_sdacha.sh', '.', CONTRACT, '--run'], 0),
    ('precision', ['bash', 'scripts/check_precision_gate.sh', '.', CONTRACT], 0),
    ('spec', ['bash', 'scripts/check_spec_ready.sh', '.', CONTRACT], 0),
    ('production224', ['bash', 'fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh', '--repo', '.'], 1),
    ('production201', ['bash', 'fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh', '--repo', '.'], 0),
]


def main():
    logs = ROOT / 'tmp/acceptance231'
    logs.mkdir(parents=True, exist_ok=False)
    scratch = ROOT / 'tmp/scratch-arch231'
    scratch.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, TMPDIR=str(scratch), SDACHA_TIMEOUT_SEK='1200', SDACHA_BUDZHET_SEK='2400',
               VALIDATE_STD_SHELLCHECK='/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck')
    results = []
    for name, command, expected in COMMANDS:
        process = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=2400)
        (logs / (name + '.stdout')).write_bytes(process.stdout)
        (logs / (name + '.stderr')).write_bytes(process.stderr)
        row = {'name': name, 'command': command, 'rc': process.returncode, 'expected': expected}
        results.append(row)
        (logs / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
        print(name, 'RAW_RC', process.returncode, 'EXPECTED', expected, flush=True)
        for line in process.stdout.decode(errors='replace').splitlines():
            if ' RED ' in line or line.startswith(('KLETKI ', 'STABY ', 'REGRESSION224_', 'ДЕКЛАРАЦИИ ')):
                print(line, flush=True)
        if process.returncode != expected:
            print(process.stderr.decode(errors='replace'), flush=True)
    return int(any(row['rc'] != row['expected'] for row in results))


if __name__ == '__main__':
    sys.exit(main())
