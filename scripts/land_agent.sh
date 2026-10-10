#!/usr/bin/env bash
# ТОНКАЯ ОБЁРТКА scripts/land_agent.sh → scripts/accept_publish.sh (094 §Решения п.6).
# Wrapper НЕ пишет мир, НЕ пишет журнал, НЕ коммитит — он только вызывает дверь
# (object/prepare/publish) и пробрасывает её код возврата. Вся merge-семантика
# (identity orchestrator, --no-ff, перенос санкций 065 И-10, атомарный update-ref,
# гейт сцепки/identity/реестра 016 И-7/И-9 как наследство) перенесена в ДВЕРЬ
# (контракт 094 ПЕРЕСЕЧЕНИЕ implementer scripts/land_agent.sh).
#
# Коды возврата:
#   0 — приземлено (дверь publish rc 0)
#   1 — отказ: «land: <причина>» (дверь publish rc 1, либо собственная пред-/пост-проверка)
#   2 — NOT_IMPLEMENTED: нет инструмента или предмет отсутствует
#
# CLI сохранён для обратной совместимости с fixtures/land_agent/ (022) и
# fixtures/check_charter/ (065): --branch <wip> --worktree <path> --root <repo>.
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOR="$SELF_DIR/accept_publish.sh"

[ -f "$DOOR" ] || { printf 'land: дверь отсутствует: %s\n' "$DOOR" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'land: нет git\n' >&2; exit 2; }

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

# Предспавновая сверка: HEAD worktree == tip заявленной ветки (016 И-8 (b)) — это
# единственная проверка wrapper'а. Всё остальное (политика, журнал, merge,
# identity/registry/zones) делает дверь. Wrapper НЕ пишет мир и НЕ коммитит.
tip="$(git -C "$ROOT" rev-parse "refs/heads/$BRANCH_ARG" 2>/dev/null)" || {
  printf 'land: ветка отсутствует: %s\n' "$BRANCH_ARG" >&2; exit 1; }
wt_head="$(git -C "$WORKTREE_PATH" rev-parse HEAD 2>/dev/null)" || {
  printf 'land: worktree HEAD не читается\n' >&2; exit 1; }
[ "$tip" = "$wt_head" ] || {
  printf 'land: предмет не в worktree (tip %s, wt_head %s)\n' "$tip" "$wt_head" >&2; exit 1; }

# Делегирование двери. wrapper НЕ пишет политику (И-6: политика только из base),
# НЕ пишет журнал (И-1/И-4: verdict/check — дело судей и CI-обвязки), НЕ делает
# merge (Решение 6: всё — в двери). Дверь читает harness/policy из base и при
# отсутствии/неконформности отказывает ИМЕНОВАННО; журнал дверь НЕ читает без
# --journal (--journal ОБЯЗАН быть пустой, иначе wrapper подделывал бы доказательства).
BASE="$(git -C "$ROOT" rev-parse main)"
CAND="$(git -C "$ROOT" rev-parse "$BRANCH_ARG")"
TASK="$BRANCH_ARG"

# Подготовленный merge (без движения refs) — дверь prepare
MERGE="$(bash "$DOOR" prepare --repo "$ROOT" --task "$TASK" --base "$BASE" --candidate "$CAND")" || {
  printf 'land: prepare отказал\n' >&2; exit 1; }

# Делегирование publish с пустым --journal (без строк verdict/check) — дверь
# честно откажет на И-1 «нет применимого accept для задачи», и merge не состоится.
# Это и есть контрактная защита от Б-1: дверь САМА судит доказательства, wrapper
# их не фабрикует.
EMPTY_J="$(mktemp)"
trap 'rm -f "$EMPTY_J"' EXIT
bash "$DOOR" publish \
  --repo "$ROOT" --task "$TASK" --target main \
  --base "$BASE" --candidate "$CAND" --merge "$MERGE" \
  --candidate-ref "$BRANCH_ARG" --journal "$EMPTY_J"
rc=$?

if [ "$rc" -eq 0 ]; then
  printf 'LANDED main=%s branch=%s\n' "$(git -C "$ROOT" rev-parse main)" "$BRANCH_ARG"
  # Снос worktree после успешной публикации (016 И-6 — прецедент одной операцией).
  git -C "$ROOT" worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
fi
exit "$rc"