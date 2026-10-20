// Красные тесты 108 — route-уровень (пост-заморозочное усиление гейта по
// вердиктам судей круга 1, contracts-108-impl-v1; прецедент 107 e8a55b9cf —
// erstinfo-route.test.tsx). Рендерится НАСТОЯЩИЙ маршрут
// mobile/src/app/(tabs)/[section].tsx (TabRoute) целиком в Jest/RNTL.
//
// Обходы, воспроизводимые клетками:
//  - adversary/F04.V04: route создаёт слот константой
//    <StartSectionHost reducedMotion={false} /> — TabShell читает
//    AccessibilityInfo.isReduceMotionEnabled (shell-faden честно гаснет),
//    но созданный элемент несёт неизменяемый false: системная настройка не
//    достигает StartScreen. Клетки ROUTE_MOTION_SYSTEM_{full,reduced} подают
//    настройку публичным API RN (тем же, что читает TabShell) и сверяют
//    МАРКЕРНЫЕ СЛОТЫ ветви start-motion-* (поверхность, по которой экранная
//    модель различает reduced/full), а также сохранение слотов F04.V04.
//    Текст отладочной строки ('reduced'/'full', совет R108-8) оракулом НЕ
//    служит — только testID-слоты.
//  - reviewer/R108-1: TabShell размонтирует слот start при смене вкладки и
//    переходе в profile — черновик композера теряется (Maestro
//    cmp-mob-004-start: написать → вернуться → продолжить). Клетки
//    ROUTE_DRAFT_RETURN_* проходят путь целиком: литеральный текст в
//    композер → уход (замкнутое множество: три вкладки других секций +
//    profile; слот реально размонтирован) → возврат (вкладка start /
//    shell-back) → литеральный текст на месте (getByDisplayValue).
//  - положительный контроль подключённости ROUTE_MOUNT_MISSIONS_FROM_RUNTIME:
//    StartScreen монтирован в секции start и получает missions из runtime
//    (listMissions сценария PRESENT/WORKING) — зелёный на C и на модели.
//
// Оракул независим (правило 8): все ожидания — литералы source.json
// (fixed.draft_text, fixed.mission_id), снятые ДО запуска субъекта.
// Публичные швы только: параметры маршрута (expo-router useLocalSearchParams),
// AccessibilityInfo, testIDs shell-*/section-*/start-* (999/108), value
// поля ввода композера. Паттерн await render/await fireEvent — прецедент
// rehearsal.test.tsx (RNTL 14).
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import React from 'react';
import { AccessibilityInfo } from 'react-native';

import { setScenario } from '@/mocks/start-mock';

// Параметры маршрута — управляемая среда клетки (фабрика видит только
// переменные с префиксом mock — требование hoisting jest.mock).
const mockEnv = {
  params: { section: 'start' } as { section?: string | string[]; returnTo?: string | string[] },
};

jest.mock('expo-router', () => ({
  useLocalSearchParams: () => mockEnv.params,
}));

import TabRoute from '@/app/(tabs)/[section]';

// Литералы оракула source.json (fixed.*), НЕ экспорты субъекта.
const EXPECT = {
  draft: 'Kfz-Rechner Frage',
  mission_id: 'MIS-CAR-01',
};

// Системная настройка reduce motion — публичный API RN, тот же, которым
// пользуется TabShell; все клетки подают её одинаково (lockstep).
function setSystemReduceMotion(enabled: boolean) {
  jest.spyOn(AccessibilityInfo, 'isReduceMotionEnabled').mockResolvedValue(enabled);
}

// Promise настройки читается дважды (TabShell и route); флеш микрозадач,
// чтобы разрешение дошло до состояния до утверждений клетки.
async function flushSystemSetting() {
  await act(async () => {});
  await act(async () => {});
}

beforeEach(() => {
  mockEnv.params = { section: 'start' };
  setScenario('PRESENT', 'WORKING');
});

afterEach(() => {
  jest.restoreAllMocks();
});

