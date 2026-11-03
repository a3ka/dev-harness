// Батарея 148 (vkladki-tabov), живой jest-зонд (правка блоков 1 вердикта
// Crit148: класс «литерал на месте, исполняемое иное» закрывается
// ИСПОЛНЕНИЕМ на реальных компонентах R; v3a — вердикт Crit148k2a:
// измерения расширены с «слот/бейдж/абсолютный оверлей» до ФАКТИЧЕСКОЙ
// зоны нажатия (Б2) и ИСПОЛЬЗОВАНИЯ токенов 1.1 компонентом (Б3);
// v3b — вердикт Crit148k2b: (Б1) СВЯЗЬ компонента с токеном, не
// совпадение числа — высота лейсте == nav.height, minHeight вкладок ==
// nav.item.min-height, судятся равенством $value и следуют за
// подменённым значением источника (литерал 49 и final2 71 красны);
// (Б2) ДЕЙСТВУЮЩИЕ цели контента нажимаются с новым вызовом
// собственного колбэка (не унаследованным от предыдущей цели);
// (Б3) эффективная зона по RN height/min/max/padding по осям,
// измеренному тексту и hitSlop: конформные формы зелёные, зона <44 красна.
// Зонд пишется produkt_sud в ИЗОЛИРОВАННУЮ КОПИЮ mobile (node_modules —
// симлинк установки R) и запускается продуктовым jest; оракул текстов —
// каталог ui-copy самого R (литералов нет), геометрия — рендер-дерево
// RNTL, значения токенов — носитель vkladki-tokeny-148.json (дословная
// копия веток nav/touch-target пакета D24-Kompakt-1.1, включая
// nav.height; чисел в зонде нет). Измеряет предмет ИСПОЛНЕНИЕМ:
//   GA-02/04 — контент вкладок ДОСТИГАЕТ экрана через слот
//              sectionScreens живого TabShell (переход по нажатию);
//   GA-03    — бейдж «Ihre Rückmeldung nötig» из параметра маршрута
//              ?mitte=needs на живом маршруте (tabs)/[section];
//   GA-09    — таб-лейсте — АБСОЛЮТНЫЙ оверлей нижнего края, контент
//              вкладки НЕ внутри него (Inhalt läuft darunter);
//   Б1      — лейсте/вкладки СЛЕДУЮТ за токенами nav.height /
//              nav.item.min-height ($value 1.1; final2 71 краснеет
//              равенством);
//   Б2      — фактическая зона нажатия каждой объявленной цели
//              (эффективный бокс стиля РЕАЛЬНОГО Pressable по правилам
//              RN + невидимое расширение hitSlop) ≥ touch-target.min 44
//              на ОБОИХ профилях (390×844 и 393×852 — Dimensions.set);
//              цели лейсте ≥ nav.item.min-height 48; строки Vorgänge
//              ≥ 60 (зона манифеста 1.1); видимая рамка меньше зоны
//              находкой НЕ является (слово владельца 2026-11-02);
//   Б2-действие — обязательные цели контента ДОСТУПНЫ (не disabled) и
//              НАЖИМАЮТСЯ: событие доходит до колбэка контента;
//   Б3      — типографика вкладки ИСПОЛЬЗУЕТ токены 1.1: fontSize/
//              lineHeight надписи == nav.label.font-size /
//              nav.label.line-height ($value; литерал final2 11px
//              краснеет равенством).
// Зонд не знает о мутациях: каждый мутант судится исполнением,
// а не сравнением текста. Независимые зелёные контроли судьи проходят
// на конформных RN-формах (minHeight/padding/стороны/hitSlop) и
// подменённом значении источника токенов. Идиомы среды —
// как у тестов продукта (async render RNTL, press внутри act);
// react-native НЕ мокается целиком (урок 145 v1: спред requireActual
// в RN 0.86 роняет загрузку инвариантом TurboModuleRegistry) — профиль
// задаётся Dimensions.set.
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
  const m = /^(\d+)px$/.exec(znach);
  if (m === null) {
    throw new Error(`TOKEN_NE_PX: ${znach} — грамматика носителя 1.1 Npx`);
  }
  return Number(m[1]);
}

