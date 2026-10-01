#!/usr/bin/env bash
# ПРИЧИНА: честный toy-мир (HEAD==origin/main, porcelain пуст, HANDOFF этой
# identity, детектор rc 0, нет мусорных worktree, стартовый след в прошлом)
# → дверь зелёная, маркер поставлен.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

[ -n "${BARRIER:-}" ] || { echo "BARRIER not set" >&2; exit 2; }
SUBJ="$BARRIER"
: "${WORK:?WORK must be set by verify_antiplacebo}"
MARKER="$WORK/marker"
TRACE="$WORK/trace"
rm -f "$MARKER" "$TRACE"

# Toy-мир.
mkdir -p "$WORK/scripts"
cp "$REPO/scripts/check_no_leak.sh" "$WORK/scripts/"
git -C "$WORK" init -q -b main
git -C "$WORK" config user.name orchestrator
git -C "$WORK" config user.email orchestrator@dev-harness.local
printf 'ignored-leak.txt\n' > "$WORK/.gitignore"
printf '## ГДЕ МЫ (toy)\n' > "$WORK/HANDOFF.md"
git init -q --bare -b main "$WORK-origin.git"
git -C "$WORK" remote add origin "$WORK-origin.git"
git -C "$WORK" add -A && git -C "$WORK" commit -qm 'toy: init'
git -C "$WORK" push -q origin main

# Стартовый след — в прошлом, детекторный снимок — после.
printf '%s\n' "$(date -Is -d '1 hour ago')" > "$TRACE"
bash "$WORK/scripts/check_no_leak.sh" --snapshot "$WORK" >/dev/null 2>&1

cd / && env ORCH_RESTART_MARKER="$MARKER" ORCH_SESSION_START="$TRACE" bash "$SUBJ" >/dev/null 2>&1
rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: rc %s\n' "$rc" >&2; exit 1; }
[ -e "$MARKER" ] || { printf 'ОТКАЗ: маркер не поставлен\n' >&2; exit 1; }
printf '%s: rc 0, маркер поставлен\n' "case_01" >&2
exit 0