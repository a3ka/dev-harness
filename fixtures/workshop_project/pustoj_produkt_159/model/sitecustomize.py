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
    # The parent must report a spawn even if the child starts with env={}
    # or -E -S and never loads this observer.  Keep wrappers for thread
    # starts (CPython does not audit threading.Thread.start), and use the
    # process audit events for native forks, execs and all spawn variants.
    import _thread
    import threading

    _thread_start = _thread.start_new_thread
    _threading_start = threading.Thread.start

    def _started(kind):
        _record('PRE_GATE_%s' % kind if not os.path.exists(_gate)
                else 'POST_GATE_%s' % kind)

    def _start_thread(*args, **kwargs):
        _started('THREAD')
        return _thread_start(*args, **kwargs)

    def _start_threading(self, *args, **kwargs):
        _started('THREAD')
        return _threading_start(self, *args, **kwargs)
    _thread.start_new_thread = _start_thread
    threading.Thread.start = _start_threading
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
        # CPython audit hooks survive sys.settrace/profile(None).  Process
        # events are observed in the parent, before any clean-env child runs.
        if event in ('sys.settrace', 'sys.setprofile'):
            _record('OBSERVER_DISABLED:%s' % event)
        elif event in ('os.posix_spawn', 'os.spawn', 'os.system',
                       'os.exec', 'os.fork', 'os.forkpty',
                       'subprocess.Popen', '_thread.start_new_thread'):
            if event in ('subprocess.Popen', 'os.posix_spawn', 'os.spawn'):
                executable = args[0] if args else None
                argv = args[1] if len(args) > 1 else None
                root = os.path.abspath(os.path.join(
                    os.path.dirname(_subject), '..', '..', '..'))
                gate = os.path.join(root, 'scripts',
                                    'check_pustoj_produkt.sh')
                tracer = os.path.join(os.path.dirname(_observer),
                                      'gate_tracer.sh')
                if (isinstance(argv, (list, tuple)) and len(argv) == 3
                        and ((executable == '/usr/bin/bash'
                              and argv[0] == '/usr/bin/bash'
                              and argv[1] in (gate, tracer))
                             or (event == 'subprocess.Popen'
                                 and executable == 'bash'
                                 and argv[0] == 'bash'
                                 and argv[1] == tracer))):
                    return  # The fixture's tracer also uses bash from PATH.
            _started('SPAWN:' + event)

    sys.addaudithook(_audit)
