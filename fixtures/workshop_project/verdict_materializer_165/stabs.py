"""Deliberately flawed stand-ins; every mutant has one revealing input in probe.py."""
from copy import deepcopy
import model


def source_any(h, uri, owner, obj):
    h = deepcopy(h)
    h['source'] = uri
    return model.decide(h, uri, owner, obj)


def role_any(h, uri, owner, obj):
    h = deepcopy(h)
    h['agent'] = 'critic'
    return model.decide(h, uri, owner, obj)


def quote_any(h, uri, owner, obj):
    return model.decide(h, uri, model.QUOTE, obj)


def task_any(h, uri, owner, obj):
    h = deepcopy(h)
    h['task'] = 'OBJECT=' + obj
    return model.decide(h, uri, owner, obj)


def incomplete_any(h, uri, owner, obj):
    h = deepcopy(h)
    h['result']['complete'] = True
    h['result']['tool'] = 'yield'
    return model.decide(h, uri, owner, obj)


def forged_accept(h, uri, owner, obj):
    h = deepcopy(h)
    lines = h['result']['verdict'].splitlines()
    lines[0] = 'accept'
    h['result']['verdict'] = '\n'.join(lines) + '\n'
    return model.decide(h, uri, owner, obj)


def wrong_object(h, uri, owner, obj):
    h = deepcopy(h)
    lines = h['result']['verdict'].splitlines()
    lines[1] = 'OBJECT=' + obj
    h['result']['verdict'] = '\n'.join(lines) + '\n'
    return model.decide(h, uri, owner, obj)


def verdict_role_any(h, uri, owner, obj):
    h = deepcopy(h)
    h['result']['verdict'] = h['result']['verdict'].replace('роль=reviewer;', 'роль=critic;')
    return model.decide(h, uri, owner, obj)


def missing_verdict_any(h, uri, owner, obj):
    h = deepcopy(h)
    h['result']['verdict'] = 'accept\nOBJECT=' + obj + '\nСУД: роль=critic; сессия=' + uri.removeprefix('history://') + ';\n'
    return model.decide(h, uri, owner, obj)
