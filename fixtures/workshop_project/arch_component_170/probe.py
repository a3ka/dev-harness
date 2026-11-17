#!/usr/bin/env python3
"""170: public make_task boundary, honest control and branch-specific mutants.

Cells are fitted to the REAL accepted 187a door (main: scripts/make_task.sh +
scripts/check_architecture_contract.sh):
- missing --arch-component refusal: code subject AND local R/architecture/
  directory (any project); lock file does not decide applicability;
- brief source: pinned scope (repoId=Complior-back AND architecture.lock.json)
  reads `node tooling/checks/cli.js brief --compact [--with-rules] --component`
  inside the extracted pinned tree; outside the scope the legacy
  `npm --prefix R/architecture run brief -- --compact ...` path survives;
- pin refusals are named ARCH_PIN (real door grammar: any revision resolving
  to a commit in the clone; commit:"HEAD" resolves to the clone HEAD —
  cell symbolic_pin fixes this real behaviour);
- a code subject in pinned scope is judged by the 187a line/zones BEFORE the
  flag question (cell empty_lock_required).
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
TOY = ROOT / 'fixtures/context_pack_095/_toy.sh'
VERIFY = Path('/tmp/dev-harness-verify')
BASE = 'frozen/contracts/166/2:scripts/make_task.sh'
IDS = ('api.identity', 'worker.events')  # architecture/README.md and checks/test/workflow-v242.test.js
RULE_ROLES = ('architect', 'critic', 'arbiter')
PLAIN_ROLES = ('implementer', 'adversary', 'reviewer')
MODEL_BODY = r'''ARCH_SEC=""
if [ "$KIND" = task ]; then
  _arch_repo="$(printf '%s' "$MERGED" | jq -r .repoId.value)"
  _arch_dir="$REPO/architecture"
  _arch_code=0
  if printf '%s\n' "$CBYTES" | grep -Eq '(^|[[:punct:]])[[:space:]]*КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'; then _arch_code=1; fi
  _arch_scope=0
  if [ "$_arch_repo" = Complior-back ] && [ -f "$REPO/architecture.lock.json" ]; then _arch_scope=1; fi
  _arch_root=""
  _arch_pin=""
  _arch_model=""
  _arch_pin_read() {
    _arch_root="${ARCHITECTURE_ROOT:-}"
    if [ -z "$_arch_root" ]; then die "ARCH_PIN: закреплённый клон модели не задан (ARCHITECTURE_ROOT)"; fi
    [ -d "$_arch_root" ] || die "ARCH_PIN: клон модели не найден: $_arch_root"
    _arch_pin="$(jq -r '.commit // empty' "$REPO/architecture.lock.json" 2>/dev/null || true)"
    [ -n "$_arch_pin" ] || die "ARCH_PIN: в architecture.lock.json нет закреплённого коммита"
    git -C "$_arch_root" cat-file -e "${_arch_pin}^{commit}" 2>/dev/null || die "ARCH_PIN: коммит $_arch_pin не разрешается в клоне модели: $_arch_root"
  }
  _arch_model_tree() {
    _arch_model="$(mktemp -d)"
    git -C "$_arch_root" archive "$_arch_pin" | tar -x -C "$_arch_model" || die "ARCH_PIN: дерево закреплённого коммита $_arch_pin не развернуть"
    [ -f "$_arch_model/tooling/checks/cli.js" ] || die "ARCH_PIN: в закреплённом дереве нет tooling/checks/cli.js"
  }
  if [ "$_arch_code" = 1 ] && [ "$_arch_scope" = 1 ]; then
    # Witness of frozen 187а on the same input: the 170 world must satisfy 187а
    # (АРХИТЕКТУРА line, zones via locate of the pinned model) before the flag question.
    _arch_task="$CBYTES"
    [ -z "$TASKFILE" ] || _arch_task="$(cat "$TASKFILE")"
    _arch_line="$(printf '%s\n' "$_arch_task" | grep -m1 -E '^[[:space:]]*АРХИТЕКТУРА:' || true)"
    _arch_rest="$(printf '%s' "$_arch_line" | tr '\t' ' ' | sed -e 's/^[[:space:]]*АРХИТЕКТУРА:[[:space:]]*//' -e 's/[[:space:]]*$//')"
    _arch_lvl="${_arch_rest%% *}"
    case "$_arch_lvl" in
      L1|L2) ;;
      L3) die "ARCH_OWNER: уровень L3 требует решения владельца: $_arch_line" ;;
      *) die "ARCH_LINE_MISSING: грамматика строки «АРХИТЕКТУРА:» — уровень L1|L2|L3 и список id" ;;
    esac
    _arch_ids="${_arch_rest#"$_arch_lvl" }"
    printf '%s\n' "$_arch_ids" | grep -Eqx '[A-Za-z0-9_][A-Za-z0-9._-]*(,[A-Za-z0-9_][A-Za-z0-9._-]*)*' || die "ARCH_LINE_MISSING: неконформный список id строки «АРХИТЕКТУРА:»"
    [ -z "$(printf '%s\n' "$_arch_ids" | tr ',' '\n' | sort | uniq -d)" ] || die "ARCH_LINE_MISSING: дубль id компонента"
    _arch_pin_read
    _arch_model_tree
    for _arch_path in $(printf '%s\n' "$_arch_task" | sed -n 's/^ЗОНА implementer://p'); do
      _arch_where="$(cd "$_arch_model" && node tooling/checks/cli.js locate --path "$_arch_path" 2>/dev/null)" || die "PATH_WITHOUT_COMPONENT: $_arch_path"
      _arch_comps="$(printf '%s' "$_arch_where" | jq -r 'if (type == "object") and ((.matches | type) == "array") then ([.matches[].components[]?] | unique | join(" ")) else "" end')"
      [ -n "$_arch_comps" ] || die "PATH_WITHOUT_COMPONENT: $_arch_path"
      for _arch_c in $_arch_comps; do
        printf '%s\n' "$_arch_ids" | tr ',' '\n' | grep -Fxq "$_arch_c" || die "ARCH_ZONE: путь $_arch_path отнесён моделью к компоненту $_arch_c, а строка «АРХИТЕКТУРА:» называет $_arch_ids"
      done
    done
  fi
  if [ -n "$ARCH_COMPONENT" ]; then
    if [ "$_arch_scope" = "1" ]; then
      _arch_pin_read
      _arch_model_tree
    else
      [ -d "$_arch_dir" ] || die "ARCHITECTURE_NET: нет каталога architecture/ в проекте: $_arch_dir"
    fi
    case "$ARCH_COMPONENT" in ''|,*|*,|*,,*) die "ARCH_COMPONENT_ID: непустой список id через запятую: $ARCH_COMPONENT" ;; esac
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      case "$_arch_id" in ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id: $_arch_id" ;; esac
    done
    _arch_err="$(mktemp 2>/dev/null || true)"
    [ -n "$_arch_err" ] && [ -f "$_arch_err" ] || _arch_err=/dev/null
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      _arch_rules=""
      case "$ROLE" in architect|critic|arbiter) _arch_rules="--with-rules" ;; esac
      if [ "$_arch_scope" = "1" ]; then
        if [ -n "$_arch_rules" ]; then
          _arch_text="$(cd "$_arch_model" && node tooling/checks/cli.js brief --compact --with-rules --component "$_arch_id" 2>/dev/null)" || die "ARCH_BRIEF_OTKAZ: $_arch_id (закреплённая модель не отдала бриф)"
        else
          _arch_text="$(cd "$_arch_model" && node tooling/checks/cli.js brief --compact --component "$_arch_id" 2>/dev/null)" || die "ARCH_BRIEF_OTKAZ: $_arch_id (закреплённая модель не отдала бриф)"
        fi
      else
        _arch_rc=0
        if [ -n "$_arch_rules" ]; then
          _arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --with-rules --component "$_arch_id" 2>"$_arch_err")" || _arch_rc=$?
        else
          _arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --component "$_arch_id" 2>"$_arch_err")" || _arch_rc=$?
        fi
        if [ "$_arch_rc" -ne 0 ]; then
          _arch_hint="$(awk 'NR==1 { gsub(/[\r\n\t]/, " "); print substr($0, 1, 200) }' "$_arch_err" 2>/dev/null || true)"
          if [ -n "$_arch_hint" ]; then die "ARCH_BRIEF_OTKAZ: $_arch_id (npm rc=$_arch_rc): $_arch_hint"; fi
          die "ARCH_BRIEF_OTKAZ: $_arch_id (npm rc=$_arch_rc)"
        fi
      fi
      [ -n "$_arch_text" ] || die "ARCH_BRIEF_OTKAZ: пустой бриф компонента: $_arch_id"
      ARCH_SEC="${ARCH_SEC}COMPONENT: $_arch_id
${_arch_text}
"
    done
  elif [ -d "$_arch_dir" ] && [ "$_arch_code" = "1" ]; then
    die "ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)"
  fi
fi
'''


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise ValueError(f'model anchor count {text.count(old)}: {old[:90]}')
    return text.replace(old, new, 1)


def model_text():
    text = subprocess.run(['git', '-C', str(ROOT), 'show', BASE],
                          capture_output=True, text=True, check=True).stdout
    text = replace_once(text, 'PRINT_CONTEXT=0\nwhile [ $# -gt 0 ]; do',
                        'PRINT_CONTEXT=0; ARCH_COMPONENT=""\nwhile [ $# -gt 0 ]; do')
    text = replace_once(text, '    --print-context) PRINT_CONTEXT=1; shift ;;',
                        '    --print-context) PRINT_CONTEXT=1; shift ;;\n'
                        '    --arch-component) ARCH_COMPONENT="${2:-}"; shift 2 ;;')
    text = replace_once(text, 'TRACE_MAN="trace${TAB}', MODEL_BODY + '\nTRACE_MAN="trace${TAB}')
    text = replace_once(text, "  printf '=== REUSE ===\\n%s' \"$REUSE_LINES\"",
                        "  printf '=== REUSE ===\\n%s' \"$REUSE_LINES\"\n"
                        "  [ -z \"$ARCH_SEC\" ] || printf '=== ARCHITECTURE BRIEF ===\\n%s' \"$ARCH_SEC\"")
    return text


# Frozen 187a (frozen/contracts/187/1) requires this standalone line in a backend code task;
# the IDs cover every --arch-component ID the battery passes.
ARCH_LINE = 'АРХИТЕКТУРА: L1 api.identity,worker.events'
# Pinned model CLI: the 187a door calls locate and brief DIRECTLY inside the
# extracted pinned tree (`node tooling/checks/cli.js ...`), not through npm.
# The brief revision is read from the tree the CLI itself lives in, so a door
# that reads the clone HEAD instead of the pin answers WRONG-HEAD-170.
MODEL_CLI = r'''const a = process.argv.slice(2);
const fs = require('fs');
const path = require('path');
if (process.env.ARCH170_CALLS) {
  fs.appendFileSync(process.env.ARCH170_CALLS, 'cli ' + (a[0] || '') + '\n');
}
const revision = fs.readFileSync(path.join(__dirname, '..', '..', 'brief-revision'), 'utf8').trim();
if (a[0] === 'locate' && a[1] === '--path' && a.length === 3) {
  const declared = a[2] === 'scripts/' || a[2].startsWith('scripts/');
  console.log(JSON.stringify({
    scope: 'product', path: a[2], status: declared ? 'DECLARED' : 'UNRESOLVED',
    matches: declared ? [{module: 'scripts', components: ['api.identity'],
      specification: 'toy', explicit: true, matched: 'zone'}] : [],
    components: declared ? ['api.identity'] : [], implementationEvidence: []
  }));
  process.exit(0);
}
let rules = false;
let component = null;
if (a[0] === 'brief' && a[1] === '--compact' && a[2] === '--with-rules'
    && a[3] === '--component' && a.length === 5) {
  rules = true; component = a[4];
} else if (a[0] === 'brief' && a[1] === '--compact' && a[2] === '--component'
    && a.length === 4) {
  component = a[3];
} else {
  console.error('cli.js: unsupported brief argv'); process.exit(41);
}
if (component !== 'api.identity' && component !== 'worker.events') {
  console.error('UNKNOWN_COMPONENT'); process.exit(42);
}
if (process.env.ARCH170_FAIL_ID === component) {
  console.error('cli notice: brief command failed'); process.exit(17);
}
console.log('REVISION:' + revision);
console.log('# ARCH-BRIEF:' + component);
console.log('OWN-CONTRACT:' + component + ':' + process.env.ARCH170_NONCE);
if (process.env.ARCH170_PADDING) {
  console.log('ARCH-BRIEF-PADDING:' + 'X'.repeat(parseInt(process.env.ARCH170_PADDING, 10)));
}
if (rules) { console.log('FITNESS-RULE-FOR:' + component); }
process.exit(0);
'''


def model_tree(directory, revision):
    (directory / 'tooling/checks').mkdir(parents=True, exist_ok=True)
    (directory / 'package.json').write_text('{"scripts":{"brief":"node tooling/checks/cli.js brief"}}\n')
    (directory / 'tooling/checks/cli.js').write_text(MODEL_CLI)
    (directory / 'brief-revision').write_text(revision + '\n')


def world(*, lock='pin', code=True, class_line=None, local_copy=False):
    built = subprocess.run(['bash', '-c', '. "$1"; _t95_world arch-170', '_', str(TOY)],
                           capture_output=True, text=True, check=True).stdout.strip()
    repo = Path(built) / 'repo'
    profile = repo / 'harness.project.json'
    data = json.loads(profile.read_text())
    data['repoId'] = 'Complior-back'
    data['contextPack']['rows'].append({
        'kind': 'map', 'path': 'STRUCTURE.md',
        'roles': 'orchestrator,architect,critic,arbiter,implementer,adversary,reviewer',
        'mandatory': True, 'why': 'all modules'})
    data['contextPack']['rows'].append({
        'kind': 'rules', 'path': 'COMMON-RULES.md',
        'roles': 'orchestrator,architect,critic,arbiter,implementer,adversary,reviewer',
        'mandatory': True, 'why': 'project-wide rules'})
    profile.write_text(json.dumps(data, ensure_ascii=False))
    (repo / 'STRUCTURE.md').write_text('# Project structure\n')
    (repo / 'COMMON-RULES.md').write_text('# Project-wide rules\n')
    contract = repo / 'contracts/777-toy.md'
    contract.write_text((class_line if class_line is not None else
                         'КЛАСС ЗАДАЧИ: ' + ('кодовый' if code else 'документальный'))
                        + '\n' + ARCH_LINE + '\n' + contract.read_text())
    (repo / 'registry/trace.tsv').write_text(''.join(
        f'{role}\topenai-codex/gpt-6-sol\tallowed\n' for role in ('orchestrator',) + RULE_ROLES + PLAIN_ROLES))
    model = Path(built) / 'CompliorOS-architecture'
    model.mkdir()
    subprocess.run(['git', '-C', str(model), 'init', '-q'], check=True)
    model_tree(model, 'PINNED-170')
    subprocess.run(['git', '-C', str(model), 'add', '.'], check=True)
    subprocess.run(['git', '-C', str(model), '-c', 'user.name=Fixture',
                    '-c', 'user.email=fixture@local', 'commit', '-qm', 'published architecture'], check=True)
    pin = subprocess.run(['git', '-C', str(model), 'rev-parse', 'HEAD'],
                         capture_output=True, text=True, check=True).stdout.strip()
    (model / 'brief-revision').write_text('WRONG-HEAD-170\n')
    subprocess.run(['git', '-C', str(model), 'add', '.'], check=True)
    subprocess.run(['git', '-C', str(model), '-c', 'user.name=Fixture',
                    '-c', 'user.email=fixture@local', 'commit', '-qm', 'later head'], check=True)
    lock_text = {'pin': json.dumps({'commit': pin, 'workItem': 'COMPLIOR-777'}),
                 'zero': json.dumps({'commit': '0' * 40, 'workItem': 'COMPLIOR-777'}),
                 'symbolic': json.dumps({'commit': 'HEAD', 'workItem': 'COMPLIOR-777'}),
                 'no_commit': json.dumps({'workItem': 'COMPLIOR-777'}),
                 'empty': ''}
    if lock is not None:
        (repo / 'architecture.lock.json').write_text(lock_text[lock])
    if local_copy:
        model_tree(repo / 'architecture', 'WRONG-LOCAL-170')
    subprocess.run(['git', '-C', str(repo), 'add', '.'], check=True, capture_output=True)
    subprocess.run(['git', '-C', str(repo), 'commit', '-qm', 'toy context'], check=True)
    subprocess.run(['git', '-C', str(repo), 'tag', 'frozen/contracts/777/1'], check=True)
    return Path(built), repo, model


def invoke(subject, repo, role, component=None, *, kind='task', env=None):
    argv = ['bash', str(subject), '--repo', str(repo), '--role', role,
            '--kind', kind, '--contract', '777', '--model-trace', str(repo / 'registry/trace.tsv')]
    if role == 'reviewer' and kind == 'task':
        argv += ['--task-file', str(repo / 'contracts/777-toy.md')]
    if component is not None:
        argv += ['--arch-component', component]
    return subprocess.run(argv, capture_output=True, text=True, timeout=40, env=env)


CLASS_LINES = {
    'class_dot': 'КЛАСС ЗАДАЧИ: кодовый.',
    'class_parens': 'КЛАСС ЗАДАЧИ: КОДОВЫЙ (реализация)',
    'class_semicolon': 'КЛАСС ЗАДАЧИ: КОДОВЫЙ; один вертикальный слайс',
    'class_risk_tail': 'КЛАСС ЗАДАЧИ: кодовый. КЛАСС РИСКА: обычный',
    'class_upper_c': 'КЛАСС ЗАДАЧИ: КОДОВЫЙ',
}


def section(text, title):
    marker = f'=== {title} ===\n'
    if text.count(marker) != 1:
        return []
    return text.split(marker, 1)[1].split('=== ', 1)[0].splitlines()


NO_LOCK = ('legacy', 'architecture_missing', 'architecture_missing_required', 'local_without_lock')
LOCK_OF = {'invalid_pin': 'zero', 'empty_lock': 'empty', 'empty_lock_required': 'empty',
           'lock_without_commit': 'no_commit', 'symbolic_pin': 'symbolic'}
OTHER_PROJECT = ('wrong_project',)
# Real door: the missing-flag refusal needs the local architecture/ directory.
NEEDS_LOCAL_DIR = ('required', 'wrong_project', 'architecture_missing_required',
                   'local_wrong', 'local_without_lock')
NO_COMMIT = 'ОТКАЗ: ARCH_PIN: в architecture.lock.json нет закреплённого коммита'
PIN_TAIL = {'architecture_missing': 'ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/',
            'local_without_lock': 'ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (npm rc=',
            'empty_lock': NO_COMMIT, 'lock_without_commit': NO_COMMIT,
            'empty_lock_required': NO_COMMIT, 'invalid_pin': 'ОТКАЗ: ARCH_PIN: коммит',
            'model_root_unset': 'ОТКАЗ: ARCH_PIN: закреплённый клон модели не задан'}
PIN_REFUSALS = tuple(PIN_TAIL)
# local_without_lock walks the REAL legacy fallback (npm from the local copy):
# one npm call is the door's behaviour there, not a defect.
NO_BRIEF_CALL = tuple(key for key in PIN_REFUSALS if key != 'local_without_lock') \
    + ('malformed_id', 'second_malformed_id')


def run_case(name, subject):
    role = {'brief_kind': 'orchestrator', 'critic_rules': 'critic', 'arbiter_rules': 'arbiter',
            'implementer_plain': 'implementer', 'adversary_plain': 'adversary',
            'reviewer_plain': 'reviewer', 'implementer_brief_failure': 'implementer',
            'adversary_brief_failure': 'adversary',
            'reviewer_brief_failure': 'reviewer'}.get(name, 'architect')
    lock = None if name in NO_LOCK else LOCK_OF.get(name, 'pin')
    code = name != 'document'
    component = ('api.identity,worker.events' if name in
                 ('multi_component', 'brief_failure', 'implementer_brief_failure',
                  'adversary_brief_failure', 'reviewer_brief_failure') else
                 'api.identity,../x' if name == 'second_malformed_id' else
                 '../escape' if name == 'malformed_id' else
                 'api.identity' if name in ('architect_rules', 'critic_rules', 'arbiter_rules',
                    'implementer_plain', 'adversary_plain', 'reviewer_plain', 'local_wrong',
                    'brief_over_budget', 'symbolic_pin') + PIN_REFUSALS else None)
    local = name in NEEDS_LOCAL_DIR or name in CLASS_LINES
    built, repo, model = world(lock=lock, code=code, class_line=CLASS_LINES.get(name),
                               local_copy=local)
    try:
        expected_ids = IDS if name == 'multi_component' else IDS[:1]
        nonce = 'SENTINEL-170-' + name
        # Independent in-memory oracle, constructed before invoking subject.
        expected = [(f'# ARCH-BRIEF:{ident}', f'OWN-CONTRACT:{ident}:{nonce}',
                     f'FITNESS-RULE-FOR:{ident}') for ident in expected_ids]
        with tempfile.TemporaryDirectory(dir=VERIFY, prefix='arch170-bin-') as bin_dir:
            os.symlink(HERE / 'npm_stub.py', Path(bin_dir) / 'npm')
            calls = Path(bin_dir) / 'calls'
            env = dict(os.environ, ARCH170_NONCE=nonce,
                       ARCH170_CALLS=str(calls), ARCHITECTURE_ROOT=str(model),
                       PATH=bin_dir + os.pathsep + os.environ['PATH'])
            if name == 'class_upper_c':
                env['LC_ALL'] = 'C'
            if name in ('brief_failure', 'implementer_brief_failure',
                        'adversary_brief_failure', 'reviewer_brief_failure'):
                env['ARCH170_FAIL_ID'] = 'worker.events'
            if name == 'brief_over_budget':
                env['ARCH170_PADDING'] = '41000'
            if name == 'model_root_unset':
                del env['ARCHITECTURE_ROOT']
            if name in OTHER_PROJECT:
                # Project identity alone must not decide applicability of the door:
                # with a local architecture/ the requirement stays.
                profile = repo / 'harness.project.json'
                data = json.loads(profile.read_text())
                data['repoId'] = 'another-project'
                profile.write_text(json.dumps(data))
            result = invoke(subject, repo, role, component, kind='brief' if name == 'brief_kind' else 'task', env=env)
            call_lines = calls.read_text().splitlines() if calls.exists() else []
        brief_calls = sum(1 for line in call_lines if line in ('npm', 'cli brief'))
        map_lines = section(result.stdout, 'MAP')
        rule_lines = section(result.stdout, 'RULES')
        brief_lines = section(result.stdout, 'ARCHITECTURE BRIEF')
        manifest = section(result.stdout, 'MANIFEST')
        reject = {**{key: 'ARCH_PIN' for key in PIN_REFUSALS},
                  'required': 'ARCH_COMPONENT_NET', 'wrong_project': 'ARCH_COMPONENT_NET',
                  'architecture_missing_required': 'ARCH_COMPONENT_NET',
                  **{key: 'ARCH_COMPONENT_NET' for key in CLASS_LINES},
                  'malformed_id': 'ARCH_COMPONENT_ID', 'second_malformed_id': 'ARCH_COMPONENT_ID',
                  'architecture_missing': 'ARCHITECTURE_NET',
                  'local_without_lock': 'ARCH_BRIEF_OTKAZ',
                  'brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'implementer_brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'adversary_brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'reviewer_brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'brief_over_budget': 'режь задачу'}.get(name)
        if name == 'symbolic_pin':
            # Real door: commit:"HEAD" resolves to the CLONE HEAD, the brief is
            # served from that tree (REVISION:WRONG-HEAD-170) — no 40-hex grammar.
            good = (result.returncode == 0 and 'MAP: STRUCTURE.md :: all modules' in map_lines
                    and 'RULES: COMMON-RULES.md' in rule_lines
                    and 'map\tSTRUCTURE.md\tmandatory\tprofile' in manifest
                    and 'rules\tCOMMON-RULES.md\tmandatory\tprofile' in manifest)
            good &= brief_lines.count('REVISION:WRONG-HEAD-170') == 1
            good &= 'REVISION:PINNED-170' not in brief_lines
            good &= brief_lines.count('# ARCH-BRIEF:api.identity') == 1
            good &= f'OWN-CONTRACT:api.identity:{nonce}' in brief_lines
        elif reject:
            first = (result.stderr.splitlines() or [''])[0]
            good = result.returncode == 1 and not result.stdout and first.startswith('ОТКАЗ: ' + reject + ':')
            if name in PIN_TAIL:
                good &= first.startswith(PIN_TAIL[name])
            if name in NO_BRIEF_CALL:
                good &= brief_calls == 0
            if name in ('brief_failure', 'implementer_brief_failure',
                        'adversary_brief_failure', 'reviewer_brief_failure'):
                good &= first.startswith('ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events')
            if name == 'brief_over_budget':
                good &= '> 40000' in result.stderr
        else:
            good = (result.returncode == 0 and 'MAP: STRUCTURE.md :: all modules' in map_lines
                    and 'RULES: COMMON-RULES.md' in rule_lines
                    and 'map\tSTRUCTURE.md\tmandatory\tprofile' in manifest
                    and 'rules\tCOMMON-RULES.md\tmandatory\tprofile' in manifest)
            if component:
                actual_briefs = [line for line in brief_lines if line.startswith('# ARCH-BRIEF:')]
                good &= brief_lines.count('REVISION:PINNED-170') == len(expected_ids)
                good &= 'WRONG-HEAD-170' not in brief_lines and 'WRONG-LOCAL-170' not in brief_lines
                good &= actual_briefs == [row[0] for row in expected]
                for title, own, fitness in expected:
                    good &= brief_lines.count(title) == 1 and brief_lines.count(own) == 1
                    good &= (brief_lines.count(fitness) == 1) if role in RULE_ROLES else fitness not in brief_lines
            else:
                good &= not any(line.startswith('# ARCH-BRIEF:') for line in brief_lines)
                good &= 'REVISION:PINNED-170' not in brief_lines
        calls_detail = f' brief_calls={brief_calls}' if name in NO_BRIEF_CALL else ''
        print(f'170 {name} {"ok" if good else "KRASNO"} rc={result.returncode} '
              f'stderr={result.stderr.strip()!r}{calls_detail}', flush=True)
        return bool(good)
    finally:
        shutil.rmtree(built)


CASES = ('required', 'legacy', 'document', 'brief_kind', 'lock_without_dir',
         'architect_rules', 'critic_rules', 'arbiter_rules',
         'implementer_plain', 'adversary_plain', 'reviewer_plain',
         'multi_component', 'wrong_project', 'malformed_id',
         'architecture_missing', 'architecture_missing_required', 'invalid_pin',
         'local_wrong', 'local_without_lock',
         'empty_lock', 'lock_without_commit', 'empty_lock_required', 'symbolic_pin',
         'model_root_unset',
         'brief_failure', 'implementer_brief_failure',
         'adversary_brief_failure', 'reviewer_brief_failure', 'brief_over_budget',
         'class_dot', 'class_parens', 'class_semicolon', 'class_risk_tail',
         'class_upper_c', 'second_malformed_id')


def cells(subject, selected=None):
    return {name: run_case(name, subject) for name in CASES if selected is None or name == selected}


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    VERIFY.mkdir(parents=True, exist_ok=True)
    try:
        if args.repo:
            subject = args.repo.resolve() / 'scripts/make_task.sh'
            if not subject.is_file():
                print('170 SUBJECT_ABSENT', file=sys.stderr)
                return 2
            return 0 if all(cells(subject).values()) else 1
        with tempfile.TemporaryDirectory(dir=VERIFY, prefix='arch170-model-') as tmp:
            directory = Path(tmp) / 'scripts'
            directory.mkdir()
            for file in (ROOT / 'scripts').iterdir():
                if file.is_file() and file.name != 'make_task.sh':
                    (directory / file.name).symlink_to(file)
            honest = model_text()
            subject = directory / 'make_task.sh'
            subject.write_text(honest)
            control = cells(subject)
            if not all(control.values()):
                print('170 CONTROL_INVALID', file=sys.stderr)
                return 2
            if args.model:
                return 0
            mutants = (
                ('requirement_removed',
                 '    die "ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)"',
                 '    : # requirement bypass', 'required'),
                ('rules_omitted', '_arch_rules="--with-rules"', '_arch_rules=""', 'architect_rules'),
                ('rules_leaked', '_arch_rules=""\n      case "$ROLE"',
                 '_arch_rules="--with-rules"\n      case "$ROLE"', 'implementer_plain'),
                ('only_first_id', '      ARCH_SEC="${ARCH_SEC}COMPONENT: $_arch_id\n${_arch_text}\n"',
                 '      ARCH_SEC="${ARCH_SEC}COMPONENT: $_arch_id\n${_arch_text}\n"\n      _arch_rest=""', 'multi_component'),
                ('fixed_id', 'brief --compact --with-rules --component "$_arch_id"',
                 'brief --compact --with-rules --component "api.identity"', 'multi_component'),
                ('map_removed', "  printf '=== MAP ===\\n%s' \"$MAP_LINES\"",
                 "  printf '=== MAP ===\\n%s' \"\"", 'architect_rules'),
                ('rules_removed', "  printf '=== RULES ===\\n%s' \"$RULES_LINES\"",
                 "  printf '=== RULES ===\\n%s' \"\"", 'architect_rules'),
                ('backend_only', 'elif [ -d "$_arch_dir" ] && [ "$_arch_code" = "1" ]; then',
                 'elif [ -d "$_arch_dir" ] && [ "$_arch_code" = "1" ] && [ "$_arch_repo" = "Complior-back" ]; then',
                 'wrong_project'),
                ('lock_required_for_requirement', 'elif [ -d "$_arch_dir" ] && [ "$_arch_code" = "1" ]; then',
                 'elif [ -d "$_arch_dir" ] && [ "$_arch_code" = "1" ] && [ -f "$REPO/architecture.lock.json" ]; then',
                 'architecture_missing_required'),
                ('local_copy_required', 'if [ -n "$ARCH_COMPONENT" ]; then\n    if [ "$_arch_scope" = "1" ]; then',
                 'if [ -n "$ARCH_COMPONENT" ]; then\n    if [ "$_arch_scope" = "1" ]; then\n'
                 '      [ -d "$_arch_dir" ] || die "ARCHITECTURE_NET: нет локальной копии"',
                 'architect_rules'),
                ('local_source', '_arch_model="$(mktemp -d)"',
                 '_arch_model="$REPO/architecture"', 'local_wrong'),
                ('head_instead_of_pin',
                 'archive "$_arch_pin"', 'archive HEAD', 'local_wrong'),
                ('invalid_pin_accepted',
                 'git -C "$_arch_root" cat-file -e "${_arch_pin}^{commit}" 2>/dev/null || die "ARCH_PIN: коммит $_arch_pin не разрешается в клоне модели: $_arch_root"',
                 'git -C "$_arch_root" cat-file -e "${_arch_pin}^{commit}" 2>/dev/null || _arch_pin="$(git -C "$_arch_root" rev-parse HEAD)"',
                 'invalid_pin'),
                ('empty_lock_head_fallback',
                 '[ -n "$_arch_pin" ] || die "ARCH_PIN: в architecture.lock.json нет закреплённого коммита"',
                 '[ -n "$_arch_pin" ] || _arch_pin="$(git -C "$_arch_root" rev-parse HEAD)"',
                 'empty_lock'),
                ('applicability_valid_pin_only',
                 'if [ "$_arch_code" = 1 ] && [ "$_arch_scope" = 1 ]; then',
                 'if [ "$_arch_code" = 1 ] && [ "$_arch_scope" = 1 ] '
                 '&& [ "$(jq -r \'.commit // empty\' "$REPO/architecture.lock.json" 2>/dev/null)" =~ ^[0-9a-f]{40}$ ]; then',
                 'empty_lock_required'),
                ('symbolic_refused',
                 '[ -n "$_arch_pin" ] || die "ARCH_PIN: в architecture.lock.json нет закреплённого коммита"',
                 '[ -n "$_arch_pin" ] || die "ARCH_PIN: в architecture.lock.json нет закреплённого коммита"\n'
                 '    printf \'%s\\n\' "$_arch_pin" | grep -Eqx \'[0-9a-f]{40}\' || die "ARCH_PIN: lock не указывает на коммит архитектуры"',
                 'symbolic_pin'),
                ('brief_failure_ignored', ' || die "ARCH_BRIEF_OTKAZ: $_arch_id (закреплённая модель не отдала бриф)"',
                 ' || :', 'brief_failure'),
                ('plain_brief_failure_ignored',
                 '_arch_text="$(cd "$_arch_model" && node tooling/checks/cli.js brief --compact --component "$_arch_id" 2>/dev/null)" || die "ARCH_BRIEF_OTKAZ: $_arch_id (закреплённая модель не отдала бриф)"',
                 '_arch_text="$(cd "$_arch_model" && node tooling/checks/cli.js brief --compact --component "$_arch_id" 2>/dev/null)" || :',
                 'implementer_brief_failure'),
                ('exact_class_line',
                 "grep -Eq '(^|[[:punct:]])[[:space:]]*КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'",
                 "grep -Eiq '^КЛАСС ЗАДАЧИ: кодовый$'", 'class_dot'),
                ('locale_only_case',
                 "grep -Eq '(^|[[:punct:]])[[:space:]]*КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'",
                 "grep -Eiq '(^|[[:punct:]])[[:space:]]*КЛАСС ЗАДАЧИ:[[:space:]]*кодовый([^[:alnum:]_]|$)'",
                 'class_upper_c'),
                ('validate_during_brief',
                 '''    case "$ARCH_COMPONENT" in ''|,*|*,|*,,*) die "ARCH_COMPONENT_ID: непустой список id через запятую: $ARCH_COMPONENT" ;; esac
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      case "$_arch_id" in ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id: $_arch_id" ;; esac
    done
''', '', 'second_malformed_id'),
                ('brief_outside_budget',
                 '  [ -z "$ARCH_SEC" ] || printf \'=== ARCHITECTURE BRIEF ===\\n%s\' "$ARCH_SEC"',
                 '  : # brief deferred past budget', 'brief_over_budget'),
            )
            misses = 0
            for name, old, new, branch in mutants:
                if name == 'brief_failure_ignored':
                    if honest.count(old) != 2:
                        raise ValueError(f'expected both brief failure branches, found {honest.count(old)}')
                    mutated = honest.replace(old, new)
                else:
                    mutated = replace_once(honest, old, new)
                if name == 'local_source':
                    mutated = replace_once(
                        mutated,
                        'git -C "$_arch_root" archive "$_arch_pin" | tar -x -C "$_arch_model" || die "ARCH_PIN: дерево закреплённого коммита $_arch_pin не развернуть"',
                        '    : # use unpinned local copy')
                if name == 'validate_during_brief':
                    mutated = replace_once(
                        mutated, '      _arch_rules=""',
                        """      case "$_arch_id" in ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id: $_arch_id" ;; esac
      _arch_rules=""")
                if name == 'brief_outside_budget':
                    mutated = replace_once(
                        mutated, 'pack_body\nprintf \'%s\' "$MAN_BODY"',
                        'pack_body\n  [ -z "$ARCH_SEC" ] || printf \'=== ARCHITECTURE BRIEF ===\\n%s\' "$ARCH_SEC"\n'
                        'printf \'%s\' "$MAN_BODY"')
                subject.write_text(mutated)
                caught = not cells(subject, branch)[branch]
                print(f'170 STAB {name} {"caught" if caught else "ZHIV"} @ {branch}', flush=True)
                misses += not caught
            return 1 if misses else 0
    except (ValueError, subprocess.CalledProcessError, OSError) as error:
        print(f'170 CONTROL_INVALID: {error}', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
