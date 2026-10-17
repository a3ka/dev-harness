#!/usr/bin/env python3
"""993 handoff CLI mutations; no main-validator cells are changed.

Conformant inputs are complete delivered trees with FILES.sha256 lines in the
existing '<sha256>  <relative path>' format and one historical SQL file per
001..013. The oracle (paths, bytes, hashes, expected outcomes) is captured before
executing the subject. --subject is a proof-only readonly source override; its
own checksum is refreshed in the disposable copy, never in the source repo.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

CLI = 'tools/verify_handoff.py'


def snapshot(repo):
    lines = (repo / 'FILES.sha256').read_text().splitlines()
    entries = dict(line.split('  ', 1)[::-1] for line in lines)
    historical = []
    for number in range(1, 14):
        paths = list((repo / 'db').glob(f'{number:03d}_*.sql'))
        assert len(paths) == 1, f'BASELINE_DB_{number:03d}'
        path = paths[0].relative_to(repo).as_posix()
        data = paths[0].read_bytes()
        assert entries.get(path) == hashlib.sha256(data).hexdigest(), path
        historical.append((path, data))
    return lines, historical


def cases(historical):
    yield 'baseline', 'baseline', None, 0, None
    yield 'add-014', 'add-014', None, 0, None
    yield 'add-014-015', 'add-014-015', None, 0, None
    for kind in ('corrupt', 'missing-file', 'missing-entry'):
        for path, _ in historical:
            yield f'{kind}-{Path(path).name[:3]}', kind, path, 1, f'AssertionError: {path}'


def run(repo, out, subject=None, selected=None):
    lines, historical = snapshot(repo)
    source = (subject or (repo / CLI)).read_bytes()
    # Expectations and all source bytes above are in memory before any CLI call.
    rows = list(cases(historical))
    if selected:
        assert any(row[0] == selected for row in rows), 'EMPTY_SELECTION'
        rows = [row for row in rows if row[0] in ('baseline', selected)]
    assert rows, 'EMPTY_SELECTION'
    out.mkdir(parents=True, exist_ok=False)
    results = []
    with tempfile.TemporaryDirectory(prefix='handoff993-') as temporary:
        root = Path(temporary) / 'repo'
        shutil.copytree(repo, root, ignore=shutil.ignore_patterns('.git', 'node_modules', '.venv', '__pycache__'))
        cli = root / CLI
        cli.write_bytes(source)
        cli.chmod(0o444)
        original = [line for line in lines if line.split('  ', 1)[1] != CLI]
        original.append(hashlib.sha256(source).hexdigest() + '  ' + CLI)
        added = ['db/014_probe_993.sql', 'db/015_probe_993.sql']
        assert not any((root / path).exists() for path in added), 'PROBE_PATH_OCCUPIED'
        for name, kind, path, expected_rc, reason in rows:
            for relative, data in historical:
                (root / relative).write_bytes(data)
            for relative in added:
                (root / relative).unlink(missing_ok=True)
            current = list(original)
            if kind.startswith('add-'):
                for relative in added[:1 if kind == 'add-014' else 2]:
                    data = b'-- additive handoff integrity fixture; not runtime evidence\nSELECT 1;\n'
                    (root / relative).write_bytes(data)
                    current.append(hashlib.sha256(data).hexdigest() + '  ' + relative)
            elif kind == 'corrupt':
                target = root / path
                data = target.read_bytes()
                target.write_bytes(bytes([data[0] ^ 1]) + data[1:])
            elif kind == 'missing-file':
                (root / path).unlink()
            elif kind == 'missing-entry':
                current = [line for line in current if line.split('  ', 1)[1] != path]
            (root / 'FILES.sha256').write_text('\n'.join(current) + '\n')
            result = subprocess.run([sys.executable, str(cli)], cwd=root,
                                    capture_output=True, text=True, timeout=120)
            report = None
            if expected_rc == 0:
                try:
                    report = json.loads(result.stdout)
                except ValueError:
                    pass
                matched = (result.returncode == 0 and isinstance(report, dict)
                           and report.get('status') == 'PASS_STATIC'
                           and report.get('all_manifest_files_and_hashes') == 'PASS'
                           and report.get('runtime_acceptance') == 'NOT_ASSERTED')
            else:
                # Exact standalone final exception line, not a path in traceback source.
                stderr_lines = result.stderr.rstrip().splitlines()
                matched = (result.returncode == 1 and bool(stderr_lines)
                           and stderr_lines[-1] == reason)
            results.append(dict(case=name, expected_rc=expected_rc, reason=reason,
                                rc=result.returncode, matched=matched,
                                stdout=result.stdout, stderr=result.stderr))
            print(f'993 handoff case={name} rc={result.returncode} expected={expected_rc} matched={matched}', flush=True)
    baseline = next((row for row in results if row['case'] == 'baseline'), None)
    # A negative is measurable only with its unchanged full-tree control.
    assert baseline and baseline['matched'], 'BASELINE_NOT_GREEN'
    mismatch = sum(not row['matched'] for row in results)
    (out / 'raw.json').write_text(json.dumps(results, indent=2) + '\n')
    print(f'993 handoff cases={len(results)} mismatches={mismatch} baseline_green={bool(baseline and baseline["matched"])}')
    return int(bool(mismatch))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--subject', type=Path)
    parser.add_argument('--case')
    args = parser.parse_args()
    return run(args.repo.resolve(), args.out.resolve(), args.subject, args.case)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, AssertionError, subprocess.TimeoutExpired) as error:
        print('993 HANDOFF_UNMEASURABLE: ' + str(error), file=sys.stderr)
        sys.exit(2)
