import React from 'react';
import { fireEvent, render, screen, within } from '@testing-library/react-native';
import { StyleSheet } from 'react-native';

import { TabShell } from '../bootstrap/tab-shell';
import { ThemeContext } from '../theme/context';
import { themeTokens, type ColorScheme } from '../theme/tokens';
import { Button } from '../ui/button';
import { Notice } from '../ui/notice';
import { TextField } from '../ui/text-field';
import source from './source.json';

// 999 CMP-MOB-002: ui-примитивы и контейнеры на токенах D2.2.5.1. Значения
// цветов сверяются с source.json (projection источника), не с локальными
// константами. Accent — заливка с тёмным текстом; лаймовый ТЕКСТ на светлом
// фоне запрещён (tokens.json: accent usage).
const SCHEMES: ColorScheme[] = ['dark', 'light'];
const BACK = source.copy['global.back'].text;
const TABS = source.tabs_order as readonly string[];

function withScheme(scheme: ColorScheme, node: React.ReactNode) {
  return <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>{node}</ThemeContext.Provider>;
}

describe('999 ui', () => {
  it('BUTTON_ROLE_VARIANTS', async () => {
    const onPress = jest.fn();
    await render(withScheme('dark', <Button label={BACK} onPress={onPress} testID="btn-dark" />));
    const dark = screen.getByTestId('btn-dark');
    expect(dark.props.accessibilityRole).toBe('button');
    await fireEvent.press(dark);
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('BUTTON_ROLE_LIGHT_SECONDARY', async () => {
    const onPress = jest.fn();
    await render(
      withScheme('light', <Button label={BACK} onPress={onPress} testID="btn-light" variant="secondary" />),
    );
    const light = screen.getByTestId('btn-light');
    expect(light.props.accessibilityRole).toBe('button');
    await fireEvent.press(light);
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('BUTTON_DISABLED_STATE', async () => {
    await render(
      withScheme('dark', <Button label={BACK} onPress={jest.fn()} disabled testID="btn-disabled" />),
    );
    expect(screen.getByTestId('btn-disabled').props.accessibilityState.disabled).toBe(true);
  });

  it('NOTICE_ROLE', async () => {
    await render(
      withScheme('light', <Notice testID="notice">{source.copy['ia117.nav.VORGAENGE'].text}</Notice>),
    );
    expect(screen.getByRole('alert')).toBeOnTheScreen();
    expect(screen.getByTestId('notice')).toBeOnTheScreen();
  });

  it('TEXTFIELD_LABEL_SECURE', async () => {
    const change = jest.fn();
    await render(
      withScheme(
        'light',
        <TextField
          label={source.copy['ia115.nav.POST'].text}
          onChangeText={change}
          secureTextEntry
          testID="tf"
          value=""
        />,
      ),
    );
    expect(screen.getByText(source.copy['ia115.nav.POST'].text)).toBeOnTheScreen();
    const input = screen.getByTestId('tf');
    expect(input.props.secureTextEntry).toBe(true);
    await fireEvent.changeText(input, 'x');
    expect(change).toHaveBeenCalledWith('x');
  });

  it('SAFE_KEYBOARD_CONTAINER', async () => {
    await render(<TabShell colorScheme="light" />);
    expect(screen.getByTestId('shell-safe-area')).toBeOnTheScreen();
    expect(screen.getByTestId('shell-keyboard-container')).toBeOnTheScreen();
  });

  it('ACCENT_NOT_TEXT_ON_LIGHT', async () => {
    await render(<TabShell colorScheme="light" />);
    const lime = source.tokens.accent.light;
    const textNodes = [
      screen.getByTestId('section-title-start'),
      ...TABS.map((id) =>
        within(screen.getByTestId(`shell-tab-${id}`)).getByText(source.copy[source.labels[id]].text),
      ),
      within(screen.getByTestId('shell-profile-entry')).getByText(source.copy['action.F12.A01'].text),
    ];
    expect(textNodes.length).toBeGreaterThan(0);
    for (const node of textNodes) {
      const style = StyleSheet.flatten(node.props.style);
      if (style && typeof style.color === 'string') {
        expect(style.color).not.toBe(lime);
      }
    }
  });
});
