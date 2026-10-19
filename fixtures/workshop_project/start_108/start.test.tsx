// Красные тесты 108 (CMP-MOB-004), архитекторская проба Start F04.01–F04.07.
// ОРУКУЛ НЕЗАВИСИМ (правило 8): все ожидаемые значения — литералы этого
// файла, побайтово из source.json (снят с Complior-mob 76ac10fa ДО запуска
// субъекта); проба НЕ импортирует константы значений из @/mocks/start-mock —
// моковский перечень состояний сверяется с оракулом клеткой
// ORACLE_MISSION_STATES. Клетки порождаются циклами по закрытой грамматике
// (avatar × presence × motion; ui_state × action × admission; mission_state ×
// motion; mission_state × mission_state), не ручным списком.
// Круг 4 (ось D круга 3): ожидания читают ТОЛЬКО блок литералов EXPECT —
// ни одна клетка не сверяется объектом/полем, поданным продукту (alias-
// мутация входа продуктом не меняет оракул; декои input-alias-* в матрице).
// Оси 107 (арбитраж К5′–К9′), оси круга 1 критика 108 и ЗАКРЫТЫЙ перечень
// арбитража 108 (verdicts/arbitration/contracts-108-pravila-e-p-v1.md,
// Решение 2) применены двумя правилами на ВЕСЬ тест:
//  - ПРАВИЛО Э (эффекты): каждая клетка, выполняющая хотя бы один шаг
//    (press/focus/changeText/rerender), заканчивается toEqual ПОЛНОГО
//    вектора эффектов {write, talk, resume, mic};
//  - ПРАВИЛО П (поля): каждая клетка, где brief ожидаем видимым, сверяет
//    ВСЕ три поля (mission_id/state/updated_at) exact-литералом И наличие
//    start-action-resume; где невидимым — тройное отсутствие
//    (start-resume-brief/start-action-resume/queryByText(mission_id));
//  - A SNAPSHOT_REFRESH — ПОЛНЫЙ квадрат 10×10 упорядоченных пар состояний,
//    включая диагональ from===to (повторный снимок — штатное событие),
//    без ручных исключений из цикла;
//  - B ADMISSION_LOST — произведение ui(3) × to{EMPTY,NULL} × avatar(3);
//    растворяет ACL_REVOKED/ACL_REVOKED_LISTENING/MISSIONS_NULL_TRANSITION;
//  - D BRIEF_FIELDS — произведение ЗНАЧЕНИЙ полей {FIXED,ALT}^3 = 8
//    (смешанные поля внутри перечня, К5′ прецедента 107);
//  - E RUNTIME_SCENARIO — page.items подаётся в экран БЕЗ обработчиков
//    (путь runtime → экран, правило П), как RUNTIME_SNAPSHOT_FULL;
//  - каждое действие × полный вектор эффектов ПОСЛЕ КАЖДОГО ШАГА: из CALM
//    (К3), из каждого ui_state × admission включая null (К3′ ACTION_FROM),
//    resume по всем mission_states × motion (RESUME_EFFECT);
//  - переходы, а не только начальный render: потеря доступа на достигнутом
//    ui-состоянии (ADMISSION_LOST), обновление снимка при неизменной
//    кардинальности (SNAPSHOT_REFRESH);
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

// Произведение ЗНАЧЕНИЙ полей брифа (К2′, арбитраж 108 D): каждое поле
// берётся из {FIXED, ALT} независимо от остальных.
const FIELD_PICKS = ['FIXED', 'ALT'] as const;
type FieldPick = (typeof FIELD_PICKS)[number];
const FIELD_VALUES: Record<'mission_id' | 'state' | 'updated_at', Record<FieldPick, string>> = {
  mission_id: { FIXED: FIXED.mission_id, ALT: ALT.mission_id },
  state: { FIXED: 'WORKING', ALT: ALT.state },
  updated_at: { FIXED: FIXED.updated_at, ALT: ALT.updated_at },
};

