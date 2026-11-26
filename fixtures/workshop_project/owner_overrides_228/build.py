#!/usr/bin/env python3
"""Reference deltas on the pinned ancestor. No production file is written."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '78672b79bac88b9c3765b3d9b53cd983d4a13728'
GATES = ('check_charter', 'check_zones', 'check_protected', 'check_contract_frozen')
SHA = r'[0-9a-f]{40}'


def base(path):
    return subprocess.check_output(['git', '-C', str(ROOT), 'show', BASE + ':' + path]).decode()


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('REFERENCE_ANCHOR: ' + old[:100])
    return text.replace(old, new, 1)


def span(text, first, last):
    a = text.index(first)
    b = text.index(last, a)
    return a, b


def case_rows(text, key, author='*'):
    """Pinned simple case arms only; discovered scope is checked by baseline Bash."""
    arms = list(re.finditer(r'^\s*(' + SHA + r'(?:\|' + SHA + r')*)\)\s*$', text, re.M))
    rows = []
    for i, arm in enumerate(arms):
        block = text[arm.end():arms[i + 1].start() if i + 1 < len(arms) else len(text)]
        paths = re.findall(r'\[ "\$[pf]" = "([^"]+)" \]', block)
        if not paths:
            for match in re.finditer(r'^\s*((?:[A-Za-z0-9._/*-]+)(?:\|[A-Za-z0-9._/*-]+)*)\)\s*(?:return|$)', block, re.M):
                if match.group(1) != '*':
                    paths.extend(match.group(1).split('|'))
        if not paths:
            paths = ['*']
        for sha in arm.group(1).split('|'):
            for path in paths:
                rows.append([key, sha, path, author, 'R-0114', 'never'])
    return rows


def extracted():
    texts = {gate: base('scripts/' + gate + '.sh') for gate in GATES}
    charter = texts['check_charter']
    a, b = span(charter, 'grandfather_pair() {', '\nrazreshil() {')
    rows = case_rows(charter[a:b], 'check_charter/grandfather')
    c, d = span(charter, '  case "$c" in\n    a8a58', '\n  local body line path reason')
    rows += case_rows(charter[c:d], 'check_charter/permit')
    protected = texts['check_protected']
    e, f = span(protected, '    case "$c" in\n      31fcb', '    is_lagging_merge_artifact')
    rows += case_rows(protected[e:f], 'check_protected/delete')
    zones = texts['check_zones']
    g, h = span(zones, '        case "$c" in\n          78bae', '        # Дельта коммита')
    for row in case_rows(zones[g:h], 'check_zones/mint', 'orchestrator'):
        row[2] = 'registry/contracts.tsv'
        rows.append(row)
    i, j = span(zones, '      # ── ГРАНДФАЗЕР (узкий, слово владельца 2026-10-09 —', '      inside=1')
    rows += case_rows(zones[i:j], 'check_zones/process')
    rows += [
        ['check_contract_frozen/skip-version', '-', 'contracts/148/4', '*', 'R-0114', 'never'],
        ['check_zones/skip-version', '-', 'contracts/148/4', '*', 'R-0114', 'never'],
    ]
    if len(rows) != len({tuple(row[:4]) for row in rows}):
        raise RuntimeError('DUPLICATE_EXTRACTED')
    return texts, sorted(rows), (a, b, c, d, e, f, g, h, i, j)


def reference():
    texts, rows, indexes = extracted()
    a, b, c, d, e, f, g, h, i, j = indexes
    # Preserve live parser/CLI semantics; replace only the historical decisions.
    t = texts['check_charter']
    t = t[:c] + '  owner_override_has check_charter/permit "$c" "$p" || [ "$?" -eq 1 ] || return 2\n  if owner_override_has check_charter/permit "$c" "$p"; then return 0; fi\n' + t[d:]
    t = t[:a] + 'grandfather_pair() {\n  owner_override_has check_charter/grandfather "$1" "$2"\n}\n' + t[b:]
    t = replace_once(t, '  grandfather_pair "$c" "$p" && return 0', '  if [ "$p" != registry/owner-overrides.tsv ]; then\n    local owner_rc=0\n    grandfather_pair "$c" "$p" && return 0 || owner_rc=$?\n    [ "$owner_rc" -eq 1 ] || return "$owner_rc"\n  fi')
    t = replace_once(t, '    AGENTS.md|ROADMAP.md)', '    registry/owner-overrides.tsv)\n      return 0\n      ;;\n    AGENTS.md|ROADMAP.md)')
    t = replace_once(t, 'for f in AGENTS.md ROADMAP.md; do', 'for f in AGENTS.md ROADMAP.md registry/owner-overrides.tsv; do')
    # Validate the authority-file delta separately, including additions/deletions;
    # no grant from the candidate registry may authorize its own carrier.
    authority = '''owner_file_commits="$(g log --format=%H --no-renames --diff-merges=first-parent ustav/1..HEAD -- registry/owner-overrides.tsv)"
while IFS= read -r owner_c; do
  [ -n "$owner_c" ] || continue
  if ! razreshil "$owner_c" registry/owner-overrides.tsv; then
    bad "уставной документ изменён без разрешения владельца: registry/owner-overrides.tsv в ${owner_c:0:8}"
  fi
done <<<"$owner_file_commits"
'''
    t = replace_once(t, 'docs=0; changes=0; excused=0', authority + '\ndocs=0; changes=0; excused=0')
    texts['check_charter'] = t
    t = texts['check_protected']
    t = t[:e] + '''    local owner_rc=0
    owner_override_has check_protected/delete "$c" "$p" && return 0 || owner_rc=$?
    [ "$owner_rc" -eq 1 ] || return "$owner_rc"
''' + t[f:]
    texts['check_protected'] = t
    t = texts['check_zones']
    t = t[:i] + '''      if owner_override_has check_zones/process "$c" "$f" "$an"; then
        printf '%s\\n' "$f" >> "$TMP/process_excluded"
        continue
      fi
''' + t[j:]
    t = t[:g] + '''        if owner_override_has check_zones/mint "$c" "$f" "$an"; then
          skip_path=1
          continue
        fi
''' + t[h:]
    t = replace_once(t, '[ "$add_nnn" = "148" ] && [ "$vmax" = "5" ]', 'owner_override_has check_zones/skip-version - "contracts/$add_nnn/$((vmax - 1))" && [ "$vmax" = "5" ]')
    # The empty-tree SHA is a Git constant, NOT an owner grant. Compute it.
    t = replace_once(t, '$(g rev-parse --verify 4b825dc642cb6eb9a060e54bf899d15f3f938a82)', '"$(g hash-object -t tree --stdin </dev/null)"')
    texts['check_zones'] = t
    t = texts['check_contract_frozen']
    t = replace_once(t, '[ "$dir/$NNN/$k" = "contracts/148/4" ]', 'owner_override_has check_contract_frozen/skip-version - "$dir/$NNN/$k"')
    texts['check_contract_frozen'] = t
    library = (HERE / 'model/lib_owner.sh').read_text()
    for gate, t in texts.items():
        # Code import is mandatory, but no data is read while sourced as a library.
        anchor = 'SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"'
        if gate == 'check_protected':
            anchor = 'INCR_NAME=check_protected'
            t = replace_once(t, anchor, 'SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\n# shellcheck disable=SC1091\n. "$SELF_DIR/lib_owner.sh"\n' + anchor)
        else:
            t = replace_once(t, anchor, anchor + '\n# shellcheck disable=SC1091\n. "$SELF_DIR/lib_owner.sh"')
        anchor = 'g() { git -C "$ROOT" "$@"; }' if gate != 'check_protected' else 'ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"'
        if anchor not in t and gate == 'check_protected':
            match = re.search(r'^ROOT=.*$', t, re.M)
            if not match:
                raise RuntimeError('PROTECTED_ROOT_ABSENT')
            anchor = match.group(0)
        # Malformed registry is not a negative membership result.
        t = replace_once(t, anchor, anchor + '\nowner_override_validate || exit 1')
        texts[gate] = t
    return texts, rows, library


def capture():
    texts, rows, _ = extracted()
    dest = HERE / 'baseline.json'
    payload = {'baseline': BASE, 'files': {k: hashlib.sha256(v.encode()).hexdigest() for k, v in texts.items()},
               'rows': rows, 'sha40_occurrences': {k: len(re.findall(r'\b' + SHA + r'\b', v)) for k, v in texts.items()}}
    dest.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n')
    print('BASELINE', BASE, 'ROWS', len(rows), 'UNIQUE_SHA', len({r[1] for r in rows if r[1] != '-'}))


if __name__ == '__main__':
    capture()
