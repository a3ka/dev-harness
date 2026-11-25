#!/usr/bin/env bash
# 203 v2: public entrypoint; no network, all writable worlds under TMPDIR.
# Modes follow the neighbouring families: --repo <root> judges the live tree
# (red by cells until the implementation lands), --model judges the etalon
# overlay, --stabs runs every addressed mutation, --sintaksis runs bash -n
# over the etalon carriers.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
mode="${1:---model}"
case "$mode" in
  --repo|--model|--stabs|--sintaksis) ;;
  *) printf 'NOT_IMPLEMENTED: mode %s\n' "$mode" >&2; exit 2 ;;
esac
export PYTHONDONTWRITEBYTECODE=1
case "$mode" in
  --repo)
    [ "$#" -eq 2 ] || { printf 'usage: %s --repo <root>\n' "$0" >&2; exit 2; }
    exec python3 "$here/probe.py" --repo "$2"
    ;;
  *)
    [ "$#" -eq 1 ] || { printf 'usage: %s %s\n' "$0" "$mode" >&2; exit 2; }
    exec python3 "$here/probe.py" "$mode"
    ;;
esac
