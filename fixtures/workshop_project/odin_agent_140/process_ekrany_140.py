#!/usr/bin/env python3
"""R0191: real task-hook seam; immutable expectations precede the subject.

No production writes, network, primary .git, or clone cleanup. Worlds and raw
logs remain in the caller's --evidence directory (inside its own tree).
"""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CURRENT = '0a52424e06fe5cdd9929f455f45f7e173ff84427'
HOOK = '.omp/extensions/spawn-guard.ts'
POLICY_PATH = 'docs/context/OWNER-DECISIONS-F0.md'
POLICY_BLOB = '215246a1f0ddbe374797bc845dc8c5ea5aa65ff0'
MODEL = 'openai-codex/gpt-6.1-sol'
REMOTE = 'https://github.com/a3ka/Complior-mob.git'
ENV = {**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_SYSTEM': '/dev/null',
       'GIT_AUTHOR_NAME': 'architect', 'GIT_AUTHOR_EMAIL': 'architect@dev-harness.local',
       'GIT_COMMITTER_NAME': 'architect', 'GIT_COMMITTER_EMAIL': 'architect@dev-harness.local',
       'PYTHONDONTWRITEBYTECODE': '1'}
for key in ('GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE'):
    ENV.pop(key, None)

DRIVER = r'''import {pathToFileURL} from 'node:url';
import {readFileSync} from 'node:fs';
import childProcess from 'node:child_process';
import {syncBuiltinESMExports} from 'node:module';
const calls = [];
const real = childProcess.spawnSync;
childProcess.spawnSync = (...args) => {
  const result = real(...args);
  if (args[1]?.includes('--sudit')) calls.push({argv:args[1],rc:result.status,
    stdout:result.stdout,stderr:result.stderr});
  return result;
};
syncBuiltinESMExports();
const [hook, inputFile, session] = process.argv.slice(2);
const mod = await import(pathToFileURL(hook).href);
const handlers = [];
mod.default({on: (name, fn) => {if (name === 'tool_call') handlers.push(fn);}});
if (handlers.length !== 1) throw Error('handler cardinality');
const event = JSON.parse(readFileSync(inputFile, 'utf8'));
const result = await handlers[0](event, {sessionManager:{getSessionFile:()=>session}});
console.log(JSON.stringify({result:result??null,calls}));
'''

# name -> (expected block token or None, real door calls).
# None means actual hook permission with no subject-lock state change.
CASES = {
    'honest': (None, 0), 'flat': (None, 0), 'ssh': (None, 0),
    'title-header': (None, 0), 'other-name': (None, 0),
    'prose-only': ('SUBJECT_NET_V_ZADANII', 1),
    'ordinary': ('SUBJECT_NET_V_ZADANII', 1),
    'foreign': ('PROCESS_EKRANY_REMOTE', 0),
    'policy-forged': ('PROCESS_EKRANY_POLICY', 0),
    'policy-mode': ('PROCESS_EKRANY_POLICY', 0),
    'policy-dirty': (None, 0),
    'unpublished': ('PROCESS_EKRANY_NEDOSTUPEN', 0),
    'stale-object': ('PROCESS_EKRANY_OBJECT', 0),
    'wrong-head': ('PROCESS_EKRANY_OBJECT', 0),
    'wrong-line': ('PROCESS_EKRANY_PIN', 0),
    'wrong-session': ('PROCESS_EKRANY_SESSION', 0),
    'wrong-session-cwd': ('PROCESS_EKRANY_SESSION', 0),
    'missing-session': ('PROCESS_EKRANY_NEDOSTUPEN', 0),
    'message-session': ('PROCESS_EKRANY_SESSION', 0),
    'wrong-pin': ('PROCESS_EKRANY_SESSION', 0),
    'wrong-model': ('PROCESS_EKRANY_MODEL', 0),
    'model-in-prose': ('PROCESS_EKRANY_MODEL', 0),
    'wrong-role': ('PROCESS_EKRANY_MODEL', 0),
    'duplicate-object': ('PROCESS_EKRANY_PIN', 0),
    'duplicate-process': ('PROCESS_EKRANY_KONTEKST', 0),
    'fake-process': ('PROCESS_EKRANY_KONTEKST', 0),
    'mixed-batch': ('PROCESS_EKRANY_PAKET', 0),
    'two-special': ('PROCESS_EKRANY_PAKET', 0),
    'bad-alphabet': ('тип агента вне алфавита', 0),
    'default-agent': ('спавн без явного agent', 0),
    'missing-install-config': ('конфиг установленного харнеса не читается', 0),
    'env-pin': (None, 0), 'other-tool': (None, 0),
}
# Each mutant is bound only to inputs where its defect is observable.
MUTATIONS = {
    'policy': ("if (git('ls-tree', object, '--', POLICY.policyPath) !==\n        `100644 blob ${POLICY.policyBlob}\\t${POLICY.policyPath}`)", "if (false)", ['policy-forged', 'policy-mode']),
    'remote': ("if (![POLICY.remote,", "if (false && ![POLICY.remote,", ['foreign']),
    'model': ("item.model !== POLICY.model", "false", ['wrong-model', 'model-in-prose']),
    'session': ("basename(sessionFile) !== session + '.jsonl'", "false", ['wrong-session']),
    'cwd': ("realpathSync(header.cwd) !== realpathSync(process.cwd())", "false", ['wrong-session-cwd']),
    'pin': ("realpathSync(worktree) !== realpathSync(process.cwd())", "false", ['wrong-pin']),
    'publication': ("git('rev-parse', '--verify', `refs/remotes/origin/${branch}^{commit}`) !== object", "false", ['unpublished']),
    'head': ("git('rev-parse', '--verify', 'HEAD^{commit}') !== object", "false", ['wrong-head']),
    'batch': ("if (items.length !== 1)", "if (false)", ['mixed-batch', 'two-special']),
}


