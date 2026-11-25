#!/usr/bin/env python3
"""224 carriers: ancestor canon + one round selector; addressed mutants (Н-39)."""
import hashlib
import json
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
BASE = '5fa6b2c294c2dfd677febb200c73dc27467461e6'
SELECTOR = r'''# 224: round numbers order verdicts; commit ancestry still binds OBJECT/F.
_select_round_verdict() {
  local files="$1" role="$2" f text cid number call field day name_day key
  local best=0 seen=' ' metadata='' prior_n prior_d
  _rv_file='' _rv_cid='' _rv_first=''
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="${f##*/}"
    if [[ "$name" =~ -v([1-9][0-9]*)(-[A-Za-z0-9._-]+)?\.md$ ]]; then
      number="${BASH_REMATCH[1]}"
    else
      die "done: VERDICT_ROUND_MISSING: $role: $f"
    fi
    # Bound arithmetic without accepting an overflowing or noncanonical number.
    [ "${#number}" -le 9 ] || die "done: VERDICT_ROUND_INVALID: $role: $f"
    case "$seen" in
      *" $number "*) die "done: VERDICT_ROUND_DUPLICATE: $role: $number: $f" ;;
    esac
    seen="$seen$number "
    text="$(git -C "$ROOT" cat-file -p "HEAD:$f")" \
      || die "done: VERDICT_ROUND_READ: $role: $f"
    text="${text//$'\r'/}"
    call='' day='' name_day=''
    if [[ "$name" =~ -([0-9]{4}-[0-9]{2}-[0-9]{2})(-|\.md$) ]]; then
      name_day="${BASH_REMATCH[1]}"
    fi
    while IFS= read -r field; do
      [[ "$field" == 'СУД: '* ]] || continue
      if [[ "$field" =~ (^|[\;\ ])вызов=([1-9][0-9]*)(/([1-9][0-9]*))?([\;\ ]|$) ]]; then
        [ -z "$call" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        call="${BASH_REMATCH[2]}"
      elif [[ "$field" == *'вызов='* ]]; then
        die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      fi
      if [[ "$field" =~ (^|[\;\ ])дата=([0-9]{4}-[0-9]{2}-[0-9]{2})([\;\ ]|$) ]]; then
        [ -z "$day" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        day="${BASH_REMATCH[2]}"
      elif [[ "$field" == *'дата='* ]]; then
        die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      fi
    done <<< "$text"
    [ -z "$call" ] || [ "$call" = "$number" ] \
      || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
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
        if { [ "$prior_n" -lt "$number" ] && [[ "$prior_d" > "$day" ]]; } \
          || { [ "$prior_n" -gt "$number" ] && [[ "$prior_d" < "$day" ]]; }; then
          die "done: VERDICT_ROUND_ORDER: $role: $f"
        fi
      done <<< "$metadata"
      metadata="${metadata}${number} ${day}"$'\n'
    fi
    cid="$(git -C "$ROOT" log --format=%H -1 -- "$f")" \
      || die "done: история вердикта не читается: $f — проверить невозможно"
    [ -n "$cid" ] || die "done: у вердикта на HEAD нет коммита в истории: $f — проверить невозможно"
    key="$number"
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
    'st02-mtime': ('key="$number"', 'key="$(stat -c %Y "$ROOT/$f")"', ['review-parallel', 'adversary-parallel']),
    'st03-first-file': ('key="$number"', 'key=1', ['review-parallel', 'adversary-parallel']),
    'st04-duplicate-allowed': ('*" $number "*) die "done: VERDICT_ROUND_DUPLICATE: $role: $number: $f" ;;', '*" $number "*) : ;;', ['review-duplicate', 'adversary-duplicate']),
    'st05-missing-default': ('die "done: VERDICT_ROUND_MISSING: $role: $f"', 'number=4', ['review-missing', 'adversary-missing']),
    'st06-metadata-ignored': ('[ "$call" = "$number" ]', '[ -n "$number" ]', ['review-conflict', 'adversary-conflict']),
    'st07-date-ignored': ('die "done: VERDICT_ROUND_ORDER: $role: $f"', ': # inverted date accepted', ['review-date-order', 'adversary-date-order']),
    'st08-object-bind-removed': ('( cd "$ROOT" && git merge-base --is-ancestor "$frozen_commit" "$object_sha" ) || bind_rc=$?', ': # old OBJECT accepted', ['review-old-object']),
    'st09-adverse-object-removed': ('[ "$_aobject" = "$object_sha" ] || die', 'true || die', ['adversary-other-object']),
    'st10-old-round': ('[ "$key" -gt "$best" ]', '{ [ "$best" -eq 0 ] || [ "$key" -lt "$best" ]; }', ['review-late-fail', 'adversary-late-fail']),
    'st11-no-frozen-bind': ('( cd "$ROOT" && git merge-base --is-ancestor "$frozen_commit" "$freshest_cid" ) || fresh_rc=$?', ': # stale accept accepted', ['regression-new-freeze']),
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
    manifest = {'base': BASE, 'nositeli': {k: hashlib.sha256(v.encode()).hexdigest() for k, v in carriers.items()}, 'stab_vhod': links}
    (HERE / 'source.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print('NOSITELI', len(carriers), 'STABY', len(MUTATIONS), 'SVJAZI', len(links))


if __name__ == '__main__':
    main()
