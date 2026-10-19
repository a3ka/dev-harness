// Красные тесты 107 (CMP-MOB-003), архитекторская проба Erstinformation.
// Значения — побайтово из оракула source.json (сняты с Complior-mob 76ac10fa
// ДО запуска субъекта); клетки порождаются циклами по закрытой грамматике
// (delivery_states × versions × admissions × evidence_fields), не ручным списком.
// Круг 3 (арбитраж contracts-107-perechen-v1): критерий — ЗАКРЫТОЕ произведение
// осей К5′–К9′, а не поштучные мутанты: К5′ произведение ЗНАЧЕНИЙ полей
// доказательства (96), К6′ действие × полный вектор эффектов × состояние ×
// версия × admission (100), К7′ исход ack × версия ушла × admission с порядком
// ack-start→settled→recheck и исходом reject (12), К8′ серверная грамматика
// (как на OBJECT), К9′ mock/runtime → экран × admission + полный снимок (21).
// Круги 1–2 (kritik-107-krug1/krug2): семьи К1–К4, К8, статическая — сохранены.
// Паттерн await render/await fireEvent — прецедент rehearsal.test.tsx (RNTL 14).
import { act, fireEvent, render, screen } from '@testing-library/react-native';
import React from 'react';

import { Erstinformation } from '@/features/onboarding/erstinformation';
import type {
  AcknowledgeDisclosureResult,
  DisclosureGateSnapshot,
} from '@/api/api-client';
import { acknowledgeMock, gateFor, lastAcknowledged } from '@/mocks/disclosure-mock';
import { runtime } from '@/mocks/runtime';

const STATES = ['CHECKING', 'PENDING', 'FAILED', 'OUTDATED', 'CURRENT_CONFIRMED'] as const;
const AXES = ['EQ', 'STALE'] as const;
const ADMISSIONS = ['W0', 'W1A'] as const;

const NOTICE_KEY: Record<string, string> = {
  CHECKING: 'disclosure.checking',
  PENDING: 'disclosure.pending',
  FAILED: 'disclosure.failed',
  OUTDATED: 'disclosure.updated',
};

const TEXTS: Record<string, string> = {
  'disclosure.checking': 'Die Bereitstellung Ihrer Erstinformation wird geprüft.',
  'disclosure.pending': 'Der Nachweis steht noch aus. Wir prüfen die Übermittlung.',
  'disclosure.failed':
    'Die Bereitstellung konnte nicht bestätigt werden. Ihr Anliegen bleibt gespeichert.',
  'disclosure.retry': 'Bereitstellung erneut prüfen',
  'disclosure.updated': 'Für diesen Schritt ist eine neuere Erstinformation erforderlich.',
  'disclosure.missing':
    'Die erforderliche Erstinformation wurde noch nicht bestätigt bereitgestellt.',
  'disclosure.not_applicable':
    'Für diesen Schritt ist keine erneute Bereitstellung erforderlich.',
  'frame.F02.03.title': 'Informationen zu Ihrem Makler',
  'frame.F02.05.title': 'Dokument ansehen',
  'frame.F02.08.title': 'Bereitstellung der Erstinformation',
  'action.F02.A02': 'Dokument öffnen',
};

const FIXED = {
  disclosure_ref: 'disc-erst-001',
  document_ref: 'doc-erstinformation',
  responsible_entity: 'Makler Meier GmbH',
  responsible_entity_id: 're-001',
  source_ref: 'source://broker-portal/erstinformation',
  evidence_ref: 'evidence://delivery/8f3a',
  checked_at: '2026-10-19T12:00:00Z',
};

function gate(state: string, axis: 'EQ' | 'STALE'): DisclosureGateSnapshot {
  const required = axis === 'EQ' ? 2 : 3;
  const confirmed = state === 'CURRENT_CONFIRMED';
  return {
    applicability: 'REQUIRED',
    required_document_id: FIXED.document_ref,
    required_document_version: required,
    responsible_entity_id: FIXED.responsible_entity_id,
    delivery_state: state as DisclosureGateSnapshot['delivery_state'],
    delivery_evidence_ref: confirmed ? FIXED.evidence_ref : null,
    checked_at: FIXED.checked_at,
  };
}

const payload = {
  disclosure_ref: FIXED.disclosure_ref,
  document_ref: FIXED.document_ref,
  version: 2,
  responsible_entity: FIXED.responsible_entity,
  source_ref: FIXED.source_ref,
};

