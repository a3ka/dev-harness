#!/usr/bin/env python3
"""231: data-driven reference and addressed full-door mutations, never production."""
import hashlib
import json
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '568f0ea63271e3461b574105cba8faec7563a8fd'
LOAD = '''# 231: installation HEAD is authoritative, never author cwd/index/environment.
_forms_root="$(git -C "$SELF_DIR" rev-parse --show-toplevel 2>/dev/null)" || die "done: DONE_FORMS_CONFIG"
_new_done_tmp || die "done: DONE_FORMS_CONFIG"
_forms_file="$_DONE_TMP_LAST"
_new_done_tmp || die "done: DONE_FORMS_CONFIG"
_forms_schema="$_DONE_TMP_LAST"
git -C "$_forms_root" show HEAD:config/done_forms.json > "$_forms_file" 2>/dev/null || die "done: DONE_FORMS_CONFIG"
git -C "$_forms_root" show HEAD:config/done_forms.schema.json > "$_forms_schema" 2>/dev/null || die "done: DONE_FORMS_CONFIG"
VALIDATE_STD_PINS="$_forms_root/ops/server/validators.tsv" bash "$SELF_DIR/validate_std.sh" json "$_forms_schema" "$_forms_file" >/dev/null 2>&1 || die "done: DONE_FORMS_CONFIG"
_forms_rows="$(jq -r '.verdicts[] | [.pattern, .version_group, .number_group, .default_version, .mode, (.reject_on_miss // "-")] | map(tostring) | join("\\t")' "$_forms_file")" || die "done: DONE_FORMS_CONFIG"
_forms_reserved="$(jq -r '.reserved[]' "$_forms_file")" || die "done: DONE_FORMS_CONFIG"
_forms_station="$(jq -r '.station_lines[]' "$_forms_file")" || die "done: DONE_FORMS_CONFIG"
_forms_external="$(jq -r '.external_pattern' "$_forms_file")" || die "done: DONE_FORMS_CONFIG"
_forms_plain="$(jq -r '.plain_call_from_record' "$_forms_file")" || die "done: DONE_FORMS_CONFIG"
'''
NAMES = '''    while IFS=$'\\t' read -r pattern vg ng default mode reject; do
      if [[ "$name" =~ $pattern ]]; then
        version="$default"
        if [ "$vg" -ne 0 ]; then version="${BASH_REMATCH[$vg]-}"; fi
        if [ "$ng" -ne 0 ]; then number="${BASH_REMATCH[$ng]-}"; fi
        declared="$version"
        case "$mode" in
          explicit) explicit=1 declared="$number" ;;
          plain) plain=1 ;;
          legacy) legacy=1 ;;
          numbered) : ;;
        esac
        break
      elif [ "$reject" != '-' ] && [[ "$name" =~ $reject ]]; then
        die "done: VERDICT_ROUND_INVALID: $role: $f"
      fi
    done <<< "$_forms_rows"
    if [ -z "$version" ]; then
      while IFS= read -r pattern; do
        if [[ "$name" =~ $pattern ]]; then die "done: VERDICT_ROUND_INVALID: $role: $f"; fi
      done <<< "$_forms_reserved"
      if [ "$count" -eq 1 ]; then version=1; else die "done: VERDICT_ROUND_MISSING: $role: $f"; fi
    fi
'''
CALL_KEY = '''    if [ "$legacy" -eq 1 ] && [ -n "$call" ] && [ "$call" != "$declared" ]; then
      die "done: VERDICT_ROUND_CONFLICT: $role: $f"
    fi
    if [ "$plain" -eq 1 ] && [ "$_forms_plain" = true ] && [ -n "$call" ]; then
      declared=''
      if [ -z "$phase_version" ]; then version="$call"; fi
    fi
'''
PRODUCT = '''    _station=0
    while IFS= read -r _literal; do
      if [ "$_pdecl" = "$_literal" ]; then _station=1; fi
    done <<< "$_forms_station"
    if [ "$_station" -eq 1 ]; then
      place="станция"
    elif [[ "$_pdecl" =~ $_forms_external ]]; then
      place="${BASH_REMATCH[1]}"
'''


