#!/usr/bin/env bash
# Единая дверь слияния ветки проекта (контракт 063, ветвь (в)): гейт впереди,
# merge ТОЛЬКО --no-ff с identity оркестратора (канарейка 016 И-5; committer
# сверяется после merge, И-7). Прецедент 016 scripts/land_agent.sh:182.
#
# Аргументы:
#   --repo <корень>   путь к корню репозитория проекта (обязательно);
#   --branch ИМЯ      имя ветки для приземления (обязательно);
#   --orchestrator ИМЯ имя merge-коммита (по умолчанию orchestrator).
#
# Коды возврата:
#   0 — посажено локально (merge-коммит с двумя родителями, subject `land: <ветка>`,
#       committer == orchestrator);
#   1 — именованный отказ (красный гейт / не-clean main / merge конфликт /
#       identity расщеплена);
#   2 — NOT_IMPLEMENTED.
set -uo pipefail

export PATH=/usr/bin:/bin
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$SELF_DIR/check_merge_gate.sh"

usage() {
  printf 'land project ОТКАЗ: usage: bash scripts/land_project.sh --repo <корень> --branch <ветка>\n' >&2
  exit 1
}

REPO=""; BRANCH=""; ORCH="orchestrator"
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)         REPO="${2:?}"; shift 2 ;;
    --branch)       BRANCH="${2:?}"; shift 2 ;;
    --orchestrator) ORCH="${2:?}"; shift 2 ;;
    --help|-h)      usage ;;
    *)              printf 'land project ОТКАЗ: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

[ -n "$REPO" ]   || usage
[ -n "$BRANCH" ] || usage
[ -d "$REPO" ]   || { printf 'land project ОТКАЗ: каталог репо не существует: %s\n' "$REPO" >&2; exit 1; }

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Грязный главный чекаут → rc 1 (И-7). Только tracked-изменения: untracked
# `.review/`-файлы (находки ревьюера) не считаются загрязнением — они
# ловятся гейтом ниже, а их коммитность НЕ обязательна для срабатывания
# гейта (И-3: «незакоммиченность .review/-файла не разблокирует»).
if [ -n "$(git -C "$REPO" status --porcelain --untracked-files=no)" ]; then
  printf 'land project ОТКАЗ: главное дерево загрязнено — приземление отвергнуто\n' >&2
  exit 1
fi

# Ветка должна существовать.
if ! git -C "$REPO" show-ref --verify --quiet "refs/heads/$BRANCH"; then
  printf 'land project ОТКАЗ: ветка %s не существует — приземлять нечего\n' "$BRANCH" >&2
  exit 1
fi

# Гейт впереди (И-7). Красный → rc 1 с прокси stderr гейта; HEAD целевой ветки
# не меняется (merge ещё не выполнен).
GATE_OUT="$(HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-}" \
            bash "$GATE" --repo "$REPO" 2>&1)"
GATE_RC=$?
if [ "$GATE_RC" -ne 0 ]; then
  printf '%s\n' "$GATE_OUT" >&2
  exit 1
fi

# Merge ТОЛЬКО --no-ff, identity оркестратора литералом в ОДНОЙ СТРОКЕ с
# `git merge` (канарейка 016 И-5; ff-слияние невозможно по построению).
# subject `land: <ветка>`. commit.gpgsign=false — иначе CI-окружение без GPG
# ключа красит merge отказом. ВСЕ -c флаги и merge идут в одной команде.
MERGE_CMD=(git -C "$REPO" \
  -c user.name="$ORCH" \
  -c user.email="${ORCH}@dev-harness.local" \
  -c commit.gpgsign=false \
  merge --no-ff -m "land: $BRANCH" "$BRANCH")
if ! "${MERGE_CMD[@]}" >/dev/null 2>&1; then
  printf 'land project ОТКАЗ: merge --no-ff %s отказал — конфликт или иная ошибка git\n' "$BRANCH" >&2
  exit 1
fi

# Сверка committer после merge (И-7). merge_cn == orchestrator.
merge_cn="$(git -C "$REPO" log -1 --format=%cn HEAD)"
if [ "$merge_cn" != "$ORCH" ]; then
  printf 'land project ОТКАЗ: merge-коммит подписан %s, ожидался %s — identity оркестратора не применилась\n' \
    "$merge_cn" "$ORCH" >&2
  exit 1
fi

exit 0
