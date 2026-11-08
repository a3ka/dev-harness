#!/usr/bin/env bash
# Без флага: живой субъект, честная модель и обманные стабы; первый отказ сохраняет rc.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(cd "$here/../../.." && pwd -P)"
mode=all
case "${1:-}" in
  --repo|--model|--stabs) mode="$1"; shift ;;
  --*) printf 'ОТКАЗ: неизвестный режим: %s\n' "$1" >&2; exit 2 ;;
esac
if [ "$#" -gt 1 ]; then
  printf 'ОТКАЗ: ожидается не более одного корня репозитория\n' >&2
  exit 2
fi
root="${1:-$root}"
probe="$root/fixtures/workshop_project/model_choice_166/probe.py"
if [ "$mode" = all ] || [ "$mode" = --repo ]; then
  python3 "$probe" --repo "$root" || exit $?
fi
if [ "$mode" = all ] || [ "$mode" = --model ]; then
  python3 "$probe" --model || exit $?
fi
if [ "$mode" = all ] || [ "$mode" = --stabs ]; then
  python3 "$probe" --stabs
fi
