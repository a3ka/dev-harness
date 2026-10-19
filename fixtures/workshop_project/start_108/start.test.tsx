// Красные тесты 108 (CMP-MOB-004), архитекторская проба Start F04.01–F04.07.
// Значения — побайтово из оракула source.json (сняты с Complior-mob 76ac10fa
// ДО запуска субъекта); клетки порождаются циклами по закрытой грамматике
// (avatar_states × missions_presence × motion; actions × effects; ui_states;
// mission_states; mock/runtime), не ручным списком.
// Оси 107 (круги 1–2 + арбитраж К5′–К9′) применены с первой редакции:
//  - полное произведение состояний × доступности × движения (К1);
//  - каждое доступное действие × полный вектор эффектов, включая запрещённый
//    наблюдатель микрофона (К3); побочные эффекты наблюдены все;
//  - revoked-ACL переход убирает прежнее содержание brief (К2);
//  - Listening — UI-состояние с порядком выхода, без wire-эффектов (К4);
//  - черновик сохраняется при смене пропсов и каналов (К5);
//  - настоящие @/mocks/start-mock и @/mocks/runtime исполняются, снимок
// Паттерн await render/await fireEvent — прецедент rehearsal.test.tsx (RNTL 14).
import { act, fireEvent, render, screen } from '@testing-library/react-native';
import React from 'react';

import { StartScreen } from '@/features/start/start-screen';
import type { MissionBrief, MissionState } from '@/api/api-client';
import type { AvatarState } from '@/ui/agent-presence/agent-presence';
import { MISSION_STATES, MISSION_ID, UPDATED_AT, missionsFor, missionsSnapshot, setScenario } from '@/mocks/start-mock';
import { runtime } from '@/mocks/runtime';

const AVATARS: readonly AvatarState[] = ['idle', 'working', 'unavailable'];
const PRESENCES = ['EMPTY', 'PRESENT'] as const;
const MOTIONS = ['full', 'reduced'] as const;
const ACTIONS = ['WRITE', 'TALK', 'RESUME'] as const;

const TEXTS: Record<string, string> = {
  'frame.F04.01.title': 'Was möchten Sie klären?',
  'frame.F04.01.body':
    'Was ist passiert? Schreiben Sie, sprechen Sie oder fügen Sie ein Foto oder Dokument hinzu.',
  'frame.F04.02.title': 'Was ist passiert?',
  'frame.F04.02.body': 'Schreiben Sie Ihr Anliegen oder starten Sie ein Gespräch.',
  'frame.F04.03.title': 'Ich höre zu.',
  'frame.F04.03.body':
    'Sie können das Gespräch jederzeit unterbrechen oder zum Text wechseln.',
  'frame.F04.06.title': 'Hier machen wir weiter.',
  'frame.F04.06.body': 'Sehen Sie den aktuellen Stand und setzen Sie Ihr Anliegen fort.',
  'action.F04.A01': 'Nachricht schreiben',
  'action.F04.A02': 'Sprechen',
  'action.F04.A03': 'Vorgang fortsetzen',
};

const FIXED = { mission_id: MISSION_ID, updated_at: UPDATED_AT, draft_text: 'Kfz-Rechner Frage' };

function brief(presence: 'EMPTY' | 'PRESENT', state: MissionState = 'WORKING'): MissionBrief[] {
  return presence === 'PRESENT'
    ? [{ mission_id: FIXED.mission_id, state, updated_at: FIXED.updated_at }]
    : [];
}

async function harness(props: Partial<Parameters<typeof StartScreen>[0]> = {}) {
  const calls = {
    write: 0,
    talk: 0,
    resume: [] as string[],
    mic: 0,
  };
  const current: Parameters<typeof StartScreen>[0] = {
    missions: brief('PRESENT'),
    avatarState: 'idle',
    reducedMotion: false,
    onWrite: () => {
      calls.write += 1;
    },
    onTalk: () => {
      calls.talk += 1;
    },
    onResume: (missionId: string) => {
      calls.resume.push(missionId);
    },
    onMicrophoneRequested: () => {
      calls.mic += 1;
    },
    ...props,
  };
  const view = await render(<StartScreen {...current} />);
  return {
    calls,
    rerender: async (override: Partial<Parameters<typeof StartScreen>[0]>) => {
      Object.assign(current, override);
      await act(async () => {
        view.rerender(<StartScreen {...current} />);
      });
    },
  };
}

