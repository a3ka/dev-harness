import React from 'react';
import { fireEvent, render, within } from '@testing-library/react-native';

import { TabShell } from '../bootstrap/tab-shell';
import source from './source.json';

// 999 CMP-MOB-002: исчерпывающая таблица переходов навигационного shell.
// Урок Н-324/Н-325: клетки порождаются ПЕРЕБОРОМ по закрытому перечню вкладок
// из source.json (единственный источник грамматики), а не списком известных
// обходов. Таблица: вкладка × initialSection × возврат из профиля ×
// selected-состояние — для ВСЕХ четырёх вкладок. Несколько render() в одном
// случае допустимы без unmount() (auto-cleanup между случаями); запросы —
// через результат рендера, не через screen.
const TABS = source.tabs_order as readonly string[];

function expectSelected(view: { getByTestId: (id: string) => { props: { accessibilityState?: { selected?: boolean } } } }, id: string, selected: boolean) {
  expect(view.getByTestId(`shell-tab-${id}`).props.accessibilityState?.selected).toBe(selected);
}

describe('999 nav', () => {
  it('TABS_ORDER', async () => {
    const view = await render(<TabShell />);
    const tabs = await view.findAllByRole('tab');
    const ids = tabs.map((tab) => tab.props.testID as string);
    expect(ids.slice(0, TABS.length)).toEqual(TABS.map((id) => `shell-tab-${id}`));
  });

  it('TAB_LABELS_IA', async () => {
    const view = await render(<TabShell />);
    for (const id of TABS) {
      const tab = view.getByTestId(`shell-tab-${id}`);
      const key = source.labels[id];
      expect(within(tab).getByText(source.copy[key].text)).toBeTruthy();
    }
  });

  it('PROFILE_SECONDARY_NOT_TAB', async () => {
    const view = await render(<TabShell />);
    const tabs = await view.findAllByRole('tab');
    expect(tabs).toHaveLength(4);
    await fireEvent.press(view.getByTestId('shell-profile-entry'));
    expect(view.getByTestId('profile-surface')).toBeTruthy();
    expect(view.queryAllByRole('tab')).toHaveLength(0);
    await fireEvent.press(view.getByTestId('shell-back'));
    expect(view.queryByTestId('profile-surface')).toBeNull();
    expect((await view.findAllByRole('tab')).length).toBe(4);
  });

  it('TAB_SWITCH_SELECTS_SECTION', async () => {
    const view = await render(<TabShell />);
    for (const id of TABS) {
      await fireEvent.press(view.getByTestId(`shell-tab-${id}`));
      expectSelected(view, id, true);
      expect(view.getByTestId(`section-${id}`)).toBeTruthy();
      expect(view.getByTestId(`section-title-${id}`)).toBeTruthy();
      for (const other of TABS) {
        if (other !== id) {
          expectSelected(view, other, false);
        }
      }
    }
  });

  it('TAB_SWITCH_NO_COMMAND', async () => {
    const onCommand = jest.fn();
    const view = await render(<TabShell onCommand={onCommand} />);
    for (const id of TABS) {
      await fireEvent.press(view.getByTestId(`shell-tab-${id}`));
    }
    await fireEvent.press(view.getByTestId('shell-profile-entry'));
    await fireEvent.press(view.getByTestId('shell-back'));
    expect(onCommand).not.toHaveBeenCalled();
  });

  // Клетки initialSection: по одной на каждую вкладку закрытого перечня.
  for (const initial of TABS) {
    it(`INITIAL_${initial.toUpperCase()}`, async () => {
      const view = await render(<TabShell initialSection={initial} />);
      for (const id of TABS) {
        expectSelected(view, id, id === initial);
      }
      expect(view.getByTestId(`section-${initial}`)).toBeTruthy();
      expect(view.getByTestId(`section-title-${initial}`)).toBeTruthy();
    });
  }

  // Клетки deep link: декартово произведение перечня вкладок
  // (initialSection × returnSection), включая вырожденную диагональ.
  for (const initial of TABS) {
    for (const ret of TABS) {
      it(`DEEPLINK_RETURN_${initial.toUpperCase()}_TO_${ret.toUpperCase()}`, async () => {
        const view = await render(<TabShell initialSection={initial} returnSection={ret} />);
        expectSelected(view, initial, true);
        expect(view.getByTestId(`shell-back`)).toBeTruthy();
        await fireEvent.press(view.getByTestId('shell-back'));
        expectSelected(view, ret, true);
        expect(view.getByTestId(`section-${ret}`)).toBeTruthy();
        expect(view.queryByTestId('shell-back')).toBeNull();
      });
    }
  }

  it('DEEPLINK_NO_RETURN', async () => {
    const view = await render(<TabShell initialSection="post" />);
    expectSelected(view, 'post', true);
    expect(view.queryByTestId('shell-back')).toBeNull();
  });

  // Возврат из профиля сохраняет исходный раздел: по клетке на каждую вкладку.
  for (const id of TABS) {
    it(`PROFILE_RETURN_${id.toUpperCase()}`, async () => {
      const view = await render(<TabShell />);
      if (id !== 'start') {
        await fireEvent.press(view.getByTestId(`shell-tab-${id}`));
      }
      expectSelected(view, id, true);
      await fireEvent.press(view.getByTestId('shell-profile-entry'));
      expect(view.getByTestId('profile-surface')).toBeTruthy();
      await fireEvent.press(view.getByTestId('shell-back'));
      expectSelected(view, id, true);
      expect(view.getByTestId(`section-${id}`)).toBeTruthy();
    });
  }

  it('REDUCED_MOTION_ACTIONS', async () => {
    const view = await render(<TabShell reducedMotion />);
    expect(view.queryByTestId('shell-faden')).toBeNull();
    for (const id of TABS) {
      const tab = view.getByTestId(`shell-tab-${id}`);
      expect(tab.props.disabled).not.toBe(true);
      expect(tab.props.accessibilityState?.disabled).not.toBe(true);
      await fireEvent.press(tab);
      expect(view.getByTestId(`section-${id}`)).toBeTruthy();
    }
    await fireEvent.press(view.getByTestId('shell-profile-entry'));
    expect(view.getByTestId('profile-surface')).toBeTruthy();
  });

  it('SECTION_CONTENT_COPY', async () => {
    const view = await render(<TabShell />);
    for (const id of TABS) {
      if (id !== 'start') {
        await fireEvent.press(view.getByTestId(`shell-tab-${id}`));
      }
      const titleKey = source.sections[id];
      const section = view.getByTestId(`section-${id}`);
      expect(within(section).getByText(source.copy[titleKey].text)).toBeTruthy();
    }
  });
});
