#!/usr/bin/env bash
set -euo pipefail
bash mobile/scripts/ci-maestro-version.sh
bash .harness/fixtures/workshop_project/vkhod_117/battery.sh
