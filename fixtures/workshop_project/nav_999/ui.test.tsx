import React from 'react';
import { fireEvent, render, within } from '@testing-library/react-native';
import type { TestInstance } from 'test-renderer';
import { KeyboardAvoidingView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TabShell } from '../bootstrap/tab-shell';
import { ThemeContext } from '../theme/context';
import { themeTokens, type ColorScheme } from '../theme/tokens';
import { Button } from '../ui/button';
import { Notice } from '../ui/notice';
import { TextField } from '../ui/text-field';
import source from './source.json';
import { TABS, backgroundOf, colorOf, isDescendantOfHost, nearestCompositeIs, wiredOnPress } from './surface_sweep';

// 999 CMP-MOB-002, круг 3 (решение арбитража 999, К2/К3/К4.3): клетки
// примитивов порождаются декартовым произведением закрытых перечней из
// source.json — Button {primary,secondary} × {disabled} × {dark,light},
// TextField {secure} × {dark,light} — и в каждой клетке наблюдаются ВСЕ
// заявленные свойства. Контейнеры — композиция 3.1–3.3 (не наличие где
// угодно); акцент-гейт — обход всех host-Text/TextInput, не ручной список.
const TOK = source.tokens as Record<string, Record<'dark' | 'light', string>>;

function schemeNode(scheme: ColorScheme, node: React.ReactNode) {
  return <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>{node}</ThemeContext.Provider>;
}

