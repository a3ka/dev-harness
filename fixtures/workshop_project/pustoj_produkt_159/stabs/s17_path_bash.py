#!/usr/bin/env python3
"""Trust PATH/bash even when its apparent gate has been replaced by exit 99."""
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        return 2
    gate, root = sys.argv[1:]
    completed = subprocess.run(['bash', gate, root], capture_output=True,
                               text=True, timeout=60)
    sys.stdout.write(completed.stdout)
    sys.stderr.write(completed.stderr)
    return completed.returncode


if __name__ == '__main__':
    sys.exit(main())