def one(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('ANCHOR ' + repr(old) + ': ' + str(text.count(old)))
    return text.replace(old, new)


def blob(ref, path):
    return subprocess.run(['git', '-C', str(ROOT), 'show', ref + ':' + path], capture_output=True, check=True).stdout


def reference():
    text = blob(BASE, 'scripts/done_contract.sh').decode()
    start = text.index('    if [[ "$name" =~ -impl-v')
    end = text.index('    [ "${#version}" -le 9 ]', start)
    text = text[:start] + NAMES + text[end:]
    text = one(text, 'local version number declared call denominator phase_version explicit',
               'local version number declared call denominator phase_version explicit legacy plain pattern vg ng default mode reject')
    text = one(text, "version='' number=0 declared='' explicit=0", "version='' number=0 declared='' explicit=0 legacy=0 plain=0")
    anchor = '    # ── сверка объявлений с именем носителя ──────────────────────────────\n'
    text = one(text, anchor, anchor + CALL_KEY)
    start = text.index('    if [ "$_pdecl" = "ПРОДУКТ: станция" ]; then')
    end = text.index('    else\n', start)
    text = text[:start] + PRODUCT + text[end:]
    text = one(text, 'TARGET="${1:', LOAD + '\nTARGET="${1:')
    return one(text, '#!/usr/bin/env bash\n', '#!/usr/bin/env bash\n# shellcheck disable=SC2034,SC2295,SC1010\n')


# One source of all observable mutation/input links (Н-39).
MUTATIONS = {
    'lexical': ('if [ "$key" -gt "$best" ]; then', 'if [[ "$key" > "$best" ]]; then', ['numeric-fail', 'numeric-accept']),
    'bare-zero': ('version="$default"', 'version="$default"; if [ "$vg" -eq 0 ]; then version=0; fi', ['bare-duplicate']),
    'bare-skipped': ('version="$default"', 'if [ "$vg" -eq 0 ]; then continue 2; fi; version="$default"', ['bare-fail']),
    'krug-rejected': ('.verdicts[] |', '.verdicts[:3][] |', ['krug']),
    'unchecked-call': (CALL_KEY, '    if [ "$legacy" -eq 1 ]; then declared=""; fi\n', ['old-conflict-low', 'old-conflict-high']),
    'always-conflict': ('[ "$legacy" -eq 1 ] && [ -n "$call" ] && [ "$call" != "$declared" ]', '[ "$legacy" -eq 1 ] && [ -n "$call" ]', ['old-call-equal']),
    'old-rejected': ('.verdicts[] |', '.verdicts[:3][] |', ['back181', 'back179', 'mobile218', 'krug']),
    'call-instead-name': ('legacy) legacy=1 ;;', 'legacy) plain=1 declared="" ;;', ['old-conflict-low', 'old-conflict-high']),
    'v-call-required': ('[ "$_forms_plain" = true ]', 'false', ['live227', 'plain-call-high', 'plain-call-low']),
    'explicit-unchecked': ('[ "$call" = "$declared" ]', '[ "$explicit" -eq 1 ] || [ "$call" = "$declared" ]', ['explicit-conflict']),
    'duplicates-allowed': ('*" $key "*) die "done: VERDICT_ROUND_DUPLICATE: $role: $key: $f" ;;', '*" $key "*) : ;;', ['same-call', 'bare-duplicate']),
    'dot-rejected': ("'.station_lines[]'", "'.station_lines[:1][]'", ['product-live215']),
    'dot-tail-allowed': ('[ "$_pdecl" = "$_literal" ]', '[[ "$_pdecl" == "$_literal"* ]]', ['product-double-dot', 'product-dot-x']),
    'zero-allowed': ('\n      if [[ "$name" =~ $pattern ]]; then', '\n      pattern="${pattern//\\[1-9\\]\\[0-9\\]\\*/[0-9]+}"\n      if [[ "$name" =~ $pattern ]]; then', ['old-zero', 'old-leading-zero']),
    'hardcoded-names': ('done <<< "$_forms_rows"', 'done <<< "$__fixed_rows"', ['config-name-added']),
    'hardcoded-products': ('done <<< "$_forms_station"', 'done <<< "$__fixed_station"', ['product-config-added']),
    'hardcoded-call-rule': ('[ "$_forms_plain" = true ]', 'true', ['config-call-disabled']),
    'config-ignored': ('done <<< "$_forms_rows"', 'done <<< "$__fixed_rows"', ['config-name-added', 'config-name-removed']),
    'config-worktree': ('show HEAD:config/done_forms.json', 'show :config/done_forms.json', ['config-index']),
    'config-author-tree': ('git -C "$_forms_root" show HEAD:config/done_forms.json', 'cat "$PWD/config/done_forms.json"', ['config-author']),
    'config-environment': ('git -C "$_forms_root" show HEAD:config/done_forms.json', 'cat "$DONE_FORMS_CONFIG"', ['config-environment']),
    'config-dirty-install': ('git -C "$_forms_root" show HEAD:config/done_forms.json', 'cat "$_forms_root/config/done_forms.json"', ['config-worktree']),
    'config-fail-open': ('|| die "done: DONE_FORMS_CONFIG"', '|| exit 0', ['config-broken', 'config-empty', 'config-missing', 'config-schema', 'config-version', 'config-control']),
    'config-schema-ignored': (LOAD.splitlines()[8], ': # schema ignored', ['config-version', 'config-control']),
}


def main():
    import sys
    sys.dont_write_bytecode = True
    from probe import CASES
    model = reference()
    policy = json.loads((ROOT / 'config/done_forms.json').read_text())
    rows = '\n'.join('\t'.join(str(x[k]) for k in ('pattern', 'version_group', 'number_group', 'default_version', 'mode')) + '\t' + x.get('reject_on_miss', '-') for x in policy['verdicts'])
    fixed = "\n__fixed_rows='" + rows + "'\n__fixed_station='" + '\n'.join(policy['station_lines']) + "'\n"
    carriers = {'model/done_contract.sh': model.encode()}
    links = []
    for name, (old, new, cells) in MUTATIONS.items():
        path = 'stabs/' + name + '/done_contract.sh'
        # Fail-open mutates every fail-closed exit; other mutations are surgical.
        mutated = model.replace(old, new) if name == 'config-fail-open' else one(model, old, new)
        if name in ('hardcoded-names', 'hardcoded-products', 'config-ignored'):
            mutated = one(mutated, '\nTARGET=', fixed + '\nTARGET=')
        carriers[path] = mutated.encode()
        for cell in cells:
            names = [cell] if cell.startswith(('product-', 'config-')) and cell not in ('config-name-added', 'config-name-removed', 'config-call-disabled') else [role + '-' + cell for role in ('review', 'adversary')]
            for case in names:
                if case not in CASES:
                    raise RuntimeError('UNKNOWN_CASE ' + case)
                links.append({'stab': path, 'case': case})
    for path, content in carriers.items():
        dest = HERE / path
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(content)
    (HERE / 'source.json').write_text(json.dumps({'base': BASE, 'nositeli': {p: hashlib.sha256(c).hexdigest() for p, c in carriers.items()}, 'stab_vhod': links}, indent=2) + '\n')
    (HERE / 'stabs.tsv').write_text(''.join(x['stab'] + '\t' + x['case'] + '\n' for x in links))
    print('NOSITELI', len(carriers), 'STABY', len(MUTATIONS), 'SVJAZI', len(links))


if __name__ == '__main__':
    main()
