#!/usr/bin/env bash
# Loaded by the real 041 runner in an isolated copy, never installed globally.
_owner228_cell() {
  bash "${OWNER_228_ROOT:?}/fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh" --model --cell "$1"
}
battery_delimiter_collision() { _owner228_cell bad-space; }
battery_regex_injection() { _owner228_cell regex-path; }
battery_silent_drop() { _owner228_cell bad-tail; }
battery_self_application_green() { _owner228_cell migration-matrix; }
