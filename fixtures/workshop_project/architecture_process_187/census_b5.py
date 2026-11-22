#!/usr/bin/env python3
"""187 census for the merged tree: a bare call prints the actual cell/mutant
census of BOTH families (ARCH_CI ancestor cells and Б-5 brief stderr/signal
cells: names and counters) and rejects empty, duplicated or dangling coverage;
`census_b5.py <stage> [mode...]` records battery modes without stopping on an
expected red door and never masks a red rc."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def census():
    from workflow_probe import CASES, STABS
    from ci_ancestor import CASES as ANCESTOR_CASES, STABS as ANCESTOR_STABS
    import brief_stderr
    import brief_signals

    labels = [case[0] for case in CASES]
    ancestor_labels = [case[0] for case in ANCESTOR_CASES]
    stderr_labels = [case[0] for case in brief_stderr.CASES]
    signal_labels = [case[0] for case in brief_signals.CASES]
    dangling = sorted(
        ({case for case, _ in STABS.values()} - set(labels))
        | ({case for case, _ in brief_stderr.STABS.values()} - set(stderr_labels))
        | ({case for case, _ in brief_signals.STABS.values()} - set(signal_labels)))
    print(json.dumps({
        'CELLS': len(CASES),
        'STABS': len(STABS),
        'ANCESTOR_CELLS': len(ANCESTOR_CASES),
        'ANCESTOR_STABS': len(ANCESTOR_STABS),
        'B5_STDERR_CELLS': len(brief_stderr.CASES),
        'B5_STDERR_STABS': len(brief_stderr.STABS),
        'B5_SIGNAL_CELLS': len(brief_signals.CASES),
        'B5_SIGNAL_STABS': len(brief_signals.STABS),
        'B5_CELLS': len(brief_stderr.CASES) + len(brief_signals.CASES),
        'B5_STABS': len(brief_stderr.STABS) + len(brief_signals.STABS),
        'OLD_CELLS': len(CASES) - len(ANCESTOR_CASES),
        'OLD_STABS': len(STABS) - len(ANCESTOR_STABS),
        'BATTERY_CELLS': (len(CASES) + len(brief_stderr.CASES)
                          + len(brief_signals.CASES) + 1),
        'BATTERY_STABS': (len(STABS) + len(brief_stderr.STABS)
                          + len(brief_signals.STABS)),
        'DANGLING': dangling,
        'ANCESTOR_LABELS': ancestor_labels,
        'B5_LABELS': stderr_labels + signal_labels,
    }, ensure_ascii=False, indent=2))
    families = (labels, ancestor_labels, stderr_labels, signal_labels)
    return int(not all(families) or dangling
               or any(len(names) != len(set(names)) for names in families))


def runner(stage):
    modes = sys.argv[2:] or ['model', 'stabs', 'repo', 'wiring']
    logs = Path(os.environ.get('TMPDIR', tempfile.gettempdir()))
    failed = False
    for mode in modes:
        if mode in ('signals', 'signals-base', 'signals-control'):
            tools = ROOT
            if mode == 'signals-base':
                tools = logs / (stage + '-base')
                (tools / 'scripts').mkdir(parents=True, exist_ok=True)
                source = subprocess.check_output(
                    ['git', '-C', str(ROOT), 'show',
                     'a4f87d04a1:scripts/check_architecture_contract.sh'])
                (tools / 'scripts/check_architecture_contract.sh').write_bytes(source)
            command = [sys.executable, str(HERE / 'brief_signals.py'), '--repo', str(tools)]
            if mode == 'signals-control':
                command.append('--control')
        else:
            command = ['bash', str(HERE / 'red_architecture_process_187.sh'), '--' + mode]
        # Signal modes intentionally accept an isolated library snapshot.
        if mode in ('repo', 'wiring'):
            command.append(str(ROOT))
        result = subprocess.run(command, cwd=ROOT, capture_output=True, timeout=300)
        (logs / f'{stage}-{mode}.stdout').write_bytes(result.stdout)
        (logs / f'{stage}-{mode}.stderr').write_bytes(result.stderr)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        print(f'CENSUS {stage} --{mode} rc={result.returncode}', flush=True)
        failed = failed or result.returncode != 0
    return int(failed)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        raise SystemExit(runner(sys.argv[1]))
    raise SystemExit(census())