// Оракул ожиданий (круг 4, ось D круга 3 / урок 107 К9′(б)): литералы
// выписаны ОТДЕЛЬНО от входов. Вход продукту собирают FIXED/ALT/FIELD_VALUES
// и brief(); ожидание читает ТОЛЬКО EXPECT — alias-мутация поданного снимка
// продуктом (Object.assign входа) не может изменить ожидание клетки.
const EXPECT = {
  brief: { mission_id: 'MIS-CAR-01', updated_at: '2026-10-09T12:00:00Z' },
  draft: 'Kfz-Rechner Frage',
  fields: {
    mission_id: { FIXED: 'MIS-CAR-01', ALT: 'MIS-OTHER-02' },
    state: { FIXED: 'WORKING', ALT: 'RECEIVED' },
    updated_at: { FIXED: '2026-10-09T12:00:00Z', ALT: '2026-10-19T10:11:12Z' },
  },
};

// Ожидаемый бриф: литералы EXPECT (+ параметр клетки), НЕ вход продукту.
function expectedBrief(state: MissionState = 'WORKING'): MissionBrief {
  return { mission_id: EXPECT.brief.mission_id, state, updated_at: EXPECT.brief.updated_at };
}

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
type Effects = typeof ZERO_EFFECTS;

// ПРАВИЛО Э (арбитраж 108): клетка с шагом заканчивается ПОЛНЫМ вектором
// эффектов {write, talk, resume, mic} — чтение части вектора не допускается.
function expectEffects(calls: Effects, expected: Effects) {
  expect(calls).toEqual(expected);
}

// ПРАВИЛО П (арбитраж 108): видимый бриф — ВСЕ три поля exact-литералом
// (FIXED/ALT/состояние клетки) И наличие start-action-resume; невидимый —
// тройное отсутствие, включая остаточные приватные строки (queryByText).
function expectBriefVisible(expected: MissionBrief) {
  expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(expected.mission_id, { exact: true });
  expect(screen.getByTestId('start-brief-state')).toHaveTextContent(expected.state, { exact: true });
  expect(screen.getByTestId('start-brief-updated-at')).toHaveTextContent(expected.updated_at, { exact: true });
  expect(screen.getByTestId('start-action-resume')).toBeOnTheScreen();
}

function expectBriefAbsent(missionId: string) {
  expect(screen.queryByTestId('start-resume-brief')).toBeNull();
  expect(screen.queryByTestId('start-action-resume')).toBeNull();
  expect(screen.queryByText(missionId)).toBeNull();
}

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
// работающим процессом, слоты стабильны. Правило П в каждой клетке.
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
          expectBriefVisible(expectedBrief());
        } else {
          expectBriefAbsent(EXPECT.brief.mission_id);
          expect(screen.queryByTestId('start-contextual-card')).toBeNull();
        }
      });
    }
  }
}

// К1′: то же произведение присутствия/запрещённых элементов на ДОСТИГНУТОМ
// UI-состоянии (после взаимодействия: фокус композера / talk) — структура
// наблюдается ПОСЛЕ смены UI-state, не только до взаимодействия.
// Правила Э (полный вектор после шага) и П.
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
            expectBriefVisible(expectedBrief());
          } else {
            expectBriefAbsent(EXPECT.brief.mission_id);
            expect(screen.queryByTestId('start-contextual-card')).toBeNull();
          }
          expectEffects(calls, { ...ZERO_EFFECTS, talk: ui === 'LISTENING' ? 1 : 0 });
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
// Правило П: все три поля exact-литералом.
for (const state of MISSION_STATES) {
  it(`108 start BRIEF_STATE_${state}`, async () => {
    await harness({ missions: brief('PRESENT', state) });
    expectBriefVisible(expectedBrief(state));
    expect(screen.getByText(TEXTS['frame.F04.06.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.06.body'])).toBeOnTheScreen();
  });
}