/** Нажатие — внутри act (идиома erstinformation-demo-path). */
async function nazhat(id: string) {
  await act(async () => {
    fireEvent.press(screen.getByTestId(id));
  });
}

/** Стиль узла рендер-дерева, сведённый StyleSheet.flatten. */
function stilUzla(uzol: unknown): { position?: string; bottom?: number; left?: number; right?: number } {
  const props = (uzol as { props?: { style?: unknown } }).props ?? {};
  return (StyleSheet.flatten([props.style]) ?? {}) as {
    position?: string;
    bottom?: number;
    left?: number;
    right?: number;
  };
}

/** Предки узла рендер-дерева (снизу вверх). */
function predki(uzol: unknown): unknown[] {
  const rjad = [];
  let tek = (uzol as { parent?: unknown }).parent;
  while (tek) {
    rjad.push(tek);
    tek = (tek as { parent?: unknown }).parent;
  }
  return rjad;
}

/** Является ли узел оверлеем лейсте: absolute, прижат к нижнему краю. */
function estOverlej(uzol: unknown): boolean {
  const st = stilUzla(uzol);
  return st.position === 'absolute' && st.bottom === 0 && st.left === 0 && st.right === 0;
}

interface ZonaNazhatija {
  readonly vysota: number;
  readonly shirina: number | null;
}

/** Число из стиля (undefined/NaN → null). */
function ch(x: unknown): number | null {
  return typeof x === 'number' && Number.isFinite(x) ? x : null;
}


/** Измеряемая нижняя граница высоты содержимого: текст не ниже своей
 * строки. max консервативен для нескольких потомков, однострочная
 * кнопка Filter измеряется точно по своему fontSize. */
function minimalnajaVysotaTeksta(uzol: unknown): number {
  const z = uzol as { type?: unknown; props?: { style?: unknown }; children?: unknown[] };
  const st = (StyleSheet.flatten([z.props?.style]) ?? {}) as Record<string, unknown>;
  const sobstvennaja = z.type === 'Text' ? (ch(st.lineHeight) ?? ch(st.fontSize) ?? 0) : 0;
  return Math.max(sobstvennaja, ...(z.children ?? []).map((potomok) =>
    typeof potomok === 'string' ? 0 : minimalnajaVysotaTeksta(potomok)));
}
/**
 * Эффективная ВЫСОТА бокса RN/Yoga: height — базис, minHeight — пол
 * (36+44 → 44), maxHeight — потолок (пол сильнее потолка);
 * собственный padding по приоритету side > axis > all входит в бокс.
 * Без явного height меряем нижнюю границу текста + padding.
 */

function effektivnajaVysota(st: Record<string, unknown>, soderzhimoe = 0): number {
  const vys = ch(st.height);
  const pol = ch(st.minHeight);
  const potolok = ch(st.maxHeight);
  const padVerh = ch(st.paddingTop) ?? ch(st.paddingVertical) ?? ch(st.padding) ?? 0;
  const padNiz = ch(st.paddingBottom) ?? ch(st.paddingVertical) ?? ch(st.padding) ?? 0;
  let telo = vys !== null ? Math.max(vys, padVerh + padNiz)
    : Math.max(pol ?? 0, soderzhimoe + padVerh + padNiz);
  if (pol !== null && telo < pol) {
    telo = pol;
  }
  if (potolok !== null && telo > potolok && (pol ?? 0) <= potolok) {
    telo = potolok;
  }
  return telo;
}

/** Эффективная ШИРИНА бокса — те же правила RN по горизонтали. */
function effektivnajaShirina(st: Record<string, unknown>): number {
  const sh = ch(st.width);
  const pol = ch(st.minWidth);
  const potolok = ch(st.maxWidth);
  const padLevo = ch(st.paddingLeft) ?? ch(st.paddingHorizontal) ?? ch(st.padding) ?? 0;
  const padPravo = ch(st.paddingRight) ?? ch(st.paddingHorizontal) ?? ch(st.padding) ?? 0;
  let telo = sh !== null ? Math.max(sh, padLevo + padPravo)
    : Math.max(pol ?? 0, padLevo + padPravo);
  if (pol !== null && telo < pol) {
    telo = pol;
  }
  if (potolok !== null && telo > potolok && (pol ?? 0) <= potolok) {
    telo = potolok;
  }
  return telo;
}

