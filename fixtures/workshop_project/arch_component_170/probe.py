#!/usr/bin/env python3
"""170: public make_task boundary, honest control and branch-specific mutants."""
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
  _arch_code=0
  if printf '%s\n' "$CBYTES" | grep -Eq '^КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'; then _arch_code=1; fi
  if [ -n "$ARCH_COMPONENT" ]; then
    [ -f "$REPO/architecture.lock.json" ] || die "ARCHITECTURE_NET: нет закреплённого коммита"
    _arch_pin="$(jq -er '.commit' "$REPO/architecture.lock.json" 2>/dev/null)" || die "ARCHITECTURE_NET: нет закреплённого коммита"
    printf '%s\n' "$_arch_pin" | grep -Eqx '[0-9a-f]{40}' || die "ARCHITECTURE_NET: lock не указывает на коммит архитектуры"
    [ -n "${ARCHITECTURE_ROOT:-}" ] && [ -d "$ARCHITECTURE_ROOT" ] || die "ARCHITECTURE_NET: нет репозитория архитектуры ARCHITECTURE_ROOT"
    [ "$(git -C "$ARCHITECTURE_ROOT" cat-file -t "$_arch_pin" 2>/dev/null)" = commit ] || die "ARCHITECTURE_NET: lock не указывает на коммит архитектуры"
    _arch_dir="$(mktemp -d)"
    git -C "$ARCHITECTURE_ROOT" archive "$_arch_pin" | tar -x -C "$_arch_dir" || die "ARCHITECTURE_NET: не прочитан закреплённый коммит"
    case "$ARCH_COMPONENT" in ''|,*|*,|*,,*) die "ARCH_COMPONENT_ID: пустой id" ;; esac
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      case "$_arch_id" in ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id" ;; esac
    done
    if [ "$_arch_repo" = Complior-back ] && [ "$_arch_code" = 1 ]; then
      # Witness of frozen/contracts/187/1 on the same input: the 170 world must satisfy 187a.
      _arch_task="$CBYTES"
      [ -z "$TASKFILE" ] || _arch_task="$(cat "$TASKFILE")"
      _arch_line="$(printf '%s\n' "$_arch_task" | grep -m1 -E '^АРХИТЕКТУРА:' || true)"
      printf '%s\n' "$_arch_line" | grep -Eqx 'АРХИТЕКТУРА: L[123] [A-Za-z0-9_][A-Za-z0-9._-]*(,[A-Za-z0-9_][A-Za-z0-9._-]*)*' || die "ARCH_LINE_MISSING: нет строки АРХИТЕКТУРА"
      case "$_arch_line" in 'АРХИТЕКТУРА: L3 '*) die "ARCH_OWNER: L3" ;; esac
      for _arch_path in $(printf '%s\n' "$_arch_task" | sed -n 's/^ЗОНА implementer://p'); do
        _arch_where="$(cd "$_arch_dir" && node tooling/checks/cli.js locate --path "$_arch_path")" || die "PATH_WITHOUT_COMPONENT: $_arch_path"
        printf '%s\n' "${_arch_line#АРХИТЕКТУРА: L? }" | tr ',' '\n' | grep -Fxq "$_arch_where" || die "ARCH_ZONE: $_arch_path"
      done
    fi
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      _arch_rules=""
      case "$ROLE" in architect|critic|arbiter) _arch_rules="--with-rules" ;; esac
      if [ -n "$_arch_rules" ]; then
        _arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --with-rules --component "$_arch_id" 2>&1)" || die "ARCH_BRIEF_OTKAZ: $_arch_id"
      else
        _arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --component "$_arch_id" 2>&1)" || die "ARCH_BRIEF_OTKAZ: $_arch_id"
      fi
      [ -n "$_arch_text" ] || die "ARCH_BRIEF_OTKAZ: пустой $_arch_id"
      ARCH_SEC="${ARCH_SEC}${_arch_text}
"
    done
    rm -rf "$_arch_dir"
  elif { [ -f "$REPO/architecture.lock.json" ] || [ "$_arch_repo" = Complior-back ]; } && [ "$_arch_code" = 1 ]; then
    die "ARCH_COMPONENT_NET: требуется --arch-component"
  fi
