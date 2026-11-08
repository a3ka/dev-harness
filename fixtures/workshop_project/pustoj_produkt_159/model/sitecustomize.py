"""Report Python work after the gate's refusal to the parent observer pipe.

The checker retains the evidence in memory: the subject cannot erase its own
record by truncating a file in its working tree.  Trace application frames
regardless of whether they are module-level, in probe.py, or imported.
"""
import linecache
import os
import sys
import sysconfig
_gate = os.environ.get('PUSTOJ_PRODUKT_TRACE')
_cells_fd = os.environ.get('PUSTOJ_PRODUKT_CELLS_FD')
_cells = os.environ.get('PUSTOJ_PRODUKT_CELLS_TRACE')
_subject = os.environ.get('PUSTOJ_PRODUKT_CELLS_SUBJECT')
try:
    _observer_fd = int(_cells_fd) if _cells_fd else None
    if _observer_fd is not None:
        os.fstat(_observer_fd)  # gate subprocesses do not inherit the pipe
except (ValueError, OSError):
    _observer_fd = None
if _gate and _observer_fd is not None and _subject:
    _cells_fd = _observer_fd
    _stdlib = os.path.realpath(sysconfig.get_path('stdlib'))
    _observer = os.path.realpath(__file__)

    def _own(frame):
        path = os.path.realpath(frame.f_code.co_filename)
        return (path != _observer and not path.startswith(_stdlib + os.sep)
                and not path.startswith('<'))

    def _record(event):
        line = (event + '\n').encode('utf-8')
        os.write(_cells_fd, line)
        if _cells:
            with open(_cells, 'ab') as out:
                out.write(line)
    # A thread/process spawned before the gate can wait for its refusal and
    # execute a cell without inheriting this thread-local Python profiler.
    # Record the start, not the eventual side effect: the pipe is held by the
    # checker, outside the subject's mutable tree.  The direct gate child is
    # the one permitted spawn on the early-exit path.
    import _thread
    import subprocess
    import threading

    _thread_start = _thread.start_new_thread
    _threading_start = threading.Thread.start
    _fork = os.fork
    _popen = subprocess.Popen

    def _started(kind):
        _record('PRE_GATE_%s' % kind if not os.path.exists(_gate)
                else 'POST_GATE_%s' % kind)

    def _start_thread(*args, **kwargs):
        _started('THREAD')
        return _thread_start(*args, **kwargs)

    def _start_threading(self, *args, **kwargs):
        _started('THREAD')
        return _threading_start(self, *args, **kwargs)

    def _start_fork(*args, **kwargs):
        _started('FORK')
        return _fork(*args, **kwargs)

    def _start_process(*args, **kwargs):
        command = args[0] if args else kwargs.get('args')
        argv = command if isinstance(command, (list, tuple)) else ()
        executable = os.fspath(argv[0]) if argv else ''
        target = os.fspath(argv[1]) if len(argv) > 1 else ''
        root = os.path.abspath(os.path.join(
            os.path.dirname(_subject), '..', '..', '..'))
        gates = (os.path.join(root, 'scripts', 'check_pustoj_produkt.sh'),
                 os.path.join(os.path.dirname(_observer), 'gate_tracer.sh'))
        if not (os.path.basename(executable) == 'bash' and target in gates):
            _started('SUBPROCESS')
        return _popen(*args, **kwargs)

    _thread.start_new_thread = _start_thread
    threading.Thread.start = _start_threading
    os.fork = _start_fork
    subprocess.Popen = _start_process
    _forward_or_return = ('return', 'if ', 'elif ', 'else:',
                          'sys.stdout.write(', 'sys.stderr.write(',
                          'sys.stdout.flush(', 'sys.stderr.flush(', 'print(')

    def _observe(frame, event, arg):
        if (event not in ('call', 'c_call')
                or not _own(frame)
                or not os.path.exists(_gate)):
            return
        name = frame.f_code.co_name
        if event == 'call':
            # Any battery-local function entered after the gate's refusal
            # performs more work than forwarding output and returning its rc.
            name = 'CALL:' + name
        else:
            # A cell can be wholly in main(): even a silent sum() is execution.
            # Only forwarding the gate's output is part of the early exit.
            name = getattr(arg, '__name__', '')
            if name in ('write', 'flush', 'print', 'exit'):
                return
            name = 'C_CALL:' + name
        _record(name)

    sys.setprofile(_observe)

    def _lines(frame, event, arg):
        if event == 'line' and os.path.exists(_gate):
            source = linecache.getline(frame.f_code.co_filename,
                                       frame.f_lineno).strip()
            if not source.startswith(_forward_or_return):
                _record('LINE:%s:%d' % (frame.f_code.co_name,
                                         frame.f_lineno))
        return _lines

    def _trace(frame, event, arg):
        if event == 'call' and _own(frame):
            return _lines
        return None

    sys.settrace(_trace)

    def _audit(event, args):
        # CPython audit hooks cannot be removed by sys.settrace/profile(None).
        # A subject trying to blind the observer before the gate still leaves
        # evidence even if the subsequent cell is silent.
        if event in ('sys.settrace', 'sys.setprofile'):
            _record('OBSERVER_DISABLED:%s' % event)

    sys.addaudithook(_audit)
