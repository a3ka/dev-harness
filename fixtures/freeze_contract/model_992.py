"""Executable candidate construction, only for --model/--matrix.

Only recognized old sites are transformed; the behavioral battery judges the
result. Normal acceptance always executes scripts/ without these patches.
"""


def replace(text, old, new):
    if old not in text:
        # A completed implementation needs no model transformation.
        return text
    return text.replace(old, new)


def candidate(name, text):
    if name in ('freeze_contract.sh', 'done_contract.sh'):
        if name == 'freeze_contract.sh':
            old = 'done < <(g for-each-ref --format=\'%(refname)\' "refs/tags/frozen/$dir/$NNN/" 2>/dev/null || true)'
            start = 'vmax=0\nwhile IFS= read -r t; do'
            cmd = 'g for-each-ref --format=\'%(refname)\' "refs/tags/frozen/$dir/$NNN/"'
            reason = 'версии заморозки: for-each-ref не читается'
        else:
            old = 'done < <(cd "$ROOT" && git for-each-ref --format=\'%(refname)\' "refs/tags/done/contracts/$NNN/" 2>/dev/null || true)'
            start = 'done_vmax=0\nwhile IFS= read -r t; do'
            cmd = 'git -C "$ROOT" for-each-ref --format=\'%(refname)\' "refs/tags/done/contracts/$NNN/"'
            reason = 'done: версии: for-each-ref не читается'
        if old in text:
            text = replace(text, start, f'versions="$({cmd})" || die "{reason}"\n' + start)
            text = replace(text, old, 'done <<< "$versions"')
    elif name == 'check_charter.sh':
        text = replace(text, '  | awk \'/\\.md$/\' | sort > "$TMP/docs" || true', '  | awk \'/\\.md$/\' | sort > "$TMP/docs" || { bad "ls-tree не читается"; exit 1; }')
        text = replace(text, '    charter_diff_paths "$c" "$ROOT" | grep -qxF -- "$f" || continue', '    paths="$(charter_diff_paths "$c" "$ROOT")" || { bad "$f: diff-tree не читается"; continue; }\n    grep -qxF -- "$f" <<< "$paths" || continue')
    elif name == 'gitw_preflight_071.sh':
        for start, old, cmd, label in [
            ('while IFS= read -r l; do', 'done < <(git worktree list --porcelain 2>/dev/null)', 'git worktree list --porcelain', 'worktree list'),
            ("while IFS=$'\\t' read -r sha name; do", "done < <(git for-each-ref --format='%(objectname)%09%(refname)' refs/tags 2>/dev/null)", "git for-each-ref --format='%(objectname)%09%(refname)' refs/tags", 'for-each-ref'),
        ]:
            if old in text:
                text = replace(text, start, f'listing="$({cmd})" || {{ printf "gitw ПРЕДПОЛЁТ-ОТКАЗ: {label} не читается\\n" >&2; exit 1; }}\n' + start)
                text = replace(text, old, 'done <<< "$listing"')
        text = replace(text, 'pkg_content="$(git show "${send_tip}:package.json" 2>/dev/null)"', 'pkg_entry="$(git ls-tree "$send_tip" -- package.json)" || { printf "gitw ПРЕДПОЛЁТ-ОТКАЗ: package.json дерево не читается\\n" >&2; exit 1; }\npkg_content=""\nif [ -n "$pkg_entry" ]; then\n  pkg_content="$(git show "${send_tip}:package.json" 2>/dev/null)" || { printf "gitw ПРЕДПОЛЁТ-ОТКАЗ: package.json не читается\\n" >&2; exit 1; }\nfi')
    elif name == 'judge_gate.sh':
        text = replace(text, 'seq="$(d98_seq)"', 'seq="$(d98_seq)" || exit 1')
        text = replace(text, '  done <"$JOURNAL"', '  done <"$JOURNAL" || d98_die "журнал: seq не прочитан"')
    elif name == 'check_ci_gate.sh':
        lines = text.splitlines()
        for i, line in enumerate(lines):
            if line.lstrip().startswith("printf 'check\\t") and line.endswith('>>"$JOURNAL"'):
                lines[i] += ' || die "журнал: check-строка не записана: $JOURNAL"'
        text = '\n'.join(lines) + '\n'
    elif name == 'profile_resolver.sh':
        text = replace(text, 'dk="$(jq -r \'.defaults | keys_unsorted[]\' "$file" 2>/dev/null)"', 'dk="$(jq -r \'.defaults | keys_unsorted[]\' "$file" 2>/dev/null)" || die_p "defaults: jq не выполнился"')
        text = replace(text, 'bk="$(jq -r ".${branch} | keys_unsorted[]" "$file" 2>/dev/null)"', 'bk="$(jq -r ".${branch} | keys_unsorted[]" "$file" 2>/dev/null)" || die_p "${branch}: jq не выполнился"')
        text = replace(text, '    if ! jq -e "(.${branch}|type)==\\"object\\"" "$file" >/dev/null 2>&1; then\n      continue\n    fi', '    local object_rc=0\n    jq -e "(.${branch}|type)==\\"object\\"" "$file" >/dev/null 2>&1 || object_rc=$?\n    [ "$object_rc" -le 1 ] || die_p "${branch}: jq не выполнился"\n    [ "$object_rc" -eq 0 ] || continue')
        text = replace(text, '  [ "$(jq -r --arg p "$parent" \'(getpath($p | split(".")) // null) | type\' "$file" 2>/dev/null)" = "object" ] || return 0', '  local parent_type\n  parent_type="$(jq -r --arg p "$parent" \'(getpath($p | split(".")) // null) | type\' "$file" 2>/dev/null)" || die_p "${parent}: jq не выполнился"\n  [ "$parent_type" = object ] || return 0')
        text = replace(text, '  arr="$(jq -r --arg p "$path" \'if (getpath($p | split(".")) | type) == "array" then (getpath($p | split(".")) | join("\\n")) else empty end\' "$file" 2>/dev/null)"', '  arr="$(jq -r --arg p "$path" \'if (getpath($p | split(".")) | type) == "array" then (getpath($p | split(".")) | join("\\n")) else empty end\' "$file" 2>/dev/null)" || die_p "${path}: jq не выполнился"')
    return text
