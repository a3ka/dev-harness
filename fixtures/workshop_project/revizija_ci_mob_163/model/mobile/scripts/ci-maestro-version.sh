#!/usr/bin/env bash
set -euo pipefail
actual_version="$(maestro --version 2>/dev/null || true)"
if [ "$actual_version" != '2.11.0' ]; then
  echo "MAESTRO_VERSION_MISMATCH: expected=2.11.0 actual='$actual_version'" >&2
  exit 1
fi
