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
// v4 (слово владельца 2026-10-22 ~18:50 UTC «а», форк n135-copy-111):
// две строки макета First-Run.png (sha256 0411d0a3…, кадр First-Run dark/light
// манифеста 135) — дословно, без ключей i18n (инвариант 4 «+2 ровно» не
// меняется); реализация 135 несёт те же байты (FIRST_RUN_BODY/FOOTER).
const SUBHEADLINE =
  'Ein Brief, ein Schaden, ein neues Auto – sagen Sie es. Complior liest, erklärt, vergleicht und erledigt. Sie bestätigen nur, was wirklich zählt.';
const FOOTER = 'Versicherung. Erledigt.';
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
// К8 v2 (сужение гварда RESTYLE_GUARD_995 — слово владельца 2026-10-20
// ~18:00/18:18 UTC, ответ консультанта 19:20, форк n117-krug1-maket-i-111,
// развилка 1 (А)): гвард держит кадры 995 КРОМЕ F03.01/F03.02 (email/code —
// их рестайл принадлежит предмету 117, вход по D2.2.5.1). На защищаемых
// кадрах (welcome и прочие) внешний корень PilotApp несёт литералы 995 —
// фон #FFFFFF и отступки 48/16/16; {flex:1, ground} — только first-run
// (его судит К6). Литералы — ожидания файла (поверхность 995), не значения
// субъекта (Н-379/Н-383). WELCOME_SUMMARY — testID summary-узла кадра welcome.
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

