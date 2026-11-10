#!/usr/bin/env bash
# Run the subject, honest control, and deceptive variants from any cwd.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

rc=0
python3 "$here/red_predverie_172.py" --repo || rc=1
python3 "$here/red_predverie_172.py" --model || rc=1
python3 "$here/red_predverie_172.py" --stabs || rc=1
exit "$rc"
