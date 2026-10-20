#!/usr/bin/env bash
# s2_bez_merge.sh — ОБМАННЫЙ СТАБ: одиночный проход БЕЗ merge-коммитов (--no-merges).
# Наблюдаемая ложь: d2_merge — merge-дельта к первому родителю (И-7, контракт 019) не судится.
st113_merge_bez() { printf '%s\n' --no-merges; }
ST113_MERGE=st113_merge_bez
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
