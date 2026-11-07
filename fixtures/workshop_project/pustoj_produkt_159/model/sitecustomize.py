"""Observe battery-local cell calls after the gate refuses, including silent cells.

Loaded by Python before probe.py via PYTHONPATH in the 159 battery. The gate
itself runs in a separate process; only calls in the selected subject file are
recorded. The trace is an observation, never an oracle for expected results.
"""
import linecache
import os
import sys

_gate = os.environ.get('PUSTOJ_PRODUKT_TRACE')
_cells = os.environ.get('PUSTOJ_PRODUKT_CELLS_TRACE')
_subject = os.environ.get('PUSTOJ_PRODUKT_CELLS_SUBJECT')
if _gate and _cells and _subject:
    _subject = os.path.realpath(_subject)
    _forward_or_return = ('return', 'if ', 'elif ', 'else:',
                          'sys.stdout.write(', 'sys.stderr.write(',
                          'sys.stdout.flush(', 'sys.stderr.flush(', 'print(')

    def _observe(frame, event, arg):
        if (event not in ('call', 'c_call')
                or frame.f_code.co_name == '<module>'
                or os.path.realpath(frame.f_code.co_filename) != _subject
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
            if name in ('write', 'flush', 'print'):
                return
            name = 'C_CALL:' + name
        with open(_cells, 'a', encoding='utf-8') as out:
            out.write('%s\n' % name)

    sys.setprofile(_observe)

    def _lines(frame, event, arg):
        if event == 'line' and os.path.exists(_gate):
            source = linecache.getline(_subject, frame.f_lineno).strip()
            if not source.startswith(_forward_or_return):
                with open(_cells, 'a', encoding='utf-8') as out:
                    out.write('LINE:%s:%d\n' % (frame.f_code.co_name,
                                                frame.f_lineno))
        return _lines

    def _trace(frame, event, arg):
        if (event == 'call'
                and frame.f_code.co_name != '<module>'
                and os.path.realpath(frame.f_code.co_filename) == _subject):
            return _lines
        return None

    sys.settrace(_trace)