// F04.V04 на маршруте: системная настройка {false,true} доходит до
// StartScreen — маркерный слот reduced-ветви виден ТОЛЬКО при true; слоты
// карточек/действий сохранены в обоих режимах. Shell свою часть чтения
// выполняет всегда (shell-faden есть только в full) — вектор клетки
// наблюдает обе поверхности, дефект C различим уже на start-motion-*.
it('108 start ROUTE_MOTION_SYSTEM_full', async () => {
  setSystemReduceMotion(false);
  await render(<TabRoute />);
  await waitFor(() => expect(screen.getByTestId('shell-faden')).toBeOnTheScreen());
  expect(screen.getByTestId('start-motion-full')).toBeOnTheScreen();
  expect(screen.queryByTestId('start-motion-reduced')).toBeNull();
  expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
  expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id);
  expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
});

it('108 start ROUTE_MOTION_SYSTEM_reduced', async () => {
  setSystemReduceMotion(true);
  await render(<TabRoute />);
  await flushSystemSetting();
  expect(screen.queryByTestId('shell-faden')).toBeNull();
  expect(screen.getByTestId('start-motion-reduced')).toBeOnTheScreen();
  expect(screen.queryByTestId('start-motion-full')).toBeNull();
  expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
  expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id);
  expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
});

// R108-1 на маршруте: черновик живёт выше слота — переживает смену вкладки.
// Замкнутое множество ухода: вкладки других секций TAB_ORDER (позиция
// назначения × путь «вкладка → вкладка») + профиль (вторичный маршрут:
// вход shell-profile-entry → возврат shell-back). Во время ухода слот
// start размонтирован (композер отсутствует) — возврат обязан восстановить
// литеральный текст в поле ввода.
for (const dest of ['vorgaenge', 'schutz', 'post'] as const) {
  it(`108 start ROUTE_DRAFT_RETURN_TAB_${dest}`, async () => {
    setSystemReduceMotion(false);
    await render(<TabRoute />);
    await waitFor(() => expect(screen.getByTestId('start-composer-input')).toBeOnTheScreen());
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), EXPECT.draft);
    await fireEvent.press(screen.getByTestId(`shell-tab-${dest}`));
    expect(screen.getByTestId(`section-${dest}`)).toBeOnTheScreen();
    expect(screen.queryByTestId('start-composer')).toBeNull();
    await fireEvent.press(screen.getByTestId('shell-tab-start'));
    expect(screen.getByTestId('section-start')).toBeOnTheScreen();
    expect(screen.getByTestId('start-composer-input')).toBeOnTheScreen();
    expect(screen.getByDisplayValue(EXPECT.draft)).toBeOnTheScreen();
  });
}

it('108 start ROUTE_DRAFT_RETURN_PROFILE', async () => {
  setSystemReduceMotion(false);
  await render(<TabRoute />);
  await waitFor(() => expect(screen.getByTestId('start-composer-input')).toBeOnTheScreen());
  await fireEvent.changeText(screen.getByTestId('start-composer-input'), EXPECT.draft);
  await fireEvent.press(screen.getByTestId('shell-profile-entry'));
  expect(screen.getByTestId('profile-surface')).toBeOnTheScreen();
  expect(screen.queryByTestId('start-composer')).toBeNull();
  await fireEvent.press(screen.getByTestId('shell-back'));
  expect(screen.getByTestId('section-start')).toBeOnTheScreen();
  expect(screen.getByTestId('start-composer-input')).toBeOnTheScreen();
  expect(screen.getByDisplayValue(EXPECT.draft)).toBeOnTheScreen();
});

// Положительный контроль подключённости (зелёный на C): StartScreen реально
// монтирован в секции start и получает missions из runtime.
it('108 start ROUTE_MOUNT_MISSIONS_FROM_RUNTIME', async () => {
  setSystemReduceMotion(false);
  await render(<TabRoute />);
  await waitFor(() => expect(screen.getByTestId('start-brief-mission-id')).toBeOnTheScreen());
  expect(screen.getByTestId('section-title-start')).toBeOnTheScreen();
  expect(screen.getByTestId('start-screen')).toBeOnTheScreen();
  expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id);
  expect(screen.getByTestId('start-brief-state')).toHaveTextContent('WORKING');
  expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
});

