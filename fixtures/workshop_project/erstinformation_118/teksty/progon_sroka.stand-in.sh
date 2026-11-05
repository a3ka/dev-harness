#!/usr/bin/env bash
# Product carrier: mobile/e2e-erstinformation/batareja/progon_sroka.sh
# One invocation creates a fresh Jest report and checks it before returning.
set -euo pipefail
repo=$(realpath "${1:?product root required}")
harness=$(realpath "${2:?harness root required}")
cd "$repo/mobile"
rm -f e2e-erstinformation/jest-otchet.json
npm test -- --json --outputFile=e2e-erstinformation/jest-otchet.json
python3 e2e-erstinformation/batareja/proverka_proiskhozdenija.py \
  --pack "$repo/mobile/e2e-erstinformation" --repo "$repo" \
  --harness "$harness" --jest-otchet e2e-erstinformation/jest-otchet.json
