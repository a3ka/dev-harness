#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ гарда контракта 130 «тег после текста» (носитель батареи, не продукт).
# Продукт — scripts/gitw_teg_130.sh (зона implementer); батарея ставит эту модель на его
# место в копии scripts/ и сверяет поведение gitw с оракулом.
#
#   gitw_teg_130.sh push <цель> <настоящий-git> <post_sub_idx> <argv gitw ...>
#       состав обмена — `git push --dry-run --porcelain --no-verify` с тем же argv;
#       каждый создаваемый/двигаемый refs/tags/frozen/* судится против main ЦЕЛИ (ls-remote).
#       rc 0 — тегов заморозки нет либо все допущены; rc 1 — именованный отказ.
#   gitw_teg_130.sh held <цель> <refs/tags/frozen/...>
#       rc 0 — тег в ожидании текста (текст или вердикт ещё не в main цели);
#       rc 1 — не в ожидании (текст в main цели — тег обязан уйти);
#       rc 2 — нечем судить (вне грамматики, main цели не читается).
#
# Отказ: «gitw ТЕГ-ОТКАЗ: <тег>: <класс>: <деталь>», классы — §Грамматика контракта 130.
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES

otkaz() { printf 'gitw ТЕГ-ОТКАЗ: %s: %s: %s\n' "$1" "$2" "$3" >&2; }

RMAIN=""
# main ЦЕЛИ: живой ls-remote, не локальный main и не refs/remotes/origin/main.
main_celi() {
  local tgt="$1" out
  out="$(git ls-remote "$tgt" refs/heads/main 2>/dev/null)" || return 1
  RMAIN="$(printf '%s\n' "$out" | awk -F'\t' '$2=="refs/heads/main"{print $1}')"
  [ -n "$RMAIN" ] || return 1
  return 0
}

# judge_tag <полное-имя-тега> <коммит-под-тегом>
#   0 — допущен; 1 — отказ по содержанию (текст/вердикт); 2 — вне грамматики/нечем судить.
judge_tag() {
  local ref="$1" commit="$2" short dir nnn v names path n blob_tag blob_main vk vpath body first
  short="${ref#refs/tags/}"
  if [[ ! "$ref" =~ ^refs/tags/frozen/(contracts|plans)/([0-9]{3})/([1-9][0-9]{0,3})$ ]]; then
    otkaz "$short" "тег вне грамматики" "ожидается frozen/(contracts|plans)/NNN/v"
    return 2
  fi
  dir="${BASH_REMATCH[1]}"; nnn="${BASH_REMATCH[2]}"; v="${BASH_REMATCH[3]}"
  if [ -z "$RMAIN" ]; then
    otkaz "$short" "main цели не читается" "ls-remote refs/heads/main пуст или упал"
    return 2
  fi
  if ! git cat-file -e "${RMAIN}^{commit}" 2>/dev/null; then
    otkaz "$short" "main цели не читается" "вершины ${RMAIN:0:12} нет локально — gitw fetch и повтор"
    return 2
  fi
  names="$(git ls-tree --name-only "$commit" -- "$dir/" 2>/dev/null)"
  n=0; path=""
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if [[ "$p" =~ ^${dir}/${nnn}-[^/]+\.md$ ]]; then n=$((n + 1)); path="$p"; fi
  done <<<"$names"
  if [ "$n" -ne 1 ]; then
    otkaz "$short" "текст не в main цели" "под тегом файлов $dir/$nnn-*.md: $n (нужен ровно один)"
    return 1
  fi
  blob_tag="$(git rev-parse --verify --quiet "$commit:$path" 2>/dev/null)"
  blob_main="$(git rev-parse --verify --quiet "$RMAIN:$path" 2>/dev/null || true)"
  if ! [ "$blob_main" = "$blob_tag" ]; then
    otkaz "$short" "текст не в main цели" "$path blob $blob_tag, в main цели ${RMAIN:0:12}: ${blob_main:-нет} — сначала ленд текста, тег остаётся локальным"
    return 1
  fi
  vk=1
  while [ "$vk" -le "$v" ]; do
    vpath="verdicts/critic/${dir}-${nnn}-v${vk}.md"
    body="$(git cat-file -p "$RMAIN:$vpath" 2>/dev/null || true)"
    first="$(printf '%s\n' "$body" | sed -n 1p | tr -d '\r')"
    first="${first#"${first%%[![:space:]]*}"}"
    first="${first%"${first##*[![:space:]]}"}"
    if ! [ "$first" = accept ]; then
      otkaz "$short" "вердикт критика не в main цели" "$vpath в main цели ${RMAIN:0:12}: ${first:-нет} (нужно accept)"
      return 1
    fi
    vk=$((vk + 1))
  done
  return 0
}

# sostav: строки «<from>\t<to>» создаваемых/двигаемых ссылок обмена по git push --dry-run.
sostav() {
  local out rc flag spec
  out="$("$REALGIT" "${PRE[@]}" --dry-run --porcelain --no-verify "${POST[@]}" 2>/dev/null)"; rc=$?
  SOSTAV_LINES=0
  while IFS=$'\t' read -r flag spec _; do
    case "$flag" in
      ' '|'+'|'*') ;;
      '-'|'='|'!') SOSTAV_LINES=$((SOSTAV_LINES + 1)); continue ;;
      *) continue ;;
    esac
    [ -n "${spec:-}" ] || continue
    SOSTAV_LINES=$((SOSTAV_LINES + 1))
    printf '%s\t%s\n' "${spec%%:*}" "${spec#*:}"
  done <<<"$out"
  if [ "$rc" -ne 0 ] && [ "$SOSTAV_LINES" -eq 0 ]; then
    return 1
  fi
  return 0
}

