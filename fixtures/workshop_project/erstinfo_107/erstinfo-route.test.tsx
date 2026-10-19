// Красные тесты 107 — route-уровень (пост-заморозочное усиление гейта по
// вердикту адверсария contracts-107-impl-v3): настоящий route-файл
// mobile/src/app/(entry)/erstinformation.tsx рендерится целиком в Jest/RNTL
// на disposable R. Обход адверсария: C стартует в W0 и не имеет достижимого
// перехода в W1A (единственный setter W1A висит на Continue, видимой только
// при уже W1A и доказанном gate) — getDisclosureGate не вызывается никогда,
// корректный CURRENT_CONFIRMED runtime не достигает экрана. Свидетельство
// адверсария (контроль W1A rc0, entry rc1) воспроизводится клетками
// ROUTE_INIT_W1A_*/ROUTE_RECHECK_*: на C они красны ровно этим, на честной
// модели — зелены.
// Admission подаётся РАБОЧИМ путём: сессия читается api.getSession, admission
// поднимается из ПОРТА composition root (runtime.admission). Session/OpenAPI
// 5.8.2 поля допуска не несит (api/generated/api-5_8.ts: principal_ref,
// display_name, auth_time, expires_at, locale, disclosure_requirements,
// home_widget_snapshot) — порт, не угаданное поле (слово консультанта по
// форку n107-impl-krug3). Ответы gate — литеральные снимки из оракула
// source.json (delivery_states × versions × fixed), ожидаются в памяти ДО
// вызова субъекта.
// Замкнутое произведение осей без раздувания (урок 107/108): INIT —
// admission {W0, W1A} × state × axis (W1A: 5×2=10; W0: одна клетка ожидания);
// RECHECK — триггер {CONFIRM, RETRY} × класс второго кадра, закрытый по
// РАЗЛИЧИМЫМ кадрам грамматики (evidence-EQ, updated-STALE, failed, pending,
// checking для CONFIRM; failed-остался, evidence-восстановился для RETRY).
// W0-клетка держит холодный шов: gate-ответ доступен, но вызовов 0.
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import React from 'react';

import type { Admission, DisclosureGateSnapshot } from '@/api/api-client';

const AXES = ['EQ', 'STALE'] as const;

// Литералы оракула source.json (fixed.*, versions, notice_key_by_state),
// снятые ДО запуска субъекта; не вывод кода субъекта.
const FIXED = {
  disclosure_ref: 'disc-erst-001',
  document_ref: 'doc-erstinformation',
  responsible_entity: 'Makler Meier GmbH',
  responsible_entity_id: 're-001',
  source_ref: 'source://broker-portal/erstinformation',
  evidence_ref: 'evidence://delivery/8f3a',
  checked_at: '2026-10-19T12:00:00Z',
};

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
  'disclosure.updated': 'Für diesen Schritt ist eine neuere Erstinformation erforderlich.',
  'frame.F02.08.title': 'Bereitstellung der Erstinformation',
};

