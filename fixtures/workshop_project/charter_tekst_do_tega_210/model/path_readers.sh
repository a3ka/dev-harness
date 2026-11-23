#!/usr/bin/env bash
# 210: executable models of the path-reading seams, not replacement policies.
# Callers supply the unchanged next_id/charter library and a real Git world.
next_head_210() {
  local root="$1" loc path_in_tree base max=0
  local -a locations=(contracts/)
  git -C "$root" ls-tree -r -z --name-only HEAD -- contracts/ > "$TMP/head" || return 1
  while IFS= read -r -d '' path_in_tree; do
    case "$path_in_tree" in contracts/*) ;; *) continue ;; esac
    base="${path_in_tree##*/}"
    parse_artifact_basename "$base" || continue
    [ "$ARTIFACT_NUMBER" -le "$max" ] || max="$ARTIFACT_NUMBER"
  done < "$TMP/head"
  printf '%s\n' "$max"
}
next_history_210() {
  local root="$1" path base max=0
  git -C "$root" log -z --all --diff-filter=A --name-only --format= > "$TMP/history" || return 1
  while IFS= read -r -d '' path; do
    # With empty --format Git emits a single LF between commits, never a header.
    path="${path#$'\n'}"
    case "$path" in contracts/*) ;; *) continue ;; esac
    base="${path##*/}"
    parse_artifact_basename "$base" || continue
    [ "$ARTIFACT_NUMBER" -le "$max" ] || max="$ARTIFACT_NUMBER"
  done < "$TMP/history"
  printf '%s\n' "$max"
}
backfill_210() {
  local root="$1" f name n tagname
  find "$root/contracts/" -type f -print0 > "$TMP/find" || return 1
  while IFS= read -r -d '' f; do
    name="${f##*/}"
    parse_artifact_basename "$name" || continue
    n="$ARTIFACT_NUMBER"
    tagname="id/CONTRACT/$(printf '%03d' "$n")"
    git -C "$root" show-ref --tags --quiet -- "refs/tags/$tagname" && continue
    git -C "$root" tag "$tagname" -m 'выдано до заведения регистра' || return 1
  done < "$TMP/find"
}
frozen_reader_210() {
  soglasno=1; chuzhoj=""
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    grandfather_pair "$c" "$f" && continue
    charter_diff_paths "$c" "$ROOT" > "$TMP/delta" || return 1
    while IFS= read -r -d '' df; do
      [ -n "$df" ] || continue
      if [ "$df" != "$f" ]; then
        case "$df" in
          contracts/*.md|plans/*.md) soglasno=0; chuzhoj="$df"; break ;;
        esac
      fi
    done < "$TMP/delta"
    [ "$soglasno" -eq 1 ] || break
  done <<<"$pred_komity"
}
zones_reader_210() {
  razrechen=1
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    charter_diff_paths "$c" "$ROOT" > "$TMP/delta" || return 1
    while IFS= read -r -d '' df; do
      [ -n "$df" ] || continue
      case "$df" in contracts/"$nnn"-*.md) ;; *) continue ;; esac
      razreshil "$c" "$df" || { razrechen=0; break 2; }
    done < "$TMP/delta"
  done <<<"$pred_komity"
}