async function harness(props: Partial<Parameters<typeof Erstinformation>[0]> = {}) {
  const calls = {
    ack: [] as Array<[string, number]>,
    recheck: 0,
    open: [] as Array<[string, number]>,
    cont: 0,
  };
  const api = {
    onAcknowledge: (ref: string, version: number) => {
      calls.ack.push([ref, version]);
    },
    onRecheck: () => {
      calls.recheck += 1;
    },
    onOpenDocument: (ref: string, version: number) => calls.open.push([ref, version]),
    onContinue: () => {
      calls.cont += 1;
    },
  };
  const current: Parameters<typeof Erstinformation>[0] = {
    gate: gate('CURRENT_CONFIRMED', 'EQ'),
    disclosure: payload,
    ...api,
    ...props,
  };
  const view = await render(<Erstinformation {...current} />);
  return {
    calls,
    rerender: (override: Partial<Parameters<typeof Erstinformation>[0]>) => {
      Object.assign(current, override);
      view.rerender(<Erstinformation {...current} />);
    },
  };
}

// FLOW: разнесение состояний F02.08; CURRENT_CONFIRMED только при
// совпадении версии и evidence; старая версия показывает disclosure.updated.
for (const state of STATES) {
  for (const axis of AXES) {
    const confirmedFresh = state === 'CURRENT_CONFIRMED' && axis === 'EQ';
    const staleConfirmed = state === 'CURRENT_CONFIRMED' && axis === 'STALE';
    const expectedKey = staleConfirmed ? NOTICE_KEY.OUTDATED : NOTICE_KEY[state];
    it(`107 erstinfo FLOW_${state}_VM_${axis}`, async () => {
      await harness({ gate: gate(state, axis) });
      if (confirmedFresh) {
        expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen();
        expect(screen.getByTestId('erstinfo-evidence-ref')).toHaveTextContent(FIXED.evidence_ref);
        expect(screen.queryByTestId(`erstinfo-notice-${NOTICE_KEY[state]}`)).toBeNull();
      } else {
        expect(screen.getByTestId(`erstinfo-notice-${expectedKey}`)).toBeOnTheScreen();
        expect(screen.getByText(TEXTS[expectedKey])).toBeOnTheScreen();
        expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
      }
    });
  }
}

it('107 erstinfo BROKER_CARD_FIELDS', async () => {
  await harness();
  expect(screen.getByTestId('erstinfo-responsible-entity')).toBeOnTheScreen();
  expect(screen.getByText(FIXED.responsible_entity)).toBeOnTheScreen();
  expect(screen.getByText(FIXED.responsible_entity_id)).toBeOnTheScreen();
  expect(screen.getByTestId('erstinfo-document-card')).toBeOnTheScreen();
  expect(screen.getByTestId('erstinfo-source-ref')).toHaveTextContent(FIXED.source_ref);
  expect(screen.getByTestId('erstinfo-checked-at')).toHaveTextContent(FIXED.checked_at);
});

it('107 erstinfo ACK_EXPLICIT_CURRENT', async () => {
  const { calls } = await harness();
  await fireEvent.press(screen.getByTestId('erstinfo-confirm'));
  await act(async () => {});
  expect(calls.ack).toEqual([[FIXED.disclosure_ref, 2]]);
});

it('107 erstinfo ACK_PDF_OPEN_NOT_ACK', async () => {
  const { calls } = await harness();
  await fireEvent.press(screen.getByTestId('erstinfo-open-document'));
  expect(calls.ack).toEqual([]);
  expect(calls.open).toEqual([[FIXED.document_ref, 2]]);
  expect(screen.getByTestId('erstinfo-frame-F02.05')).toBeOnTheScreen();
});

// Подтверждение не предлагается ни в одном не-confirmed состоянии.
for (const state of STATES.filter((s) => s !== 'CURRENT_CONFIRMED')) {
  it(`107 erstinfo ACK_ABSENT_${state}`, async () => {
    await harness({ gate: gate(state, 'EQ') });
    expect(screen.queryByTestId('erstinfo-confirm')).toBeNull();
  });
}

it('107 erstinfo ACK_STALE_NO_CONTINUE', async () => {
  const { calls } = await harness({ gate: gate('CURRENT_CONFIRMED', 'STALE') });
  await fireEvent.press(screen.getByTestId('erstinfo-confirm'));
  await act(async () => {});
  expect(calls.ack).toEqual([[FIXED.disclosure_ref, 2]]);
  expect(calls.cont).toBe(0);
  expect(calls.recheck).toBe(1);
});

