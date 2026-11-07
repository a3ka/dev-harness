#!/usr/bin/env python3
"""Stand-in for the four branches: stop immediately on gate refusal."""
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        return 2
    result = subprocess.run(['bash', sys.argv[1], sys.argv[2]],
                            capture_output=True, text=True, timeout=60)
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    return result.returncode


if __name__ == '__main__':
    sys.exit(main())
