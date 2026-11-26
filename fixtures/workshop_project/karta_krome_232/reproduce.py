#!/usr/bin/env python3
"""Crit232 counterexamples on the archived and current reference, real pre-commit calls."""
import argparse
from pathlib import Path
import tempfile
import probe

BASE = 'bbda9d3f9ebcb035e95b4671db8064a46dbe7a23'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--before', action='store_true')
    args = parser.parse_args()
    _, saved = probe.carriers()
    overlay = {name: saved['model/' + name] for name in probe.FILES}
    if args.before:
        overlay = {name: probe.git(probe.REPO, 'show', BASE + ':' + str(probe.HERE.relative_to(probe.REPO)) + '/model/' + name)
                   for name in probe.FILES if name != 'check_verdict_karta.sh'}
    bad = 0
    for case in ('new', 'replacement'):
        with tempfile.TemporaryDirectory(prefix='reproduce232-', dir=probe.REPO / 'tmp') as tmp:
            work = Path(tmp)
            tools = probe.installed(work, probe.REPO, overlay)
            root, target, _, _, _ = probe.world(work, {'call': '1'}, tools, saved)
            if case == 'new':
                target = 'verdicts/critic/contracts-178-v1-new.md'
                probe.put(root, target, probe.verdict('2'))
            else:
                probe.put(root, target, probe.verdict('1', {5: 'чисто'}))
            head = probe.git(root, 'rev-parse', 'HEAD')
            p = probe.run(['bash', tools / 'scripts/pre_judge.sh', 'verdict', '--repo', root, '--file', target])
            expected = (1 if case == 'new' else 0) if args.before else (0 if case == 'new' else 1)
            print(case, 'rc=', p.returncode, 'stdout=', repr(p.stdout), 'stderr=', repr(p.stderr), flush=True)
            bad += p.returncode != expected or probe.git(root, 'rev-parse', 'HEAD') != head
            if case == 'replacement':
                probe.git(root, 'add', target)
                probe.git(root, 'commit', '-qm', 'materialized invalid replacement')
                q = probe.run(['bash', tools / 'scripts/check_verdict_karta.sh', root, target])
                print('replacement-after-commit rc=', q.returncode, 'stdout=', repr(q.stdout), 'stderr=', repr(q.stderr), flush=True)
                bad += q.returncode != 1
    return int(bad != 0)


if __name__ == '__main__':
    raise SystemExit(main())
