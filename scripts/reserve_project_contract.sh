#!/usr/bin/env bash
# scripts/reserve_project_contract.sh — резервирование следующего номера
# контракта для ВНЕШНЕГО проекта (контракт 996, пакет B).
#
#   bash scripts/reserve_project_contract.sh --repo R
#
# Что делает:
#   1. Зовёт scripts/project_workflow.sh --repo R, чтобы убедиться, что
#      проект валиден (есть workflowPaths — иначе отказ rc 2).
#   2. Синхронизирует origin (git fetch — тихий best-effort; недостижимость
#      origin rc 1 «origin недоступен»).
#   3. Зовёт scripts/next_id.sh <R> CONTRACT — выдаёт NNN тем же единым
#      механизмом, что и для харнеса (атомарная резервация тегом id/CONTRACT/<NNN>
#      локально).
#   4. Публикует аннотированный тег id/CONTRACT/<NNN> non-force на origin
#      ПРОЕКТА (через gitw, чтобы канонический remote соблюдался).
#   5. Сверяет tag-object-sha локального тега с sha, который ls-remote
#      возвращает на origin. Гонка/расхождение → rc 1, stdout пуст,
#      конкурент неизменен.
#
# stdout (при успехе) — ОДНА строка: NNN (ровно три цифры, как и у next_id).
# rc 0 — успех; rc 1 — отказ с именованной причиной на stderr; rc 2 —
# NOT_IMPLEMENTED.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git"
command -v jq >/dev/null 2>&1  || skip "нет jq"

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --) shift; break ;;
    *) REPO="$1"; shift ;;
  esac
done
[ -n "$REPO" ] || die "usage: bash scripts/reserve_project_contract.sh --repo <R>"
[ -d "$REPO" ] || die "каталог репо не существует: $REPO"
REPO="$(cd "$REPO" && pwd -P)"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 \
  || skip "$REPO не репозиторий git"

# 1. Профиль валиден (project_workflow — единственный печатник путей).
[ -x "$HERE/project_workflow.sh" ] || die "нет project_workflow.sh"
_pw_err="$(mktemp 2>/dev/null || echo /dev/null)"
if ! _pw_out="$(bash "$HERE/project_workflow.sh" --repo "$REPO" 2>"$_pw_err")"; then
  _pw_reason="$(cat "$_pw_err" 2>/dev/null || true)"
  rm -f "$_pw_err"
  die "${_pw_reason#ОТКАЗ: }"
fi
rm -f "$_pw_err"

# 2. Канонический origin из профиля (для обмена через gitw).
[ -x "$HERE/profile_resolver.sh" ] || die "нет profile_resolver.sh"
_pr_err="$(mktemp 2>/dev/null || echo /dev/null)"
if ! _pr_out="$(HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$REPO}" \
              bash "$HERE/profile_resolver.sh" --repo "$REPO" 2>"$_pr_err")"; then
  _pr_reason="$(cat "$_pr_err" 2>/dev/null || true)"
  rm -f "$_pr_err"
  die "профиль: ${_pr_reason#profile ОТКАЗ: }"
fi
rm -f "$_pr_err"
CANON="$(printf '%s' "$_pr_out" | jq -r '.git.value.canonicalRemote // empty')"
[ -n "$CANON" ] || die "профиль без git.canonicalRemote"

# 3. Синхронизация origin (best-effort; недоступность — rc 1 «origin недоступен»).
origin_url="$(git -C "$REPO" remote get-url origin 2>/dev/null || true)"
[ -n "$origin_url" ] || die "origin не настроен в репо проекта"
# Fetch через gitw, чтобы канон был согласован; если origin=канон → проходит,
# иначе — отказ (canonicalRemote не обязан совпадать с реальным URL; тут
# достаточно fetch).
gitw_out="$(bash "$HERE/gitw" -C "$REPO" fetch origin 2>&1)" || {
  # origin отсутствует или не каноничен; в случае канона (тестовая среда) —
  # fetch завершится успешно. Если на origin = тот же канон — fetch пройдёт
  # через gitw (canonicalRemote == origin url); иначе — rc 1.
  case "$gitw_out" in
    *'авторитет недоступен'*|*'не канонический'*)\
      die "origin недоступен или не канонический: $gitw_out" ;;
    *) die "fetch origin: $gitw_out" ;;
  esac
}

