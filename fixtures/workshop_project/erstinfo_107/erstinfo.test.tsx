// Красные тесты 107 (CMP-MOB-003), архитекторская проба Erstinformation.
// Значения — побайтово из оракула source.json (сняты с Complior-mob 76ac10fa
// ДО запуска субъекта); клетки порождаются циклами по закрытой грамматике
// (delivery_states × versions × admissions × evidence_invalid), не ручным списком.
// Круг 2 (kritik-107-krug1): полнота доказательства CURRENT_CONFIRMED (Б1),
// произведение состояний×версий×admission и побочные эффекты (Б2), время
// ack с управляемым Promise (Б3), исполнение настоящего ApiClient/mock (Б4),
// серверная грамматика MISSING/UNKNOWN/NOT_REQUIRED/snapshot-absent (С3),
// pin версии открытия в F02.05 (С4).
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

it('107 erstinfo FAILED_RETRY_ACTION', async () => {
  const { calls } = await harness({ gate: gate('FAILED', 'EQ') });
  await fireEvent.press(screen.getByTestId('erstinfo-retry'));
  expect(calls.recheck).toBe(1);
  expect(calls.ack).toEqual([]);
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

// Б1: CURRENT_CONFIRMED × непригодное evidence × обе admission —
// evidence-карта и continue отсутствуют при каждом виде негодного доказательства.
const EVIDENCE_INVALID: Record<string, Partial<DisclosureGateSnapshot>> = {
  EVIDENCE_NULL: { delivery_evidence_ref: null },
  EVIDENCE_EMPTY: { delivery_evidence_ref: '' },
  CHECKED_AT_EMPTY: { checked_at: '' },
  WRONG_DOCUMENT: { required_document_id: 'doc-another-document' },
  APPLICABILITY_UNKNOWN: { applicability: 'UNKNOWN' },
  VERSION_NOT_EQUAL: { required_document_version: 1 },
};
for (const admission of ADMISSIONS) {
  for (const [name, patch] of Object.entries(EVIDENCE_INVALID)) {
    it(`107 erstinfo EVIDENCE_${name}_${admission}`, async () => {
      await harness({ admission, gate: { ...gate('CURRENT_CONFIRMED', 'EQ'), ...patch } });
      expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
      expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
    });
  }
}

// Б2: полное произведение delivery_states × EQ/STALE × admissions —
// continue виден ТОЛЬКО в CURRENT_CONFIRMED_EQ при W1A.
for (const admission of ADMISSIONS) {
  for (const state of STATES) {
    for (const axis of AXES) {
      const allowed = admission === 'W1A' && state === 'CURRENT_CONFIRMED' && axis === 'EQ';
      it(`107 erstinfo GATE_CONTINUE_${admission}_${state}_${axis}`, async () => {
        await harness({ admission, gate: gate(state, axis) });
        if (allowed) {
          expect(screen.getByTestId('erstinfo-continue')).toBeOnTheScreen();
        } else {
          expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
        }
      });
    }
  }
}

// Б2: побочные эффекты {ack,open} × admission × версия — запрещённые
// эффекты (continue при ack/open; ack при open) наблюдаются все.
for (const admission of ADMISSIONS) {
  for (const axis of AXES) {
    it(`107 erstinfo ACTION_ACK_NO_CONTINUE_${admission}_${axis}`, async () => {
      const { calls } = await harness({ admission, gate: gate('CURRENT_CONFIRMED', axis) });
      await fireEvent.press(screen.getByTestId('erstinfo-confirm'));
      await act(async () => {});
      expect(calls.ack).toEqual([[FIXED.disclosure_ref, 2]]);
      expect(calls.cont).toBe(0);
      expect(calls.open).toEqual([]);
    });
    it(`107 erstinfo ACTION_OPEN_NO_CONTINUE_${admission}_${axis}`, async () => {
      const { calls } = await harness({ admission, gate: gate('CURRENT_CONFIRMED', axis) });
      await fireEvent.press(screen.getByTestId('erstinfo-open-document'));
      await act(async () => {});
      expect(calls.open).toEqual([[FIXED.document_ref, 2]]);
      expect(calls.ack).toEqual([]);
      expect(calls.cont).toBe(0);
    });
  }
}
it('107 erstinfo ACTION_CONTINUE_ONLY_W1A_EQ', async () => {
  const { calls } = await harness({ admission: 'W1A' });
  await fireEvent.press(screen.getByTestId('erstinfo-continue'));
  await act(async () => {});
  expect(calls.cont).toBe(1);
  expect(calls.ack).toEqual([]);
  expect(calls.open).toEqual([]);
  expect(calls.recheck).toBe(0);
});

// Б3: время — новая версия во время незавершённого ack (управляемый Promise):
// после завершения ack обязателен recheck, continue не происходит.
for (const admission of ADMISSIONS) {
  it(`107 erstinfo ACK_VERSION_CHANGES_${admission}`, async () => {
    let resolveAck!: (value: AcknowledgeDisclosureResult | void) => void;
    const ackPromise = new Promise<AcknowledgeDisclosureResult | void>((resolve) => {
      resolveAck = resolve;
    });
    const { calls, rerender } = await harness({
      admission,
      onAcknowledge: () => ackPromise,
    });
    await fireEvent.press(screen.getByTestId('erstinfo-confirm'));
    await act(async () => {
      rerender({ gate: gate('CURRENT_CONFIRMED', 'STALE') });
    });
    await act(async () => {
      resolveAck({ accepted: false, version: 2, evidence_ref: null });
    });
    expect(calls.cont).toBe(0);
    expect(calls.recheck).toBe(1);
    expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
  });
}

// Б3: успешный current-ack тоже перечитывает gate ПОСЛЕ завершения Promise.
for (const admission of ADMISSIONS) {
  for (const axis of AXES) {
    it(`107 erstinfo ACK_RECHECKS_${admission}_${axis}`, async () => {
      const { calls } = await harness({ admission, gate: gate('CURRENT_CONFIRMED', axis) });
      await fireEvent.press(screen.getByTestId('erstinfo-confirm'));
      await act(async () => {});
      expect(calls.ack).toEqual([[FIXED.disclosure_ref, 2]]);
      expect(calls.recheck).toBe(1);
    });
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

// С3: серверная грамматика за пределами пяти экранных состояний —
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

// Б4: сценарии mock и запись подтверждённой версии исполняются на НАСТОЯЩЕМ
// @/mocks/disclosure-mock, не ищутся подстрокой.
for (const state of STATES) {
  for (const axis of AXES) {
    it(`107 erstinfo MOCK_SCENARIO_${state}_${axis}`, () => {
      const snap = gateFor(state, axis);
      expect(snap.applicability).toBe('REQUIRED');
      expect(snap.required_document_id).toBe(FIXED.document_ref);
      expect(snap.delivery_state).toBe(state);
      expect(snap.required_document_version).toBe(axis === 'EQ' ? 2 : 3);
      expect(snap.delivery_evidence_ref).toBe(
        state === 'CURRENT_CONFIRMED' ? FIXED.evidence_ref : null,
      );
    });
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
it('107 erstinfo RUNTIME_GATE_SNAPSHOT', async () => {
  const snap = await runtime.api.getDisclosureGate();
  expect(snap).toMatchObject({
    applicability: 'REQUIRED',
    required_document_id: FIXED.document_ref,
    delivery_state: 'CURRENT_CONFIRMED',
    required_document_version: 2,
    delivery_evidence_ref: FIXED.evidence_ref,
  });
});
