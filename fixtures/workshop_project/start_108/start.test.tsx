// Красные тесты 108 (CMP-MOB-004), архитекторская проба Start F04.01–F04.07.
// ОРУКУЛ НЕЗАВИСИМ (правило 8): все ожидаемые значения — литералы этого
// файла, побайтово из source.json (снят с Complior-mob 76ac10fa ДО запуска
// субъекта); проба НЕ импортирует константы значений из @/mocks/start-mock —
// моковский перечень состояний сверяется с оракулом клеткой
// ORACLE_MISSION_STATES. Клетки порождаются циклами по закрытой грамматике
// (avatar × presence × motion; ui_state × action × admission; mission_state ×
// motion; mission_state × mission_state), не ручным списком.
// Оси 107 (арбитраж К5′–К9′) и оси круга 1 критика 108 применены:
//  - полное произведение состояний × доступности × движения на НАЧАЛЬНОМ
//    рендере (К1) и на ДОСТИГНУТЫХ UI-состояниях INPUT/LISTENING (К1′);
//  - каждое действие × полный вектор эффектов ПОСЛЕ КАЖДОГО ШАГА: из CALM
//    (К3), из каждого ui_state × admission включая null (К3′ ACTION_FROM),
//    resume по всем mission_states × motion (RESUME_EFFECT);
//  - переходы, а не только начальный render: отзыв ACL в CALM и в LISTENING,
//    PRESENT→null, обновление снимка при неизменной кардинальности — все
//    упорядоченные пары состояний (SNAPSHOT_REFRESH);
//  - поля брифа читаются из ПОДАННОГО снимка: различающая пара ALT
//    (BRIEF_FIELDS_FROM_PORT), не фиксированные строки;
//  - настоящий runtime.api.listMissions по всем сценариям presence × state;
//  - черновик переживает все переходы avatar (произведение from×to) и
//    admission (EMPTY/NULL), а не только idle→working;
//  - кадр F04.06 наблюдается текстом каталога в каждом BRIEF_STATE.
// Паттерн await render/await fireEvent — прецедент rehearsal.test.tsx (RNTL 14).
import { act, fireEvent, render, screen } from '@testing-library/react-native';
import React from 'react';

import { StartScreen } from '@/features/start/start-screen';
import type { MissionBrief, MissionState } from '@/api/api-client';
import type { AvatarState } from '@/ui/agent-presence/agent-presence';
import { MISSION_STATES as MOCK_MISSION_STATES, missionsFor, missionsSnapshot, setScenario } from '@/mocks/start-mock';
import { runtime } from '@/mocks/runtime';

const AVATARS: readonly AvatarState[] = ['idle', 'working', 'unavailable'];
const PRESENCES = ['EMPTY', 'PRESENT'] as const;
const MOTIONS = ['full', 'reduced'] as const;
const ACTIONS = ['WRITE', 'TALK', 'RESUME'] as const;
const UI_STATES = ['CALM', 'INPUT', 'LISTENING'] as const;
const ADMISSIONS = ['EMPTY', 'PRESENT', 'NULL'] as const;

// Оракул (source.json): литералы теста, НЕ перечень субъекта.
const ORACLE_STATES: readonly MissionState[] = [
  'RECEIVED', 'WORKING', 'NEEDS_INFORMATION', 'ADVISER_REVIEW',
  'NEEDS_APPROVAL', 'WAITING_EXTERNAL', 'COMPLETED', 'PARTIAL',
  'BLOCKED', 'CANCELLED',
];
const MISSION_STATES = ORACLE_STATES;

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

// fixed из source.json литералами: ожидания НЕ берутся у субъекта (мока).
const FIXED = {
  mission_id: 'MIS-CAR-01',
  updated_at: '2026-10-09T12:00:00Z',
  draft_text: 'Kfz-Rechner Frage',
};
// Различающая пара входов (зависимость полей от поданного снимка): значения,
// не совпадающие ни с одним полем fixed.
const ALT = { mission_id: 'MIS-OTHER-02', state: 'RECEIVED', updated_at: '2026-10-19T10:11:12Z' };

