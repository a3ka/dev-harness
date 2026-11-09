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
  if [ -n "$ARCH_COMPONENT" ]; then
    [ -d "$REPO/architecture" ] || die "ARCHITECTURE_NET: нет каталога architecture/"
    case "$ARCH_COMPONENT" in ''|,*|*,|*,,*) die "ARCH_COMPONENT_ID: пустой id" ;; esac
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      case "$_arch_id" in ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id" ;; esac
      _arch_rules=""
      case "$ROLE" in architect|critic|arbiter) _arch_rules="--with-rules" ;; esac
      if [ -n "$_arch_rules" ]; then
        _arch_text="$(npm --prefix "$REPO/architecture" run brief -- --compact --with-rules --component "$_arch_id")" || die "ARCH_BRIEF_OTKAZ: $_arch_id"
      else
        _arch_text="$(npm --prefix "$REPO/architecture" run brief -- --compact --component "$_arch_id")" || die "ARCH_BRIEF_OTKAZ: $_arch_id"
      fi
      [ -n "$_arch_text" ] || die "ARCH_BRIEF_OTKAZ: пустой $_arch_id"
      ARCH_SEC="${ARCH_SEC}${_arch_text}
"
    done
  elif [ -d "$REPO/architecture" ] && printf '%s\n' "$CBYTES" | grep -Eiq '^КЛАСС ЗАДАЧИ: кодовый$'; then
    die "ARCH_COMPONENT_NET: требуется --arch-component"
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


def world(*, arch=True, code=True):
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
    contract.write_text('КЛАСС ЗАДАЧИ: ' + ('кодовый' if code else 'документальный') + '\n' + contract.read_text())
    (repo / 'registry/trace.tsv').write_text(''.join(
        f'{role}\topenai-codex/gpt-6-sol\tallowed\n' for role in ('orchestrator',) + RULE_ROLES + PLAIN_ROLES))
    if arch:
        (repo / 'architecture').mkdir()
    subprocess.run(['git', '-C', str(repo), 'add', '.'], check=True, capture_output=True)
    subprocess.run(['git', '-C', str(repo), 'commit', '-qm', 'toy context'], check=True)
    subprocess.run(['git', '-C', str(repo), 'tag', 'frozen/contracts/777/1'], check=True)
    return Path(built), repo


def invoke(subject, repo, role, component=None, *, kind='task', env=None):
    argv = ['bash', str(subject), '--repo', str(repo), '--role', role,
            '--kind', kind, '--contract', '777', '--model-trace', str(repo / 'registry/trace.tsv')]
    if role == 'reviewer' and kind == 'task':
        argv += ['--task-file', str(repo / 'contracts/777-toy.md')]
    if component is not None:
        argv += ['--arch-component', component]
    return subprocess.run(argv, capture_output=True, text=True, timeout=40, env=env)


def run_case(name, subject):
    role = {'brief_kind': 'orchestrator', 'critic_rules': 'critic', 'arbiter_rules': 'arbiter',
            'implementer_plain': 'implementer', 'adversary_plain': 'adversary',
            'reviewer_plain': 'reviewer'}.get(name, 'architect')
    arch = name != 'legacy'
    code = name != 'document'
    component = ('api.identity,worker.events' if name == 'multi_component' else
                 '../escape' if name == 'malformed_id' else
                 'api.identity' if name in ('architect_rules', 'critic_rules', 'arbiter_rules',
                    'implementer_plain', 'adversary_plain', 'reviewer_plain', 'lose_map',
                    'lose_rules', 'malformed_id') else None)
    built, repo = world(arch=arch, code=code)
    try:
        expected_ids = IDS if name == 'multi_component' else IDS[:1]
        nonce = 'SENTINEL-170-' + name
        # Independent in-memory oracle, constructed before invoking subject.
        expected = [(f'# ARCH-BRIEF:{ident}', f'OWN-CONTRACT:{ident}:{nonce}',
                     f'FITNESS-RULE-FOR:{ident}') for ident in expected_ids]
        with tempfile.TemporaryDirectory(dir=VERIFY, prefix='arch170-bin-') as bin_dir:
            os.symlink(HERE / 'npm_stub.py', Path(bin_dir) / 'npm')
            env = dict(os.environ, ARCH170_PROJECT=str(repo), ARCH170_NONCE=nonce,
                       PATH=bin_dir + os.pathsep + os.environ['PATH'])
            if name == 'wrong_project':
                # Profile cannot accidentally decide applicability: project identity changes.
                profile = repo / 'harness.project.json'
                data = json.loads(profile.read_text())
                data['repoId'] = 'another-project'
                profile.write_text(json.dumps(data))
            result = invoke(subject, repo, role, component, kind='brief' if name == 'brief_kind' else 'task', env=env)
        lines = result.stdout.splitlines()
        manifest = result.stdout.split('=== MANIFEST ===\n', 1)[-1].split('=== BUDGET ===', 1)[0].splitlines()
        reject = {'required': 'ARCH_COMPONENT_NET', 'wrong_project': 'ARCH_COMPONENT_NET',
                  'malformed_id': 'ARCH_COMPONENT_ID'}.get(name)
        if reject:
            good = (result.returncode == 1 and not result.stdout
                    and result.stderr.splitlines()[0].startswith('ОТКАЗ: ' + reject + ':'))
        else:
            good = (result.returncode == 0 and 'MAP: STRUCTURE.md :: all modules' in lines
                    and 'RULES: COMMON-RULES.md' in lines
                    and 'map\tSTRUCTURE.md\tmandatory\tprofile' in manifest
                    and 'rules\tCOMMON-RULES.md\tmandatory\tprofile' in manifest)
            if component and name != 'malformed_id':
                actual_briefs = [line for line in lines if line.startswith('# ARCH-BRIEF:')]
                good &= actual_briefs == [row[0] for row in expected]
                for title, own, fitness in expected:
                    good &= lines.count(title) == 1 and lines.count(own) == 1
                    good &= (lines.count(fitness) == 1) if role in RULE_ROLES else fitness not in lines
            elif name not in ('malformed_id',):
                good &= not any(line.startswith('# ARCH-BRIEF:') for line in lines)
        if name == 'malformed_id':
            good &= not (repo / 'architecture/generated').exists()
        print(f'170 {name} {"ok" if good else "KRASNO"} rc={result.returncode} '
              f'stderr={result.stderr.strip()!r}', flush=True)
        return bool(good)
    finally:
        shutil.rmtree(built)


CASES = ('required', 'legacy', 'document', 'brief_kind', 'architect_rules',
         'critic_rules', 'arbiter_rules', 'implementer_plain', 'adversary_plain',
         'reviewer_plain', 'multi_component', 'wrong_project', 'malformed_id')


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
                ('fixed_id', '--with-rules --component "$_arch_id")',
                 '--with-rules --component "api.identity")', 'multi_component'),
                ('map_removed', "  printf '=== MAP ===\\n%s' \"$MAP_LINES\"",
                 "  printf '=== MAP ===\\n%s' \"\"", 'architect_rules'),
                ('rules_removed', "  printf '=== RULES ===\\n%s' \"$RULES_LINES\"",
                 "  printf '=== RULES ===\\n%s' \"\"", 'architect_rules'),
                ('backend_only', '[ -d "$REPO/architecture" ] && printf',
                 '[ -d "$REPO/architecture" ] && [ "$(printf \'%s\' "$MERGED" | jq -r .repoId.value)" = Complior-back ] && printf',
                 'wrong_project'),
            )
            misses = 0
            for name, old, new, branch in mutants:
                mutated = replace_once(honest, old, new)
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