// К2′ (арбитраж 108 D): зависимость полей брифа от ПОДАННОГО снимка —
// произведение ЗНАЧЕНИЙ полей {FIXED, ALT}^3 = 8 клеток (смешанные поля
// внутри перечня: одна ALT-пара доказывает 2 точки из 8). Вход собирает
// FIELD_VALUES, ожидание — ТОЛЬКО литералы EXPECT.fields (ось D круга 3:
// объект входа не служит оракулом); правило П по поданному снимку и
// правило Э после нажатия resume (resume-аргумент = поданный mission_id).
for (const id of FIELD_PICKS) {
  for (const st of FIELD_PICKS) {
    for (const ts of FIELD_PICKS) {
      it(`108 start BRIEF_FIELDS_${id}_${st}_${ts}`, async () => {
        // Вход продукту — FIELD_VALUES; ожидание — литералы EXPECT.fields:
        // объект входа никогда не служит оракулом (ось D круга 3 критика).
        const input: MissionBrief = {
          mission_id: FIELD_VALUES.mission_id[id],
          state: FIELD_VALUES.state[st] as MissionState,
          updated_at: FIELD_VALUES.updated_at[ts],
        };
        const expected: MissionBrief = {
          mission_id: EXPECT.fields.mission_id[id],
          state: EXPECT.fields.state[st] as MissionState,
          updated_at: EXPECT.fields.updated_at[ts],
        };
        const { calls } = await harness({ missions: [input] });
        expectBriefVisible(expected);
        await fireEvent.press(screen.getByTestId('start-action-resume'));
        expectEffects(calls, { ...ZERO_EFFECTS, resume: [expected.mission_id] });
      });
    }
  }
}

// К2″: resume-эффект по произведению mission_state × motion — полный вектор
// (resume=[поданный mission_id], write/talk/mic нулевые) в каждой клетке;
// правило П до нажатия.
for (const state of MISSION_STATES) {
  for (const motion of MOTIONS) {
    it(`108 start RESUME_EFFECT_${state}_${motion}`, async () => {
      const { calls } = await harness({
        missions: brief('PRESENT', state),
        reducedMotion: motion === 'reduced',
      });
      expectBriefVisible(expectedBrief(state));
      await fireEvent.press(screen.getByTestId('start-action-resume'));
      expectEffects(calls, { write: 0, talk: 0, resume: [EXPECT.brief.mission_id], mic: 0 });
    });
  }
}

// К8: null при первом render — безопасный fallback: присутствие и композер
// живы, карточки нет (правило П — тройное отсутствие).
for (const avatar of AVATARS) {
  it(`108 start MISSIONS_NULL_${avatar}`, async () => {
    await harness({ avatarState: avatar, missions: null });
    expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
    expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
    expectBriefAbsent(EXPECT.brief.mission_id);
  });
}

// К2″′ ∪ К8 (арбитраж 108 B): потеря доступа на ДОСТИГНУТОМ ui-состоянии —
// произведение ui(3) × to{EMPTY,NULL} × avatar(3). Растворяет прежние
// ACL_REVOKED / ACL_REVOKED_LISTENING / MISSIONS_NULL_TRANSITION: дело
// исчезло из listMissions (отзыв ACL) или listMissions стал недоступен —
// прежнее содержание brief/resume/mission_id убрано на ЛЮБОМ достигнутом
// ui-состоянии, без остаточных приватных строк; присутствие/композер живы.
// Правило Э: полный вектор ПОСЛЕ перехода (talk=1 только если достигали
// LISTENING — сам переход эффектов не добавляет).
for (const ui of UI_STATES) {
  for (const to of ['EMPTY', 'NULL'] as const) {
    for (const avatar of AVATARS) {
      it(`108 start ADMISSION_LOST_${ui}_${to}_${avatar}`, async () => {
        const view = await harness({ avatarState: avatar, missions: brief('PRESENT') });
        await reachUiState(ui);
        await view.rerender({ missions: to === 'EMPTY' ? [] : null });
        expectBriefAbsent(EXPECT.brief.mission_id);
        expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
        expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
        expectEffects(view.calls, { ...ZERO_EFFECTS, talk: ui === 'LISTENING' ? 1 : 0 });
      });
    }
  }
}

