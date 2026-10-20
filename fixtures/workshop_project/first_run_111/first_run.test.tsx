// 111 First-Run (CMP-MOB-005): поведенческая батарея. Оракул — source.json
// каталога D2.2.5.1, снятый с read-only docs/ Complior-mob 76ac10fa ДО
// запуска субъекта; все ожидания — ЛИТЕРАЛЫ ниже (правило 8, Н-351: ни одна
// клетка не сверяется значением, прочитанным у субъекта). Вход (провайдер
// темы) — themeTokens 999; ожидание — токены-литералы source.json. К7:
// мок-провайдер safe-area (SafeAreaInsetsContext) с литеральными insets.
import { cleanup, fireEvent, render, screen, waitFor, within } from '@testing-library/react-native';
import React from 'react';
import { SafeAreaInsetsContext } from 'react-native-safe-area-context';


import { PilotApp } from '@/bootstrap/pilot-app';
import { ThemeContext } from '@/theme/context';
import { themeTokens, type ColorScheme } from '@/theme/tokens';

// ---- EXPECT: литералы оракула (source.json, побайтово) ----
const PROMISE = 'Sie sagen, was passiert ist. Complior kümmert sich um den Rest.';
const CTA = 'Anmelden oder Konto erstellen';
const FRAME_F03_01_TITLE = 'Anmelden oder Konto erstellen';
const GROUND_DARK = '#0a0a0a';
const GROUND_LIGHT = '#f3f2ee';
const INK_DARK = '#f2f1ec';
const INK_LIGHT = '#121211';
const WORDMARK_LABEL = 'complior';
// source.json wordmark.asset = 'mobile/assets/images/wordmark-dark.png'
const WORDMARK_ASSET = 'wordmark-dark.png';
const DEMO = 'Demo';
// К7: литеральные top-инсеты мока (top>0); пара значений — отслеживание:
// честный отступ обязан равняться текущему литералу, хардкод любого одного
// из них красен на втором рендере клетки.
const INSET_TOP_A = 47;
const INSET_TOP_B = 59;
// К8 (С10/Р2, ревью круга 3): кадры 995 (F03.01+, welcome) — поверхность
// 995, не рестайлятся (frozen 111/1 стр. 41–42, 80–83 «Вне предмета»):
// внешний корень PilotApp на них несёт литералы 995 — фон #FFFFFF и
// отступы 48/16/16; {flex:1, ground} — только first-run (его судит К6).
// Литералы — ожидания файла (поверхность 995), не значения субъекта
// (Н-379/Н-383). WELCOME_SUMMARY — testID summary-узла кадра welcome.
const SURFACE_995_BG = '#FFFFFF';
const SURFACE_995_PAD_TOP = 48;
const SURFACE_995_PAD_H = 16;
const SURFACE_995_PAD_BOTTOM = 16;
const WELCOME_SUMMARY = 'F02.01';
// Канон D2.2.5.1 не объявляет усечённого набора краёв для First-Run:
// действующая safe-area = все четыре края (кодировка нативного шва
// react-native-safe-area-context: 'additive' = край защищён, 'off' = снят).
const EDGES_ALL_ACTIVE = {
  top: 'additive',
  right: 'additive',
  bottom: 'additive',
  left: 'additive',
};

