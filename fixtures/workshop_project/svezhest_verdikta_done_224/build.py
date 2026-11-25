#!/usr/bin/env python3
"""224 carriers: ancestor canon + one round selector; addressed mutants (Н-39)."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
from probe import CASES

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
BASE = '5fa6b2c294c2dfd677febb200c73dc27467461e6'
SELECTOR = r'''# 224: round numbers order verdicts; commit ancestry still binds OBJECT/F.
_select_round_verdict() {
  local files="$1" role="$2" f name text cid number call field day name_day key
  local version declared rest token kind denominator phase_version explicit count=0
  local best=0 seen=' ' metadata='' prior_n prior_d
  _rv_file='' _rv_cid='' _rv_first=''
  while IFS= read -r f; do
    [ -z "$f" ] || count=$((count + 1))
  done <<< "$files"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="${f##*/}" version='' declared='' explicit=0
    if [[ "$name" =~ -impl-v([1-9][0-9]*)-vyzov([1-9][0-9]*)\.md$ ]]; then
      version="${BASH_REMATCH[1]}" number="${BASH_REMATCH[2]}" explicit=1
      declared="$number"
    elif [[ "$name" == *-impl-v*-vyzov*.md ]]; then
      die "done: VERDICT_ROUND_INVALID: $role: $f"
    elif [[ "$name" =~ -v([1-9][0-9]*)(-[A-Za-z0-9._-]+)?\.md$ ]]; then
      version="${BASH_REMATCH[1]}" number=0 declared="$version"
    elif [[ "$name" =~ -impl-a([1-9][0-9]*)\.md$ ]]; then
      version="${BASH_REMATCH[1]}" number=0 declared="$version"
    elif [[ "$name" =~ -(v|impl-v|impl-a)[0-9] ]]; then
      die "done: VERDICT_ROUND_INVALID: $role: $f"
    elif [ "$count" -eq 1 ]; then
      version=1 number=0
    else
      die "done: VERDICT_ROUND_MISSING: $role: $f"
    fi
    [ "${#version}" -le 9 ] && [ "${#number}" -le 9 ] \
      || die "done: VERDICT_ROUND_INVALID: $role: $f"
    text="$(git -C "$ROOT" cat-file -p "HEAD:$f")" \
      || die "done: VERDICT_ROUND_READ: $role: $f"
    text="${text//$'\r'/}"
    call='' day='' name_day='' phase_version=''
    if [[ "$name" =~ -([0-9]{4}-[0-9]{2}-[0-9]{2})(-|\.md$) ]]; then
      name_day="${BASH_REMATCH[1]}"
    fi
    while IFS= read -r field; do
      [[ "$field" == 'СУД: '* ]] || continue
      rest="${field#СУД: }"
      # One cursor consumes every supported field start, regardless of order.
      while [[ "$rest" =~ (^|[\;\ ])(фаза|вызов|дата)= ]]; do
        kind="${BASH_REMATCH[2]}"
        rest="${rest#*"${BASH_REMATCH[0]}"}"
        token="${rest%%;*}"
        # A space-separated next field also ends this value: a cycle must not
        # greedily absorb a later phase/call/date declaration.
        if [[ "$token" =~ \ (фаза|вызов|дата)= ]]; then
          token="${token%%"${BASH_REMATCH[0]}"*}"
        fi
        case "$kind" in
          фаза)
            if [[ "$token" =~ ^реализация\ v([1-9][0-9]*)(\ |$) ]]; then
              token="${BASH_REMATCH[1]}"
            elif [[ "$token" =~ ^реализация[^\;]*круг\ ([1-9][0-9]*)([,\)\ ]|$) ]]; then
              token="${BASH_REMATCH[1]}"
            else
              continue # An unversioned phase remains free historical prose.
            fi
            [ -z "$phase_version" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
            phase_version="$token"
            ;;
          вызов)
            token="${token%% *}"
            [ -z "$call" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
            if [[ "$token" =~ ^([1-9][0-9]*)(/([1-9][0-9]*))?$ ]]; then
              call="${BASH_REMATCH[1]}" denominator="${BASH_REMATCH[3]}"
              [ "${#call}" -le 9 ] && [ "${#denominator}" -le 9 ] \
                || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
            else
              die "done: VERDICT_ROUND_CONFLICT: $role: $f"
            fi
            ;;
          дата)
            token="${token%% *}"
            [ -z "$day" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
            [[ "$token" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
              || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
            day="$token"
            ;;
        esac
      done
    done <<< "$text"
    if [ -n "$phase_version" ]; then
      [ "${#phase_version}" -le 9 ] && [ -n "$call" ] \
        || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      if [ "$explicit" -eq 1 ]; then
        [ "$version" = "$phase_version" ] \
          || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      else
        version="$phase_version" number="$call" declared="$call"
      fi
    fi
    [ -z "$call" ] || [ -z "$declared" ] || [ "$call" = "$declared" ] \
      || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
    # Two coordinates avoid confusing implementation generation and call.
    key=$((version * 1000000000 + number))
    case "$seen" in
      *" $key "*) die "done: VERDICT_ROUND_DUPLICATE: $role: $key: $f" ;;
    esac
    seen="$seen$key "
    if [ -n "$name_day" ]; then
      [ -z "$day" ] || [ "$day" = "$name_day" ] \
        || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      day="$name_day"
    fi
    if [ -n "$day" ]; then
      [ "$(date -u -d "$day" +%F 2>/dev/null)" = "$day" ] \
        || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      while read -r prior_n prior_d; do
        [ -n "$prior_d" ] || continue
        if { [ "$prior_n" -lt "$key" ] && [[ "$prior_d" > "$day" ]]; } \
          || { [ "$prior_n" -gt "$key" ] && [[ "$prior_d" < "$day" ]]; }; then
          die "done: VERDICT_ROUND_ORDER: $role: $f"
        fi
      done <<< "$metadata"
      metadata="${metadata}${key} ${day}"$'\n'
    fi
    cid="$(git -C "$ROOT" log --format=%H -1 -- "$f")" \
      || die "done: история вердикта не читается: $f — проверить невозможно"
    [ -n "$cid" ] || die "done: у вердикта на HEAD нет коммита в истории: $f — проверить невозможно"
    if [ "$key" -gt "$best" ]; then
      best="$key" _rv_file="$f" _rv_cid="$cid"
      _rv_first="${text%%$'\n'*}"
      _rv_first="${_rv_first#"${_rv_first%%[![:space:]]*}"}"
      _rv_first="${_rv_first%"${_rv_first##*[![:space:]]}"}"
    fi
  done <<< "$files"
}

'''
# Whole-function boundaries are checked, never guessed line positions.
REVIEW_START = '# Свежий по коммит-истории: перебираем'
REVIEW_END = 'vcount=$(printf'
ADVERSE_START = '  # Свежий — по коммит-истории, тем же алгоритмом'
ADVERSE_END = '  _anorm='
REVIEW = '''_select_round_verdict "$vfiles" review
freshest="$_rv_file" freshest_cid="$_rv_cid" freshest_first="$_rv_first"
'''
ADVERSE = '''  _select_round_verdict "$_afiles" adversary
  afresh="$_rv_file" _afresh_cid="$_rv_cid" _afresh_first="$_rv_first"
'''
# Each link names an input where the changed operation is observably wrong.
MUTATIONS = {
    'st01-ancestry': (None, None, ['review-parallel', 'adversary-parallel']),
    'st02-mtime': ('key=$((version * 1000000000 + number))', 'key="$(stat -c %Y "$ROOT/$f")"', ['review-parallel', 'adversary-parallel']),
    'st03-first-file': ('key=$((version * 1000000000 + number))', 'key=1', ['review-parallel', 'adversary-parallel']),
    'st04-duplicate-allowed': ('*" $key "*) die "done: VERDICT_ROUND_DUPLICATE: $role: $key: $f" ;;', '*" $key "*) : ;;', ['review-duplicate', 'adversary-duplicate']),
    'st05-missing-default': ('die "done: VERDICT_ROUND_MISSING: $role: $f"', 'version=4 number=0', ['review-missing', 'adversary-missing']),
    'st06-metadata-ignored': ('[ "$call" = "$declared" ]', '[ -n "$declared" ]', ['review-conflict', 'adversary-conflict']),
    'st07-date-ignored': ('die "done: VERDICT_ROUND_ORDER: $role: $f"', ': # inverted date accepted', ['review-date-order', 'adversary-date-order']),
    'st08-object-bind-removed': ('( cd "$ROOT" && git merge-base --is-ancestor "$frozen_commit" "$object_sha" ) || bind_rc=$?', ': # old OBJECT accepted', ['review-old-object']),
    'st09-adverse-object-removed': ('[ "$_aobject" = "$object_sha" ] || die', 'true || die', ['adversary-other-object']),
    'st10-old-round': ('[ "$key" -gt "$best" ]', '{ [ "$best" -eq 0 ] || [ "$key" -lt "$best" ]; }', ['review-late-fail', 'adversary-late-fail']),
    'st11-no-frozen-bind': ('( cd "$ROOT" && git merge-base --is-ancestor "$frozen_commit" "$freshest_cid" ) || fresh_rc=$?', ': # stale accept accepted', ['regression-new-freeze']),
    'st12-first-call-only': ('call="${BASH_REMATCH[1]}" denominator="${BASH_REMATCH[3]}"', 'call="${BASH_REMATCH[1]}" denominator="${BASH_REMATCH[3]}" rest=""', ['review-second-conflict', 'adversary-second-conflict', 'review-repeat-call', 'adversary-repeat-call']),
    'st13-legacy-a-missing': ('elif [[ "$name" =~ -impl-a([1-9][0-9]*)\\.md$ ]]; then\n      version="${BASH_REMATCH[1]}" number=0 declared="$version"', 'elif [[ "$name" =~ -impl-a([1-9][0-9]*)\\.md$ ]]; then\n      die "done: VERDICT_ROUND_MISSING: $role: $f"', ['frozen201-risk-same-object']),
    'st14-version-is-call': ('version="${BASH_REMATCH[1]}" number="${BASH_REMATCH[2]}" explicit=1', 'version="${BASH_REMATCH[1]}" number=0 explicit=1', ['historic186']),
    'st15-ignore-phase': ('version="$phase_version" number="$call" declared="$call"', ': # phase namespace ignored', ['historic186']),
    'st16-ignore-phase-conflict': ('[ "$version" = "$phase_version" ]', 'true', ['historic186-phase-conflict']),
    'st17-phase-without-call': ('[ "${#phase_version}" -le 9 ] && [ -n "$call" ]', '[ "${#phase_version}" -le 9 ]', ['historic186-phase-no-call']),
    'st18-ignore-cycle': ('^реализация[^\\;]*круг\\ ', '^реализация[^\\;]*круг_\\ ', ['historic129']),
    'st19-malformed-suffix': ('elif [[ "$name" == *-impl-v*-vyzov*.md ]]; then', 'elif false; then', ['historic186-bad-call-name']),
    'st20-first-phase-only': ('[ -z "$phase_version" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"', '[ -z "$phase_version" ] || continue',
                            ['record-' + role + '-' + name for role in ('review', 'adversary')
                             for name in ('phase-v-second-conflict', 'phase-cycle-second-conflict',
                                          'phase-v-repeat', 'phase-cycle-repeat', 'phase-mixed',
                                          'phase-reverse-mixed', 'phase-three', 'call-before-phase',
                                          'phase-spaces')]),
    'st21-first-date-only': ('[ -z "$day" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"', '[ -z "$day" ] || continue',
                           ['record-' + role + '-' + name for role in ('review', 'adversary')
                            for name in ('date-second-conflict', 'date-repeat', 'date-three', 'date-spaces')]),
}


def replace_one(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('ANCHOR ' + repr(old) + ': ' + str(text.count(old)))
    return text.replace(old, new)


def region(text, start, end, replacement):
    a = text.index(start)
    b = text.index(end, a)
    return text[:a] + replacement + text[b:]


def main():
    baseline = subprocess.run(['git', '-C', str(REPO), 'show', BASE + ':scripts/done_contract.sh'], check=True, capture_output=True).stdout.decode()
    model = region(baseline, REVIEW_START, REVIEW_END, REVIEW)
    model = region(model, ADVERSE_START, ADVERSE_END, ADVERSE)
    model = replace_one(model, 'TARGET="${1:?', SELECTOR + 'TARGET="${1:?')
    # Bare NEXT_ID_LIB in baseline is only consumed by the sourced library.
    model = replace_one(model, 'NEXT_ID_LIB=1', 'export NEXT_ID_LIB=1')
    # Baseline diagnostics, unchanged by 224: dir/vmax/library flags, the old
    # ROOT pattern removal and the unquoted literal --stage done.
    model = replace_one(model, '#!/usr/bin/env bash\n',
                        '#!/usr/bin/env bash\n# shellcheck disable=SC2034,SC2295,SC1010\n')
    carriers = {'model/station.sh': baseline, 'model/done_contract.sh': model}
    links = []
    for name, (old, new, cases) in MUTATIONS.items():
        mutant = baseline if old is None else replace_one(model, old, new)
        rel = 'stabs/' + name + '/done_contract.sh'
        carriers[rel] = mutant
        links.extend({'stab': rel, 'case': case} for case in cases)
    for rel, text in carriers.items():
        path = HERE / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        path.chmod(0o755)
    manifest = {'base': BASE, 'kletki': len(CASES), 'mutacii': len(MUTATIONS), 'svjazi': len(links),
                'nositeli': {k: hashlib.sha256(v.encode()).hexdigest() for k, v in carriers.items()}, 'stab_vhod': links}
    (HERE / 'source.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print('NOSITELI', len(carriers), 'STABY', len(MUTATIONS), 'SVJAZI', len(links))


if __name__ == '__main__':
    main()
