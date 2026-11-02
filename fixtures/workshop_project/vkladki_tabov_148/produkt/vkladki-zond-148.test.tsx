// Батарея 148 (vkladki-tabov), живой jest-зонд (правка блоков 1 вердикта
// Crit148: класс «литерал на месте, исполняемое иное» закрывается
// ИСПОЛНЕНИЕМ на реальных компонентах R; v3a — вердикт Crit148k2a:
// измерения расширены с «слот/бейдж/абсолютный оверлей» до ФАКТИЧЕСКОЙ
// зоны нажатия (Б2) и ИСПОЛЬЗОВАНИЯ токенов 1.1 компонентом (Б3)).
// Зонд пишется produkt_sud в ИЗОЛИРОВАННУЮ КОПИЮ mobile (node_modules —
// симлинк установки R) и запускается продуктовым jest; оракул текстов —
// каталог ui-copy самого R (литералов нет), геометрия — рендер-дерево
// RNTL, значения токенов — носитель vkladki-tokeny-148.json (дословная
// копия веток nav/touch-target пакета D24-Kompakt-1.1; чисел в зонде
// нет). Измеряет предмет ИСПОЛНЕНИЕМ:
//   GA-02/04 — контент вкладок ДОСТИГАЕТ экрана через слот
//              sectionScreens живого TabShell (переход по нажатию);
//   GA-03    — бейдж «Ihre Rückmeldung nötig» из параметра маршрута
//              ?mitte=needs на живом маршруте (tabs)/[section];
//   GA-09    — таб-лейсте — АБСОЛЮТНЫЙ оверлей нижнего края, контент
//              вкладки НЕ внутри него (Inhalt läuft darunter);
//   Б2      — фактическая зона нажатия каждой объявленной цели
//              (высота/minHeight стиля РЕАЛЬНОГО Pressable +
//              невидимое расширение hitSlop) ≥ touch-target.min 44 на
//              ОБОИХ профилях (390×844 и 393×852 — Dimensions.set);
//              цели лейсте ≥ nav.item.min-height 48; строки Vorgänge
//              ≥ 60 (зона манифеста 1.1); видимая рамка меньше зоны
//              находкой НЕ является (слово владельца 2026-11-02);
//   Б3      — типографика вкладки ИСПОЛЬЗУЕТ токены 1.1: fontSize/
//              lineHeight надписи == nav.label.font-size /
//              nav.label.line-height ($value; литерал final2 11px
//              краснеет равенством).
// Зонд не знает о мутациях: каждая из мутаций батареи (tabs/badge/
// skroll/kasanie/tokeny) роняет СВОЙ ассерт поведением, не сравнением
// строк. Идиомы среды — как у тестов продукта (async render RNTL,
// press внутри act); react-native НЕ мокается целиком (урок 145 v1:
// спред requireActual в RN 0.86 роняет загрузку инвариантом
// TurboModuleRegistry) — профиль задаётся Dimensions.set.
import React from 'react';
import { Dimensions, StyleSheet, View } from 'react-native';
import { act, fireEvent, render, screen, waitFor, within } from '@testing-library/react-native';
import { TabShell } from '../tab-shell';
import { GespraechMitte } from '../gespraech-mitte';
import { VorgaengeListe } from '../../features/missions/components/VorgaengeListe';
import { SchutzUebersicht } from '../../features/protection/components/SchutzUebersicht';
import { PostEingang } from '../../features/post/components/PostEingang';
import { uiCopyDe } from '../../i18n/ui-copy';
import TabRoute from '../../app/(tabs)/[section]';
import TOKENY from './vkladki-tokeny-148.json';

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

/** Размерность px из носителя 1.1 (числа в зонде запрещены). */
function px(znach: string): number {
  const chislo = Number.parseFloat(znach);
  if (!Number.isFinite(chislo) || !znach.endsWith('px')) {
    throw new Error(`TOKEN_NE_PX: ${znach} — носитель 1.1 ожидает размерность px`);
  }
  return chislo;
}

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

interface ZonaNazhatija {
  readonly vysota: number;
  readonly shirina: number | null;
}

/**
 * Фактическая зона нажатия цели (Б2): тело = height ?? minHeight стиля
 * РЕАЛЬНОГО Pressable рендер-дерева + невидимое расширение hitSlop
 * (токены touch-target.extend.* пакета 1.1: «sichtbar kleinere
 * Steuerelemente erweitern die Zielfläche unsichtbar»). Ширина судится
 * только там, где несёт явное объявление (width/minWidth/hitSlop):
 * ширина строк ряда даётся раскладкой лейсте, как в самом пакете.
 * Тело без объявления зоны (нет height/minHeight и нет расширения)
 * равно 0 — зона ниже нормы, реализация обязана нести настоящую
 * hit-area (И-7: hitSlop/Pressable, не декларация манифеста).
 */
