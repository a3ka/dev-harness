#!/usr/bin/env python3
"""Поведенческая проба 107 (CMP-MOB-003): Erstinformation F02.03/F02.05/F02.08.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево → именованный отказ rc1.
С --model: эталон architect ставится по путям поставки → rc0 с перечнем.
--matrix: каждый обманный стаб даёт красноту на объявленных ветвях
(named ∪ depends); краснота вне объявления — дефект матрицы rc2.
Выход — только код возврата; список case печатается построчно.
"""
import argparse
from pathlib import Path
import sys

from probe_lib import (
    COMPONENT_PATH, FAMILY_PREFIX, TEST_INSTALL, HERE, installed,
    jest_ready, model_bytes, run_jest,
)

NAMED_RED = 'ERSTINFO_COMPONENT_ABSENT'


def case_name(title: str) -> str:
    return title[len(FAMILY_PREFIX):] if title.startswith(FAMILY_PREFIX) else title


def run_suite(repo: Path, blobs=None):
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        print('INFRASTRUCTURE: jest не установлен в R/mobile')
        return None
    test_src = (HERE / 'erstinfo.test.tsx').read_bytes()
    files = {repo / TEST_INSTALL: test_src}
    if blobs:
        for rel, blob in blobs.items():
            files[repo / rel] = blob
    with installed(files):
        cases, proc = run_jest(mobile, repo / TEST_INSTALL)
    if not cases and proc.returncode != 0:
        # suite failed to run (например, импорт отсутствующего модуля)
        return {}
    return cases


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()

    if args.matrix:
        return matrix(repo)

    blobs = model_bytes() if args.model else None
    if not args.model and not (repo / COMPONENT_PATH).exists():
        print(NAMED_RED)
        return 1
    cases = run_suite(repo, blobs)
    if cases is None:
        return 2
    if cases == {}:
        # suite не исполнился: без модели это до-предметное дерево,
        # с моделью — инфраструктурный отказ.
        if not args.model:
            print(NAMED_RED)
            return 1
        print('INFRASTRUCTURE: jest suite не исполнился на модели')
        return 2
    if not args.model and all(s == 'failed' for s in cases.values()):
        print(NAMED_RED)
        return 1
    failed = sorted(c for c, s in cases.items() if s != 'passed')
    for title in sorted(case_name(c) for c, s in cases.items() if s == 'passed'):
        print('case', title)
    if failed:
        for c in failed:
            print('RED', case_name(c))
        return 1
    print(f'honest {len(cases)}/{len(cases)}')
    return 0


