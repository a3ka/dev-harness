#!/usr/bin/env bash
# G (D-семья) — полное честное дерево: accept + зелёная ПРОВОДКА + v1 + причина
# → тег done/contracts/001/1 ставится, РЕЕСТР НЕ ТРОНУТ (шаг 8: done-писатель
# реестр не пишет; byte-сверка снимком ДО вызова, правило 8 — оракул в памяти).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/dg_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
mkdir -p "$T/registry"
printf '777 → sentinel-stroka-reestra\n' > "$T/registry/contracts.tsv"
commit_all "$T" 'reestr-sentinel'
SNAP="$(cat "$T/registry/contracts.tsv")"   # снято в память ДО вызова

run_writer "$T" 'chestrnoe prizemlenie'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: DG: честное дерево не принято (rc %s):\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
g "$T" rev-parse -q --verify 'refs/tags/done/contracts/001/1' >/dev/null || { printf 'ОТКАЗ: DG: тег done/contracts/001/1 не жив\n' >&2; exit 1; }
[ "$(cat "$T/registry/contracts.tsv")" = "$SNAP" ] || { printf 'ОТКАЗ: DG: реестр тронут писателем (diff не пуст)\n' >&2; exit 1; }
printf 'DG: тег поставлен, реестр байт-в-байт нетронут\n' >&2
exit 0
