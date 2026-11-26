"""Fault seam for real CLI filesystem operations, not a cleaner replacement."""
import os

_target = os.environ.get('CI225_FAULT_PATH')
_kind = os.environ.get('CI225_FAULT_KIND')
_scandir = os.scandir
_stat = os.stat


def scandir(path):
    if _kind == 'readdir' and os.fspath(path) == _target:
        raise PermissionError(13, 'injected readdir error', _target)
    return _scandir(path)


def stat(path, *args, **kwargs):
    if _kind == 'stat' and os.fspath(path) == _target:
        raise FileNotFoundError(2, 'injected stat error', _target)
    return _stat(path, *args, **kwargs)


os.scandir = scandir
os.stat = stat
