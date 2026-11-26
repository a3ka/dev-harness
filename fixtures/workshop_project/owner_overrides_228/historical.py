#!/usr/bin/env python3
"""Literal CLI parity, restricted to twice-reproduced pinned-baseline SHAs.

The saved oracle is never replaced. Baseline-only observations may be recorded
explicitly in the reproducibility manifest; they are not candidate expectations.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
import probe

HERE = Path(__file__).resolve().parent
ROOT = probe.ROOT
MANIFEST = HERE / 'reproducibility.json'


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


def history_world(world):
    world.mkdir()
    probe.git(world, 'init', '-q')
    objects = probe.git(ROOT, 'rev-parse', '--git-path', 'objects')
    objects = (ROOT / objects).resolve()
    probe.put(world / '.git/objects/info/alternates', str(objects) + '\n')
    refs = json.loads((HERE / 'refs.json').read_text())
    # Retain actual published tag objects, not synthetic origin/provenance.
    for name, sha in refs:
        probe.git(world, 'update-ref', name, sha)
    probe.put(world / 'registry/owner-overrides.tsv', probe.registry(probe.ROWS))
    peeled = probe.git(world, 'for-each-ref', '--format=%(refname) %(*objectname) %(objectname)', 'refs/tags/')
    return {line.split()[0]: (line.split()[-1], line.split()[1]) for line in peeled.splitlines()}


def main():
    args = sys.argv[1:]
    record = '--record-reproducibility' in args
    if record:
        args.remove('--record-reproducibility')
    if args != ['--model'] and not (len(args) == 2 and args[0] == '--repo'):
        raise RuntimeError('HISTORICAL_USAGE: --model | --repo R [--record-reproducibility]')
    if record and args != ['--model']:
        raise RuntimeError('HISTORICAL_RECORD_BASELINE_ONLY')
    # Snapshot all expectations and the closed exception budget before subjects.
    expected = json.loads((HERE / 'historical.json').read_text())
    manifest = json.loads(MANIFEST.read_text())
    declared = set(manifest['declared_unreproducible_shas'])
    shas = sorted({r[1] for r in probe.ROWS if r[1] != '-'})
    pairs = [(sha, gate) for sha in shas for gate in probe.GATES]
    if (expected['baseline'] != probe.build.BASE or manifest['baseline'] != probe.build.BASE or
            [(r['sha'], r['gate']) for r in expected['records']] != pairs or
            len(declared) != len(manifest['declared_unreproducible_shas']) or not declared.issubset(set(shas))):
        raise RuntimeError('HISTORICAL_ORACLE_INCOMPLETE')
    answers = {(r['sha'], r['gate']): {k: v for k, v in r.items() if k not in ('sha', 'gate')}
               for r in expected['records']}
    for entry in manifest['unreproducible']:
        if entry['saved'] != answers[entry['sha'], entry['gate']]:
            raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: changed saved answer')
    bad = decisions = 0
    observed = []
    excluded = []
    proof = []
    with tempfile.TemporaryDirectory(prefix='historical-', dir=probe.SCRATCH) as tmp:
        work = Path(tmp)
        subject = probe.materialize(work / 'subject', model=args == ['--model'],
                                    repo=ROOT if args == ['--model'] else Path(args[1]).resolve())
        baseline = probe.materialize(work / 'baseline')
        for gate in probe.GATES:
            text = probe.build.base('scripts/' + gate + '.sh')
            if hashlib.sha256(text.encode()).hexdigest() != probe.BASELINE['files'][gate]:
                raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: baseline source ' + gate)
            probe.put(baseline / 'scripts' / (gate + '.sh'), text)
        world = work / 'world'
        all_refs = history_world(world)
        active_refs = set(all_refs)
        for sha in shas:
            if probe.git(world, 'cat-file', '-t', sha) != 'commit':
                raise RuntimeError('HISTORICAL_COMMIT_MISSING: ' + sha)
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
                cache = world / ('cache-' + gate)
                probe.put(cache, parent + '\n')
                extra = () if gate == 'check_contract_frozen' else ('--incr', cache)
                registry = (tree / 'registry/owner-overrides.tsv')
                data = registry.read_bytes() if registry.is_file() else b''
                probe.put(world / 'registry/owner-overrides.tsv', data)
                return digest(probe.cli(tree, world, gate, extra))

            stable_sha = True
            for gate in probe.GATES:
                saved = answers[sha, gate]
                stable, rechecked = assess(saved, lambda: invoke(baseline, gate))
                proof.append(dict(sha=sha, gate=gate, saved=saved, rechecked=rechecked))
                if not stable:
                    stable_sha = False
                    try:
                        exclusion(sha, gate, saved, rechecked, declared, observed)
                    finally:
                        checkpoint = dict(baseline=probe.build.BASE, complete=False,
                                          declared_unreproducible_shas=sorted(declared),
                                          unreproducible=observed, observations=proof)
                        probe.put(probe.SCRATCH / 'historical-reproducibility-observed.json',
                                  json.dumps(checkpoint, indent=2) + '\n')
                elif saved['rc'] not in (0, 1):
                    raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: stable invalid rc ' + repr((sha, gate, saved)))
            if not stable_sha:
                excluded.append(sha)
                print('HISTORICAL_SHA', sha, 'EXCLUDED_UNREPRODUCIBLE', flush=True)
                continue
            for gate in probe.GATES:
                actual = invoke(subject, gate)
                decisions += 1
                if actual['rc'] not in (0, 1):
                    raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: candidate ' + repr((sha, gate, actual)))
                if not parity(answers[sha, gate], actual):
                    bad += 1
                    print('KRASNO historical', sha, gate, actual, flush=True)
            print('HISTORICAL_SHA', sha, 'doors=4', flush=True)
    report = dict(baseline=probe.build.BASE, complete=True,
                  declared_unreproducible_shas=sorted(declared), unreproducible=observed,
                  reproducible_shas=[sha for sha in shas if sha not in excluded], observations=proof)
    probe.put(probe.SCRATCH / 'historical-reproducibility-observed.json', json.dumps(report, indent=2) + '\n')
    if record:
        # The saved oracle remains untouched; only measured baseline evidence.
        probe.put(MANIFEST, json.dumps(report, indent=2) + '\n')
    print(f'HISTORICAL_SHAS={len(shas)} REPRODUCIBLE_SHAS={len(shas)-len(excluded)} '
          f'EXCLUDED_SHAS={len(excluded)} UNREPRODUCIBLE_RESPONSES={len(observed)} '
          f'DECISIONS={decisions} MISMATCHES={bad}', flush=True)
    return int(bad != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, subprocess.SubprocessError, KeyError, ValueError, IndexError, TypeError) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        sys.exit(2)
