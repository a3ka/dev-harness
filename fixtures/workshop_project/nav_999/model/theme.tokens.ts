// Эталон 999: нативная проекция токенов D2.2.5.1 (docs/ux/02_.../tokens.json).
// Значения — побайтово из источника; второй вручную изобретённый набор запрещён
// (STRUCTURE.md §6). Файл — часть честного эталона architect, не копируется в PR.
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
  },
};

export const TAB_ORDER = ['start', 'vorgaenge', 'schutz', 'post'] as const;
export type ShellSectionId = (typeof TAB_ORDER)[number];