// К3: каждое доступное действие × полный вектор эффектов (write/talk/resume/mic)
// × avatar × presence × motion из CALM. Доступность: write/talk всегда,
// resume ⇔ PRESENT. Правила П (по presence) и Э (полный вектор ПОСЛЕ действия).
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
          if (presence === 'PRESENT') {
            expectBriefVisible(expectedBrief());
          } else {
            expectBriefAbsent(EXPECT.brief.mission_id);
          }
          if (action === 'RESUME' && presence === 'EMPTY') {
            // Resume без доступного дела не предлагается и не жмётся.
            expect(screen.queryByTestId('start-action-resume')).toBeNull();
            expectEffects(calls, { ...ZERO_EFFECTS });
            return;
          }
          const testID =
            action === 'WRITE' ? 'start-action-write' : action === 'TALK' ? 'start-action-talk' : 'start-action-resume';
          await fireEvent.press(screen.getByTestId(testID));
          expect(screen.queryByTestId('start-voice-session')).toBeNull();
          expectEffects(calls, {
            write: action === 'WRITE' ? 1 : 0,
            talk: action === 'TALK' ? 1 : 0,
            resume: action === 'RESUME' ? [EXPECT.brief.mission_id] : [],
            mic: 0,
          });
        });
      }
    }
  }
}

// К3′: замыкание произведения — действие × ДОСТИГНУТОЕ ui_state × admission
// (EMPTY/PRESENT/NULL). Полный вектор эффектов проверяется ПОСЛЕ достижения
// UI-состояния и ПОСЛЕ действия (порядок событий: эффект до последнего
// действия не доказывает отсутствие эффекта после него). Правило П по
// достигнутому состоянию до действия.
for (const ui of UI_STATES) {
  for (const action of ACTIONS) {
    for (const admission of ADMISSIONS) {
      it(`108 start ACTION_FROM_${ui}_${action}_${admission}`, async () => {
        const { calls } = await harness({ missions: admissionMissions(admission) });
        await reachUiState(ui);
        // Полный вектор ПОСЛЕ достижения UI-состояния, ДО действия.
        expectEffects(calls, { ...ZERO_EFFECTS, talk: ui === 'LISTENING' ? 1 : 0 });
        if (admission === 'PRESENT') {
          expectBriefVisible(expectedBrief());
        } else {
          expectBriefAbsent(EXPECT.brief.mission_id);
        }
        if (action === 'RESUME' && admission !== 'PRESENT') {
          // Resume без доступного дела не предлагается и не жмётся.
          expect(screen.queryByTestId('start-action-resume')).toBeNull();
          expectEffects(calls, { ...ZERO_EFFECTS, talk: ui === 'LISTENING' ? 1 : 0 });
          return;
        }
        const testID =
          action === 'WRITE' ? 'start-action-write' : action === 'TALK' ? 'start-action-talk' : 'start-action-resume';
        await fireEvent.press(screen.getByTestId(testID));
        // Полный вектор ПОСЛЕ действия: только свой эффект, mic всегда 0.
        expect(screen.queryByTestId('start-voice-session')).toBeNull();
        expectEffects(calls, {
          write: action === 'WRITE' ? 1 : 0,
          talk: (ui === 'LISTENING' ? 1 : 0) + (action === 'TALK' ? 1 : 0),
          resume: action === 'RESUME' ? [EXPECT.brief.mission_id] : [],
          mic: 0,
        });
      });
    }
  }
}

// К3″ (арбитраж 108 A): обновление снимка при неизменной кардинальности —
// ПОЛНЫЙ квадрат 10×10 упорядоченных пар состояний, ВКЛЮЧАЯ диагональ
// from===to (повторный снимок того же состояния — штатное событие
// listMissions; ручные исключения из цикла не допускаются). Правило П до и
// после rerender (поданный снимок отражается дословно), правило Э после
// (смена снимка — не действие пользователя, вектор нулевой).
for (const from of MISSION_STATES) {
  for (const to of MISSION_STATES) {
    it(`108 start SNAPSHOT_REFRESH_${from}_${to}`, async () => {
      const view = await harness({ missions: brief('PRESENT', from) });
      expectBriefVisible(expectedBrief(from));
      await view.rerender({ missions: brief('PRESENT', to) });
      expectBriefVisible(expectedBrief(to));
      expectEffects(view.calls, { ...ZERO_EFFECTS });
    });
  }
}

