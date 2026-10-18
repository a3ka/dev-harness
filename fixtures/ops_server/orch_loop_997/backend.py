#!/usr/bin/env python3
"""PATH-only systemd/omp substitutes; never delegate to station binaries."""
import ctypes
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
# One write-space definition for both confinement and deletion. control is
# observer-owned, not a conforming subject's receipt location.
WRITABLE = (root / 'home', root / 'volatile-state', root / 'tmp', control)

def event(kind, **fields):
    with (control / 'events').open('a') as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        stream.write(json.dumps(dict(kind=kind, pid=os.getpid(), **fields)) + '\n')
        stream.flush()

def count(kind):
    return sum(json.loads(line)['kind'] == kind for line in (control / 'events').read_text().splitlines())

def confine_writes():
    libc = ctypes.CDLL(None, use_errno=True)
    syscall = libc.syscall
    syscall.restype = ctypes.c_long
    # Linux syscall numbers shared by x86_64 and asm-generic architectures.
    create, add_rule, restrict_self = 444, 445, 446
    abi = syscall(create, None, ctypes.c_size_t(0), ctypes.c_uint32(1))
    if abi < 1:
        raise OSError(ctypes.get_errno(), 'Landlock ABI unavailable')
    write_file = 1 << 1
    # REMOVE_DIR/FILE and MAKE_CHAR/DIR/REG/SOCK/FIFO/BLOCK/SYM.
    handled = write_file | sum(1 << bit for bit in range(4, 13))
    if abi >= 2:
        handled |= 1 << 13  # REFER
    if abi >= 3:
        handled |= 1 << 14  # TRUNCATE

    class Ruleset(ctypes.Structure):
        _fields_ = [('handled_access_fs', ctypes.c_uint64)]

    class PathBeneath(ctypes.Structure):
        _pack_ = 1
        _fields_ = [('allowed_access', ctypes.c_uint64), ('parent_fd', ctypes.c_int32)]

    attr = Ruleset(handled)
    ruleset = syscall(create, ctypes.byref(attr), ctypes.c_size_t(ctypes.sizeof(attr)), 0)
    if ruleset < 0:
        raise OSError(ctypes.get_errno(), 'Landlock create_ruleset')
    try:
        for path in (*WRITABLE, Path('/dev')):
            fd = os.open(path, os.O_PATH | os.O_CLOEXEC)
            try:
                rule = PathBeneath(write_file if path == Path('/dev') else handled, fd)
                if syscall(add_rule, ruleset, 1, ctypes.byref(rule), 0) != 0:
                    raise OSError(ctypes.get_errno(), 'Landlock add_rule')
            finally:
                os.close(fd)
        if libc.prctl(38, 1, 0, 0, 0) != 0:  # PR_SET_NO_NEW_PRIVS
            raise OSError(ctypes.get_errno(), 'Landlock no_new_privs')
        if syscall(restrict_self, ruleset, 0) != 0:
            raise OSError(ctypes.get_errno(), 'Landlock restrict_self')
    finally:
        os.close(ruleset)

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
    try:
        confine_writes()
    except OSError as error:
        event('landlock_unavailable', error=str(error))
        sys.exit(2)
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
    # Delete new objects throughout the same space allowed by Landlock.
    # Only the canonical lock inode survives; its bytes are not a receipt.
    baseline = set(json.loads(os.environ['TOY_BASELINE']))
    lock = Path(os.environ['HOME']) / '.local/state/dev-harness/orch-loop.lock'
    protected = {str(lock)}
    if case not in ('clean_exit', 'duplicate', 'duplicate_mark', 'duplicate_log'):
        if lock.exists():
            os.truncate(lock, 0)
        canaries = (Path(str(mark) + '.scoped'), mark.parent / 'unrelated-receipt',
                    Path(os.environ['HOME']) / 'arbitrary-state-receipt',
                    root / 'tmp/arbitrary-tmp-receipt')
        for path in canaries:
            path.touch()
        deleted = []
        swept = (path for directory in WRITABLE if directory != control
                 for path in directory.rglob('*'))
        for path in sorted(swept, key=lambda p: len(p.parts), reverse=True):
            if str(path) in baseline or str(path) in protected:
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
