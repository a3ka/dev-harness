#!/usr/bin/env bash
# ПРИЧИНА: porcelain непуст
# ОКРУЖЕНИЕ: ORCH_SESSION_START=$WORK/../trace
#
# Честный минимум семьи orch_restart (контракт 072): зелёная ветка —
# чистый toy-мир (HEAD==origin/main, porcelain пуст, HANDOFF этой
# identity, детектор rc 0, нет мусорных worktree, стартовый след в
# прошлом) → rc 0, маркер поставлен. Красная ветка — untracked файл
# в $WORK → rc 1 «porcelain непуст» (gate (б)).
#
# Каркас _toy.sh (комментарий и зона): зеркало семьи 043, красные
# ветки держит батарея perezapusk_sessii; здесь — контрольная зелёная
# + честное предъявление красного повторным прогоном проверяющего.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

[ -n "${BARRIER:-}" ] || { echo "BARRIER not set" >&2; exit 2; }
SUBJ="$BARRIER"
: "${WORK:?WORK must be set by verify_antiplacebo}"
MARKER="$WORK/marker"
# Стартовый след сессии — ВНЕ $WORK: иначе файл попадает в porcelain и
# gate (б) красит «porcelain непуст» ещё на ЗЕЛЁНОМ прогоне.
TRACE="$WORK/../trace"
# TMPDIR=$WORK — снимок детектора пишется в $WORK/dev-harness-leak/<hash>;
# verify_antiplacebo при обслуживании запроса передаёт барьеру TMPDIR=$WORK,
# иначе --check ищет снимок в $TMPDIR_BASE/dev-harness-leak/<hash>, а не там,
# где лежит снимок этой фикстурки. Игнор dev-harness-leak/ обязателен —
# иначе сам каталог снимка красит gate (б).
export TMPDIR="$WORK"
rm -f "$MARKER" "$TRACE"

# Toy-мир.
mkdir -p "$WORK/scripts"
cp "$REPO/scripts/check_no_leak.sh" "$WORK/scripts/"
git -C "$WORK" init -q -b main
git -C "$WORK" config user.name orchestrator
git -C "$WORK" config user.email orchestrator@dev-harness.local
printf 'ignored-leak.txt\nscripts/orch_restart.sh\ndev-harness-leak/\n' > "$WORK/.gitignore"
printf '## ГДЕ МЫ (toy)\n' > "$WORK/HANDOFF.md"
git init -q --bare -b main "$WORK-origin.git"
git -C "$WORK" remote add origin "$WORK-origin.git"
git -C "$WORK" add -A && git -C "$WORK" commit -qm 'toy: init'
git -C "$WORK" push -q origin main

# Стартовый след — в прошлом, детекторный снимок — после.
printf '%s\n' "$(date -Is -d '1 hour ago')" > "$TRACE"
bash "$WORK/scripts/check_no_leak.sh" --snapshot "$WORK" >/dev/null 2>&1

# ЗЕЛЁНАЯ ВЕТКА: чистый toy → rc 0, маркер поставлен.
# BARRIER_ROOT=$WORK — иначе дверь судит реальный репо, а не toy (BASH_SOURCE/.. → ROOT).
cd / && env BARRIER_ROOT="$WORK" ORCH_RESTART_MARKER="$MARKER" ORCH_SESSION_START="$TRACE" \
  bash "$SUBJ" >/dev/null 2>&1
rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: зелёная ветка rc %s, ожидался 0\n' "$rc" >&2; exit 1; }
[ -e "$MARKER" ] || { printf 'ОТКАЗ: маркер не поставлен\n' >&2; exit 1; }
printf '%s: rc 0, маркер поставлен\n' "case_01-green" >&2
rm -f "$MARKER"

# КРАСНАЯ ВЕТКА: untracked в $WORK → rc 1 «porcelain непуст».
# Маркер обязан НЕ стоять (инвариант 3): проверяющий не должен иметь
# возможность «снести зелёное прошлым состоянием».
printf 'untracked\n' > "$WORK/dirty.txt"
cd / && env BARRIER_ROOT="$WORK" ORCH_RESTART_MARKER="$MARKER" ORCH_SESSION_START="$TRACE" \
  bash "$SUBJ" 2>&1 | grep -Fq -- 'porcelain непуст' \
  || { printf 'ОТКАЗ: красная ветка не назвала «porcelain непуст»\n' >&2; exit 1; }
printf '%s: rc 1 «porcelain непуст»\n' "case_01-red" >&2
exit 0