// К1: произведение avatar × presence × motion — присутствие есть всегда,
// ровно один композер, ≤1 контекстная карточка, empty-groups/KPI/voice-session
// отсутствуют, unavailable не выглядит работающим процессом, слоты стабильны.
for (const avatar of AVATARS) {
  for (const presence of PRESENCES) {
    for (const motion of MOTIONS) {
      it(`108 start STRUCTURE_${avatar}_${presence}_${motion}`, async () => {
        await harness({ avatarState: avatar, missions: brief(presence), reducedMotion: motion === 'reduced' });
        expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
        expect(screen.getByTestId(`start-avatar-${avatar}`)).toBeOnTheScreen();
        expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
        expect(screen.queryByTestId('start-empty-groups')).toBeNull();
        expect(screen.queryByTestId('start-kpi-dashboard')).toBeNull();
        expect(screen.queryByTestId('start-voice-session')).toBeNull();
        if (avatar === 'unavailable') {
          expect(screen.queryByTestId('start-avatar-working')).toBeNull();
        }
        const cards = screen.queryAllByTestId('start-contextual-card');
        expect(cards.length).toBeLessThanOrEqual(1);
        if (presence === 'PRESENT') {
          expect(screen.getByTestId('start-resume-brief')).toBeOnTheScreen();
          expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(FIXED.mission_id);
        } else {
          expect(screen.queryByTestId('start-resume-brief')).toBeNull();
          expect(screen.queryByTestId('start-contextual-card')).toBeNull();
          expect(screen.queryByText(FIXED.mission_id)).toBeNull();
        }
      });
    }
  }
}

// К2: бриф показывает полное состояние дела (все 10 значений OpenAPI-enum).
for (const state of MISSION_STATES) {
  it(`108 start BRIEF_STATE_${state}`, async () => {
    await harness({ missions: brief('PRESENT', state) });
    expect(screen.getByTestId('start-brief-state')).toHaveTextContent(state);
    expect(screen.getByTestId('start-brief-updated-at')).toHaveTextContent(FIXED.updated_at);
    expect(screen.getByTestId('start-action-resume')).toBeOnTheScreen();
  });
}

// К2: отзыв ACL — дело исчезло из listMissions → прежнее содержание brief
// и resume убраны, без остаточных приватных строк; присутствие/композер живы.
for (const avatar of AVATARS) {
  it(`108 start ACL_REVOKED_${avatar}`, async () => {
    const view = await harness({ avatarState: avatar, missions: brief('PRESENT') });
    expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(FIXED.mission_id);
    await view.rerender({ missions: brief('EMPTY') });
    expect(screen.queryByTestId('start-resume-brief')).toBeNull();
    expect(screen.queryByTestId('start-action-resume')).toBeNull();
    expect(screen.queryByText(FIXED.mission_id)).toBeNull();
    expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
    expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
    expect(view.calls.mic).toBe(0);
  });
}
for (const avatar of AVATARS) {
  it(`108 start MISSIONS_NULL_${avatar}`, async () => {
    await harness({ avatarState: avatar, missions: null });
    expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
    expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
    expect(screen.queryByTestId('start-resume-brief')).toBeNull();
    expect(screen.queryByTestId('start-action-resume')).toBeNull();
  });
}

// К3: каждое доступное действие × полный вектор эффектов (write/talk/resume/mic)
// × avatar × presence × motion. Доступность: write/talk всегда, resume ⇔ PRESENT.
for (const action of ACTIONS) {
  for (const avatar of AVATARS) {
    for (const presence of PRESENCES) {
      for (const motion of MOTIONS) {
        it(`108 start ACTION_${action}_${avatar}_${presence}_${motion}`, async () => {
          const { calls } = await harness({
            avatarState: avatar,
            missions: brief(presence),
            reducedMotion: motion === 'reduced',
          });
          expect(screen.getByTestId('start-action-write')).toBeOnTheScreen();
          expect(screen.getByTestId('start-action-talk')).toBeOnTheScreen();
          if (action === 'RESUME' && presence === 'EMPTY') {
            // Resume без доступного дела не предлагается и не жмётся.
            expect(screen.queryByTestId('start-action-resume')).toBeNull();
            expect(calls).toEqual({ write: 0, talk: 0, resume: [], mic: 0 });
            return;
          }
          const testID =
            action === 'WRITE' ? 'start-action-write' : action === 'TALK' ? 'start-action-talk' : 'start-action-resume';
          await fireEvent.press(screen.getByTestId(testID));
          expect(calls.mic).toBe(0);
          expect(calls.talk).toBe(action === 'TALK' ? 1 : 0);
          expect(calls.write).toBe(action === 'WRITE' ? 1 : 0);
          if (action === 'RESUME') {
            expect(calls.resume).toEqual([FIXED.mission_id]);
          } else {
            expect(calls.resume).toEqual([]);
          }
          expect(screen.queryByTestId('start-voice-session')).toBeNull();
        });
      }
    }
  }
}

