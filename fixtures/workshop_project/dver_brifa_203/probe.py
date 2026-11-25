#!/usr/bin/env python3
"""203 v2: real public doors on offline Git/Node worlds, in-memory oracle.

Four subjects, one per owner point: (1) the door itself links the pinned
export's dependencies; (2) a brief refusal reason is the model's own code and
message, not the first stderr line «{»; (3) «АРХИТЕКТУРА:» ids are elements
of the model BY PIN (make_task line gate, freeze gate, public door, flag);
(4) the pack budget is the effective pack.maxBytes, with no 40000 branch for
pinned briefs. Expectations are held in memory before any subject call; the
subject disk is never re-read as an oracle.
"""
import argparse
from dataclasses import dataclass
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / 'fixtures/workshop_project/architecture_process_187'))
from probe import world, put, git, CONTRACT, critic_state  # noqa: E402
from model import materialize  # noqa: E402
from stabs import STABS, mutate  # noqa: E402

ROLES = ('architect', 'critic', 'arbiter', 'implementer', 'adversary', 'reviewer')

# Toy pinned CLI: locate places app/identity/ and app/auth/; brief answers
# from brief-data.json (dependency proof via require, JSON refusal report of
# the real CLI shape, or a raw stderr for the non-JSON branch). Anything else
# is rc 2 — the door never depends on unimplemented commands here.
CLI = r'''const fs = require('node:fs');
const a = process.argv.slice(2); const name = a[0];
const data = JSON.parse(fs.readFileSync('brief-data.json', 'utf8'));
if (name === 'locate') {
  const p = a[a.indexOf('--path') + 1];
  const auth = p.startsWith('app/auth/');
  console.log(JSON.stringify({status:'DECLARED', scope:'DECLARED_PLACEMENT_ONLY', path:p,
    matches:[{module: auth ? 'module.auth' : 'module.identity',
    components: auth ? ['api.auth'] : ['api.identity'],
    specification:'system/' + (auth ? 'auth' : 'identity') + '/module.js', explicit:true,
    matched: auth ? 'app/auth/' : 'app/identity/'}]}));
} else if (name === 'brief') {
  const id = a[a.indexOf('--component') + 1];
  if (data.dependency) process.stdout.write(require('brief-dependency-203') + '\n');
  if (data.fail && Object.prototype.hasOwnProperty.call(data.fail, id)) {
    const f = data.fail[id];
    if (f.raw !== undefined && f.raw !== null) process.stderr.write(f.raw);
    else process.stderr.write(JSON.stringify({status:'FAIL', scope:'ARCHITECTURE_TOOL_INPUT',
      findings:[{code:f.code, message:f.message}], implementationEvidence:'NOT_ASSESSED'}, null, 2) + '\n');
    process.exitCode = f.rc;
  } else {
    process.stdout.write((data[id] || '') + (a.includes('--with-rules') ? (data.rules || '') : ''));
  }
} else { process.exitCode = 2; }
'''

FIRST = ('# api.identity\nDeclaration: system/identity/module.js\n'
         'Product placement: app/identity/\n## Own contracts\n'
         'identity.lookup READY input schema.query output schema.record\n'
         'semanticInvariant: lookup does not write\n'
         'writers: identity.owner\nisolationKeys: scope_id\n'
         '## Neighbour ports (signatures only)\n'
         'email.send(schema.mail) -> schema.sent\n'
         '## Resources and requirements\nresource.identity; requirement.account\n')
SECOND = '# worker.events\nwriter event.owner; isolationKeys tenant_id\n'
AUTH_BRIEF = '# api.auth\nDeclaration: system/auth/module.js\n'

UNKNOWN_FAIL = {'code': 'UNKNOWN_ARCHITECTURE_ELEMENT',
                'message': 'Unknown architecture element: resource.identity', 'rc': 1}
TOY_FAIL = {'code': 'TOY_REFUSAL_CODE_203',
            'message': 'причина с юникодом и id api.identity внутри', 'rc': 17}


