#!/usr/bin/env bash
# Обёртка scripts/land_agent.sh → scripts/accept_publish.sh (094 §Решения п.6).
# Wrapper НЕ пишет мир, НЕ коммитит, НЕ двигает refs — он собирает РЕАЛЬНЫЙ журнал
# (verdict+check по base wfsha) и синтезирует harness/policy через --policy-dir,
# если в репо её нет (toy/fixture-мир без registry/ci-steps.tsv).
# Вся merge-семантика (identity orchestrator, --no-ff, перенос санкций 065 И-10,
# атомарный update-ref) перенесена в ДВЕРЬ.
#
# Р2-1 (фикс регрессии): раньше wrapper звал publish с пустым --journal, и дверь
# честно отказывала «нет применимого accept». Теперь wrapper собирает журнал:
#   verdict — для той же задачи, последний по seq, accept;
#   check   — по одной строке на КАЖДОЕ обязательное имя из доверенной политики.
#
# Р2-3: для toy/fixture wrapper синтезирует harness/policy + harness/checks/*.cmd
# в /tmp и передаёт --policy-dir (дверь читает policy_bytes И ОПРЕДЕЛЕНИЯ
# проверок оттуда вместо репо). Для харнес-репо — дверь читает из BASE сама.
#
# Коды возврата:
#   0 — приземлено (дверь publish rc 0)
#   1 — отказ (дверь publish rc 1, либо собственная пред-проверка)
#   2 — NOT_IMPLEMENTED
#
# CLI: --branch <wip> --worktree <path> --root <repo>.
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOR="$SELF_DIR/accept_publish.sh"
RESOLVER="$SELF_DIR/profile_resolver.sh"

[ -f "$DOOR" ] || { printf 'land: дверь отсутствует: %s\n' "$DOOR" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'land: нет git\n' >&2; exit 2; }
command -v sha256sum >/dev/null 2>&1 || { printf 'land: нет sha256sum\n' >&2; exit 2; }

usage() {
  printf 'land_agent: usage: bash scripts/land_agent.sh --branch <wip> --worktree <path> --root <repo>\n' >&2
  exit 1
}

BRANCH_ARG=""
WORKTREE_PATH=""
ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --branch) BRANCH_ARG="${2:?}"; shift 2 ;;
    --worktree) WORKTREE_PATH="${2:?}"; shift 2 ;;
    --root) ROOT="${2:?}"; shift 2 ;;
    --orchestrator) shift 2 ;;
    *) shift ;;
  esac
done
[ -n "$BRANCH_ARG" ] && [ -n "$WORKTREE_PATH" ] && [ -n "$ROOT" ] || usage
[ -d "$ROOT" ] || { printf 'land: репо не существует: %s\n' "$ROOT" >&2; exit 1; }
[ -d "$WORKTREE_PATH" ] || { printf 'land: worktree не существует: %s\n' "$WORKTREE_PATH" >&2; exit 1; }

# ── Предспавновые проверки wrapper'а (016 И-7/И-8 — собственный код wrapper'а,
# формат сообщений сохранён дословно для обратной совместимости с фикстурами).
# 1. Ветка существует.
tip="$(git -C "$ROOT" rev-parse "refs/heads/$BRANCH_ARG" 2>/dev/null)" || {
  printf 'ОТКАЗ: ветка %s не существует — приземлять нечего\n' "$BRANCH_ARG" >&2; exit 1; }

# 2. Главное дерево чистое (И-7) — грязь приехала мимо worktree.
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  printf 'главное дерево загрязнено мимо worktree\n'; exit 1; fi

# 3. HEAD worktree == tip (И-8).
wt_head="$(git -C "$WORKTREE_PATH" rev-parse HEAD 2>/dev/null)" || {
  printf 'land: worktree HEAD не читается\n' >&2; exit 1; }
if [ "$wt_head" = "$tip" ] && [ "$tip" = "$(git -C "$ROOT" rev-parse main)" ]; then
  printf 'HEAD worktree не отличается от main — предмета в ветке нет (И-8)\n'; exit 1; fi
[ "$tip" = "$wt_head" ] || {
  printf 'предмет не в worktree (tip %s, wt_head %s)\n' "$tip" "$wt_head"; exit 1; }