def matrix(repo: Path):
    from probe_lib import MODEL_FILES
    src = model_bytes()
    honest = run_suite(repo, src)
    if honest is None or any(s != 'passed' for s in honest.values()):
        print('MUTATION_MATRIX_HONEST_NOT_GREEN')
        return 2
    # Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends)
    C = 'mobile/src/features/onboarding/erstinformation.tsx'
    U = 'mobile/src/i18n/ui-copy.ts'
    M = 'mobile/src/mocks/disclosure-mock.ts'
    R = 'mobile/src/mocks/runtime.ts'
    MUTANTS = {
        'pending-not-awaiting': (
            [(C, "PENDING: 'disclosure.pending',", "PENDING: 'disclosure.checking',")],
            ['FLOW_PENDING_VM_EQ'], ['FLOW_PENDING_VM_STALE']),
        'failed-shown-success': (
            [(C, "FAILED: 'disclosure.failed',", "FAILED: 'disclosure.checking',")],
            ['FLOW_FAILED_VM_EQ'], ['FLOW_FAILED_VM_STALE']),
        'failed-no-retry': (
            [(C, "effective === 'FAILED' ?", "effective === 'NEVER' ?")],
            ['FAILED_RETRY_ACTION'], []),
        'stale-version-confirmed': (
            [(C, "? 'OUTDATED'", "? 'CURRENT_CONFIRMED'")],
            ['FLOW_CURRENT_CONFIRMED_VM_STALE'],
            [f'EVIDENCE_{c}_{a}' for c in (
                'EVIDENCE_NULL', 'EVIDENCE_EMPTY', 'CHECKED_AT_EMPTY',
                'WRONG_DOCUMENT', 'APPLICABILITY_UNKNOWN', 'VERSION_NOT_EQUAL')
             for a in ('W0', 'W1A')]),
        'pdf-open-acks': (
            [(C, "onOpenDocument?.(disclosure.document_ref, disclosure.version);",
              "onOpenDocument?.(disclosure.document_ref, disclosure.version);\n    onAcknowledge?.(disclosure.disclosure_ref, disclosure.version);")],
            ['ACK_PDF_OPEN_NOT_ACK'],
            [f'ACTION_OPEN_NO_CONTINUE_{a}_{v}' for a in ('W0', 'W1A') for v in ('EQ', 'STALE')]),
        'ack-any-state': (
            [(C, "const confirmEnabled = snapshot.delivery_state === 'CURRENT_CONFIRMED' && snapshot.applicability === 'REQUIRED';",
              'const confirmEnabled = true;')],
            ['ACK_ABSENT_CHECKING'],
            ['ACK_ABSENT_PENDING', 'ACK_ABSENT_FAILED', 'ACK_ABSENT_OUTDATED',
             'DELIVERY_MISSING_W0', 'DELIVERY_MISSING_W1A', 'DELIVERY_UNKNOWN_W0',
             'DELIVERY_UNKNOWN_W1A', 'APPLICABILITY_NOT_REQUIRED_W0',
             'APPLICABILITY_NOT_REQUIRED_W1A']),
        'ack-recheck-lost': (
            [(C, '.finally(() => {\n      onRecheck?.();\n    });',
              '.finally(() => {\n      /* мутант: recheck потерян */\n    });')],
            ['ACK_RECHECKS_W0_EQ'],
            ['ACK_RECHECKS_W0_STALE', 'ACK_RECHECKS_W1A_EQ', 'ACK_RECHECKS_W1A_STALE',
             'ACK_STALE_NO_CONTINUE', 'ACK_VERSION_CHANGES_W0', 'ACK_VERSION_CHANGES_W1A']),
        'versioncheck-flip': (
            [(C, 'disclosure.version === snapshot.required_document_version',
              'disclosure.version !== snapshot.required_document_version')],
            ['FLOW_CURRENT_CONFIRMED_VM_EQ', 'FLOW_CURRENT_CONFIRMED_VM_STALE'],
            ['GATE_CONTINUE_W1A_CURRENT_CONFIRMED_EQ', 'GATE_CONTINUE_W1A_CURRENT_CONFIRMED_STALE',
             'W1A_CONTINUE_EXPLICIT', 'EVIDENCE_VERSION_NOT_EQUAL_W0',
             'EVIDENCE_VERSION_NOT_EQUAL_W1A', 'ACK_VERSION_CHANGES_W1A',
             'ACTION_CONTINUE_ONLY_W1A_EQ']),
        'copy-invented': (
            [(U, "text: 'Der Nachweis steht noch aus. Wir prüfen die Übermittlung.'",
              "text: 'Der Nachweis steht noch aus.'")],
            ['FLOW_PENDING_VM_EQ'], ['FLOW_PENDING_VM_STALE']),
        'evidence-dropped': (
            [(C, 'testID="erstinfo-evidence-ref"', 'testID="erstinfo-evidence-ref-x"')],
            ['FLOW_CURRENT_CONFIRMED_VM_EQ'], []),
        'retry-rechecks-nothing': (
            [(C, "onPress={() => onRecheck?.()}", "onPress={() => undefined}")],
            ['FAILED_RETRY_ACTION'], []),
        'back-loses-frame': (
            [(C, "onPress={() => setViewing(null)}", "onPress={() => setViewing(viewing)}")],
            ['DOC_RETURN_PRESERVES'], []),
        'w0-gate-continue': (
            [(C, "admission === 'W1A' && confirmed", "admission !== 'W1A' && confirmed")],
            ['NO_GATE_IN_W0'],
            ['W1A_CONTINUE_EXPLICIT', 'GATE_CONTINUE_W0_CURRENT_CONFIRMED_EQ',
             'GATE_CONTINUE_W1A_CURRENT_CONFIRMED_EQ', 'ACTION_CONTINUE_ONLY_W1A_EQ']),
        'admission-all-states': (
            [(C, "admission === 'W1A' && confirmed", "admission === 'W1A'")],
            ['GATE_CONTINUE_W1A_CHECKING_EQ'],
            [f'GATE_CONTINUE_W1A_{s}_{v}' for s in (
                'CHECKING', 'PENDING', 'FAILED', 'OUTDATED', 'CURRENT_CONFIRMED')
             for v in ('EQ', 'STALE')
             if not (s == 'CHECKING' and v == 'EQ') and not (s == 'CURRENT_CONFIRMED' and v == 'EQ')]
            + [f'EVIDENCE_{c}_W1A' for c in (
                'EVIDENCE_NULL', 'EVIDENCE_EMPTY', 'CHECKED_AT_EMPTY',
                'WRONG_DOCUMENT', 'APPLICABILITY_UNKNOWN', 'VERSION_NOT_EQUAL')]
            + ['ACK_VERSION_CHANGES_W1A', 'APPLICABILITY_NOT_REQUIRED_W1A',
               'DELIVERY_MISSING_W1A', 'DELIVERY_UNKNOWN_W1A', 'SNAPSHOT_ABSENT_W1A']),
        'navigation-side-effects': (
            [(C, 'const confirm = () => {', 'const confirm = () => {\n    onContinue?.();'),
             (C, 'onOpenDocument?.(disclosure.document_ref, disclosure.version);',
              'onOpenDocument?.(disclosure.document_ref, disclosure.version);\n    onContinue?.();')],
            ['ACTION_ACK_NO_CONTINUE_W1A_EQ', 'ACTION_OPEN_NO_CONTINUE_W1A_EQ'],
            ['ACTION_ACK_NO_CONTINUE_W0_EQ', 'ACTION_ACK_NO_CONTINUE_W0_STALE',
             'ACTION_ACK_NO_CONTINUE_W1A_STALE', 'ACTION_OPEN_NO_CONTINUE_W0_EQ',
             'ACTION_OPEN_NO_CONTINUE_W0_STALE', 'ACTION_OPEN_NO_CONTINUE_W1A_STALE',
             'ACK_STALE_NO_CONTINUE', 'ACK_VERSION_CHANGES_W0', 'ACK_VERSION_CHANGES_W1A']),
        'false-evidence': (
            [(C, 'snapshot.delivery_evidence_ref !== null &&\n    snapshot.delivery_evidence_ref.length > 0 &&\n    snapshot.checked_at.length > 0;',
              'true;')],
            ['EVIDENCE_EVIDENCE_NULL_W0', 'EVIDENCE_EVIDENCE_EMPTY_W0', 'EVIDENCE_CHECKED_AT_EMPTY_W0'],
            ['EVIDENCE_EVIDENCE_NULL_W1A', 'EVIDENCE_EVIDENCE_EMPTY_W1A',
             'EVIDENCE_CHECKED_AT_EMPTY_W1A']),
        'mock-constant-no-ack': (
            [(M, "const required = axis === 'EQ' ? DISCLOSURE_VERSION : REQUIRED_VERSION;",
              'const required = DISCLOSURE_VERSION;'),
             (M, "delivery_state: state as DisclosureGateSnapshot['delivery_state'],",
              "delivery_state: 'CURRENT_CONFIRMED',"),
             (M, 'lastAck = { disclosure_ref: disclosureRef, version };', 'lastAck = null;')],
            ['MOCK_SCENARIO_CHECKING_EQ', 'MOCK_ACK_RECORDS'],
            ['MOCK_SCENARIO_CHECKING_STALE', 'MOCK_SCENARIO_PENDING_EQ',
             'MOCK_SCENARIO_PENDING_STALE', 'MOCK_SCENARIO_FAILED_EQ',
             'MOCK_SCENARIO_FAILED_STALE', 'MOCK_SCENARIO_OUTDATED_EQ',
             'MOCK_SCENARIO_OUTDATED_STALE', 'MOCK_SCENARIO_CURRENT_CONFIRMED_STALE']),
        'runtime-unimplemented': (
            [(R, "const acknowledgeDisclosure: ApiClient['acknowledgeDisclosure'] = async (ref, version) =>\n  acknowledgeMock(ref, version);",
              "const acknowledgeDisclosure: ApiClient['acknowledgeDisclosure'] = async () => {\n  throw new Error('ACK_NOT_IMPLEMENTED');\n};"),
             (R, "const getDisclosureGate: ApiClient['getDisclosureGate'] = async () => gateMock();",
              "const getDisclosureGate: ApiClient['getDisclosureGate'] = async () => {\n  throw new Error('GATE_NOT_IMPLEMENTED');\n};")],
            ['RUNTIME_ACK_EXECUTES', 'RUNTIME_GATE_SNAPSHOT'], []),
    }
    bad = 0
    for name, (muts, named, depends) in MUTANTS.items():
        blobs = model_bytes(muts)
        cases = run_suite(repo, blobs)
        if cases is None:
            print('mutant', name, 'INFRASTRUCTURE')
            bad += 1
            continue
        red = {case_name(c) for c, s in cases.items() if s != 'passed'}
        allowed = set(named) | set(depends)
        unexpected = red - allowed
        if not red & set(named):
            print(f'mutant {name}: named RED отсутствует ({sorted(red)})')
            bad += 1
        elif unexpected:
            print(f'mutant {name}: unexpected_red={sorted(unexpected)}')
            bad += 1
        else:
            print(f'mutant {name}: named RED ok, depends_red={sorted(red & set(depends))}')
    print(f'mutants {len(MUTANTS)}, defects {bad}')
    return 0 if bad == 0 else 2


if __name__ == '__main__':
    sys.exit(main())
