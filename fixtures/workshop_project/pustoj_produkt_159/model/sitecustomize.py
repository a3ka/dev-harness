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