it('107 erstinfo DOC_OPEN_EXACT_VERSION', async () => {
  // STALE: требуемая версия 3, открытая — 2; F02.05 показывает 2 (exact version).
  await harness({ gate: gate('CURRENT_CONFIRMED', 'STALE') });
  await fireEvent.press(screen.getByTestId('erstinfo-open-document'));
  expect(screen.getByTestId('erstinfo-frame-F02.05')).toBeOnTheScreen();
  expect(screen.getByTestId('erstinfo-document-version')).toHaveTextContent('Version 2');
});

it('107 erstinfo DOC_RETURN_PRESERVES', async () => {
  await harness();
  await fireEvent.press(screen.getByTestId('erstinfo-open-document'));
  await fireEvent.press(screen.getByTestId('erstinfo-back'));
  expect(screen.getByTestId('erstinfo-frame-F02.03')).toBeOnTheScreen();
  expect(screen.getByTestId('erstinfo-responsible-entity')).toBeOnTheScreen();
  expect(screen.getByText(FIXED.responsible_entity)).toBeOnTheScreen();
  expect(screen.getByTestId('erstinfo-document-ref')).toHaveTextContent(FIXED.document_ref);
});

it('107 erstinfo NO_AUTO_CONTINUE_ON_VIEW', async () => {
  const { calls } = await harness({ admission: 'W1A' });
  expect(calls.cont).toBe(0);
  expect(calls.ack).toEqual([]);
});

it('107 erstinfo W1A_CONTINUE_EXPLICIT', async () => {
  const { calls } = await harness({ admission: 'W1A' });
  await fireEvent.press(screen.getByTestId('erstinfo-continue'));
  expect(calls.cont).toBe(1);
});

it('107 erstinfo NO_GATE_IN_W0', async () => {
  await harness({ admission: 'W0' });
  expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
});

it('107 erstinfo COPY_TITLES_FROM_CATALOG', async () => {
  await harness();
  expect(screen.getByText(TEXTS['frame.F02.03.title'])).toBeOnTheScreen();
  expect(screen.getByText(TEXTS['frame.F02.08.title'])).toBeOnTheScreen();
  expect(screen.getByText(TEXTS['action.F02.A02'])).toBeOnTheScreen();
});

// К5′ (арбитраж 107, инвариант 3): доказательство — произведение ЗНАЧЕНИЙ полей
// evidence, не одиночные patch'и. ref ∈ {valid,null,''} × checked_at ∈ {valid,''}
// × document ∈ {same,other} × applicability ∈ {REQUIRED,UNKNOWN} × version ∈
// {EQ,NOT_EQUAL} = 48 комбинаций × 2 admission = 96 клеток; ровно одна
// комбинация валидна (evidence-карта; continue ⇔ W1A), 47 → disclosure.updated
// без evidence-карты и без continue. «Любое нарушение» инварианта 3 доказано
// произведением: мутант, различающий подмножества полей, различим своей клеткой.
const EVIDENCE_FIELDS: Array<[string, Array<Partial<DisclosureGateSnapshot>>]> = [
  ['REF', [{}, { delivery_evidence_ref: null }, { delivery_evidence_ref: '' }]],
  ['CHK', [{}, { checked_at: '' }]],
  ['DOC', [{}, { required_document_id: 'doc-another-document' }]],
  ['APPL', [{}, { applicability: 'UNKNOWN' }]],
  ['VER', [{}, { required_document_version: 1 }]],
];

function evidenceCombos(
  i = 0,
  acc: Partial<DisclosureGateSnapshot> = {},
  name = '',
): Array<{ name: string; patch: Partial<DisclosureGateSnapshot>; valid: boolean }> {
  if (i === EVIDENCE_FIELDS.length) {
    return [{ name, patch: acc, valid: Object.keys(acc).length === 0 }];
  }
  const [label, values] = EVIDENCE_FIELDS[i];
  return values.flatMap((p, j) =>
    evidenceCombos(i + 1, { ...acc, ...p }, name + label + j),
  );
}

