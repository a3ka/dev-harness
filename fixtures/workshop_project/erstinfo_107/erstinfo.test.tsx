// Красные тесты 107 (CMP-MOB-003), архитекторская проба Erstinformation.
// Значения — побайтово из оракула source.json (сняты с Complior-mob 76ac10fa
// ДО запуска субъекта); клетки порождаются циклами по закрытой грамматике
// (delivery_states × versions × admissions), не ручным списком.
// Паттерн await render/await fireEvent — прецедент rehearsal.test.tsx (RNTL 14).
import { fireEvent, render, screen } from '@testing-library/react-native';
import React from 'react';

import { Erstinformation } from '@/features/onboarding/erstinformation';
import type { DisclosureGateSnapshot } from '@/api/api-client';

const STATES = ['CHECKING', 'PENDING', 'FAILED', 'OUTDATED', 'CURRENT_CONFIRMED'] as const;
const AXES = ['EQ', 'STALE'] as const;

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
    onAcknowledge: (ref: string, version: number) => calls.ack.push([ref, version]),
    onRecheck: () => {
      calls.recheck += 1;
    },
    onOpenDocument: (ref: string, version: number) => calls.open.push([ref, version]),
    onContinue: () => {
      calls.cont += 1;
    },
  };
  await render(
    <Erstinformation
      gate={gate('CURRENT_CONFIRMED', 'EQ')}
      disclosure={payload}
      {...api}
      {...props}
    />,
  );
  return { calls };
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
