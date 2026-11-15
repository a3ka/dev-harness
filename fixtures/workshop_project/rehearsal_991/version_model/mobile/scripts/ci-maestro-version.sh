#!/usr/bin/env bash
# 991 v3 model: version gate script shared by station and cloud lanes.
# Body semantics equal the live inline step delivered by 991 v2 (FP-1 fix):
# mismatch refuses with the named reason, never a silent or soft failure.
set -euo pipefail
actual_version="$(maestro --version 2>/dev/null || true)"
if [ "$actual_version" != '2.11.0' ]; then
  echo "MAESTRO_VERSION_MISMATCH: expected=2.11.0 actual='$actual_version'" >&2
  exit 1
fi
