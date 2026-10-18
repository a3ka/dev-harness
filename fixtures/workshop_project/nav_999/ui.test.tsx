import React from 'react';
import { fireEvent, render, within } from '@testing-library/react-native';
import type { TestInstance } from 'test-renderer';
import { KeyboardAvoidingView, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { TabShell } from '../bootstrap/tab-shell';
import { ThemeContext } from '../theme/context';
import { themeTokens, type ColorScheme } from '../theme/tokens';
import { Button } from '../ui/button';
import { Notice } from '../ui/notice';
import { TextField } from '../ui/text-field';
import source from './source.json';

// 999 CMP-MOB-002: ui-примитивы — декартово произведение закрытых перечней
// {Button primary, Button secondary, Notice, TextField} × {dark, light}
// (Н-324/Н-325: клетки порождаются перечнем, не списком обходов). В КАЖДОЙ
// клетке наблюдаются все заявленные свойства: role, onPress, точный цвет
// подписи и заливки из source.json, акцентный гейт (подпись ≠ accent).
// Контейнеры наблюдаются по композиции (fiber-тождество компонента), а не
// только по testID: замена контейнера обычным View красна.
type PropsFiber = { memoizedProps?: Record<string, unknown> } & FiberLike;

// Проводка порта onPress до хоста: ближайший композит над хостом, чьи
// memoizedProps несут onPress (Pressable), обязан получить РОВНО колбэк
// потребителя. fireEvent.press в RNTL 14 всплывает до пропсов самого
// вызова и не различает отвязанный обработчик — наблюдаем проводку fiber-ом.
function wiredPressHandler(host: TestInstance): unknown {
  let fiber: PropsFiber = host.unstable_fiber?.return ?? null;
  while (fiber) {
    const props = fiber.memoizedProps;
    if (props && 'onPress' in props) {
      return props.onPress;
    }
    fiber = fiber.return;
  }
  return undefined;
}

function compositeCount(root: TestInstance, component: unknown): number {
  return root.queryAll((node) => {
    let fiber: FiberLike = node.unstable_fiber?.return ?? null;
    while (fiber) {
      if (fiber.type === component) return true;
      fiber = fiber.return;
    }
    return false;
  }).length;
}


function schemeNode(scheme: ColorScheme, node: React.ReactNode) {
  return <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>{node}</ThemeContext.Provider>;
}

function flattenColor(node: TestInstance): string | undefined {
  const style = StyleSheet.flatten(node.props.style);
  return typeof style?.color === 'string' ? style.color : undefined;
}

function flattenBackground(node: TestInstance): string | undefined {
  const style = StyleSheet.flatten(node.props.style);
  return typeof style?.backgroundColor === 'string' ? style.backgroundColor : undefined;
}

describe('999 ui', () => {
  // Клетки Button: variant × theme, все свойства в каждой клетке.
  for (const scheme of ['dark', 'light'] as const) {
    for (const variant of ['primary', 'secondary'] as const) {
      it(`BUTTON_${scheme.toUpperCase()}_${variant.toUpperCase()}`, async () => {
        const onPress = jest.fn();
        const view = await render(
          schemeNode(scheme, <Button label={source.copy['global.back'].text} onPress={onPress} variant={variant} testID={`btn-${scheme}-${variant}`} />),
        );
        const btn = view.getByTestId(`btn-${scheme}-${variant}`);
        expect(btn.props.accessibilityRole).toBe('button');
        expect(wiredPressHandler(btn)).toBe(onPress);
        await fireEvent.press(btn);
        expect(onPress).toHaveBeenCalledTimes(1);
        const tokens = source.tokens as Record<string, Record<'dark' | 'light', string>>;
        const label = within(btn).getByText(source.copy['global.back'].text);
        const expected = variant === 'primary' ? tokens['on-primary'][scheme] : tokens.ink[scheme];
        expect(flattenColor(label)).toBe(expected);
        // акцентный гейт на примитиве: подпись не может быть accent-текстом.
        expect(flattenColor(label)).not.toBe(tokens.accent[scheme]);
        const expectedSurface = variant === 'primary' ? tokens.primary[scheme] : tokens.panel[scheme];
        expect(flattenBackground(btn)).toBe(expectedSurface);
      });
    }
  }

  it('BUTTON_DISABLED_STATE', async () => {
    for (const scheme of ['dark', 'light'] as const) {
      const onPress = jest.fn();
      const view = await render(
        schemeNode(scheme, <Button label={source.copy['global.back'].text} onPress={onPress} disabled testID={`btn-disabled-${scheme}`} />),
      );
      const btn = view.getByTestId(`btn-disabled-${scheme}`);
      expect(btn.props.accessibilityState?.disabled).toBe(true);
      await fireEvent.press(btn);
      expect(onPress).not.toHaveBeenCalled();
    }
  });

  // Клетки Notice: theme × {role alert, testID, цвета на токенах, гейт}.
  for (const scheme of ['dark', 'light'] as const) {
    it(`NOTICE_${scheme.toUpperCase()}`, async () => {
      const view = await render(
        schemeNode(scheme, <Notice testID={`notice-${scheme}`}>{source.copy['ia117.nav.VORGAENGE'].text}</Notice>),
      );
      expect(view.getByRole('alert')).toBeTruthy();
      expect(view.getByTestId(`notice-${scheme}`)).toBeTruthy();
      const tokens = source.tokens as Record<string, Record<'dark' | 'light', string>>;
      const box = view.getByTestId(`notice-${scheme}`);
      expect(flattenBackground(box)).toBe(tokens.card[scheme]);
      const text = within(box).getByText(source.copy['ia117.nav.VORGAENGE'].text);
      expect(flattenColor(text)).toBe(tokens['on-card'][scheme]);
      expect(flattenColor(text)).not.toBe(tokens.accent[scheme]);
    });
  }

  // Клетки TextField: theme × {label, secureTextEntry, onChangeText, гейт}.
  for (const scheme of ['dark', 'light'] as const) {
    it(`TEXTFIELD_${scheme.toUpperCase()}`, async () => {
      const change = jest.fn();
      const view = await render(
        schemeNode(
          scheme,
          <TextField label={source.copy['ia115.nav.POST'].text} onChangeText={change} secureTextEntry testID={`tf-${scheme}`} value="" />,
        ),
      );
      const tokens = source.tokens as Record<string, Record<'dark' | 'light', string>>;
      const label = view.getByText(source.copy['ia115.nav.POST'].text);
      expect(flattenColor(label)).toBe(tokens.ink[scheme]);
      expect(flattenColor(label)).not.toBe(tokens.accent[scheme]);
      const input = view.getByTestId(`tf-${scheme}`);
      expect(input.props.secureTextEntry).toBe(true);
      await fireEvent.changeText(input, 'x');
      expect(change).toHaveBeenCalledWith('x');
    });
  }

  it('SAFE_KEYBOARD_CONTAINER', async () => {
    const view = await render(<TabShell colorScheme="light" />);
    // Наблюдение композиции: настоящий SafeAreaView из
    // react-native-safe-area-context и KeyboardAvoidingView из react-native
    // присутствуют как компоненты (fiber-тождество), а не только как testID.
    expect(compositeCount(view.root!, SafeAreaView)).toBeGreaterThan(0);
    expect(compositeCount(view.root!, KeyboardAvoidingView)).toBeGreaterThan(0);
    // Automation-семантика шва сохраняется.
    expect(view.getByTestId('shell-safe-area')).toBeTruthy();
    expect(view.getByTestId('shell-keyboard-container')).toBeTruthy();
  });

  it('ACCENT_NOT_TEXT_ON_LIGHT', async () => {
    const view = await render(<TabShell colorScheme="light" />);
    const lime = source.tokens.accent.light;
    const TABS = source.tabs_order as readonly string[];
    const textNodes = [
      view.getByTestId('section-title-start'),
      ...TABS.map((id) => within(view.getByTestId(`shell-tab-${id}`)).getByText(source.copy[source.labels[id]].text)),
      within(view.getByTestId('shell-profile-entry')).getByText(source.copy['action.F12.A01'].text),
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