// К4: UI-состояния кадров — CALM (F04.01), INPUT (F04.02 по фокусу композера),
// LISTENING (F04.03 по talk; выход через write к тексту; микрофон молчит).
// Правило П (бриф на месте во всех кадрах), правило Э после шагов.
for (const avatar of AVATARS) {
  it(`108 start FRAME_CALM_${avatar}`, async () => {
    await harness({ avatarState: avatar, missions: brief('PRESENT') });
    expect(screen.getByTestId('start-frame-F04.01')).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.01.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.01.body'])).toBeOnTheScreen();
    expect(screen.queryByTestId('start-frame-F04.02')).toBeNull();
    expect(screen.queryByTestId('start-frame-F04.03')).toBeNull();
    expectBriefVisible(expectedBrief());
  });

  it(`108 start FRAME_INPUT_${avatar}`, async () => {
    const { calls } = await harness({ avatarState: avatar, missions: brief('PRESENT') });
    await fireEvent(screen.getByTestId('start-composer-input'), 'focus');
    expect(screen.getByTestId('start-frame-F04.02')).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.02.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.02.body'])).toBeOnTheScreen();
    expect(screen.queryByTestId('start-frame-F04.01')).toBeNull();
    expectBriefVisible(expectedBrief());
    expectEffects(calls, { ...ZERO_EFFECTS });
  });

  it(`108 start FRAME_LISTENING_${avatar}`, async () => {
    const { calls } = await harness({ avatarState: avatar, missions: brief('PRESENT') });
    await fireEvent.press(screen.getByTestId('start-action-talk'));
    expect(screen.getByTestId('start-frame-F04.03')).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.03.title'])).toBeOnTheScreen();
    expect(screen.getByText(TEXTS['frame.F04.03.body'])).toBeOnTheScreen();
    // Listening — чистое UI-состояние: бриф на месте (правило П), каналы
    // не создали конкурирующую Mission.
    expectBriefVisible(expectedBrief());
    // Выход к тексту — write возвращает из Listening; полный вектор
    // эффектов проверен ПОСЛЕ выхода (правило Э).
    await fireEvent.press(screen.getByTestId('start-action-write'));
    expect(screen.getByTestId('start-frame-F04.02')).toBeOnTheScreen();
    expectEffects(calls, { write: 1, talk: 1, resume: [], mic: 0 });
  });
}

// К5: черновик композера сохраняется при смене пропсов и смене канала
// (Maestro: написать → вернуться → продолжить; черновик сохранён).
// Правила П и Э в каждой клетке.
it('108 start DRAFT_PRESERVED_AVATAR_CHANGE', async () => {
  const view = await harness({ missions: brief('PRESENT') });
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
  await view.rerender({ avatarState: 'working' });
  expect(screen.getByDisplayValue(EXPECT.draft)).toBeOnTheScreen();
  expectBriefVisible(expectedBrief());
  expectEffects(view.calls, { ...ZERO_EFFECTS });
});

it('108 start DRAFT_PRESERVED_ACL_CHANGE', async () => {
  const view = await harness({ missions: brief('PRESENT') });
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
  await view.rerender({ missions: brief('EMPTY') });
  expect(screen.getByDisplayValue(EXPECT.draft)).toBeOnTheScreen();
  expectBriefAbsent(EXPECT.brief.mission_id);
  expectEffects(view.calls, { ...ZERO_EFFECTS });
});