def run(argv, cwd, check=True):
    result = subprocess.run(argv, cwd=cwd, env=ENV, capture_output=True, text=True, timeout=30)
    if check and result.returncode:
        raise RuntimeError(f'{argv!r}: rc={result.returncode}\n{result.stdout}\n{result.stderr}')
    return result


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise ValueError(f'anchor cardinality: {old!r}')
    return text.replace(old, new)


def git(repo, *args):
    return run(['git', '-C', str(repo), *args], repo).stdout.strip()


def snapshot(root):
    return {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in root.rglob('*') if p.is_file()}


def private_session_paths(world, session, event):
    """Check physical parents before creating synthetic state or invoking a hook."""
    try:
        root = world.resolve(strict=True)
        if not root.is_dir():
            raise ValueError('world is not a directory')
        def physical(path):
            if not path.is_absolute() or '..' in path.parts:
                raise ValueError(f'noncanonical path: {path}')
            parent, missing = path, []
            while True:
                try:
                    parent.lstat()
                    break
                except FileNotFoundError:
                    missing.append(parent.name)
                    parent = parent.parent
            resolved = parent.resolve(strict=True)
            if missing and not resolved.is_dir():
                raise ValueError(f'parent is not a directory: {parent}')
            if not resolved.is_relative_to(root):
                raise ValueError(f'physical parent outside world: {path} -> {resolved}')
            return resolved.joinpath(*reversed(missing))
        text = str(session)
        prefix, marker, _ = text.partition('/zones/')
        journal, separator, _ = text.rpartition('/agent/sessions/')
        if not marker or not separator:
            raise ValueError('synthetic session layout is not recognized')
        paths = {
            'sessionFile': session,
            'state': Path(prefix) / 'zamok',
            'journal': Path(journal) / 'agent/sessions',
            # The hook chooses a fresh random basename in this physical parent.
            'hookEventParent': Path(prefix),
            'inputEvent': event,
        }
        actual = {name: physical(path) for name, path in paths.items()}
        if actual['hookEventParent'] != physical(world / 'state'):
            raise ValueError('first /zones/ does not select this world state')
        return {name: str(path) for name, path in actual.items()}
    except (OSError, RuntimeError, ValueError) as error:
        raise ValueError(f'UNSAFE_SESSION_ROOT: {error}') from error


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--repo', type=Path, help='assembled production tree; default: published current snapshot')
    ap.add_argument('--preflight', action='store_true', help='check physical paths only; never import or run the hook')
    ap.add_argument('--evidence', required=True, type=Path)
    args = ap.parse_args()
    evidence = args.evidence.resolve()
    if not evidence.is_relative_to(ROOT):
        raise ValueError('evidence must be inside own native copy')
    evidence.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='worlds-', dir=evidence))
    if args.preflight:
        paths = private_session_paths(
            work, work / 'state/zones/dev/.omp/profiles/dev/agent/sessions/c/p/Lead.jsonl',
            work / 'event.json')
        print(json.dumps({'world': str(work), 'paths': paths}, ensure_ascii=False), flush=True)
        return 0
    def source(path):
        if args.repo:
            return (args.repo.resolve() / path).read_text()
        return git(ROOT, 'show', CURRENT + ':' + path) + '\n'
    hook, door, config = map(source, (HOOK, 'scripts/zamok_predmeta.sh', 'config/agent_models.json'))
    reference = (HERE / 'model/process_ekrany_140.ts').read_text()
    policy = (HERE / 'materialy/owner-decisions-f0-r0191.md').read_bytes()
    # All expectations, policies and input bytes are captured before any hook executes.
    blob = hashlib.sha1(b'blob ' + str(len(policy)).encode() + b'\0' + policy).hexdigest()
    if blob != POLICY_BLOB:
        raise ValueError('ORACLE_TAMPERED: published policy fixture')
    anchor = '      // Событие — во временный файл ВНУТРИ корня состояний:'
    injection = '''      const processDecision = processEkrany(call.input, sessionFile);
      if (processDecision.kind === 'block') return {block:true, reason:processDecision.reason};
      if (processDecision.kind === 'pass') return undefined;
'''
    driver = work / 'driver.mjs'
    driver.write_text(DRIVER)
    records = []
    def cell(namespace, label, name, model_text=None, special=None):
        base = work / namespace / label / name
        base.mkdir(parents=True)
        install = base / 'install'
        for path, content in ((HOOK, hook), ('scripts/zamok_predmeta.sh', door),
                              ('config/agent_models.json', config)):
            dest = install / path
            dest.parent.mkdir(parents=True, exist_ok=True)
            if name != 'missing-install-config' or not path.startswith('config/'):
                dest.write_text(content)
        target_hook = hook
        if model_text is not None:
            (install / 'process.ts').write_text(model_text)
            target_hook = "import {processEkrany} from '../../process.ts';\n" + replace_once(hook, anchor, injection + anchor)
        if special == 'alphabet':
            target_hook = replace_once(target_hook, 'if (verdict !== undefined) return verdict;', 'if (false) return verdict;')
        if special == 'text':
            target_hook = replace_once(target_hook, '      const processDecision = processEkrany(call.input, sessionFile);',
                "      if (JSON.stringify(call.input).includes('Ф0')) return undefined;\n      const processDecision = processEkrany(call.input, sessionFile);")
        (install / HOOK).write_text(target_hook)
        repo = base / 'product'
        repo.mkdir()
        git(repo, 'init', '-q')
        git(repo, 'remote', 'add', 'origin', REMOTE if name != 'foreign' else 'https://github.com/other/Complior-mob.git')
        if name == 'ssh':
            git(repo, 'remote', 'set-url', 'origin', 'ssh://git@github.com/a3ka/Complior-mob.git')
        path = repo / POLICY_PATH
        path.parent.mkdir(parents=True)
        path.write_bytes(policy + (b'forged\n' if name == 'policy-forged' else b''))
        if name == 'policy-mode': path.chmod(0o755)
        git(repo, 'add', '.')
        git(repo, 'commit', '-qm', 'published screen policy')
        old = git(repo, 'rev-parse', 'HEAD')
        (repo / 'screen.txt').write_text('real screen payload\n')
        git(repo, 'add', '.')
        git(repo, 'commit', '-qm', 'screen line')
        obj = git(repo, 'rev-parse', 'HEAD')
        if name != 'unpublished':
            git(repo, 'update-ref', 'refs/remotes/origin/f0/L1', obj)
        if name == 'policy-dirty':
            path.write_text('dirty checkout is not policy truth\n')
        requested = old if name == 'stale-object' else obj
        if name == 'wrong-head':
            git(repo, 'switch', '--detach', old)
        state = base / 'state'
        session = state / 'zones/dev/.omp/profiles/dev/agent/sessions/c/p/Lead.jsonl'
        eventfile = base / 'event.json'
        private_session_paths(base, session, eventfile)
        session.parent.mkdir(parents=True)
        header = {'type':'session', 'version':3, 'id':'runtime-uuid', 'cwd':str(repo)}
        if name == 'wrong-session-cwd':
            header['cwd'] = str(install)
        if name == 'message-session':
            header = {'type':'message', 'message':{'role':'user', 'text':json.dumps(header)}}
        if name != 'missing-session':
            session.write_text((json.dumps({'type':'title','title':''})+'\n' if name == 'title-header' else '') + json.dumps(header)+'\n')
        task = '\n'.join(['PROCESS=PROCESS-EKRANY','LINE=L1','OBJECT='+requested,
                          'SESSION=Lead','WORKTREE='+str(repo),'BRANCH=f0/L1'])
        if name in ('ordinary', 'prose-only'):
            task = 'ordinary engineering task' + (' Ф0 PROCESS-EKRANY' if name == 'prose-only' else '')
        changes = {'wrong-line':('LINE=L1','LINE=L2'), 'wrong-session':('SESSION=Lead','SESSION=Other'),
                   'wrong-pin':('WORKTREE='+str(repo),'WORKTREE='+str(install)),
                   'fake-process':('PROCESS=PROCESS-EKRANY','PROCESS=F0')}
        if name in changes:
            task = task.replace(*changes[name])
        if name == 'duplicate-object': task += '\nOBJECT='+obj
        if name == 'duplicate-process': task += '\nPROCESS=PROCESS-EKRANY'
        item = {'agent':'reviewer','name':'ReviewerF0','model':MODEL,'task':task}
        if name == 'other-name': item['name'] = 'FreshReviewer.2'
        if name == 'wrong-model': item['model'] = 'wrong/model'
        if name == 'model-in-prose':
            item.pop('model'); item['task'] += '\nmodel='+MODEL
        if name == 'wrong-role': item['agent'] = 'critic'
        if name == 'bad-alphabet': item['agent'] = 'evil'
        if name == 'default-agent': item['agent'] = 'task'
        items = [item]
        if name == 'mixed-batch': items.append({'agent':'architect','name':'Ordinary','task':'SUBJECT=140','isolated':False})
        if name == 'two-special': items.append(copy.deepcopy(item))
        event = {'toolName':'task','input':item if name == 'flat' else {'tasks':items}}
        if name == 'other-tool': event['toolName'] = 'read'
        eventfile.write_text(json.dumps(event))
        before = snapshot(state)
        # Recheck all physical parents immediately before the subject, including
        # missing-session and not-yet-created state/event paths. No alias/fallback.
        private_session_paths(base, session, eventfile)
        saved = dict(ENV)
        if name == 'env-pin': ENV.update({'HARNESS_TOOLS_ROOT':str(repo),'OMP_SESSION_FILE':'/fake','ODIN140':'pass'})
        try:
            result = run(['node', str(driver), str(install / HOOK), str(eventfile), str(session)], repo, check=False)
        finally:
            ENV.clear(); ENV.update(saved)
        (base / 'stdout.log').write_text(result.stdout)
        (base / 'stderr.log').write_text(result.stderr)
        expected, calls = CASES[name]
        reason = ''
        try:
            got = json.loads(result.stdout)
            blocked = got['result']
            ok = result.returncode == 0 and len(got['calls']) == calls
            ok &= blocked is None if expected is None else bool(blocked and blocked.get('block') is True and expected in blocked.get('reason',''))
            # A rejected ordinary event may create an empty zamok directory, not files.
            ok &= snapshot(state) == before
            reason = json.dumps(got, ensure_ascii=False)
        except (ValueError, KeyError, TypeError):
            ok = False
            reason = result.stderr
        print(f'F0 {label} {name} {"OK" if ok else "KRASNO"} {reason}', flush=True)
        records.append({'label':label,'case':name,'ok':bool(ok),'argv':['node',str(driver),str(install/HOOK),str(eventfile),str(session)],'rc':result.returncode})
        return bool(ok)
    baseline = args.model or args.stabs
    outcomes = [cell('baseline', 'model' if baseline else 'production', name, reference if baseline else None) for name in CASES]
    if args.stabs and all(outcomes):
        for label, (old, new, targets) in MUTATIONS.items():
            changed = replace_once(reference, old, new)
            for name in targets:
                outcomes.append(not cell('mutations', label, name, changed))
            outcomes.append(cell('controls', label, 'honest', changed))
        for label, target in [('alphabet','bad-alphabet'), ('text','prose-only')]:
            outcomes.append(not cell('hook-mutations', label, target, reference, label))
            outcomes.append(cell('hook-controls', label, 'honest', reference, label))
    report = evidence / ('stabs.json' if args.stabs else 'model.json' if args.model else 'production.json')
    report.write_text(json.dumps(records, ensure_ascii=False, indent=2)+'\n')
    print(f'F0_RESULTS CHECKS={len(outcomes)} BAD={sum(not x for x in outcomes)} REPORT={report}', flush=True)
    return 0 if all(outcomes) else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(f'NOT_IMPLEMENTED: {error}', file=sys.stderr)
        sys.exit(2)
