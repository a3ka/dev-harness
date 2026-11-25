#!/usr/bin/env python3
"""203: real make_task, independent in-memory byte oracle, offline Git/Node worlds."""
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
from probe import world, put, git, CONTRACT  # noqa: E402
from model import materialize  # noqa: E402
from stabs import STABS, mutate  # noqa: E402

ROLES = ('architect', 'critic', 'arbiter', 'implementer', 'adversary', 'reviewer')
CASES = ('dependencies', 'lock-different', 'lock-same-size', 'donor-lock-missing',
         'pin-lock-missing', 'modules-missing', 'dependency-free', 'budget-small',
         'budget-large', 'budget-utf8', 'stderr-first', 'stderr-second',
         'stderr-empty', 'stderr-unicode', *(f'rules-{role}' for role in ROLES),
         'two-components')
DEP_CASES = {'dependencies', 'lock-different', 'lock-same-size', 'donor-lock-missing',
             'pin-lock-missing', 'modules-missing'}
REFUSE_DEPS = DEP_CASES - {'dependencies'}
BUDGET_CASES = {'budget-large', 'budget-utf8'}
CLI = r'''const fs = require('node:fs');
const args = process.argv.slice(2);
if (args[0] === 'locate') {
  console.log(JSON.stringify({status:'DECLARED', scope:'DECLARED_PLACEMENT_ONLY',
    path:args[2], matches:[{module:'module.identity', components:['api.identity'],
    specification:'system/identity/module.js', explicit:true, matched:'app/identity/'}]}));
} else if (args[0] === 'brief') {
  const id = args[args.indexOf('--component') + 1];
  fs.appendFileSync(process.env.BRIEF203_LOG, id + '\n');
  const data = JSON.parse(fs.readFileSync('brief-data.json', 'utf8'));
  if (data.dependency) require('brief-dependency-203');
  if (data.fail === id) {
    process.stdout.write('partial output before rc 17\n');
    process.stderr.write(data.stderr);
    process.exitCode = 17;
  } else {
    process.stdout.write(data[id] + (args.includes('--with-rules') ? data.rules : ''));
  }
} else { process.exitCode = 1; }
'''


@dataclass(frozen=True)
class Expected:
    rc: int
    components: tuple
    briefs: tuple
    reason: str = ''
    hint: str = ''
    called: tuple = ()