it('108 start DRAFT_PRESERVED_LISTENING_ROUNDTRIP', async () => {
  const { calls } = await harness({ missions: brief('PRESENT') });
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
  await fireEvent.press(screen.getByTestId('start-action-talk'));
  await fireEvent.press(screen.getByTestId('start-action-write'));
  expect(screen.getByDisplayValue(EXPECT.draft)).toBeOnTheScreen();
  expectBriefVisible(expectedBrief());
  expectEffects(calls, { write: 1, talk: 1, resume: [], mic: 0 });
});

// К5′: черновик переживает ВСЕ переходы avatarState (произведение from×to,
// включая unavailable — F04.V03 сохраняет контекст) и admission-переходы
// (EMPTY и NULL — отзыв ACL/недоступность listMissions). Правила П и Э.
for (const from of AVATARS) {
  for (const to of AVATARS) {
    if (from === to) continue;
    it(`108 start DRAFT_AVATAR_${from}_TO_${to}`, async () => {
      const view = await harness({ avatarState: from, missions: brief('PRESENT') });
      await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
      await view.rerender({ avatarState: to });
      expect(screen.getByDisplayValue(EXPECT.draft)).toBeOnTheScreen();
      expectBriefVisible(expectedBrief());
      expectEffects(view.calls, { ...ZERO_EFFECTS });
    });
  }
}

for (const to of ['EMPTY', 'NULL'] as const) {
  it(`108 start DRAFT_ADMISSION_${to}`, async () => {
    const view = await harness({ missions: brief('PRESENT') });
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), FIXED.draft_text);
    await view.rerender({ missions: to === 'EMPTY' ? [] : null });
    expect(screen.getByDisplayValue(EXPECT.draft)).toBeOnTheScreen();
    expectBriefAbsent(EXPECT.brief.mission_id);
    expectEffects(view.calls, { ...ZERO_EFFECTS });
  });
}

// К6: настоящие сценарии @/mocks/start-mock — произведение presence × state;
// ожидания — литералы оракула, НЕ экспорты мока.
for (const presence of PRESENCES) {
  for (const state of MISSION_STATES) {
    it(`108 start MOCK_SCENARIO_${presence}_${state}`, () => {
      expect(missionsFor(presence, state)).toEqual(
        presence === 'PRESENT'
          ? [{ mission_id: EXPECT.brief.mission_id, state, updated_at: EXPECT.brief.updated_at }]
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
    { mission_id: EXPECT.brief.mission_id, state: 'BLOCKED', updated_at: EXPECT.brief.updated_at },
  ]);
});

// К6′ (арбитраж 108 E): настоящий @/mocks/runtime.api.listMissions по ВСЕМ
// сценариям presence × state — runtime-шов не искажает заявленный снимок ни
// в одном состоянии; тот же page.items подаётся в экран БЕЗ onResume и
// обработчиков (как RUNTIME_SNAPSHOT_FULL — путь runtime → экран), правило
// П: PRESENT — все три поля exact по state, EMPTY — тройное отсутствие.
for (const presence of PRESENCES) {
  for (const state of MISSION_STATES) {
    it(`108 start RUNTIME_SCENARIO_${presence}_${state}`, async () => {
      setScenario(presence, state);
      const page = await runtime.api.listMissions();
      expect(page.items).toEqual(
        presence === 'PRESENT'
          ? [{ mission_id: EXPECT.brief.mission_id, state, updated_at: EXPECT.brief.updated_at }]
          : [],
      );
      await render(<StartScreen missions={page.items} avatarState="idle" />);
      if (presence === 'PRESENT') {
        expectBriefVisible(expectedBrief(state));
      } else {
        expectBriefAbsent(EXPECT.brief.mission_id);
      }
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
    { mission_id: EXPECT.brief.mission_id, state: 'NEEDS_INFORMATION', updated_at: EXPECT.brief.updated_at },
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
    mission_id: EXPECT.brief.mission_id,
    state: 'WORKING',
    updated_at: EXPECT.brief.updated_at,
  });
  await render(<StartScreen missions={page.items} avatarState="idle" />);
  // Правило П: все три поля после render — путь runtime → экран несёт
  // updated_at так же, как mission_id и state (без обработчиков).
  expectBriefVisible(expectedBrief());
});