mode="${1:-}"; shift || true
case "$mode" in
  push)
    TGT="$1"; REALGIT="$2"; PSI="$3"; shift 3
    ARGS=( "$@" )
    PRE=( "${ARGS[@]:0:PSI}" ); POST=( "${ARGS[@]:PSI}" )
    SOSTAV_LINES=0
    if ! lines="$(sostav)"; then
      otkaz "(обмен)" "состав обмена не читается" "git push --dry-run не дал ни одной ссылки"
      exit 1
    fi
    frozen=()
    while IFS=$'\t' read -r from to; do
      [ -n "${to:-}" ] || continue
      case "$to" in
        refs/tags/frozen/*) frozen+=( "$from"$'\t'"$to" ) ;;
      esac
    done <<<"$lines"
    [ "${#frozen[@]}" -gt 0 ] || exit 0
    main_celi "$TGT" || RMAIN=""
    bad=0
    for fl in "${frozen[@]}"; do
      from="${fl%%$'\t'*}"; to="${fl#*$'\t'}"
      commit="$(git rev-parse --verify --quiet "${from}^{commit}" 2>/dev/null || true)"
      if [ -z "$commit" ]; then
        otkaz "${to#refs/tags/}" "состав обмена не читается" "источник $from не разрешается в коммит"
        bad=1; continue
      fi
      judge_tag "$to" "$commit" || bad=1
    done
    [ "$bad" -eq 0 ] || exit 1
    exit 0
    ;;
  held)
    TGT="$1"; ref="$2"
    commit="$(git rev-parse --verify --quiet "${ref}^{commit}" 2>/dev/null || true)"
    [ -n "$commit" ] || exit 2
    main_celi "$TGT" || RMAIN=""
    judge_tag "$ref" "$commit" 2>/dev/null
    case "$?" in
      0) exit 1 ;;
      1) exit 0 ;;
      *) exit 2 ;;
    esac
    ;;
  *)
    printf 'gitw ТЕГ-ОТКАЗ: (вызов): режим не распознан: %s\n' "$mode" >&2
    exit 2
    ;;
esac
