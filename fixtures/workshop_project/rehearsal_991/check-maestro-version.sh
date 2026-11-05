#!/usr/bin/env bash
set -euo pipefail

version="$(maestro --version)"
if [[ "$version" != '2.11.0' ]]; then
  printf 'MAESTRO_VERSION_MISMATCH: expected 2.11.0, got %s\n' "$version" >&2
  exit 1
fi
