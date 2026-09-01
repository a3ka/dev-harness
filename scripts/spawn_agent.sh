#!/usr/bin/env bash
# Барьер спавна (контракт 016, срез 2): ветка wip/<NNN>/<автор> + worktree ВНЕ стерегомого дерева.
#
# Зачем: без явного спавна агент коммитит прямо в HEAD общего дерева, и судья зон судит историю
# задним числом — предмет «выход за зону» ловится ПОСЛЕ ухода в main, откат стоит force-push'а.
# Прецедент 0171f1b: «14 worktree все подписаны reviewer» — общий дефолт user.name размывал
# identity на всех ветках; изоляция worktree должна закрываться явной identity (Н-61/А-25).
#
# КОНТРАКТ ВЫХОДА (stdout, машинно-читаемо, ровно две строки):
#   WORKTREE=<абсолютный путь к worktree>
#   BRANCH=wip/<NNN>/<автор>
# ОРКЕСТРАТОР вставляет WORKTREE в задание субагента ДО спавна (контракт §6.2а); никакого
# другого выхода скрипт не печатает.
#
# ОТКАЗЫ rc 1 (поимённо, документированы в контракте):
#   * живая ветка wip/<NNN>/<автор> уже есть в refs/heads/;
#   * путь worktree оказался ВНУТРИ стерегомого дерева (корень репо);
#   * вызов вне корня репозитория git;
#   * HEAD репо не main.
#
# АТОМАРНОСТЬ. Ветка+worktree одной транзакцией: если worktree add отказывает после создания
# ветки, ветка удаляется. Если git отказывает сразу — никаких побочных эффектов.
#
# IDENTITY. Все git-вызовы идут с явным -c user.name/-c user.email (Н-61/А-25). Канарейка
# И-5 проверяет grep'ом эту строку по всему scripts/.
#
# Коды возврата: 0 — спавн успешен (WORKTREE + BRANCH на stdout), 1 — именованный отказ,
# 2 — нечем проверить (нет git, не репозиторий, не HEAD).

set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat >&2 <<USAGE
использование: spawn_agent.sh --author <имя> [--nnn <номер>] [--root <каталог>]

Аргументы:
  --author ИМЯ     имя автора (user.name), обязательно
  --nnn НОМЕР      номер артефакта (3 цифры). По умолчанию — следующий свободный.
  --root КАТАЛОГ   корень репозитория. По умолчанию — текущий.

Контракт: печатает WORKTREE=<путь> и BRANCH=wip/<NNN>/<автор> на stdout, rc 0.
USAGE
  exit 1
}

author=""
nnn=""
root_arg=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --author) author="${2:?}"; shift 2 ;;
    --nnn)    nnn="${2:?}"; shift 2 ;;
    --root)   root_arg="${2:?}"; shift 2 ;;
    --help|-h) usage ;;
    *)        printf 'spawn_agent: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

[ -n "$author" ] || { printf 'spawn_agent: --author обязателен\n' >&2; usage; }

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Канонический корень. Если не задан — cwd.
if [ -z "$root_arg" ]; then
  ROOT="$(pwd -P 2>/dev/null || pwd)"
else
  ROOT="$(cd "$root_arg" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: %s не каталог\n' "$root_arg" >&2; exit 2; }
fi
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' "$ROOT" >&2; exit 2; }

# HEAD обязан быть main. wip/* ответвляются от main, и если HEAD смотрит мимо — спавн мимо
# границы, контракт это именует.
current_head="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"
if [ "$current_head" != "main" ]; then
  printf 'ОТКАЗ: HEAD не main (текущая ветка: %s) — спавн wip/* только от main\n' "$current_head" >&2
  exit 1
fi
# Все git-вызовы ниже идут с явным `-c user.name/-c user.email` (Н-61/А-25). Канарейка
# И-5 проверяет grep'ом эту строку по всему scripts/.
g() {
  git -C "$ROOT" \
    -c user.name=implementer \
    -c user.email=implementer@dev-harness.local \
    -c commit.gpgsign=false \
    "$@"
}

