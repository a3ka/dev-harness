#!/usr/bin/env bash
# Reference candidate, not a production file or a byte-for-byte port requirement.
# The caller supplies existing g/bad/razreshil/publication predicates.
pr_refuse() { printf 'PR_WINDOW_%s\n' "$1" >&2; exit 1; }

pr_prepare() {
  local shallow remote base head bases c row p
  local merge_mode=-c
  shallow="$(g rev-parse --is-shallow-repository)" || pr_refuse HISTORY_UNREADABLE
  [ "$shallow" = false ] || pr_refuse SHALLOW
  head="$(g rev-parse --verify 'HEAD^{commit}')" || pr_refuse HEAD_UNREADABLE
  base="$(g rev-parse --verify 'refs/remotes/origin/main^{commit}' 2>/dev/null)" || pr_refuse BASE_MISSING
  remote="$(g ls-remote --exit-code origin refs/heads/main)" || pr_refuse ORIGIN_UNAVAILABLE
  [ "$remote" = "$base"$'\trefs/heads/main' ] || pr_refuse BASE_UNTRUSTED
  bases="$(g merge-base --all "$base" "$head")" || pr_refuse BASE_UNRELATED
  case "$bases" in ''|*$'\n'*) pr_refuse BASE_AMBIGUOUS ;; esac
  PR_HEAD="$head"; PR_MAIN="$base"; PR_BASE="$bases"
  PR_COMMITS="$(g rev-list --reverse "$head" --not "$base")" || pr_refuse HISTORY_UNREADABLE
  declare -gA PR_PATHS=() PR_MD=() PR_CHANGE=()
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    # -c lists only paths differing from every parent. Inherited main content
    # is not a new merge edit; every non-main side commit is still in PR_COMMITS.
    row="$(mktemp "$ROOT/tmp/pr-paths.XXXXXX")" || pr_refuse TEMP_UNAVAILABLE
    if ! g diff-tree --root -r "$merge_mode" --no-commit-id --no-renames --name-only -z "$c" > "$row"; then
      rm -f "$row"; pr_refuse DELTA_UNREADABLE
    fi
    while IFS= read -r -d '' p; do
      PR_PATHS["$p"]=1; PR_CHANGE["$c:$p"]=1
    done < "$row"
    if ! g diff-tree --root -r "$merge_mode" --no-commit-id --no-renames --diff-filter=MD --name-only -z "$c" > "$row"; then
      rm -f "$row"; pr_refuse DELTA_UNREADABLE
    fi
    while IFS= read -r -d '' p; do PR_MD["$c:$p"]=1; done < "$row"
    rm -f "$row"
  done <<< "$PR_COMMITS"
  printf 'pr: %s main=%s base=%s head=%s\n' "$PR_NAME" "$PR_MAIN" "$PR_BASE" "$PR_HEAD" >&2
}

pr_collect() {
  local dir="$1" number="$2" row path
  row="$(mktemp "$ROOT/tmp/pr-scope.XXXXXX")" || pr_refuse TEMP_UNAVAILABLE
  if ! g ls-tree -r -z --name-only "$PR_HEAD" -- "$dir/" > "$row"; then
    rm -f "$row"; pr_refuse SCOPE_UNREADABLE
  fi
  while IFS= read -r -d '' path; do
    case "$path" in "$dir/$number-"*.md) PR_FROZEN_PATHS["$path"]=1 ;; esac
  done < "$row"
  rm -f "$row"
}

pr_files() {
  local p c t n dir tags
  declare -gA PR_FROZEN_PATHS=()
  for p in "${!PR_PATHS[@]}"; do
    case "$p" in
      contracts/*.md|plans/*.md) PR_FROZEN_PATHS["$p"]=1 ;;
      verdicts/critic/contracts-*-v*.md|verdicts/critic/plans-*-v*.md)
        n="${p#verdicts/critic/}"; dir="${n%%-*}"; n="${n#*-}"; n="${n%%-*}"
        pr_collect "$dir" "$n"
        ;;
    esac
  done
  # A tag anchored on an own PR commit is itself in scope even when that commit
  # only added a verdict/code. Tags anchored exclusively on main are not.
  tags="$(g for-each-ref --format='%(refname)' refs/tags/frozen/)" || pr_refuse TAGS_UNREADABLE
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    c="$(g rev-parse --verify "$t^{commit}")" || pr_refuse TAG_UNREADABLE
    case $'\n'"$PR_COMMITS"$'\n' in *$'\n'"$c"$'\n'*)
      n="${t#refs/tags/frozen/}"; dir="${n%%/*}"; n="${n#*/}"; n="${n%%/*}"
      pr_collect "$dir" "$n"
      ;;
    esac
  done <<< "$tags"
  for p in "${!PR_FROZEN_PATHS[@]}"; do
    printf '%s\n' "$p"
  done | LC_ALL=C sort
}

pr_tags() {
  local t dir n f found tags
  tags="$(g for-each-ref --format='%(refname)' refs/tags/frozen/)" || pr_refuse TAGS_UNREADABLE
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    n="${t#refs/tags/frozen/}"; dir="${n%%/*}"; n="${n#*/}"; n="${n%%/*}"
    found=0
    while IFS= read -r f; do
      case "$f" in "$dir/$n-"*.md) found=1 ;; esac
    done < "$TMP/files"
    [ "$found" -eq 0 ] || printf '%s\n' "$t"
  done <<< "$tags"
}

pr_changes() {
  local c
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    [ -n "${PR_CHANGE[$c:$f]+set}" ] || continue
    # vmax belongs to the calling frozen guard's artifact loop.
    # shellcheck disable=SC2154
    if g merge-base --is-ancestor "$c" "refs/tags/frozen/$dir/$NNN/$vmax"; then continue; fi
    printf '%s\n' "$c"
  done <<< "$PR_COMMITS"
}

pr_charter() {
  local c p since n publication_rc membership_rc
  g rev-parse --verify --quiet refs/tags/ustav/1 >/dev/null || skip 'устав не введён'
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    for p in "${!PR_PATHS[@]}"; do
      [ -n "${PR_MD[$c:$p]+set}" ] || continue
      membership_rc=0; is_charter_path "$p" "$ROOT" || membership_rc=$?
      [ "$membership_rc" -ne 2 ] || pr_refuse SCOPE_UNREADABLE
      [ "$membership_rc" -eq 0 ] || continue
      case "$p" in
        AGENTS.md|ROADMAP.md) since=refs/tags/ustav/1 ;;
        *) n="${p##*/}"; n="${n%%-*}"; since="refs/tags/frozen/${p%%/*}/$n/1" ;;
      esac
      if g merge-base --is-ancestor "$c" "$since"; then continue; fi
      if razreshil "$c" "$p"; then
        ok "уставной документ изменён с разрешения владельца: $p в ${c:0:8}"
      else
        publication_rc=0; charter_frozen_publication "$c" "$p" "$ROOT" || publication_rc=$?
        if [ "$publication_rc" -eq 0 ]; then
          ok "уставной документ внесён публикацией заморозки: $p в ${c:0:8}"
        elif [ "$publication_rc" -eq 2 ]; then
          bad "не могу проверить публикацию заморозки: $p в ${c:0:8}"
        else
          bad "уставной документ изменён без разрешения владельца: $p в ${c:0:8}"
        fi
      fi
    done
  done <<< "$PR_COMMITS"
  # fails is the existing caller-owned guard counter.
  # shellcheck disable=SC2154
  [ "$fails" -eq 0 ]
}
