#!/usr/bin/env bash
# Б-4: VK==MAX зелён, VK==MAX+1 красен при обоих капах.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: pack-maxbytes: предмет отсутствует\n' >&2; exit 1; }
W="$(_t95_world maxbytes-boundary)" || exit 2
trap '_t95_cleanup "$W"' EXIT
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed
python3 "$HERE/pack_maxbytes_probe.py" "$SUBJ" "$W" boundary
