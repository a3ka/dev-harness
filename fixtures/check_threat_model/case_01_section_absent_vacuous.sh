#!/usr/bin/env bash
# Р1 (green/vacuous) — секции «## Модель угроз» нет вовсе → rc 0, вне
# применимости барьера (присутствие — cognitive-only критика, roles/critic.md).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

W="$(mktemp -d "${TMPDIR:-/tmp}/tm_case01.XXXXXX")"; trap 'rm -rf "$W"' EXIT
F="$W/c.md"
put_contract "$F" '# kontrakt

## Predmet
p bez sekcii modeli ugroz'
run_barrier "$W" 'c.md'
accept 'case_01'
printf '%s\n' "$LAST_OUT" | grep -Fq 'секция отсутствует' || { printf 'ОТКАЗ: case_01: нет фразы «секция отсутствует»:\n%s\n' "$LAST_OUT" >&2; exit 1; }
exit 0
