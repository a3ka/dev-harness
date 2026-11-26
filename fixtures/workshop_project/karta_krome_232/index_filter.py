#!/usr/bin/env python3
"""Crit232b exact text/CRLF counterexample, before and after the raw-byte repair."""
import argparse
from pathlib import Path
import tempfile
import probe

BASE = '0901d79cf18d64073c9ad25f13065cbf7ad7b603'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--before', action='store_true')
    args = parser.parse_args()
    _, saved = probe.carriers()
    overlay = {name: saved['model/' + name] for name in probe.FILES}
    if args.before:
        overlay = {name: probe.git(probe.REPO, 'show', BASE + ':' +
                   str(probe.HERE.relative_to(probe.REPO)) + '/model/' + name)
                   for name in probe.FILES}
    bad = 0
    for case in ('pj-index-text-normalized', 'pj-index-text-lf', 'pj-index-crlf-raw'):
        spec = probe.CASES[case]
        with tempfile.TemporaryDirectory(prefix='index-filter232-', dir=probe.REPO / 'tmp') as tmp:
            tools = probe.installed(Path(tmp), probe.REPO, overlay)
            root, target, body, head, _ = probe.world(Path(tmp), spec, tools, saved)
            initial_index = probe.git(root, 'ls-files', '--stage', '--', target)

            def call(label, expected):
                before_index = probe.git(root, 'ls-files', '--stage', '--', target)
                p = probe.run(['bash', tools / 'scripts/pre_judge.sh', 'verdict',
                               '--repo', root, '--file', target])
                print(case, label, 'rc=', p.returncode, 'stdout=', repr(p.stdout),
                      'stderr=', repr(p.stderr), flush=True)
                refused = ('ОТКАЗ: KARTA_NE_SHTATNA\n'.encode() +
                           'карта не штатная: индекс отличается от --file\n'.encode())
                expected_output = (b'VERDICT_BRANCH=wip/178/critic\n', b'') if expected == 0 else (b'', refused)
                return (p.returncode != expected or (p.stdout, p.stderr) != expected_output or
                        probe.git(root, 'rev-parse', 'HEAD') != head or
                        (root / target).read_bytes() != body or
                        probe.git(root, 'ls-files', '--stage', '--', target) != before_index)

            bad += bool(initial_index)
            bad += call('unstaged', 0)
            probe.git(root, 'add', '--', target)
            staged = probe.git(root, 'rev-parse', ':' + target)
            # --stdin has no path attributes: hash the exact bytes, not clean(body).
            raw = probe.checked(['git', '-C', root, 'hash-object', '--no-filters', '--', root / target])
            print(case, 'staged=', repr(staged), 'raw=', repr(raw), flush=True)
            if case == 'pj-index-text-normalized':
                bad += staged != b'be050a1b0a0be911950356926920c3d927559d0a\n'
                bad += raw != b'b73f98cb5211388f1a4599047b5b511e15cc151d\n'
            else:
                bad += staged != raw
            expected = 0 if args.before else spec.get('rc', 0)
            bad += call('staged', expected)
    return int(bad != 0)


if __name__ == '__main__':
    raise SystemExit(main())