function zonaCelej(id: string): ZonaNazhatija {
  const uzol = screen.getByTestId(id);
  const props = (uzol as { props?: { style?: unknown; hitSlop?: unknown } }).props ?? {};
  const st = (StyleSheet.flatten([props.style]) ?? {}) as {
    height?: number;
    minHeight?: number;
    width?: number;
    minWidth?: number;
  };
  const syr = props.hitSlop;
  const slop = typeof syr === 'number'
    ? { top: syr, bottom: syr, left: syr, right: syr }
    : ((syr ?? {}) as { top?: number; bottom?: number; left?: number; right?: number });
  const telo = typeof st.height === 'number' ? st.height
    : typeof st.minHeight === 'number' ? st.minHeight : 0;
  const vysota = telo + (slop.top ?? 0) + (slop.bottom ?? 0);
  const obJavlena = typeof st.width === 'number' || typeof st.minWidth === 'number'
    || Boolean(slop.left) || Boolean(slop.right);
  const shirina = obJavlena
    ? (typeof st.width === 'number' ? st.width
        : typeof st.minWidth === 'number' ? st.minWidth : 0)
      + (slop.left ?? 0) + (slop.right ?? 0)
    : null;
  return { vysota, shirina };
}

/** Зона цели ≥ нормы; отказ именован (мутант убит предметным ассертом). */
function proveritZonu(id: string, minimum: number, normaVysoty?: number) {
  const z = zonaCelej(id);
  const norma = normaVysoty ?? minimum;
  if (z.vysota < norma) {
    throw new Error(
      `ZONA_NAZHATIJA_MENSHE_NORMY ${id}: фактическая высота зоны ${z.vysota} < ${norma}` +
      ` (touch-target.min=${minimum}${normaVysoty !== undefined ? `, nav.item.min-height=${normaVysoty}` : ''}` +
      ' пакета D24-Kompakt-1.1; видимая рамка меньше зоны находкой не является)',
    );
  }
  if (z.shirina !== null && z.shirina < minimum) {
    throw new Error(`ZONA_NAZHATIJA_MENSHE_NORMY ${id}: фактическая ширина зоны ${z.shirina} < ${minimum}`);
  }
}

// Слоты зонда: уникальные testID, которых в R нет (маркеры, не копия).
const sloty = {
  post: <View testID="zond-slot-post" />,
  schutz: <View testID="zond-slot-schutz" />,
  vorgaenge: <View testID="zond-slot-vorgaenge" />,
};

// Реальный контент вкладок R в слотах шва (И-1) — зонд измеряет
// компоненты ПРОДУКТА, не копию батареи.
const kontent = {
  post: <PostEingang />,
  schutz: <SchutzUebersicht />,
  vorgaenge: <VorgaengeListe />,
};

// Оба профиля предмета (И-9): 390×844 и 393×852 — через Dimensions.set
// мока RN (исполнение под каждой геометрией; зона токенов не зависит от
// ширины, но профиль-зависимая реализация судится в обоих рендерах).
const PROFILI = [
  { imja: '390x844', shirina: 390, vysota: 844 },
  { imja: '393x852', shirina: 393, vysota: 852 },
] as const;

function ustanovitProfil(profil: { shirina: number; vysota: number }) {
  // оба ключа обязательны (замена только window роняет SafeAreaView мока
  // в пустое дерево), а сам вызов — ВНЕ act: наложение act-областей
  // роняет ВСЕ последующие рендеры сьюта (замеры пачки: тестид 0)
  const geometrija = { width: profil.shirina, height: profil.vysota, scale: 1, fontScale: 1 };
  Dimensions.set({ window: geometrija, screen: { ...geometrija } });
}

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
  expect(screen.getByTestId('gespraech-mitte-badge').props.children).toBe(uiCopyDe['ui.mission.group.needs_user'].text);
  view.unmount();
});

