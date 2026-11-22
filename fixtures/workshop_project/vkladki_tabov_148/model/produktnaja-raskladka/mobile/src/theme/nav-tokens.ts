// Проекция токенов D 2.4 Kompakt 1.1 — единственный источник чисел экрана
// «нижнее меню» (таб-лейсте + контент вкладок Vorgänge/Schutz/Post).
//
// Источник значений — пакет D24-Kompakt-1.1 в product main:
// docs/ux/05_Kompakt_D24/source/tokens.json (пины пакета — SPEC §2 контракта
// 148). Имена полей — как в источнике (nav.*, touch-target.*, typography.*,
// size.*, space.*, radius.*, vorgaenge.group.*): второй набор рукотворных имён
// запрещён (STRUCTURE.md §6). Литерал равного числа в месте, где грамматика
// экрана требует чтения токена, запрещён (контракт 148 И-8, класс 2 перечня
// продуктовых находок: «литерал вместо токена»).
//
// Кегль/межстрочный интервал — в pt артборда 390x844; компоненты умножают их
// на артборд (ab.w/ab.y), как делает шов артборда в bootstrap/tab-shell.
// Трекинг в источнике записан в em — здесь он переведён в pt (em × кегль),
// потому что React Native принимает letterSpacing в единицах шрифта.
//
// Значения финала 2 (nav.height 71, nav.icon 24, nav.label.font-size 11,
// nav.pebble 48×32, nav.hide-offset 84) НЕ переносились: пины пакета 1.1.

/** color.* — палитра D 2.4 Kompakt 1.1 (dark/light), значения пакета
 * побайтово; используется там, где тема продукта (theme/tokens.ts, палитра
 * D2.2.5.1) не несёт нужного тона: приглушённые чернила, линия, тёплый
 * тон «нужен ответ», успех, акцентный текст. */
export const COLOR = {
  dark: {
    inkMuted: '#a6a69f',
    line: '#2c2c2a',
    onCardMuted: '#5b5b55',
    cardRaised: '#d9d8d1',
    cardBorder: '#00000000',
    calm: '#163a27',
    onCalm: '#d6f75a',
    accentText: '#d6f75a',
    warm: '#ff7f45',
    warmOnCard: '#9a3c0c',
    successText: '#8fe08a',
  },
  light: {
    inkMuted: '#5f5e58',
    line: '#dcdbd5',
    onCardMuted: '#5f5e58',
    cardRaised: '#efeeea',
    cardBorder: '#dcdbd5',
    calm: '#e2f0d8',
    onCalm: '#1f4a2b',
    accentText: '#3f6d0f',
    warm: '#ff7f45',
    warmOnCard: '#9a3c0c',
    successText: '#2f6f2a',
  },
} as const;

/** header.* — шапка экрана (низ шапки, wordmark, цель профиля). */
export const HEADER = {
  /** Низ шапки: начало контента вкладки. */
  height: 52,
  /** Высота wordmark. */
  wordmark: { height: 22 },
  /** Цель профиля в шапке. */
  profile: { target: 44, icon: 24 },
} as const;

/** nav.* — геометрия таб-лейсты и её слотов. */
export const NAV = {
  /** Высота лейсте без домашней полосы: 1 pt линия + кнопки 48 pt. */
  height: 49,
  /** Зона касания одной вкладки. */
  item: {
    minHeight: 48,
    /** nav.item.padding — «5px 0 6px». */
    padding: { top: 5, right: 0, bottom: 6, left: 0 },
  },
  /** Подпись вкладки. */
  label: { fontSize: 10, lineHeight: 12 },
  /** Значок вкладки. */
  icon: 20,
  /** «Камешек» центральной кнопки Mitte (Gespräch). */
  pebble: { width: 40, height: 24 },
  /** Точка-бейдж «нужен ответ» на камешке. */
  badge: 8,
  /** Смещение лейсты при уходе в голос (меню 147). */
  hideOffset: 49,
} as const;

/** touch-target.* — минимальная зона касания и её расширения. */
export const TOUCH_TARGET = {
  /** Минимальная зона касания обязательной цели. */
  min: 44,
  /** Вертикальное расширение зоны малой кнопки. */
  extendButtonSm: 4,
  /** Расширение зоны сегмент-контрола (чипы дорожки .p-seg). */
  extendSegmented: 3,
} as const;