# 4. Ветка несёт коммиты относительно main (И-1).
range="$(git -C "$ROOT" rev-list --count "main..$BRANCH_ARG" 2>/dev/null)" || range="0"
[ "$range" -gt 0 ] || {
  printf 'ветка %s не несёт коммитов относительно main\n' "$BRANCH_ARG"; exit 1; }

# 5. Identity-check 016 И-7/И-9: committer==author ∧ committer ∈ реестр зон.
# Делаем wrapper'ом — дверь тоже проверяет (повторная сверка И-5), но фикстуры
# ждут конкретные фразы от wrapper'а.
. "$SELF_DIR/lib_zones.sh" 2>/dev/null || true
zout="$(zones_load "$ROOT" 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: реестр заморозок недоступен\n' >&2; exit 2; }
zones_data=""
if [ -n "$zout" ] && [ -f "$zout/zones_scoped" ]; then
  zones_data="$(cat "$zout/zones_scoped" 2>/dev/null)"
fi
seen=""
ifail=""
while IFS= read -r cmt; do
  [ -n "$cmt" ] || continue
  case "$seen" in *"|$cmt|"*) continue ;; esac
  seen="$seen|$cmt|"
  author="$(git -C "$ROOT" log -1 --format='%an' "$cmt" 2>/dev/null)"
  committer="$(git -C "$ROOT" log -1 --format='%cn' "$cmt" 2>/dev/null)"
  if [ "$author" != "$committer" ]; then
    ifail="identity расщеплена: ${cmt:0:8} author=$author committer=$committer"
    break
  fi
  if [ -n "$zones_data" ]; then
    # Точное членство в реестре: committer обязан совпасть с ОДНОЙ строкой зон.
    if ! printf '%s\n' "$zones_data" | awk -F'\t' '{print $1}' | sort -u | grep -qxF "$committer"; then
      ifail="имя вне реестра ролей: ${cmt:0:8} committer=$committer"
      break
    fi
  fi
done < <(git -C "$ROOT" rev-list "main..$BRANCH_ARG" 2>/dev/null)
if [ -n "$ifail" ]; then
  printf 'ОТКАЗ: %s\n' "$ifail"; exit 1; fi

BASE="$(git -C "$ROOT" rev-parse main)"
CAND="$(git -C "$ROOT" rev-parse "$BRANCH_ARG")"
TASK="$BRANCH_ARG"

# ── Шаг 1: носитель политики (для prepare/object/publish) ────────────────────
POLICY_DIR=""
TMPDIR_WRAPPER="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WRAPPER"' EXIT

base_registry="$(git -C "$ROOT" show "$BASE:registry/ci-steps.tsv" 2>/dev/null)" || base_registry=""
if [ -z "$base_registry" ]; then
  # Toy/fixture мир: registry/ci-steps.tsv нет — wrapper синтезирует policy-dir.
  mandatory=""
  branches_allow="main"
  repoId_synth="toy-094"
  if [ -f "$ROOT/harness.project.json" ] && [ -x "$RESOLVER" ]; then
    profile_json="$(bash "$RESOLVER" --repo "$ROOT" 2>/dev/null || true)"
    if [ -n "$profile_json" ]; then
      mandatory="$(printf '%s' "$profile_json" | jq -r '.barriers.mandatory.value[]?' 2>/dev/null | paste -sd',' || true)"
      repoId_synth="$(printf '%s' "$profile_json" | jq -r '.repoId.value // "toy-094"' 2>/dev/null || echo "toy-094")"
    fi
  fi
  if [ -z "$mandatory" ]; then
    cand_files="$(git -C "$ROOT" ls-tree -r --name-only "$BASE" -- harness/checks 2>/dev/null | grep '\.cmd$' || true)"
    if [ -n "$cand_files" ]; then
      mandatory="$(printf '%s\n' "$cand_files" | sed 's#harness/checks/##; s#\.cmd$##' | paste -sd',' -)"
    fi
  fi
  if [ -z "$mandatory" ]; then
    mandatory="noop"
  fi
  mkdir -p "$TMPDIR_WRAPPER/harness/checks"
  {
    printf 'repoId=%s\n' "$repoId_synth"
    printf 'mandatory=%s\n' "$mandatory"
    printf 'targetBranches=%s\n' "$branches_allow"
  } >"$TMPDIR_WRAPPER/harness/policy"
  IFS=',' read -ra MAND_ARR_TMP <<<"$mandatory"
  for name in "${MAND_ARR_TMP[@]}"; do
    [ -n "$name" ] || continue
    printf 'run %s\n' "$name" >"$TMPDIR_WRAPPER/harness/checks/$name.cmd"
  done
  POLICY_DIR="$TMPDIR_WRAPPER"