/**
 * Фактическая зона нажатия цели (Б2): эффективный бокс стиля
 * РЕАЛЬНОГО Pressable по правилам RN + невидимое расширение hitSlop
 * (токены touch-target.extend.* пакета 1.1: «sichtbar kleinere
 * Steuerelemente erweitern die Zielfläche unsichtbar»). Ширина судится
 * только там, где несёт явное объявление (width/minWidth/hitSlop):
 * ширина строк ряда даётся раскладкой лейсте, как в самом пакете.
 * Без явной декларации высоты однострочный текст тоже занимает место;
 * если сумма контента и сторон меньше минимума, зона красна (И-7).
 */
function zonaCelej(id: string): ZonaNazhatija {
  const uzol = screen.getByTestId(id);
  const props = (uzol as { props?: { style?: unknown; hitSlop?: unknown } }).props ?? {};
  const st = (StyleSheet.flatten([props.style]) ?? {}) as Record<string, unknown>;
  const syr = props.hitSlop;
  const slop = typeof syr === 'number'
    ? { top: syr, bottom: syr, left: syr, right: syr }
    : ((syr ?? {}) as { top?: number; bottom?: number; left?: number; right?: number });
  const vysota = effektivnajaVysota(st, minimalnajaVysotaTeksta(uzol)) + (slop.top ?? 0) + (slop.bottom ?? 0);
  const obJavlena = ch(st.width) !== null || ch(st.minWidth) !== null
    || ch(st.maxWidth) !== null || Boolean(slop.left) || Boolean(slop.right);
  const shirina = obJavlena
    ? effektivnajaShirina(st) + (slop.left ?? 0) + (slop.right ?? 0)
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

// Б1 (Crit148k2b): СВЯЗЬ компонента с токеном, не совпадение числа.
// Высота строки лейсте == nav.height, эффективная высота вкладок ==
// nav.item.min-height — равенством $value 1.1 (final2 71 краснеет);
// при подмене значения источника (контроль svjaz батареи: N+2px,
// модуль kompakt-tokens регенерирован извлечением) честный компонент
// СЛЕДУЕТ — литерал 49 в таб-шелле краснеет именно там (мутант
// nav-literal исполняется под подменой).
test('Б1: лейсте и вкладки следуют за токенами nav.height/item.min-height', async () => {
  const vysotaLeiste = px(TOKENY['nav']['height'].$value);
  const minVysotaVkladki = px(TOKENY['nav']['item.min-height'].$value);
  const view = await render(<TabShell initialSection="start" reducedMotion />);
  const leiste = screen.getByTestId('shell-tabbar');
  const stLeiste = (StyleSheet.flatten([
    (leiste as { props?: { style?: unknown } }).props?.style,
  ]) ?? {}) as Record<string, unknown>;
  const faktLeiste = effektivnajaVysota(stLeiste);
  if (faktLeiste !== vysotaLeiste) {
    throw new Error(
      `NAV_VYSOTA_NE_IZ_TOKENA: высота лейсте ${faktLeiste} != nav.height ${vysotaLeiste}` +
      ` ($value пакета 1.1; final2 ${TOKENY['nav']['height'].final2} краснеет равенством;` +
      ' компонент обязан читать токен, не литерал — Crit148k2b Б1)',
    );
  }
  for (const vkladka of ['start', 'vorgaenge', 'schutz', 'post'] as const) {
    const stVkladki = (StyleSheet.flatten([
      (screen.getByTestId(`shell-tab-${vkladka}`) as { props?: { style?: unknown } }).props?.style,
    ]) ?? {}) as Record<string, unknown>;
    const faktVkladki = effektivnajaVysota(stVkladki);
    if (faktVkladki !== minVysotaVkladki) {
      throw new Error(
        `NAV_MINHEIGHT_NE_IZ_TOKENA shell-tab-${vkladka}: эффективная высота вкладки` +
        ` ${faktVkladki} != nav.item.min-height ${minVysotaVkladki} ($value пакета 1.1)`,
      );
    }
  }
  view.unmount();
});

// Б2-действие (Crit148k2b, И-4): ДЕЙСТВУЮЩИЕ цели контента. Цель
// обязана быть ДОСТУПНОЙ для нажатия (не disabled) и НАЖИМАТЬСЯ:
// событие доходит до колбэка контента с ожидаемым аргументом.
// Отсутствие цели красно (getByTestId бросает), отключённая цель
// красна именованно (TSEL_OTKLJUCHENA — мутант disabled батареи),
// цель без действующего отклика красна (TSEL_NAZHATIE_NE_DEJSTVUET).
// Тесты стоят ДО блока зон: press после Dimensions.set вешает сьют
// (замеры пачки).
type Nazhatie = readonly [id: string, kolbek: string, arg?: string];

const NAZHATIJA_RAZDELA: Readonly<Record<'vorgaenge' | 'schutz' | 'post', readonly Nazhatie[]>> = {
  // testID строк Vorgänge == id строки (vkladki-dannye)
  vorgaenge: [
    ['vorgaenge-stroka-rechtsschutz', 'onVorgang', 'vorgaenge-stroka-rechtsschutz'],
    ['vorgaenge-stroka-hausrat-vertrag', 'onVorgang', 'vorgaenge-stroka-hausrat-vertrag'],
    ['vorgaenge-vse-sdelannye', 'onAlleErledigte'],
  ],
  schutz: [
    ['schutz-svod', 'onBereich', 'svod'],
    ['schutz-stat-vertraege', 'onBereich', 'vertraege'],
    ['schutz-stat-beitrag', 'onBereich', 'beitrag'],
    ['schutz-optionen', 'onBereich', 'optionen'],
    ['schutz-oblast-mobilitaet', 'onBereich', 'mobilitaet'],
    ['schutz-oblast-wohnen', 'onBereich', 'wohnen'],
    ['schutz-oblast-gesundheit', 'onBereich', 'gesundheit'],
    ['schutz-oblast-recht', 'onBereich', 'recht'],
    ['schutz-oblast-familie', 'onBereich', 'familie'],
  ],
  post: [
    ['post-filtr-alle', 'onFiltr', 'all'],
    ['post-filtr-vhodjaschie', 'onFiltr', 'received'],
    ['post-filtr-otpravlennye', 'onFiltr', 'sent'],
    // настройки фильтра нажимают ТЕКУЧИЙ фильтр (по умолчанию all)
    ['post-filtr-nastrojki', 'onFiltr', 'all'],
    ['post-napisat-complior', 'onSchicken'],
    ['post-deckungsanfrage', 'onNachricht', 'post-deckungsanfrage'],
    ['post-soobschenie-rechtsschutz', 'onNachricht', 'post-soobschenie-rechtsschutz'],
  ],
};

/** Одна обязательная цель: доступна (не disabled) и НАЖИМАЕТСЯ.
 * Среда RN 0.86 (замер пачки): host Pressable не несёт проп onPress
 * (механика — onResponder-события/onClick), доступность наблюдаема через
 * accessibilityState.disabled (мутант disabled даёт {disabled:true}),
 * действенность — ПОВЕДЕНИЕМ: fireEvent.press вызывает колбэк контента
 * ровно с ожидаемым аргументом (отключённая/безымянная цель колбэка не
 * вызывает — замер пачки: 0 вызовов). */
async function proveritDejstvieTseli(id: string, kolbek: { mock: { calls: readonly (readonly unknown[])[] } }, arg?: string) {
  const uzol = screen.getByTestId(id);
  const props = (uzol as {
    props?: {
      disabled?: unknown;
      accessibilityState?: { disabled?: boolean };
    };
  }).props ?? {};
  const a11y = props.accessibilityState ?? {};
  if (props.disabled === true || a11y.disabled === true) {
    throw new Error(
      `TSEL_OTKLJUCHENA ${id}: обязательная цель контента отключена (disabled) —` +
      ' И-4 требует ДЕЙСТВУЮЩИЕ цели: видимость и зона без нажатия обходом являются',
    );
  }
  // Изолируем именно ЭТО нажатие: другой элемент может ранее вызвать
  // тот же callback с тем же аргументом (Filter после Alle).
  const doNazhatiya = kolbek.mock.calls.length;
  await nazhat(id);
  const novye = kolbek.mock.calls.slice(doNazhatiya);
  const vigovreno = novye.length === 1
    && (arg === undefined || (novye[0].length === 1 && novye[0][0] === arg));
  if (!vigovreno) {
    throw new Error(
      `TSEL_NAZHATIE_NE_DEJSTVUET ${id}: нажатие не дошло до своего колбэка контента` +
      ` (новые вызовы ${JSON.stringify(novye)}; ожидался аргумент ${JSON.stringify(arg)})`,
    );
  }
}

test('Б2-действие (vorgaenge+Mitte): обязательные цели доступны и нажимаются', async () => {
  const kolbeki = {
    onVorgang: jest.fn<(id: string) => void>(),
    onAlleErledigte: jest.fn<() => void>(),
  };
  const mitteNazhatie = jest.fn<() => void>();
  const view = await render(
    <TabShell
      initialSection="vorgaenge"
      mitte={<GespraechMitte reducedMotion onPress={mitteNazhatie} />}
      reducedMotion
      sectionScreens={{
        vorgaenge: <VorgaengeListe onVorgang={kolbeki.onVorgang} onAlleErledigte={kolbeki.onAlleErledigte} />,
      }}
    />,
  );
  await waitFor(() => expect(screen.getByTestId('vorgaenge-stroka-rechtsschutz')).toBeOnTheScreen());
  for (const [id, kolbek, arg] of NAZHATIJA_RAZDELA.vorgaenge) {
    await proveritDejstvieTseli(id, kolbeki[kolbek as keyof typeof kolbeki] as { mock: { calls: readonly (readonly unknown[])[] } }, arg);
  }
  // Mitte — цель лейсте (И-7): доступна и нажимается (до контракта 147 —
  // мок-отклик: колбэк владельца слота)
  await proveritDejstvieTseli('gespraech-mitte', mitteNazhatie);
  view.unmount();
});

test('Б2-действие (schutz): обязательные цели доступны и нажимаются', async () => {
  const onBereich = jest.fn<(bereich: string) => void>();
  const view = await render(
    <TabShell
      initialSection="schutz"
      reducedMotion
      sectionScreens={{ schutz: <SchutzUebersicht onBereich={onBereich} /> }}
    />,
  );
  await waitFor(() => expect(screen.getByTestId('schutz-optionen')).toBeOnTheScreen());
  for (const [id, _kolbek, arg] of NAZHATIJA_RAZDELA.schutz) {
    await proveritDejstvieTseli(id, onBereich, arg);
  }
  view.unmount();
});

test('Б2-действие (post): обязательные цели доступны и нажимаются', async () => {
  const kolbeki = {
    onFiltr: jest.fn<(filtr: 'all' | 'received' | 'sent') => void>(),
    onNachricht: jest.fn<(id: string) => void>(),
    onSchicken: jest.fn<() => void>(),
  };
  const view = await render(
    <TabShell
      initialSection="post"
      reducedMotion
      sectionScreens={{
        post: <PostEingang onFiltr={kolbeki.onFiltr} onNachricht={kolbeki.onNachricht} onSchicken={kolbeki.onSchicken} />,
      }}
    />,
  );
  await waitFor(() => expect(screen.getByTestId('post-filtr-nastrojki')).toBeOnTheScreen());
  for (const [id, kolbek, arg] of NAZHATIJA_RAZDELA.post) {
    await proveritDejstvieTseli(id, kolbeki[kolbek as keyof typeof kolbeki] as { mock: { calls: readonly (readonly unknown[])[] } }, arg);
  }
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
