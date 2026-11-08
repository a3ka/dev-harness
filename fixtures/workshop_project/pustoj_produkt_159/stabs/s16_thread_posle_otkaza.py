#!/usr/bin/env python3
"""Spawn before the gate; the quiet cell runs only after a real refusal."""
import os
import subprocess
import sys
import threading
import time


def main():
    if len(sys.argv) != 3:
        return 2
    gate, root = sys.argv[1:]
    marker = os.environ.get('PUSTOJ_MUT_MARKER')
    trace = os.environ.get('PUSTOJ_PRODUKT_TRACE')
    if not marker or not trace:
        return subprocess.call(['/usr/bin/bash', gate, root])

    refused = threading.Event()

    def quiet_cell():
        for _ in range(500):
            if os.path.isfile(trace):
                if not refused.wait(timeout=6):
                    return
                with open(marker, 'a', encoding='utf-8') as out:
                    out.write('thread cell after gate refusal\n')
                return
            time.sleep(0.01)

    worker = threading.Thread(target=quiet_cell)
    worker.start()
    result = subprocess.run(['/usr/bin/bash', gate, root],
                            capture_output=True, text=True, timeout=60)
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    if result.returncode != 0:
        refused.set()
    worker.join(timeout=6)
    return result.returncode


if __name__ == '__main__':
    sys.exit(main())
