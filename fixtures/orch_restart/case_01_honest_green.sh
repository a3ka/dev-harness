#!/usr/bin/env bash
# ПРИЧИНА: porcelain непуст
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# ОКРУЖЕНИЕ: ORCH_RESTART_MARKER=$WORK/marker
# ОКРУЖЕНИЕ: ORCH_SESSION_START=$WORK/../trace
# ОКРУЖЕНИЕ: TMPDIR=/tmp
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
#
# BARRIER_ROOT=$WORK — seam verify_antiplacebo (ap_run): копирует scripts/orch_restart.sh
# в $WORK/scripts/orch_restart.sh перед вызовом; BASH_SOURCE/.. двери → $WORK,
# дверь судит toy-мир, не основной чекаут. Без BARRIER_ROOT ap_run не копирует —
# дверь судит РЕАЛЬНЫЙ репо (BASH_SOURCE → $REPO), и gate (г) красит ложным
# «мутировал во время сверки» от правок сессии.
#
# TMPDIR=/tmp — снапшот детектора живёт ВНЕ $WORK (/tmp/dev-harness-leak/<hash>),
# и mktemp внутри check_no_leak.sh (producer-ноги TRACKED/UNTRACKED) тоже пишет
# В /tmp; иначе TMPDIR=$WORK → tmp.XXX создаются в $WORK как untracked, повторное
# чтение манифеста ловит их как новые строки → gate (г) красит ложным
# «повторное чтение разошлось с первым». Архитекторская батарея
# fixtures/perezapusk_sessii/red_dver_perezapuska_072.sh использует TMPDIR по
# умолчанию (/tmp) — здесь тот же канон.
#
# orch_restart.sh ПРЕ-КОПИРУЕТСЯ в $WORK/scripts/ до снимка: иначе ap_run
# добавляет файл В $WORK/scripts/ уже после снимка, UNTRACKED-нога детектора
# (ls-files --others, МИМО ignore) видит его как новую строку → delta против
# снимка непуста → gate (г) красный. Пре-копия = тот же байт, что копирует
# ap_run, sha256/sha1 в манифесте идентичен снимку.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

[ -n "${BARRIER:-}" ] || { echo "BARRIER not set" >&2; exit 2; }
: "${WORK:?WORK must be set by verify_antiplacebo}"
MARKER="$WORK/marker"
# Стартовый след сессии — ВНЕ $WORK: иначе файл попадает в porcelain и
# gate (б) красит «porcelain непуст» ещё на ЗЕЛЁНОМ прогоне.
TRACE="$WORK/../trace"
export TMPDIR="/tmp"
rm -f "$MARKER" "$TRACE"

# Toy-мир: чистый репозиторий с main + origin (bare), HANDOFF.md закоммичен,
# автор orchestrator. .gitignore скрывает orch_restart.sh и marker для
# `git status --porcelain` (gate (б)): UNTRACKED-нога детектора их ВИДИТ
# (ls-files --others без --exclude-standard), но это ожидаемо — снапшот их
# тоже содержит (см. пре-копию ниже).
mkdir -p "$WORK/scripts"
cp "$REPO/scripts/check_no_leak.sh" "$WORK/scripts/"
git -C "$WORK" init -q -b main
git -C "$WORK" config user.name orchestrator
git -C "$WORK" config user.email orchestrator@dev-harness.local
printf 'scripts/orch_restart.sh\nmarker\n' > "$WORK/.gitignore"
printf '## ГДЕ МЫ (toy)\n' > "$WORK/HANDOFF.md"
git init -q --bare -b main "$WORK-origin.git"
git -C "$WORK" remote add origin "$WORK-origin.git"
git -C "$WORK" add -A && git -C "$WORK" commit -qm 'toy: init'
git -C "$WORK" push -q origin main
git -C "$WORK" fetch origin main 2>/dev/null
git -C "$WORK" branch -u origin/main main 2>/dev/null

# Пре-копия orch_restart.sh: чтобы ap_run (BARRIER) не появлялся В $WORK/scripts/
# МЕЖДУ снимком и gate (г) двери. После пре-копии — снапшок включает этот файл;
# ap_run поверх него копирует тот же байт (cp перезаписывает, hash стабилен).
cp "$REPO/scripts/orch_restart.sh" "$WORK/scripts/orch_restart.sh"

# Стартовый след — в прошлом, детекторный снимок — после.
printf '%s\n' "$(date -Is -d '1 hour ago')" > "$TRACE"
bash "$WORK/scripts/check_no_leak.sh" --snapshot "$WORK" >/dev/null 2>&1

# ЗЕЛЁНАЯ ВЕТКА: чистый toy → rc 0, маркер поставлен.
# BARRIER_ROOT=$WORK → ap_run копирует скрипт в $WORK/scripts/, BASH_SOURCE/.. → $WORK.
# env var BARRIER_ROOT передаётся обёртке $BARRIER (она же `$wrap`) — verify_antiplacebo
# unsets BARRIER_ROOT до старта фикстуры, поэтому выставляем inline у обёртки.
BARRIER_ROOT="$WORK" ORCH_RESTART_MARKER="$MARKER" ORCH_SESSION_START="$TRACE" "$BARRIER" >/dev/null 2>&1
rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: зелёная ветка rc %s, ожидался 0\n' "$rc" >&2; exit 1; }
[ -e "$MARKER" ] || { printf 'ОТКАЗ: маркер не поставлен\n' >&2; exit 1; }
printf '%s: rc 0, маркер поставлен\n' "case_01-green" >&2

# КРАСНАЯ ВЕТКА: untracked в $WORK → rc 1 «porcelain непуст» (gate (б)).
# Маркер обязан НЕ стоять (инвариант 3): проверяющий не должен иметь
# возможность «снести зелёное прошлым состоянием».
rm -f "$MARKER"
printf 'untracked\n' > "$WORK/dirty.txt"
BARRIER_ROOT="$WORK" ORCH_RESTART_MARKER="$MARKER" ORCH_SESSION_START="$TRACE" "$BARRIER" 2>&1 | grep -Fq -- 'porcelain непуст' \
  || { printf 'ОТКАЗ: красная ветка не назвала «porcelain непуст»\n' >&2; exit 1; }
[ ! -e "$MARKER" ] || { printf 'ОТКАЗ: маркер поставлен при отказе (инвариант 3)\n' >&2; exit 1; }
echo "case_01-red: rc 1 «porcelain непуст»" >&2
exit 0