#!/usr/bin/env python3
"""Executable gate: each negative input has its own outcome and matching deceptive stub."""
import argparse
from copy import deepcopy
import json
from pathlib import Path
import subprocess
import sys
import tempfile

import model
import stabs

HERE = Path(__file__).resolve().parent
OBJECT = 'a' * 40
OTHER = 'b' * 40
URI = 'history://Critic165a'
VERDICT = f'accept\nOBJECT={OBJECT}\nСУД: repo=dev-harness; роль=critic; сессия=Critic165a; предмет=165;\nЗавершённый суд.\n'
BASE = {'source': URI, 'agent': 'critic', 'task': 'SUBJECT=165\nOBJECT=' + OBJECT + '\n',
        'result': {'tool': 'yield', 'complete': True, 'verdict': VERDICT}}


def cases():
    yield 'source', {'source': 'disk://Critic165a'}, URI, model.QUOTE, OBJECT, 'ISTOCHNIK_NE_CRITIC_HISTORY', stabs.source_any
    yield 'author', {'agent': 'reviewer'}, URI, model.QUOTE, OBJECT, 'AVTOR_NE_CRITIC', stabs.role_any
    yield 'owner', {}, URI, 'утверждаю пакет 1', OBJECT, 'NET_BUKVALNOJ_TSITATY', stabs.quote_any
    yield 'task-object', {'task': 'SUBJECT=165\nOBJECT=' + OTHER}, URI, model.QUOTE, OBJECT, 'ZADANIE_NE_OB_OBJECT', stabs.task_any
    yield 'incomplete', {'result': {'complete': False}}, URI, model.QUOTE, OBJECT, 'NET_ZAKONCHENNOGO_YIELD', stabs.incomplete_any
    yield 'forged-accept', {'result': {'verdict': VERDICT.replace('accept\n', 'FAIL\n', 1)}}, URI, model.QUOTE, OBJECT, 'VERDICT_NE_ACCEPT', stabs.forged_accept
    yield 'verdict-object', {'result': {'verdict': VERDICT.replace('OBJECT=' + OBJECT, 'OBJECT=' + OTHER)}}, URI, model.QUOTE, OBJECT, 'VERDICT_OBJECT_NE_SOVPAL', stabs.wrong_object
    yield 'verdict-author', {'result': {'verdict': VERDICT.replace('роль=critic;', 'роль=reviewer;')}}, URI, model.QUOTE, OBJECT, 'VERDICT_AVTOR_NE_CRITIC', stabs.verdict_role_any
    yield 'no-verdict', {'result': {'verdict': None}}, URI, model.QUOTE, OBJECT, 'NET_VERDIKTA', stabs.missing_verdict_any


def make_history(delta):
    h = deepcopy(BASE)
    for key, value in delta.items():
        if isinstance(value, dict):
            h[key].update(value)
        else:
            h[key] = value
    return h


def invoke(candidate, history, uri, owner, obj):
    with tempfile.TemporaryDirectory(prefix='materializer-165-') as tmp:
        root = Path(tmp)
        history_file, owner_file, output = root / 'history.json', root / 'owner.txt', root / 'verdict.md'
        history_file.write_text(json.dumps(history))
        owner_file.write_text(owner)
        cmd = [sys.executable, str(candidate), '--history', str(history_file), '--history-uri', uri,
               '--owner-text', str(owner_file), '--object', obj, '--output', str(output)]
        result = subprocess.run(cmd, text=True, capture_output=True)
        written = output.read_text() if output.exists() else None
        return result.returncode, result.stdout + result.stderr, written


def battery(candidate, stubs=False):
    rc, output, written = invoke(candidate, BASE, URI, model.QUOTE, OBJECT)
    if rc != 0 or written != VERDICT:
        print(f'CONTROL_NOT_GREEN: rc={rc} {output}', file=sys.stderr)
        return 1
    failures = 0
    for name, delta, uri, owner, obj, reason, stab in cases():
        h = make_history(delta)
        rc, output, written = invoke(candidate, h, uri, owner, obj)
        if rc != 1 or reason not in output or written is not None:
            print(f'{name}: NOT_RED rc={rc} output={output!r} written={written is not None}', file=sys.stderr)
            failures += 1
            continue
        if stubs:
            try:
                accepted = stab(h, uri, owner, obj)
            except model.Refusal as e:
                print(f'{name}: STUB_NOT_EXPOSED {e}', file=sys.stderr)
                failures += 1
            else:
                if not accepted.startswith('accept\n'):
                    print(f'{name}: STUB_BAD_RESULT', file=sys.stderr)
                    failures += 1
        print(f'{name}: {reason}; stub={"accepted" if stubs else "not-run"}')
    print(f'cells={sum(1 for _ in cases())}; failures={failures}')
    return 1 if failures else 0


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--repo', type=Path)
    args = parser.parse_args()
    if args.repo:
        candidate = args.repo / 'scripts' / 'materialize_verdict_165.py'
        if not candidate.is_file():
            print('SUBJECT_ABSENT: scripts/materialize_verdict_165.py', file=sys.stderr)
            return 1
    else:
        candidate = HERE / 'model.py'
    return battery(candidate, stubs=args.stabs)


if __name__ == '__main__':
    sys.exit(main())
