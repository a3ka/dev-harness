#!/usr/bin/env bash
# Live probes for fixr5impl (per arbiter verdict 071 §П2/П3/П4)
#
# Прогоны в собственной песочнице: красный main, свой bare, журнал — rc/строка.
# ВАЖНО: c19, c21, c36, c40 (pre-remote формы: значение ДО remote) по
# вердикту арбитра — ПРЕДЕЛ 071 (exec канарейки 045 раньше крюка, крюк не
# вызывается). FAIL-критерием они НЕ являются; фиксируем фактический rc.
#
# Все остальные — внутри предмета, должны быть отказы/успех по §2 контракта.
set -uo pipefail

SCRATCH=/tmp/dev-harness-verify/impl071r5/probes
rm -rf "$SCRATCH"
mkdir -p "$SCRATCH"
GW=/tmp/dev-harness-verify/impl071r5/repo/scripts/gitw
PF=/tmp/dev-harness-verify/impl071r5/repo/scripts/gitw_preflight_071.sh

# Bare (B1): каноническая цель
B1="$SCRATCH/b1"
git init -q --bare "$B1"
CANON="$B1"

# Сторонний "зелёный" клон (Tgreen) для c23
TG="$SCRATCH/tgreen"
git init -q -b main "$TG"
cd "$TG"
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q --allow-empty -m green-base

# Сторонний "красный" клон (Tred) — основной мир проб
T="$SCRATCH/tred"
git init -q -b main "$T"
cd "$T"
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q --allow-empty -m red-base
# копируем ВСЕ теги репо: замороженность черновиков доказывается тегами
while IFS= read -r r; do
  git tag "${r#refs/tags/}" "$(git rev-parse HEAD)" 2>/dev/null || true
done < <(git -C /tmp/dev-harness-verify/impl071r5/repo for-each-ref --format='%(refname)' refs/tags)
git remote add origin "$B1"
git push -q origin main --tags

# Сделать main красным: добавим жирный roles/orchestrator.md (ceilings красный)
cd "$T"
python3 -c "print('x'*60000)" > roles/orchestrator.md
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false add roles/orchestrator.md
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q -m 'fat role'
git push -q origin main

# Создать отдельную ветку wip/071/x для проб с веткой ≠ main
git checkout -q -b wip/071/x

# Bare c push-options: receive.advertisePushOptions=true
BPO="$SCRATCH/bpo"
git init -q --bare "$BPO"
git -C "$BPO" config receive.advertisePushOptions true
# заполним его main
cd "$T"
git checkout -q main
git push -q "$BPO" main
git checkout -q wip/071/x
git push -q "$BPO" wip/071/x
git remote add pusher "$BPO"

# Помощники
push_red() {
  local label="$1"; shift
  local env="GIT_EXCHANGE_GUARD_CANONICAL=$CANON"
  local extra=()
  # для c19/c21/c36/c40 явно НЕ ставим GITW_PREFLIGHT_071_API — exec 045 раньше
  # для c34/c39/bpo: API не нужен (push-options)
  local stdout_file="$SCRATCH/${label}.out"
  local stderr_file="$SCRATCH/${label}.err"
  (
    cd "$T"
    env $env "$@" bash "$GW" push origin main >"$stdout_file" 2>"$stderr_file"
  )
  echo "rc=$?: $(tail -n 1 "$stderr_file" 2>/dev/null || echo "(no stderr)")"
}