describe('999 ui', () => {
  for (const scheme of ['dark', 'light'] as const) {
    for (const variant of ['primary', 'secondary'] as const) {
      for (const disabled of [false, true]) {
        const suffix = disabled ? '_DISABLED' : '';
        it(`BUTTON_${scheme.toUpperCase()}_${variant.toUpperCase()}${suffix}`, async () => {
          const onPress = jest.fn();
          const testID = `btn-${scheme}-${variant}${disabled ? '-disabled' : ''}`;
          const view = await render(
            schemeNode(scheme, <Button label={source.copy['global.back'].text} onPress={onPress} variant={variant} disabled={disabled} testID={testID} />),
          );
          const btn = view.getByTestId(testID);
          expect(btn.props.accessibilityRole).toBe('button');
          expect(btn.props.accessibilityState?.disabled ?? false).toBe(disabled);
          if (!disabled) expect(wiredOnPress(btn)).toBe(onPress);
          await fireEvent.press(btn);
          expect(onPress).toHaveBeenCalledTimes(disabled ? 0 : 1);
          const label = within(btn).getByText(source.copy['global.back'].text);
          expect(colorOf(label)).toBe(variant === 'primary' ? TOK['on-primary'][scheme] : TOK.ink[scheme]);
          expect(colorOf(label)).not.toBe(TOK.accent[scheme]);
          expect(backgroundOf(btn)).toBe(variant === 'primary' ? TOK.primary[scheme] : TOK.panel[scheme]);
        });
      }
    }
  }

  // К2.2: Notice × {dark, light}.
  for (const scheme of ['dark', 'light'] as const) {
    it(`NOTICE_${scheme.toUpperCase()}`, async () => {
      const view = await render(
        schemeNode(scheme, <Notice testID={`notice-${scheme}`}>{source.copy['ia117.nav.VORGAENGE'].text}</Notice>),
      );
      expect(view.getByRole('alert')).toBeTruthy();
      const box = view.getByTestId(`notice-${scheme}`);
      expect(backgroundOf(box)).toBe(TOK.card[scheme]);
      const text = within(box).getByText(source.copy['ia117.nav.VORGAENGE'].text);
      expect(colorOf(text)).toBe(TOK['on-card'][scheme]);
      expect(colorOf(text)).not.toBe(TOK.accent[scheme]);
    });
  }

  // К2.3: TextField scheme × secure (ОБА значения) — 4 клетки, все свойства.
  for (const scheme of ['dark', 'light'] as const) {
    for (const secure of [true, false]) {
      it(`TEXTFIELD_${scheme.toUpperCase()}_SECURE_${secure ? 1 : 0}`, async () => {
        const change = jest.fn();
        const view = await render(
          schemeNode(scheme, <TextField label={source.copy['ia115.nav.POST'].text} onChangeText={change} secureTextEntry={secure} testID="tf" value="v1" />),
        );
        const label = view.getByText(source.copy['ia115.nav.POST'].text);
        expect(colorOf(label)).toBe(TOK.ink[scheme]);
        expect(colorOf(label)).not.toBe(TOK.accent[scheme]);
        const input = view.getByTestId('tf');
        expect(input.props.secureTextEntry ?? false).toBe(secure);
        expect(input.props.value).toBe('v1');
        expect(colorOf(input)).toBe(TOK.ink[scheme]);
        expect(colorOf(input)).not.toBe(TOK.accent[scheme]);
        expect(backgroundOf(input)).toBe(TOK.panel[scheme]);
        await fireEvent.changeText(input, 'x');
        expect(change).toHaveBeenCalledWith('x');
      });
    }
  }

  // К3.1–3.3 (П3): SAFE_KEYBOARD_CONTAINER заменён проверками композиции —
  // ближайший композит над хостами, контент внутри обоих хостов, хосты
  // шва внутри safe-area; в каждом разделе-состоянии.
  it('SHELL_CONTAINER_COMPOSITION', async () => {
    const view = await render(<TabShell />);
    for (const id of TABS) {
      if (id !== 'start') {
        await fireEvent.press(view.getByTestId(`shell-tab-${id}`));
      }
      expect(nearestCompositeIs(view.getByTestId('shell-safe-area'), SafeAreaView)).toBe(true);
      expect(nearestCompositeIs(view.getByTestId('shell-keyboard-container'), KeyboardAvoidingView)).toBe(true);
      const content = view.getByTestId(`section-${id}`);
      expect(isDescendantOfHost(content, 'shell-safe-area')).toBe(true);
      expect(isDescendantOfHost(content, 'shell-keyboard-container')).toBe(true);
      for (const host of ['shell-back', 'shell-profile-entry', ...TABS.map((tab) => `shell-tab-${tab}`)]) {
        const node = view.queryByTestId(host);
        if (node) expect(isDescendantOfHost(node, 'shell-safe-area')).toBe(true);
      }
    }
  });

  it('SHELL_CONTAINER_PROFILE', async () => {
    const view = await render(<TabShell initialSection="schutz" />);
    await fireEvent.press(view.getByTestId('shell-profile-entry'));
    expect(nearestCompositeIs(view.getByTestId('shell-safe-area'), SafeAreaView)).toBe(true);
    expect(nearestCompositeIs(view.getByTestId('shell-keyboard-container'), KeyboardAvoidingView)).toBe(true);
    const content = view.getByTestId('profile-surface');
    expect(isDescendantOfHost(content, 'shell-safe-area')).toBe(true);
    expect(isDescendantOfHost(content, 'shell-keyboard-container')).toBe(true);
    for (const host of ['shell-back', 'shell-profile-entry']) {
      expect(isDescendantOfHost(view.getByTestId(host), 'shell-safe-area')).toBe(true);
    }
  });

  // К4.3: акцент-гейт обходом ВСЕХ host-Text/TextInput во всех состояниях
  // (разделы и профиль), не ручным списком узлов.
  for (const scheme of ['light', 'dark'] as const) {
    it(scheme === 'light' ? 'ACCENT_NOT_TEXT_ON_LIGHT' : 'ACCENT_NOT_TEXT_IN_DARK', async () => {
      const view = await render(<TabShell colorScheme={scheme} />);
      for (const id of TABS) {
        if (id !== 'start') {
          await fireEvent.press(view.getByTestId(`shell-tab-${id}`));
        }
        const hosts = view.root.queryAll((node) => node.type === 'Text' || node.type === 'TextInput');
        expect(hosts.length).toBeGreaterThan(0);
        for (const host of hosts) expect(colorOf(host)).not.toBe(TOK.accent[scheme]);
      }
      await fireEvent.press(view.getByTestId('shell-profile-entry'));
      const hosts = view.root.queryAll((node) => node.type === 'Text' || node.type === 'TextInput');
      expect(hosts.length).toBeGreaterThan(0);
      for (const host of hosts) expect(colorOf(host)).not.toBe(TOK.accent[scheme]);
    });
  }
});