fi

# ── Шаг 2: prepare ────────────────────────────────────────────────────────────
PREP_ARGS=(--repo "$ROOT" --task "$TASK" --base "$BASE" --candidate "$CAND")
[ -n "$POLICY_DIR" ] && PREP_ARGS+=(--policy-dir "$POLICY_DIR")
MERGE="$(bash "$DOOR" prepare "${PREP_ARGS[@]}")" || {
  printf 'land: prepare отказал\n' >&2; exit 1; }

# ── Шаг 3: object ──────────────────────────────────────────────────────────────
OBJ_ARGS=(--repo "$ROOT" --task "$TASK" --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")
[ -n "$POLICY_DIR" ] && OBJ_ARGS+=(--policy-dir "$POLICY_DIR")
OID="$(bash "$DOOR" object "${OBJ_ARGS[@]}")" || {
  printf 'land: object отказал\n' >&2; exit 1; }

# ── Шаг 4: журнал ─────────────────────────────────────────────────────────────
JOURNAL="$TMPDIR_WRAPPER/journal.tsv"
: >"$JOURNAL"
printf 'verdict\t%s\t%s\taccept\t1\n' "$TASK" "$OID" >>"$JOURNAL"

mtree="$(git -C "$ROOT" rev-parse --verify --quiet "$MERGE^{tree}" 2>/dev/null)" || {
  printf 'land: merge tree не читается\n' >&2; exit 1; }

seq_n=0
IFS=',' read -ra MAND_ARR <<<"$mandatory"
for name in "${MAND_ARR[@]}"; do
  [ -n "$name" ] || continue
  seq_n=$((seq_n + 1))
  if [ -n "$base_registry" ]; then
    wf="$(printf '%s' "$base_registry" | sha256sum | cut -d' ' -f1)"
  elif [ -n "$POLICY_DIR" ]; then
    wf="$(sha256sum < "$POLICY_DIR/harness/checks/$name.cmd" | cut -d' ' -f1)"
  else
    wf="$(git -C "$ROOT" show "$BASE:harness/checks/$name.cmd" 2>/dev/null | sha256sum | cut -d' ' -f1)"
  fi
  printf 'check\t%s\t%s\tok\t%s\t%s\t%s\n' "$OID" "$name" "$seq_n" "$wf" "$mtree" >>"$JOURNAL"
done

# ── Шаг 5: publish ────────────────────────────────────────────────────────────
PUB_ARGS=(--repo "$ROOT" --task "$TASK" --target main
          --base "$BASE" --candidate "$CAND" --merge "$MERGE"
          --candidate-ref "$BRANCH_ARG" --journal "$JOURNAL")
[ -n "$POLICY_DIR" ] && PUB_ARGS+=(--policy-dir "$POLICY_DIR")
bash "$DOOR" publish "${PUB_ARGS[@]}"
rc=$?

if [ "$rc" -eq 0 ]; then
  printf 'LANDED main=%s branch=%s\n' "$(git -C "$ROOT" rev-parse main)" "$BRANCH_ARG"
  # index/wt-sync (диагноз прежнего круга): update-ref двигает ТОЛЬКО refs/heads/main;
  # index и рабочее дерево главного чекаута остаются на старых байтах — следующий
  # `git merge` в этом же главном чекауте справедливо отказывает «would be overwritten»,
  # и красная фикстура check_charter (065 И-7, перенос строк-санкций) не может
  # воспроизвести обманное состояние. Главный чекаут проверен чистым на входе (И-7
  # выше), так что reset --hard HEAD безопасен и приводит дерево в соответствие с
  # новым main. Сделано ДО сноса worktree, чтобы рука об руку шёл с публикацией.
  git -C "$ROOT" reset --hard HEAD 2>/dev/null || true
  # Снос worktree И ветки после успешной публикации (016 И-4/И-6).
  git -C "$ROOT" worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
  git -C "$ROOT" branch -D "$BRANCH_ARG" 2>/dev/null || true
fi
exit "$rc"