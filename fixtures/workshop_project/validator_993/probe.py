#!/usr/bin/env python3
"""993: execute the real Complior validator against isolated full-input mutations.

No validator implementation or rule shim is supplied here. Before implementation,
controls are expected to expose the broken baseline, NOT count as green tests.
Failure IDs form the diagnostic contract with the implementer. --diagnostic only
measures the historical bodyless crash with a single explicitly labelled in-memory
source substitution; it is never used by the acceptance matrix.
"""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import yaml

API = 'contracts/BrokerOS_Unified_OpenAPI_v3.yaml'
INDEX = 'contracts/operation-index.json'
BINDINGS = 'contracts/frontend-consumer-bindings.json'
VALIDATOR = 'tests/validate_contract_v3_9.py'
POST_PAGE = {'items': [], 'next_cursor': None, 'as_of': '2026-10-17T00:00:00Z'}


def operations(api):
    return {op['operationId']: op for methods in api['paths'].values()
            for op in methods.values() if isinstance(op, dict) and 'operationId' in op}


def required_checks(api):
    """Independent source walk; never infer coverage from index, cases or report."""
    expected = set()
    for oid, op in operations(api).items():
        rules = {'problem', 'response_example'}
        if not op.get('deprecated', False):
            rules.update(('source_consumers', 'consumer_resolution'))
        else:
            rules.add('consumer_availability')
        if 'requestBody' in op:
            # A local requestBody $ref is still a body, not an exemption.
            rules.add('request_example')
        if 'x-authentication-policy' in op:
            rules.add('provider_auth')
        else:
            rules.add('contract_scope_policy')
        expected.update(oid + '_' + rule for rule in rules)
    for methods in api['paths'].values():
        for method in ('post', 'put', 'patch', 'delete'):
            op = methods.get(method)
            if not isinstance(op, dict) or 'operationId' not in op:
                continue
            oid = op['operationId']
            if 'x-authentication-policy' in op:
                continue
            rules = {'policy_consistency'}
            if op.get('x-command-policy', {}).get('mutation') is not False:
                # cas records both required target CAS and justified no-target CAS.
                rules.update(('command_identity', 'command_idempotency', 'cas', 'csrf'))
            if 'x-conditional-policy' in op:
                rules.add('conditional_policy')
            expected.update(oid + '_' + rule for rule in rules)
    if not expected:
        raise ValueError('EMPTY_OPERATION_COVERAGE')
    return frozenset(expected)


def coverage_failures(report, expected):
    checks = report.get('checks') if isinstance(report, dict) else None
    if not isinstance(checks, list) or any(
            not isinstance(row, dict) or not isinstance(row.get('id'), str)
            for row in checks):
        return ['CHECK_COVERAGE_INVALID_REPORT']
    observed = {row['id'] for row in checks}
    return ['CHECK_COVERAGE_MISSING:' + key for key in sorted(expected - observed)]


def remove_header(api, op, name):
    def resolved(p):
        if '$ref' in p:
            return api['components']['parameters'][p['$ref'].split('/')[-1]]
        return p
    before = op['parameters']
    after = [p for p in before if resolved(p)['name'] != name]
    assert len(after) < len(before), ('MUTATION_NOT_APPLIED', name)
    op['parameters'] = after


def media(op):
    return op['requestBody']['content']['application/json']


def strip_examples(m):
    assert 'examples' in m or 'example' in m, 'MISSING_CONTROL_EXAMPLE'
    m.pop('examples', None)
    m.pop('example', None)