function brief(presence: 'EMPTY' | 'PRESENT', state: MissionState = 'WORKING'): MissionBrief[] {
  return presence === 'PRESENT'
    ? [{ mission_id: FIXED.mission_id, state, updated_at: FIXED.updated_at }]
    : [];
}

function admissionMissions(admission: 'EMPTY' | 'PRESENT' | 'NULL'): MissionBrief[] | null {
  if (admission === 'PRESENT') return brief('PRESENT');
  if (admission === 'EMPTY') return [];
  return null;
}

const ZERO_EFFECTS = { write: 0, talk: 0, resume: [] as string[], mic: 0 };

async function harness(props: Partial<Parameters<typeof StartScreen>[0]> = {}) {
  const calls = { ...ZERO_EFFECTS, resume: [] as string[] };
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

async function reachUiState(ui: 'CALM' | 'INPUT' | 'LISTENING') {
  if (ui === 'INPUT') {
    await fireEvent(screen.getByTestId('start-composer-input'), 'focus');
  } else if (ui === 'LISTENING') {
    await fireEvent.press(screen.getByTestId('start-action-talk'));
  }
}

// К1: произведение avatar × presence × motion на начальном рендере —
// присутствие есть всегда, ровно один композер, ≤1 контекстная карточка,
// empty-groups/KPI/voice-session отсутствуют, unavailable не выглядит
// работающим процессом, слоты стабильны.
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

// К1′: то же произведение присутствия/запрещённых элементов на ДОСТИГНУТОМ
// UI-состоянии (после взаимодействия: фокус композера / talk) — структура
// наблюдается ПОСЛЕ смены UI-state, не только до взаимодействия.
for (const ui of ['INPUT', 'LISTENING'] as const) {
  for (const avatar of AVATARS) {
    for (const presence of PRESENCES) {
      for (const motion of MOTIONS) {
        it(`108 start STRUCTURE_AFTER_${ui}_${avatar}_${presence}_${motion}`, async () => {
          const { calls } = await harness({
            avatarState: avatar,
            missions: brief(presence),
            reducedMotion: motion === 'reduced',
          });
          await reachUiState(ui);
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
          expect(calls.mic).toBe(0);
          expect(calls.resume).toEqual([]);
        });
      }
    }
  }
}

// Оракул: перечень состояний мока равен оракулу source.json (мок не несёт
// собственной грамматики; циклы этого файла идут по ORACLE_STATES).
it('108 start ORACLE_MISSION_STATES', () => {
  expect([...MOCK_MISSION_STATES]).toEqual([...ORACLE_STATES]);
});

// К2: бриф показывает полное состояние дела (все 10 значений OpenAPI-enum)
// и кадр F04.06 — текстом каталога (title+body), не только testID.
for (const state of MISSION_STATES) {
  it(`108 start BRIEF_STATE_${state}`, async () => {
    await harness({ missions: brief('PRESENT', state) });
    expect(screen.getByTestId('start-brief-state')).toHaveTextContent(state);
    expect(screen.getByTestId('start-brief-updated-at')).toHaveTextContent(FIXED.updated_at);
    expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(FIXED.mission_id);
    expect(screen.getByText(TEXTS['frame.F04.06.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.06.body'])).toBeOnTheScreen();
    expect(screen.getByTestId('start-action-resume')).toBeOnTheScreen();
  });
}

// К2′: зависимость полей брифа от ПОДАННОГО снимка — различающая пара ALT:
// поданный снимок с чужими mission_id/state/updated_at отражается дословно,
// resume-аргумент равен поданному mission_id (фиксированные строки ловятся).
it('108 start BRIEF_FIELDS_FROM_PORT', async () => {
  const { calls } = await harness({
    missions: [{ mission_id: ALT.mission_id, state: ALT.state, updated_at: ALT.updated_at }],
  });
  expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(ALT.mission_id);
  expect(screen.getByTestId('start-brief-state')).toHaveTextContent(ALT.state);
  expect(screen.getByTestId('start-brief-updated-at')).toHaveTextContent(ALT.updated_at);
  await fireEvent.press(screen.getByTestId('start-action-resume'));
  expect(calls).toEqual({ write: 0, talk: 0, resume: [ALT.mission_id], mic: 0 });
});

// К2″: resume-эффект по произведению mission_state × motion — полный вектор
// (resume=[поданный mission_id], write/talk/mic нулевые) в каждой клетке.
for (const state of MISSION_STATES) {
  for (const motion of MOTIONS) {
    it(`108 start RESUME_EFFECT_${state}_${motion}`, async () => {
      const { calls } = await harness({
        missions: brief('PRESENT', state),
        reducedMotion: motion === 'reduced',
      });
      await fireEvent.press(screen.getByTestId('start-action-resume'));
      expect(calls).toEqual({ write: 0, talk: 0, resume: [FIXED.mission_id], mic: 0 });
    });
  }
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

// К2‴: отзыв ACL на ДОСТИГНУТОМ UI-состоянии — переход PRESENT→EMPTY в
// LISTENING тоже убирает прежнее содержание brief/resume/mission_id
// (переключение канала не продлевает протухший ACL-снимок).
for (const avatar of AVATARS) {
  it(`108 start ACL_REVOKED_LISTENING_${avatar}`, async () => {
    const view = await harness({ avatarState: avatar, missions: brief('PRESENT') });
    await fireEvent.press(screen.getByTestId('start-action-talk'));
    await view.rerender({ missions: [] });
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

// К8′: ПЕРЕХОД PRESENT→null (listMissions стал недоступен) — безопасный
// fallback без остаточной приватной карточки, присутствие/композер живы.
for (const avatar of AVATARS) {
  it(`108 start MISSIONS_NULL_TRANSITION_${avatar}`, async () => {
    const view = await harness({ avatarState: avatar, missions: brief('PRESENT') });
    await view.rerender({ missions: null });
    expect(screen.queryByTestId('start-resume-brief')).toBeNull();
    expect(screen.queryByTestId('start-action-resume')).toBeNull();
    expect(screen.queryByText(FIXED.mission_id)).toBeNull();
    expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
    expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
  });
}

// К3: каждое доступное действие × полный вектор эффектов (write/talk/resume/mic)
// × avatar × presence × motion из CALM. Доступность: write/talk всегда,
// resume ⇔ PRESENT.
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

// К3′: замыкание произведения — действие × ДОСТИГНУТОЕ ui_state × admission
// (EMPTY/PRESENT/NULL). Полный вектор эффектов проверяется ПОСЛЕ достижения
// UI-состояния и ПОСЛЕ действия (порядок событий: эффект до последнего
// действия не доказывает отсутствие эффекта после него).
for (const ui of UI_STATES) {
  for (const action of ACTIONS) {
    for (const admission of ADMISSIONS) {
      it(`108 start ACTION_FROM_${ui}_${action}_${admission}`, async () => {
        const { calls } = await harness({ missions: admissionMissions(admission) });
        await reachUiState(ui);
        // Полный вектор ПОСЛЕ достижения UI-состояния, ДО действия.
        expect(calls).toEqual({ ...ZERO_EFFECTS, talk: ui === 'LISTENING' ? 1 : 0 });
        if (action === 'RESUME' && admission !== 'PRESENT') {
          // Resume без доступного дела не предлагается и не жмётся.
          expect(screen.queryByTestId('start-action-resume')).toBeNull();
          expect(calls).toEqual({ ...ZERO_EFFECTS, talk: ui === 'LISTENING' ? 1 : 0 });
          return;
        }
        const testID =
          action === 'WRITE' ? 'start-action-write' : action === 'TALK' ? 'start-action-talk' : 'start-action-resume';
        await fireEvent.press(screen.getByTestId(testID));
        // Полный вектор ПОСЛЕ действия: только свой эффект, mic всегда 0.
        expect(calls).toEqual({
          write: action === 'WRITE' ? 1 : 0,
          talk: (ui === 'LISTENING' ? 1 : 0) + (action === 'TALK' ? 1 : 0),
          resume: action === 'RESUME' ? [FIXED.mission_id] : [],
          mic: 0,
        });
        expect(screen.queryByTestId('start-voice-session')).toBeNull();
      });
    }
  }
}

// К3″: обновление снимка при неизменной кардинальности — все упорядоченные
// пары состояний: экран показывает ПОДАННОЕ состояние после rerender,
// не удержанный прежний снимок (равная длина массива не маскирует смену).
for (const from of MISSION_STATES) {
  for (const to of MISSION_STATES) {
    if (from === to) continue;
    it(`108 start SNAPSHOT_REFRESH_${from}_${to}`, async () => {
      const view = await harness({ missions: brief('PRESENT', from) });
      expect(screen.getByTestId('start-brief-state')).toHaveTextContent(from);
      await view.rerender({ missions: brief('PRESENT', to) });
      expect(screen.getByTestId('start-brief-state')).toHaveTextContent(to);
      expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(FIXED.mission_id);
      expect(screen.getByTestId('start-brief-updated-at')).toHaveTextContent(FIXED.updated_at);
    });
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
    // Выход к тексту — write возвращает из Listening; полный вектор
    // эффектов проверен ПОСЛЕ выхода (не только до него).
    await fireEvent.press(screen.getByTestId('start-action-write'));
    expect(screen.getByTestId('start-frame-F04.02')).toBeOnTheScreen();
    expect(calls).toEqual({ write: 1, talk: 1, resume: [], mic: 0 });
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
  await harness({ missions: brief('PRESENT') });
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
  await fireEvent.press(screen.getByTestId('start-action-talk'));
  await fireEvent.press(screen.getByTestId('start-action-write'));
  expect(screen.getByDisplayValue(FIXED.draft_text)).toBeOnTheScreen();
});

// К5′: черновик переживает ВСЕ переходы avatarState (произведение from×to,
// включая unavailable — F04.V03 сохраняет контекст) и admission-переходы
// (EMPTY и NULL — отзыв ACL/недоступность listMissions).
for (const from of AVATARS) {
  for (const to of AVATARS) {
    if (from === to) continue;
    it(`108 start DRAFT_AVATAR_${from}_TO_${to}`, async () => {
      const view = await harness({ avatarState: from, missions: brief('PRESENT') });
      await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
      await view.rerender({ avatarState: to });
      expect(screen.getByDisplayValue(FIXED.draft_text)).toBeOnTheScreen();
    });
  }
}

for (const to of ['EMPTY', 'NULL'] as const) {
  it(`108 start DRAFT_ADMISSION_${to}`, async () => {
    const view = await harness({ missions: brief('PRESENT') });
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
    await view.rerender({ missions: to === 'EMPTY' ? [] : null });
    expect(screen.getByDisplayValue(FIXED.draft_text)).toBeOnTheScreen();
  });
}

// К6: настоящие сценарии @/mocks/start-mock — произведение presence × state;
// ожидания — литералы оракула, НЕ экспорты мока.
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

// К6′: настоящий @/mocks/runtime.api.listMissions по ВСЕМ сценариям
// presence × state — runtime-шов не искажает заявленный снимок ни в одном
// состоянии (не только в избранных сценариях).
for (const presence of PRESENCES) {
  for (const state of MISSION_STATES) {
    it(`108 start RUNTIME_SCENARIO_${presence}_${state}`, async () => {
      setScenario(presence, state);
      const page = await runtime.api.listMissions();
      expect(page.items).toEqual(
        presence === 'PRESENT'
          ? [{ mission_id: FIXED.mission_id, state, updated_at: FIXED.updated_at }]
          : [],
      );
    });
  }
}

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
