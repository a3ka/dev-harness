"""Deliberately flawed stand-ins; every mutant has one revealing input in probe.py.

Каждый стаб — нейтрализация ровно одного дефекта клетки: честная дверь на
нейтрализованном входе обязана остаться зелёной (К-14), а клетка — красной
на исходном (Н-39: привязка по коду cases() в probe.py, не по прозе).
"""
from copy import deepcopy
from pathlib import Path
import tempfile

import model

GOOD_URI = 'history://Critic165a'


def _door_ok(h, uri, owner, obj, out='verdict.md', seed=None):
    """Честная эквивалентная запись: дверь на нейтрализованном входе пишет в зону и принимает."""
    with tempfile.TemporaryDirectory(prefix='stub-165-') as tmp:
        zone = Path(tmp) / 'verdicts' / 'critic'
        zone.mkdir(parents=True)
        if seed is not None:
            (zone / 'verdict.md').write_text(seed)
        model.door(tmp, h, uri, owner, obj, out)
        return (zone / 'verdict.md').read_text()


def source_any(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    h['source'] = uri
    return _door_ok(h, uri, owner, obj, out, seed)


def role_any(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    h['agent'] = 'critic'
    return _door_ok(h, uri, owner, obj, out, seed)


def quote_any(h, uri, owner, obj, out='verdict.md', seed=None):
    return _door_ok(h, uri, model.QUOTE, obj, out, seed)


def task_any(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    h['task'] = 'OBJECT=' + obj
    return _door_ok(h, uri, owner, obj, out, seed)


def incomplete_any(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    h['result']['complete'] = True
    h['result']['tool'] = 'yield'
    return _door_ok(h, uri, owner, obj, out, seed)


def forged_accept(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    lines = h['result']['verdict'].splitlines()
    lines[0] = 'accept'
    h['result']['verdict'] = '\n'.join(lines) + '\n'
    return _door_ok(h, uri, owner, obj, out, seed)


def wrong_object(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    lines = h['result']['verdict'].splitlines()
    lines[1] = 'OBJECT=' + obj
    h['result']['verdict'] = '\n'.join(lines) + '\n'
    return _door_ok(h, uri, owner, obj, out, seed)


def verdict_role_any(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    h['result']['verdict'] = h['result']['verdict'].replace('роль=reviewer;', 'роль=critic;')
    return _door_ok(h, uri, owner, obj, out, seed)


def missing_verdict_any(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    h['result']['verdict'] = 'accept\nOBJECT=' + obj + '\nСУД: роль=critic; сессия=' + uri.removeprefix('history://') + ';\n'
    return _door_ok(h, uri, owner, obj, out, seed)


def uri_valid(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    h['source'] = GOOD_URI
    h['result']['verdict'] = h['result']['verdict'].replace(
        'сессия=' + uri.removeprefix('history://'), 'сессия=' + GOOD_URI.removeprefix('history://'))
    return _door_ok(h, GOOD_URI, owner, obj, out, seed)


def object_hex(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    good = obj[:-1] + 'a'
    h['task'] = h['task'].replace('OBJECT=' + obj, 'OBJECT=' + good)
    h['result']['verdict'] = h['result']['verdict'].replace('OBJECT=' + obj, 'OBJECT=' + good)
    return _door_ok(h, uri, owner, good, out, seed)


def sud_single(h, uri, owner, obj, out='verdict.md', seed=None):
    h = deepcopy(h)
    lines = h['result']['verdict'].splitlines()
    h['result']['verdict'] = '\n'.join(
        line for i, line in enumerate(lines) if not (i != 2 and line.startswith('СУД:'))) + '\n'
    return _door_ok(h, uri, owner, obj, out, seed)


def out_in_zone(h, uri, owner, obj, out='verdict.md', seed=None):
    return _door_ok(h, uri, owner, obj, 'verdict.md', seed)


def perezapis_same(h, uri, owner, obj, out='verdict.md', seed=None):
    return _door_ok(h, uri, owner, obj, out, model.decide(h, uri, owner, obj))