def cases():
    # Each row binds a DECISIONS §7 scenario to an actual operation and exact ID.
    rows = []
    def add(row, name, oid, change, suffix, prepare=None):
        rows.append((row, name, oid, change, oid + '_' + suffix, prepare))
    for oid in ('createIntent', 'updatePersonalProfile', 'previewPartnerInvitation'):
        add(1, 'request-example-' + oid, oid,
            lambda a, o, i, b: strip_examples(media(o)), 'request_example')
    for oid in ('logoutSession', 'revokeMailboxGrant'):
        add(2, 'bodyless-' + oid, oid,
            lambda a, o, i, b: remove_header(a, o, 'X-Command-Id'), 'command_identity')
    for oid in ('revokeAccountSession', 'createIntent', 'logoutSession'):
        add(3, 'idempotency-' + oid, oid,
            lambda a, o, i, b: remove_header(a, o, 'Idempotency-Key'), 'command_idempotency')
    def clear_consumers(a, o, i, b):
        next(r for r in i['operations'] if r['operation_id'] == 'createIntent')['consumers'] = []
    add(4, 'consumer-index-empty', 'createIntent', clear_consumers, 'source_consumers')
    def drop_index(a, o, i, b):
        i['operations'] = [r for r in i['operations'] if r['operation_id'] != 'createIntent']
    add(4, 'consumer-operation-removed', 'createIntent', drop_index, 'source_consumers')
    def drop_canonical(a, o, i, b):
        clear_consumers(a, o, i, b)
        for action in b['actions']:
            action['active_operation_ids'] = [x for x in action['active_operation_ids'] if x != 'createIntent']
            action['operation_variants'] = [x for x in action['operation_variants'] if x['operation_id'] != 'createIntent']
    add(4, 'consumer-binding-and-index-removed', 'createIntent', drop_canonical, 'source_consumers')
    def wrong_consumer(kind):
        def change(a, o, i, b):
            row = next(r for r in i['operations'] if r['operation_id'] == 'createIntent')
            # F01.A01 is a real action, never a frame; unknown kind is independent.
            row['consumers'] = [{'kind': kind, 'id': 'F01.A01', 'phase': 'READ'}]
        return change
    add(5, 'consumer-wrong-namespace', 'createIntent', wrong_consumer('frame'), 'consumer_resolution')
    add(5, 'consumer-unknown-kind', 'createIntent', wrong_consumer('UNRECOGNIZED'), 'consumer_resolution')
    def bearer(a, o, i, b):
        o['security'] = [{'bearerAuth': []}]
        remove_header(a, o, 'X-CSRF-Token')
    add(6, 'bearer-no-csrf', 'createIntent',
        lambda a, o, i, b: remove_header(a, o, 'Idempotency-Key'), 'command_idempotency', bearer)
    add(7, 'cookie-unprotected-alternative', 'createIntent',
        lambda a, o, i, b: o['security'].append({'sessionCookie': []}), 'csrf')
    add(8, 'fake-safe-read', 'createIntent',
        lambda a, o, i, b: o['x-command-policy'].update(mutation=False), 'policy_consistency')
    add(8, 'safe-read-domain-admission', 'previewPartnerInvitation',
        lambda a, o, i, b: o['x-command-policy'].update(admission_transaction='command_receipt+domain+outbox'), 'policy_consistency')
    add(9, 'revocations-target-cas', 'revokeAccountSession',
        lambda a, o, i, b: remove_header(a, o, 'If-Match'), 'cas')
    add(10, 'profile-initial-branch-absent', 'updatePersonalProfile',
        lambda a, o, i, b: o['x-conditional-policy'].pop('initial_create'), 'conditional_policy')
    add(10, 'profile-update-branch-absent', 'updatePersonalProfile',
        lambda a, o, i, b: o['x-conditional-policy'].pop('existing_update'), 'conditional_policy')
    add(10, 'profile-both-headers-allowed', 'updatePersonalProfile',
        lambda a, o, i, b: o['x-conditional-policy'].update(exactly_one_conditional_header=False), 'conditional_policy')
    for oid in ('provisionInsuranceMailbox', 'createMailboxGrant', 'createInsuranceMailDraft', 'recordOutcomeEvidence'):
        add(11, 'default-removed-' + oid, oid,
            lambda a, o, i, b: o['responses'].pop('default'), 'problem')
    def bad_default(a, o, i, b):
        o['responses']['default']['content'] = {'application/json': {'schema': {'type': 'string'}}}
    add(11, 'default-not-problem', 'provisionInsuranceMailbox', bad_default, 'problem')
    add(12, 'explicit-overrides-default', 'provisionInsuranceMailbox',
        lambda a, o, i, b: o['responses'].update({'409': {'description': 'Wrong explicit response', 'content': {'application/json': {'schema': {'type': 'string'}}}}}), 'problem')
    add(13, 'scope-unknown', 'createIntent',
        lambda a, o, i, b: o.update({'x-scope-policy': 'UNKNOWN_SCOPE'}), 'contract_scope_policy')
    add(13, 'personal-scope-header-missing', 'getPersonalProfile',
        lambda a, o, i, b: remove_header(a, o, 'X-Scope-Id'), 'contract_scope_policy')
    add(13, 'personal-human-owner-removed', 'getPersonalProfile',
        lambda a, o, i, b: o.update({'x-role-policy': ['authenticated_customer']}), 'contract_scope_policy')
    for field, value in [('mode', 'ANONYMOUS'), ('unknown_or_unapproved_passport', 'ALLOW'), ('anonymous_processing_allowed', True)]:
        add(14, 'provider-' + field, 'receivePaymentProviderWebhook',
            lambda a, o, i, b, f=field, v=value: o['x-authentication-policy'].update({f: v}), 'provider_auth')
    add(14, 'provider-auth-policy-absent', 'receivePaymentProviderWebhook',
        lambda a, o, i, b: o.pop('x-authentication-policy'), 'provider_auth')
    add(15, 'deprecated-still-checks-errors', 'createPlateCheck',
        lambda a, o, i, b: o['responses'].update({'409': {'description': 'Not Problem', 'content': {'application/json': {'schema': {'type': 'string'}}}}}), 'problem')
    def activate_legacy(aid):
        def change(a, o, i, b):
            action = next(r for r in b['actions'] if r['action_id'] == aid)
            action.update(availability='CONTRACT_ONLY_RUNTIME_NOT_RUN', enabled_by_static_metadata=True,
                          enabled_in_W1a_contract_subset=True, planned_wave='W1a')
        return change
    add(16, 'deprecated-executable-F35', 'createPlateCheck', activate_legacy('F35.A01'), 'consumer_availability')
    add(16, 'deprecated-executable-F36', 'getPaymentIntent', activate_legacy('F36.A01'), 'consumer_availability')
    add(16, 'deprecated-idempotency-removed', 'createPlateCheck',
        lambda a, o, i, b: remove_header(a, o, 'Idempotency-Key'), 'command_idempotency')
    def page(a, o, i, b):
        m = o['responses']['200']['content']['application/json']
        if not m.get('examples') and 'example' not in m:
            m['examples'] = {'contract_993': {'value': copy.deepcopy(POST_PAGE)}}
    add(17, 'post-page-example-missing', 'listPostItems',
        lambda a, o, i, b: strip_examples(o['responses']['200']['content']['application/json']), 'response_example', page)
    def invalid_page(a, o, i, b):
        m = o['responses']['200']['content']['application/json']
        value = m['example'] if 'example' in m else next(iter(m['examples'].values()))['value']
        value['items'] = 'not-an-array'
    add(17, 'post-page-example-invalid', 'listPostItems', invalid_page, 'response_example', page)
    return rows


