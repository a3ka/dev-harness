#!/usr/bin/env python3
"""Validate response values against the pinned OpenAPI-derived schema, not DTO guesses."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys
import subprocess
from jsonschema import Draft202012Validator
from runtime_probe import run as run_runtime

HERE = Path(__file__).resolve().parent


def validate(root, values):
    errors = []
    for operation, name in [('getSession', 'Session'), ('getDisclosure', 'Disclosure')]:
        schema = {'$ref': '#/components/schemas/' + name, 'components': root['components']}
        failures = list(Draft202012Validator(schema).iter_errors(values.get(operation)))
        if failures: errors.append('MOCK_SCHEMA_INVALID:' + operation)
    return errors


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--repo', type=Path, required=True)
    p.add_argument('--matrix', action='store_true')
    p.add_argument('--model', choices=['honest', 'wrong-session', 'wrong-disclosure'])
    a = p.parse_args()
    expected = json.loads((HERE / 'source.json').read_text())
    raw = (a.repo / 'api/mock-5_8.json').read_bytes()
    if hashlib.sha256(raw).hexdigest() != expected['hashes']['schema']:
        raise RuntimeError('SCHEMA_SOURCE_CHANGED')
    root = json.loads(raw)
    honest = {'getSession': expected['session'], 'getDisclosure': expected['disclosure']}
    if not a.matrix and not a.model:
        path = a.repo / 'mobile/src/mocks/pilot-responses.json'
        if not path.exists():
            print('MOCK_RESPONSES_ABSENT'); return 1
        values = json.loads(path.read_text())
        errors = validate(root, values)
        if errors:
            print('\n'.join(errors)); return 1
        rc, _ = run_runtime(a.repo, ['RUNTIME_RESPONSES'], values=values)
        print('RUNTIME_RESPONSES_MISMATCH' if rc else '995 schema checked=2 runtime=matched')
        return rc
    rows = [('honest', None), ('wrong-session', 'MOCK_SCHEMA_INVALID:getSession'), ('wrong-disclosure', 'MOCK_SCHEMA_INVALID:getDisclosure')]
    results = []
    for mode, reason in rows:
        if not a.matrix and a.model != mode: continue
        values = copy.deepcopy(honest)
        if mode == 'wrong-session': values['getSession']['principal_ref'] = 42
        if mode == 'wrong-disclosure': values['getDisclosure']['acknowledged'] = 'false'
        errors = validate(root, values)
        rc = int(bool(errors))
        print(f'995 schema/{mode}: rc={rc} reasons={errors}')
        results.append(errors == ([] if reason is None else [reason]))
        if not a.matrix: return rc
    if a.matrix:
        for model, reason in [('honest', ''), ('wrong-session', 'principal_ref'), ('wrong-disclosure', 'acknowledged')]:
            rc, failure = run_runtime(a.repo, ['RUNTIME_RESPONSES'], model=model, values=honest)
            expected_rc = int(model != 'honest')
            results.append(rc == expected_rc and reason in failure)
            print(f'995 schema/runtime-{model}: rc={rc} fixture_schema=valid')
    print(f'995 schema checked={len(results)}')
    return int(not all(results))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.TimeoutExpired) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr)
        sys.exit(2)
