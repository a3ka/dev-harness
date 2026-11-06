#!/usr/bin/env bash
# Probe-only entrypoint: red until the real materializer exists, green after implementation.
set -u
ROOT="$(cd "$(dirname "$0")/../../.." && pwd -P)"
python3 "$ROOT/fixtures/workshop_project/verdict_materializer_165/probe.py" --repo "$ROOT"
