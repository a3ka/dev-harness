#!/usr/bin/env python3
"""Build fixture-only full CLI candidates from the named base, never production."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
sys.dont_write_bytecode = True
from catalog import BASE, MERGED, frozen, inventory

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DATA = json.loads((HERE / 'policy.json').read_bytes())


def original(path):
    return subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':' + path],
                          check=True, capture_output=True).stdout.decode()


def one(text, before, after):
    if text.count(before) != 1:
        raise RuntimeError('ANCHOR ' + repr(before) + ': ' + str(text.count(before)))
    return text.replace(before, after)


def put(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


RESOLVER = r'''
# 229: optional units read from the same already-open validated profile FDs.
_judge_self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
for _src in repo project; do
  if [ "$_src" = repo ]; then _file="$REPO_JSON_FD"; _prefix=''; else _file="$PROJECT_JSON_FD"; _prefix='defaults.'; fi
  jq -e "(.${_prefix}judges == null or (.${_prefix}judges | type) == \"object\")" "$_file" >/dev/null || die_p 'judges: object required'
  if jq -e ".${_prefix}judges | has(\"policy\")" "$_file" >/dev/null 2>&1; then
    _policy="$(jq -c ".${_prefix}judges.policy" "$_file")"
    printf '%s' "$_policy" | python3 "$_judge_self/judges_policy.py" validate >/dev/null || die_p 'judges.policy: POLICY_INVALID'
  fi
done
_judges="$(jq -nc --slurpfile r "$REPO_JSON_FD" --slurpfile p "$PROJECT_JSON_FD" '
  if ($r[0].judges // {} | has("policy")) then {"judges.policy":{value:$r[0].judges.policy,origin:"repo"}}
  elif ($p[0].defaults.judges // {} | has("policy")) then {"judges.policy":{value:$p[0].defaults.judges.policy,origin:"project"}}
  else {} end')"
MERGED="$(jq -nc --argjson old "$MERGED" --argjson judges "$_judges" '$old + $judges')"
# Hook shape belongs to 227; this additive control uses its argv-array seam.
_hook="$(jq -nc --slurpfile r "$REPO_JSON_FD" --slurpfile p "$PROJECT_JSON_FD" '
 if ($r[0].hooks // {} | has("judgeSetup")) then {"hooks.judgeSetup":{value:$r[0].hooks.judgeSetup,origin:"repo"}}
 elif ($p[0].defaults.hooks // {} | has("judgeSetup")) then {"hooks.judgeSetup":{value:$p[0].defaults.hooks.judgeSetup,origin:"project"}}
 else {} end')"
printf '%s' "$_hook" | jq -e 'all(.[]; (.value|type)=="array" and (.value|length)>0 and all(.value[]; type=="string" and (contains("\u0000")|not)))' >/dev/null || die_p 'hooks.judgeSetup: argv required'
MERGED="$(jq -nc --argjson old "$MERGED" --argjson hook "$_hook" '$old + $hook')"
'''

POLICY_START = r'''
# 229: malformed known policy fails closed before any lock/ledger mutation.
JUDGE_POLICY="$(python3 "$(dirname "${BASH_SOURCE[0]}")/judges_policy.py" resolve --repo "$REPO")" \
  || otp BITYJ_VHOD 'judges.policy: POLICY_INVALID'
'''

RETRY = r'''    if [ "$klass" = sudja ] && [ "$JUDGE_POLICY" != null ]; then
      retry_status="$(python3 "$(dirname "${BASH_SOURCE[0]}")/judges_policy.py" accounting \
        --repo "$REPO" --ledger "$LEDGER" --repo-id "$REPO_ID" --subject "$sv" --role "$rol" --object "$obj")" || {
          mutexi_snyat_vse; otp BITYJ_VHOD 'judges.policy accounting unavailable'; }
      if [ "$retry_status" = ARBITRATION_REQUIRED ] || [ "$retry_status" = BUDGET_EXHAUSTED ]; then
        mutexi_snyat_vse
        otp OBJECT_UZHE_SUZHEN "$retry_status repo=$REPO_ID subject=$sv role=$rol object=$obj"
      fi
      case "$retry_status" in
        ARBITRATION_REQUIRED\ *)
          mutexi_snyat_vse
          otp ARBITRATION_REQUIRED "${retry_status#* }"
          ;;
        BUDGET_EXHAUSTED\ *)
          mutexi_snyat_vse
          otp BUDGET_EXHAUSTED "${retry_status#* }"
          ;;
      esac
    fi
'''

ENV_CHECK = r'''      if [ "$first" = 'БЛОК-СРЕДЫ' ]; then
        [ "$JUDGE_POLICY" != null ] || continue
        printf '%s\n' "$blob" | grep -Eq '^СРЕДА-КОМАНДА: .+$' || continue
        printf '%s\n' "$blob" | grep -Eq '^СРЕДА-RC: ([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$' || continue
        return 3
      fi
'''

# Mutations target actual subject operations; every mapping is executable below.
MUTATIONS = {
    'env-counts-as-court': ('scripts/zamok_predmeta.sh',
        '$l.prichina == "obryv_bez_verdikta" or $l.prichina == "blok_sredy"',
        '$l.prichina == "obryv_bez_verdikta"', ['env-retry']),
    'env-is-interruption': ('scripts/zamok_predmeta.sh',
        "    elif [ \"$verdict_rc\" = 3 ]; then\n      prichina='blok_sredy'\n",
        "    elif [ \"$verdict_rc\" = 3 ]; then\n      prichina='obryv_bez_verdikta'\n", ['env-release']),
    'unlimited-retries': ('scripts/judges_policy.py',
        "if interruptions > value['interruptionRetries'] or environment > value['environmentRetries']:",
        'if False:', ['interruption-cap', 'environment-cap']),
    'one-not-two': ('scripts/judges_policy.py',
        "interruptions > value['interruptionRetries']", "interruptions >= value['interruptionRetries']",
        ['second-retry']),
    'ignore-scope': ('scripts/judges_policy.py',
        "if row.get('repoId') != repo_id or row.get('subjectId') != subject:",
        'if False:', ['foreign-scope']),
    'release-oldest': ('scripts/judges_policy.py',
        'for start in reversed(starts):', 'for start in starts:', ['reused-holder']),
    'skip-hook': ('scripts/judges_policy.py', 'if hook:', 'if False:', ['setup-hook']),
    'skip-object': ('scripts/judges_policy.py',
        "if git('rev-parse', 'HEAD') != args.object:", 'if False:', ['setup-wrong-object']),
    'skip-branch': ('scripts/judges_policy.py',
        "if git('symbolic-ref', '--short', 'HEAD') != f'wip/{args.subject}/{args.role}':", 'if False:', ['setup-wrong-branch']),
    'bad-is-missing': ('scripts/judges_policy.py',
        "return None if value is None else validate(value)",
        'return None', ['policy-causal']),
}
MUTATIONS['env-opens-reviewer'] = (
    'scripts/zamok_predmeta.sh', '      [ "$_judge_rc" = 3 ] && continue\n',
    '      :\n', ['env-not-adversary'])
MUTATIONS['ignore-exhaustion-action'] = (
    'scripts/judges_policy.py',
    "print('ARBITRATION_REQUIRED' if value['onExhaustion'] == 'arbiter' else 'BUDGET_EXHAUSTED')",
    "print('ARBITRATION_REQUIRED')", ['policy-stop-action'])
MUTATIONS.update({
    'remove-exhaustion-enum': (
        'config/judges-policy.json',
        '"onExhaustion": {\n        "enum": [\n          "arbiter",\n          "stop"\n        ]\n      }',
        '"onExhaustion": {}', ['policy-exhaustion-unknown', 'policy-exhaustion-padded']),
    'phase-counts-technical': (
        'scripts/judges_policy.py',
        "substantive = sum(s['state'] == 'verdikt_zakommiten' for s in phase)",
        'substantive = len(phase)', ['phase-critic-stop-interruption', 'phase-reviewer-arbiter-environment']),
    'phase-ignores-role': (
        'scripts/judges_policy.py',
        "s.get('rol') == role and (obj is None or s.get('object') == obj)",
        "(obj is None or s.get('object') == obj)",
        ['phase-critic-stop-other-role', 'phase-adversary-arbiter-other-role']),
    'phase-off-by-one': (
        'scripts/judges_policy.py', 'substantive + 1 > limit', 'substantive + 1 >= limit',
        ['phase-critic-stop-below', 'phase-reviewer-arbiter-below']),
    'phase-no-limit': (
        'scripts/judges_policy.py', 'if limit is not None and substantive + 1 > limit:',
        'if False:', ['phase-critic-stop-one', 'phase-adversary-arbiter-one']),
    'phase-stop-is-arbiter': (
        'scripts/judges_policy.py',
        "action = 'ARBITRATION_REQUIRED' if value['onExhaustion'] == 'arbiter' else 'BUDGET_EXHAUSTED'",
        "action = 'ARBITRATION_REQUIRED'", ['phase-critic-stop-one', 'phase-reviewer-stop-at']),
    'phase-arbiter-is-stop': (
        'scripts/judges_policy.py',
        "action = 'ARBITRATION_REQUIRED' if value['onExhaustion'] == 'arbiter' else 'BUDGET_EXHAUSTED'",
        "action = 'BUDGET_EXHAUSTED'", ['phase-adversary-arbiter-one', 'phase-reviewer-arbiter-at']),
    'phase-old-diagnosis': (
        'scripts/zamok_predmeta.sh',
        'otp BUDGET_EXHAUSTED "${retry_status#* }"',
        'otp OBJECT_UZHE_SUZHEN "${retry_status#* }"',
        ['phase-critic-stop-one', 'phase-adversary-stop-at']),
    'phase-resets-on-object': (
        'scripts/judges_policy.py',
        'phase = rounds(Path(args.ledger), args.repo_id, args.subject, args.role, None)',
        'phase = rounds(Path(args.ledger), args.repo_id, args.subject, args.role, args.object)',
        ['phase-critic-stop-other-object', 'phase-reviewer-arbiter-other-object']),
})
for _path, _rules in DATA['norms'].items():
    for _g, _line in _rules.items():
        _case = f'norm-{_g}-{Path(_path).stem}'
        MUTATIONS[_case] = (_path, _line + '\n', '', [_case])


def build():
    model = HERE / 'model'
    helper = (model / 'judges_policy.py').read_text()
    helper = one(helper, "    from jsonschema import Draft202012Validator\n",
                 "    if value == 'station':\n        value = load_config()['defaults']\n    from jsonschema import Draft202012Validator\n")
    put(model / 'scripts/judges_policy.py', helper)
    put(model / 'config/judges-policy.json', json.dumps(DATA, ensure_ascii=False, indent=2) + '\n')
    resolver = original('scripts/profile_resolver.sh')
    resolver = one(resolver, "  repo:pack:maxBytes:optional\n", "  repo:pack:maxBytes:optional\n  repo:judges:optional\n  repo:judges:policy:optional\n  project:defaults:judges:optional\n  project:defaults:judges:policy:optional\n  repo:hooks:optional\n  repo:hooks:judgeSetup:optional\n  project:defaults:hooks:optional\n  project:defaults:hooks:judgeSetup:optional\n")
    resolver = one(resolver, ' sourceCanon pack"', ' sourceCanon pack judges hooks"')
    resolver = one(resolver, '_BAD_KIND_ROW=', RESOLVER + '\n_BAD_KIND_ROW=')
    resolver = one(resolver, '_CW_PATH_TMP=$(mktemp)\n', r'''TMPDIR="${TMPDIR:-$REPO/tmp}"
mkdir -p -- "$TMPDIR" || die_p 'TMPDIR_UNWRITABLE'
export TMPDIR
_CW_PATH_TMP=$(mktemp) || die_p 'TMPDIR_UNWRITABLE'
''')
    put(model / 'scripts/profile_resolver.sh', resolver)
    lock = original('scripts/zamok_predmeta.sh')
    for code in MERGED:
        lock = re.sub(r'\botp ' + code + r'\b', 'otp BITYJ_VHOD', lock)
    lock = one(lock, 'ts_now() {', POLICY_START + '\nts_now() {')
    lock = one(lock, '$l.prichina == "obryv_bez_verdikta" then',
               '$l.prichina == "obryv_bez_verdikta" or $l.prichina == "blok_sredy" then')
    lock = one(lock, '    [ "$(stare_holder "$h")" = \'yield\' ] && return 0\n', r'''    if [ "$JUDGE_POLICY" != null ]; then
      _judge_obj="$(jq -rs --arg h "$h" --arg r "$REPO_ID" --arg n "$1" '[.[] | select(.t=="START" and .holder==$h and .repoId==$r and .subjectId==$n)] | last | .object' "$LEDGER")"
      verdict_sessii "$1" "$h" "$2" "$_judge_obj"; _judge_rc=$?
      [ "$_judge_rc" = 3 ] && continue
    fi
    [ "$(stare_holder "$h")" = 'yield' ] && return 0
''')
    lock = one(lock, '    # [D11 uzhe-suzhen] повторный круг', RETRY + '    # [D11 uzhe-suzhen] повторный круг')
    lock = one(lock, 'case "$first" in accept|FAIL)', 'case "$first" in accept|FAIL|БЛОК-СРЕДЫ)')
    lock = one(lock, '      return 0\n    done < <(git -C "$REPO" diff-tree',
               ENV_CHECK + '      return 0\n    done < <(git -C "$REPO" diff-tree')
    lock = one(lock, '    if verdict_sessii "$NNN_ARG" "$h_holder" "$h_rol" "$h_obj"; then\n',
               '    verdict_sessii "$NNN_ARG" "$h_holder" "$h_rol" "$h_obj"; verdict_rc=$?\n    if [ "$verdict_rc" = 0 ]; then\n')
    lock = one(lock, "      prichina='verdikt_zakommiten'\n    else\n", "      prichina='verdikt_zakommiten'\n    elif [ \"$verdict_rc\" = 3 ]; then\n      prichina='blok_sredy'\n    else\n")
    put(model / 'scripts/zamok_predmeta.sh', lock)
    pre = original('scripts/pre_judge.sh')
    pre = one(pre, 'set -uo pipefail\n', r'''set -uo pipefail
if [ "${1:-}" = setup ]; then
  shift
  exec python3 "$(dirname "${BASH_SOURCE[0]}")/judges_policy.py" setup "$@"
fi
''')
    put(model / 'scripts/pre_judge.sh', pre)
    # Static delivery cells prove the norm exists, not an LLM's compliance.
    for path, rules in DATA['norms'].items():
        put(model / path, '## Политика судей 229\n\n' + '\n'.join(rules.values()) + '\n')
    for name, (path, before, after, _) in MUTATIONS.items():
        put(HERE / 'stabs' / name / path, one((model / path).read_text(), before, after))
    carriers = [p for p in model.rglob('*') if p.is_file()] + [p for p in (HERE / 'stabs').rglob('*') if p.is_file()]
    manifest = {'base': BASE, 'frozen': frozen(), 'refusals': dict(inventory(original('scripts/zamok_predmeta.sh'))),
                'fates': {code: ('BITYJ_VHOD' if code in MERGED else code)
                          for code in inventory(original('scripts/zamok_predmeta.sh'))},
                'nositeli': {str(p.relative_to(HERE)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(carriers)},
                'stab_vhod': {name: values[3] for name, values in MUTATIONS.items()}}
    put(HERE / 'source.json', json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print('CARRIERS', len(carriers), 'STABS', len(MUTATIONS), 'LINKS', sum(len(v[3]) for v in MUTATIONS.values()))


if __name__ == '__main__':
    build()