@dataclass(frozen=True)
class Expected:
    rc: int
    stdout_empty: bool = True
    line_prefixes: tuple = ()   # stderr lines that must start with these
    line_exact: tuple = ()      # stderr lines that must equal these
    any_contains: tuple = ()    # substrings somewhere in stderr
    pack_contains: tuple = ()   # stdout markers of the assembled pack
    pack_forbids: tuple = ()
    budget_suffix: str = ''     # BUDGET: vklejka=<n>/<suffix>
    donor_guard: bool = False   # donor node_modules survives the run
    tag_expected: bool = False  # frozen tag outcome for freeze cells


CASES = {
    # ── (1) дверь сама ставит зависимости выгрузки пина ───────────────────
    'deps-linked': dict(dependency=True, expect=Expected(
        rc=0, stdout_empty=False, pack_contains=('DEP203_OK', 'identity.lookup READY'),
        pack_forbids=('WRONG_HEAD_203',), budget_suffix='/40000', donor_guard=True)),
    'deps-lock-differs': dict(dependency=True, donor_lock='differs', expect=Expected(
        rc=1, line_prefixes=('ОТКАЗ: ARCH_BRIEF_DEPS:',), any_contains=('npm ci',))),
    'deps-lock-same-size': dict(dependency=True, donor_lock='same-size', expect=Expected(
        rc=1, line_prefixes=('ОТКАЗ: ARCH_BRIEF_DEPS:',), any_contains=('npm ci',))),
    'deps-donor-lock-missing': dict(dependency=True, donor_lock='missing', expect=Expected(
        rc=1, line_prefixes=('ОТКАЗ: ARCH_BRIEF_DEPS:',), any_contains=('npm ci',))),
    'deps-donor-modules-missing': dict(dependency=True, donor_modules=False, expect=Expected(
        rc=1, line_prefixes=('ОТКАЗ: ARCH_BRIEF_DEPS:',), any_contains=('npm ci',))),
    'deps-pin-lock-missing': dict(dependency=True, pin_lock=False, expect=Expected(
        rc=1, line_prefixes=('ОТКАЗ: ARCH_BRIEF_DEPS:',), any_contains=('npm ci',))),
    'deps-free': dict(dependency=False, expect=Expected(
        rc=0, stdout_empty=False, pack_contains=('identity.lookup READY',),
        pack_forbids=('WRONG_HEAD_203', 'DEP203_OK'))),
    # ── (2) причина отказа — код + сообщение из ответа модели ─────────────
    'reason-json': dict(fail={'api.identity': TOY_FAIL}, expect=Expected(
        rc=1, line_prefixes=(
            'ARCH_BRIEF_STDERR: TOY_REFUSAL_CODE_203: причина с юникодом и id api.identity внутри',
            'ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity'))),
    'reason-nonjson': dict(fail={'api.identity': {
        'rc': 3, 'raw': 'FIRST_CAUSE_203: boom\nSECOND_CAUSE_203: never\n'}}, expect=Expected(
        rc=1, line_prefixes=('ARCH_BRIEF_STDERR: FIRST_CAUSE_203: boom',),
        any_contains=('ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity',))),
    'reason-empty': dict(fail={'api.identity': {'rc': 5, 'raw': ''}}, expect=Expected(
        rc=1, line_prefixes=('ARCH_BRIEF_STDERR: (stderr модели пуст)',),
        any_contains=('ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity',))),
    'reason-second': dict(comp='api.identity,worker.events', fail={'worker.events': {
        'code': 'MODEL_SCHEMA_VIOLATION', 'message': 'invalid shape', 'rc': 9}}, expect=Expected(
        rc=1, line_prefixes=('ARCH_BRIEF_STDERR: MODEL_SCHEMA_VIOLATION: invalid shape',),
        any_contains=('worker.events',))),
    # ── (3) id строки «АРХИТЕКТУРА:» — элементы модели ПО ПИНУ ────────────
    'element-line-unknown': dict(line='L1 api.identity,resource.identity',
                                 fail={'resource.identity': UNKNOWN_FAIL}, expect=Expected(
        rc=1, line_exact=('ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity',))),
    'element-line-known': dict(expect=Expected(
        rc=0, stdout_empty=False, pack_contains=('identity.lookup READY',))),
    'element-flag-unknown': dict(comp='resource.identity',
                                 fail={'resource.identity': UNKNOWN_FAIL}, expect=Expected(
        rc=1, line_prefixes=(
            'ARCH_BRIEF_STDERR: UNKNOWN_ARCHITECTURE_ELEMENT: Unknown architecture element: resource.identity',),
        any_contains=('resource.identity',))),
    'element-pin-not-head': dict(line='L1 resource.identity', zone='',
                                 comp='resource.identity', head_knows_unknown=True,
                                 fail={'resource.identity': UNKNOWN_FAIL}, expect=Expected(
        rc=1, line_exact=('ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity',))),
    'element-freeze-unknown': dict(kind='freeze',
                                   contract_line='АРХИТЕКТУРА: L1 api.auth,resource.identity\n',
                                   contract_zone='app/auth/model.js',
                                   fail={'resource.identity': UNKNOWN_FAIL}, expect=Expected(
        rc=1, line_exact=('ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity',))),
    'element-freeze-known': dict(kind='freeze', expect=Expected(
        rc=0, stdout_empty=False, tag_expected=True)),
    'element-door-unknown': dict(kind='door',
                                 contract_line='АРХИТЕКТУРА: L1 api.identity,resource.identity\n',
                                 fail={'resource.identity': UNKNOWN_FAIL}, expect=Expected(
        rc=1, line_exact=('UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity',))),
    # ── (4) кап — pack.maxBytes, ветки 40000 нет ──────────────────────────
    'cap-within': dict(pack_max=260000, pad=91445, expect=Expected(
        rc=0, stdout_empty=False, pack_contains=('END_OF_COMPLETE_BRIEF',),
        budget_suffix='/260000')),
    'cap-over-profile': dict(pack_max=60000, pad=91445, expect=Expected(
        rc=1, line_prefixes=('ОТКАЗ: режь задачу: ',), any_contains=('> 60000',))),
    'cap-default': dict(pad=91445, expect=Expected(
        rc=1, line_prefixes=('ОТКАЗ: режь задачу: ',), any_contains=('> 40000',))),
}