for (const admission of ADMISSIONS) {
  for (const { name, patch, valid } of evidenceCombos()) {
    it(`107 erstinfo EVIDENCE_PROD_${admission}_${name}`, async () => {
      await harness({ admission, gate: { ...gate('CURRENT_CONFIRMED', 'EQ'), ...patch } });
      if (valid) {
        expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen();
        expect(screen.queryByTestId('erstinfo-continue') !== null).toBe(admission === 'W1A');
      } else {
        expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
        expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
        expect(screen.getByTestId('erstinfo-notice-disclosure.updated')).toBeOnTheScreen();
      }
    });
  }
}

// К6′ (арбитраж 107, инварианты 4–6, issue #7 работа 5): каждое действие
// {open,retry,confirm,continue,back} × полный вектор эффектов (open, ack,
// recheck, cont) × state × axis × admission = 5×2×2×5 = 100 клеток.
// (а) доступность ровно по правилу: retry ⇔ FAILED; confirm ⇔ CURRENT_CONFIRMED;
// continue ⇔ W1A ∧ CURRENT_CONFIRMED ∧ EQ; open/back всегда; (б) после нажатия
// вектор E равен ожидаемому: open→(1,0,0,0), retry→(0,0,1,0),
// confirm→(0,1,1,0) после settlement, continue→(0,0,0,1), back→(0,0,0,0).
type ActionId = 'OPEN' | 'RETRY' | 'CONFIRM' | 'CONTINUE' | 'BACK';
const ACTIONS: Array<[ActionId, string]> = [
  ['OPEN', 'erstinfo-open-document'],
  ['RETRY', 'erstinfo-retry'],
  ['CONFIRM', 'erstinfo-confirm'],
  ['CONTINUE', 'erstinfo-continue'],
  ['BACK', 'erstinfo-back'],
];
const EFFECT: Record<ActionId, { open: number; ack: number; recheck: number; cont: number }> = {
  OPEN: { open: 1, ack: 0, recheck: 0, cont: 0 },
  RETRY: { open: 0, ack: 0, recheck: 1, cont: 0 },
  CONFIRM: { open: 0, ack: 1, recheck: 1, cont: 0 },
  CONTINUE: { open: 0, ack: 0, recheck: 0, cont: 1 },
  BACK: { open: 0, ack: 0, recheck: 0, cont: 0 },
};

for (const admission of ADMISSIONS) {
  for (const state of STATES) {
    for (const axis of AXES) {
      for (const [action, testID] of ACTIONS) {
        it(`107 erstinfo ACTION_VECTOR_${admission}_${state}_${axis}_${action}`, async () => {
          const { calls } = await harness({ admission, gate: gate(state, axis) });
          if (action === 'BACK') {
            // back живёт в F02.05: сначала открытие документа, эффект open сброшен.
            await fireEvent.press(screen.getByTestId('erstinfo-open-document'));
            calls.open.length = 0;
          }
          const available =
            action === 'BACK' ||
            action === 'OPEN' ||
            (action === 'RETRY' && state === 'FAILED') ||
            (action === 'CONFIRM' && state === 'CURRENT_CONFIRMED') ||
            (action === 'CONTINUE' &&
              admission === 'W1A' &&
              state === 'CURRENT_CONFIRMED' &&
              axis === 'EQ');
          const el = screen.queryByTestId(testID);
          expect(el !== null).toBe(available);
          if (el === null) {
            return;
          }
          await fireEvent.press(el);
          await act(async () => {});
          expect({
            open: calls.open.length,
            ack: calls.ack.length,
            recheck: calls.recheck,
            cont: calls.cont,
          }).toEqual(EFFECT[action]);
        });
      }
    }
  }
}

// К7′ (арбитраж 107, инвариант 5): исход ack {accepted, notAccepted, reject} ×
// moved {нет, да: gate → STALE до settlement} × admission = 12 клеток; порядок
// событий ack-start → settled → recheck (до settlement recheck = 0, после —
// ровно 1), cont = 0, continue виден ⇔ W1A ∧ ¬moved (после reject дальнейшее
// решает перечитанный gate, а не исход ack). Исход reject обязателен: контракт
// :96 предписывает http-runtime именованный отказ до CMP-BCK-008/024 — экран
// наблюдает завершение и этого Promise (эталон гасит rejection терминальным
// .catch ПОСЛЕ finally).
const ACK_OUTCOMES: Record<
  string,
  (d: {
    resolve: (v: AcknowledgeDisclosureResult | void) => void;
    reject: (e: Error) => void;
  }) => void