function ports(verifyStatus: 'invalid' | 'authenticated' = 'invalid') {
  return {
    auth: {
      begin: jest.fn(async (email: string) => ({ challenge: email, evidence: 'SYNTHETIC' })),
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

// К7:SafeAreaInsetsContext.Provider — литеральный мок insets (top>0) без
// host-узлов: дерево toJSON не меняется (К6 судит корень PilotApp), а
// useSafeAreaInsets() субъекта возвращает литерал провайдера. react-native-
// safe-area-context 5.7: SafeAreaView применяет инсет нативно (в Jest не
// наблюдаем), поэтому наблюдаемая кодировка честной модели — потребление
// инсета через useSafeAreaInsets (дословно совет починки R1).
async function renderFirstRun(
  scheme: ColorScheme,
  insetTop: number = INSET_TOP_A,
  verifyStatus: 'invalid' | 'authenticated' = 'invalid',
) {
  return render(
    <SafeAreaInsetsContext.Provider value={{ top: insetTop, right: 0, bottom: 0, left: 0 }}>
      <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
        <PilotApp {...ports(verifyStatus)} />
      </ThemeContext.Provider>
    </SafeAreaInsetsContext.Provider>,
  );
}

function styleOf(node: { props: { style?: unknown } }): Record<string, unknown> {
  const style = node.props.style;
  if (Array.isArray(style)) {
    return Object.assign({}, ...style.map((s: unknown) => (s ? s : {})));
  }
  return (style as Record<string, unknown>) ?? {};
}

function backgroundOf(node: { props: { style?: unknown } }): unknown {
  return styleOf(node).backgroundColor;
}

function colorOf(node: { props: { style?: unknown } }): unknown {
  return styleOf(node).color;
}

// К8: внешний host-корень дерева PilotApp (Provider-обёртки — не host-узлы,
// toJSON их не печатает; первый печатный узел = корень PilotApp).
function hostRootOf(json: unknown): { type?: unknown; props: { style?: unknown } } {
  return (Array.isArray(json) ? json[0] : json) as { type?: unknown; props: { style?: unknown } };
}

function textOf(node: { props: { children?: unknown } }): string {
  const children = node.props.children;
  if (typeof children === 'string') return children;
  throw Error('textOf: не строковый children');
}

// К7: вертикальные отступы (paddingTop+marginTop) каждого узла цепи
// бейдж→…→корень (включая сам бейдж); composit-узлы без style дают 0.
// Клетка требует, чтобы один из них РАВНЯЛСЯ top-инсету мока — отступ
// применяется выше бейджа, значит его верх (и центр) ниже инсета.
function nodeTopOffsets(badge: unknown): number[] {
  const out: number[] = [];
  let node: unknown = badge;
  while (node) {
    const inst = node as { parent?: unknown; props?: { style?: unknown } };
    if (inst.props) {
      const style = styleOf(inst as { props: { style?: unknown } });
      out.push((Number(style.paddingTop) || 0) + (Number(style.marginTop) || 0));
    }
    node = inst.parent;
  }
  return out;
}

// Все текстовые листья host-дерева (toJSON): видимая поверхность экрана.
function collectText(json: unknown, out: string[]): void {
  if (Array.isArray(json)) {
    json.forEach((child) => collectText(child, out));
    return;
  }
  if (json && typeof json === 'object') {
    const node = json as { children?: unknown[] };
    if (node.children) collectText(node.children, out);
    return;
  }
  if (typeof json === 'string') out.push(json);
}

describe('111 first-run', () => {
  // К1 структура: произведение scheme(2) на первом рендере '/'; в каждой
  // клетке наблюдаются ВСЕ заявленные элементы: wordmark (label/role),
  // promise (текст+ink), CTA (testID 995+role+label), Demo-бейдж, контейнер
  // safe-area на ground схемы.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`FIRST_RUN_STRUCTURE_${S}`, async () => {
      await renderFirstRun(scheme);
      const wordmark = screen.getByTestId('first-run-wordmark');
      expect(wordmark.props.accessibilityLabel).toBe(WORDMARK_LABEL);
      expect(wordmark.props.accessibilityRole).toBe('image');
      expect(screen.getByText(PROMISE)).toBeOnTheScreen();
      expect(colorOf(screen.getByText(PROMISE))).toBe(scheme === 'dark' ? INK_DARK : INK_LIGHT);
      const cta = screen.getByTestId('first-run-continue');
      expect(cta.props.accessibilityRole).toBe('button');
      expect(within(cta).getByText(CTA)).toBeOnTheScreen();
      const badge = screen.getByTestId('demo-indicator');
      expect(within(badge).getByText(DEMO)).toBeOnTheScreen();
      expect(backgroundOf(screen.getByTestId('first-run-safe-area'))).toBe(
        scheme === 'dark' ? GROUND_DARK : GROUND_LIGHT,
      );
    });
  }

  // К2 переход (семантика 995 сохранена): CTA открывает F03.01 — кадр email
  // с заголовком frame.F03.01.title и полем auth-email; бренд-элементы
  // First-Run исчезают без остатка. Переход обязателен в ОБЕИХ схемах темы
  // (инвариант 8): мутант «CTA навигирует только в dark» красен LIGHT-клеткой.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`CTA_OPENS_F03_01_${S}`, async () => {
      await renderFirstRun(scheme);
      await fireEvent.press(screen.getByTestId('first-run-continue'));
      expect(screen.getByText(FRAME_F03_01_TITLE)).toBeOnTheScreen();
      expect(screen.getByTestId('auth-email')).toBeOnTheScreen();
      expect(screen.queryByText(PROMISE)).toBeNull();
      expect(screen.queryByTestId('first-run-wordmark')).toBeNull();
      expect(screen.queryByTestId('first-run-continue')).toBeNull();
    });
  }

  // К2′ текст CTA = ui.first_run.enter_f03 = frame.F03.01.title (факт
  // каталога, equality_facts source.json): наблюдаемый label CTA до нажатия
  // байт-равен наблюдаемому заголовку F03.01 после нажатия и литералу.
  it('CTA_TEXT_EQUALS_FRAME_TITLE', async () => {
    await renderFirstRun('dark');
    const label = textOf(within(screen.getByTestId('first-run-continue')).getByText(CTA));
    expect(label).toBe(CTA);
    await fireEvent.press(screen.getByTestId('first-run-continue'));
    // заголовок ищется РОЛЬЮ, не текстом: на застрявшем First-Run сам CTA
    // несёт тот же текст (equality_facts) и не должен засчитываться кадром.
    const header = screen.getByRole('header');
    expect(textOf(header)).toBe(label);
    expect(textOf(header)).toBe(FRAME_F03_01_TITLE);
  });

  // К3 действующая safe-area (шифр канона не объявляет усечения краёв),
  // произведение scheme(2) — инвариант объявлен без исключения по схеме:
  // наблюдаем нативный шов библиотеки в ОБЕИХ схемах — SafeAreaView
  // конвертирует edges в карту краёв; все четыре 'additive' = защита краёв
  // действует. edges={[]} или частичный набор дают 'off' — клетка красна
  // (отключённая нативно safe-area при живом импорте и цвете — не safe-area).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`SAFEAREA_EDGES_ACTIVE_${S}`, async () => {
      await renderFirstRun(scheme);
      const container = screen.getByTestId('first-run-safe-area');
      expect(container.props.edges).toEqual(EDGES_ALL_ACTIVE);
    });
  }

  // К4 wordmark-ассет связан с экраном, произведение scheme(2): Image.source
  // наблюдаемого wordmark указывает на ассет wordmark-dark.png (литерал имени
  // из source.json) в ОБЕИХ схемах. Подмена source на соседний ассет
  // (splash-icon.png) при сохранённых label/role/testID красит клетку.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`WORDMARK_SOURCE_BOUND_${S}`, async () => {
      await renderFirstRun(scheme);
      const wordmark = screen.getByTestId('first-run-wordmark');
      const source = wordmark.props.source as { testUri?: unknown } | undefined;
      expect(source && typeof source === 'object' && 'testUri' in source).toBe(true);
      expect(String(source.testUri)).toContain(WORDMARK_ASSET);
    });
  }

  // К5 закрытый состав видимой копии First-Run, произведение scheme(2):
  // каждый текстовый лист host-дерева ⊆ литеральный перечень
  // {Demo, promise, CTA} в ОБЕИХ схемах. Каталог D2.2.5.1 даёт First-Run
  // ровно два текстовых ключа; «Demo» — метка mock composition
  // (STRUCTURE.md §5). Некаталожная немецкая строка на поверхности (напр.
  // саблайн эталонного HTML без ключа каталога) красит — в любой схеме.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`FIRST_RUN_COPY_CLOSED_${S}`, async () => {
      const { toJSON } = await renderFirstRun(scheme);
      const leaves: string[] = [];
      collectText(toJSON(), leaves);
      const visible = leaves.map((t) => t.trim()).filter((t) => t.length > 0);
      expect(visible.length > 0).toBe(true);
      for (const t of visible) {
        expect([DEMO, PROMISE, CTA]).toContain(t);
      }
    });
  }

  // К6 полная поверхность кадра, произведение scheme(2) (A2, суд круг 1):
  // наблюдаемый внешний узел First-Run-кадра (корень PilotApp — Provider
  // не host-узел) окрашен ground текущей темы (литералы токенов), заполняет
  // поверхность (flex 1) и не несёт отступок (отсутствуют или нулевые) —
  // вокруг SafeAreaView нет рамки/полос другого цвета. Мутанты: корень
  // #FFFFFF (белая рамка заглушки), #ff00ff (обход адверсария: не-ground
  // цвет проходил все прежние клетки), отступы 48/16/16.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`FIRST_RUN_GROUND_FULL_SURFACE_${S}`, async () => {
      const { toJSON } = await renderFirstRun(scheme);
      const json = toJSON();
      const root = (Array.isArray(json) ? json[0] : json) as
        { type?: unknown; props: { style?: unknown } };
      expect(root).toBeDefined();
      expect(root.type).toBe('View');
      expect(backgroundOf(root)).toBe(scheme === 'dark' ? GROUND_DARK : GROUND_LIGHT);
      const style = styleOf(root);
      expect(style.flex).toBe(1);
      expect([undefined, 0]).toContain(style.paddingTop);
      expect([undefined, 0]).toContain(style.paddingHorizontal);
      expect([undefined, 0]).toContain(style.paddingBottom);
    });
  }

  // К7 Demo-бейдж внутри safe-area (R1, ревью круг 2), произведение scheme(2):
  // на устройстве круга 2 бейдж [0,0][137,64] лежал целиком в статус-баре —
  // вне safe-area экрана. Наблюдение: вертикальный отступ бейджа (paddingTop
  // или marginTop какого-то узла цепи бейдж→корень, включая сам бейдж) равен
  // top-инсету провайдера-мока; два литеральных значения (47, 59) — отслежи-
  // вание: отступ обязан меняться за инсетом, хардкод измеренного 47 красен
  // на втором рендере. Мутанты: бейдж без safe-отступа (форма продукта круга
  // 2), paddingTop: 0, хардкод 47.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`DEMO_BADGE_INSET_${S}`, async () => {
      for (const insetTop of [INSET_TOP_A, INSET_TOP_B]) {
        await renderFirstRun(scheme, insetTop);
        const badge = screen.getByTestId('demo-indicator');
        expect(nodeTopOffsets(badge)).toContain(insetTop);
        // RNTL 14: между рендерами внутри одного теста — await cleanup()
        // (сбрасывает screen и очередь размонтирований); ручной unmount()
        // оставляет screen на размонтированном дереве и валит СЛЕДУЮЩИЙ
        // тест файла (замер: LIGHT-клетка краснела «Unable to find»).
        await cleanup();
      }
    });
  }

  // К8 рестайл-страж кадров 995 (С10/Р2, ревью круга 3), произведение
  // scheme(2): переход CTA (путь устройства из Р2) приводит в F03.01 —
  // внешний корень PilotApp на кадре 995 несёт литералы поверхности 995:
  // фон #FFFFFF и отступы 48/16/16. Рестайл круга 3 (ground на всех кадрах,
  // root без отступов) красит в обеих схемах; К6 при этом зелёная —
  // first-run-кадр не тронут. Мутанты: restyle-995-ground (merged-root,
  // красит и К6 — отступки root проявляются на first-run),
  // restyle-995-no-padding, restyle-995-padding-shifted, а
  // restyle-welcome-ground красит ТОЛЬКО К8′.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`RESTYLE_GUARD_995_F03_01_${S}`, async () => {
      const view = await renderFirstRun(scheme);
      await fireEvent.press(screen.getByTestId('first-run-continue'));
      expect(screen.getByTestId('auth-email')).toBeOnTheScreen();
      const root = hostRootOf(view.toJSON());
      expect(root.type).toBe('View');
      expect(backgroundOf(root)).toBe(SURFACE_995_BG);
      const style = styleOf(root);
      expect(style.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(style.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(style.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }

  // К8′ та же поверхность 995 на кадре welcome: полный поток
  // (CTA → F03.01 → demo-entry → code → verify authenticated) — корень
  // обязан остаться литералами 995. Welcome-only рестайл (ground только на
  // welcome) красит ТОЛЬКО эту пару — К8 и К6 зелёны.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`RESTYLE_GUARD_995_WELCOME_${S}`, async () => {
      const view = await renderFirstRun(scheme, INSET_TOP_A, 'authenticated');
      await fireEvent.press(screen.getByTestId('first-run-continue'));
      await fireEvent.press(await screen.findByTestId('auth-demo-entry'));
      await fireEvent.press(await screen.findByTestId('auth-verify'));
      await waitFor(() => expect(screen.getByTestId(WELCOME_SUMMARY)).toBeOnTheScreen());
      const root = hostRootOf(view.toJSON());
      expect(root.type).toBe('View');
      expect(backgroundOf(root)).toBe(SURFACE_995_BG);
      const style = styleOf(root);
      expect(style.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(style.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(style.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }
});