def build(base, name, *, dependency=False, pin_lock=True, donor_lock='same',
          donor_modules=True, pack_max=None, pad=0, fail=None,
          line='L1 api.identity', zone='app/identity/model.js', comp='api.identity',
          head_knows_unknown=False, contract_line=None, contract_zone=None, kind='task'):
    product = world(base, name)
    if pack_max is not None:
        profile = json.loads((product / 'harness.project.json').read_text())
        profile['pack'] = {'maxBytes': pack_max}
        put(product, 'harness.project.json', json.dumps(profile))
    arch = base / (name + '-architecture')
    arch.mkdir()
    git(arch, 'init', '-q', '-b', 'main')
    git(arch, 'config', 'user.name', 'Fixture')
    git(arch, 'config', 'user.email', 'fixture@local')
    git(arch, 'config', 'core.hooksPath', '/dev/null')
    git(arch, 'config', 'commit.gpgsign', 'false')
    package = {'name': 'brief-world', 'version': '1.0.0'}
    if dependency:
        package['dependencies'] = {'brief-dependency-203': '1.0.0'}
    put(arch, 'package.json', json.dumps(package))
    lock = json.dumps({'name': 'brief-world', 'lockfileVersion': 3, 'packages': {
        '': package, 'node_modules/brief-dependency-203': {'version': '1.0.0'}}}) + '\n'
    if dependency and pin_lock:
        put(arch, 'package-lock.json', lock)
    put(arch, 'tooling/checks/cli.js', CLI)
    first = FIRST + ('x' * pad + '\nEND_OF_COMPLETE_BRIEF\n' if pad else '')
    data = {'api.identity': first, 'api.auth': AUTH_BRIEF, 'worker.events': SECOND,
            'rules': '## Model fitness rules\nRULE203: model evidence only\n',
            'dependency': dependency, 'fail': fail or {}}
    put(arch, 'brief-data.json', json.dumps(data))
    git(arch, 'add', '.')
    git(arch, 'commit', '-qm', 'pinned architecture A')
    pin = git(arch, 'rev-parse', 'HEAD')
    # HEAD moves past the pin: B must never leak into the pack or the gates.
    later = dict(data)
    later['api.identity'] = 'WRONG_HEAD_203\n'
    if head_knows_unknown:
        later['fail'] = {}
        later['resource.identity'] = 'WRONG_HEAD_203 resource.identity\n'
    put(arch, 'brief-data.json', json.dumps(later))
    git(arch, 'add', '.')
    git(arch, 'commit', '-qm', 'later architecture B')
    if dependency and donor_modules:
        put(arch, 'node_modules/brief-dependency-203/index.js',
            'module.exports = "DEP203_OK";\n')
    if donor_lock == 'differs':
        put(arch, 'package-lock.json', lock + ' ')
    elif donor_lock == 'same-size':
        put(arch, 'package-lock.json', lock.replace('1.0.0', '2.0.0'))
    elif donor_lock == 'missing':
        (arch / 'package-lock.json').unlink(missing_ok=True)
    put(product, 'architecture.lock.json', json.dumps({'commit': pin}))
    if contract_line is not None:
        text = (product / CONTRACT).read_text().replace(
            'АРХИТЕКТУРА: L1 api.identity\n', contract_line)
        if contract_zone is not None:
            text = text.replace('app/identity/model.js', contract_zone)
        put(product, CONTRACT, text)
        git(product, 'add', '.')
        git(product, 'commit', '-qm', 'contract line')
        git(product, 'push', '-q', 'origin', 'main')
    task = product / 'task203.md'
    task.write_text('SUBJECT=777\nАРХИТЕКТУРА: ' + line + '\n'
                    + (f'ЗОНА implementer: {zone}\n' if zone else ''))
    trace = product / 'trace203.tsv'
    trace.write_text(''.join(item + '\tzai/glm-5.3\tallowed\n' for item in ROLES))
    git(product, 'add', '.')
    git(product, 'commit', '-qm', '203 pinned task')
    return product, arch, task, trace, comp


