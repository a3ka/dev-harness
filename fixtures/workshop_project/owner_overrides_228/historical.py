#!/usr/bin/env python3
"""Committed historical evidence; live replay is explicit and never mandatory."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

sys.dont_write_bytecode = True
import probe

HERE = Path(__file__).resolve().parent
ROOT = probe.ROOT
MANIFEST = HERE / 'reproducibility.json'
LOCK_SHA256 = '738f50547f6b946e85b23ba475e0166bd2934ff942a2966a337f37ab524f0072'


def digest(result):
    rc, stdout, stderr = result
    return {'rc': rc, 'stdout_sha256': hashlib.sha256(stdout).hexdigest(),
            'stderr_sha256': hashlib.sha256(stderr).hexdigest()}


def assess(saved, repeat):
    """Both observations are mandatory, even when the first already differs."""
    rechecked = [repeat(), repeat()]
    return all(answer == saved for answer in rechecked), rechecked


def parity(saved, actual):
    return saved == actual


def exclusion(sha, gate, saved, rechecked, declared, observed):
    item = dict(sha=sha, gate=gate, saved=saved, rechecked=rechecked)
    observed.append(item)
    print(f'EXCLUDED_SHAS={len({r["sha"] for r in observed})} UNREPRODUCIBLE_RESPONSES={len(observed)}', flush=True)
    if len({r['sha'] for r in observed}) > len(declared):
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: exclusion growth ' + repr(item))
    return item


def snapshot(manifest, expected, log):
    """Validate a frozen witness, then compare every recorded pair in memory."""
    try:
        from jsonschema import Draft202012Validator
        from jsonschema.exceptions import ValidationError
    except ImportError as exc:
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: jsonschema unavailable') from exc
    schema = json.loads((HERE / 'reproducibility.schema.json').read_text())
    try:
        Draft202012Validator(schema).validate(manifest)
    except ValidationError as exc:
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: snapshot schema: ' + exc.message) from exc
    shas = sorted({r[1] for r in probe.ROWS if r[1] != '-'})
    pairs = [(sha, gate) for sha in shas for gate in probe.GATES]
    if expected['baseline'] != probe.build.BASE or manifest['baseline'] != probe.build.BASE:
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: baseline identity')
    if [(r['sha'], r['gate']) for r in expected['records']] != pairs:
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: incomplete original oracle')
    answers = {(r['sha'], r['gate']): {k: v for k, v in r.items() if k not in ('sha', 'gate')}
               for r in expected['records']}
    excluded = manifest['declared_unreproducible_shas']
    observed = manifest['unreproducible']
    if sorted({r['sha'] for r in observed}) != excluded or len(observed) != len(excluded):
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: exclusion growth or changed list')
    for entry in observed:
        if (entry['saved'] != answers[entry['sha'], entry['gate']] or
                all(value == entry['saved'] for value in entry['rechecked']) or
                not any(value['rc'] == 141 for value in [entry['saved'], *entry['rechecked']])):
            raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: exclusion evidence')
    completed = manifest['completed_shas']
    reproduced = manifest['reproducible_shas']
    if (completed != shas[:len(completed)] or
            reproduced != [sha for sha in completed if sha not in excluded] or
            manifest['failure']['last_completed_sha'] != completed[-1] or
            manifest['failure']['next_sha'] != shas[len(completed)]):
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: changed coverage')
    # Equality lines are the measured reference witness, NOT raw stored outputs.
    lines = log.decode().splitlines()
    equality = [line.split()[1] for line in lines if line.startswith('HISTORICAL_SHA ') and line.endswith(' doors=4')]
    if equality != reproduced:
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: equality witness coverage')
    records = manifest['records']
    if [(r['sha'], r['gate']) for r in records] != [(sha, gate) for sha in reproduced for gate in probe.GATES]:
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: snapshot records')
    bad = 0
    for record in records:
        saved = answers[record['sha'], record['gate']]
        if record['baseline'] != saved or saved['rc'] not in (0, 1):
            raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: changed baseline answer')
        if not parity(saved, record['reference']):
            bad += 1
            print('KRASNO snapshot', record['sha'], record['gate'], flush=True)
    return bad


def load_snapshot():
    # Take all immutable oracle bytes before invoking any subject.
    raw = MANIFEST.read_bytes()
    manifest = json.loads(raw)
    historical = (HERE / 'historical.json').read_bytes()
    refs = (HERE / 'refs.json').read_bytes()
    log = (HERE / 'historical-parity.log').read_bytes()
    lock_raw = (HERE / 'snapshot-lock.json').read_bytes()
    if hashlib.sha256(lock_raw).hexdigest() != LOCK_SHA256:
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: snapshot lock hash')
    lock = json.loads(lock_raw)
    for name, data in (('reproducibility.json', raw), ('historical.json', historical),
                       ('refs.json', refs), ('historical-parity.log', log)):
        if hashlib.sha256(data).hexdigest() != lock[name]:
            raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: snapshot hash ' + name)
    if (manifest['historical_sha256'] != lock['historical.json'] or
            manifest['refs_sha256'] != lock['refs.json'] or
            manifest['provenance']['log_sha256'] != lock['historical-parity.log']):
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: provenance hashes')
    expected = json.loads(historical)
    return manifest, expected, log


def history_world(world):
    world.mkdir()
    probe.git(world, 'init', '-q')
    objects = probe.git(ROOT, 'rev-parse', '--git-path', 'objects')
    objects = (ROOT / objects).resolve()
    probe.put(world / '.git/objects/info/alternates', str(objects) + '\n')
    refs = json.loads((HERE / 'refs.json').read_text())
    for name, sha in refs:
        probe.git(world, 'update-ref', name, sha)
    probe.put(world / 'registry/owner-overrides.tsv', probe.registry(probe.ROWS))
    peeled = probe.git(world, 'for-each-ref', '--format=%(refname) %(*objectname) %(objectname)', 'refs/tags/')
    return {line.split()[0]: (line.split()[-1], line.split()[1]) for line in peeled.splitlines()}


def baseline_tree(work):
    baseline = probe.materialize(work / 'baseline')
    for gate in probe.GATES:
        text = probe.build.base('scripts/' + gate + '.sh')
        if hashlib.sha256(text.encode()).hexdigest() != probe.BASELINE['files'][gate]:
            raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: baseline source ' + gate)
        probe.put(baseline / 'scripts' / (gate + '.sh'), text)
    return baseline


def historical(manifest, expected, repo=None, seconds=2400):
    """Bounded, manual real-tool replay. No writes to the committed oracle."""
    if not all(shutil.which(tool) for tool in ('git', 'bash')):
        raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: git/bash unavailable')
    answers = {(r['sha'], r['gate']): {k: v for k, v in r.items() if k not in ('sha', 'gate')}
               for r in expected['records']}
    shas = sorted({sha for sha, _ in answers})
    deadline = time.monotonic() + seconds
    report = dict(complete=False, unreproducible=[], reproduced_shas=[], mismatches=[])
    bad = 0
    with tempfile.TemporaryDirectory(prefix='historical-', dir=probe.SCRATCH) as tmp:
        work = Path(tmp)
        subject = probe.materialize(work / 'subject', model=repo is None, repo=ROOT if repo is None else repo)
        baseline = baseline_tree(work)
        world = work / 'world'
        all_refs = history_world(world)
        active_refs = set(all_refs)
        for sha in shas:
            if time.monotonic() >= deadline:
                report['stopped'] = 'TIME_BUDGET'
                break
            ancestors = set(probe.git(world, 'rev-list', sha).splitlines())
            wanted = {name for name, (oid, commit) in all_refs.items() if commit in ancestors}
            updates = [f'delete {name}' for name in sorted(active_refs - wanted)]
            updates += [f'update {name} {all_refs[name][0]}' for name in sorted(wanted - active_refs)]
            if updates:
                probe.git(world, 'update-ref', '--stdin', data=('\n'.join(updates) + '\n').encode())
            active_refs = wanted
            probe.git(world, 'update-ref', 'HEAD', sha)
            parent = probe.git(world, 'rev-parse', sha + '^1')

            def invoke(tree, gate):
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    raise subprocess.TimeoutExpired('historical time budget', seconds)
                cache = world / ('cache-' + gate)
                probe.put(cache, parent + '\n')
                extra = () if gate == 'check_contract_frozen' else ('--incr', cache)
                registry = tree / 'registry/owner-overrides.tsv'
                probe.put(world / 'registry/owner-overrides.tsv', registry.read_bytes() if registry.is_file() else b'')
                old_timeout = probe.SOURCE['runner']['timeout_seconds']
                try:
                    probe.SOURCE['runner']['timeout_seconds'] = min(60, remaining)
                    return digest(probe.cli(tree, world, gate, extra))
                finally:
                    probe.SOURCE['runner']['timeout_seconds'] = old_timeout

            stable_sha = True
            for gate in probe.GATES:
                saved = answers[sha, gate]
                try:
                    stable, rechecked = assess(saved, lambda: invoke(baseline, gate))
                except subprocess.TimeoutExpired:
                    if gate != 'check_zones' and time.monotonic() < deadline:
                        raise
                    report['unreproducible'].append(dict(sha=sha, gate=gate, reason='BASELINE_TIMEOUT'))
                    stable_sha = False
                    print('UNREPRODUCIBLE', sha, gate, 'BASELINE_TIMEOUT', flush=True)
                    break
                if gate == 'check_zones' and any(a['rc'] == 141 for a in [saved, *rechecked]):
                    report['unreproducible'].append(dict(sha=sha, gate=gate, reason='BASELINE_SIGPIPE', saved=saved, rechecked=rechecked))
                    stable_sha = False
                    print('UNREPRODUCIBLE', sha, gate, 'BASELINE_SIGPIPE', flush=True)
                elif not stable:
                    report['mismatches'].append(dict(sha=sha, gate=gate, kind='BASELINE_VS_SNAPSHOT', saved=saved, actual=rechecked))
                    bad += 1
                    stable_sha = False
                    print('KRASNO baseline-vs-snapshot', sha, gate, rechecked, flush=True)
                elif saved['rc'] not in (0, 1):
                    raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: stable invalid baseline rc')
            if stable_sha:
                try:
                    for gate in probe.GATES:
                        actual = invoke(subject, gate)
                        if actual['rc'] not in (0, 1):
                            raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: candidate rc ' + str(actual['rc']))
                        if not parity(answers[sha, gate], actual):
                            bad += 1
                            report['mismatches'].append(dict(sha=sha, gate=gate, kind='REFERENCE_VS_SNAPSHOT', actual=actual))
                            print('KRASNO historical', sha, gate, actual, flush=True)
                except subprocess.TimeoutExpired:
                    if time.monotonic() < deadline:
                        raise
                    report['stopped'] = 'TIME_BUDGET'
                    break
                report['reproduced_shas'].append(sha)
                print('HISTORICAL_SHA', sha, 'doors=4', flush=True)
            probe.put(probe.SCRATCH / 'historical-manual.json', json.dumps(report, indent=2) + '\n')
        else:
            report['complete'] = not report['unreproducible']
    probe.put(probe.SCRATCH / 'historical-manual.json', json.dumps(report, indent=2) + '\n')
    if 'stopped' in report:
        print('HISTORICAL_STOPPED', report['stopped'], flush=True)
    print(f'HISTORICAL_MANUAL complete={str(report["complete"]).lower()} '
          f'REPRODUCIBLE_SHAS={len(report["reproduced_shas"])} '
          f'EXCLUDED_SHAS={len({r["sha"] for r in report["unreproducible"]})} MISMATCHES={bad}', flush=True)
    return int(bad != 0)


def dispatch(mode):
    manifest, expected, log = load_snapshot()
    bad = snapshot(manifest, expected, log)
    print(f'HISTORICAL_SNAPSHOT complete=false REPRODUCIBLE_SHAS={len(manifest["reproducible_shas"])} '
          f'EXCLUDED_SHAS={len(manifest["unreproducible"])} DECISIONS={len(manifest["records"])} MISMATCHES={bad}', flush=True)
    if mode == '--model':
        return int(bad != 0)
    if mode == '--historical':
        return historical(manifest, expected) if not bad else 1
    raise RuntimeError('HISTORICAL_USAGE')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--model', action='store_true')
    group.add_argument('--historical', action='store_true')
    parser.add_argument('--repo', type=Path)
    parser.add_argument('--seconds', type=int, default=2400)
    args = parser.parse_args()
    if not 1 <= args.seconds <= 2400 or (args.repo and not args.historical):
        raise RuntimeError('HISTORICAL_USAGE: repo only in manual mode; seconds 1..2400')
    if args.model:
        return dispatch('--model')
    manifest, expected, log = load_snapshot()
    if snapshot(manifest, expected, log):
        return 1
    return historical(manifest, expected, args.repo.resolve() if args.repo else None, args.seconds)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print('NOT_IMPLEMENTED: HISTORICAL_ORACLE_TOOL_FAILURE: ' + str(exc), file=sys.stderr)
        sys.exit(2)
