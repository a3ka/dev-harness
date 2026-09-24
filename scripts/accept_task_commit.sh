#!/usr/bin/env bash
# Барьер приёмника патча task-субагента (контракт 037, §Инварианты М2):
# fetch HEAD локального --source в object store --root, литеральная сверка
# identity (%an/%ae) КАЖДОГО коммита диапазона wip-branch..FETCH_HEAD с
# объявленным --author, cherry-pick диапазона на <--branch> через одноразовый
# временный worktree с явной identity. --root'ов собственный чекаут НЕ
# переключается и НЕ модифицируется (И-7/И-8 land_agent.sh, перенесённые
# сюда).
#
# КОНТРАКТ CLI:
#   scripts/accept_task_commit.sh --source <путь> --branch wip/<NNN>/<автор>
#     --author <имя> [--root <корень>]
#
# ГРАММАТИКА СТРУКТУРНЫХ ПОЛЕЙ (041 §Инварианты п.2):
#   --author <имя>          ^[A-Za-z0-9_-]+$   (^...$, обе границы заякорены)
#   --branch <ветка>        ^wip/[0-9]+/[A-Za-z0-9_-]+$  (^...$)
#   commit sha              ^[0-9a-f]{40}$    (^...$)
#   --source <путь>, --root <путь>  ЛОКАЛЬНЫЕ пути (НЕ ssh://, НЕ https://,
#                          НЕ git://), подаются только через `git -C <путь>`
#                          (argv-элемент, без шелл-интерполяции),
#                          валидируются как git-репозитории.
#
# ТРИ РАЗДЕЛЬНЫХ переменных НА ВСЁМ пути: $SOURCE_DIR, $BRANCH, $AUTHOR —
# НИКОГДА не склеиваются в одну строку разделителем с последующим split
# (байт `/` легален ВНУТРИ --branch; 038/guard-ere-metacharacters круг 13).
#
# IDENTITY COMPARISON: ЛИТЕРАЛЬНОЕ bash-равенство `[ = ]`,
# НИКОГДА grep -E/glob, построенный из untrusted %an/%ae.
#
# Коды возврата:
#   0 — принято (stdout: ACCEPTED branch=<branch> tip=<sha>)
#   1 — именованный отказ (ветка не существует / нечего принимать / identity
#       расхождение / мерж-коммит в диапазоне — не поддерживается / cherry-pick
#       конфликт; --branch НЕ изменяется)
#   2 — нечем проверить (нет git / --source не репозиторий / --root не
#       репозиторий / --source/--root не локальный каталог)
#
# ДИАПАЗОН КАК МАССИВ: RANGE_SHAS — bash-массив (НЕ многострочная строка),
# cherry-pick "${RANGE_SHAS[@]}" разворачивает каждый sha в ОТДЕЛЬНЫЙ argv —
# фикс argv-бага RANGE_SHAS против замороженного М2 п.5.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

usage() {
  cat >&2 <<USAGE
использование: accept_task_commit.sh --source ПУТЬ --branch wip/NNN/автор --author имя [--root КАТАЛОГ]
USAGE
  exit 1
}

# ТРИ РАЗДЕЛЬНЫХ argv-переменных от старта до самого финала — никогда
# не склеиваются в одну строку разделителем с последующим split.
SOURCE_ARG=""
BRANCH_ARG=""
AUTHOR_ARG=""
ROOT_ARG=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --source)  SOURCE_ARG="${2:?}"; shift 2 ;;
    --branch)  BRANCH_ARG="${2:?}"; shift 2 ;;
    --author)  AUTHOR_ARG="${2:?}"; shift 2 ;;
    --root)    ROOT_ARG="${2:?}"; shift 2 ;;
    --help|-h) usage ;;
    *) printf 'accept_task_commit: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

[ -n "$SOURCE_ARG" ] || { printf 'accept_task_commit: --source обязателен\n' >&2; usage; }
[ -n "$BRANCH_ARG" ] || { printf 'accept_task_commit: --branch обязателен\n' >&2; usage; }
[ -n "$AUTHOR_ARG" ] || { printf 'accept_task_commit: --author обязателен\n' >&2; usage; }

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Замкнутый положительный алфавит, точечный якорь ^…$ на ОБЕ границы
# (НЕ префикс-матч). grep -Eqx — POSIX ERE с -x (целая строка), точечный
# якорь по границам строки.
# --author: ^[A-Za-z0-9_-]+$
if ! printf '%s\n' "$AUTHOR_ARG" | grep -Eqx '[A-Za-z0-9_-]+'; then
  printf 'ОТКАЗ: --author не соответствует грамматике [A-Za-z0-9_-]+: %s\n' "$AUTHOR_ARG" >&2
  exit 1
fi

# --branch: ^wip/[0-9]+/[A-Za-z0-9_-]+$ — обе границы заякорены.
if ! printf '%s\n' "$BRANCH_ARG" | grep -Eqx 'wip/[0-9]+/[A-Za-z0-9_-]+'; then
  printf 'ОТКАЗ: --branch не соответствует грамматике wip/NNN/автор: %s\n' "$BRANCH_ARG" >&2
  exit 1
