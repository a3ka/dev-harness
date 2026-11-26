#!/usr/bin/env python3
"""226 reference overlay, not production. Generate immutable carriers and census."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '5b8ae0cdca9429d9d651c19d2775016e57ce271f'
FILES = ('scripts/profile_resolver.sh', 'scripts/check_architecture_contract.sh',
         'scripts/check_architecture_pin.sh', 'scripts/make_task.sh',
         'scripts/freeze_contract.sh', 'scripts/done_contract.sh',
         'fixtures/workshop_project/architecture_process_187/probe.py',
         'fixtures/workshop_project/architecture_steward_186/pin_probe.py')

PROFILE = '''# arch187_profile <repo>: validate before reading the repo-only policy.
arch187_profile() {
  ARCH187_PRODUCT_REPO=""
  ARCH187_REFUSAL=""
  local repo="$1" self value
  if [ ! -f "$repo/harness.project.json" ]; then
    if [ -f "$repo/architecture.lock.json" ]; then
      ARCH187_REFUSAL="ARCH_PROFILE_MISSING: harness.project.json"
      return 2
    fi
    return 0
  fi
  self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if ! HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$repo}" \\
      bash "$self/profile_resolver.sh" --repo "$repo" >/dev/null; then
    ARCH187_REFUSAL="ARCH_PROFILE: профиль проекта не прошёл resolver"
    return 2
  fi
  # shellcheck disable=SC1091
  PROFILE_RESOLVER_LIB=1 . "$self/profile_resolver.sh"
  value="$(profile_get "$repo" hooks.archBrief false)"
  [ "$value" = false ] && return 0
  ARCH187_PRODUCT_REPO="$value"
  return 0
}

arch187_scope() {
  ARCH187_SCOPE=0
  local repo="${1:-}"
  [ -n "$repo" ] && [ -d "$repo" ] || return 1
  arch187_profile "$repo" || return 2
  [ -n "$ARCH187_PRODUCT_REPO" ] || return 1
  [ -f "$repo/architecture.lock.json" ] || return 1
  ARCH187_SCOPE=1
  return 0
}'''

VALIDATE = '''# 226: repo-only hooks.archBrief. Unknown sibling names retain M-0 warnings.
if jq -e 'if (.defaults.hooks | type) == "object"
    then .defaults.hooks | (has("archBrief")) else false end' "$PROJECT_JSON_FD" >/dev/null; then
  die_p "ARCH_PROFILE_LAYER: hooks.archBrief: разрешён только репо-слой harness.project.json"
fi
if jq -e 'has("hooks")' "$REPO_JSON_FD" >/dev/null; then
  jq -e '.hooks | type == "object"' "$REPO_JSON_FD" >/dev/null \\
    || die_p "значение вне алфавита: hooks.archBrief: hooks не объект"
  if jq -e '.hooks | has("archBrief")' "$REPO_JSON_FD" >/dev/null; then
    jq -e '.hooks.archBrief | if . == false then true
      elif type == "string" then test("^[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*\\\\z")
      else false end' "$REPO_JSON_FD" >/dev/null \\
      || die_p "значение вне алфавита: hooks.archBrief: ожидается false или owner/repo"
  fi
fi

'''

PIN_READ = '''# 226: explicit pin command requires an enabled project policy; no ENV fallback.
_PIN_SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
ARCH187_LIB=1 . "$_PIN_SELF/check_architecture_contract.sh"
arch187_profile "$PRODUCT_ROOT" || { printf '%s\\n' "$ARCH187_REFUSAL" >&2; exit 1; }
[ -n "$ARCH187_PRODUCT_REPO" ] || { printf 'ARCH_PROFILE_REQUIRED: hooks.archBrief\\n' >&2; exit 1; }
PRODUCT_REPO="$ARCH187_PRODUCT_REPO"'''


def once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('ANCHOR ' + repr(old[:100]))
    return text.replace(old, new, 1)


def overlay(texts):
    path = 'scripts/profile_resolver.sh'
    text = texts[path]
    text = once(text, '  repo:pack:optional\n',
                '  repo:hooks:optional\n  repo:hooks:archBrief:optional\n  repo:pack:optional\n')
    text = once(text, 'sourceCanon pack"', 'sourceCanon pack hooks"')
    text = once(text, '# ── И-5: пин версии слоя проекта', VALIDATE + '# ── И-5: пин версии слоя проекта')
    # Only known keys enter merged; defaults deliberately cannot activate the gate.
    text = once(text, '    pack: (\n', '''    hooks: (
      if $r.hooks != null then {value: ($r.hooks | with_entries(select(.key == "archBrief"))), origin: "repo"}
      else null end
    ),
    pack: (
''')
    texts[path] = text
    path = 'scripts/check_architecture_contract.sh'
    text = texts[path]
    start = text.index('arch187_scope() {')
    end = text.index('\n}', start) + 2
    text = text[:start] + PROFILE + text[end:]
    text = once(text, 'if ! arch187_scope "$repo"; then\n', '''_scope_rc=0
arch187_scope "$repo" || _scope_rc=$?
if [ "$_scope_rc" -gt 1 ]; then
  printf '%s\\n' "$ARCH187_REFUSAL" >&2
  exit 1
fi
if [ "$_scope_rc" = 1 ]; then
''')
    texts[path] = text
    path = 'scripts/check_architecture_pin.sh'
    texts[path] = once(texts[path], 'PRODUCT_REPO="${PRODUCT_REPO:-a3ka/Complior-back}"', PIN_READ).replace('<корень-Complior-back>', '<корень-продукта>')
    path = 'scripts/make_task.sh'
    texts[path] = once(texts[path], '''  if arch187_scope "$REPO_ABS"; then
    _arch187_scope=1
  fi''', '''  _scope_rc=0
  arch187_scope "$REPO_ABS" || _scope_rc=$?
  [ "$_scope_rc" -le 1 ] || die "$ARCH187_REFUSAL"
  if [ "$_scope_rc" = 0 ]; then
    _arch187_scope=1
  fi''')
    for path in ('scripts/freeze_contract.sh', 'scripts/done_contract.sh'):
        texts[path] = once(texts[path], '  if arch187_scope "$ROOT"; then\n', '''  _scope_rc=0
  arch187_scope "$ROOT" || _scope_rc=$?
  [ "$_scope_rc" -le 1 ] || die "$ARCH187_REFUSAL"
  if [ "$_scope_rc" = 0 ]; then
''')
    path = 'fixtures/workshop_project/architecture_process_187/probe.py'
    texts[path] = once(texts[path], "    put(root, 'harness.project.json', json.dumps(profile))",
                       "    if kind == 'backend':\n        profile['hooks'] = {'archBrief': 'a3ka/Complior-back'}\n"
                       "    put(root, 'harness.project.json', json.dumps(profile))")
    path = 'fixtures/workshop_project/architecture_steward_186/pin_probe.py'
    texts[path] = once(texts[path], "    product_head = commit(product,",
                       '''    profile = {'schemaVersion': 1, 'repoId': 'Complior-back', 'language': 'javascript',
               'projectLayer': {'version': '1', 'profilePath': '.harness/project-layer.json'},
               'workflowPaths': {'contracts': '.harness/contracts', 'verdicts': '.harness/verdicts',
                                 'registry': '.harness/registry', 'fixtures': '.harness/fixtures'},
               'git': {'canonicalRemote': 'ssh://git@github.com/a3ka/Complior-back.git'},
               'commands': dict.fromkeys(['test', 'build', 'typecheck', 'lint'], 'true'),
               'ci': {'workflow': '.github/workflows/toy.yml'},
               'barriers': {'mandatory': [], 'optional': []},
               'hooks': {'archBrief': 'a3ka/Complior-back'}}
    for relative, content in {
        'harness.project.json': json.dumps(profile),
        '.harness/project-layer.json': json.dumps({'schemaVersion': 1, 'version': '1',
            'projectId': 'toy', 'workspaceId': 'toy', 'defaults': {}}),
        '.github/workflows/toy.yml': 'name: toy\\\\non: push\\\\njobs: {}\\\\n',
    }.items():
        path = product / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
    product_head = commit(product,''')
    # Old comments may describe the retired selector; no executable project literal remains.
    return texts


# Mutations are bound here to observable cells, never in contract prose.
MUTATIONS = {
 'st01-ignore-key': ('scripts/check_architecture_contract.sh',
                    '[ -n "$ARCH187_PRODUCT_REPO" ] || return 1', 'return 1', ['other-enabled']),
 'st02-name-selector': ('scripts/check_architecture_contract.sh',
                       '[ -n "$ARCH187_PRODUCT_REPO" ] || return 1',
                       '[ "$(jq -r .repoId "$repo/harness.project.json")" = "Complior-back" ] || return 1',
                       ['other-enabled', 'backend-absent']),
 'st03-absence-on': ('scripts/check_architecture_contract.sh',
                    '[ -n "$ARCH187_PRODUCT_REPO" ] || return 1', ':', ['other-absent']),
 'st04-false-on': ('scripts/check_architecture_contract.sh',
                  '[ "$value" = false ] && return 0', ':', ['explicit-false']),
 'st05-invalid-off': ('scripts/check_architecture_contract.sh',
                     '    return 2\n  fi\n  # shellcheck disable=SC1091',
                     '    return 0\n  fi\n  # shellcheck disable=SC1091', ['bad-door']),
 'st06-null-absent': ('scripts/profile_resolver.sh',
                     '.hooks | has("archBrief")', '.hooks.archBrief != null', ['bad-null']),
 'st07-zero-false': ('scripts/profile_resolver.sh',
                    'if . == false then true', 'if . == false or . == 0 then true', ['bad-zero']),
 'st08-string-false': ('scripts/profile_resolver.sh',
                      'if . == false then true', 'if . == false or . == "false" then true', ['bad-string-false']),
 'st09-substring': ('scripts/profile_resolver.sh',
                   'test("^[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*\\\\z")',
                   'test("[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*")',
                   ['bad-space', 'bad-nul', 'bad-newline']),
 'st10-lowercase-only': ('scripts/profile_resolver.sh',
                        '[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*',
                        '[a-z0-9][a-z0-9_.-]*/[a-z0-9][a-z0-9_.-]*', ['mixed-case']),
 'st11-length-cap': ('scripts/profile_resolver.sh',
                     'elif type == "string" then test(', 'elif type == "string" and length < 100 then test(', ['long-value']),
 'st12-pin-constant': ('scripts/check_architecture_pin.sh',
                      'PRODUCT_REPO="$ARCH187_PRODUCT_REPO"', 'PRODUCT_REPO="a3ka/Complior-back"', ['pin-other']),
 'st13-pin-env': ('scripts/check_architecture_pin.sh',
                 'PRODUCT_REPO="$ARCH187_PRODUCT_REPO"', 'PRODUCT_REPO="${PRODUCT_REPO:-$ARCH187_PRODUCT_REPO}"', ['pin-env']),
 'st14-pin-substring': ('scripts/check_architecture_pin.sh',
                       'PRODUCT_REPO="$ARCH187_PRODUCT_REPO"', 'PRODUCT_REPO="${ARCH187_PRODUCT_REPO,,}"', ['pin-case']),
 'st17-array-allowed': ('scripts/profile_resolver.sh',
                       'else false end\' "$REPO_JSON_FD"', 'else true end\' "$REPO_JSON_FD"', ['bad-array']),
 'st18-missing-profile-off': ('scripts/check_architecture_contract.sh',
                            '      return 2\n    fi\n    return 0',
                            '      return 0\n    fi\n    return 0', ['missing-profile-door']),
 'st19-wrong-layer-off': ('scripts/profile_resolver.sh',
                        '  die_p "ARCH_PROFILE_LAYER: hooks.archBrief: разрешён только репо-слой harness.project.json"',
                        '  : # wrong layer silently ignored',
                        ['layer-cannot-enable', 'layer-conflict', 'layer-false']),
 'st20-corrupt-profile-off': ('scripts/check_architecture_contract.sh',
                             '    return 2\n  fi\n  # shellcheck disable=SC1091',
                             '    return 0\n  fi\n  # shellcheck disable=SC1091',
                             ['malformed-profile-door', 'missing-layer-door', 'malformed-layer-door']),
 # The same jq branch as production profile_resolver.sh:960-963. The first
 # two replacements reproduce Adv226 Б-2 verbatim; each link observes only
 # the changed side of the grammar, not a combined invalid input.
 'st21-trailing-space': ('scripts/profile_resolver.sh',
                       r'[A-Za-z0-9_.-]*\\z', r'[A-Za-z0-9_.-]* ?\\z',
                       ['bad-trailing-space']),
 'st22-owner-initial-underscore': ('scripts/profile_resolver.sh',
                                 '^[A-Za-z0-9]', '^[A-Za-z0-9_]',
                                 ['bad-owner-underscore']),
 'st23-repo-initial-underscore': ('scripts/profile_resolver.sh',
                                '/[A-Za-z0-9]', '/[A-Za-z0-9_]',
                                ['bad-repo-underscore']),
 'st24-repo-initial-hyphen': ('scripts/profile_resolver.sh',
                            '/[A-Za-z0-9]', '/[A-Za-z0-9-]',
                            ['bad-repo-hyphen']),
 'st25-final-lf': ('scripts/profile_resolver.sh',
                  r'\\z', '$', ['bad-trailing-lf']),
 'st26-internal-space': ('scripts/profile_resolver.sh',
                        '[A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*',
                        '[A-Za-z0-9_. -]*/[A-Za-z0-9][A-Za-z0-9_. -]*',
                        ['bad-owner-internal-space', 'bad-repo-internal-space']),
}


# Arb226: mutations of the actual jq operations, with single-axis witnesses.
MUTATIONS.update({
 'st27-false-case-adv226b': ('scripts/profile_resolver.sh',
     'if . == false then true',
     'if . == false or . == "FALSE" or . == "False" then true',
     ['grid-false-case-31', 'grid-false-case-01']),
 'st28-boolean-type': ('scripts/profile_resolver.sh',
     'if . == false then true', 'if type == "boolean" then true', ['grid-type-true']),
 'st29-number-false': ('scripts/profile_resolver.sh',
     'if . == false then true', 'if . == false or type == "number" then true',
     ['grid-type-zero']),
 'st30-trim': ('scripts/profile_resolver.sh',
     '.hooks.archBrief | if . == false',
     r'.hooks.archBrief | if type == "string" then gsub("^\\s+|\\s+$"; "") else . end | if . == false',
     ['grid-boundary-before-sp', 'grid-boundary-after-sp']),
 'st31-owner-initial-dot': ('scripts/profile_resolver.sh',
     '^[A-Za-z0-9]', '^[A-Za-z0-9.]', ['grid-ascii-owner-first-046']),
 'st32-owner-initial-hyphen': ('scripts/profile_resolver.sh',
     '^[A-Za-z0-9]', '^[A-Za-z0-9-]', ['grid-ascii-owner-first-045']),
 'st33-repo-initial-dot': ('scripts/profile_resolver.sh',
     '/[A-Za-z0-9]', '/[A-Za-z0-9.]', ['grid-ascii-repo-first-046']),
 'st34-owner-inner-slash': ('scripts/profile_resolver.sh',
     '[A-Za-z0-9_.-]*/', '[A-Za-z0-9_./-]*/', ['grid-ascii-owner-middle-047']),
 'st35-repo-inner-slash': ('scripts/profile_resolver.sh',
     r'[A-Za-z0-9_.-]*\\z', r'[A-Za-z0-9_./-]*\\z', ['grid-ascii-repo-middle-047']),
 'st36-owner-empty': ('scripts/profile_resolver.sh',
     '^[A-Za-z0-9]', '^[A-Za-z0-9]?', ['grid-separator-02']),
 'st37-repo-empty': ('scripts/profile_resolver.sh',
     '/[A-Za-z0-9]', '/[A-Za-z0-9]?', ['grid-separator-03']),
 'st38-unicode-owner-first': ('scripts/profile_resolver.sh',
     '^[A-Za-z0-9]', r'^[\\p{L}\\d]', ['grid-unicode-owner-first-0', 'grid-unicode-owner-first-1']),
 'st39-unicode-repo-first': ('scripts/profile_resolver.sh',
     '/[A-Za-z0-9]', r'/[\\p{L}\\d]', ['grid-unicode-repo-first-0', 'grid-unicode-repo-first-1']),
 'st40-unicode-owner-rest': ('scripts/profile_resolver.sh',
     '[A-Za-z0-9_.-]*/', r'[\\p{L}\\d_.-]*/', ['grid-unicode-owner-rest-0', 'grid-unicode-owner-rest-1']),
 'st41-unicode-repo-rest': ('scripts/profile_resolver.sh',
     r'[A-Za-z0-9_.-]*\\z', r'[\\p{L}\\d_.-]*\\z', ['grid-unicode-repo-rest-0', 'grid-unicode-repo-rest-1']),
 'st42-length-1024': ('scripts/profile_resolver.sh',
     'elif type == "string" then test(',
     'elif type == "string" then (length <= 1024) and test(',
     ['grid-length-owner', 'grid-length-repo', 'grid-length-both']),
 'st43-merge-casefold': ('scripts/profile_resolver.sh',
     '($r.hooks | with_entries(select(.key == "archBrief")))',
     '($r.hooks | with_entries(select(.key == "archBrief")) | .archBrief |= if type == "string" then ascii_downcase else . end)',
     ['grid-separator-10']),
 'st44-start-anchor': ('scripts/profile_resolver.sh',
     'test("^[A-Za-z0-9]', 'test("[A-Za-z0-9]', ['grid-boundary-before-sp']),
})
for index, char in enumerate('false'):
    spelling = 'false'[:index] + char.upper() + 'false'[index + 1:]
    MUTATIONS[f'st{45 + index}-casefold-position-{index}'] = (
        'scripts/profile_resolver.sh', 'if . == false then true',
        f'if . == false or . == "{spelling}" then true',
        [f'grid-false-case-{1 << index:02d}'])


# Arb226b: control-flow mutations bind to public aliases, never extraction errors.
_GUARD = 'if jq -e \'.hooks | has("archBrief")\' "$REPO_JSON_FD" >/dev/null; then'
_OUTER = 'if jq -e \'has("hooks")\' "$REPO_JSON_FD" >/dev/null; then'
_REJECT = '|| die_p "значение вне алфавита: hooks.archBrief: ожидается false или owner/repo"'
_DIE = 'die_p() { printf \'profile ОТКАЗ: %s\\n\' "$*" >&2; exit 1; }'
MUTATIONS.update({
 'st50-guard-cr-adv226c': ('scripts/profile_resolver.sh', _GUARD,
     'if jq -e \'.hooks | has("archBrief") and ((.archBrief | type != "string") or (.archBrief | contains("\\r") | not))\' "$REPO_JSON_FD" >/dev/null; then',
     ['public-control-cr']),
 'st51-hooks-skip': ('scripts/profile_resolver.sh', _OUTER,
     'if false; then', ['public-control-null']),
 'st52-hooks-invert': ('scripts/profile_resolver.sh', _OUTER,
     'if ! jq -e \'has("hooks")\' "$REPO_JSON_FD" >/dev/null; then',
     ['public-control-null', 'public-hooks-absent']),
 'st53-hooks-shape-skip': ('scripts/profile_resolver.sh',
     '|| die_p "значение вне алфавита: hooks.archBrief: hooks не объект"',
     '|| :', ['public-hooks-null']),
 'st54-leaf-strings-only': ('scripts/profile_resolver.sh', _GUARD,
     'if jq -e \'.hooks | has("archBrief") and (.archBrief | type == "string")\' "$REPO_JSON_FD" >/dev/null; then',
     ['public-control-null']),
 'st55-leaf-skip': ('scripts/profile_resolver.sh', _GUARD,
     'if false; then', ['public-control-cr']),
 'st56-zero-instead-false': ('scripts/profile_resolver.sh',
     'if . == false then true', 'if . == 0 then true',
     ['public-control-zero', 'public-control-false']),
 'st57-string-check-skip': ('scripts/profile_resolver.sh',
     'elif type == "string" then test(', 'elif true then test(',
     ['public-control-null']),
 'st58-string-check-invert': ('scripts/profile_resolver.sh',
     'elif type == "string" then test(', 'elif type != "string" then test(',
     ['public-control-valid']),
 'st59-rejection-skip': ('scripts/profile_resolver.sh', _REJECT,
     '|| :', ['public-control-cr']),
 'st60-rejection-rc-zero': ('scripts/profile_resolver.sh', _DIE,
     _DIE.replace('exit 1', 'exit 0'), ['public-control-cr']),
 'st61-rejection-rc-two': ('scripts/profile_resolver.sh', _DIE,
     _DIE.replace('exit 1', 'exit 2'), ['public-control-cr']),
 'st62-rejection-no-reason': ('scripts/profile_resolver.sh', _REJECT,
     '|| die_p "неверный профиль"', ['public-control-cr']),
 'st63-rejection-stdout': ('scripts/profile_resolver.sh', _DIE,
     _DIE.replace(' >&2', ''), ['public-control-cr']),
})


def generate():
    texts = {p: subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':' + p],
                              check=True, capture_output=True, text=True).stdout for p in FILES}
    texts = overlay(texts)
    carriers = {}
    for p, text in texts.items():
        out = HERE / 'model' / p
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text)
        carriers[str(out.relative_to(HERE))] = hashlib.sha256(out.read_bytes()).hexdigest()
    bindings = {}
    for name, (path, old, new, cells) in MUTATIONS.items():
        out = HERE / 'stabs' / name / path
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(once(texts[path], old, new))
        carriers[str(out.relative_to(HERE))] = hashlib.sha256(out.read_bytes()).hexdigest()
        bindings[name] = {'path': path, 'cells': cells}
    import runpy
    public = runpy.run_path(str(HERE / 'probe.py'), run_name='catalog226')['public_source'](bindings)
    (HERE / 'source.json').write_text(json.dumps({'base': BASE, 'files': list(FILES),
        'carriers': carriers, 'bindings': bindings, 'public': public}, ensure_ascii=False, indent=2) + '\n')
    print('CARRIERS', len(carriers), 'STABY', len(bindings),
          'SVJAZI', sum(len(v['cells']) for v in bindings.values()))


if __name__ == '__main__':
    generate()
