#!/usr/bin/env bash
# D6 (зелёный вход) — v2 СО строкой «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» (ASCII-дефис U+002D,
# grep -F литерал) в причине: клапан отпирает административное состояние v>1,
# тег done/contracts/001/2 ставится. Санкция остаётся в аннотации тега
# (greppable след, шаг 8 контракта).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d6_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
g "$T" tag -a done/contracts/001/1 -m 'istorija: pervoe prizemlenie'
run_writer "$T" 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: slovo vladeltsa doslovno — povtornoe prizemlenie'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: D6: v2 с РАЗРЕШИЛОМ не поставлен (rc %s):\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
g "$T" rev-parse -q --verify 'refs/tags/done/contracts/001/2' >/dev/null || { printf 'ОТКАЗ: D6: тег done/contracts/001/2 не жив\n' >&2; exit 1; }
annot="$(g "$T" for-each-ref 'refs/tags/done/contracts/001/2' --format='%(contents)')"
printf '%s\n' "$annot" | grep -Fq 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' || { printf 'ОТКАЗ: D6: санкция не осталась в аннотации тега:\n%s\n' "$annot" >&2; exit 1; }
printf 'D6: тег v2 поставлен, санкция в аннотации\n' >&2
exit 0