fi

# --source и --root — ЛОКАЛЬНЫЕ файловые пути, не git-transport URI.
# Запрет схем: ssh://, https://, git://, file:// (последний — git транспорт-
# синтаксис; мы требуем локальный каталог без схемы).
for patharg in "source:$SOURCE_ARG" "root:$ROOT_ARG"; do
  label="${patharg%%:*}"
  val="${patharg#*:}"
  case "$val" in
    [a-zA-Z][a-zA-Z0-9+.-]*://*)
      printf 'ОТКАЗ: --%s не локальный путь (URI-схема): %s\n' "$label" "$val" >&2
      exit 2 ;;
  esac
done

# ROOT — канонизированный; --root обязателен быть git-репозиторием.
if [ -z "$ROOT_ARG" ]; then
  ROOT="$(pwd -P 2>/dev/null || pwd)"
else
  ROOT="$(cd "$ROOT_ARG" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: --root не каталог: %s\n' "$ROOT_ARG" >&2; exit 2; }
fi
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: --root не репозиторий git: %s\n' "$ROOT" >&2; exit 2; }

# SOURCE — канонизированный локальный путь; обязателен быть git-репозиторием.
SOURCE_DIR="$(cd "$SOURCE_ARG" 2>/dev/null && pwd -P 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: --source не каталог: %s\n' "$SOURCE_ARG" >&2; exit 2; }
git -C "$SOURCE_DIR" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: --source не репозиторий git: %s\n' "$SOURCE_ARG" >&2; exit 2; }

# Ветка wip/<NNN>/<автор> ОБЯЗАНА существовать как refs/heads/<branch> в --root.
if ! git -C "$ROOT" show-ref --verify --quiet "refs/heads/$BRANCH_ARG"; then
  printf 'ОТКАЗ: ветка %s не существует — спавни через spawn_agent.sh\n' "$BRANCH_ARG" >&2
  exit 1
fi

# Запоминаем tip ДО любых операций — для атомарного отказа (сравнение
# ветки до/после; update-ref откажет если кто-то сдвинул ветку под нами).
TIP_BEFORE="$(git -C "$ROOT" rev-parse "refs/heads/$BRANCH_ARG")"

# Шаг 2: fetch HEAD --source в object store --root. Не переключает HEAD
# --root и не трогает refs/heads/* (только refs/remotes/<remote>/<ref>).
# <repository> — путь или URL (git-fetch(1)); локальный путь принимается
# БЕЗ схемы, file:// НЕ используем (запрещён выше).
if ! git -C "$ROOT" fetch --no-tags "$SOURCE_DIR" HEAD 2>/dev/null; then
  printf 'ОТКАЗ: git fetch --root из --source отказал\n' >&2
  exit 2
fi

FETCH_HEAD_SHA="$(git -C "$ROOT" rev-parse FETCH_HEAD)"
if ! printf '%s\n' "$FETCH_HEAD_SHA" | grep -Eqx '[0-9a-f]{40}'; then
  printf 'ОТКАЗ: FETCH_HEAD не валидный sha: %s\n' "$FETCH_HEAD_SHA" >&2
  exit 2
fi

# Шаг 3: диапазон <--branch>..FETCH_HEAD. Собираем в МАССИВ (не в одну
# многострочную строку) — argv-баг RANGE_SHAS против замороженного М2 п.5
# (cherry-pick "$RANGE_SHAS" получал ОДИН argv с embedded newline вместо
# отдельных аргументов на коммит; честный линейный диапазон из НЕСКОЛЬКИХ
# коммитов не мог быть cherry-pick-нут одним вызовом; живая проба блокера
# M2 вердикта адверсария). Контракт 037 §Инварианты М2 п.5 «cherry-pick
# диапазона на <--branch>» — каждый sha ОТДЕЛЬНЫМ argv.
RANGE_SHAS=()
while IFS= read -r sha; do
  [ -n "$sha" ] || continue
  RANGE_SHAS+=("$sha")
done < <(git -C "$ROOT" rev-list "$BRANCH_ARG..$FETCH_HEAD_SHA" 2>/dev/null || true)
if [ "${#RANGE_SHAS[@]}" -eq 0 ]; then
  printf 'ОТКАЗ: нечего принимать — диапазон %s..%s пуст\n' "$BRANCH_ARG" "$FETCH_HEAD_SHA" >&2
  exit 1
fi

# Шаг 4: ЛИТЕРАЛЬНАЯ сверка %an/%ae КАЖДОГО коммита диапазона с --author.
# Две ОТДЕЛЬНЫЕ переменные (НЕ склеенные в одну строку разделителем).
EXPECTED_AN="$AUTHOR_ARG"
EXPECTED_AE="${AUTHOR_ARG}@dev-harness.local"

