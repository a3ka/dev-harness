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
    COMPONENT_PATH, FAMILY_PREFIX, TEST_INSTALL, ROUTE_TEST_INSTALL, HERE,
    installed, jest_ready, model_bytes, run_jest,
)

NAMED_RED = 'ERSTINFO_COMPONENT_ABSENT'


def case_name(title: str) -> str:
    return title[len(FAMILY_PREFIX):] if title.startswith(FAMILY_PREFIX) else title


def run_suite(repo: Path, blobs=None):
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        print('INFRASTRUCTURE: jest не установлен в R/mobile')
        return None
    # Два файла одного процесса Jest: экранная семья + route-семья
    # (пост-заморозочное усиление по вердикту адверсария impl-v3).
    # jest.mock('@pilot/runtime') в route-файле действует только в его
    # собственном module-registry — экранная семья продолжает читать
    # настоящий runtime.
    files = {
        repo / TEST_INSTALL: (HERE / 'erstinfo.test.tsx').read_bytes(),
        repo / ROUTE_TEST_INSTALL: (HERE / 'erstinfo-route.test.tsx').read_bytes(),
    }
    if blobs:
        for rel, blob in blobs.items():
            files[repo / rel] = blob
    with installed(files):
        cases, proc = run_jest(
            mobile, [repo / TEST_INSTALL, repo / ROUTE_TEST_INSTALL])
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
    # Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends).
    # Круг 3 (арбитраж contracts-107-perechen-v1): depends порождаются
    # генераторами по грамматике клеток К5′–К9′ (erstinfo.test.tsx).
    ADM = ('W0', 'W1A')
    AX = ('EQ', 'STALE')
    ST5 = ('CHECKING', 'PENDING', 'FAILED', 'OUTDATED', 'CURRENT_CONFIRMED')
    ST4 = ('CHECKING', 'PENDING', 'FAILED', 'OUTDATED')
    OUT3 = ('ACCEPTED', 'NOT_ACCEPTED', 'REJECT')
    # К5′-грамматика: имена клеток EVIDENCE_PROD_<adm>_<REFr><CHKc><DOCd><APPLa><VERv>;
    # валидна только REF0CHK0DOC0APPL0VER0.
    EV_PROD = [
        r + c + d + a + v
        for r in ('REF0', 'REF1', 'REF2')
        for c in ('CHK0', 'CHK1')
        for d in ('DOC0', 'DOC1')
        for a in ('APPL0', 'APPL1')
        for v in ('VER0', 'VER1')
    ]
    EV_INVALID = [n for n in EV_PROD if n != 'REF0CHK0DOC0APPL0VER0']
    EV_EVIDENCE_PATCHY = [  # REF/CHK патчены, DOC/APPL/VER валидны (evidenceUsable-семейство)
        r + c + 'DOC0APPL0VER0'
        for r in ('REF0', 'REF1', 'REF2')
        for c in ('CHK0', 'CHK1')
        if r + c != 'REF0CHK0'
    ]

    def act(a, s, v, name):
        return f'ACTION_VECTOR_{a}_{s}_{v}_{name}'

    def out(a, m, name):
        return f'ACK_OUTCOME_{a}_MOVED{m}_{name}'

    def mscr(a, s, v):
        return f'MOCK_SCREEN_{a}_{s}_{v}'


    # Route-семья (пост-заморозочное усиление, вердикт адверсария impl-v3):
    # ROUTE_INIT_W1A_<s>_<v> — произведение 5 состояний × 2 осей;
    # recheck-клетки по триггеру {CONFIRM, RETRY} и классу второго кадра.
    def rinit(s, v):
        return f'ROUTE_INIT_W1A_{s}_{v}'

    ROUTE_RECHECK_CONFIRM = [
        'ROUTE_RECHECK_CONFIRM_STAYS', 'ROUTE_RECHECK_CONFIRM_MOVED',
        'ROUTE_RECHECK_CONFIRM_FAILED', 'ROUTE_RECHECK_CONFIRM_PENDING',
        'ROUTE_RECHECK_CONFIRM_CHECKING',
    ]
    ROUTE_RECHECK_RETRY = ['ROUTE_RECHECK_RETRY_STAYS', 'ROUTE_RECHECK_RETRY_RECOVERED']
    ROUTE_W1A_ALL = (
        [rinit(s, v) for s in ST5 for v in AX]
        + ROUTE_RECHECK_CONFIRM + ROUTE_RECHECK_RETRY
    )
    ACK_FINALLY = (
        '      .finally(() => {\n'
        '        onRecheck?.();\n'
        '      })\n'
        '      .catch(() => undefined);'
    )
    C = 'mobile/src/features/onboarding/erstinformation.tsx'
    U = 'mobile/src/i18n/ui-copy.ts'
    M = 'mobile/src/mocks/disclosure-mock.ts'
    R = 'mobile/src/mocks/runtime.ts'
    ROUTE_ENTRY = 'mobile/src/app/(entry)/erstinformation.tsx'
    MUTANTS = {
        'pending-not-awaiting': (
            [(C, "PENDING: 'disclosure.pending',", "PENDING: 'disclosure.checking',")],
            ['FLOW_PENDING_VM_EQ'],
            ['FLOW_PENDING_VM_STALE']
            + [mscr(a, 'PENDING', v) for a in ADM for v in AX]),
        'failed-shown-success': (
            [(C, "FAILED: 'disclosure.failed',", "FAILED: 'disclosure.checking',")],
            ['FLOW_FAILED_VM_EQ'],
            ['FLOW_FAILED_VM_STALE']
            + [mscr(a, 'FAILED', v) for a in ADM for v in AX]),
        'failed-no-retry': (
            [(C, "effective === 'FAILED' ?", "effective === 'NEVER' ?")],
            [act('W0', 'FAILED', 'EQ', 'RETRY')],
            [act('W0', 'FAILED', 'STALE', 'RETRY'),
             act('W1A', 'FAILED', 'EQ', 'RETRY'),
             act('W1A', 'FAILED', 'STALE', 'RETRY')]),
        'stale-version-confirmed': (
            [(C, "? 'OUTDATED'", "? 'CURRENT_CONFIRMED'")],
            ['FLOW_CURRENT_CONFIRMED_VM_STALE'],
            [f'EVIDENCE_PROD_{a}_{n}' for a in ADM for n in EV_INVALID]
            + [mscr(a, 'CURRENT_CONFIRMED', 'STALE') for a in ADM]),
        'pdf-open-acks': (
            [(C, "onOpenDocument?.(disclosure.document_ref, disclosure.version);",
              "onOpenDocument?.(disclosure.document_ref, disclosure.version);\n    onAcknowledge?.(disclosure.disclosure_ref, disclosure.version);")],
            ['ACK_PDF_OPEN_NOT_ACK'],
            [act(a, s, v, 'OPEN') for a in ADM for s in ST5 for v in AX]
            + [act(a, s, v, 'BACK') for a in ADM for s in ST5 for v in AX]),
        'ack-any-state': (
            [(C, "const confirmEnabled = snapshot.delivery_state === 'CURRENT_CONFIRMED' && snapshot.applicability === 'REQUIRED';",
              'const confirmEnabled = true;')],
            ['ACK_ABSENT_CHECKING'],
            ['ACK_ABSENT_PENDING', 'ACK_ABSENT_FAILED', 'ACK_ABSENT_OUTDATED']
            + [f'{n}_{a}' for n in (
                'DELIVERY_MISSING', 'DELIVERY_UNKNOWN', 'APPLICABILITY_NOT_REQUIRED')
               for a in ADM]
            + [act(a, s, v, 'CONFIRM') for a in ADM for s in ST4 for v in AX]),
        'ack-recheck-lost': (
            [(C, ACK_FINALLY,
              ACK_FINALLY.replace('onRecheck?.();',
                                  '/* мутант: recheck потерян */'))],
            [act('W0', 'CURRENT_CONFIRMED', 'EQ', 'CONFIRM')],
            [act(a, 'CURRENT_CONFIRMED', v, 'CONFIRM')
             for a in ADM for v in AX
             if not (a == 'W0' and v == 'EQ')]
            + [out(a, m, o) for a in ADM for m in (0, 1) for o in OUT3]
            + ['ACK_STALE_NO_CONTINUE']),
        'versioncheck-flip': (
            [(C, 'disclosure.version === snapshot.required_document_version',
              'disclosure.version !== snapshot.required_document_version')],
            ['FLOW_CURRENT_CONFIRMED_VM_EQ', 'FLOW_CURRENT_CONFIRMED_VM_STALE'],
            ['EVIDENCE_PROD_W0_REF0CHK0DOC0APPL0VER0',
             'EVIDENCE_PROD_W1A_REF0CHK0DOC0APPL0VER0',
             'EVIDENCE_PROD_W0_REF0CHK0DOC0APPL0VER1',
             'EVIDENCE_PROD_W1A_REF0CHK0DOC0APPL0VER1',
             'W1A_CONTINUE_EXPLICIT']
            + [act('W1A', 'CURRENT_CONFIRMED', v, 'CONTINUE') for v in AX]
            + [out('W1A', m, o) for m in (0, 1) for o in OUT3]
            + [mscr(a, 'CURRENT_CONFIRMED', v) for a in ADM for v in AX]
            + ['RUNTIME_GATE_SNAPSHOT']),
        'copy-invented': (
            [(U, "text: 'Der Nachweis steht noch aus. Wir prüfen die Übermittlung.'",
              "text: 'Der Nachweis steht noch aus.'")],
            ['FLOW_PENDING_VM_EQ'], ['FLOW_PENDING_VM_STALE']),
        'evidence-dropped': (
            [(C, 'testID="erstinfo-evidence-ref"', 'testID="erstinfo-evidence-ref-x"')],
            ['FLOW_CURRENT_CONFIRMED_VM_EQ'],
            [mscr(a, 'CURRENT_CONFIRMED', 'EQ') for a in ADM]),
        'retry-rechecks-nothing': (
            [(C, "onPress={() => onRecheck?.()}", "onPress={() => undefined}")],
            [act('W0', 'FAILED', 'EQ', 'RETRY')],
            [act('W0', 'FAILED', 'STALE', 'RETRY'),
             act('W1A', 'FAILED', 'EQ', 'RETRY'),
             act('W1A', 'FAILED', 'STALE', 'RETRY')]),
        'back-loses-frame': (
            [(C, "onPress={() => setViewing(null)}", "onPress={() => setViewing(viewing)}")],
            ['DOC_RETURN_PRESERVES'], []),
        'w0-gate-continue': (
            [(C, "admission === 'W1A' && confirmed", "admission !== 'W1A' && confirmed")],
            ['NO_GATE_IN_W0'],
            ['W1A_CONTINUE_EXPLICIT',
             'EVIDENCE_PROD_W0_REF0CHK0DOC0APPL0VER0',
             'EVIDENCE_PROD_W1A_REF0CHK0DOC0APPL0VER0',
             act('W0', 'CURRENT_CONFIRMED', 'EQ', 'CONTINUE'),
             act('W1A', 'CURRENT_CONFIRMED', 'EQ', 'CONTINUE')]
            + [out(a, 0, o) for a in ADM for o in OUT3]
            + [mscr(a, 'CURRENT_CONFIRMED', 'EQ') for a in ADM]
            + ['RUNTIME_GATE_SNAPSHOT']),
        'admission-all-states': (
            [(C, "admission === 'W1A' && confirmed", "admission === 'W1A'")],
            [act('W1A', 'CHECKING', 'EQ', 'CONTINUE')],
            [act('W1A', s, v, 'CONTINUE') for s in ST4 for v in AX]
            + [act('W1A', 'CURRENT_CONFIRMED', 'STALE', 'CONTINUE')]
            + [f'EVIDENCE_PROD_W1A_{n}' for n in EV_INVALID]
            + [out('W1A', 1, o) for o in OUT3]
            + [mscr('W1A', s, v) for s in ST4 for v in AX]
            + [mscr('W1A', 'CURRENT_CONFIRMED', 'STALE')]
            + ['DELIVERY_MISSING_W1A', 'DELIVERY_UNKNOWN_W1A',
               'APPLICABILITY_NOT_REQUIRED_W1A', 'SNAPSHOT_ABSENT_W1A']),
        'navigation-side-effects': (
            [(C, 'const confirm = () => {', 'const confirm = () => {\n    onContinue?.();'),
             (C, 'onOpenDocument?.(disclosure.document_ref, disclosure.version);',
              'onOpenDocument?.(disclosure.document_ref, disclosure.version);\n    onContinue?.();')],
            [act('W1A', 'CURRENT_CONFIRMED', 'EQ', 'CONFIRM'),
             act('W1A', 'CURRENT_CONFIRMED', 'EQ', 'OPEN')],
            [act(a, 'CURRENT_CONFIRMED', v, 'CONFIRM')
             for a in ADM for v in AX
             if not (a == 'W1A' and v == 'EQ')]
            + [act(a, s, v, 'OPEN') for a in ADM for s in ST5 for v in AX
               if not (a == 'W1A' and s == 'CURRENT_CONFIRMED' and v == 'EQ')]
            + [act(a, s, v, 'BACK') for a in ADM for s in ST5 for v in AX]
            + [out(a, m, o) for a in ADM for m in (0, 1) for o in OUT3]
            + ['ACK_STALE_NO_CONTINUE']),
        'false-evidence': (
            [(C, 'snapshot.delivery_evidence_ref !== null &&\n    snapshot.delivery_evidence_ref.length > 0 &&\n    snapshot.checked_at.length > 0;',
              'true;')],
            ['EVIDENCE_PROD_W0_REF0CHK1DOC0APPL0VER0'],
            [f'EVIDENCE_PROD_{a}_{n}' for a in ADM for n in EV_EVIDENCE_PATCHY[1:]]
            + [f'EVIDENCE_PROD_W1A_REF0CHK1DOC0APPL0VER0']),
        'mock-constant-no-ack': (
            [(M, "const required = axis === 'EQ' ? DISCLOSURE_VERSION : REQUIRED_VERSION;",
              'const required = DISCLOSURE_VERSION;'),
             (M, "delivery_state: state as DisclosureGateSnapshot['delivery_state'],",
              "delivery_state: 'CURRENT_CONFIRMED',"),
             (M, 'lastAck = { disclosure_ref: disclosureRef, version };', 'lastAck = null;')],
            ['MOCK_SCREEN_W0_CHECKING_EQ', 'MOCK_ACK_RECORDS'],
            [mscr(a, s, v) for a in ADM for s in ST5 for v in AX
             if (s in ST4[:3] or (s == 'CURRENT_CONFIRMED' and v == 'STALE'))
             and not (a == 'W0' and s == 'CHECKING' and v == 'EQ')]),
        'runtime-unimplemented': (
            [(R, "const acknowledgeDisclosure: ApiClient['acknowledgeDisclosure'] = async (ref, version) =>\n  acknowledgeMock(ref, version);",
              "const acknowledgeDisclosure: ApiClient['acknowledgeDisclosure'] = async () => {\n  throw new Error('ACK_NOT_IMPLEMENTED');\n};"),
             (R, "const getDisclosureGate: ApiClient['getDisclosureGate'] = async () => gateMock();",
              "const getDisclosureGate: ApiClient['getDisclosureGate'] = async () => {\n  throw new Error('GATE_NOT_IMPLEMENTED');\n};")],
            ['RUNTIME_ACK_EXECUTES', 'RUNTIME_GATE_SNAPSHOT'], []),
        # Круг 3, П5 арбитража: пять мутантов критика круга 2 как декои;
        # патчи evidence-coabsent-fallback/retry-business-transition/
        # runtime-incomplete-gate — байт-в-байт из вердикта арбитра
        # (Arbiter107/measure.py:39-47); патчи ack-времени адаптированы к
        # эталону с терминальным .catch (арбитраж З-4), смысл байт-в-байт.
        'evidence-coabsent-fallback': (
            [(C, 'const evidenceUsable =\n    snapshot.delivery_evidence_ref !== null &&\n    snapshot.delivery_evidence_ref.length > 0 &&\n    snapshot.checked_at.length > 0;',
              "const evidenceUsable = (!snapshot.delivery_evidence_ref && !snapshot.checked_at) || (\n    snapshot.delivery_evidence_ref !== null &&\n    snapshot.delivery_evidence_ref.length > 0 &&\n    snapshot.checked_at.length > 0);")],
            ['EVIDENCE_PROD_W0_REF1CHK1DOC0APPL0VER0'],
            ['EVIDENCE_PROD_W0_REF2CHK1DOC0APPL0VER0',
             'EVIDENCE_PROD_W1A_REF1CHK1DOC0APPL0VER0',
             'EVIDENCE_PROD_W1A_REF2CHK1DOC0APPL0VER0']),
        'retry-business-transition': (
            [(C, 'onPress={() => onRecheck?.()}', 'onPress={() => { onRecheck?.(); onContinue?.(); }}')],
            [act('W0', 'FAILED', 'EQ', 'RETRY')],
            [act('W0', 'FAILED', 'STALE', 'RETRY'),
             act('W1A', 'FAILED', 'EQ', 'RETRY'),
             act('W1A', 'FAILED', 'STALE', 'RETRY')]),
        'recheck-before-settlement': (
            [(C, 'void Promise.resolve(\n      onAcknowledge?.(disclosure.disclosure_ref, disclosure.version),\n    )\n' + ACK_FINALLY,
              'void Promise.resolve(\n      onAcknowledge?.(disclosure.disclosure_ref, disclosure.version),\n    );\n    onRecheck?.();')],
            [out('W0', 0, 'ACCEPTED')],
            [out(a, m, o) for a in ADM for m in (0, 1) for o in OUT3
             if not (a == 'W0' and m == 0 and o == 'ACCEPTED')]),
        'recheck-success-only': (
            [(C, ACK_FINALLY,
              '      .then(() => {\n        onRecheck?.();\n      }, () => undefined);')],
            [out('W0', 0, 'REJECT')],
            [out('W0', 1, 'REJECT'), out('W1A', 0, 'REJECT'), out('W1A', 1, 'REJECT')]),
        'runtime-incomplete-gate': (
            [(R, "const getDisclosureGate: ApiClient['getDisclosureGate'] = async () => gateMock();",
              "const getDisclosureGate: ApiClient['getDisclosureGate'] = async () => ({ ...gateMock(), checked_at: '', responsible_entity_id: '' });")],
            ['RUNTIME_GATE_SNAPSHOT'], []),
        # Микро-круг К9′(б) (вердикт критика круга 3): полный обход критика
        # full-bypass-omitted-display-fallback — gateFor и runtime СОВМЕСТНО
        # теряют обязательное клиентское поле responsible_entity_id, экран
        # маскирует дефект fallback'ом 're-001'. Патчи байт-в-байт из
        # воспроизводителя критика full_bypass.py. Дефект наблюдаем на входе
        # RUNTIME_GATE_SNAPSHOT: runtime.api.getDisclosureGate() возвращает
        # снимок без обязательного поля — литеральный семипольный оракул
        # (erstinfo.test.tsx, не gateFor) это различает; экранная маскировка
        # 're-001' держит BROKER_CARD_FIELDS/MOCK_SCREEN зелёными, поэтому
        # named-клетка ровно одна.
        'full-bypass-omitted-display-fallback': (
            [(M, 'responsible_entity_id: FIXED.responsible_entity_id,',
              "...({} as Pick<DisclosureGateSnapshot, 'responsible_entity_id'>),"),
             (C, '{snapshot.responsible_entity_id}</Text>',
              "{snapshot.responsible_entity_id || 're-001'}</Text>")],
            ['RUNTIME_GATE_SNAPSHOT'],
            []),
        # Пост-заморозочное усиление (вердикт адверсария impl-v3):
        # «admission защёлкнут на W0» — route поднимает admission из порта
        # composition root после чтения сессии; мутант подменяет подъём
        # литералом 'W0' (байт-в-байт реальная ветвь честной модели — отказ
        # сессии оставляет W0). Воспроизводит дефект C 0070c38: W1A
        # недостижим, getDisclosureGate не вызывается никогда.
        'admission-pinned-w0': (
            [(ROUTE_ENTRY, 'setAdmission(shippedRuntime.admission());',
              "setAdmission('W0');")],
            ['ROUTE_INIT_W1A_CURRENT_CONFIRMED_EQ'],
            [n for n in ROUTE_W1A_ALL if n != 'ROUTE_INIT_W1A_CURRENT_CONFIRMED_EQ']),
    }
    # Экранные мутанты легитимно краснят и route-клетки (route рендерит тот же
    # экран); depends расширены по грамматике клеток и измеряются полным
    # прогоном ниже. Мутанты M/R-файлов route-семьёй не затронуты: route-тест
    # подаёт среду через jest.mock('@pilot/runtime').
    ROUTE_DEPENDS = {
        'pending-not-awaiting': [rinit('PENDING', v) for v in AX]
                                + ['ROUTE_RECHECK_CONFIRM_PENDING'],
        'failed-shown-success': [rinit('FAILED', v) for v in AX]
                               + ['ROUTE_RECHECK_CONFIRM_FAILED',
                                  'ROUTE_RECHECK_RETRY_STAYS',
                                  'ROUTE_RECHECK_RETRY_RECOVERED'],
        'failed-no-retry': ROUTE_RECHECK_RETRY,
        'stale-version-confirmed': [rinit('CURRENT_CONFIRMED', 'STALE'),
                                    'ROUTE_RECHECK_CONFIRM_MOVED'],
        'versioncheck-flip': [rinit('CURRENT_CONFIRMED', 'EQ'),
                              rinit('CURRENT_CONFIRMED', 'STALE'),
                              'ROUTE_RECHECK_CONFIRM_STAYS',
                              'ROUTE_RECHECK_CONFIRM_MOVED',
                              'ROUTE_RECHECK_CONFIRM_FAILED',
                              'ROUTE_RECHECK_CONFIRM_PENDING',
                              'ROUTE_RECHECK_CONFIRM_CHECKING',
                              'ROUTE_RECHECK_RETRY_RECOVERED'],
        'w0-gate-continue': [rinit('CURRENT_CONFIRMED', 'EQ'),
                             'ROUTE_RECHECK_CONFIRM_STAYS',
                             'ROUTE_RECHECK_RETRY_RECOVERED'],
        'admission-all-states': ([rinit(s, v) for s in ST4 for v in AX]
                                 + [rinit('CURRENT_CONFIRMED', 'STALE')]
                                 + ['ROUTE_RECHECK_CONFIRM_MOVED',
                                    'ROUTE_RECHECK_CONFIRM_FAILED',
                                    'ROUTE_RECHECK_CONFIRM_PENDING',
                                    'ROUTE_RECHECK_CONFIRM_CHECKING',
                                    'ROUTE_RECHECK_RETRY_STAYS']),
        'copy-invented': [rinit('PENDING', v) for v in AX],
        'evidence-dropped': [rinit('CURRENT_CONFIRMED', 'EQ'),
                             'ROUTE_RECHECK_CONFIRM_STAYS',
                             'ROUTE_RECHECK_RETRY_RECOVERED'],
        'retry-rechecks-nothing': ROUTE_RECHECK_RETRY,
        'ack-recheck-lost': ROUTE_RECHECK_CONFIRM,
    }
    for mname, extra in ROUTE_DEPENDS.items():
        muts, named, depends = MUTANTS[mname]
        MUTANTS[mname] = (muts, named, depends + extra)
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
