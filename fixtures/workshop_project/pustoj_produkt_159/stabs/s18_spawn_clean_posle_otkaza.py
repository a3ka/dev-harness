#!/usr/bin/env python3
"""Spawn a child with no inherited observer before the gate; run a cell after refusal."""
import os
import subprocess
import sys


CHILD = '''import os, sys, time
marker, parent = sys.argv[1], int(sys.argv[2])
for _ in range(600):
    if os.getppid() != parent:
        with open(marker, 'a', encoding='utf-8') as out:
            out.write('spawn cell after gate refusal\\n')
        break
    time.sleep(0.01)
'''


def main():
    if len(sys.argv) != 3:
        return 2
    gate, root = sys.argv[1:]
    marker = os.environ.get('PUSTOJ_MUT_MARKER')
    if not marker:
        return subprocess.call(['/usr/bin/bash', gate, root])
    os.posix_spawn(sys.executable,
                   [sys.executable, '-E', '-S', '-c', CHILD, marker,
                    str(os.getpid())], {})
    return subprocess.call(['/usr/bin/bash', gate, root])


if __name__ == '__main__':
    sys.exit(main())