/** Начертание текста (fontWeight пакета). */
export type FontWeight = '400' | '500' | '600' | '700';

/** typography.* — роли текста экрана (трекинг переведён в pt). */
export const TYPOGRAPHY = {
  displayXl: { fontSize: 40, lineHeight: 44, fontWeight: '500', letterSpacing: -1.2 },
  display: { fontSize: 28, lineHeight: 32, fontWeight: '500', letterSpacing: -0.56 },
  displaySm: { fontSize: 22, lineHeight: 26, fontWeight: '500', letterSpacing: -0.44 },
  title: { fontSize: 22, lineHeight: 28, fontWeight: '500', letterSpacing: -0.33 },
  heading: { fontSize: 17, lineHeight: 22, fontWeight: '500', letterSpacing: -0.17 },
  body: { fontSize: 15, lineHeight: 21, fontWeight: '400', letterSpacing: 0 },
  bodySm: { fontSize: 13, lineHeight: 18, fontWeight: '400', letterSpacing: 0 },
  labelLg: { fontSize: 15, lineHeight: 20, fontWeight: '500', letterSpacing: 0 },
  label: { fontSize: 14, lineHeight: 18, fontWeight: '500', letterSpacing: 0 },
  labelSm: { fontSize: 13, lineHeight: 18, fontWeight: '500', letterSpacing: 0 },
  caption: { fontSize: 12, lineHeight: 16, fontWeight: '500', letterSpacing: 0.12 },
  captionSm: { fontSize: 11, lineHeight: 14, fontWeight: '500', letterSpacing: 0.11 },
  mono: { fontSize: 13, lineHeight: 18, fontWeight: '500', letterSpacing: 0 },
  monoSm: { fontSize: 12, lineHeight: 16, fontWeight: '500', letterSpacing: 0 },
} as const;

/** size.* — размеры строк, чипов, карточек. */
export const SIZE = {
  xs: 28,
  dot: 24,
  s: 32,
  sm: 36,
  rowDense: 40,
  md: 44,
  /** size.row — строка списка. */
  row: 44,
  lg: 48,
  trio: 56,
  cardStat: 112,
  cardDoc: 152,
  cardCalm: 168,
  cardAttention: 208,
} as const;

/** space.* — отступы. */
export const SPACE = {
  s1: 4,
  s2: 8,
  s3: 12,
  s4: 16,
  s5: 16,
  s6: 20,
  s8: 24,
  s12: 40,
} as const;

/** radius.* — скругления. */
export const RADIUS = {
  sm: 10,
  md: 16,
  card: 20,
  full: 9999,
} as const;

/** vorgaenge.group.* — подпись группы списка, её точка, счётчик и поля. */
export const VORGAENGE_GROUP = {
  /** Точка группы. */
  dot: 8,
  /** Поля подписи группы: «{space.8} 4px 10px» (верх, бок, низ). */
  margin: { top: 24, right: 4, bottom: 10, left: 4 },
  /** Счётчик группы: моно 12/16, начертание 500. */
  count: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '500',
  },
  /** Подпись группы (капс с трекингом). */
  label: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '500',
    /** 0.06em × 12 pt. */
    letterSpacing: 0.72,
    textTransform: 'uppercase',
  },
} as const;

/** Тип роли текста: кегль/межстрочный/трекинг в pt артборда. */
export type TypeRole = keyof typeof TYPOGRAPHY;

/** Стиль текста роли в dp окна: `{ fontSize, lineHeight, fontWeight, letterSpacing }`. */
export interface TypeStyle {
  readonly fontSize: number;
  readonly lineHeight: number;
  readonly fontWeight: FontWeight;
  readonly letterSpacing: number;
}

/** Артборд макета: pt → dp окна (по ширине / по высоте). */
export interface ScaleArtboard {
  readonly w: (pt: number) => number;
  readonly y: (pt: number) => number;
}

/** Стиль текста роли в dp окна: `{ ...typo(ab, TYPOGRAPHY.body), color }`. */
export function typo(ab: ScaleArtboard, role: TypeRole): TypeStyle {
  const base: TypeStyle = TYPOGRAPHY[role];
  return {
    fontSize: ab.w(base.fontSize),
    lineHeight: ab.y(base.lineHeight),
    fontWeight: base.fontWeight,
    letterSpacing: ab.w(base.letterSpacing),
  };
}