fi
'''
# Anchors of the honest control used by mutants; replace_once proves each occurs exactly once.
LOCK_CHECK = r'''[ -f "$REPO/architecture.lock.json" ] || die "ARCHITECTURE_NET: нет закреплённого коммита"'''
PIN_READ = r'''_arch_pin="$(jq -er '.commit' "$REPO/architecture.lock.json" 2>/dev/null)" || die "ARCHITECTURE_NET: нет закреплённого коммита"'''
PIN_GRAMMAR = r'''    printf '%s\n' "$_arch_pin" | grep -Eqx '[0-9a-f]{40}' || die "ARCHITECTURE_NET: lock не указывает на коммит архитектуры"'''
ARCHIVE = r'''    git -C "$ARCHITECTURE_ROOT" archive "$_arch_pin" | tar -x -C "$_arch_dir" || die "ARCHITECTURE_NET: не прочитан закреплённый коммит"'''


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
# Pinned model: only the 187a `locate` command; the 170 brief boundary is `npm --prefix <tree> run brief`.
MODEL_CLI = r'''const a = process.argv.slice(2);
if (a[0] === 'locate' && a[1] === '--path' && a.length === 3) {
  if (a[2] === 'scripts/' || a[2].startsWith('scripts/')) { console.log('api.identity'); process.exit(0); }
  console.error('PATH_WITHOUT_COMPONENT'); process.exit(1);
}
console.error('cli.js: brief goes through npm run brief'); process.exit(2);
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
OTHER_PROJECT = ('wrong_project', 'legacy', 'empty_lock_required')
NO_PIN = 'ОТКАЗ: ARCHITECTURE_NET: нет закреплённого коммита'
NOT_COMMIT = 'ОТКАЗ: ARCHITECTURE_NET: lock не указывает на коммит архитектуры'
PIN_TAIL = {'architecture_missing': NO_PIN, 'local_without_lock': NO_PIN, 'empty_lock': NO_PIN,
            'lock_without_commit': NO_PIN, 'invalid_pin': NOT_COMMIT, 'symbolic_pin': NOT_COMMIT}
PIN_REFUSALS = tuple(PIN_TAIL) + ('model_root_unset',)


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
                    'malformed_id', 'brief_over_budget') + PIN_REFUSALS else None)
    built, repo, model = world(lock=lock, code=code, class_line=CLASS_LINES.get(name),
                               local_copy=name in ('local_wrong', 'local_without_lock'))
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
                # Profile cannot accidentally decide applicability: project identity changes.
                profile = repo / 'harness.project.json'
                data = json.loads(profile.read_text())
                data['repoId'] = 'another-project'
                profile.write_text(json.dumps(data))
            result = invoke(subject, repo, role, component, kind='brief' if name == 'brief_kind' else 'task', env=env)
            npm_calls = len(calls.read_text().splitlines()) if calls.exists() else 0
        map_lines = section(result.stdout, 'MAP')
        rule_lines = section(result.stdout, 'RULES')
        brief_lines = section(result.stdout, 'ARCHITECTURE BRIEF')
        manifest = section(result.stdout, 'MANIFEST')
        reject = {'required': 'ARCH_COMPONENT_NET', 'wrong_project': 'ARCH_COMPONENT_NET',
                  'architecture_missing_required': 'ARCH_COMPONENT_NET',
                  'empty_lock_required': 'ARCH_COMPONENT_NET',
                  **{key: 'ARCH_COMPONENT_NET' for key in CLASS_LINES},
                  'malformed_id': 'ARCH_COMPONENT_ID', 'second_malformed_id': 'ARCH_COMPONENT_ID',
                  **{key: 'ARCHITECTURE_NET' for key in PIN_REFUSALS},
                  'brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'implementer_brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'adversary_brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'reviewer_brief_failure': 'ARCH_BRIEF_OTKAZ',
                  'brief_over_budget': 'режь задачу'}.get(name)
        if reject:
            first = (result.stderr.splitlines() or [''])[0]
            good = result.returncode == 1 and not result.stdout and first.startswith('ОТКАЗ: ' + reject + ':')
            if name in PIN_TAIL:
                good &= first.startswith(PIN_TAIL[name])
            if name in PIN_REFUSALS + ('second_malformed_id',):
                good &= npm_calls == 0
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
        if name == 'malformed_id':
            good &= not (repo / 'architecture/generated').exists()
        calls_detail = f' npm_calls={npm_calls}' if name in PIN_REFUSALS + ('second_malformed_id',) else ''
        print(f'170 {name} {"ok" if good else "KRASNO"} rc={result.returncode} '
              f'stderr={result.stderr.strip()!r}{calls_detail}', flush=True)
        return bool(good)
    finally:
        shutil.rmtree(built)


