#!/usr/bin/env python3
"""Independent public-door probes for the 187 cutover. Synthetic projects own their .git."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

from probe import world, put, git, run, CONTRACT, REVIEW, TOOLS

# Expected answers are immutable tuples in the verifier, never read back from the subject.
# Mutation is one named coordinate at a time; each mutant is paired with its OWN red case.
CASES = (
    ('task-valid', 'task', '', 0, '', 'task'),
    ('task-line-missing', 'task', 'line-missing', 1, 'ARCH_LINE_MISSING', 'task'),
    ('task-line-blank', 'task', 'line-blank', 1, 'ARCH_LINE_MISSING', 'task'),
    ('task-l3', 'task', 'l3', 1, 'ARCH_OWNER', 'task'),
    ('task-unmapped', 'task', 'unmapped', 1, 'PATH_WITHOUT_COMPONENT', 'task'),
    ('brief-lock', 'task', 'brief-lock', 0, 'PINNED_BRIEF_187', 'task'),
    ('brief-no-local-copy', 'task', 'no-local', 0, 'PINNED_BRIEF_187', 'task'),
    ('brief-with-rules', 'task', 'with-rules', 0, 'RULES_FROM_PIN_187', 'task'),
    ('brief-no-rules', 'task', 'no-rules', 0, 'PINNED_BRIEF_187', 'task'),
    ('freeze-valid', 'freeze', '', 0, '', 'freeze'),
    ('freeze-no-line', 'freeze', 'freeze-no-line', 1, 'ARCH_LINE_MISSING', 'freeze'),
    ('freeze-foreign', 'freeze', 'foreign', 1, 'ARCH_ZONE', 'freeze'),
    ('freeze-unmapped', 'freeze', 'unmapped', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
    ('freeze-draft', 'freeze', 'draft', 1, 'ARCH_DRAFT', 'freeze'),
    ('check-valid', 'precritic', '', 0, '', 'precritic'),
    ('check-failure', 'precritic', 'check-1', 1, 'ARCH_CHECK', 'precritic'),
    ('check-not-evaluated', 'precritic', 'check-2', 1, 'ARCH_NOT_EVALUATED', 'precritic'),
    ('done-valid', 'done', '', 0, '', 'done'),
    ('done-review-missing', 'done', 'review-missing', 1, 'ARCH_REVIEW', 'done'),
    ('done-ci-missing', 'done', 'ci-missing', 1, 'ARCH_CI', 'done'),
    ('done-ci-other-sha', 'done', 'ci-other-sha', 1, 'ARCH_CI', 'done'),
    ('done-ci-red', 'done', 'ci-red', 1, 'ARCH_CI', 'done'),
    ('done-ci-skipped', 'done', 'ci-skipped', 1, 'ARCH_CI', 'done'),
    ('legacy-mob', 'freeze', 'mobile', 0, '', 'freeze'),
    ('legacy-harness', 'freeze', 'harness', 0, '', 'freeze'),
)
STABS = {
    'task-no-line': ('task-line-missing', 'allow-line'),
    'task-blank-accepted': ('task-line-blank', 'allow-line'),
    'structure-dropped': ('task-valid', 'omit-structure'),
    'obsolete-doc-reintroduced': ('task-valid', 'include-old-doc'),
    'task-l3-auto': ('task-l3', 'allow-l3'),
    'task-unmapped-path': ('task-unmapped', 'allow-unmapped'),
    'brief-from-head': ('brief-lock', 'use-head'),
    'brief-requires-local-copy': ('brief-no-local-copy', 'requires-local'),
    'brief-rules-omitted': ('brief-with-rules', 'omit-rules'),
    'brief-rules-leaked': ('brief-no-rules', 'leak-rules'),
    'zone-foreign': ('freeze-foreign', 'allow-zone'),
    'zone-unmapped': ('freeze-unmapped', 'allow-zone'),
    'freeze-line-ignored': ('freeze-no-line', 'allow-zone'),
    'draft-operation': ('freeze-draft', 'allow-draft'),
    'check-not-called': ('check-failure', 'skip-check'),
    'check-rc-ignored': ('check-not-evaluated', 'rc2-green'),
    'reviewer-line-ignored': ('done-review-missing', 'ignore-review'),
    'ci-not-read': ('done-ci-missing', 'ignore-ci'),
    'ci-sha-ignored': ('done-ci-other-sha', 'ignore-ci'),
    'ci-conclusion-ignored': ('done-ci-red', 'ignore-ci'),
    'ci-skipped-green': ('done-ci-skipped', 'ignore-ci'),
    'mob-required': ('legacy-mob', 'require-all'),
    'harness-required': ('legacy-harness', 'require-all'),
}

def architecture(base, root, variation):
    """A separate git repository with A pinned and a later, deliberately different B HEAD."""
    arch = base / (root.name + '-model')
    arch.mkdir()
    git(arch, 'init', '-q', '-b', 'main')
    git(arch, 'config', 'user.name', 'Fixture')
    git(arch, 'config', 'user.email', 'fixture@local')
    git(arch, 'config', 'commit.gpgsign', 'false')
    put(arch, 'package.json', json.dumps({'scripts': {'brief': 'node tooling/checks/cli.js brief',
                                                       'check': 'node tooling/checks/cli.js check'}}))
    put(arch, 'tooling/checks/cli.js', '''const fs=require('fs');
const a=process.argv.slice(2); const name=a[0];
if (name==='brief') {
 const id=a[a.indexOf('--component')+1];
 if(id!=='api.identity') process.exit(1);
 console.log('PINNED_BRIEF_187 '+id);
 if(a.includes('--with-rules')) console.log('RULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed');
} else if(name==='locate') {
 const p=a[a.indexOf('--path')+1];
 if(p.startsWith('app/identity/')) console.log('api.identity');
 else { console.error('PATH_WITHOUT_COMPONENT'); process.exit(1); }
} else if(name==='check') {
 const status=fs.readFileSync('check-rc','utf8').trim();
 if(status==='2') console.log('NOT_EVALUATED');
 process.exit(Number(status));
} else if(name==='finding'&&a[1]==='new') {
 const input=JSON.parse(fs.readFileSync(a[a.indexOf('--input')+1],'utf8'));
 const keys=['module','observed','model','proposed','level','authorStatus'];
 if(keys.some(k=>!input[k])||!['L1','L2','L3'].includes(input.level))process.exit(1);
 const dir='governance/findings'; fs.mkdirSync(dir,{recursive:true});
 const n=fs.readdirSync(dir).filter(f=>/^\\d{3}-/.test(f)).length+1;
 fs.writeFileSync(dir+'/'+String(n).padStart(3,'0')+'-'+a[2]+'.json',JSON.stringify(input));
} else process.exit(2);
''')
    put(arch, 'check-rc', (variation[-1] if variation in ('check-1', 'check-2') else '0') + '\n')
    git(arch, 'add', '-A')
    git(arch, 'commit', '-qm', 'published architecture')
    pinned = git(arch, 'rev-parse', 'HEAD')
    put(arch, 'tooling/checks/cli.js', (arch / 'tooling/checks/cli.js').read_text().replace('PINNED_BRIEF_187', 'WRONG_HEAD_BRIEF_187').replace('RULES_FROM_PIN_187', 'WRONG_HEAD_RULES_187'))
    git(arch, 'add', '-A')
    git(arch, 'commit', '-qm', 'unpublished later architecture')
    put(root, 'architecture.lock.json', json.dumps({'commit': pinned, 'workItem': 'COMPLIOR-777'}))
    return arch, pinned

def ci_bin(root):
    return root.parent / (root.name + '-bin')

def ci_record(root):
    return root.parent / (root.name + '-ci-187.json')

def prepare(root, arch, pinned, variation):
    role = 'implementer' if variation == 'no-rules' else 'architect'
    task = root / 'task-187.md'
    task.write_text('SUBJECT=777\nАРХИТЕКТУРА: L1 api.identity\nЗОНА implementer: app/identity/model.js\n')
    if variation in ('mobile', 'harness'):
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    trace = root / 'trace-187.tsv'
    trace.write_text(role + '\tzai/glm-5.3\tallowed\n')
    # The check-run report is external to the subject repo and names the final SHA.
    record = {'total_count': 1, 'check_runs': [
        {'id': 187, 'name': 'arch', 'status': 'completed', 'conclusion': 'success'}]}
    if variation == 'line-missing':
        task.write_text(task.read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    elif variation == 'line-blank':
        task.write_text(task.read_text().replace('АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: '))
    elif variation == 'no-local':
        for file in (root / 'architecture').rglob('*'):
            if file.is_file(): file.unlink()
        for directory in sorted((root / 'architecture').rglob('*'), reverse=True):
            if directory.is_dir(): directory.rmdir()
        (root / 'architecture').rmdir()
    elif variation == 'freeze-no-line':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    elif variation == 'l3':
        task.write_text(task.read_text().replace('L1 api.identity', 'L3 api.identity'))
    elif variation == 'unmapped':
        task.write_text(task.read_text().replace('app/identity/model.js', 'server/src/auth/evil.js'))
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'server/src/auth/evil.js'))
    elif variation == 'foreign':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'app/billing/evil.js'))
        put(root, 'app/billing/evil.js', 'module.exports=2;\n')
    elif variation == 'draft':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('identity.lookup', 'identity.draft'))
    elif variation == 'review-missing':
        put(root, REVIEW, 'ACCEPT\n')
    # CI report mutations happen after commit: the report must reference the final SHA.
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'isolated scenario ' + (variation or 'valid'))
    if variation == 'no-rules':
        git(root, 'tag', 'frozen/contracts/777/1')
    record['check_runs'][0]['head_sha'] = git(root, 'rev-parse', 'HEAD')
    if variation == 'ci-missing': record = {'total_count': 0, 'check_runs': []}
    if variation == 'ci-other-sha': record['check_runs'][0]['head_sha'] = 'f' * 40
    if variation == 'ci-red': record['check_runs'][0]['conclusion'] = 'failure'
    if variation == 'ci-skipped': record['check_runs'][0]['conclusion'] = 'skipped'
    ci_record(root).write_text(json.dumps(record))
    git(root, 'push', '-q', 'origin', 'main')
    bin_dir = ci_bin(root)
    bin_dir.mkdir()
    fake_curl = bin_dir / 'curl'
    fake_curl.write_text('#!/usr/bin/env bash\n'
                         'case \"${@: -1}\" in *\"/commits/\"*\"/check-runs?\"*) cat \"$ARCH187_CURL_RESPONSE\" ;; *) exit 31 ;; esac\n')
    fake_curl.chmod(0o755)
    return task, trace, role

def verdict(root, arch, pinned, action, task, role, mutant=''):
    profile = json.loads((root / 'harness.project.json').read_text())
    if profile['repoId'] != 'Complior-back' and mutant != 'require-all':
        return 0, ''
    contract = (root / CONTRACT).read_text()
    if action == 'task':
        text = task.read_text()
        if (not any(line.startswith('АРХИТЕКТУРА: L1 ') or line.startswith('АРХИТЕКТУРА: L2 ')
                    or line.startswith('АРХИТЕКТУРА: L3 ') for line in text.splitlines())) and mutant != 'allow-line':
            return 1, 'ARCH_LINE_MISSING'
        if 'АРХИТЕКТУРА: L3 ' in text and mutant != 'allow-l3':
            return 1, 'ARCH_OWNER'
        if 'server/src/auth/' in text and mutant != 'allow-unmapped':
            return 1, 'PATH_WITHOUT_COMPONENT'
        revision = git(arch, 'rev-parse', 'HEAD') if mutant == 'use-head' else pinned
        if mutant == 'requires-local' and not (root / 'architecture').exists():
            return 1, 'ARCHITECTURE_NET'
        model = git(arch, 'show', revision + ':tooling/checks/cli.js')
        banner = 'PINNED_BRIEF_187' if 'PINNED_BRIEF_187' in model else 'WRONG_HEAD_BRIEF_187'
        result = banner + ' api.identity'
        needs_rules = role in ('architect', 'critic', 'arbiter')
        if mutant == 'omit-rules': needs_rules = False
        if mutant == 'leak-rules': needs_rules = True
        if needs_rules:
            result += '\\nRULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed'
        if mutant != 'omit-structure': result += '\nSTRUCTURE.md'
        if mutant == 'include-old-doc': result += '\ndocs/ARCHITECTURE.md'
        return 0, result
    if action == 'freeze':
        if not any(line.startswith('АРХИТЕКТУРА: L1 ') for line in contract.splitlines()) and mutant not in ('allow-zone', 'require-all'):
            return 1, 'ARCH_LINE_MISSING'
        if 'identity.draft' in contract and mutant != 'allow-draft':
            return 1, 'ARCH_DRAFT'
        if 'server/src/auth/' in contract and mutant != 'allow-zone':
            return 1, 'PATH_WITHOUT_COMPONENT'
        if 'app/billing/' in contract and mutant != 'allow-zone':
            return 1, 'ARCH_ZONE'
        return (1, 'ARCH_LINE_MISSING') if mutant == 'require-all' else (0, '')
    if action == 'precritic':
        check_rc = int(git(arch, 'show', pinned + ':check-rc').strip())
        if check_rc == 2 and mutant != 'rc2-green': return 1, 'ARCH_NOT_EVALUATED'
        if check_rc and mutant != 'skip-check': return 1, 'ARCH_CHECK'
        return 0, ''
    if action == 'done':
        if 'СВЕРКА-АРХИТЕКТУРЫ:' not in (root / REVIEW).read_text() and mutant != 'ignore-review':
            return 1, 'ARCH_REVIEW'
        response = json.loads(ci_record(root).read_text())
        runs = response['check_runs']
        arch_runs = [r for r in runs if r.get('name') == 'arch']
        if mutant != 'ignore-ci' and (not arch_runs or
                                      arch_runs[-1].get('head_sha') != git(root, 'rev-parse', 'HEAD') or
                                      arch_runs[-1].get('status') != 'completed' or
                                      arch_runs[-1].get('conclusion') != 'success'):
            return 1, 'ARCH_CI'
        return 0, ''
    raise RuntimeError('unknown action')

def live(tools, root, arch, pinned, action, task, trace, role):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(root), ARCHITECTURE_ROOT=str(arch))
    if action == 'done':
        env['ARCH187_CURL_RESPONSE'] = str(ci_record(root))
        env['PATH'] = str(ci_bin(root)) + os.pathsep + env.get('PATH', '')
    if action == 'task':
        command = ['bash', tools / 'scripts/make_task.sh', '--repo', root, '--role', role,
                   '--kind', 'task', '--contract', '777', '--task-file', task,
                   '--model-trace', trace, '--arch-component', 'api.identity']
    else:
        command = {'freeze': ['bash', tools / 'scripts/freeze_contract.sh', CONTRACT, 'toy reason', root],
                   'precritic': ['bash', tools / 'scripts/pre_critic.sh', '--repo', root, CONTRACT],
                   'done': ['bash', tools / 'scripts/done_contract.sh', CONTRACT, 'toy reason', root]}[action]
    return run(*command, cwd=root, env=env)

def main():
    import argparse
    p = argparse.ArgumentParser()
    modes = p.add_mutually_exclusive_group()
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--repo', type=Path)
    args = p.parse_args()
    tools = args.repo.resolve() if args.repo else TOOLS
    failures = []
    with tempfile.TemporaryDirectory(prefix='workflow-187-') as temp:
        base = Path(temp)
        for label, action, variation, expected, reason, _ in CASES:
            kind = 'mobile' if variation == 'mobile' else 'harness' if variation == 'harness' else 'backend'
            root = world(base, label, kind)
            arch, pinned = architecture(base, root, variation)
            task, trace, role = prepare(root, arch, pinned, variation)
            honest_rc, honest_out = verdict(root, arch, pinned, action, task, role)
            if honest_rc != expected or (reason and reason not in honest_out):
                raise RuntimeError(f'broken fixture: {label} expected {expected}/{reason}, got {honest_rc}/{honest_out}')
            if args.model or args.stabs:
                rc, output = honest_rc, honest_out
            else:
                result = live(tools, root, arch, pinned, action, task, trace, role)
                rc, output = result.returncode, result.stdout + result.stderr
            ok = (rc == expected and (not reason or reason in output))
            if action == 'task' and not expected:
                if 'PINNED_BRIEF_187' not in output or 'WRONG_HEAD_BRIEF_187' in output:
                    ok = False
                if 'STRUCTURE.md' not in output or 'docs/ARCHITECTURE.md' in output:
                    ok = False
                if role == 'implementer' and 'RULES_FROM_PIN_187' in output:
                    ok = False
                if role in ('architect', 'critic', 'arbiter') and 'RULES_FROM_PIN_187' not in output:
                    ok = False
            if not args.model and not args.stabs and expected and action in ('freeze', 'done'):
                marker = 'frozen' if action == 'freeze' else 'done'
                if git(root, 'tag', '-l', marker + '/contracts/777/*'): ok = False
            if not ok: failures.append(label)
            print(f'{"GREEN" if ok else "RED"} {label}: rc={rc} expected={expected}' +
                  (f' reason={reason}' if reason else '') + (f' output={output[:350]!r}' if not ok else ''))
            if args.stabs:
                for name, (case, mutant) in STABS.items():
                    if case != label: continue
                    fake_rc, fake_out = verdict(root, arch, pinned, action, task, role, mutant)
                    caught = fake_rc != expected or (reason and reason not in fake_out)
                    if not expected and action == 'task':
                        caught = caught or ('PINNED_BRIEF_187' not in fake_out or
                            'WRONG_HEAD_BRIEF_187' in fake_out or
                            'STRUCTURE.md' not in fake_out or
                            'docs/ARCHITECTURE.md' in fake_out or
                            (role == 'implementer' and 'RULES_FROM_PIN_187' in fake_out) or
                            (role in ('architect', 'critic', 'arbiter') and 'RULES_FROM_PIN_187' not in fake_out))
                    print(f'STAB {name} {"caught" if caught else "ZHIV"} @ {label}')
                    if not caught: failures.append(name)
        print(f'CELLS={len(CASES)} STABS={len(STABS) if args.stabs else 0} FAILURES={len(failures)}')
    return int(bool(failures))

if __name__ == '__main__':
    raise SystemExit(main())
