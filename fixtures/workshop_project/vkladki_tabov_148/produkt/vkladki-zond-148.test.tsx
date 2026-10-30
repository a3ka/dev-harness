// Батарея 148 (vkladki-tabov), живой jest-зонд (правка блоков 1 вердикта
// Crit148: класс «литерал на месте, исполняемое иное» закрывается
// ИСПОЛНЕНИЕМ на реальных компонентах R). Зонд пишется produkt_sud в
// ИЗОЛИРОВАННУЮ КОПИЮ mobile (node_modules — симлинк установки R) и
// запускается продуктовым jest; оракул текстов — каталог ui-copy самого
// R (литералов нет), геометрия — рендер-дерево RNTL. Измеряет три
// исполняемых измерения предмета:
//   GA-02/04 — контент вкладок ДОСТИГАЕТ экрана через слот sectionScreens
//              живого TabShell (переход по нажатию вкладки);
//   GA-03    — бейдж «Ihre Rückmeldung nötig» из параметра маршрута
//              ?mitte=needs на живом маршруте (tabs)/[section];
//   GA-09    — таб-лейсте — АБСОЛЮТНЫЙ оверлей нижнего края, контент
//              вкладки НЕ внутри него (Inhalt läuft darunter).
// Зонд не знает о мутациях: каждая из трёх мутаций батареи (tabs/badge/
// scroll) роняет СВОЙ ассерт поведением, не сравнением строк. Идиомы
// среды — как у тестов продукта (async render RNTL, press внутри act).
import React from 'react';
import { StyleSheet, View } from 'react-native';
import { act, fireEvent, render, screen, waitFor, within } from '@testing-library/react-native';
import { TabShell } from '../tab-shell';
import { uiCopyDe } from '../../i18n/ui-copy';
import TabRoute from '../../app/(tabs)/[section]';

// Параметры маршрута — управляемая среда зонда (прецедент продукта:
// start-route-dopusk.test.tsx; фабрика jest.mock читает mockEnv ЛЕНИВО,
// префикс mock — требование hoisting babel-jest).
const mockEnv = {
  params: { section: 'vorgaenge' } as {
    section?: string | string[];
    returnTo?: string | string[];
    mitte?: string | string[];
  },
};

jest.mock('expo-router', () => ({
  useLocalSearchParams: () => mockEnv.params,
}));

/** Нажатие — внутри act (идиома erstinformation-demo-path). */
async function nazhat(id: string) {
  await act(async () => {
    await fireEvent.press(screen.getByTestId(id));
  });
}

/** Стиль узла рендер-дерева, сведённый StyleSheet.flatten. */
function stilUzla(uzol: unknown): { position?: string; bottom?: number; left?: number; right?: number } {
  const props = (uzol as { props?: { style?: unknown } }).props;
  return StyleSheet.flatten([props?.style]) as { position?: string; bottom?: number; left?: number; right?: number };
}

/** Предки узла рендер-дерева (снизу вверх). */
function predki(uzol: unknown): unknown[] {
  const spisok: unknown[] = [];
  for (let u = (uzol as { parent?: unknown }).parent; u; u = (u as { parent?: unknown }).parent) {
    spisok.push(u);
  }
  return spisok;
}

/** Является ли узел оверлеем лейсте: absolute, прижат к нижнему краю. */
function estOverlej(uzol: unknown): boolean {
  const st = stilUzla(uzol);
  return Boolean(st && st.position === 'absolute' && st.bottom === 0 && st.left === 0 && st.right === 0);
}

// Слоты зонда: уникальные testID, которых в R нет (маркеры, не копия).
const sloty = {
  post: <View testID="zond-slot-post" />,
  schutz: <View testID="zond-slot-schutz" />,
  vorgaenge: <View testID="zond-slot-vorgaenge" />,
};

test('GA-02/04: контент вкладок достигает экрана через слот sectionScreens', async () => {
  const view = await render(<TabShell initialSection="start" reducedMotion sectionScreens={sloty} />);
  // честная база 999: start без слота в sectionScreens — заголовок секции
  expect(screen.getByTestId('section-title-start')).toBeOnTheScreen();
  for (const [vkladka, id] of [
    ['vorgaenge', 'zond-slot-vorgaenge'],
    ['schutz', 'zond-slot-schutz'],
    ['post', 'zond-slot-post'],
  ] as const) {
    await nazhat(`shell-tab-${vkladka}`);
    await waitFor(() => expect(screen.getByTestId(id)).toBeOnTheScreen());
  }
  // возврат на start: слот погашен, замороженный заголовок вернулся
  await nazhat('shell-tab-start');
  await waitFor(() => expect(screen.getByTestId('section-title-start')).toBeOnTheScreen());
  expect(screen.queryByTestId('zond-slot-vorgaenge')).toBeNull();
  view.unmount();
});

test('GA-03: ?mitte=needs — бейдж «Ihre Rückmeldung nötig» на живом маршруте', async () => {
  mockEnv.params = { section: 'vorgaenge', mitte: 'needs' };
  const view = await render(<TabRoute />);
  await waitFor(() => expect(screen.getByTestId('gespraech-mitte-badge')).toBeOnTheScreen());
  expect(screen.getByTestId('gespraech-mitte-badge').props.children).toBe(uiCopyDe['ui.vorgaenge.group.needs_you'].text);
  view.unmount();
});

test('GA-03 контроль: без ?mitte=needs бейджа нет, статус рабочий', async () => {
  mockEnv.params = { section: 'vorgaenge' };
  const view = await render(<TabRoute />);
  await waitFor(() => expect(screen.getByTestId('gespraech-mitte-status')).toBeOnTheScreen());
  expect(screen.getByTestId('gespraech-mitte-status').props.children).toBe(uiCopyDe['ui.vorgaenge.group.working'].text);
  view.unmount();
});

test('GA-09: лейсте — абсолютный оверлей нижнего края, контент вне него', async () => {
  const view = await render(
    <TabShell initialSection="vorgaenge" reducedMotion sectionScreens={sloty} />,
  );
  await waitFor(() => expect(screen.getByTestId('zond-slot-vorgaenge')).toBeOnTheScreen());
  // подъём от вкладки лейсте: среди предков обязан быть оверлей
  // position:absolute, прижатый к нижнему краю (bottom/left/right = 0)
  const nadpisiVkladok = predki(screen.getByTestId('shell-tab-vorgaenge'));
  expect(nadpisiVkladok.some(estOverlej)).toBe(true);
  // контент вкладки НЕ потомок оверлея: скролл идёт ПОД лейсте
  const nadpisiKontenta = predki(screen.getByTestId('zond-slot-vorgaenge'));
  const overlej = nadpisiVkladok.find(estOverlej);
  expect(overlej !== undefined && nadpisiKontenta.includes(overlej)).toBe(false);
  view.unmount();
});
