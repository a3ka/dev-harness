#!/usr/bin/env python3
"""Forward gate refusal, then run a silent module-level cell."""
import subprocess
import sys

result = subprocess.run(['bash', sys.argv[1], sys.argv[2]],
                        capture_output=True, text=True, timeout=60)
sys.stdout.write(result.stdout)
sys.stderr.write(result.stderr)
if result.returncode:
    sum(range(7))
sys.exit(result.returncode)