// Литеральный снимок сценария: семь полей DisclosureGateSnapshot, значения из
// source.json (versions.eq/stale.required = 2/3, fixed.*); EQ — версия
// совпадает, STALE — требуемая новее.
function routeGate(state: string, axis: 'EQ' | 'STALE'): DisclosureGateSnapshot {
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

// Состояние composition-среды клетки. Всё, к чему обращается фабрика
// jest.mock, живёт здесь (префикс mock — требование hoisting).
const mockEnv = {
  admission: 'W0' as Admission,
  gateQueue: [] as DisclosureGateSnapshot[],
  gateCalls: 0,
  sessionCalls: 0,
  ackCalls: [] as Array<[string, number]>,
  session: {
    principal_ref: 'principal-001',
    display_name: 'Demo',
    auth_time: '2026-10-19T10:00:00Z',
    expires_at: '2026-10-19T11:00:00Z',
    locale: 'de-DE',
    disclosure_requirements: ['disc-erst-001'],
  },
  disclosure: {
    disclosure_ref: FIXED.disclosure_ref,
    document_ref: FIXED.document_ref,
    version: 2,
    acknowledged: false,
  },
};

jest.mock('@pilot/runtime', () => ({
  runtime: {
    auth: {},
    api: {
      getSession: async () => {
        mockEnv.sessionCalls += 1;
        return mockEnv.session;
      },
      getDisclosure: async () => mockEnv.disclosure,
      acknowledgeDisclosure: async (ref: string, version: number) => {
        mockEnv.ackCalls.push([ref, version]);
        return {
          disclosure_ref: ref,
          version,
          accepted: true,
          evidence_ref: `SYNTHETIC:${FIXED.evidence_ref}`,
        };
      },
      getDisclosureGate: async () => {
        mockEnv.gateCalls += 1;
        return mockEnv.gateQueue.length > 1
          ? (mockEnv.gateQueue.shift() as DisclosureGateSnapshot)
          : mockEnv.gateQueue[0];
      },
    },
    admission: () => mockEnv.admission,
  },
}));

import Entry from '@/app/(entry)/erstinformation';

beforeEach(() => {
  mockEnv.admission = 'W0';
  mockEnv.gateQueue = [routeGate('CURRENT_CONFIRMED', 'EQ')];
  mockEnv.gateCalls = 0;
  mockEnv.sessionCalls = 0;
  mockEnv.ackCalls = [];
});

// W0: gate-ответ доступен в среде, но шов холоден — вызовов 0, UI в
// состоянии ожидания (безопасный fallback gate=null → disclosure.checking),
// без evidence/continue.
it('107 erstinfo ROUTE_INIT_W0_WAITING', async () => {
  mockEnv.admission = 'W0';
  await render(<Entry />);
  await waitFor(() =>
    expect(screen.getByTestId('erstinfo-notice-disclosure.checking')).toBeOnTheScreen(),
  );
  expect(screen.getByText(TEXTS['disclosure.checking'])).toBeOnTheScreen();
  await act(async () => {});
  expect(mockEnv.gateCalls).toBe(0);
  expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
  expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
});

// W1A: сессия прочитана, admission поднят из порта, gate вызван РОВНО 1 раз,
// кадр соответствует сценарию (замкнутое произведение state × axis).
// На C 0070c38 (недостижимый W1A) все десять клеток красны: gate 0 вызовов,
// кадр сценария не появляется — воспроизведение свидетеля адверсария.
for (const state of ['CHECKING', 'PENDING', 'FAILED', 'OUTDATED', 'CURRENT_CONFIRMED']) {
  for (const axis of AXES) {
    const confirmedFresh = state === 'CURRENT_CONFIRMED' && axis === 'EQ';
    const expectedKey =
      state === 'CURRENT_CONFIRMED' && axis === 'STALE'
        ? NOTICE_KEY.OUTDATED
        : NOTICE_KEY[state];
    it(`107 erstinfo ROUTE_INIT_W1A_${state}_${axis}`, async () => {
      mockEnv.admission = 'W1A';
      mockEnv.gateQueue = [routeGate(state, axis)];
      await render(<Entry />);
      await waitFor(() => {
        if (confirmedFresh) {
          expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen();
        } else {
          expect(screen.getByTestId(`erstinfo-notice-${expectedKey}`)).toBeOnTheScreen();
        }
      });
      await act(async () => {});
      // Рабочий путь: сессия прочитана; gate потреблён после W1A ровно один раз.
      expect(mockEnv.sessionCalls).toBeGreaterThanOrEqual(1);
      expect(mockEnv.gateCalls).toBe(1);
      if (confirmedFresh) {
        expect(screen.getByTestId('erstinfo-evidence-ref')).toHaveTextContent(FIXED.evidence_ref);
        expect(screen.getByText(TEXTS['frame.F02.08.title'])).toBeOnTheScreen();
        expect(screen.getByTestId('erstinfo-continue')).toBeOnTheScreen();
      } else {
        expect(screen.getByText(TEXTS[expectedKey])).toBeOnTheScreen();
        expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
        expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
      }
    });
  }
}

// Recheck-путь: тот же seam после действия пользователя. CONFIRM — явное
// подтверждение (только при CURRENT_CONFIRMED ∧ EQ): ack → recheck → ВТОРОЙ
// вызов gate; второй кадр замкнут по различимым кадрам грамматики.
for (const [name, second, expectedKey] of [
  ['STAYS', ['CURRENT_CONFIRMED', 'EQ'], null],
  ['MOVED', ['CURRENT_CONFIRMED', 'STALE'], 'disclosure.updated'],
  ['FAILED', ['FAILED', 'EQ'], 'disclosure.failed'],
  ['PENDING', ['PENDING', 'EQ'], 'disclosure.pending'],
  ['CHECKING', ['CHECKING', 'EQ'], 'disclosure.checking'],
] as Array<[string, [string, 'EQ' | 'STALE'], string | null]>) {
  it(`107 erstinfo ROUTE_RECHECK_CONFIRM_${name}`, async () => {
    mockEnv.admission = 'W1A';
    mockEnv.gateQueue = [
      routeGate('CURRENT_CONFIRMED', 'EQ'),
      routeGate(second[0], second[1]),
    ];
    await render(<Entry />);
    await waitFor(() => expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen());
    expect(mockEnv.gateCalls).toBe(1);
    fireEvent.press(screen.getByTestId('erstinfo-confirm'));
    await waitFor(() => expect(mockEnv.gateCalls).toBe(2));
    if (expectedKey === null) {
      await waitFor(() => expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen());
      expect(screen.getByTestId('erstinfo-continue')).toBeOnTheScreen();
    } else {
      await waitFor(() =>
        expect(screen.getByTestId(`erstinfo-notice-${expectedKey}`)).toBeOnTheScreen(),
      );
      expect(screen.queryByTestId('erstinfo-evidence')).toBeNull();
      expect(screen.queryByTestId('erstinfo-continue')).toBeNull();
    }
    expect(mockEnv.ackCalls).toEqual([[FIXED.disclosure_ref, 2]]);
  });
}

// Recheck-путь RETRY: повторная проверка из FAILED (retry ⇔ FAILED); второй
// кадр — остался FAILED / восстановился до evidence-EQ. Retry не делает ack.
it('107 erstinfo ROUTE_RECHECK_RETRY_STAYS', async () => {
  mockEnv.admission = 'W1A';
  mockEnv.gateQueue = [routeGate('FAILED', 'EQ'), routeGate('FAILED', 'EQ')];
  await render(<Entry />);
  await waitFor(() =>
    expect(screen.getByTestId('erstinfo-notice-disclosure.failed')).toBeOnTheScreen(),
  );
  expect(mockEnv.gateCalls).toBe(1);
  fireEvent.press(screen.getByTestId('erstinfo-retry'));
  await waitFor(() => expect(mockEnv.gateCalls).toBe(2));
  await waitFor(() =>
    expect(screen.getByTestId('erstinfo-notice-disclosure.failed')).toBeOnTheScreen(),
  );
  expect(mockEnv.ackCalls).toEqual([]);
});

it('107 erstinfo ROUTE_RECHECK_RETRY_RECOVERED', async () => {
  mockEnv.admission = 'W1A';
  mockEnv.gateQueue = [routeGate('FAILED', 'EQ'), routeGate('CURRENT_CONFIRMED', 'EQ')];
  await render(<Entry />);
  await waitFor(() =>
    expect(screen.getByTestId('erstinfo-notice-disclosure.failed')).toBeOnTheScreen(),
  );
  expect(mockEnv.gateCalls).toBe(1);
  fireEvent.press(screen.getByTestId('erstinfo-retry'));
  await waitFor(() => expect(mockEnv.gateCalls).toBe(2));
  await waitFor(() => expect(screen.getByTestId('erstinfo-evidence')).toBeOnTheScreen());
  expect(screen.getByTestId('erstinfo-continue')).toBeOnTheScreen();
  expect(mockEnv.ackCalls).toEqual([]);
});
