// Реализация CMP-MOB-002: нативная проекция токенов D2.2.5.1.
// Значения палитры — побайтово из docs/ux/02_.../tokens.json (источник
// заморожен, второй набор вручную изобретённых имён запрещён по
// STRUCTURE.md §6). Имя TAB_ORDER фиксирует порядок вкладок по IA 1.17
// (start, vorgaenge, schutz, post); ShellSectionId выводится из перечня.
export type ColorScheme = 'dark' | 'light';

export interface ThemeTokens {
  ground: string;
  ink: string;
  panel: string;
  card: string;
  'on-card': string;
  primary: string;
  'on-primary': string;
  accent: string;
  // 117 v2 (D2.2.5.1 tokens.json): лайм как ТЕКСТ — только accent-text
  // (README:395); вторичный текст — ink-muted.
  'accent-text': string;
  'ink-muted': string;
}

export const themeTokens: Record<ColorScheme, ThemeTokens> = {
  dark: {
    ground: '#0a0a0a',
    ink: '#f2f1ec',
    panel: '#1e1e1d',
    card: '#e9e8e2',
    'on-card': '#121211',
    primary: '#d6f75a',
    'on-primary': '#121211',
    accent: '#d6f75a',
    'accent-text': '#d6f75a',
    'ink-muted': '#a6a69f',
  },
  light: {
    ground: '#f3f2ee',
    ink: '#121211',
    panel: '#e6e5df',
    card: '#ffffff',
    'on-card': '#121211',
    primary: '#121211',
    'on-primary': '#f3f2ee',
    accent: '#d6f75a',
    'accent-text': '#3f6d0f',
    'ink-muted': '#5f5e58',
  },
};

export const TAB_ORDER = ['start', 'vorgaenge', 'schutz', 'post'] as const;
export type ShellSectionId = (typeof TAB_ORDER)[number];