probe() {
  local label="$1"; shift
  echo "=== $label ==="
  local out err rc
  out="$SCRATCH/${label}.out"
  err="$SCRATCH/${label}.err"
  ( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" "$@" bash "$GW" push "$@" ) >"$out" 2>"$err"
  rc=$?
  echo "rc=$rc"
  echo "stderr-tail: $(tail -n 2 "$err" 2>/dev/null | tr '\n' '|')"
  echo "stdout-tail: $(tail -n 1 "$out" 2>/dev/null | tr '\n' '|')"
  local b1now; b1now=$(git -C "$B1" rev-parse refs/heads/main 2>/dev/null || echo "NONE")
  echo "bare-main: $b1now"
  echo ""
}

# c27: push origin '*' (cwd = корень, glob совпадает) — должен быть отказ
echo ">>> c27 push origin '*'"
( cd "$T" && touch 'refs/heads/zzz' 2>/dev/null || true
  # CWD содержит файл refs/heads/zzz → glob '*' совпадает
  env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" push origin '*' ) >"$SCRATCH/c27.out" 2>"$SCRATCH/c27.err"
echo "c27 rc=$? stderr: $(tail -n 1 "$SCRATCH/c27.err")"
echo ""

# c34: push origin -o --repo main (push-options + значение ПОСЛЕ remote)
echo ">>> c34 push origin -o --repo main (pusher-bare)"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$BPO" bash "$GW" push pusher -o --repo main ) >"$SCRATCH/c34.out" 2>"$SCRATCH/c34.err"
echo "c34 rc=$? stderr: $(tail -n 1 "$SCRATCH/c34.err")"
echo ""

# c44: push origin +main
echo ">>> c44 push origin +main"
( cd "$T" && git checkout -q main
  env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" push origin +main ) >"$SCRATCH/c44.out" 2>"$SCRATCH/c44.err"
echo "c44 rc=$? stderr: $(tail -n 1 "$SCRATCH/c44.err")"
echo ""

# c47: push origin @
echo ">>> c47 push origin @"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" push origin @ ) >"$SCRATCH/c47.out" 2>"$SCRATCH/c47.err"
echo "c47 rc=$? stderr: $(tail -n 1 "$SCRATCH/c47.err")"
echo ""

# c39: push origin -o x (push-options, pusher-bare)
echo ">>> c39 push origin -o x (pusher-bare)"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$BPO" bash "$GW" push pusher -o x ) >"$SCRATCH/c39.out" 2>"$SCRATCH/c39.err"
echo "c39 rc=$? stderr: $(tail -n 1 "$SCRATCH/c39.err")"
echo ""

# c24: -c push.default=matching push origin
echo ">>> c24 -c push.default=matching push origin (wip)"
( cd "$T" && git checkout -q wip/071/x
  env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" -c push.default=matching push origin ) >"$SCRATCH/c24.out" 2>"$SCRATCH/c24.err"
echo "c24 rc=$? stderr: $(tail -n 1 "$SCRATCH/c24.err")"
echo ""

# c25: -c remote.origin.push=refs/heads/main:refs/heads/main push origin (wip)
echo ">>> c25 -c remote.origin.push=refs/heads/main:refs/heads/main push origin (wip)"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" -c remote.origin.push=refs/heads/main:refs/heads/main push origin ) >"$SCRATCH/c25.out" 2>"$SCRATCH/c25.err"
echo "c25 rc=$? stderr: $(tail -n 1 "$SCRATCH/c25.err")"
echo ""

# c26: remote.origin.push в конфиге репо + push origin (wip)
echo ">>> c26 remote.origin.push в конфиге репо, push origin (wip)"
( cd "$T" && git config remote.origin.push refs/heads/main:refs/heads/main
  env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" push origin ) >"$SCRATCH/c26.out" 2>"$SCRATCH/c26.err"
git config --unset remote.origin.push
echo "c26 rc=$? stderr: $(tail -n 1 "$SCRATCH/c26.err")"
echo ""

# c23: cwd = чужой зелёный клон, -C <T> push origin
echo ">>> c23 cwd = чужой зелёный клон, -C <T> push origin (red-T)"
( cd "$TG" && env GIT_EXCHANGE_GUARD_CANONICAL="$T" bash "$GW" -C "$T" push origin ) >"$SCRATCH/c23.out" 2>"$SCRATCH/c23.err"
echo "c23 rc=$? stderr: $(tail -n 1 "$SCRATCH/c23.err")"
echo ""

# === ПРЕДЕЛ 071: pre-remote формы (exec 045 раньше крюка) ===
# c19: push --receive-pack git-receive-pack origin
echo ">>> c19 push --receive-pack git-receive-pack origin (ПРЕДЕЛ 071)"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" push --receive-pack git-receive-pack origin ) >"$SCRATCH/c19.out" 2>"$SCRATCH/c19.err"
echo "c19 rc=$? stderr: $(tail -n 1 "$SCRATCH/c19.err")"
echo ""

# c21: push origin --receive-pack git-receive-pack (значение ПОСЛЕ — это нормальная форма для 071)
echo ">>> c21 push origin --receive-pack git-receive-pack (ПРЕДЕЛ 071?)"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" push origin --receive-pack git-receive-pack ) >"$SCRATCH/c21.out" 2>"$SCRATCH/c21.err"
echo "c21 rc=$? stderr: $(tail -n 1 "$SCRATCH/c21.err")"
echo ""

# c36: push -o --repo origin main (значение ДО remote)
echo ">>> c36 push -o --repo origin main (ПРЕДЕЛ 071)"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$CANON" bash "$GW" push -o --repo origin main ) >"$SCRATCH/c36.out" 2>"$SCRATCH/c36.err"
echo "c36 rc=$? stderr: $(tail -n 1 "$SCRATCH/c36.err")"
echo ""

# c40: push -o x origin (значение ДО remote)
echo ">>> c40 push -o x origin (ПРЕДЕЛ 071)"
( cd "$T" && env GIT_EXCHANGE_GUARD_CANONICAL="$BPO" bash "$GW" push -o x pusher ) >"$SCRATCH/c40.out" 2>"$SCRATCH/c40.err"
echo "c40 rc=$? stderr: $(tail -n 1 "$SCRATCH/c40.err")"
echo ""

echo "=== итог ==="
echo "B1 main: $(git -C "$B1" rev-parse refs/heads/main 2>/dev/null || echo NONE)"