# 4. Выдача номера: тот же next_id.sh (единый механизм, атомарная локальная
# резервация). Контракт 996 К3 «резервируется reserve_project_contract на
# origin проекта, вердикт своей роли — под workflowPaths.verdicts».
[ -x "$HERE/next_id.sh" ] || die "нет next_id.sh"
_nn_err="$(mktemp 2>/dev/null || echo /dev/null)"
if ! _nn_out="$(bash "$HERE/next_id.sh" "$REPO" CONTRACT 2>"$_nn_err")"; then
  _nn_reason="$(cat "$_nn_err" 2>/dev/null || true)"
  rm -f "$_nn_err"
  die "next_id: ${_nn_reason#ОТКАЗ: }"
fi
rm -f "$_nn_err"
NNN="$(printf '%s' "$_nn_out" | tr -d '[:space:]')"
[ "$(printf '%s' "$NNN" | wc -c | tr -d ' ')" = "3" ] || die "номер вне грамматики NNN: $NNN"
TAG="id/CONTRACT/$NNN"

# 5. Локальный тег должен быть аннотированный (next_id создаёт
# lightweight; пересоздаём как annotated для ls-remote).
tag_type="$(git -C "$REPO" cat-file -t "refs/tags/$TAG" 2>/dev/null || true)"
[ "$tag_type" = "tag" ] || {
  # Снимаем lightweight и создаём аннотированный с тем же объектом (next_id
  # уже создал lightweight; переносим коммит-объект и заменяем ref).
  current_sha="$(git -C "$REPO" rev-parse --verify --quiet "refs/tags/$TAG" 2>/dev/null || true)"
  [ -n "$current_sha" ] || die "локальный тег не получен: $TAG"
  msg="выдача механизмом $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git -C "$REPO" tag -d "$TAG" 2>/dev/null || true
  git -C "$REPO" tag -a "$TAG" "$current_sha" -m "$msg" \
    || die "не удалось создать аннотированный тег $TAG"
}

# 6. Публикация на origin проекта (через gitw — единый страж канона).
# non-force: `+refs/tags/...:refs/tags/...` отсутствует.
gitw_pub_err="$(mktemp 2>/dev/null || echo /dev/null)"
gitw_pub_out="$(bash "$HERE/gitw" -C "$REPO" push origin "refs/tags/$TAG:refs/tags/$TAG" 2>"$gitw_pub_err" || true)"
if [ -n "$gitw_pub_err" ] && [ -s "$gitw_pub_err" ]; then
  _pub_reason="$(cat "$gitw_pub_err" 2>/dev/null || true)"
  rm -f "$gitw_pub_err"
  # origin может быть не тем каноном (например, fetch.sh стенды): gitw
  # откажет «URL origin не канонический». Для контракта — это легитимный
  # отказ: origin не каноничен, резервация не объявлена.
  case "$_pub_reason" in
    *'не канонический'*|*'авторитет недоступен'*)\
      die "публикация на origin проекта не прошла: $_pub_reason" ;;
    *) die "публикация на origin проекта: $_pub_reason" ;;
  esac
fi
rm -f "$gitw_pub_err"

# 7. Сверка tag-object-sha локально и на origin.
local_sha="$(git -C "$REPO" rev-parse --verify --quiet "refs/tags/$TAG" 2>/dev/null || true)"
[ -n "$local_sha" ] || die "локальный sha не получен: $TAG"
remote_sha="$(git -C "$REPO" ls-remote --quiet origin "refs/tags/$TAG" 2>/dev/null | awk '{print $1}' || true)"
if [ "$remote_sha" != "$local_sha" ]; then
  die "tag-object-sha расходится: local=$local_sha remote=$remote_sha — конкурент на origin, номер не выдан"
fi

# 8. stdout — NNN (как требует next_id).
printf '%s\n' "$NNN"