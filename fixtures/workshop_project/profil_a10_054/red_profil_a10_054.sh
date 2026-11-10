#!/usr/bin/env bash
# 054 v+1 (A10): repo layer only at <R>/.harness/harness.project.json — red cells and stubs.
#   bash fixtures/workshop_project/profil_a10_054/red_profil_a10_054.sh [--model|--stabs]
# rc: 0 — all cells/stubs as expected; 1 — named RED/ALIVE; 2 — NOT_IMPLEMENTED prerequisite.
set -u
HERE="$(cd -- "${BASH_SOURCE[0]%/*}" && pwd -P)" || exit 2
if ! command -v python3 >/dev/null 2>&1; then
  printf 'NOT_IMPLEMENTED: python3 unavailable\n' >&2
  exit 2
fi
PYTHONDONTWRITEBYTECODE=1 python3 "$HERE/probe.py" "$@"
exit $?
