#!/usr/bin/env python3
"""Executable gate: each negative input has its own outcome and matching deceptive stub.

Оракул — снимок ВСЕХ файлов игрушечного корня до/после вызова (правило 8:
ожидания в памяти проверяющего, диск проверяемого не истина): место записи
(зона verdicts/critic/), побайтовое содержание и неизменность остального
наблюдаются напрямую, а не выводом кандидата.
"""
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
NONHEX = 'a' * 39 + 'z'
URI = 'history://Critic165a'
BAD_URI = 'history://Reviewer165a'
VERDICT = f'accept\nOBJECT={OBJECT}\nСУД: repo=dev-harness; роль=critic; сессия=Critic165a; предмет=165;\nЗавершённый суд.\n'
BASE = {'source': URI, 'agent': 'critic', 'task': 'SUBJECT=165\nOBJECT=' + OBJECT + '\n',
        'result': {'tool': 'yield', 'complete': True, 'verdict': VERDICT}}
OUT = 'verdict.md'
IN_ZONE = 'verdicts/critic/' + OUT
OLD_BYTES = 'accept\nOBJECT=' + OTHER + '\nСТАРЫЕ БАЙТЫ, НЕ СОВПАДАЮЩИЕ С МАТЕРИАЛИЗУЕМЫМ ВЕРДИКТОМ\n'


def cases():
    yield 'source', {'source': 'disk://Critic165a'}, URI, model.QUOTE, OBJECT, OUT, None, 'ISTOCHNIK_NE_CRITIC_HISTORY', stabs.source_any
    yield 'author', {'agent': 'reviewer'}, URI, model.QUOTE, OBJECT, OUT, None, 'AVTOR_NE_CRITIC', stabs.role_any
    yield 'owner', {}, URI, 'утверждаю пакет 1', OBJECT, OUT, None, 'NET_BUKVALNOJ_TSITATY', stabs.quote_any
    yield 'task-object', {'task': 'SUBJECT=165\nOBJECT=' + OTHER}, URI, model.QUOTE, OBJECT, OUT, None, 'ZADANIE_NE_OB_OBJECT', stabs.task_any
    yield 'incomplete', {'result': {'complete': False}}, URI, model.QUOTE, OBJECT, OUT, None, 'NET_ZAKONCHENNOGO_YIELD', stabs.incomplete_any
    yield 'forged-accept', {'result': {'verdict': VERDICT.replace('accept\n', 'FAIL\n', 1)}}, URI, model.QUOTE, OBJECT, OUT, None, 'VERDICT_NE_ACCEPT', stabs.forged_accept
    yield 'verdict-object', {'result': {'verdict': VERDICT.replace('OBJECT=' + OBJECT, 'OBJECT=' + OTHER)}}, URI, model.QUOTE, OBJECT, OUT, None, 'VERDICT_OBJECT_NE_SOVPAL', stabs.wrong_object
    yield 'verdict-author', {'result': {'verdict': VERDICT.replace('роль=critic;', 'роль=reviewer;')}}, URI, model.QUOTE, OBJECT, OUT, None, 'VERDICT_AVTOR_NE_CRITIC', stabs.verdict_role_any
    yield 'no-verdict', {'result': {'verdict': None}}, URI, model.QUOTE, OBJECT, OUT, None, 'NET_VERDIKTA', stabs.missing_verdict_any
    yield 'uri', {'source': BAD_URI, 'result': {'verdict': VERDICT.replace('сессия=Critic165a;', 'сессия=Reviewer165a;')}}, BAD_URI, model.QUOTE, OBJECT, OUT, None, 'URI_NEVALIDEN', stabs.uri_valid
    yield 'object-hex', {'task': 'SUBJECT=165\nOBJECT=' + NONHEX, 'result': {'verdict': VERDICT.replace('OBJECT=' + OBJECT, 'OBJECT=' + NONHEX)}}, URI, model.QUOTE, NONHEX, OUT, None, 'OBJECT_NEVALIDEN', stabs.object_hex
    yield 'sud-second', {'result': {'verdict': VERDICT + 'СУД: роль=critic; сессия=Critic165a;\n'}}, URI, model.QUOTE, OBJECT, OUT, None, 'SUD_NE_EDINSTVENNA', stabs.sud_single
    yield 'out-zone', {}, URI, model.QUOTE, OBJECT, '../vne_zony.md', None, 'OUT_ZONE', stabs.out_in_zone
    yield 'perezapis', {}, URI, model.QUOTE, OBJECT, OUT, OLD_BYTES, 'PEREZAPIS_NE_SOVPAL', stabs.perezapis_same


def make_history(delta):
    h = deepcopy(BASE)
    for key, value in delta.items():
        if isinstance(value, dict):
            h[key].update(value)
        else:
            h[key] = value
    return h


def snapshot(root):
    files = {}
    for path in sorted(root.rglob('*')):
        if path.is_file():
            files[str(path.relative_to(root))] = path.read_bytes()
    return files


def invoke(candidate, history, uri, owner, obj, out=OUT, seed=None):
    with tempfile.TemporaryDirectory(prefix='materializer-165-') as tmp:
        root = Path(tmp)
        zone = root / 'verdicts' / 'critic'
        zone.mkdir(parents=True)
        history_file, owner_file = root / 'history.json', root / 'owner.txt'
        history_file.write_text(json.dumps(history))
        owner_file.write_text(owner)
        if seed is not None:
            (zone / OUT).write_text(seed)
        before = snapshot(root)
        cmd = [sys.executable, str(candidate), '--repo-root', str(root), '--history', str(history_file),
               '--history-uri', uri, '--owner-text', str(owner_file), '--object', obj, '--output', out]
        result = subprocess.run(cmd, text=True, capture_output=True)
        after = snapshot(root)
        changed = sorted(name for name in after if after[name] != before.get(name))
        return result.returncode, result.stdout + result.stderr, changed, after.get(IN_ZONE)


def battery(candidate, stubs=False):
    rc, output, changed, written = invoke(candidate, BASE, URI, model.QUOTE, OBJECT)
    if rc != 0 or changed != [IN_ZONE] or written != VERDICT.encode():
        print(f'CONTROL_NOT_GREEN: rc={rc} changed={changed} written={written!r} {output}', file=sys.stderr)
        return 1
    failures = 0
    for name, delta, uri, owner, obj, out, seed, reason, stab in cases():
        h = make_history(delta)
        rc, output, changed, written = invoke(candidate, h, uri, owner, obj, out, seed)
        if rc != 1 or reason not in output or changed:
            print(f'{name}: NOT_RED rc={rc} reason={reason in output} changed={changed} output={output!r}', file=sys.stderr)
            failures += 1
            continue
        if stubs:
            try:
                accepted = stab(h, uri, owner, obj, out, seed)
            except (model.Refusal, model.EnvMissing, OSError) as e:
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