> = {
  ACCEPTED: (d) =>
    d.resolve({
      disclosure_ref: FIXED.disclosure_ref,
      version: 2,
      accepted: true,
      evidence_ref: FIXED.evidence_ref,
    }),
  NOT_ACCEPTED: (d) =>
    d.resolve({
      disclosure_ref: FIXED.disclosure_ref,
      version: 2,
      accepted: false,
      evidence_ref: null,
    }),
  REJECT: (d) => d.reject(new Error('ACK_NAMED_FAILURE')),
};

for (const admission of ADMISSIONS) {
  for (const moved of [false, true]) {
    for (const [oname, settle] of Object.entries(ACK_OUTCOMES)) {
      it(`107 erstinfo ACK_OUTCOME_${admission}_MOVED${moved ? 1 : 0}_${oname}`, async () => {
        let resolveAck!: (v: AcknowledgeDisclosureResult | void) => void;
        let rejectAck!: (e: Error) => void;
        const ackPromise = new Promise<AcknowledgeDisclosureResult | void>((resolve, reject) => {
          resolveAck = resolve;
          rejectAck = reject;
        });
        const events: string[] = [];
        const { calls, rerender } = await harness({
          admission,
          onAcknowledge: () => {
            events.push('ack-start');
            return ackPromise;
          },
          onRecheck: () => {
            events.push('recheck');
          },
        });
        await fireEvent.press(screen.getByTestId('erstinfo-confirm'));
        if (moved) {
          await act(async () => {
            rerender({ gate: gate('CURRENT_CONFIRMED', 'STALE') });
          });
        }
        // До settlement: только ack-start, recheck ещё не вызван.
        expect(events).toEqual(['ack-start']);
        await act(async () => {
          events.push('settled');
          settle({ resolve: resolveAck, reject: rejectAck });
        });
        // После settlement: ровно один recheck; continue не нажимается.
        expect(events).toEqual(['ack-start', 'settled', 'recheck']);
        expect(calls.cont).toBe(0);
        expect(calls.open).toEqual([]);
        expect(screen.queryByTestId('erstinfo-continue') !== null).toBe(
          admission === 'W1A' && !moved,
        );
      });
    }
  }
}

// С4: F02.05 держит версию открытия — смена payload во время чтения
// не подменяет надпись (и не требует нового onOpenDocument).
for (const admission of ADMISSIONS) {
  it(`107 erstinfo DOC_PINS_VERSION_${admission}`, async () => {
    const { rerender } = await harness({ admission });
    await fireEvent.press(screen.getByTestId('erstinfo-open-document'));
    await act(async () => {
      rerender({
        disclosure: { ...payload, version: 3 },
        gate: gate('CURRENT_CONFIRMED', 'EQ'),
      });
    });
    expect(screen.getByTestId('erstinfo-document-version')).toHaveTextContent('Version 2');
  });
}

// С3/К8′: серверная грамматика за пределами пяти экранных состояний —
// MISSING/UNKNOWN delivery и NOT_REQUIRED/отсутствующий snapshot:
// безопасный fallback без evidence/confirm/continue, без краха.
const SERVER_EXTRA_NOTICE: Record<string, string> = {
  DELIVERY_MISSING: 'disclosure.missing',
  DELIVERY_UNKNOWN: 'disclosure.checking',
  APPLICABILITY_NOT_REQUIRED: 'disclosure.not_applicable',
};
const SERVER_EXTRA: Record<string, Partial<DisclosureGateSnapshot>> = {
  DELIVERY_MISSING: { delivery_state: 'MISSING' },
  DELIVERY_UNKNOWN: { delivery_state: 'UNKNOWN' },
  APPLICABILITY_NOT_REQUIRED: { applicability: 'NOT_REQUIRED' },
};
for (const admission of ADMISSIONS) {
  for (const [name, patch] of Object.entries(SERVER_EXTRA)) {
    it(`107 erstinfo ${name}_${admission}`, async () => {
      await harness({ admission, gate: { ...gate('CURRENT_CONFIRMED', 'EQ'), ...patch } });
      expect(screen.getByTestId(`erstinfo-notice-${SERVER_EXTRA_NOTICE[name]}`)).toBeOnTheScreen();
      expect(screen.getByText(TEXTS[SERVER_EXTRA_NOTICE[name]])).toBeOnTheScreen();
      expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
      expect(screen.queryByTestId('erstinfo-confirm')).toBeNull();
      expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
    });
  }
  it(`107 erstinfo SNAPSHOT_ABSENT_${admission}`, async () => {
    await harness({ admission, gate: null });
    expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
    expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
  });
}

