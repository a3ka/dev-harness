#!/usr/bin/env bash
# Честный вход режима bash: синтаксис разборчив, маркера находки нет.
set -euo pipefail
main() {
  local instrument="$1"
  printf 'использую инструмент: %s\n' "$instrument"
}
main "${1:-validate_std}"