for sha in "${RANGE_SHAS[@]}"; do
  if ! printf '%s\n' "$sha" | grep -Eqx '[0-9a-f]{40}'; then
    printf 'ОТКАЗ: диапазон вернул не-sha: %s\n' "$sha" >&2
    exit 1
  fi
  actual_an="$(git -C "$ROOT" log -1 --format='%an' "$sha")"
  actual_ae="$(git -C "$ROOT" log -1 --format='%ae' "$sha")"
  # ЛИТЕРАЛЬНОЕ bash-равенство строк (НЕ grep -E/glob из untrusted %an/%ae):
  # 038/guard-ere-metacharacters круг 13 — именно здесь был пробит тот же
  # класс. `[ = ]` интерпретирует обе стороны буквально, ERE-метасимволы в
  # %an/%ae (git ничем их не ограничивает) не меняют результат сравнения.
  if [ "$actual_an" != "$EXPECTED_AN" ] || [ "$actual_ae" != "$EXPECTED_AE" ]; then
    printf 'ОТКАЗ: identity расхождение sha=%s actual_an=%s actual_ae=%s ожидалось an=%s ae=%s\n' \
      "$sha" "$actual_an" "$actual_ae" "$EXPECTED_AN" "$EXPECTED_AE" >&2
    exit 1
  fi
  # Шаг 4а (v2 — блокер M2 вердикта адверсария): мерж-политика — %P с
  # более одним родителем → ИМЕНОВАННЫЙ отказ rc1 «мерж-коммит в диапазоне —
  # не поддерживается» с называнием sha первого мержа; --branch не меняется.
  # ТЕМ ЖЕ проходом по диапазону, что п.4 (выше). %P — пробело-разделённые
  # parent sha; один свн. пэрент = нет пробела; два+ свн. = пробел =
  # мерж-коммит. Контракт 037 §Инварианты М2 4а.
  parents="$(git -C "$ROOT" log -1 --format='%P' "$sha")"
  case "$parents" in
    *' '*)
      printf 'ОТКАЗ: мерж-коммит в диапазоне — не поддерживается sha=%s\n' "$sha" >&2
      exit 1 ;;
  esac
done

# Шаг 5: cherry-pick через одноразовый временный worktree. --root'ов
# чекаут НЕ переключается; временный worktree полностью изолирует
# операцию от состояния --root'с рабочего дерева (включая грязное —
# СОВЕТ критика contracts-037-v1.md:62, явный выбор архитектуры).
WT_PARENT="$(mktemp -d "${TMPDIR:-/tmp}/accept_task_commit.XXXXXX")"
WT_PATH="$WT_PARENT/wt"
# --detach: временный worktree стартует detached от <--branch> (исходный
# tip). После успешного cherry-pick обновляем refs/heads/<--branch> в
# --root атомарно через update-ref (с предыдущим значением).
if ! git -C "$ROOT" worktree add --detach "$WT_PATH" "$BRANCH_ARG" >/dev/null 2>&1; then
  rm -rf "$WT_PARENT"
  printf 'ОТКАЗ: создание временного worktree отказало\n' >&2
  exit 2
fi
trap 'git -C "$ROOT" worktree remove --force "$WT_PATH" 2>/dev/null || true; rm -rf "$WT_PARENT"' EXIT

# Cherry-pick с явной identity — committer == author == ожидаемая роль.
# -c user.name=... -c user.email=... на ОДНОМ вызове (аналогично
# MERGE_ARGS в land_agent.sh). commit.gpgsign=false — без подписи.
if ! git -C "$WT_PATH" \
     -c user.name="$EXPECTED_AN" \
     -c user.email="$EXPECTED_AE" \
     -c commit.gpgsign=false \
     cherry-pick "${RANGE_SHAS[@]}" >/dev/null 2>&1; then
  # Чистим worktree и tmpdir через trap. --branch НЕ изменён (мы работали
  # в отдельном worktree; refs/heads/<--branch> в --root нетронут).
  printf 'ОТКАЗ: cherry-pick отказал (конфликт или иная ошибка)\n' >&2
  exit 1
fi

NEW_TIP="$(git -C "$WT_PATH" rev-parse HEAD)"
if ! printf '%s\n' "$NEW_TIP" | grep -Eqx '[0-9a-f]{40}'; then
  printf 'ОТКАЗ: new tip не валидный sha: %s\n' "$NEW_TIP" >&2
  exit 2
fi

# Атомарное обновление refs/heads/<--branch> в --root на новый tip —
# через update-ref с ПРЕДЫДУЩИМ значением (защита от гонки: если ветка
# сдвинулась под нами между чтением TIP_BEFORE и этой строкой,
# update-ref откажет, не перезапишет чужой коммит).
if ! git -C "$ROOT" update-ref "refs/heads/$BRANCH_ARG" "$NEW_TIP" "$TIP_BEFORE"; then
  printf 'ОТКАЗ: update-ref %s отказал (ветка сдвинулась под нами)\n' "$BRANCH_ARG" >&2
  exit 1
fi

# Удаляем временный worktree ДО финального stdout (trap тоже отработает).
git -C "$ROOT" worktree remove --force "$WT_PATH" 2>/dev/null || true
rm -rf "$WT_PARENT"
trap - EXIT

printf 'ACCEPTED branch=%s tip=%s\n' "$BRANCH_ARG" "$NEW_TIP"
exit 0
