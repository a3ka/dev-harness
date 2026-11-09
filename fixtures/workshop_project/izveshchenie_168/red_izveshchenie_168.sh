#!/usr/bin/env bash
# Red against the current station; after implementation all three independent proofs are required.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
python3 "$here/probe.py" --repo
python3 "$here/probe.py" --model
python3 "$here/probe.py" --stabs
