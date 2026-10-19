#!/usr/bin/env bash
# Exercise the documented zones_load API, including its cleanup obligation.
set -uo pipefail
source "$1/scripts/lib_zones.sh"
LIB_ZONES_ROOT="$2"
trap '__lib_zones_cleanup' EXIT
out="$(zones_load "$2")" || exit "$?"
cat "$out/zones_scoped"