function ports(
  verifyStatus: 'invalid' | 'authenticated' = 'invalid',
  beginStatus: 'ok' | 'unavailable' = 'ok',
) {
  return {
    auth: {
      // К9: begin со status 'unavailable' — публичный порт перевода
      // PilotApp в кадр unavailable (handleDemoEntry: status unavailable
      // → setFrame('unavailable')).
      begin: jest.fn(async (email: string) =>
        beginStatus === 'unavailable'
          ? { challenge: email, evidence: 'SYNTHETIC', status: 'unavailable' as const }
          : { challenge: email, evidence: 'SYNTHETIC' },
      ),
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
  beginStatus: 'ok' | 'unavailable' = 'ok',
) {
  return render(
    <SafeAreaInsetsContext.Provider value={{ top: insetTop, right: 0, bottom: 0, left: 0 }}>
      <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
        <PilotApp {...ports(verifyStatus, beginStatus)} />
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

// Все текстовые листья ВИДИМОГО host-дерева (toJSON): видимая поверхность
// экрана. v4c (критик круг 2): текст скрытого узла — НЕ присутствующий:
// display:'none', opacity 0 (и нулевые литеральные width/height) на узле
// ИЛИ любом его предке вырезают поддерево целиком — «наличие строки»
// обязано судить видимость, не присутствие в дереве (обход круга 2:
// display:none внутри зоны implementer проходил honest rc0 23/23).
function hiddenByStyle(node: { props?: { style?: unknown } }): boolean {
  if (!node.props) return false;
  const style = styleOf(node as { props: { style?: unknown } });
  if (style.display === 'none') return true;
  if (style.opacity === 0 || style.opacity === '0') return true;
  return style.width === 0 || style.height === 0;
}

function collectText(json: unknown, out: string[]): void {
  if (Array.isArray(json)) {
    json.forEach((child) => collectText(child, out));
    return;
  }
  if (json && typeof json === 'object') {
    const node = json as { children?: unknown[]; props?: { style?: unknown } };
    if (hiddenByStyle(node)) return;
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
  // {Demo, promise, CTA, подзаголовок макета, футер макета} в ОБЕИХ схемах
  // — И НАОБОРОТ: обе строки макета обязаны ПРИСУТСТВОВАТЬ на экране
  // (v4b, критик 111 v4 круг 1): «каталог += две строки» — наличие, а не
  // только допустимость; экран с удалёнными рендерящими узлами проходил
  // замкнутость (ложное зелёное rc0 23/23). Отсутствие подзаголовка или
  // футера полным текстом красит клетку своей схемы. v4c (критик круг 2):
  // ПРИСУТСТВОВАТЬ = быть ВИДИМЫМ — collectText вырезает поддеревья с
  // display:'none'/opacity 0/нулевыми литеральными размерами (узел или
  // любой предок); скрытая строка не считается присутствующей.
  // Каталог D2.2.5.1 даёт First-Run ровно два текстовых ключа; «Demo» —
  // метка mock composition (STRUCTURE.md §5); v4 (слово владельца
  // 2026-10-22 ~18:50 UTC «а»): две строки макета First-Run.png разрешены
  // дословно (SUBHEADLINE/FOOTER выше), без ключей i18n. Строка вне
  // перечня красит — в любой схеме, в т.ч. неточное совпадение с
  // каталогизированной строкой (сокращённая форма саблайна).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`FIRST_RUN_COPY_CLOSED_${S}`, async () => {
      const { toJSON } = await renderFirstRun(scheme);
      const leaves: string[] = [];
      collectText(toJSON(), leaves);
      const visible = leaves.map((t) => t.trim()).filter((t) => t.length > 0);
      expect(visible.length > 0).toBe(true);
      for (const t of visible) {
        expect([DEMO, PROMISE, CTA, SUBHEADLINE, FOOTER]).toContain(t);
      }
      // v4b: наличие обеих строк макета — удаление любого рендерящего
      // узла (или обоих) красит клетку этой схемы.
      expect(visible).toContain(SUBHEADLINE);
      expect(visible).toContain(FOOTER);
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

  // К8 v2 (сужение гварда, 111 v2): F03.01/F03.02 (email/code) гвардом НЕ
  // держатся — рестайл этих кадров принадлежит предмету 117 (вход по
  // D2.2.5.1; слово владельца 2026-10-20 ~18:00/18:18 UTC, консультант
  // 19:20, развилка 1 (А)). НЕ-ожидание рестайла: корень F03.01 вправе
  // нести как литералы поверхности 995 (база не рестайлит), так и
  // ground/токены схемы предмета 117 — стиль корня клетки НЕ сверяется.
  // Живёт шов исходной клетки (путь устройства из Р2): CTA приводит в
  // F03.01 в ОБЕИХ схемах — auth-email виден; разрыв навигации
  // (onenter-not-wired, cta-testid-renamed, light-cta-noop) красит и эту
  // пару. Поверхность 995 остальных кадров держит К8′ (welcome).
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`RESTYLE_GUARD_995_F03_01_${S}`, async () => {
      await renderFirstRun(scheme);
      await fireEvent.press(screen.getByTestId('first-run-continue'));
      expect(screen.getByTestId('auth-email')).toBeOnTheScreen();
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

  // К9 v2b (усиление гейта по Б1 критика круга 1): сужение К8 (разрешённый
  // рестайл ТОЛЬКО F03.01/F03.02 — email/code, предмет 117) не снимает
  // защиту остальных кадров 995. Кадры unavailable/recovery (F03.04)
  // достигаются по публичным портам PilotApp: recovery — CTA → demo-entry
  // → no-access; unavailable — auth.begin возвращает status 'unavailable'
  // → demo-entry. Корень обязан остаться литералами 995 (#FFFFFF +
  // 48/16/16) в ОБЕИХ схемах. Обход критика «frame !== 'welcome'»
  // (рестайл всей auth-ветви при нетронутых first-run/welcome) зелён в
  // К6/К8/К8′ и красен ТОЛЬКО здесь — собственное наблюдение каждого
  // кадра, не выводимое из welcome.
  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`RESTYLE_GUARD_995_RECOVERY_${S}`, async () => {
      const view = await renderFirstRun(scheme);
      await fireEvent.press(screen.getByTestId('first-run-continue'));
      await fireEvent.press(await screen.findByTestId('auth-demo-entry'));
      await fireEvent.press(await screen.findByTestId('auth-no-access'));
      expect(await screen.findByTestId('F03.04')).toBeOnTheScreen();
      const root = hostRootOf(view.toJSON());
      expect(root.type).toBe('View');
      expect(backgroundOf(root)).toBe(SURFACE_995_BG);
      const style = styleOf(root);
      expect(style.paddingTop).toBe(SURFACE_995_PAD_TOP);
      expect(style.paddingHorizontal).toBe(SURFACE_995_PAD_H);
      expect(style.paddingBottom).toBe(SURFACE_995_PAD_BOTTOM);
    });
  }

  for (const scheme of ['dark', 'light'] as const) {
    const S = scheme.toUpperCase();
    it(`RESTYLE_GUARD_995_UNAVAILABLE_${S}`, async () => {
      const view = await renderFirstRun(scheme, INSET_TOP_A, 'invalid', 'unavailable');
      await fireEvent.press(screen.getByTestId('first-run-continue'));
      await fireEvent.press(await screen.findByTestId('auth-demo-entry'));
      expect(await screen.findByTestId('auth-unavailable')).toBeOnTheScreen();
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
