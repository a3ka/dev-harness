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
});