def setup(base, case):
    product = world(base, case)
    # Product 187 fixtures have deliberately stale architecture/. The source of
    # this battery is pinned and must ignore it, exactly as on the real backend.
    arch = base / (case + '-architecture')
    arch.mkdir()
    git(arch, 'init', '-q', '-b', 'main')
    git(arch, 'config', 'user.name', 'Fixture')
    git(arch, 'config', 'user.email', 'fixture@local')
    git(arch, 'config', 'core.hooksPath', '/dev/null')
    git(arch, 'config', 'commit.gpgsign', 'false')
    dependency = case in DEP_CASES
    package = {'name':'brief-world', 'version':'1.0.0'}
    if dependency:
        package['dependencies'] = {'brief-dependency-203':'1.0.0'}
    put(arch, 'package.json', json.dumps(package))
    lock = json.dumps({'name':'brief-world', 'lockfileVersion':3, 'packages':{
        '': package, 'node_modules/brief-dependency-203': {'version':'1.0.0'}}}) + '\n'
    if dependency and case != 'pin-lock-missing':
        put(arch, 'package-lock.json', lock)
    put(arch, 'tooling/checks/cli.js', CLI)
    # Canonical complete text is held in memory BEFORE invoking the subject.
    first = ('# api.identity\nDeclaration: system/identity/module.js\n'
             'Product placement: app/identity/\n## Own contracts\n'
             'identity.lookup READY input schema.query output schema.record\n'
             'semanticInvariant: lookup does not write\n'
             'writers: identity.owner\nisolationKeys: scope_id\n'
             '## Neighbour ports (signatures only)\nemail.send(schema.mail) -> schema.sent\n'
             '## Resources and requirements\nresource.identity; requirement.account\n')
    second = '# worker.events\nwriter event.owner; isolationKeys tenant_id\n'
    if case == 'budget-small':
        first += 'x' * 24000 + '\nEND_OF_COMPLETE_BRIEF\n'
    if case == 'budget-large':
        first += 'x' * 91445 + '\nEND_OF_COMPLETE_BRIEF\n'
    if case == 'budget-utf8':
        first += 'я' * 22000 + '\nEND_OF_COMPLETE_BRIEF\n'
    rules = '## Model fitness rules\nRULE203: model evidence only\n'
    ids = ('api.identity', 'worker.events') if case in {'two-components', 'stderr-second'} else ('api.identity',)
    role = case.removeprefix('rules-') if case.startswith('rules-') else 'architect'
    fail = ids[-1] if case.startswith('stderr-') else ''
    diagnostic = 'FIRST_CAUSE_203: dependency could not open input\nSECOND_CAUSE_203: never select this\n'
    if case == 'stderr-empty': diagnostic = ''
    if case == 'stderr-unicode': diagnostic = 'Ошибка\t' + 'я' * 240 + '\r\nlast line\n'
    data = {'dependency':dependency, 'api.identity':first, 'worker.events':second,
            'rules':rules, 'fail':fail, 'stderr':diagnostic}
    put(arch, 'brief-data.json', json.dumps(data))
    git(arch, 'add', '.')
    git(arch, 'commit', '-qm', 'pinned architecture A')
    pin = git(arch, 'rev-parse', 'HEAD')
    # Move HEAD without changing the donor lock: matching lock != use HEAD code.
    put(arch, 'brief-data.json', json.dumps({**data, 'api.identity':'WRONG_HEAD_203\n'}))
    git(arch, 'add', '.')
    git(arch, 'commit', '-qm', 'later architecture B')
    if dependency and case != 'modules-missing':
        put(arch, 'node_modules/brief-dependency-203/index.js', 'module.exports = 203;\n')
    if case in {'lock-different', 'lock-same-size'}:
        # Same basename, different content; second variant also has same byte count.
        put(arch, 'package-lock.json', lock.replace('1.0.0', '2.0.0') if case == 'lock-same-size' else lock + ' ')
    if case == 'donor-lock-missing': (arch / 'package-lock.json').unlink()
    put(product, 'architecture.lock.json', json.dumps({'commit':pin}))
    task = product / 'task203.md'
    task.write_text('SUBJECT=777\nАРХИТЕКТУРА: L1 api.identity,worker.events\nЗОНА implementer: app/identity/\n')
    trace = product / 'trace203.tsv'
    trace.write_text(''.join(item + '\tzai/glm-5.3\tallowed\n' for item in ROLES))
    git(product, 'add', '.')
    git(product, 'commit', '-qm', '203 pinned task')
    git(product, 'tag', 'frozen/contracts/777/1')
    rc, reason, hint = 0, '', ''
    called = ids
    if case in REFUSE_DEPS:
        rc, reason, hint, called = 1, 'ARCH_BRIEF_DEPS', 'npm ci', ()
    elif case in BUDGET_CASES:
        rc, reason, hint = 1, 'ARCH_BRIEF_BUDGET', 'сузьте --arch-component или разделите задание'
    elif fail:
        rc, reason = 1, 'ARCH_BRIEF_OTKAZ'
        hint = (diagnostic.splitlines()[0].replace('\t', ' ')[:200] if diagnostic else '17')
    suffix = rules if role in {'architect', 'critic', 'arbiter'} else ''
    texts = tuple((first if comp == 'api.identity' else second) + suffix for comp in ids)
    return product, arch, task, trace, role, Expected(rc, ids, texts, reason, hint, called)


