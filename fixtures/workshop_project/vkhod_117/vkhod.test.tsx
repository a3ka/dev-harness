// 117 vkhod v2 (CMP-MOB-006, сужение до splash + иконка, слово владельца
// 2026-10-21): Splash = нативный знак (app.json; статическая проба) +
// JS-ОВЕРЛЕЙ кадра Splash.png поверх дерева оболочки (арбитраж круга 2,
// С2): оверлей — не JS-кадр state-machine, `frame` стартует с 'first-run'
// как в базе. Вход F03.01/F03.02 выведен в first-run-ekran.
// Оракул — source.json (снят с read-only docs/ Complior-mob 8748a7a335 ДО
// запуска субъекта); все ожидания — ЛИТЕРАЛЫ ниже (правило 8, Н-351/Н-379:
// ни одна клетка не сверяется значением, прочитанным у субъекта). Вход
// (провайдер темы) — themeTokens 999; ожидание — литералы оракула.
// Рестайл-гварды: кадры 995 вне предмета (вход F03.01/F03.02, welcome,
// recovery F03.04, unavailable) не рестайлятся — литералы поверхности 995
// (#FFFFFF, 48/16/16).
// Урок 111 (Н-386/RNTL): каждый запрос/press await; toJSON берётся ПОСЛЕ
// screen-запросов кадра (sync-запрос флушит дерево).

// С2-б (круг критика 3): commit-журнал splash — мок пишет prevent/hide в
// общий журнал, React.Profiler пишет commit (с наличием оверлея в
// контейнере рендерера в момент commit): порядок prevent → commit
// оверлея → hide наблюдается, а не выводится из invocationCallOrder.
jest.mock('expo-splash-screen', () => {
  const mockJournal: string[] = [];
  return {
    __vkhod117Journal: mockJournal,
    preventAutoHideAsync: jest.fn(async () => {
      mockJournal.push('prevent');
      return false;
    }),
    hideAsync: jest.fn(async () => {
      mockJournal.push('hide');
    }),
  };
});

// С2-а (круг критика 3): модули композитов — сентинели. jest-expo
// трансформирует любой PNG в `1` (источник неразличим), поэтому файлы
// mobile/assets/images/splash-composite-{dark,light}.png (литералы
// overlay_117.composites; путь — от mobile/src/bootstrap/__tests__/)
// подменены уникальными объектами: Image оверлея обязан нести ИМЕННО
// модуль файла, содержимое которого судит эталон Б1.
jest.mock('../../../assets/images/splash-composite-dark.png', () => ({ vkhod117Composite: 'dark' }), {
  virtual: true,
});
jest.mock('../../../assets/images/splash-composite-light.png', () => ({ vkhod117Composite: 'light' }), {
  virtual: true,
});

import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import React from 'react';
import { Appearance, NativeModules } from 'react-native';
import { SafeAreaInsetsContext } from 'react-native-safe-area-context';
import { createRoot } from 'test-renderer';
import * as SplashScreen from 'expo-splash-screen';
import { ThemeContext } from '@/theme/context';
import PilotAppProdEntry from '@/app/index';
import { PilotApp } from '@/bootstrap/pilot-app';
import { themeTokens, type ColorScheme } from '@/theme/tokens';
// ---- EXPECT: литералы оракула (source.json, побайтово) ----
const GROUND_DARK = '#0a0a0a';
const GROUND_LIGHT = '#f3f2ee';
// 111/995: поверхность кадров вне предмета (вход F03, welcome, F03.04,
// unavailable)
const SURFACE_995_BG = '#FFFFFF';
const SURFACE_995_PAD_TOP = 48;
const SURFACE_995_PAD_H = 16;
const SURFACE_995_PAD_BOTTOM = 16;
// Р1: инсет production-входа, отличный от 47 остальных клеток.
const PROD_INSET_TOP = 59;

// С2: JS-оверлей splash — литералы (source.json overlay_117).
const SPLASH_OVERLAY_TEST_ID = 'splash-overlay';
const SPLASH_OVERLAY_HIDE_AFTER_MS = 1200;
// (Adv117v3, круг по реализации) Z-ПОРЯДОК: корень полноэкранного
// FirstRun (111) и минимум zIndex оверлея над ним (отсутствующий zIndex
// sibling-узла = 0).
const FIRST_RUN_ROOT_TEST_ID = 'first-run-safe-area';
const SPLASH_OVERLAY_ZINDEX_MIN = 1;
// В2-2 (круг 7, Rev117r2): стиль статус-бара, контрастный ground схемы
// (style expo-status-bar → barStyle RN): dark #0a0a0a → 'light' →
// light-content, light #f3f2ee → 'dark' → dark-content.
const STATUS_BAR_DARK = 'light-content';
const STATUS_BAR_LIGHT = 'dark-content';
function journalOf(mod: unknown): string[] {
  if (mod && typeof mod === 'object' && '__vkhod117Journal' in mod
      && Array.isArray(mod.__vkhod117Journal)) {
    return mod.__vkhod117Journal;
  }
  throw new Error('VKHOD117_JOURNAL_ABSENT: мок expo-splash-screen без журнала');
}
const SPLASH_JOURNAL = journalOf(SplashScreen);
const COMPOSITE_MODULE = {
  dark: require('../../../assets/images/splash-composite-dark.png') as unknown,
  light: require('../../../assets/images/splash-composite-light.png') as unknown,
};

// В2-2: стиль статус-бара, дошедший до ОС. RN StatusBar сводит стек
// смонтированных StatusBar в setImmediate и шлёт итог в
// NativeModules.StatusBarManager.setStyle (jest.fn пресета RN; iOS шлёт
// только смену, Android — каждый сброс): аргумент ПОСЛЕДНЕГО вызова —
// стиль, который показывает ОС; вызова не было — приложение стиль не
// отрисовало (undefined).
function statusBarManagerOf(mod: unknown): { setStyle: jest.Mock } {
  const manager = (mod as { StatusBarManager?: { setStyle?: unknown } } | undefined)
    ?.StatusBarManager;
  if (manager && jest.isMockFunction(manager.setStyle)) {
    return manager as { setStyle: jest.Mock };
  }
  throw new Error('VKHOD117_STATUSBAR_MANAGER_ABSENT: нет jest.fn StatusBarManager.setStyle');
}
const STATUS_BAR_MANAGER = statusBarManagerOf(NativeModules);

function osBarStyle(): unknown {
  const calls = STATUS_BAR_MANAGER.setStyle.mock.calls;
  return calls.length > 0 ? calls[calls.length - 1][0] : undefined;
}

// Сброс отложенного стека StatusBar (setImmediate FIFO: сброс RN раньше).
async function flushStatusBar(): Promise<void> {
  await React.act(async () => {
    await new Promise<void>((resolve) => setImmediate(resolve));
  });
}

function ports(
  verifyStatus: 'invalid' | 'authenticated' = 'invalid',
  beginStatus: 'ok' | 'unavailable' = 'ok',
) {
  return {
    auth: {
      begin: jest.fn(async (email: string) =>
        beginStatus === 'unavailable'
          ? { status: 'unavailable', challenge: email, evidence: 'SYNTHETIC' }
          : { challenge: email, evidence: 'SYNTHETIC' }),
      verify: jest.fn(async () => ({ status: verifyStatus, evidence: 'SYNTHETIC' })),
      resend: jest.fn(async () => ({ confirmed: true, evidence: 'SYNTHETIC' })),
      recover: jest.fn(async () => ({ status: 'unavailable', evidence: 'SYNTHETIC' })),
    },
    api: {
      getSession: jest.fn(async () => ({ locale: 'de-DE' })),
      getDisclosure: jest.fn(async () => ({ acknowledged: false })),
      execute: jest.fn(async () => {
        throw Error('995 BUSINESS_COMMAND_FORBIDDEN');
      }),
    },
    entry: { source: 'DIRECT', onboarding: 'unknown', pendingIntent: null },
  };
}