// К9′(а) (арбитраж 107, Б4): каждый mock-сценарий (state × axis) × admission —
// настоящий gateFor(state, axis) ПОДАЁТСЯ В ЭКРАН, наблюдается заявленное
// состояние (notice/evidence) и continue ⇔ W1A ∧ CURRENT_CONFIRMED ∧ EQ;
// 20 клеток. Исполнение на настоящем @/mocks/disclosure-mock, не подстрокой.
for (const admission of ADMISSIONS) {
  for (const state of STATES) {
    for (const axis of AXES) {
      it(`107 erstinfo MOCK_SCREEN_${admission}_${state}_${axis}`, async () => {
        await harness({ admission, gate: gateFor(state, axis) });
        const confirmed = state === 'CURRENT_CONFIRMED' && axis === 'EQ';
        if (confirmed) {
          expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen();
          expect(screen.getByTestId('erstinfo-evidence-ref')).toHaveTextContent(FIXED.evidence_ref);
        } else {
          const noticeKey =
            state === 'CURRENT_CONFIRMED' ? NOTICE_KEY.OUTDATED : NOTICE_KEY[state];
          expect(screen.getByTestId(`erstinfo-notice-${noticeKey}`)).toBeOnTheScreen();
          expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
        }
        expect(screen.queryByTestId('erstinfo-continue') !== null).toBe(
          admission === 'W1A' && confirmed,
        );
      });
    }
  }
}
it('107 erstinfo MOCK_ACK_RECORDS', () => {
  acknowledgeMock('independent-disclosure', 7);
  expect(lastAcknowledged()).toEqual({ disclosure_ref: 'independent-disclosure', version: 7 });
});

// Б4: настоящий @/mocks/runtime — пользовательский ack и gate-снимок
// реально исполняются операциями ApiClient, без mock-подмены методов.
it('107 erstinfo RUNTIME_ACK_EXECUTES', async () => {
  const result = await runtime.api.acknowledgeDisclosure('disc-runtime', 9);
  expect(result).toEqual({
    disclosure_ref: 'disc-runtime',
    version: 9,
    accepted: true,
    evidence_ref: `SYNTHETIC:${FIXED.evidence_ref}`,
  });
});

// К9′(б) (арбитраж 107 Б4 + микро-круг по вердикту критика круга 3, К9′(б)):
// runtime-снимок сверяется toEqual ЛИТЕРАЛЬНОМУ семипольному оракулу.
// Ожидаемое значение НЕ вычисляется кодом субъекта (gateFor/gateMock):
// toEqual(gateFor(...)) сравнивал два одинаково испорченных снимка
// (runtime.api.getDisclosureGate → gateMock → gateFor), и мутант
// «поле ответчика потеряно jointly в gateFor и runtime + экранная маскировка
// fallback'ом» проходил все пробы. Литерал выписан по первоисточникам:
// тип DisclosureGateSnapshot из api-client.ts (7 полей: applicability,
// required_document_id, required_document_version, responsible_entity_id,
// delivery_state, delivery_evidence_ref, checked_at) + source.json
// (fixed.*, versions.eq.required = 2). FIXED — локальный литерал теста,
// снятый с source.json ДО запуска субъекта, не вывод mock'а. Снимок
// ПОДАЁТСЯ В ЭКРАН: evidence-карта с checked_at и continue при W1A.
it('107 erstinfo RUNTIME_GATE_SNAPSHOT', async () => {
  const snap = await runtime.api.getDisclosureGate();
  expect(snap).toEqual({
    applicability: 'REQUIRED',
    required_document_id: FIXED.document_ref,
    required_document_version: 2,
    responsible_entity_id: FIXED.responsible_entity_id,
    delivery_state: 'CURRENT_CONFIRMED',
    delivery_evidence_ref: FIXED.evidence_ref,
    checked_at: FIXED.checked_at,
  });
  await harness({ admission: 'W1A', gate: snap });
  expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen();
  expect(screen.getByTestId('erstinfo-evidence-checked-at')).toHaveTextContent(FIXED.checked_at);
  expect(screen.getByTestId('erstinfo-continue')).toBeOnTheScreen();
});
