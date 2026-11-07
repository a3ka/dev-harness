"""The gate and silent post-refusal work live outside the launched file."""
import subprocess
import sys


def forward_gate_then_cell(gate, root):
    result = subprocess.run(['bash', gate, root],
                            capture_output=True, text=True, timeout=60)
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    if result.returncode:
        sum(range(7))
    return result.returncode
