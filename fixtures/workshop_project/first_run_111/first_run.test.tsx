// 111 First-Run (CMP-MOB-005): поведенческая батарея. Оракул — source.json
// каталога D2.2.5.1, снятый с read-only docs/ Complior-mob 76ac10fa ДО
// запуска субъекта; все ожидания — ЛИТЕРАЛЫ ниже (правило 8, Н-351: ни одна
// клетка не сверяется значением, прочитанным у субъекта). Вход (провайдер
// темы) — themeTokens 999; ожидание — токены-литералы source.json.
import { fireEvent, render, screen, within } from '@testing-library/react-native';
import React from 'react';

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
// Канон D2.2.5.1 не объявляет усечённого набора краёв для First-Run:
// действующая safe-area = все четыре края (кодировка нативного шва
// react-native-safe-area-context: 'additive' = край защищён, 'off' = снят).
const EDGES_ALL_ACTIVE = {
  top: 'additive',
  right: 'additive',
  bottom: 'additive',
  left: 'additive',
};

function ports() {
  return {
    auth: {
      begin: jest.fn(async (email: string) => ({ challenge: email, evidence: 'SYNTHETIC' })),
      verify: jest.fn(async () => ({ status: 'invalid', evidence: 'SYNTHETIC' })),
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

async function renderFirstRun(scheme: ColorScheme) {
  return render(
    <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
      <PilotApp {...ports()} />
    </ThemeContext.Provider>,
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

function textOf(node: { props: { children?: unknown } }): string {
  const children = node.props.children;
  if (typeof children === 'string') return children;
  throw Error('textOf: не строковый children');
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
});