CASES = ('required', 'legacy', 'document', 'brief_kind', 'architect_rules',
         'critic_rules', 'arbiter_rules', 'implementer_plain', 'adversary_plain',
         'reviewer_plain', 'multi_component', 'wrong_project', 'malformed_id',
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
                ('requirement_removed', '    die "ARCH_COMPONENT_NET: требуется --arch-component"',
                 '    : # requirement bypass', 'required'),
                ('rules_omitted', '_arch_rules="--with-rules"', '_arch_rules=""', 'architect_rules'),
                ('rules_leaked', '_arch_rules=""\n      case "$ROLE"',
                 '_arch_rules="--with-rules"\n      case "$ROLE"', 'implementer_plain'),
                ('only_first_id', '      ARCH_SEC="${ARCH_SEC}${_arch_text}\n"',
                 '      ARCH_SEC="${ARCH_SEC}${_arch_text}\n"\n      _arch_rest=""', 'multi_component'),
                ('fixed_id', '--with-rules --component "$_arch_id" 2>&1)',
                 '--with-rules --component "api.identity" 2>&1)', 'multi_component'),
                ('map_removed', "  printf '=== MAP ===\\n%s' \"$MAP_LINES\"",
                 "  printf '=== MAP ===\\n%s' \"\"", 'architect_rules'),
                ('rules_removed', "  printf '=== RULES ===\\n%s' \"$RULES_LINES\"",
                 "  printf '=== RULES ===\\n%s' \"\"", 'architect_rules'),
                ('backend_only', '|| [ "$_arch_repo" = Complior-back ]', '|| false',
                 'architecture_missing_required'),
                ('local_copy_required', LOCK_CHECK,
                 '[ -d "$REPO/architecture" ] || die "ARCHITECTURE_NET: нет локальной копии"', 'architect_rules'),
                ('local_source',
                 '_arch_dir="$(mktemp -d)"',
                 '_arch_dir="$REPO/architecture"', 'local_wrong'),
                ('head_instead_of_pin',
                 'archive "$_arch_pin"',
                 'archive HEAD', 'local_wrong'),
                ('missing_lock_fallback', LOCK_CHECK,
                 'if [ ! -f "$REPO/architecture.lock.json" ] && [ -d "$REPO/architecture" ]; then '
                 '_arch_dir="$REPO/architecture"; else\n    ' + LOCK_CHECK, 'local_without_lock'),
                ('invalid_pin_accepted', PIN_READ,
                 '_arch_pin="$(git -C "$ARCHITECTURE_ROOT" rev-parse HEAD)"', 'invalid_pin'),
                ('empty_lock_head_fallback', PIN_READ,
                 PIN_READ.split(' || die ')[0] + ' || _arch_pin="$(git -C "$ARCHITECTURE_ROOT" rev-parse HEAD)"',
                 'empty_lock'),
                ('applicability_valid_pin_only', '{ [ -f "$REPO/architecture.lock.json" ] ||',
                 '{ jq -e \'.commit|test("^[0-9a-f]{40}$")\' "$REPO/architecture.lock.json" >/dev/null 2>&1 ||',
                 'empty_lock_required'),
                ('pin_grammar_unchecked', PIN_GRAMMAR + '\n', '', 'symbolic_pin'),
                ('npm_failure_ignored', ' || die "ARCH_BRIEF_OTKAZ: $_arch_id"',
                 ' || :', 'brief_failure'),
                ('plain_npm_failure_ignored',
                 '_arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --component "$_arch_id" 2>&1)" || die "ARCH_BRIEF_OTKAZ: $_arch_id"',
                 '_arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --component "$_arch_id" 2>&1)" || :',
                 'implementer_brief_failure'),
                ('exact_class_line',
                 "grep -Eq '^КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'",
                 "grep -Eiq '^КЛАСС ЗАДАЧИ: кодовый$'", 'class_dot'),
                ('locale_only_case',
                 "grep -Eq '^КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'",
                 "grep -Eiq '^КЛАСС ЗАДАЧИ:[[:space:]]*кодовый([^[:alnum:]_]|$)'",
                 'class_upper_c'),
                ('validate_during_npm',
                 """    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      case "$_arch_id" in ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id" ;; esac
    done
""", '', 'second_malformed_id'),
                ('brief_outside_budget',
                 '  [ -z "$ARCH_SEC" ] || printf \'=== ARCHITECTURE BRIEF ===\\n%s\' "$ARCH_SEC"',
                 '  : # brief deferred past budget', 'brief_over_budget'),
            )
            misses = 0
            for name, old, new, branch in mutants:
                if name == 'npm_failure_ignored':
                    if honest.count(old) != 2:
                        raise ValueError(f'expected both npm failure branches, found {honest.count(old)}')
                    mutated = honest.replace(old, new)
                else:
                    mutated = replace_once(honest, old, new)
                if name == 'local_source':
                    mutated = replace_once(mutated, ARCHIVE, '    : # use unpinned local copy')
                if name == 'missing_lock_fallback':
                    mutated = replace_once(mutated, ARCHIVE, ARCHIVE + '\n    fi')
                if name == 'validate_during_npm':
                    mutated = replace_once(
                        mutated, '      _arch_rules=""',
                        """      case "$_arch_id" in ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id" ;; esac
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
