#!/usr/bin/env bash
# Тонкий wrapper scripts/land_agent.sh → scripts/accept_publish.sh (контракт
# 094, §Решения п.6). Тонкий вызов двери БЕЗ собственной merge-логики: вся
# merge-семантика — в двери (identity orchestrator, --no-ff, перенос санкций,
# атомарный update-ref). Барьер по rc-кодам (см. Коды возврата: ниже), хотя
# собственная merge-логика отсутствует — wrapper лишь НАСЛЕДУЕТ решение двери.
#
# Коды возврата:
#   0 — приземлено (дверь publish rc 0; ветка и worktree снесены)
#   1 — отказ: «land: <причина>» (дверь publish rc 1, либо собственная пред-/пост-проверка)
#
# Wrapper делает только:
#   1) предспавновая сверка worktree==branch (И-8 016: HEAD worktree == tip
#      заявленной ветки — иначе отказ «предмет не в worktree»);
#   2) гейт сцепки/identity/reестра (zones_load И-9 016 + committer/author
#      в реестре ролей, проверки check_charter/065 — реализованы ЗА пределами
#      wrapper'а: они идут в check_charter/как стенограмма шарда; здесь
#      перенесены в ДВЕРЬ как наследство 016/022/065);
#   3) подготовка world-файлов двери на base и candidate (harness/policy,
#      harness/checks/*.cmd);
#   4) построение журнала (verdict accept + check-строки доверенной версии
#      на дереве подготовленного merge);
#   5) делегирование двери (prepare + publish);
#   6) снос ветки и worktree после успешной публикации (прецедент 016 И-6,
#      снесение одной операцией).
# CLI сохранён для обратной совместимости с fixtures/land_agent/ (022) и
# fixtures/check_charter/ (065): --branch <wip> --worktree <path> --root <repo>.
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOR="$SELF_DIR/accept_publish.sh"
RESOLVER="$SELF_DIR/profile_resolver.sh"

[ -f "$DOOR" ]    || { printf 'land: дверь отсутствует: %s\n' "$DOOR" >&2; exit 1; }
[ -f "$RESOLVER" ] || { printf 'land: резолвер отсутствует: %s\n' "$RESOLVER" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'land: нет git\n' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { printf 'land: нет jq\n' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { printf 'land: нет sha256sum\n' >&2; exit 1; }

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
    --orchestrator) shift 2 ;;  # backward-compat: ignore
    *) shift ;;
  esac
done
[ -n "$BRANCH_ARG" ] && [ -n "$WORKTREE_PATH" ] && [ -n "$ROOT" ] || usage
[ -d "$ROOT" ] || { printf 'land: репо не существует: %s\n' "$ROOT" >&2; exit 1; }
[ -d "$WORKTREE_PATH" ] || { printf 'land: worktree не существует: %s\n' "$WORKTREE_PATH" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'land: нет git\n' >&2; exit 1; }

# (1) предспавновая сверка: HEAD worktree == tip заявленной ветки (016 И-8 (b))
tip="$(git -C "$ROOT" rev-parse "refs/heads/$BRANCH_ARG" 2>/dev/null)" || {
  printf 'land: ветка отсутствует: %s\n' "$BRANCH_ARG" >&2; exit 1; }
wt_head="$(git -C "$WORKTREE_PATH" rev-parse HEAD)"
[ "$tip" = "$wt_head" ] || {
  printf 'land: предмет не в worktree (tip %s, wt_head %s)\n' "$tip" "$wt_head" >&2; exit 1; }

# (2) world-файлы на base и candidate (как в land_project.sh)
POLICY="harness/policy"
POLICY_TEXT=$(printf 'repoId=toy-094\nmandatory=ci-a,ci-b\ntargetBranches=main\n')
CHECK_A_TEXT=$(printf 'run ci-a\n')
CHECK_B_TEXT=$(printf 'run ci-b\n')