def env_for(product, arch):
    env = {k: v for k, v in os.environ.items()
           if not k.startswith('GIT_') and k not in {'NODE_PATH', 'NODE_OPTIONS'}}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(product), ARCHITECTURE_ROOT=str(arch))
    return env


def subject(tools, kind, product, arch, task, trace, comp):
    env = env_for(product, arch)
    if kind == 'door':
        argv = ['bash', str(tools / 'scripts/check_architecture_contract.sh'),
                '--repo', str(product), CONTRACT]
        return subprocess.run(argv, cwd=product, env=env, capture_output=True, timeout=90)
    if kind == 'freeze':
        argv = ['bash', str(tools / 'scripts/freeze_contract.sh'), CONTRACT,
                'toy reason', str(product), str(critic_state(product))]
        return subprocess.run(argv, cwd=product, env=env, capture_output=True, timeout=180)
    argv = ['bash', str(tools / 'scripts/make_task.sh'), '--repo', str(product),
            '--role', 'architect', '--kind', 'task', '--contract', '777',
            '--task-file', str(task), '--model-trace', str(trace),
            '--arch-component', comp]
    return subprocess.run(argv, cwd=product, env=env, capture_output=True, timeout=240)


def judge(config, expect, result, product, arch):
    kind = config.get('kind', 'task')
    errors = []
    if result.returncode != expect.rc:
        errors.append(f'rc={result.returncode} expected={expect.rc}')
    out = result.stdout.decode('utf8', 'replace')
    err = result.stderr.decode('utf8', 'replace')
    lines = err.splitlines()
    first = lines[0] if lines else ''
    if expect.stdout_empty and out:
        errors.append('stdout not empty on refusal')
    if not expect.stdout_empty and not out:
        errors.append('pack missing')
    for prefix in expect.line_prefixes:
        if not any(line.startswith(prefix) for line in lines):
            errors.append(f'no stderr line starting with: {prefix[:80]}')
    for exact in expect.line_exact:
        if not any(line == exact for line in lines):
            errors.append(f'no stderr line equal to: {exact[:80]}')
    for chunk in expect.any_contains:
        if chunk not in err:
            errors.append(f'stderr lacks: {chunk[:60]}')
    for marker in expect.pack_contains:
        if marker not in out:
            errors.append(f'pack lacks: {marker[:60]}')
    for marker in expect.pack_forbids:
        if marker in out:
            errors.append(f'pack must not carry: {marker[:60]}')
    if expect.budget_suffix:
        budget = [line for line in out.splitlines() if line.startswith('BUDGET: vklejka=')]
        if not any(line.endswith(expect.budget_suffix) for line in budget):
            errors.append(f'budget line lacks suffix {expect.budget_suffix}: {budget[:1]}')
    if expect.donor_guard:
        if not (arch / 'node_modules/brief-dependency-203/index.js').is_file():
            errors.append('donor node_modules damaged')
    if kind == 'freeze':
        tag = git(product, 'tag', '-l', 'frozen/contracts/777/*')
        if bool(tag) != expect.tag_expected:
            errors.append(f'tag presence {bool(tag)} expected {expect.tag_expected}')
    return errors, f'rc={result.returncode} stderr={first[:160]!r}'


