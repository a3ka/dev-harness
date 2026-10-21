"""Стаб: отсутствующий объявленный кадр пропускается молча (не отказ)."""
from _model import m, run


class _Skip(Exception):
    pass


_orig_find = m.find_frame
_orig_proc = m.process_frame


def find(kadry_dir, k):
    try:
        return _orig_find(kadry_dir, k)
    except m.Refusal as r:
        if r.reason == 'KADR_OTSUTSTVUET':
            raise _Skip()
        raise


def proc(a, k, mera):
    try:
        return _orig_proc(a, k, mera)
    except _Skip:
        return 0


m.find_frame = find
m.process_frame = proc
run()
