#!/usr/bin/env python3
"""PATH-only systemd/omp substitutes; never delegate to station binaries."""
import fcntl
import json
import os
from pathlib import Path
import signal
import sys
import time

root = Path(os.environ['TOY_ROOT']).resolve()
assert root.name.startswith('orch997-') and (root / 'repo/.git').is_dir()
control = root / 'control'

def event(kind, **fields):
    with (control / 'events').open('a') as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        stream.write(json.dumps(dict(kind=kind, pid=os.getpid(), **fields)) + '\n')
        stream.flush()

def count(kind):
    return sum(json.loads(line)['kind'] == kind for line in (control / 'events').read_text().splitlines())

name = Path(sys.argv[0]).name
args = sys.argv[1:]
if name == 'systemd-run':
    event('scope_call', argv=args)
    if '--' not in args:
        event('bad_scope'); sys.exit(97)
    split = args.index('--')
    opts = args[:split]
    if not all(x in opts for x in ('--user', '--scope', 'MemoryMax=64M', 'MemorySwapMax=0')):
        event('bad_scope'); sys.exit(97)
    case = os.environ['TOY_CASE']
    if case in ('scope_refused', 'scope_refused_137') or (case == 'second_refused' and count('scope_call') == 2):
        # Stdout is not a scope receipt, even if it happens to spell the token.
        print('SCOPED', flush=True)
        event('scope_refused')
        sys.exit(137 if case == 'scope_refused_137' else 1)
    unit = next((s.split('=', 1)[1] for s in opts if s.startswith('--unit=')), 'anonymous.scope')
    (control / unit).write_text(str(os.getpid()))
    event('scope_created', unit=unit)
    os.environ['TOY_SCOPED'] = unit
    os.execvp(args[split + 1], args[split + 1:])
elif name == 'systemctl':
    # Real transient scopes can already be collected on return. show/is-active
    # deliberately report absence; only kill of OUR recorded PID is supported.
    if 'kill' not in args:
        sys.exit(1)
    unit = args[-1]
    path = control / unit
    if path.parent != control or not path.is_file():
        sys.exit(1)
    pid = int(path.read_text())
    try:
        env = Path(f'/proc/{pid}/environ').read_bytes()
        if ('TOY_ROOT=' + str(root)).encode() + b'\0' not in env:
            sys.exit(1)
        os.kill(pid, signal.SIGKILL if '--signal=KILL' in args else signal.SIGTERM)
    except (ProcessLookupError, FileNotFoundError):
        sys.exit(1)
    sys.exit(0)
elif name == 'sudo':
    if args[:2] != ['-nu', 'toy-agent']:
        event('bad_sudo'); sys.exit(97)
    os.execvp(args[2], args[2:])
elif name == 'omp':
    event('agent_start', scoped=os.environ.get('TOY_SCOPED', ''), argv=args)
    n = count('agent_start')
    case = os.environ['TOY_CASE']
    mark = Path(os.environ['ORCH_MARK'])
    # Sweep newly created files across ALL private writable locations, not a
    # suffix guessed from the subject. Inputs predate launch; control/ belongs
    # to the observer. Only the contract's MARK/GO/PGID and canonical lock survive.
    baseline = set(json.loads(os.environ['TOY_BASELINE']))
    protected = {str(mark), str(mark) + '.go', str(mark) + '.pgid',
                 str(Path(os.environ['HOME']) / '.local/state/dev-harness/orch-loop.lock')}
    if case not in ('clean_exit', 'duplicate', 'duplicate_mark', 'duplicate_log'):
        canaries = (Path(str(mark) + '.scoped'), mark.parent / 'unrelated-receipt',
                    Path(os.environ['HOME']) / 'arbitrary-state-receipt')
        for path in canaries:
            path.touch()
        deleted = []
        for path in sorted(root.rglob('*'), key=lambda p: len(p.parts), reverse=True):
            if path == control or control in path.parents or str(path) in baseline or str(path) in protected:
                continue
            if path.is_dir() and not path.is_symlink():
                path.rmdir()
            else:
                path.unlink()
            deleted.append(str(path.relative_to(root)))
        event('receipt_deleted', session=n, paths=deleted,
              canaries_removed=all(not path.exists() for path in canaries))
    print('TOY_STDOUT', flush=True)
    print('TOY_STDERR', file=sys.stderr, flush=True)
    def finish(signum=None, frame=None):
        event('agent_end', session=n, signal=signum)
        sys.exit(0 if signum is None else 128 + signum)
    signal.signal(signal.SIGTERM, finish)
    if case in ('duplicate', 'duplicate_mark', 'duplicate_log'):
        (control / 'ready').touch()
        while not (control / 'release').exists():
            time.sleep(0.01)
        finish()
    if case in ('marker_removed', 'second_refused') and n == 1:
        mark.touch()
        while True:
            time.sleep(0.05)
    if case == 'bounded' and n <= 3:
        if n % 2:
            mark.touch()
            event('agent_end', session=n, signal=None)
            sys.exit(0)
        event('agent_end', session=n, signal=None)
        sys.exit(7)
    if case.startswith('removed_crash') and n == 1:
        rc = {'removed_crash': 7, 'removed_crash_1': 1, 'removed_crash_137': 137}[case]
        event('agent_end', session=n, signal=None, rc=rc)
        sys.exit(rc)
    finish()
else:
    event('unexpected_tool', name=name)
    sys.exit(97)