async function renderApp(
  scheme: ColorScheme,
  verifyStatus: 'invalid' | 'authenticated' = 'invalid',
  beginStatus: 'ok' | 'unavailable' = 'ok',
  insetTop = 47,
) {
  return render(
    <SafeAreaInsetsContext.Provider value={{ top: insetTop, right: 0, bottom: 0, left: 0 }}>
      <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
        <PilotApp {...ports(verifyStatus, beginStatus)} />
      </ThemeContext.Provider>
    </SafeAreaInsetsContext.Provider>,
  );
}

// Р1 (круг 6, Rev117/Adv117): production-ВХОД — @/app/index, как его
// грузит Expo Router/RN. БЕЗ ThemeContext.Provider от теста: схема ОС
// задаётся моком Appearance.getColorScheme (jest-среда без мока даёт
// null → dark). Провод темы — обязанность субъекта, не теста.
async function renderProdEntry(osScheme: 'dark' | 'light') {
  const spy = jest
    .spyOn(Appearance, 'getColorScheme')
    .mockReturnValue(osScheme);
  try {
    return await render(
      <SafeAreaInsetsContext.Provider
        value={{ top: PROD_INSET_TOP, right: 0, bottom: 0, left: 0 }}
      >
        <PilotAppProdEntry {...ports()} />
      </SafeAreaInsetsContext.Provider>,
    );
  } finally {
    spy.mockRestore();
  }
}

function styleOf(node: { props: { style?: unknown } }): Record<string, unknown> {
  const style = node.props.style;
  const flat: Record<string, unknown> = {};
  for (const part of Array.isArray(style) ? style : [style]) {
    if (part) Object.assign(flat, part as Record<string, unknown>);
  }
  return flat;
}

function backgroundOf(node: { props: { style?: unknown } }): unknown {
  return styleOf(node).backgroundColor;
}

// (Adv117v2, круг по реализации) геометрия оверлея: канон инварианта 8 —
// бокс Image следует боксу оверлея (absoluteFill + width/height 100%),
// содержимое центрирует сам resizeMode contain. Запрещённые степени
// свободы: transform любой (translateX/translateY/scale/rotate/skew —
// прямым ключом или элементом массива стилей, включая вложенные массивы),
// margin* любого значения, left/top/right/bottom ≠ 0, position ≠
// 'absolute'. Судят клетки SPLASH_OVERLAY_GEOMETRY_{DARK,LIGHT}.
const GEOMETRY_TRANSFORM_PROPS = [
  'transform', 'translateX', 'translateY', 'scale', 'scaleX', 'scaleY',
  'rotate', 'rotateX', 'rotateY', 'rotateZ', 'skewX', 'skewY',
];
const GEOMETRY_EDGE_PROPS = ['left', 'right', 'top', 'bottom'];

function stylePartsFlat(
  style: unknown,
  out: Array<Record<string, unknown>> = [],
): Array<Record<string, unknown>> {
  if (Array.isArray(style)) {
    for (const part of style) stylePartsFlat(part, out);
  } else if (style && typeof style === 'object') {
    out.push(style as Record<string, unknown>);
  }
  return out;
}

function geometryViolations(node: { props?: { style?: unknown } }): string[] {
  const bad: string[] = [];
  for (const part of stylePartsFlat(node.props?.style)) {
    for (const key of Object.keys(part)) {
      if (GEOMETRY_TRANSFORM_PROPS.includes(key)) {
        bad.push(key + '=' + JSON.stringify(part[key]));
      } else if (GEOMETRY_EDGE_PROPS.includes(key) && part[key] !== 0) {
        bad.push(key + '=' + JSON.stringify(part[key]));
      } else if (key.startsWith('margin')) {
        bad.push(key + '=' + JSON.stringify(part[key]));
      } else if (key === 'position' && part[key] !== 'absolute') {
        bad.push(key + '=' + JSON.stringify(part[key]));
      }
    }
  }
  return bad;
}

// Внешний host-корень дерева PilotApp (Provider-обёртки host-узлами не являются).
function hostRootOf(json: unknown): { type?: unknown; props: { style?: unknown } } {
  return (Array.isArray(json) ? json[0] : json) as { type?: unknown; props: { style?: unknown } };
}

type TreeNode = { props?: { style?: unknown }; children?: unknown };

// С2: поддерево узла по testID (toJSON).
function subtreeByTestId(json: unknown, testID: string): TreeNode | null {
  const node = json as TreeNode;
  const tid = (node?.props as { testID?: string } | undefined)?.testID;
  if (tid === testID) return node;
  const children = node?.children;
  for (const child of Array.isArray(children) ? children : []) {
    const hit = subtreeByTestId(child, testID);
    if (hit) return hit;
  }
  return null;
}

// (Adv117v3) путь от корня JSON-дерева к узлу с testID — индексы детей
// на каждом уровне; пустой путь = сам корень.
function hostPathByTestId(json: unknown, testID: string, path: number[] = []): number[] | null {
  const node = json as TreeNode;
  const tid = (node?.props as { testID?: string } | undefined)?.testID;
  if (tid === testID) return path;
  const children = node?.children;
  const list = Array.isArray(children) ? children : [];
  for (let i = 0; i < list.length; i += 1) {
    const hit = hostPathByTestId(list[i], testID, [...path, i]);
    if (hit) return hit;
  }
  return null;
}

function hasNodeType(json: unknown, type: string): boolean {
  const node = json as { type?: unknown; children?: unknown };
  if (node?.type === type) return true;
  const children = node?.children;
  for (const child of Array.isArray(children) ? children : []) {
    if (hasNodeType(child, type)) return true;
  }
  return false;
}

// До кадра email: cold start рендерит first-run сразу (JS-кадра splash нет),
// CTA ведёт в F03.01.
async function toEmail(
  scheme: ColorScheme,
  verifyStatus: 'invalid' | 'authenticated' = 'invalid',
  beginStatus: 'ok' | 'unavailable' = 'ok',
) {
  const api = await renderApp(scheme, verifyStatus, beginStatus);
  const cta = await screen.findByTestId('first-run-continue');
  await fireEvent.press(cta);
  await screen.findByTestId('auth-email');
  return api;
}