// К4: UI-состояния кадров — CALM (F04.01), INPUT (F04.02 по фокусу композера),
// LISTENING (F04.03 по talk; выход через write к тексту; микрофон молчит).
for (const avatar of AVATARS) {
  it(`108 start FRAME_CALM_${avatar}`, async () => {
    await harness({ avatarState: avatar, missions: brief('PRESENT') });
    expect(screen.getByTestId('start-frame-F04.01')).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.01.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.01.body'])).toBeOnTheScreen();
    expect(screen.queryByTestId('start-frame-F04.02')).toBeNull();
    expect(screen.queryByTestId('start-frame-F04.03')).toBeNull();
  });

  it(`108 start FRAME_INPUT_${avatar}`, async () => {
    await harness({ avatarState: avatar, missions: brief('PRESENT') });
    await fireEvent(screen.getByTestId('start-composer-input'), 'focus');
    expect(screen.getByTestId('start-frame-F04.02')).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.02.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.02.body'])).toBeOnTheScreen();
    expect(screen.queryByTestId('start-frame-F04.01')).toBeNull();
  });

  it(`108 start FRAME_LISTENING_${avatar}`, async () => {
    const { calls } = await harness({ avatarState: avatar, missions: brief('PRESENT') });
    await fireEvent.press(screen.getByTestId('start-action-talk'));
    expect(calls.talk).toBe(1);
    expect(screen.getByTestId('start-frame-F04.03')).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.03.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.03.body'])).toBeOnTheScreen();
    expect(calls.mic).toBe(0);
    expect(calls.resume).toEqual([]);
    // Listening — UI-состояние: бриф на месте, каналы не создали Mission.
    expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(FIXED.mission_id);
    // Выход к тексту — write возвращает из Listening.
    await fireEvent.press(screen.getByTestId('start-action-write'));
    expect(calls.write).toBe(1);
    expect(screen.getByTestId('start-frame-F04.02')).toBeOnTheScreen();
  });
}

// К5: черновик композера сохраняется при смене пропсов и смене канала
// (Maestro: написать → вернуться → продолжить; черновик сохранён).
it('108 start DRAFT_PRESERVED_AVATAR_CHANGE', async () => {
  const view = await harness({ missions: brief('PRESENT') });
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
  await view.rerender({ avatarState: 'working' });
  expect(screen.getByDisplayValue(FIXED.draft_text)).toBeOnTheScreen();
});

it('108 start DRAFT_PRESERVED_ACL_CHANGE', async () => {
  const view = await harness({ missions: brief('PRESENT') });
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
  await view.rerender({ missions: brief('EMPTY') });
  expect(screen.getByDisplayValue(FIXED.draft_text)).toBeOnTheScreen();
});

it('108 start DRAFT_PRESERVED_LISTENING_ROUNDTRIP', async () => {
  const view = await harness({ missions: brief('PRESENT') });
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
  await fireEvent.press(screen.getByTestId('start-action-talk'));
  await fireEvent.press(screen.getByTestId('start-action-write'));
  expect(screen.getByDisplayValue(FIXED.draft_text)).toBeOnTheScreen();
});

// К6: настоящие сценарии @/mocks/start-mock — произведение presence × state.
for (const presence of PRESENCES) {
  for (const state of MISSION_STATES) {
    it(`108 start MOCK_SCENARIO_${presence}_${state}`, () => {
      expect(missionsFor(presence, state)).toEqual(
        presence === 'PRESENT'
          ? [{ mission_id: FIXED.mission_id, state, updated_at: FIXED.updated_at }]
          : [],
      );
    });
  }
}

it('108 start MOCK_SCENARIO_SETTER', () => {
  setScenario('EMPTY', 'WORKING');
  expect(missionsSnapshot().items).toEqual([]);
  setScenario('PRESENT', 'BLOCKED');
  expect(missionsSnapshot().items).toEqual([
    { mission_id: FIXED.mission_id, state: 'BLOCKED', updated_at: FIXED.updated_at },
  ]);
});

// К6: настоящий @/mocks/runtime — операции ApiClient исполняются без
// mock-подмены методов; снимок равен ПОЛНОМУ объявленному типу MissionBrief
// и подаётся в экран (runtime → экран, не app-маршрут).
it('108 start RUNTIME_LIST_EMPTY', async () => {
  setScenario('EMPTY', 'WORKING');
  const page = await runtime.api.listMissions();
  expect(page.items).toEqual([]);
});

it('108 start RUNTIME_LIST_PRESENT', async () => {
  setScenario('PRESENT', 'NEEDS_INFORMATION');
  const page = await runtime.api.listMissions();
  expect(page.items).toEqual([
    { mission_id: FIXED.mission_id, state: 'NEEDS_INFORMATION', updated_at: FIXED.updated_at },
  ]);
});

it('108 start RUNTIME_SESSION_EXECUTES', async () => {
  const session = await runtime.api.getSession();
  expect(session.locale).toBe('de-DE');
});

it('108 start RUNTIME_SNAPSHOT_FULL', async () => {
  setScenario('PRESENT', 'WORKING');
  const page = await runtime.api.listMissions();
  expect(page.items).toHaveLength(1);
  expect(page.items[0]).toEqual({
    mission_id: FIXED.mission_id,
    state: 'WORKING',
    updated_at: FIXED.updated_at,
  });
  const view = await render(<StartScreen missions={page.items} avatarState="idle" />);
  expect(view.getByTestId('start-brief-mission-id')).toHaveTextContent(FIXED.mission_id);
  expect(view.getByTestId('start-brief-state')).toHaveTextContent('WORKING');
});