// Adv108r2/B-1 (круг 3): слот startScreen обязан подаваться маршрутом
// ВСЕГДА — рендер ограничивает сам TabShell (секция start). Обход 307b396:
// startScreen={start === 'start' ? <StartSectionHost/> : undefined}, где
// start — сегмент ВХОДА: при deep link из грамматики 999
// (complior://vorgaenge?returnTo=start) или входе в другую секцию
// открытие start показывает один заголовок — нет StartScreen, AgentPresence,
// композера, brief/resume. Клетки входят в приложение НЕ через start
// (замкнутое множество TAB_ORDER) и через deep link returnTo, затем открывают
// start и сверяют полный набор поверхностей; прямая клетка входит в start
// и проходит start → другая → start (положительный контроль: зелёная и на
// 307b396). Оракул — литералы source.json (fixed.mission_id), не экспорты.
function expectStartSurfaces() {
  expect(screen.getByTestId('section-start')).toBeOnTheScreen();
  expect(screen.getByTestId('start-screen')).toBeOnTheScreen();
  expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
  expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
  expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id);
  expect(screen.getByTestId('start-brief-state')).toHaveTextContent('WORKING');
  expect(screen.getByTestId('start-action-resume')).toBeOnTheScreen();
}

for (const entry of ['vorgaenge', 'schutz', 'post'] as const) {
  it(`108 start ROUTE_ENTRY_TAB_${entry}`, async () => {
    setSystemReduceMotion(false);
    mockEnv.params = { section: entry };
    await render(<TabRoute />);
    await waitFor(() => expect(screen.getByTestId(`section-${entry}`)).toBeOnTheScreen());
    await fireEvent.press(screen.getByTestId('shell-tab-start'));
    expect(screen.getByTestId('section-start')).toBeOnTheScreen();
    expect(screen.getByTestId('start-screen')).toBeOnTheScreen();
    await waitFor(() =>
      expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id));
    expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
    expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
    expect(screen.getByTestId('start-brief-state')).toHaveTextContent('WORKING');
    expect(screen.getByTestId('start-action-resume')).toBeOnTheScreen();
  });
}

it('108 start ROUTE_ENTRY_DEEPLINK_RETURN', async () => {
  setSystemReduceMotion(false);
  mockEnv.params = { section: 'vorgaenge', returnTo: 'start' };
  await render(<TabRoute />);
  await waitFor(() => expect(screen.getByTestId('section-vorgaenge')).toBeOnTheScreen());
  await fireEvent.press(screen.getByTestId('shell-back'));
  expect(screen.getByTestId('section-start')).toBeOnTheScreen();
  expect(screen.getByTestId('start-screen')).toBeOnTheScreen();
  await waitFor(() =>
    expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id));
  expect(screen.getByTestId('start-agent-presence')).toBeOnTheScreen();
  expect(screen.queryAllByTestId('start-composer')).toHaveLength(1);
  expect(screen.getByTestId('start-brief-state')).toHaveTextContent('WORKING');
  expect(screen.getByTestId('start-action-resume')).toBeOnTheScreen();
});

it('108 start ROUTE_ENTRY_DIRECT_ROUNDTRIP', async () => {
  setSystemReduceMotion(false);
  mockEnv.params = { section: 'start' };
  await render(<TabRoute />);
  await waitFor(() =>
    expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id));
  expectStartSurfaces();
  await fireEvent.press(screen.getByTestId('shell-tab-post'));
  expect(screen.getByTestId('section-post')).toBeOnTheScreen();
  expect(screen.queryByTestId('start-composer')).toBeNull();
  await fireEvent.press(screen.getByTestId('shell-tab-start'));
  expect(screen.getByTestId('start-screen')).toBeOnTheScreen();
  await waitFor(() =>
    expect(screen.getByTestId('start-brief-mission-id')).toHaveTextContent(EXPECT.mission_id));
  expectStartSurfaces();
});
