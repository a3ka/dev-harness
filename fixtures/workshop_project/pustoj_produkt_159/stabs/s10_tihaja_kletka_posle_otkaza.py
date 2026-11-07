#!/usr/bin/env python3
"""Gate refuses correctly; an own cell runs silently afterwards."""
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        return 2
    result = subprocess.run(['bash', sys.argv[1], sys.argv[2]],
                            capture_output=True, text=True, timeout=60)
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    if result.returncode:
        sum(range(7))  # own cell in memory; no output, no file changes
    return result.returncode


if __name__ == '__main__':
    sys.exit(main())
