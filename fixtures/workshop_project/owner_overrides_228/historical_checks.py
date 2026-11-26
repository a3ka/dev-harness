#!/usr/bin/env python3
"""Small deterministic controls at the historical-oracle policy seam.

Callbacks supply literal CLI observations, not a replacement Git/CLI tool.
The full historical runner separately exercises real baseline and reference.
"""
import ast
import types
from pathlib import Path

HERE = Path(__file__).resolve().parent
SAVED = {'rc': 0, 'stdout_sha256': 'a' * 64, 'stderr_sha256': 'b' * 64}
CHANGED = dict(SAVED, rc=1)
SHA = '1' * 40
GATE = 'check_zones'


def observe(module, values):
    calls = []

    def repeat():
        result = values[len(calls)]
        calls.append(result)
        return result

    stable, rechecked = module.assess(SAVED, repeat)
    return stable, rechecked, calls


def stable(module):
    result, evidence, calls = observe(module, [SAVED, SAVED])
    return result and evidence == [SAVED, SAVED] and calls == [SAVED, SAVED]


def unstable(module):
    result, evidence, calls = observe(module, [CHANGED, CHANGED])
    observed = []
    if not result:
        module.exclusion(SHA, GATE, SAVED, evidence, {(SHA, GATE)}, observed)
    return (not result and calls == [CHANGED, CHANGED] and observed == [
        dict(sha=SHA, gate=GATE, saved=SAVED, rechecked=[CHANGED, CHANGED])])


def twice(module):
    result, evidence, calls = observe(module, [SAVED, CHANGED])
    return not result and evidence == [SAVED, CHANGED] and calls == [SAVED, CHANGED]


def mismatch(module):
    result, _, calls = observe(module, [SAVED, SAVED])
    return result and len(calls) == 2 and module.parity(SAVED, SAVED) and not module.parity(SAVED, CHANGED)


def growth(module):
    observed = []
    declared = {'3' * 40}
    module.exclusion(SHA, GATE, SAVED, [CHANGED, CHANGED], declared, observed)
    module.exclusion(SHA, 'check_charter', SAVED, [CHANGED, CHANGED], declared, observed)
    try:
        module.exclusion('2' * 40, GATE, SAVED, [CHANGED, CHANGED], declared, observed)
    except RuntimeError as exc:
        return str(exc).startswith('HISTORICAL_ORACLE_TOOL_FAILURE: exclusion growth ')
    return False


CELLS = {'stable-parity': stable, 'unstable-accounted': unstable,
         'two-rechecks': twice, 'parity-mismatch': mismatch, 'exclusion-growth': growth}
# N-39: the author binds each mutation only to an observable input in code.
STABS = (
    ('exclude-without-recheck', '    rechecked = [repeat(), repeat()]\n    return all(answer == saved for answer in rechecked), rechecked',
     '    return False, []', 'stable-parity'),
    ('exclude-all', '    return all(answer == saved for answer in rechecked), rechecked',
     '    return False, rechecked', 'stable-parity'),
    ('ignore-parity', '    return saved == actual',
     '    return True', 'parity-mismatch'),
    ('one-recheck', '    rechecked = [repeat(), repeat()]',
     '    rechecked = [repeat()]', 'two-rechecks'),
)


def load(source):
    # Mutate the actual policy functions; do not execute/import a second oracle.
    tree = ast.parse(source)
    names = {'assess', 'parity', 'exclusion'}
    tree.body = [node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name in names]
    module = types.ModuleType('historical_policy_control')
    exec(compile(tree, str(HERE / 'historical.py'), 'exec'), module.__dict__)
    return module


def run(mode):
    source = (HERE / 'historical.py').read_text()
    import historical_snapshot_checks
    snapshot_bad = historical_snapshot_checks.run(mode)
    honest = load(source)
    for name, test in CELLS.items():
        if not test(honest):
            raise RuntimeError('HISTORICAL_HONEST_CONTROL: ' + name)
    if mode == '--stabs':
        alive = 0
        for name, old, new, cell in STABS:
            if source.count(old) != 1:
                raise RuntimeError('HISTORICAL_STAB_ANCHOR: ' + name)
            mutant = load(source.replace(old, new, 1))
            ok = CELLS[cell](mutant)
            alive += int(ok)
            print(('ZHIV ' if ok else 'POIMAN ') + name + ' historical:' + cell)
        print(f'HISTORICAL_STABS={len(STABS)} BINDINGS={len(STABS)} ZHIVYH={alive}')
        return int(alive != 0 or snapshot_bad != 0)
    print(f'HISTORICAL_POLICY_CELLS={len(CELLS)} KRASNYE=0')
    return snapshot_bad