test('GA-03 контроль: без ?mitte=needs бейджа нет, статус рабочий', async () => {
  mockEnv.params = { section: 'vorgaenge' };
  const view = await render(<TabRoute />);
  await waitFor(() => expect(screen.getByTestId('gespraech-mitte-status')).toBeOnTheScreen());
  expect(screen.getByTestId('gespraech-mitte-status').props.children).toBe(uiCopyDe['ui.mission.group.working'].text);
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

// Б2 (Crit148k2a): фактическая зона нажатия. Среда (замеры пачки):
// (1) третий render() в ОДНОМ тесте даёт пустое дерево — потому каждый
// раздел×профыл — ОТДЕЛЬНЫЙ тест с одним рендером; (2) press/waitFor
// после Dimensions.set вешает сьют микрозадачной бурей — измерение
// идёт прямым рендером секции (переход вкладок покрыт тестом GA-02/04);
// (3) Dimensions.set — ВНЕ act и с ОБИМИ ключами window+screen (без
// screen SafeAreaView мока роняет дерево в пустоту, в act — все
// последующие рендеры).
const NORMA_LEISTE = px(TOKENY['nav']['item.min-height'].$value);
const NORMA_MIN = px(TOKENY['touch-target']['min'].$value);
const TSELI_RAZDELA: Readonly<Record<string, readonly (readonly [string, number | undefined])[]>> = {
  vorgaenge: [
    ['vorgaenge-stroka-rechtsschutz', 60], ['vorgaenge-stroka-hausrat-vertrag', 60],
    ['vorgaenge-vse-sdelannye', undefined],
  ],
  schutz: [
    ['schutz-svod', undefined], ['schutz-stat-vertraege', undefined],
    ['schutz-stat-beitrag', undefined], ['schutz-optionen', undefined],
    ['schutz-oblast-mobilitaet', undefined], ['schutz-oblast-wohnen', undefined],
    ['schutz-oblast-gesundheit', undefined], ['schutz-oblast-recht', undefined],
    ['schutz-oblast-familie', undefined],
  ],
  post: [
    ['post-filtr-alle', undefined], ['post-filtr-vhodjaschie', undefined],
    ['post-filtr-otpravlennye', undefined], ['post-filtr-nastrojki', undefined],
    ['post-napisat-complior', undefined], ['post-deckungsanfrage', undefined],
    ['post-soobschenie-rechtsschutz', undefined],
  ],
};

async function proveritZonyRazdela(profil: { shirina: number; vysota: number }, razdel: 'vorgaenge' | 'schutz' | 'post') {
  ustanovitProfil(profil);
  const view = await render(
    <TabShell
      initialSection={razdel}
      mitte={<GespraechMitte reducedMotion />}
      reducedMotion
      sectionScreens={kontent}
    />,
  );
  for (const id of ['shell-tab-start', 'shell-tab-vorgaenge', 'gespraech-mitte', 'shell-tab-schutz', 'shell-tab-post']) {
    proveritZonu(id, NORMA_MIN, NORMA_LEISTE);
  }
  for (const [id, norma] of TSELI_RAZDELA[razdel]) {
    proveritZonu(id, NORMA_MIN, norma);
  }
  view.unmount();
}

test('Б2 (390x844, vorgaenge): зоны ≥ touch-target.min/nav.item.min-height', async () => {
  await proveritZonyRazdela(PROFILI[0], 'vorgaenge');
});

test('Б2 (390x844, schutz): зоны ≥ touch-target.min', async () => {
  await proveritZonyRazdela(PROFILI[0], 'schutz');
});

test('Б2 (390x844, post): зоны ≥ touch-target.min', async () => {
  await proveritZonyRazdela(PROFILI[0], 'post');
});

test('Б2 (393x852, vorgaenge): зоны ≥ touch-target.min/nav.item.min-height', async () => {
  await proveritZonyRazdela(PROFILI[1], 'vorgaenge');
});

test('Б2 (393x852, schutz): зоны ≥ touch-target.min', async () => {
  await proveritZonyRazdela(PROFILI[1], 'schutz');
});

test('Б2 (393x852, post): зоны ≥ touch-target.min', async () => {
  await proveritZonyRazdela(PROFILI[1], 'post');
});

test('Б3: типографика вкладок использует токены 1.1 (nav.label.*)', async () => {
  const razmer = px(TOKENY['nav']['label.font-size'].$value);
  const vysotaStroki = px(TOKENY['nav']['label.line-height'].$value);
  const view = await render(<TabShell initialSection="start" reducedMotion />);
  for (const [vkladka, kljuch] of [
    ['start', 'ia115.nav.START'],
    ['vorgaenge', 'ia117.nav.VORGAENGE'],
    ['schutz', 'ia115.nav.SCHUTZ'],
    ['post', 'ia115.nav.POST'],
  ] as const) {
    const nadpis = within(screen.getByTestId(`shell-tab-${vkladka}`))
      .getByText(uiCopyDe[kljuch].text);
    const st = StyleSheet.flatten([nadpis.props.style]) as { fontSize?: number; lineHeight?: number };
    if (st.fontSize !== razmer) {
      throw new Error(
        `TOKEN_1_1_NE_ISPOLZUETSJA shell-tab-${vkladka}: fontSize ${st.fontSize} != ` +
        `${razmer} (nav.label.font-size $value 1.1; final2 ${TOKENY['nav']['label.font-size'].final2} краснеет)`,
      );
    }
    if (st.lineHeight !== vysotaStroki) {
      throw new Error(
        `TOKEN_1_1_NE_ISPOLZUETSJA shell-tab-${vkladka}: lineHeight ${st.lineHeight} != ` +
        `${vysotaStroki} (nav.label.line-height $value 1.1)`,
      );
    }
  }
  view.unmount();
});
