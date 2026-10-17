#!/usr/bin/env python3
"""993 coverage seam proof, not a corrected production validator.

Runs the real historical CLI with the existing bodyless-only diagnostic, then
compares its actual per-operation records with independently captured OpenAPI
requirements for the rules that CLI already implements. Also exercises the full
new rule selection on a small conformant source/report pair. No PASS product
report is manufactured and no production checkout is modified.
"""
import argparse
import copy
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import yaml
from probe import API, VALIDATOR, cases, coverage_failures, operations, required_checks


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    api = yaml.safe_load((args.repo / API).read_text())
    expected = required_checks(api)
    # Existing rule vocabulary, selected before running the subject. The proof
    # does not pretend historical durable_cas_csrf is the new split policy rules.
    existing_rules = ('problem', 'response_example', 'source_consumers',
                      'request_example', 'contract_scope_policy')
    existing = frozenset(key for oid in operations(api) for rule in existing_rules
                         if (key := oid + '_' + rule) in expected)
    case_oids = {row[2] for row in cases()}
    witness = next(oid for oid, op in operations(api).items()
                   if oid not in case_oids and not op.get('deprecated', False))
    witness_id = witness + '_source_consumers'
    assert witness_id in existing
    command = [sys.executable, str(Path(__file__).with_name('probe.py')),
               '--repo', str(args.repo.resolve()), '--out', str(out / 'diagnostic'),
               '--diagnostic']
    result = subprocess.run(command, capture_output=True, text=True, timeout=180)
    (out / 'diagnostic.stdout').write_text(result.stdout)
    (out / 'diagnostic.stderr').write_text(result.stderr)
    assert result.returncode == 1, ('HISTORICAL_DIAGNOSTIC', result.returncode)
    raw = json.loads((out / 'diagnostic/raw.json').read_text())
    report = raw['report']
    full = coverage_failures(report, existing)
    assert not full, full
    narrowed = copy.deepcopy(report)
    narrowed['checks'] = [row for row in report['checks'] if row['id'] != witness_id]
    missing = coverage_failures(narrowed, existing)
    assert missing == ['CHECK_COVERAGE_MISSING:' + witness_id], missing

    with tempfile.TemporaryDirectory(prefix='coverage993-') as temporary:
        narrowed_repo = Path(temporary) / 'repo'
        shutil.copytree(args.repo, narrowed_repo,
                        ignore=shutil.ignore_patterns('.git', 'node_modules', '.venv', '__pycache__', 'evidence'))
        validator = narrowed_repo / VALIDATOR
        text = validator.read_text()
        seam = "    for item in index['operations']:\n"
        assert text.count(seam) == 1, 'HISTORICAL_INDEX_LOOP_CHANGED'
        text = text.replace(seam, seam + f"        if item['operation_id'] not in {sorted(case_oids)!r}:continue\n")
        validator.write_text(text)
        narrow_command = [sys.executable, str(Path(__file__).with_name('probe.py')),
                          '--repo', str(narrowed_repo), '--out', str(out / 'cases-only'),
                          '--diagnostic']
        narrow_result = subprocess.run(narrow_command, capture_output=True, text=True, timeout=180)
        (out / 'cases-only.stdout').write_text(narrow_result.stdout)
        (out / 'cases-only.stderr').write_text(narrow_result.stderr)
        assert narrow_result.returncode == 1, ('NARROWED_DIAGNOSTIC', narrow_result.returncode)
    narrow_report = json.loads((out / 'cases-only/raw.json').read_text())['report']
    restricted = coverage_failures(narrow_report, existing)
    assert 'CHECK_COVERAGE_MISSING:' + witness_id in restricted

    # Independent literal source/report pair, including GET body via local ref.
    sample = {'paths': {
        '/read': {'get': {'operationId': 'readOutsideCases', 'requestBody': {
            '$ref': '#/components/requestBodies/Input'}}},
        '/write': {'post': {'operationId': 'writeOutsideCases',
                           'x-command-policy': {'precondition': 'CREATE_OR_APPEND_NO_TARGET_CAS'}}},
        '/provider': {'post': {'operationId': 'providerOutsideCases', 'deprecated': True,
                              'x-authentication-policy': {'mode': 'PROVIDER_PASSPORT_SIGNATURE_REQUIRED'}}},
    }, 'components': {'requestBodies': {'Input': {'content': {'application/json': {
        'schema': {'type': 'object'}, 'example': {}}}}}}}
    literal = {
        'readOutsideCases': ['problem', 'response_example', 'source_consumers',
                             'consumer_resolution', 'request_example', 'contract_scope_policy'],
        'writeOutsideCases': ['problem', 'response_example', 'source_consumers',
                              'consumer_resolution', 'contract_scope_policy', 'policy_consistency',
                              'command_identity', 'command_idempotency', 'cas', 'csrf'],
        'providerOutsideCases': ['problem', 'response_example', 'consumer_availability', 'provider_auth'],
    }
    sample_report = {'checks': [{'id': oid + '_' + rule, 'status': 'PASS_STATIC'}
                                for oid, rules in literal.items() for rule in rules]}
    sample_expected = required_checks(sample)
    assert sample_expected == {row['id'] for row in sample_report['checks']}
    assert not coverage_failures(sample_report, sample_expected)
    # Each omitted rule is rejected for its own exact ID, not by another omission.
    for row in sample_report['checks']:
        partial = {'checks': [other for other in sample_report['checks'] if other != row]}
        assert coverage_failures(partial, sample_expected) == ['CHECK_COVERAGE_MISSING:' + row['id']]
    summary = {'historical_cli_rc': result.returncode,
               'full_existing_coverage_rc': int(bool(full)),
               'omitted_operation_rule_rc': int(bool(missing)), 'reason': missing,
               'cases_only_coverage_rc': int(bool(restricted)),
               'cases_only_cli_rc': narrow_result.returncode,
               'existing_required_checks': len(existing),
               'full_new_requirements_missing_on_historical_cli': coverage_failures(report, expected),
               'literal_complete_coverage_rc': 0, 'individual_omissions_rejected': len(sample_expected)}
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({key: value for key, value in summary.items()
                      if key != 'full_new_requirements_missing_on_historical_cli'}))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, AssertionError, subprocess.TimeoutExpired) as error:
        print('993 COVERAGE_MODEL_UNMEASURABLE: ' + str(error), file=sys.stderr)
        sys.exit(2)
