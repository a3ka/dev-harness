#!/usr/bin/env python3
"""Full CLI differential on every literal historical grant SHA, crossed with four doors.

No synthetic SHA replacement: object database and annotated refs come from the
pinned Git ancestor. An incr window ending at the original commit is restored
for each invocation. Captured rc and both stream hashes are literal oracle data.
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


def digest(result):
    rc, stdout, stderr = result
    return {'rc': rc, 'stdout_sha256': hashlib.sha256(stdout).hexdigest(),
            'stderr_sha256': hashlib.sha256(stderr).hexdigest()}


def history_world(world):
    world.mkdir()
    probe.git(world, 'init', '-q')
    objects = probe.git(ROOT, 'rev-parse', '--git-path', 'objects')
    objects = (ROOT / objects).resolve()
    probe.put(world / '.git/objects/info/alternates', str(objects) + '\n')
    refs = json.loads((HERE / 'refs.json').read_text())
    # Actual published tag objects are retained, including grandfather provenance;
    # no origin is invented and no tag is retargeted to a fixture commit.
    for name, sha in refs:
        probe.git(world, 'update-ref', name, sha)
    probe.put(world / 'registry/owner-overrides.tsv', probe.registry(probe.ROWS))
    peeled = probe.git(world, 'for-each-ref', '--format=%(refname) %(*objectname) %(objectname)', 'refs/tags/')
    return {line.split()[0]: (line.split()[-1], line.split()[1]) for line in peeled.splitlines()}


def main():
    args = sys.argv[1:]
    resume = args == ['--capture-resume']
    capture = args in (['--capture'], ['--capture-resume'])
    if not capture and args not in (['--model'], ['--repo', '.']) and not (len(args) == 2 and args[0] == '--repo'):
        raise RuntimeError('HISTORICAL_USAGE')
    if not capture or resume:
        expected = json.loads((HERE / 'historical.json').read_text())
    records = list(expected['records']) if resume else []
    resumed = len(records)
    if not capture or resume:
        invalid = [(r['sha'], r['gate'], r['rc']) for r in expected['records'] if r['rc'] not in (0, 1)]
        if invalid:
            raise RuntimeError('HISTORICAL_ORACLE_TOOL_FAILURE: ' + repr(invalid))
    bad = 0
    shas = sorted({r[1] for r in probe.ROWS if r[1] != '-'})
    pairs = [(sha, gate) for sha in shas for gate in probe.GATES]
    if capture:
        for gate in probe.GATES:
            source = (ROOT / 'scripts' / (gate + '.sh')).read_bytes()
            if hashlib.sha256(source).hexdigest() != probe.BASELINE['files'][gate]:
                raise RuntimeError('CAPTURE_SOURCE_NOT_BASELINE: ' + gate)
    if resume and (not resumed or expected['baseline'] != probe.build.BASE or
                   [(r['sha'], r['gate']) for r in records] != pairs[:resumed]):
        raise RuntimeError('HISTORICAL_RESUME_NOT_BASELINE_PREFIX')
    if resume:
        print(f'RESUMED_DECISIONS={resumed}', flush=True)
    if not capture and (expected['baseline'] != probe.build.BASE or
                        [(r['sha'], r['gate']) for r in expected['records']] !=
                        [(sha, gate) for sha in shas for gate in probe.GATES]):
        raise RuntimeError('HISTORICAL_ORACLE_INCOMPLETE')
    with tempfile.TemporaryDirectory(prefix='historical-', dir=probe.SCRATCH) as tmp:
        work = Path(tmp)
        subject = probe.materialize(work / 'subject', model=args == ['--model'],
                                    repo=ROOT if capture or args == ['--model'] else Path(args[1]).resolve())
        world = work / 'world'
        all_refs = history_world(world)
        active_refs = set(all_refs)
        if not capture:
            candidate = subject / 'registry/owner-overrides.tsv'
            probe.put(world / 'registry/owner-overrides.tsv', candidate.read_bytes() if candidate.is_file() else b'')
        visited = 0
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
            for gate in probe.GATES:
                visited += 1
                if visited <= resumed:
                    continue
                cache = world / ('cache-' + gate)
                probe.put(cache, parent + '\n')
                # Frozen has no incr public interface; its full CLI is compared.
                extra = () if gate == 'check_contract_frozen' else ('--incr', cache)
                result = probe.cli(subject, world, gate, extra)
                if result[0] not in (0, 1):
                    raise RuntimeError('HISTORICAL_TOOL_FAILURE: ' + repr((sha, gate, result)))
                item = dict(sha=sha, gate=gate, **digest(result))
                records.append(item)
                if capture:
                    probe.put(HERE / 'historical.json', json.dumps({'baseline': probe.build.BASE, 'records': records}, indent=2) + '\n')
                if not capture and item != expected['records'][len(records) - 1]:
                    bad += 1
                    print('KRASNO historical', sha, gate, item, flush=True)
                    print(f'HISTORICAL_SHAS={len(shas)} DECISIONS={len(records)} MISMATCHES={bad}')
                    return 1
            print('HISTORICAL_SHA', sha, 'doors=4', flush=True)
    if capture:
        probe.put(HERE / 'historical.json', json.dumps({'baseline': probe.build.BASE, 'records': records}, indent=2) + '\n')
    print(f'HISTORICAL_SHAS={len(shas)} DECISIONS={len(records)} MISMATCHES={bad}')
    return int(bad != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, subprocess.SubprocessError, KeyError, ValueError, IndexError, TypeError) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        sys.exit(2)