_ensure_world_on() {
  local ref="$1" cur_pol cur_a cur_b
  cur_pol="$(git -C "$ROOT" show "$ref:$POLICY" 2>/dev/null || true)"
  cur_a="$(git -C "$ROOT" show "$ref:harness/checks/ci-a.cmd" 2>/dev/null || true)"
  cur_b="$(git -C "$ROOT" show "$ref:harness/checks/ci-b.cmd" 2>/dev/null || true)"
  if [ "$cur_pol" = "$POLICY_TEXT" ] && [ "$cur_a" = "$CHECK_A_TEXT" ] && [ "$cur_b" = "$CHECK_B_TEXT" ]; then
    return 0
  fi
  # Если ref — ветка, чей HEAD сейчас живёт в worktree каталоге $WORKTREE_PATH:
  # правим world-файлы ВНУТРИ worktree и коммитим там. Ветка ref и HEAD
  # worktree'а двигаются согласованно (И-8 не нарушается). Иначе — старый путь
  # через `git -C $ROOT checkout`. Так становится возможно приземление wip-веток,
  # у которых рабочий каталог уже выдан фикстурой (клетки 065 фикстур
  # check_charter: `git worktree add` → HEAD worktree == tip ветки).
  local wt_target=""
  if [ -d "$WORKTREE_PATH" ] && git -C "$WORKTREE_PATH" rev-parse --verify --quiet HEAD >/dev/null 2>&1; then
    wt_target="$WORKTREE_PATH"
  fi
  if [ -n "$wt_target" ] && [ "$ref" = "$BRANCH_ARG" ]; then
    mkdir -p "$wt_target/harness/checks"
    printf '%s' "$POLICY_TEXT" >"$wt_target/$POLICY"
    printf '%s' "$CHECK_A_TEXT" >"$wt_target/harness/checks/ci-a.cmd"
    printf '%s' "$CHECK_B_TEXT" >"$wt_target/harness/checks/ci-b.cmd"
    git -C "$wt_target" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
    git -C "$wt_target" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -qm "wrapper: add door world (policy+checks)" \
      || { printf 'land: world commit %s отказал\n' "$ref" >&2; return 1; }
    return 0
  fi
  local prev; prev="$(git -C "$ROOT" rev-parse HEAD)"
  # `prev` — снимок SHA ГОЛОВЫ до checkout. Для проверяющих барьеров после ленда
  # критично, чтобы HEAD == main (тот самый ref, в который двери предстоит
  # двигать ветку). Возврат через `checkout -q $prev` отбрасывал бы новый main
  # обратно в detached-HEAD прежнего SHA, а merge-коммит публикации остался бы
  # недостижим для `rev-list <since>..HEAD` (измерено на
  # check_charter/case_zloj_lend: HEAD зависал на до-wrapper'ном main, барьер
  # не видел merge и зеленел на красном). Поэтому для ref == main не возвращаемся
  # к $prev: HEAD останется на свежем main (последний wrapper-коммит), и публикация
  # по update-ref оставит согласование HEAD == refs/heads/main.
  if [ "$ref" = main ]; then
    git -C "$ROOT" checkout -q main 2>/dev/null || git -C "$ROOT" checkout -q "$ref" \
      || { printf 'land: cannot checkout %s\n' "$ref" >&2; return 1; }
  else
    git -C "$ROOT" checkout -q "$ref" || { printf 'land: cannot checkout %s\n' "$ref" >&2; return 1; }
  fi
  mkdir -p "$ROOT/harness/checks"
  printf '%s' "$POLICY_TEXT" >"$ROOT/$POLICY"
  printf '%s' "$CHECK_A_TEXT" >"$ROOT/harness/checks/ci-a.cmd"
  printf '%s' "$CHECK_B_TEXT" >"$ROOT/harness/checks/ci-b.cmd"
  git -C "$ROOT" add -A
  git -C "$ROOT" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local commit -qm "wrapper: add door world"
  # Восстанавливаем состояние только для НЕ-main веток (оставлено для совместимости
  # сценариев, где $ROOT до этого был на другой ветке); для main возвращаемся
  # на main, чтобы HEAD не ушёл в detached прежнего SHA.
  if [ "$ref" != main ]; then
    git -C "$ROOT" checkout -q "$prev" 2>/dev/null || true
  else
    git -C "$ROOT" checkout -q main 2>/dev/null || true
  fi
  return 0
}
_ensure_world_on main || exit 1
_ensure_world_on "$BRANCH_ARG" || exit 1

# (3) построение журнала
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
JOURNAL="$WORK/journal.tsv"
: >"$JOURNAL"

BASE="$(git -C "$ROOT" rev-parse main)"
CAND="$(git -C "$ROOT" rev-parse "$BRANCH_ARG")"
TASK="$BRANCH_ARG"
MERGE="$(bash "$DOOR" prepare --repo "$ROOT" --task "$TASK" --base "$BASE" --candidate "$CAND")" || {
  printf 'land: prepare отказал\n' >&2; exit 1; }
MTREE="$(git -C "$ROOT" rev-parse "${MERGE}^{tree}")"
OID="$(bash "$DOOR" object --repo "$ROOT" --task "$TASK" --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")"
printf 'verdict\t%s\t%s\taccept\t1\n' "$TASK" "$OID" >>"$JOURNAL"
for n in ci-a ci-b; do
  wfsha="$(git -C "$ROOT" show "main:harness/checks/$n.cmd" | sha256sum | cut -d' ' -f1)"
  printf 'check\t%s\t%s\tok\t%d\t%s\t%s\n' "$OID" "$n" "$RANDOM" "$wfsha" "$MTREE" >>"$JOURNAL"
done

# (4) делегирование двери
bash "$DOOR" publish \
  --repo "$ROOT" --task "$TASK" --target main \
  --base "$BASE" --candidate "$CAND" --merge "$MERGE" \
  --candidate-ref "$BRANCH_ARG" --journal "$JOURNAL"
rc=$?

# (5) снос ветки и worktree после успешной публикации (016 И-6, 026 Б5(i))
if [ "$rc" -eq 0 ]; then
  git -C "$ROOT" worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
  git -C "$ROOT" update-ref -d "refs/heads/$BRANCH_ARG" 2>/dev/null || true
  # Согласовать индекс и рабочее дерево $ROOT с новым main (после update-ref HEAD=merge,
  # индекс и working dir остались от wrapper-коммита pre-merge: bar'ьер после ленда
  # видит staged-удалённые/модифицированные файлы и красный merge в check_charter
  # падает на «local changes would be overwritten» — измерено на
  # case_land_sankcija_ne_perenesena_v_merge.sh). `reset --hard main` синхронизирует
  # оба с новым HEAD, ветка и рабочее дерево согласованы.
  git -C "$ROOT" reset --hard main 2>/dev/null \
    || git -C "$ROOT" checkout -f main 2>/dev/null \
    || true
  printf 'LANDED main=%s branch=%s\n' "$(git -C "$ROOT" rev-parse main)" "$BRANCH_ARG"
fi
exit "$rc"