# Номер артефакта. CLI-вызов next_id — он не экспортирует функцию как библиотеку (только
# parse_artifact_basename); подмножество контракта next_id используется через subprocess.
# Номер артефакта — следующий свободный в refs/heads/wip/*. Локальная нумерация: номера
# spawn_agent не пересекаются с contracts/* и существуют только в пределах дерева, где
# спавнятся. Это выделено из next_id, который выдаёт номера для классов (PLAN, VERDICT, ADR),
# а wip/<NNN> — собственный класс, лежащий вне реестра артефактов.
# ДЕФЕКТ-ПРИЧИНА НУЛЕВОЙ НУМЕРАЦИИ (пост-доне фикс-пакет 016): g() вызывался в строке ~108
# ДО определения (был ниже, в теле транзакции) — bash маскировал неизвестную `g` молча,
# цикл по for-each-ref уходил пустым, max_nnn оставался 0, и каждый следующий спавн
# получал wip/001. Подъём `g()` сюда закрывает этот дефект.
if [ -z "$nnn" ]; then
  max_nnn=0
  while IFS= read -r b; do
    [ -n "$b" ] || continue
    bn="${b#refs/heads/wip/}"
    num="${bn%%/*}"
    case "$num" in
      ''|*[!0-9]*) continue ;;
    esac
    n=$((10#$num))
    [ "$n" -gt "$max_nnn" ] && max_nnn="$n"
  done < <(g for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null)
  nnn=$((max_nnn + 1))
fi
nnn_padded="$(printf '%03d' "$((10#$nnn))")"
branch="wip/${nnn_padded}/${author}"
# Отказ: живая ветка того же имени. wip/<NNN>/<автор> — УНИКАЛЬНЫЙ ключ спавна, повтор
# запрещён (контракт Q2: «общий .git — ref ветки виден без push»).
if git -C "$ROOT" show-ref --verify --quiet "refs/heads/$branch"; then
  printf 'ОТКАЗ: ветка %s уже существует — повторный спавн запрещён\n' "$branch" >&2
  exit 1
fi

# Префикс размещения worktree — ВНЕ стерегомого дерева. Контракт пинует критерий, конкретный
# путь — нет. Префикс по умолчанию — ${TMPDIR:-/tmp}/dev-harness-worktrees/<hash8 корня>;
# тот же hash8, что использует verify_antiplacebo, чтобы скратч разных барьеров не
# пересекался при параллельных прогонах.
canon_root="$ROOT"
hash8="$(printf '%s' "$canon_root" | sha256sum | cut -c1-8)"
wt_base="${TMPDIR:-/tmp}/dev-harness-worktrees/$hash8"
mkdir -p "$wt_base" 2>/dev/null || {
  printf 'NOT_IMPLEMENTED: каталог worktrees не создать: %s\n' "$wt_base" >&2
  exit 2
}

wt_path="$wt_base/wip-${nnn_padded}-${author}"

# Каталог worktree НЕ ДОЛЖЕН лежать ВНУТРИ стерегомого дерева (контракт, когнитивный остаток
# «вход в worktree» — инструкция в задании, omp-принуждения нет). Префикс ${TMPDIR:-/tmp}
# канонически ВНЕ корня — это контракт 014 §Предмет инв. 1; но проверяем явно, потому что
# TMPDIR может быть пустым в окружении.
case "$wt_path" in
  "$canon_root"|"$canon_root"/*)
    printf 'ОТКАЗ: путь worktree %s внутри стерегомого дерева %s\n' "$wt_path" "$canon_root" >&2
    exit 1
    ;;
esac

# Каталог уже занят — другая фикстура/агент занял. Именованный отказ.
if [ -e "$wt_path" ]; then
  printf 'ОТКАЗ: каталог worktree %s уже существует — повторный спавн запрещён\n' "$wt_path" >&2
  exit 1
fi

# АТОМАРНАЯ ТРАНЗАКЦИЯ: ветка + worktree. Если worktree add откажет после создания ветки,
# ветка удаляется (rollback). Если сразу — никаких побочных эффектов. `g` определена выше —
# до нумерации, чтобы for-each-ref видел существующие ветки wip/* и нумерация шла дальше 001.

if ! g branch "$branch" main >/dev/null 2>&1; then
  printf 'ОТКАЗ: git branch %s отказал\n' "$branch" >&2
  exit 1
fi

if ! g worktree add "$wt_path" "$branch" >/dev/null 2>&1; then
  # Rollback: ветка создана, но worktree не привязался. Удаляем.
  g branch -D "$branch" >/dev/null 2>&1 || true
  printf 'ОТКАЗ: git worktree add %s отказал — ветка %s откатнута\n' "$wt_path" "$branch" >&2
  exit 1
fi

# Финальный контрактный вывод: ровно две строки на stdout.
printf 'WORKTREE=%s\n' "$wt_path"
printf 'BRANCH=%s\n' "$branch"
