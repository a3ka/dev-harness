#!/usr/bin/env python3
"""Address-bound controls of the committed snapshot and manual-mode boundary."""
import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import types

HERE = Path(__file__).resolve().parent


def load(source):
    module = types.ModuleType('historical_snapshot_control')
    module.__file__ = str(HERE / 'historical.py')
    exec(compile(source, module.__file__, 'exec'), module.__dict__)
    return module


def rejected(call):
    from jsonschema.exceptions import ValidationError
    try:
        return call() == 1
    except (RuntimeError, ValidationError):
        return True


def mismatch(module, evidence):
    manifest, expected, log = copy.deepcopy(evidence)
    answer = manifest['records'][0]['reference']
    answer['rc'] = 1 - answer['rc']
    return module.snapshot(manifest, expected, log) == 1


def truncated(module, evidence):
    manifest, expected, log = copy.deepcopy(evidence)
    manifest['records'].pop()
    return rejected(lambda: module.snapshot(manifest, expected, log))


def growth(module, evidence):
    manifest, expected, log = copy.deepcopy(evidence)
    extra = copy.deepcopy(manifest['unreproducible'][0])
    extra['sha'] = manifest['reproducible_shas'][0]
    manifest['unreproducible'].append(extra)
    return rejected(lambda: module.snapshot(manifest, expected, log))


def completeness(module, evidence):
    manifest, expected, log = copy.deepcopy(evidence)
    manifest['complete'] = True
    return rejected(lambda: module.snapshot(manifest, expected, log))


def tampered(module, evidence, repair_lock=False):
    original = module.HERE
    with tempfile.TemporaryDirectory(prefix='snapshot-hash-', dir=module.probe.SCRATCH) as tmp:
        module.HERE = Path(tmp)
        original_manifest = module.MANIFEST
        module.MANIFEST = module.HERE / 'reproducibility.json'
        try:
            for name in ('reproducibility.json', 'historical.json', 'refs.json', 'historical-parity.log', 'snapshot-lock.json'):
                (module.HERE / name).write_bytes((original / name).read_bytes())
            path = module.HERE / 'reproducibility.json'
            data = json.loads(path.read_text())
            data['records'][0]['reference']['stderr_sha256'] = '0' * 64
            path.write_text(json.dumps(data))
            if repair_lock:
                import hashlib
                lock = module.HERE / 'snapshot-lock.json'
                hashes = json.loads(lock.read_text())
                hashes['reproducibility.json'] = hashlib.sha256(path.read_bytes()).hexdigest()
                lock.write_text(json.dumps(hashes))
            return rejected(lambda: module.load_snapshot())
        finally:
            module.HERE = original
            module.MANIFEST = original_manifest


def baseline_identity(module, evidence):
    with tempfile.TemporaryDirectory(prefix='baseline-identity-', dir=module.probe.SCRATCH) as tmp:
        tree = module.baseline_tree(Path(tmp))
        return all((tree / 'scripts' / (gate + '.sh')).read_text() == module.probe.build.base('scripts/' + gate + '.sh')
                   for gate in module.probe.GATES)


def model_without_replay(module, evidence):
    calls = []
    # Observe this policy seam without invoking the expensive replay.
    module.historical = lambda *args, **kwargs: calls.append(True) or 0
    return module.dispatch('--model') == 0 and not calls


def missing_tools(module, evidence):
    env = dict(os.environ, PATH='/nonexistent', PYTHONDONTWRITEBYTECODE='1', TMPDIR=str(module.probe.SCRATCH))
    result = subprocess.run([sys.executable, HERE / 'historical.py', '--historical', '--seconds', '1'],
                            env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    return result.returncode == 2 and b'git/bash unavailable' in result.stderr


CELLS = {'snapshot-mismatch': mismatch, 'snapshot-truncated': truncated,
         'snapshot-exclusion-growth': growth, 'snapshot-complete-explicit': completeness,
         'snapshot-hash': tampered, 'baseline-identity': baseline_identity,
         'snapshot-replaced-lock': lambda m, e: tampered(m, e, repair_lock=True),
         'model-without-replay': model_without_replay, 'historical-missing-tools': missing_tools}
# N-39: each mutation is assigned in code to the input observing its own defect.
STABS = (
    ('snapshot-ignore-parity', [('if not parity(saved, record[\'reference\']):', 'if False:')], 'snapshot-mismatch'),
    ('snapshot-silent-growth', [('    Draft202012Validator(schema).validate(manifest)', '    pass'),
                              ("    observed = manifest['unreproducible']", "    observed = manifest['unreproducible'][:4]")], 'snapshot-exclusion-growth'),
    ('snapshot-ignore-hash', [('if hashlib.sha256(data).hexdigest() != lock[name]:', 'if False:')], 'snapshot-hash'),
    ('snapshot-ignore-lock', [('if hashlib.sha256(lock_raw).hexdigest() != LOCK_SHA256:', 'if False:')], 'snapshot-replaced-lock'),
    ('baseline-replaced-by-reference', [('    return baseline\n', "    return probe.materialize(work / 'replacement', model=True)\n")], 'baseline-identity'),
    ('historical-in-model', [("    if mode == '--model':\n        return int(bad != 0)",
                              "    if mode == '--model':\n        return historical(manifest, expected)")], 'model-without-replay'),
)


def run(mode):
    source = (HERE / 'historical.py').read_text()
    honest = load(source)
    if rejected(lambda: honest.load_snapshot()):
        raise RuntimeError('SNAPSHOT_HONEST_LOADER')
    evidence = honest.load_snapshot()
    if honest.snapshot(*evidence):
        raise RuntimeError('SNAPSHOT_HONEST_PARITY')
    for name, cell in CELLS.items():
        if not cell(load(source), evidence):
            raise RuntimeError('SNAPSHOT_HONEST_CONTROL: ' + name)
    alive = 0
    if mode == '--stabs':
        for name, edits, cell in STABS:
            changed = source
            for old, new in edits:
                if changed.count(old) != 1:
                    raise RuntimeError('SNAPSHOT_STAB_ANCHOR: ' + name)
                changed = changed.replace(old, new, 1)
            ok = CELLS[cell](load(changed), evidence)
            alive += int(ok)
            print(('ZHIV ' if ok else 'POIMAN ') + name + ' historical:' + cell)
    print(f'SNAPSHOT_CELLS={len(CELLS)} SNAPSHOT_STABS={len(STABS)} ZHIVYH={alive}')
    return int(alive != 0)