describe('117 vkhod', () => {
  afterEach(async () => {
    await cleanup();
  });

  // Г0 (117 v2, сужение до splash + иконка): кадры входа F03.01 (email) и
  // F03.02 (code) выведены в first-run-ekran (слово владельца 2026-10-21
  // ~14:10 UTC) и остаются поверхностью 995, как на B: внешний корень несёт
  // литералы 995 #FFFFFF и 48/16/16 на ОБОИХ кадрах. Рестайл входа в форме
  // текущего C (isD22Frame добавляет email/code) красит обе клетки.
  // Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`RESTYLE_GUARD_995_F03_${S}`, async () => {
      const api = await toEmail(scheme);
      let rootStyle = styleOf(hostRootOf(api.toJSON()));
      expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
      expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await screen.findByTestId('auth-code');
      rootStyle = styleOf(hostRootOf(api.toJSON()));
      expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
      expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }

  // Г1 рестайл-гвард 995: кадр welcome — поверхность 995 (frozen 111/1),
  // внешний корень несёт литералы 995 #FFFFFF и 48/16/16. Произведение
  // scheme(2) — рестайл только в одной схеме красит второй.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`RESTYLE_GUARD_995_WELCOME_${S}`, async () => {
      const api = await toEmail(scheme, 'authenticated');
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await fireEvent.press(await screen.findByTestId('auth-verify'));
      await screen.findByTestId('F02.01');
      const rootStyle = styleOf(hostRootOf(api.toJSON()));
      expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
      expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }

  // Г2 рестайл-гвард 995: кадр F03.04 (recovery) владельцем не назван —
  // остаётся поверхностью 995 (белый корень, отступы 48/16/16); путь —
  // через код-кадр (кнопка доступа F03.A02 живёт в F03.02).
  it('RESTYLE_GUARD_995_RECOVERY_DARK', async () => {
    const api = await toEmail('dark');
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await fireEvent.press(await screen.findByTestId('auth-no-access'));
    await screen.findByTestId('F03.04');
    const rootStyle = styleOf(hostRootOf(api.toJSON()));
    expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
    expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
    expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
    expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
  });

  // Г2′ (Б4, круг 2): recovery в СВЕТЛОЙ схеме — та же поверхность 995.
  // Свойство «исключённые кадры не рестайлятся» судится по всем кадрам ×
  // обеих схем, не выборкой соседей.
  it('RESTYLE_GUARD_995_RECOVERY_LIGHT', async () => {
    const api = await toEmail('light');
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await fireEvent.press(await screen.findByTestId('auth-no-access'));
    await screen.findByTestId('F03.04');
    const rootStyle = styleOf(hostRootOf(api.toJSON()));
    expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
    expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
    expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
    expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
  });

  // Г3 (Б4, круг 2): кадр unavailable — поверхность 995 в обеих схемах
  // (путь: demo-entry при begin=unavailable). Обход «isD22Frame добавляет
  // unavailable» красит обе клетки.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`RESTYLE_GUARD_995_UNAVAILABLE_${S}`, async () => {
      const api = await toEmail(scheme, 'invalid', 'unavailable');
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await screen.findByTestId('auth-unavailable');
      const rootStyle = styleOf(hostRootOf(api.toJSON()));
      expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
      expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }

  // Р1 (круг 6, Rev117/Adv117): тема ОС проводится на production-входе.
  // Остальные клетки оборачивают PilotApp в Provider САМИ — они судят
  // палитру ПРИ схеме, но не провод темы СО схемы устройства (на C оверлей
  // оставался тёмным при OS light: app/index — реэкспорт без провайдера,
  // useTheme по умолчанию dark). Эта клетка рендерит @/app/index БЕЗ
  // ThemeContext.Provider, схема — только мок Appearance.getColorScheme:
  // OS light → оверлей splash на ground #f3f2ee, OS dark → #0a0a0a.
  // 117 v2: проверка кадра F03.01 снята — вход выведен в first-run-ekran.
  // Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    const GROUND = scheme === 'dark' ? GROUND_DARK : GROUND_LIGHT;

    it(`PROD_ENTRY_OS_THEME_${S}`, async () => {
      await renderProdEntry(scheme);
      const overlay = await screen.findByTestId(SPLASH_OVERLAY_TEST_ID);
      expect(styleOf(overlay).backgroundColor).toBe(GROUND);
    });
  }

  // В2-2 (круг 7, Rev117r2; к В2-1): стиль статус-бара по схеме на splash.
  // На C StatusBar нет ни в mobile/src, ни в app.json — на светлом splash
  // иконки белые #ffffff на ground #f3f2ee (1,12:1). Клетка судит
  // ЭФФЕКТИВНЫЙ стиль, который отрисовка PilotApp довела до ОС
  // (osBarStyle), против литерала контраста ground схемы. Вход —
  // production @/app/index, схема ОС — только мок Appearance.getColorScheme,
  // держится всю клетку. Стиль судится на splash и ПОСЛЕ снятия оверлея
  // таймером (StatusBar вне поддерева оверлея — иначе снятие оверлея
  // снимает стиль). 117 v2 (сужение до splash + иконка): шаги F03.01/F03.02
  // сняты — вход выведен в first-run-ekran. Демаркация: конформен стиль из
  // схемы PilotApp (та же схема красит ground); style 'auto' следует
  // useColorScheme (в jest — мок пресета 'light', на устройстве — ОС, а не
  // явный провайдер над PilotApp) — не конформен. Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    const BAR = scheme === 'dark' ? STATUS_BAR_DARK : STATUS_BAR_LIGHT;

    it(`STATUS_BAR_STYLE_${S}`, async () => {
      const spy = jest.spyOn(Appearance, 'getColorScheme').mockReturnValue(scheme);
      try {
        await flushStatusBar();
        await render(
          <SafeAreaInsetsContext.Provider
            value={{ top: PROD_INSET_TOP, right: 0, bottom: 0, left: 0 }}
          >
            <PilotAppProdEntry {...ports()} />
          </SafeAreaInsetsContext.Provider>,
        );
        await flushStatusBar();
        expect(osBarStyle()).toBe(BAR);
        await waitFor(
          () => expect(screen.queryByTestId(SPLASH_OVERLAY_TEST_ID)).toBeNull(),
          { timeout: 3 * SPLASH_OVERLAY_HIDE_AFTER_MS },
        );
        await flushStatusBar();
        expect(osBarStyle()).toBe(BAR);
      } finally {
        spy.mockRestore();
      }
    });
  }

  // Р6 (круг 6, Rev117): композит оверлея вписан по ОКНУ. Бокс Image
  // жёстко следует боксу оверлея (width/height '100%' поверх
  // absoluteFill): contain масштабирует по ширине окна (2.769 px/px
  // артборда при 1080×2400) и центрирует (центр tagline = центр окна
  // ±1 dp; на C растр шёл собственным размером 390×844 dp — масштаб
  // 2.63, прижим к углу, сдвиг теглайна 28 px). Пиксельная истина на
  // устройстве — rule (В) e2e/ревьюер; клетка судит объявленный бокс
  // в дереве. Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_OVERLAY_CONTAIN_${S}`, async () => {
      const api = await renderApp(scheme);
      const overlay = subtreeByTestId(api.toJSON(), SPLASH_OVERLAY_TEST_ID);
      expect(overlay).not.toBeNull();
      const oStyle = styleOf(overlay as never);
      expect(oStyle.position).toBe('absolute');
      expect(oStyle.width).toBe('100%');
      expect(oStyle.height).toBe('100%');
      const images: Array<{ props: { source?: unknown; resizeMode?: unknown } }> = [];
      const collect = (json: unknown): void => {
        const node = json as { type?: unknown; props?: Record<string, unknown>; children?: unknown };
        if (node?.type === 'Image' && node.props) {
          images.push({ props: node.props as { source?: unknown; resizeMode?: unknown } });
        }
        for (const child of Array.isArray(node?.children) ? node.children : []) collect(child);
      };
      collect(overlay);
      expect(images.length).toBe(1);
      expect(images[0].props.resizeMode).toBe('contain');
      const iStyle = styleOf(images[0] as never);
      expect(iStyle.position).toBe('absolute');
      expect(iStyle.width).toBe('100%');
      expect(iStyle.height).toBe('100%');
    });
  }

  // (Adv117v2, круг по реализации) ГЕОМЕТРИЯ оверлея в реальном рендере:
  // сплющенный стиль оверлея и его единственного Image не несёт
  // запрещённых степеней свободы (transform любой, margin*, края ≠ 0,
  // position ≠ 'absolute') — иначе канонический композит сдвинут или
  // смасштабирован относительно Splash.png/Splash-Hell.png при зелёных
  // source/resizeMode (находка Adv117v2: translateX: 19 проходил батарею).
  // Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_OVERLAY_GEOMETRY_${S}`, async () => {
      const api = await renderApp(scheme);
      const overlay = subtreeByTestId(api.toJSON(), SPLASH_OVERLAY_TEST_ID);
      expect(overlay).not.toBeNull();
      const images: Array<{ props: { style?: unknown } }> = [];
      const collect = (json: unknown): void => {
        const node = json as { type?: unknown; props?: Record<string, unknown>; children?: unknown };
        if (node?.type === 'Image' && node.props) {
          images.push({ props: node.props as { style?: unknown } });
        }
        for (const child of Array.isArray(node?.children) ? node.children : []) collect(child);
      };
      collect(overlay);
      expect(images.length).toBe(1);
      expect([
        ...geometryViolations(overlay as never),
        ...geometryViolations(images[0]),
      ]).toEqual([]);
    });
  }

  // (Adv117v3, круг по реализации) Z-ПОРЯДОК оверлея в реальном рендере:
  // инвариант 8 — оверлей ПОВЕРХ дерева оболочки. Находка Adv117v3:
  // `zIndex: -1` у splash-overlay проходил прежнюю батарею — toBeVisible
  // не видит перекрытия соседом, а сплеш ложится ПОД полноэкранный
  // FirstRun (SafeAreaView flex:1): пользователь видит First-Run вместо
  // Splash.png. Клетка судит ДЕРЕВО рендера: сплющенный zIndex оверлея —
  // число >= 1 И строго больше zIndex корня FirstRun (отсутствующий = 0),
  // и на первой расхожей позиции путей от корня ветка оверлея стоит
  // ПОЗЖЕ ветки FirstRun (порядок sibling решает при равных zIndex —
  // оверлей обязан быть последним ребёнком корня). Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_OVERLAY_ZORDER_${S}`, async () => {
      const api = await renderApp(scheme);
      const json = api.toJSON();
      const overlay = subtreeByTestId(json, SPLASH_OVERLAY_TEST_ID);
      expect(overlay).not.toBeNull();
      const firstRun = subtreeByTestId(json, FIRST_RUN_ROOT_TEST_ID);
      expect(firstRun).not.toBeNull();
      const zOverlay = styleOf(overlay as never).zIndex;
      expect(typeof zOverlay).toBe('number');
      expect(zOverlay as number).toBeGreaterThanOrEqual(SPLASH_OVERLAY_ZINDEX_MIN);
      const zFirstRun = styleOf(firstRun as never).zIndex;
      expect(zOverlay as number).toBeGreaterThan(
        typeof zFirstRun === 'number' ? zFirstRun : 0,
      );
      const overlayPath = hostPathByTestId(json, SPLASH_OVERLAY_TEST_ID);
      const firstRunPath = hostPathByTestId(json, FIRST_RUN_ROOT_TEST_ID);
      expect(overlayPath).not.toBeNull();
      expect(firstRunPath).not.toBeNull();
      const depth = Math.min(overlayPath!.length, firstRunPath!.length);
      let split = 0;
      while (split < depth && overlayPath![split] === firstRunPath![split]) split += 1;
      expect(split < depth).toBe(true);
      expect(overlayPath![split]).toBeGreaterThan(firstRunPath![split]);
    });
  }

  // С2 (арбитраж круга 2): JS-оверлей splash присутствует при ПЕРВОМ
  // коммите — absoluteFill поверх дерева, pointerEvents none, фон ground
  // схемы, Image композита кадра внутри. Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    const GROUND = scheme === 'dark' ? GROUND_DARK : GROUND_LIGHT;

    it(`SPLASH_OVERLAY_MOUNTED_${S}`, async () => {
      const api = await renderApp(scheme);
      const overlay = await screen.findByTestId(SPLASH_OVERLAY_TEST_ID);
      expect(overlay.props.pointerEvents).toBe('none');
      const flat = styleOf(overlay);
      expect(flat.position).toBe('absolute');
      expect(flat.backgroundColor).toBe(GROUND);
      expect(hasNodeType(subtreeByTestId(api.toJSON(), SPLASH_OVERLAY_TEST_ID), 'Image'))
        .toBe(true);
    });
  }

  // С2-а (круг критика 3; арбитраж круга 2 §2 п.2): Image оверлея связан
  // с композитом, содержимое которого судит эталон Б1 (статическая
  // SPLASH_COMPOSITE_ETALON_*): в поддереве оверлея РОВНО один Image, его
  // эффективный source — модуль файла splash-composite-<схема>.png
  // (сентинель выше; icon.png, иной файл, композит чужой схемы — красны),
  // resizeMode contain, заполняет оверлей (absoluteFill), не скрыт.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_OVERLAY_COMPOSITE_${S}`, async () => {
      const api = await renderApp(scheme);
      const overlay = subtreeByTestId(api.toJSON(), SPLASH_OVERLAY_TEST_ID);
      expect(overlay).not.toBeNull();
      const images: Array<{ props: { source?: unknown; resizeMode?: unknown; style?: unknown } }> = [];
      const collect = (json: unknown): void => {
        const node = json as { type?: unknown; props?: Record<string, unknown>; children?: unknown };
        if (node?.type === 'Image' && node.props) images.push({ props: node.props });
        for (const child of Array.isArray(node?.children) ? node.children : []) collect(child);
      };
      collect(overlay);
      expect(images.length).toBe(1);
      expect(images[0].props.source).toBe(COMPOSITE_MODULE[scheme]);
      expect(images[0].props.resizeMode).toBe('contain');
      const flat = styleOf(images[0]);
      expect(flat.position).toBe('absolute');
      expect([flat.top, flat.right, flat.bottom, flat.left]).toEqual([0, 0, 0, 0]);
      expect(flat.display === 'none' || Number(flat.opacity) === 0).toBe(false);
    });
  }

  // Видимость кадра (вердикт критика 117 v2 круг 1): стиль самого Image
  // не наблюдает видимость композиции — `opacity: 0` / `display: 'none'` на
  // View оверлея или любом предке скрывает весь кадр при зелёных клетках
  // выше. Клетка судит РЕАЛЬНЫЙ рендер матчером RNTL toBeVisible (узел и
  // вся цепочка предков до корня рендера: display none, opacity 0,
  // скрытие от доступности, Modal visible=false) — оверлей И единственный
  // Image композита. Запрос включает скрытые узлы: скрытый оверлей красен
  // ЭТОЙ клеткой как невидимый, а не как отсутствующий. Пиксельная
  // видимость на устройстве — сверка кадра e2e с макетом (123, приёмка).
  // Произведение scheme(2).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_OVERLAY_VISIBLE_${S}`, async () => {
      await renderApp(scheme);
      const overlay = await screen.findByTestId(SPLASH_OVERLAY_TEST_ID, {
        includeHiddenElements: true,
      });
      expect(overlay).toBeVisible();
      const images = overlay.queryAll((node) => node.type === 'Image');
      expect(images.length).toBe(1);
      expect(images[0]).toBeVisible();
    });
  }

  // С2: оверлей БЕЗ Text-узлов — wordmark/tagline канона живут растром
  // композита (сшибка с frozen-текстами 995/111 исключена по построению).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_OVERLAY_NO_TEXT_${S}`, async () => {
      const api = await renderApp(scheme);
      const overlay = subtreeByTestId(api.toJSON(), SPLASH_OVERLAY_TEST_ID);
      expect(overlay).not.toBeNull();
      expect(hasNodeType(overlay, 'Text')).toBe(false);
    });
  }

  // С2-б (круг критика 3; арбитраж круга 2 §2 п.2 «hideAsync ПОСЛЕ
  // монтирования оверлея»): порядок жизненного цикла наблюдается
  // commit-журналом — preventAutoHideAsync (модуль) → ПЕРВЫЙ commit дерева
  // С оверлеем (React.Profiler onRender в фазе commit; наличие оверлея
  // снимается с контейнера рендерера в момент commit) → ровно один
  // hideAsync (effect после commit). hide в render (ленивый useState), на
  // модуле до prevent, пропущенный hide, первый commit без оверлея — красны.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_HIDEASYNC_ORDER_${S}`, async () => {
      const start = SPLASH_JOURNAL.length;
      const root = createRoot();
      const onRender = () => {
        SPLASH_JOURNAL.push(
          subtreeByTestId(root.container.toJSON(), SPLASH_OVERLAY_TEST_ID)
            ? 'commit+overlay'
            : 'commit',
        );
      };
      await React.act(async () => {
        root.render(
          <React.Profiler id="vkhod117" onRender={onRender}>
            <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
              <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
                <PilotApp {...ports()} />
              </ThemeContext.Provider>
            </SafeAreaInsetsContext.Provider>
          </React.Profiler>,
        );
      });
      const log = SPLASH_JOURNAL.slice(start);
      await React.act(async () => {
        root.unmount();
      });
      console.log('VKHOD117_COMMIT_JOURNAL', S, JSON.stringify(log));
      const firstCommit = log.findIndex((e) => e.startsWith('commit'));
      expect(firstCommit).toBeGreaterThanOrEqual(0);
      expect(log[firstCommit]).toBe('commit+overlay');
      expect(log.filter((e) => e === 'hide').length).toBe(1);
      expect(log.indexOf('hide')).toBeGreaterThan(firstCommit);
      const prevent = SPLASH_JOURNAL.indexOf('prevent');
      expect(prevent).toBeGreaterThanOrEqual(0);
      expect(prevent).toBeLessThan(start + firstCommit);
    });
  }

  // С2: автоскрытие таймером-литералом — fake timers: до 1199 мс оверлей
  // на месте, на 1200-й исчезает (очистка таймера в cleanup).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`SPLASH_OVERLAY_TIMER_HIDE_${S}`, async () => {
      jest.useFakeTimers();
      try {
        const api = await renderApp(scheme);
        expect(api.getByTestId(SPLASH_OVERLAY_TEST_ID)).toBeTruthy();
        await React.act(async () => {
          jest.advanceTimersByTime(SPLASH_OVERLAY_HIDE_AFTER_MS - 1);
        });
        expect(api.queryByTestId(SPLASH_OVERLAY_TEST_ID)).not.toBeNull();
        await React.act(async () => {
          jest.advanceTimersByTime(1);
        });
        expect(api.queryByTestId(SPLASH_OVERLAY_TEST_ID)).toBeNull();
      } finally {
        jest.useRealTimers();
      }
    });
  }

  // ---- 117 v3 (миграция 117/3): допуск демо-маршрута в pilot-app ----
  // Слово владельца 2026-10-24: маршрут First-Run → demo → Erstinformation
  // → Start (с вкладками) допущен ТОЛЬКО при current ∧ admission из
  // сессии; без admission/current — прежний Г0-путь (F03, поверхность
  // 995). Допуск приходит ПОРТОМ (внешняя сессия), не литералом в
  // pilot-app; оси — язык замороженной приёмки 118 (W0/W1A ×
  // null/stale/current). Корни кадров F03 судят Г0-клетки выше; здесь —
  // маршрут: прежний путь жив, Start закрыт без допуска, порядок
  // First-Run → Erstinformation → Start (testID состава Start — из
  // замороженной приёмки 118: start_tabs + четыре вкладки).
  // Оба поля OPTIONAL — как у порта модели (критик v3, блокер 1:
  // «отсутствует» — законный вход оси, не вне-алфавитная атака).
  interface OnboardingPort {
    readonly admission?: 'W0' | 'W1A';
    readonly gate?: 'null' | 'stale' | 'current';
  }

  async function renderAppOnboarding(
    onboarding: OnboardingPort,
    scheme: ColorScheme = 'dark',
  ) {
    return render(
      <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
        <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
          <PilotApp {...ports()} onboarding={onboarding} />
        </ThemeContext.Provider>
      </SafeAreaInsetsContext.Provider>,
    );
  }

  // До демо-входа: прежний вход F03.01 жив (auth-email) — миграция не
  // удаляет прежний путь ДО допуска.
  async function toEmailOnboarding(
    onboarding: OnboardingPort,
    scheme: ColorScheme = 'dark',
  ) {
    const api = await renderAppOnboarding(onboarding, scheme);
    await fireEvent.press(await screen.findByTestId('first-run-continue'));
    await screen.findByTestId('auth-email');
    return api;
  }

  // 117 v3 (арбитраж нарезки 117↔118, семантика frozen 118/1 инв. 4–5):
  // W1A → Erstinformation при ЛЮБОМ gate; при не-current Start закрыт
  // ДО и ПОСЛЕ нажатия continue (переход не происходит), кадр code не
  // возникает. Маркер gate наблюдаем на Erstinformation.
  async function expectErstinfoBezStart(gateMarker: string) {
    await screen.findByTestId('erstinformation-117');
    expect(screen.queryByTestId(`erstinfo_gate_${gateMarker}`)).not.toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    expect(screen.queryByTestId('auth-code')).toBeNull();
    await fireEvent.press(screen.getByTestId('erstinfo_continue_start'));
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    expect(screen.queryByTestId('erstinformation-117')).not.toBeNull();
  }

  // Без admission (W0) при current: демо-вход — прежний путь B (F03.02
  // code), Erstinformation/Start не возникают.
  it('MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ admission: 'W0', gate: 'current' });
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await screen.findByTestId('auth-code');
    expect(screen.queryByTestId('erstinformation-117')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
  });

  // Admission есть, gate не current (null): Erstinformation ПОКАЗАН с
  // маркером gate, Start закрыт, continue НЕ переводит (frozen 118/1
  // инв. 4–5; арбитраж нарезки 117↔118: admission решает поверхность,
  // gate — переход).
  it('MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ admission: 'W1A', gate: 'null' });
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await expectErstinfoBezStart('null');
  });

  // Admission есть, gate stale (ушедшая версия — OUTDATED по 107):
  // Erstinformation с маркером, Start закрыт, continue не переводит.
  it('MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ admission: 'W1A', gate: 'stale' });
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await expectErstinfoBezStart('stale');
  });


  // Допуск W1A ∧ current: маршрут First-Run → demo → Erstinformation →
  // continue → Start (порядок: Start не раньше Erstinformation; прежний
  // код-кадр покинут). Состав Start — testID приёмки 118.
  it('MIGRACIYA_W1A_CURRENT_MARSHRUT', async () => {
    await toEmailOnboarding({ admission: 'W1A', gate: 'current' });
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await screen.findByTestId('erstinformation-117');
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    expect(screen.queryByTestId('auth-code')).toBeNull();
    await fireEvent.press(screen.getByTestId('erstinfo_continue_start'));
    await screen.findByTestId('start_tabs');
    for (const tab of ['start_tab_start', 'start_tab_vorgaenge', 'start_tab_schutz', 'start_tab_post']) {
      expect(screen.getByTestId(tab)).toBeTruthy();
    }
  });
  // ---- 117 v3 правка по FAIL критика v3: непокрытые входы допуска ----
  // Блокер 1: поля порта OPTIONAL — «отсутствует admission/gate» есть
  // законный вход оси (не атака); сочетание W0×stale и СВЕТЛАЯ тема не
  // судились. Полная матрица шва: admission ∈ {отсутствует, W0, W1A} ×
  // gate ∈ {отсутствует, null, stale, current} × тема {dark, light};
  // Erstinformation открывает ТОЛЬКО W1A ∧ current — в обеих темах.

  // Сессия {gate:'current'} БЕЗ admission: отсутствие поля — НЕ допуск
  // (ловит умолчание-литерал `?? 'W1A'`).
  it('MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ gate: 'current' });
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await screen.findByTestId('auth-code');
    expect(screen.queryByTestId('erstinformation-117')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
  });

  // Сессия {admission:'W1A'} БЕЗ gate: отсутствие gate — НЕ current
  // (ловит умолчание-литерал `?? 'current'`).
  it('MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ admission: 'W1A' });
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await expectErstinfoBezStart('null');
  });

  // Непокрытое сочетание W0×stale: оба поля заданы, допуск НЕТ — прежний
  // путь B (admission ≠ W1A: Erstinformation поверхностью не открывается).
  it('MIGRACIYA_W0_STALE_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ admission: 'W0', gate: 'stale' });
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await screen.findByTestId('auth-code');
    expect(screen.queryByTestId('erstinformation-117')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
  });

  // W1A×stale в СВЕТЛОЙ теме: Erstinformation без Start (недопуск к
  // Start не зависит от схемы; поверхность решает admission).
  it('MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ admission: 'W1A', gate: 'stale' }, 'light');
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await expectErstinfoBezStart('stale');
  });

  // W0×null в СВЕТЛОЙ теме: светлая схема сама по себе НЕ допуск
  // (ловит обход `|| (onboarding && scheme === 'light')`).
  it('MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT', async () => {
    await toEmailOnboarding({ admission: 'W0', gate: 'null' }, 'light');
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await screen.findByTestId('auth-code');
    expect(screen.queryByTestId('erstinformation-117')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
  });

  // Допуск W1A ∧ current в СВЕТЛОЙ теме: маршрут открывается в обеих
  // темах (тема — не ось допуска; ловит сужение `&& scheme === 'dark'`).
  it('MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT', async () => {
    await toEmailOnboarding({ admission: 'W1A', gate: 'current' }, 'light');
    await fireEvent.press(screen.getByTestId('auth-demo-entry'));
    await screen.findByTestId('erstinformation-117');
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    expect(screen.queryByTestId('auth-code')).toBeNull();
    await fireEvent.press(screen.getByTestId('erstinfo_continue_start'));
    await screen.findByTestId('start_tabs');
    for (const tab of ['start_tab_start', 'start_tab_vorgaenge', 'start_tab_schutz', 'start_tab_post']) {
      expect(screen.getByTestId(tab)).toBeTruthy();
    }
  });

  // Блокер 2: Г0 наблюдается на экземпляре с ПОДКЛЮЧЁННЫМ портом
  // onboarding (недопуск W0×current) — корни F03.01 и F03.02 несут
  // литералы 995 #FFFFFF 48/16/16 в ОБЕИХ схемах: подключение порта
  // само по себе не рестайлит корень (ловит условный рестайл
  // `onboarding ? {black, padding 0} : null`).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`MIGRACIYA_G0_F03_ONBOARDING_${S}`, async () => {
      const api = await toEmailOnboarding({ admission: 'W0', gate: 'current' }, scheme);
      let rootStyle = styleOf(hostRootOf(api.toJSON()));
      expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
      expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await screen.findByTestId('auth-code');
      rootStyle = styleOf(hostRootOf(api.toJSON()));
      expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
      expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }

  // Г0 при ДОПУСКЕ (W1A ∧ current подключён): прежний вход F03.01 жив
  // и после продолжения из First-Run — корень кадра email остаётся
  // поверхностью 995 (ловит рестайл корня только при допуске).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`MIGRACIYA_G0_F03_DOPUSK_${S}`, async () => {
      const api = await toEmailOnboarding({ admission: 'W1A', gate: 'current' }, scheme);
      const rootStyle = styleOf(hostRootOf(api.toJSON()));
      expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
      expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }

  // ---- 117 v3 правка по FAIL критика круг 2: ТАБЛИЦА ВХОДОВ ДОПУСКА ----
  // Блокеры круга 2 — один корень: батарея покрывала выборку входов
  // допуска/Г0, а не всё пространство порта. Инвариант «таблица входов»:
  // ЕДИНАЯ таблица всех выразимых входов — форма порта × admission ×
  // gate × тема; ожидание каждой клетки ВЫВОДИТСЯ из строки таблицы
  // (допущен ⇔ admission === 'W1A' ∧ gate === 'current' — единственная
  // строка POLNYJ/W1A/CURRENT; все прочие строки — прежний путь B и Г0
  // #FFFFFF 48/16/16 в ОБЕИХ темах), имена клеток производны от строки.
  // Счёт клеток = строки × темы (26 × 2 = 52) — из таблицы, сверяется
  // прогоном (behavioral N/N) и разбором файла (вторая мера).
  // Оси: admission ∈ {W0, W1A, отсутствует, null, неизвестное('W2')},
  // gate ∈ {current, stale, отсутствует, null, неизвестное('future')};
  // «отсутствует» — OPTIONAL-поле (блокер 1 круга 1), null — JSON-литерал
  // внешних данных, неизвестное значение — вне замкнутого алфавита порта
  // (порт — внешняя сессия, значения не выбирает потребитель).
  // Формы порта: не подключён (проп undefined) / пустой подключённый {}
  // (обход критика круга 2 new-empty-session-demo: истина порта ≠ допуску)
  // / частичный (ровно одно поле) / полный (оба поля). Строки, где ось
  // «отсутствует» НЕ выразима формой (нет порта — нет и поля формы),
  // таблицей не порождаются: полная таблица = все ВЫРАЗИМЫЕ сочетания.
  type TablicaAdmission = 'W0' | 'W1A' | 'OTSUT' | 'NULL' | 'NEIZVESTNOE';
  type TablicaGate = 'CURRENT' | 'STALE' | 'NULL' | 'OTSUT' | 'NEIZVESTNOE';
  type TablicaPort = { admission?: unknown; gate?: unknown };

  const ADMISSION_VALUE: Record<'W0' | 'W1A' | 'NULL' | 'NEIZVESTNOE', unknown> = {
    W0: 'W0',
    W1A: 'W1A',
    NULL: null,
    NEIZVESTNOE: 'W2',
  };
  const GATE_VALUE: Record<'CURRENT' | 'STALE' | 'NULL' | 'NEIZVESTNOE', unknown> = {
    CURRENT: 'current',
    STALE: 'stale',
    NULL: null,
    NEIZVESTNOE: 'future',
  };

  function tablicaPort(adm: TablicaAdmission, gate: TablicaGate): TablicaPort {
    const port: TablicaPort = {};
    if (adm !== 'OTSUT') port.admission = ADMISSION_VALUE[adm];
    if (gate !== 'OTSUT') port.gate = GATE_VALUE[gate];
    return port;
  }

  const VHOD_TABLICA: Array<{
    form: 'NEPODKLYUCHEN' | 'PUSTOJ' | 'CHASTICHNYJ' | 'POLNYJ';
    adm: TablicaAdmission;
    gate: TablicaGate;
    port: TablicaPort | undefined;
  }> = [
    { form: 'NEPODKLYUCHEN', adm: 'OTSUT', gate: 'OTSUT', port: undefined },
    { form: 'PUSTOJ', adm: 'OTSUT', gate: 'OTSUT', port: {} },
  ];
  for (const adm of ['W0', 'W1A', 'NULL', 'NEIZVESTNOE'] as const) {
    VHOD_TABLICA.push({ form: 'CHASTICHNYJ', adm, gate: 'OTSUT', port: tablicaPort(adm, 'OTSUT') });
  }
  for (const gate of ['CURRENT', 'STALE', 'NULL', 'NEIZVESTNOE'] as const) {
    VHOD_TABLICA.push({ form: 'CHASTICHNYJ', adm: 'OTSUT', gate, port: tablicaPort('OTSUT', gate) });
  }
  for (const adm of ['W0', 'W1A', 'NULL', 'NEIZVESTNOE'] as const) {
    for (const gate of ['CURRENT', 'STALE', 'NULL', 'NEIZVESTNOE'] as const) {
      VHOD_TABLICA.push({ form: 'POLNYJ', adm, gate, port: tablicaPort(adm, gate) });
    }
  }

  async function renderAppTablica(port: TablicaPort | undefined, scheme: ColorScheme) {
    return render(
      <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
        <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
          <PilotApp {...ports()} onboarding={port as unknown as OnboardingPort | undefined} />
        </ThemeContext.Provider>
      </SafeAreaInsetsContext.Provider>,
    );
  }

  // Каждая строка × тема — клетка. Арбитраж нарезки 117↔118 (семантика
  // frozen 118/1 инв. 4–5): admission решает ПОВЕРХНОСТЬ — W1A →
  // Erstinformation при ЛЮБОМ gate (маркер gate; при не-current Start
  // закрыт, continue НЕ переводит); переход W1A ∧ current → continue →
  // Start; все строки с admission ≠ W1A — прежний путь B (кадр code).
  // Г0 наблюдается на кадрах email (все строки) и code (не-W1A строки)
  // в обеих темах (блокер 2 круга 2: рестайл отклонённого gate ловится
  // строками с gate ≠ current).
  const gateMarkerOf: Record<TablicaGate, string> = {
    CURRENT: 'current', STALE: 'stale', NULL: 'null', OTSUT: 'null', NEIZVESTNOE: 'future',
  };
  for (const row of VHOD_TABLICA) {
    const w1a = row.adm === 'W1A';
    const gateCurrent = row.gate === 'CURRENT';
    for (const scheme of ['dark', 'light'] as const) {
      const S = scheme.toUpperCase();

      it(`MIGRACIYA_TABLICA_${row.form}_${row.adm}_${row.gate}_${S}`, async () => {
        const api = await renderAppTablica(row.port, scheme);
        await fireEvent.press(await screen.findByTestId('first-run-continue'));
        await screen.findByTestId('auth-email');
        let rootStyle = styleOf(hostRootOf(api.toJSON()));
        expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
        expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
        expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
        expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
        await fireEvent.press(screen.getByTestId('auth-demo-entry'));
        if (w1a) {
          await screen.findByTestId('erstinformation-117');
          expect(screen.queryByTestId(`erstinfo_gate_${gateMarkerOf[row.gate]}`)).not.toBeNull();
          expect(screen.queryByTestId('start_tabs')).toBeNull();
          expect(screen.queryByTestId('auth-code')).toBeNull();
          await fireEvent.press(screen.getByTestId('erstinfo_continue_start'));
          if (gateCurrent) {
            await screen.findByTestId('start_tabs');
          } else {
            expect(screen.queryByTestId('start_tabs')).toBeNull();
            expect(screen.queryByTestId('erstinformation-117')).not.toBeNull();
          }
        } else {
          await screen.findByTestId('auth-code');
          expect(screen.queryByTestId('erstinformation-117')).toBeNull();
          expect(screen.queryByTestId('start_tabs')).toBeNull();
          rootStyle = styleOf(hostRootOf(api.toJSON()));
          expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
          expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
          expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
          expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
        }
      });
    }
  }

  // ---- 117 v3 (арбитраж нарезки 117↔118, круг 3): клетки (а)–(д) ----
  // Модель пинит чтение допуска ТОЛЬКО из onboarding.admission/gate:
  // entry (в т.ч. entry.onboarding='complete' — production-поле порта)
  // и посторонние поля порта (authenticated) не создают допуск;
  // начальный кадр 'first-run' при любом entry/порте; Г0 после смены
  // схемы в живом экземпляре; порядок Start при смене темы на
  // Erstinformation; порт читается в момент действия (rerender).

  type EntryOnboardingAxis = 'COMPLETE' | 'UNKNOWN' | 'INCOMPLETE' | 'OTSUT';
  const ENTRY_ONBOARDING_VALUE: Record<EntryOnboardingAxis, string | undefined> = {
    COMPLETE: 'complete', UNKNOWN: 'unknown', INCOMPLETE: 'incomplete', OTSUT: undefined,
  };
  const ENTRY_AXIS: Array<EntryOnboardingAxis> = ['COMPLETE', 'UNKNOWN', 'INCOMPLETE', 'OTSUT'];
  // Постороннее поле entry.gate='current' несёт КАЖДЫЙ вход оси: gate
  // читается из сессии, не из entry (r3-gate-from-entry).
  function entryFor(axis: EntryOnboardingAxis) {
    const onboarding = ENTRY_ONBOARDING_VALUE[axis];
    return {
      source: 'ENTRY-117',
      ...(onboarding === undefined ? {} : { onboarding }),
      gate: 'current',
    } as { source: string; onboarding?: string; gate: string };
  }
  const ENTRY_PAIRS = [
    { pair: 'W0_STALE', onboarding: { admission: 'W0', gate: 'stale' } as OnboardingPort },
    { pair: 'W0_CURRENT', onboarding: { admission: 'W0', gate: 'current' } as OnboardingPort },
    { pair: 'W1A_STALE', onboarding: { admission: 'W1A', gate: 'stale' } as OnboardingPort },
    { pair: 'W1A_CURRENT', onboarding: { admission: 'W1A', gate: 'current' } as OnboardingPort },
    { pair: 'NEPODKLYUCHEN', onboarding: undefined as OnboardingPort | undefined },
  ];

  async function renderAppEntry(
    entry: { source: string; onboarding?: string; gate: string },
    onboarding: OnboardingPort | undefined,
    scheme: ColorScheme,
  ) {
    return render(
      <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
        <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
          <PilotApp {...ports()} entry={entry as never} onboarding={onboarding} />
        </ThemeContext.Provider>
      </SafeAreaInsetsContext.Provider>,
    );
  }

  // (а) ось entry.onboarding × решающие пары порта × 2 темы: ожидание
  // клетки НЕ меняется относительно её пары (entry не источник допуска;
  // r3-admission-literal-completed, r3-gate-from-entry).
  for (const axis of ENTRY_AXIS) {
    for (const pair of ENTRY_PAIRS) {
      const w1a = pair.pair === 'W1A_STALE' || pair.pair === 'W1A_CURRENT';
      const gateCurrent = pair.pair === 'W1A_CURRENT';
      const gateMarker = gateCurrent ? 'current' : 'stale';
      for (const scheme of ['dark', 'light'] as const) {
        const S = scheme.toUpperCase();

        it(`MIGRACIYA_ENTRY_${axis}_${pair.pair}_${S}`, async () => {
          await renderAppEntry(entryFor(axis), pair.onboarding, scheme);
          await fireEvent.press(await screen.findByTestId('first-run-continue'));
          await screen.findByTestId('auth-email');
          await fireEvent.press(screen.getByTestId('auth-demo-entry'));
          if (w1a) {
            await screen.findByTestId('erstinformation-117');
            expect(screen.queryByTestId(`erstinfo_gate_${gateMarker}`)).not.toBeNull();
            expect(screen.queryByTestId('start_tabs')).toBeNull();
            expect(screen.queryByTestId('auth-code')).toBeNull();
            await fireEvent.press(screen.getByTestId('erstinfo_continue_start'));
            if (gateCurrent) {
              await screen.findByTestId('start_tabs');
            } else {
              expect(screen.queryByTestId('start_tabs')).toBeNull();
              expect(screen.queryByTestId('erstinformation-117')).not.toBeNull();
            }
          } else {
            await screen.findByTestId('auth-code');
            expect(screen.queryByTestId('erstinformation-117')).toBeNull();
            expect(screen.queryByTestId('start_tabs')).toBeNull();
          }
        });
      }
    }
  }

  // (а′) постороннее truthy-поле порта authenticated:true при W0/stale:
  // соседнее поле не заменяет пару admission/gate (r3-extra-authenticated).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED_W0_STALE_${S}`, async () => {
      const port = { admission: 'W0', gate: 'stale', authenticated: true } as never;
      await render(
        <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
          <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
            <PilotApp {...ports()} onboarding={port} />
          </ThemeContext.Provider>
        </SafeAreaInsetsContext.Provider>,
      );
      await fireEvent.press(await screen.findByTestId('first-run-continue'));
      await screen.findByTestId('auth-email');
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await screen.findByTestId('auth-code');
      expect(screen.queryByTestId('erstinformation-117')).toBeNull();
      expect(screen.queryByTestId('start_tabs')).toBeNull();
    });
  }

  // (б) начальный кадр 'first-run' при ЛЮБОМ entry и любом порте —
  // первый рендер без Start и без Erstinformation (r3-restart-completed-
  // start: сохранённый entry.onboarding='complete' не создаёт Start).
  for (const axis of ENTRY_AXIS) {
    for (const pair of ENTRY_PAIRS) {
      for (const scheme of ['dark', 'light'] as const) {
        const S = scheme.toUpperCase();

        it(`MIGRACIYA_NACHALNYJ_KADR_${axis}_${pair.pair}_${S}`, async () => {
          await renderAppEntry(entryFor(axis), pair.onboarding, scheme);
          expect(await screen.findByTestId('first-run-continue')).toBeTruthy();
          expect(screen.queryByTestId('start_tabs')).toBeNull();
          expect(screen.queryByTestId('erstinformation-117')).toBeNull();
        });
      }
    }
  }

  // (б′) remount с сохранённым completed-entry и W0/stale: второе
  // монтирование — то же наблюдение (First-Run, не Start).
  it('MIGRACIYA_REMOUNT_ENTRY_COMPLETE_W0_STALE', async () => {
    const entry = entryFor('COMPLETE');
    const p = ports();
    const tree = () => (
      <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
        <ThemeContext.Provider value={{ scheme: 'dark', tokens: themeTokens.dark }}>
          <PilotApp {...p} entry={entry as never} onboarding={{ admission: 'W0', gate: 'stale' }} />
        </ThemeContext.Provider>
      </SafeAreaInsetsContext.Provider>
    );
    const first = await render(tree());
    expect(await first.findByTestId('first-run-continue')).toBeTruthy();
    await first.unmount();
    const second = await render(tree());
    expect(await second.findByTestId('first-run-continue')).toBeTruthy();
    expect(second.queryByTestId('start_tabs')).toBeNull();
    expect(second.queryByTestId('erstinformation-117')).toBeNull();
  });

  // (в) Г0 F03.01/F03.02 после смены схемы в живом экземпляре, ОБЕ
  // стороны (dark→light и light→dark), на недопуске с ПОДКЛЮЧЁННЫМ
  // портом (r3-g0-theme-change: рестайл корня после смены схемы).
  const TEMA_SMENY = [
    { name: 'DARK_TO_LIGHT', from: 'dark' as ColorScheme, to: 'light' as ColorScheme },
    { name: 'LIGHT_TO_DARK', from: 'light' as ColorScheme, to: 'dark' as ColorScheme },
  ];
  function expectG0(api: { toJSON: () => unknown }) {
    const rootStyle = styleOf(hostRootOf(api.toJSON()));
    expect(rootStyle.backgroundColor).toBe(SURFACE_995_BG);
    expect(rootStyle.paddingTop).toBe(SURFACE_995_PAD_TOP);
    expect(rootStyle.paddingHorizontal).toBe(SURFACE_995_PAD_H);
    expect(rootStyle.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
  }
  for (const t of TEMA_SMENY) {
    it(`MIGRACIYA_G0_SMENA_TEMY_${t.name}`, async () => {
      const p = ports();
      const onboarding: OnboardingPort = { admission: 'W0', gate: 'stale' };
      const tree = (scheme: ColorScheme) => (
        <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
          <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
            <PilotApp {...p} onboarding={onboarding} />
          </ThemeContext.Provider>
        </SafeAreaInsetsContext.Provider>
      );
      const api = await render(tree(t.from));
      await fireEvent.press(await screen.findByTestId('first-run-continue'));
      await screen.findByTestId('auth-email');
      expectG0(api);
      api.rerender(tree(t.to));
      await screen.findByTestId('auth-email');
      expectG0(api);
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await screen.findByTestId('auth-code');
      expectG0(api);
    });
  }

  // (г) смена схемы на Erstinformation БЕЗ нажатия continue → Start
  // отсутствует; затем continue → Start (r3-order-theme-autostart).
  for (const t of TEMA_SMENY) {
    it(`MIGRACIYA_PORYADOK_SMENA_TEMY_${t.name}`, async () => {
      const p = ports();
      const onboarding: OnboardingPort = { admission: 'W1A', gate: 'current' };
      const tree = (scheme: ColorScheme) => (
        <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
          <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
            <PilotApp {...p} onboarding={onboarding} />
          </ThemeContext.Provider>
        </SafeAreaInsetsContext.Provider>
      );
      const api = await render(tree(t.from));
      await fireEvent.press(await screen.findByTestId('first-run-continue'));
      await screen.findByTestId('auth-email');
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await screen.findByTestId('erstinformation-117');
      expect(screen.queryByTestId('start_tabs')).toBeNull();
      api.rerender(tree(t.to));
      await screen.findByTestId('erstinformation-117');
      expect(screen.queryByTestId('start_tabs')).toBeNull();
      await fireEvent.press(screen.getByTestId('erstinfo_continue_start'));
      await screen.findByTestId('start_tabs');
    });
  }

  // (д) порт читается в МОМЕНТ действия: rerender W1A→W0 до демо →
  // недопуск, прежний путь B (r3-cached-admission: кэш admission не
  // открывает маршрут).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();

    it(`MIGRACIYA_RERENDER_W1A_W0_${S}`, async () => {
      const p = ports();
      const tree = (onboarding: OnboardingPort) => (
        <SafeAreaInsetsContext.Provider value={{ top: 47, right: 0, bottom: 0, left: 0 }}>
          <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
            <PilotApp {...p} onboarding={onboarding} />
          </ThemeContext.Provider>
        </SafeAreaInsetsContext.Provider>
      );
      const api = await render(tree({ admission: 'W1A', gate: 'current' }));
      await fireEvent.press(await screen.findByTestId('first-run-continue'));
      await screen.findByTestId('auth-email');
      api.rerender(tree({ admission: 'W0', gate: 'current' }));
      await screen.findByTestId('auth-email');
      await fireEvent.press(screen.getByTestId('auth-demo-entry'));
      await screen.findByTestId('auth-code');
      expect(screen.queryByTestId('erstinformation-117')).toBeNull();
      expect(screen.queryByTestId('start_tabs')).toBeNull();
    });
  }
});
