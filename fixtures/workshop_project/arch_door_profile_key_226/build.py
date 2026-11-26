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
  [ -f "$repo/harness.project.json" ] || return 0
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
}


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
    (HERE / 'source.json').write_text(json.dumps({'base': BASE, 'files': list(FILES),
        'carriers': carriers, 'bindings': bindings}, ensure_ascii=False, indent=2) + '\n')
    print('CARRIERS', len(carriers), 'STABY', len(bindings),
          'SVJAZI', sum(len(v['cells']) for v in bindings.values()))


if __name__ == '__main__':
    generate()