def run_cell(base, tools, label, cell, override=None):
    config = dict(CASES[cell])
    expect = config.pop('expect')
    if override:
        config.update(override)
    kind = config.get('kind', 'task')
    product, arch, task, trace, comp = build(base, label, **config)
    result = subject(tools, kind, product, arch, task, trace, comp)
    return judge(config, expect, result, product, arch)


def check_tools():
    for tool in ('bash', 'git', 'jq', 'node', 'tar', 'cmp'):
        if shutil.which(tool) is None:
            print(f'NOT_IMPLEMENTED: нет {tool}', file=sys.stderr)
            return False
    return True


def main():
    parser = argparse.ArgumentParser(add_help=False)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--repo', nargs='?', const=str(ROOT), default=None)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--sintaksis', action='store_true')
    args = parser.parse_args()
    if not check_tools():
        return 2
    if args.sintaksis:
        with tempfile.TemporaryDirectory(prefix='dver-brifa-203-') as temp:
            etalon = materialize(ROOT, Path(temp) / 'etalon')
            bad = []
            for name in ('check_architecture_contract.sh', 'make_task.sh'):
                result = subprocess.run(['bash', '-n', str(etalon / 'scripts' / name)],
                                        capture_output=True, timeout=30)
                if result.returncode:
                    bad.append(f'{name}: {result.stderr.decode("utf8", "replace")[:120]}')
            for name in bad:
                print(f'SINTAKSIS KRASNO: {name}')
            if bad:
                return 1
            print('SINTAKSIS OK')
            return 0
    orphan = sorted({cell for cell, *_ in STABS.values()} - set(CASES))
    if orphan:
        print(f'STAB_REGISTRY: привязка к несуществующей клетке: {orphan}', file=sys.stderr)
        return 1
    failures, zhivye = [], []
    with tempfile.TemporaryDirectory(prefix='dver-brifa-203-') as temp:
        base = Path(temp)
        tools = Path(args.repo).resolve() if args.repo is not None else None
        if args.model or args.stabs:
            tools = materialize(ROOT, base / 'etalon')
        for name in CASES:
            errors, detail = run_cell(base, tools, name, name)
            if errors:
                failures.append(name)
            print(f'{"GREEN" if not errors else "RED"} {name}: {detail}'
                  + (f' errors={errors}' if errors else ''))
        if args.stabs:
            for name, (cell, _file, _old, _new) in sorted(STABS.items()):
                etalon = materialize(ROOT, base / ('etalon-' + name))
                mutate(etalon, name)
                errors, detail = run_cell(base, etalon, cell + '--' + name, cell)
                caught = bool(errors)
                print(f'STAB {name} {"caught" if caught else "ZHIV"} @ {cell}: {detail}')
                if not caught:
                    zhivye.append(name)
    print(f'CELLS={len(CASES)} STABS={len(STABS) if args.stabs else 0} '
          f'FAILURES={len(failures)} ZHIVYH={len(zhivye)}')
    return int(bool(failures or zhivye))


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(2)
