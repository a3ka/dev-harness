// Эталон 999: тема как React-контекст над проекцией tokens.json.
// Значение по умолчанию детерминировано (dark), тесты задают схему портом шва.
import { createContext, useContext } from 'react';
import { themeTokens, type ColorScheme, type ThemeTokens } from './tokens';

export interface ThemeContextValue {
  readonly scheme: ColorScheme;
  readonly tokens: ThemeTokens;
}

export const ThemeContext = createContext<ThemeContextValue>({
  scheme: 'dark',
  tokens: themeTokens.dark,
});

export function useTheme(): ThemeContextValue {
  return useContext(ThemeContext);
}
