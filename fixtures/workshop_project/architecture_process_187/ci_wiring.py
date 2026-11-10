#!/usr/bin/env python3
"""Pre-freeze CI carrier gate: both 187 commands must be independently scheduled."""
from pathlib import Path
import sys

BATTERY = 'bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .'
DIRECT = 'bash scripts/check_architecture_contract.sh --repo . contracts/187-arhitektura-v-processe.md'


def check(root):
    carrier = root / 'registry/ci-steps.tsv'
    if not carrier.is_file():
        return 'CI_BATTERY_187_MISSING'
    commands = []
    for row in carrier.read_text().splitlines():
        fields = row.split('\t', 3)
        if len(fields) == 4 and fields[0] == 'step':
            commands.append(fields[3])
    if BATTERY not in commands:
        return 'CI_BATTERY_187_MISSING_OR_NOT_EXACT'
    if DIRECT not in commands:
        return 'CI_DIRECT_ARCH_187_MISSING'
    return ''


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('usage: ci_wiring.py ROOT', file=sys.stderr)
        raise SystemExit(2)
    failure = check(Path(sys.argv[1]).resolve())
    if failure:
        print(failure, file=sys.stderr)
    raise SystemExit(bool(failure))
