import React from 'react';
import { fireEvent, render, screen, within } from '@testing-library/react-native';

import { TabShell } from '../bootstrap/tab-shell';
import source from './source.json';

// 999 CMP-MOB-002: исчерпывающая таблица переходов навигационного shell (урок
// Н-324: полнота с первой редакции, ячейки варьируют независимость). Copy и
// порядок — только из source.json (единый источник грамматики), ожидания
// сняты в память до запуска субъекта. TestID — automation-семантика шва.
const TABS = source.tabs_order as readonly string[];

describe('999 nav', () => {
  it('TABS_ORDER', async () => {
    await render(<TabShell />);
    const tabs = await screen.findAllByRole('tab');
    const ids = tabs.map((tab) => tab.props.testID as string);
    expect(ids.slice(0, TABS.length)).toEqual(TABS.map((id) => `shell-tab-${id}`));
  });

  it('TAB_LABELS_IA', async () => {
    await render(<TabShell />);
    for (const id of TABS) {
      const tab = screen.getByTestId(`shell-tab-${id}`);
      const key = source.labels[id];
      await within(tab).findByText(source.copy[key].text);
    }
  });

  it('PROFILE_SECONDARY_NOT_TAB', async () => {
    await render(<TabShell />);
    const tabs = await screen.findAllByRole('tab');
    expect(tabs).toHaveLength(4);
    await fireEvent.press(screen.getByTestId('shell-profile-entry'));
    expect(screen.getByTestId('profile-surface')).toBeOnTheScreen();
    expect(screen.queryAllByRole('tab')).toHaveLength(0);
    await fireEvent.press(screen.getByTestId('shell-back'));
    expect(screen.queryByTestId('profile-surface')).toBeNull();
    expect((await screen.findAllByRole('tab')).length).toBe(4);
  });

  it('TAB_SWITCH_SELECTS_SECTION', async () => {
    await render(<TabShell />);
    for (const id of ['vorgaenge', 'schutz']) {
      await fireEvent.press(screen.getByTestId(`shell-tab-${id}`));
      expect(screen.getByTestId(`shell-tab-${id}`).props.accessibilityState.selected).toBe(true);
      expect(screen.getByTestId(`section-${id}`)).toBeOnTheScreen();
      expect(screen.getByTestId(`section-title-${id}`)).toBeOnTheScreen();
    }
    expect(screen.getByTestId('shell-tab-start').props.accessibilityState.selected).toBe(false);
  });

  it('TAB_SWITCH_NO_COMMAND', async () => {
    const onCommand = jest.fn();
    await render(<TabShell onCommand={onCommand} />);
    for (const id of TABS) {
      await fireEvent.press(screen.getByTestId(`shell-tab-${id}`));
    }
    await fireEvent.press(screen.getByTestId('shell-profile-entry'));
    await fireEvent.press(screen.getByTestId('shell-back'));
    expect(onCommand).not.toHaveBeenCalled();
  });

  it('DEEPLINK_RETURN', async () => {
    await render(<TabShell initialSection="schutz" returnSection="post" />);
    expect(screen.getByTestId('shell-tab-schutz').props.accessibilityState.selected).toBe(true);
    expect(screen.getByTestId('shell-back')).toBeOnTheScreen();
    await fireEvent.press(screen.getByTestId('shell-back'));
    expect(screen.getByTestId('shell-tab-post').props.accessibilityState.selected).toBe(true);
    expect(screen.queryByTestId('shell-back')).toBeNull();
  });

  it('REDUCED_MOTION_ACTIONS', async () => {
    await render(<TabShell reducedMotion />);
    expect(screen.queryByTestId('shell-faden')).toBeNull();
    for (const id of TABS) {
      const tab = screen.getByTestId(`shell-tab-${id}`);
      expect(tab.props.disabled).not.toBe(true);
      expect(tab.props.accessibilityState.disabled).not.toBe(true);
      await fireEvent.press(tab);
      expect(screen.getByTestId(`section-${id}`)).toBeOnTheScreen();
    }
    await fireEvent.press(screen.getByTestId('shell-profile-entry'));
    expect(screen.getByTestId('profile-surface')).toBeOnTheScreen();
  });

  it('SECTION_CONTENT_COPY', async () => {
    await render(<TabShell />);
    for (const id of TABS) {
      if (id !== 'start') {
        await fireEvent.press(screen.getByTestId(`shell-tab-${id}`));
      }
      const titleKey = source.sections[id];
      expect(
        within(screen.getByTestId(`section-${id}`)).getByText(source.copy[titleKey].text),
      ).toBeOnTheScreen();
    }
  });
});