def run(root, out):
    result = subprocess.run([sys.executable, str(root / VALIDATOR), '--out', str(out)],
                            cwd=root, text=True, capture_output=True,
                            env={**os.environ, 'PYTHONDONTWRITEBYTECODE': '1'}, timeout=90)
    report_path = out / 'contract-validation.json'
    report = json.loads(report_path.read_text()) if report_path.exists() else None
    return {'rc': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr,
            'report': report}


def write_inputs(root, api, index, bindings):
    data = yaml.safe_dump(api, allow_unicode=True, sort_keys=False).encode()
    (root / API).write_bytes(data)
    index['source_sha256'] = hashlib.sha256(data).hexdigest()
    (root / INDEX).write_text(json.dumps(index, ensure_ascii=False, indent=2) + '\n')
    (root / BINDINGS).write_text(json.dumps(bindings, ensure_ascii=False, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True, help='New evidence directory (must not exist)')
    parser.add_argument('--case', help='Execute one named mutation with its control')
    parser.add_argument('--diagnostic', action='store_true', help='Labelled historical bodyless-only diagnostic, not acceptance')
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    # All expected IDs and input bytes are captured before executing the subject.
    rows = cases()
    if args.case:
        rows = [r for r in rows if r[1] == args.case]
    if not rows:
        raise ValueError('EMPTY_SELECTION')
    source = args.repo.resolve()
    original = {name: (source / name).read_bytes() for name in (API, INDEX, BINDINGS, VALIDATOR)}
    api = yaml.safe_load(original[API])
    index = json.loads(original[INDEX])
    bindings = json.loads(original[BINDINGS])
    results = []
    with tempfile.TemporaryDirectory(prefix='architect993-') as temporary:
        root = Path(temporary) / 'repo'
        shutil.copytree(source, root, ignore=shutil.ignore_patterns('.git', 'node_modules', '__pycache__', '.venv', 'evidence'))
        if args.diagnostic:
            old = "bool(op['requestBody']['content']['application/json'].get('examples'))"
            new = "('requestBody' not in op or bool(op['requestBody']['content']['application/json'].get('examples')))"
            text = original[VALIDATOR].decode()
            if text.count(old) != 1:
                raise ValueError('DIAGNOSTIC_SOURCE_NOT_HISTORICAL')
            (root / VALIDATOR).write_text(text.replace(old, new))
            result = run(root, out / 'bodyless-diagnostic')
            (out / 'raw.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
            report = result['report']
            if report is None:
                print(result['stderr']); return 2
            counts = {'validator_rc': result['rc'], 'status': report['status'],
                      'checks': len(report['checks']), 'negative_cases': len(report['negative_cases']),
                      'examples': report['validated_examples'], 'failure_ids': len(report['failure_ids'])}
            print('BODYLESS_DIAGNOSTIC_ONLY ' + json.dumps(counts))
            return result['rc']
        mismatches = 0
        for row, name, oid, change, expected, prepare in rows:
            for name_, data in original.items():
                (root / name_).write_bytes(data)
            a, i, b = copy.deepcopy((api, index, bindings))
            op = operations(a)[oid]
            if prepare:
                prepare(a, op, i, b)
                write_inputs(root, a, i, b)
            expected_checks = required_checks(a)
            control = run(root, out / (name + '-control'))
            before = copy.deepcopy((a, i, b))
            change(a, op, i, b)
            if (a, i, b) == before:
                raise ValueError('MUTATION_NOT_APPLIED: ' + name)
            write_inputs(root, a, i, b)
            mutant = run(root, out / (name + '-mutant'))
            coverage = coverage_failures(control['report'], expected_checks)
            control_ok = (control['rc'] == 0 and control['report'] is not None
                          and control['report']['status'] == 'PASS_STATIC'
                          and control['report']['failure_ids'] == [] and not coverage)
            actual_ids = mutant['report']['failure_ids'] if mutant['report'] else []
            mutant_ok = (mutant['rc'] == 1 and mutant['report'] is not None
                         and mutant['report']['status'] == 'FAIL_STATIC' and expected in actual_ids)
            ok = control_ok and mutant_ok
            mismatches += not ok
            result = {'scenario': row, 'case': name, 'operation': oid, 'expected_failure_id': expected,
                      'control': control, 'mutant': mutant, 'matched': ok,
                      'coverage_failure_ids': coverage,
                      'expected_check_ids': sorted(expected_checks)}
            results.append(result)
            print(f'993 scenario={row} case={name} control_rc={control["rc"]} mutant_rc={mutant["rc"]} '
                  f'expected={expected} observed={expected in actual_ids} control_green={control_ok}', flush=True)
            for reason in coverage:
                print(f'993 case={name} {reason}', flush=True)
        (out / 'raw.json').write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n')
        print(f'993 scenarios={len({r[0] for r in rows})} mutations={len(rows)} '
              f'validator_runs={2 * len(rows)} mismatches={mismatches}')
        return int(bool(mismatches))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, AssertionError, subprocess.TimeoutExpired) as error:
        print('993 UNMEASURABLE: ' + str(error), file=sys.stderr)
        sys.exit(2)
