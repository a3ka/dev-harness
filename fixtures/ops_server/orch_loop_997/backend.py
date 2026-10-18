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

def event(kind, **fields):
    with (root / 'events').open('a') as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        stream.write(json.dumps(dict(kind=kind, pid=os.getpid(), **fields)) + '\n')
        stream.flush()

def count(kind):
    return sum(json.loads(line)['kind'] == kind for line in (root / 'events').read_text().splitlines())

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
    if os.environ['TOY_CASE'] == 'scope_refused' or (os.environ['TOY_CASE'] == 'second_refused' and count('scope_call') == 2):
        event('scope_refused'); sys.exit(1)
    unit = next((s.split('=', 1)[1] for s in opts if s.startswith('--unit=')), 'anonymous.scope')
    (root / unit).write_text(str(os.getpid()))
    event('scope_created', unit=unit)
    os.environ['TOY_SCOPED'] = unit
    os.execvp(args[split + 1], args[split + 1:])
elif name == 'systemctl':
    # Real transient scopes can already be collected on return. show/is-active
    # deliberately report absence; only kill of OUR recorded PID is supported.
    if 'kill' not in args:
        sys.exit(1)
    unit = args[-1]
    path = root / unit
    if path.parent != root or not path.is_file():
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
    # The legacy pathname really exists then disappears while the agent lives.
    legacy = Path(str(mark) + '.scoped')
    legacy.touch()
    if case != 'clean_exit':
        legacy.unlink()
        event('receipt_deleted', session=n)
    print('TOY_STDOUT', flush=True)
    print('TOY_STDERR', file=sys.stderr, flush=True)
    def finish(signum=None, frame=None):
        event('agent_end', session=n, signal=signum)
        sys.exit(0 if signum is None else 128 + signum)
    signal.signal(signal.SIGTERM, finish)
    if case == 'duplicate':
        (root / 'ready').touch()
        while not (root / 'release').exists():
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
    if case == 'removed_crash' and n == 1:
        event('agent_end', session=n, signal=None)
        sys.exit(7)
    finish()
else:
    event('unexpected_tool', name=name)
    sys.exit(97)
