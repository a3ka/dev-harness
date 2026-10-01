#!/usr/bin/env bash
# ПРИЧИНА: честный toy-мир (HEAD==origin/main, porcelain пуст, HANDOFF этой
# identity, детектор rc 0, нет мусорных worktree, стартовый след в прошлом)
# → дверь зелёная, маркер поставлен.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/orchr_case01.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

mk_toy_repo "$WORK"

# HANDOFF уже закоммичен orchestrator'ом (mk_toy_repo). Стартовый след —
# в прошлом относительно коммита.
trace_file="$WORK/trace"
printf '%s\n' "$(date -Is -d '1 hour ago')" > "$trace_file"
# Детекторный снимок ПОСЛЕ всего (никакого мусора ПОСЛЕ снимка).
bash "$WORK/scripts/check_no_leak.sh" --snapshot "$WORK" >/dev/null 2>&1

run_subject "$WORK"
marker="${ORCH_RESTART_MARKER:-/tmp/dev-harness-verify/orch-restart}"
[ -e "$marker" ] || { printf 'ОТКАЗ: маркер не поставлен при rc 0\n' >&2; exit 1; }
accept 'case_01 (честный вход — маркер поставлен)'
exit 0