def evaluate(tools, base, case):
    product, arch, task, trace, role, expected = setup(base, case)
    log = base / (case + '.calls')
    env = {k:v for k,v in os.environ.items() if not k.startswith('GIT_') and k not in {'NODE_PATH', 'NODE_OPTIONS'}}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(product), ARCHITECTURE_ROOT=str(arch),
               BRIEF203_LOG=str(log))
    before_lock = (arch / 'package-lock.json').read_bytes() if (arch / 'package-lock.json').exists() else None
    command = ['bash', str(tools / 'scripts/make_task.sh'), '--repo', str(product),
               '--role', role, '--kind', 'task', '--contract', '777', '--task-file', str(task),
               '--model-trace', str(trace), '--arch-component', ','.join(expected.components)]
    result = subprocess.run(command, cwd=product, env=env, capture_output=True, timeout=45)
    out = result.stdout.decode('utf8')
    err = result.stderr.decode('utf8')
    first_error = err.splitlines()[0] if err else ''
    errors = []
    if result.returncode != expected.rc: errors.append(f'rc={result.returncode} expected={expected.rc}')
    if expected.rc:
        if out: errors.append('partial stdout')
        if not first_error.startswith('ОТКАЗ: ' + expected.reason + ':'): errors.append('named refusal missing')
        if expected.hint not in first_error: errors.append('first cause/recommendation missing')
        if expected.reason == 'ARCH_BRIEF_OTKAZ' and expected.components[-1] not in first_error:
            errors.append('failing component missing')
        if expected.reason == 'ARCH_BRIEF_BUDGET' and ('40000' not in first_error or
                any(comp not in first_error for comp in expected.components)):
            errors.append('budget/component missing')
        if (product / '.omp/context/777.tsv').exists(): errors.append('success manifest on refusal')
    else:
        prefix, separator, tail = out.partition('=== ARCHITECTURE BRIEF ===\n')
        wanted = ''.join('COMPONENT: ' + comp + '\n' + text.rstrip('\n') + '\n'
                         for comp, text in zip(expected.components, expected.briefs))
        if not separator or not tail.startswith(wanted) or not tail[len(wanted):].startswith('=== '):
            errors.append('complete pinned brief differs')
        if 'MAP: STRUCTURE.md ::' not in prefix: errors.append('structure map missing')
        if 'WRONG_HEAD_203' in out: errors.append('HEAD used')
        body, _, budget_tail = out.rpartition('=== MANIFEST ===\n')
        if len(body.encode()) > 40000: errors.append('cap raised')
        if f'BUDGET: vklejka={len(body.encode())}/40000\n' not in budget_tail: errors.append('budget count differs')
        if not (product / '.omp/context/777.tsv').is_file(): errors.append('success manifest missing')
    calls = tuple(log.read_text().splitlines()) if log.exists() else ()
    if calls != expected.called: errors.append(f'brief calls={calls!r} expected={expected.called!r}')
    after_lock = (arch / 'package-lock.json').read_bytes() if (arch / 'package-lock.json').exists() else None
    if before_lock != after_lock: errors.append('donor lock changed')
    if case == 'dependencies' and not (arch / 'node_modules/brief-dependency-203/index.js').is_file():
        errors.append('donor removed during cleanup')
    return errors, f'rc={result.returncode} stderr={first_error!r}'


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--repo', type=Path)
    args = parser.parse_args()
    for command in ('bash', 'git', 'node', 'jq', 'python3', 'tar', 'cmp'):
        if not shutil.which(command):
            print('INFRASTRUCTURE: missing ' + command, file=sys.stderr)
            return 2
    failures, living = 0, 0
    with tempfile.TemporaryDirectory(prefix='brief203-') as directory:
        base = Path(directory)
        tools = materialize(ROOT, base / 'model') if args.model or args.stabs else (args.repo or ROOT).resolve()
        for case in CASES:
            scratch = base / ('honest-' + case)
            scratch.mkdir()
            errors, evidence = evaluate(tools, scratch, case)
            failures += bool(errors)
            print(('RED' if errors else 'GREEN') + f' {case}: {evidence}' + ('; ' + ', '.join(errors) if errors else ''))
        if args.stabs:
            if not STABS: raise RuntimeError('empty stabs')
            for name, (case, *_rest) in STABS.items():
                if case not in CASES: raise RuntimeError('unknown binding ' + case)
                mutant = base / ('mutant-' + name)
                shutil.copytree(tools, mutant, symlinks=True)
                mutate(mutant, name)
                scratch = base / ('stab-' + name)
                scratch.mkdir()
                errors, evidence = evaluate(mutant, scratch, case)
                living += not bool(errors)
                print(f'STAB {name} @ {case}: ' + ('CAUGHT' if errors else 'ZHIV') + ' ' + evidence)
        print(f'CELLS={len(CASES)} FAILURES={failures} STABS={len(STABS) if args.stabs else 0} ZHIVYH={living}')
    return int(bool(failures or living))


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.SubprocessError, UnicodeError) as error:
        print('INFRASTRUCTURE: ' + str(error), file=sys.stderr)
        raise SystemExit(2)
