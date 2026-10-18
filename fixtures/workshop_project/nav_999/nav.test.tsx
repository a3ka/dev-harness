import React from 'react';
import { fireEvent, render, within } from '@testing-library/react-native';

import { TabShell } from '../bootstrap/tab-shell';
import source from './source.json';
import { MODES, TABS, expectSelected, sweepSurface } from './surface_sweep';

// 999 CMP-MOB-002, круг 3 (решение арбитража 999, К1): таблица переходов
// порождается ПЕРЕБОРОМ ЗАКРЫТОЙ грамматики TABS × S × A × MODES из
// source.json (tabs_order × modes), а не списком известных обходов
// (Н-324/Н-325). Клетки 1.1–1.4 исполняются в КАЖДОМ режиме
// (reducedMotion × colorScheme); при rm=true дополнительно 1.5: faden
// отсутствует, вкладки не disabled, действия дают те же состояния.
// В каждом состоянии — общий обход поверхности (surface_sweep: К3
// контейнеры, К4 каталог/акцент). onCommand — наблюдатель в каждой клетке.
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

  // К1.1: ∀ mode, ∀ from, ∀ to — нажатие tab(to) ИЗ from.
  for (const mode of MODES) {
    for (const from of TABS) {
      for (const to of TABS) {
        it(`TAB_${from.toUpperCase()}_TO_${to.toUpperCase()}_${mode.rm ? 'RM1' : 'RM0'}_${mode.cs.toUpperCase()}`, async () => {
          const onCommand = jest.fn();
          const view = await render(
            <TabShell initialSection={from} reducedMotion={mode.rm} colorScheme={mode.cs} onCommand={onCommand} />,
          );
          expectSelected(view, from);
          if (mode.rm) {
            expect(view.queryByTestId('shell-faden')).toBeNull();
            for (const tab of TABS) expect(view.getByTestId(`shell-tab-${tab}`).props.disabled).not.toBe(true);
          }
          sweepSurface(view, mode.cs, `section-${from}`);
          const tab = view.getByTestId(`shell-tab-${to}`);
          expect(tab.props.disabled).not.toBe(true);
          await fireEvent.press(tab);
          expectSelected(view, to);
          expect(view.queryByTestId('shell-back')).toBeNull();
          sweepSurface(view, mode.cs, `section-${to}`);
          expect(onCommand).not.toHaveBeenCalled();
        });
      }
    }
  }

  // К1.2: ∀ mode, ∀ from — profile-entry → back возвращается в from.
  for (const mode of MODES) {
    for (const from of TABS) {
      it(`PROFILE_RETURN_${from.toUpperCase()}_${mode.rm ? 'RM1' : 'RM0'}_${mode.cs.toUpperCase()}`, async () => {
        const onCommand = jest.fn();
        const view = await render(
          <TabShell initialSection={from} reducedMotion={mode.rm} colorScheme={mode.cs} onCommand={onCommand} />,
        );
        expectSelected(view, from);
        if (mode.rm) expect(view.queryByTestId('shell-faden')).toBeNull();
        await fireEvent.press(view.getByTestId('shell-profile-entry'));
        expect(view.getByTestId('profile-surface')).toBeTruthy();
        expect(view.queryAllByRole('tab')).toHaveLength(0);
        expect(within(view.getByTestId('shell-back')).getByText(source.copy['global.back'].text)).toBeTruthy();
        sweepSurface(view, mode.cs, 'profile-surface');
        await fireEvent.press(view.getByTestId('shell-back'));
        expect(view.queryByTestId('profile-surface')).toBeNull();
        expectSelected(view, from);
        expect(view.queryByTestId('shell-back')).toBeNull();
        sweepSurface(view, mode.cs, `section-${from}`);
        expect(onCommand).not.toHaveBeenCalled();
      });
    }
  }

  // К1.3: ∀ mode, ∀ (initial, return) ∈ TABS² — back ведёт в return.
  for (const mode of MODES) {
    for (const initial of TABS) {
      for (const ret of TABS) {
        it(`DEEPLINK_RETURN_${initial.toUpperCase()}_TO_${ret.toUpperCase()}_${mode.rm ? 'RM1' : 'RM0'}_${mode.cs.toUpperCase()}`, async () => {
          const onCommand = jest.fn();
          const view = await render(
            <TabShell initialSection={initial} returnSection={ret} reducedMotion={mode.rm} colorScheme={mode.cs} onCommand={onCommand} />,
          );
          expectSelected(view, initial);
          if (mode.rm) expect(view.queryByTestId('shell-faden')).toBeNull();
          expect(within(view.getByTestId('shell-back')).getByText(source.copy['global.back'].text)).toBeTruthy();
          sweepSurface(view, mode.cs, `section-${initial}`);
          await fireEvent.press(view.getByTestId('shell-back'));
          expectSelected(view, ret);
          expect(view.queryByTestId('shell-back')).toBeNull();
          sweepSurface(view, mode.cs, `section-${ret}`);
          expect(onCommand).not.toHaveBeenCalled();
        });
      }
    }
  }

  // К1.4: ∀ mode, ∀ initial — returnSection не задан: Back отсутствует.
  for (const mode of MODES) {
    for (const initial of TABS) {
      it(`NO_RETURN_${initial.toUpperCase()}_${mode.rm ? 'RM1' : 'RM0'}_${mode.cs.toUpperCase()}`, async () => {
        const view = await render(
          <TabShell initialSection={initial} reducedMotion={mode.rm} colorScheme={mode.cs} />,
        );
        expectSelected(view, initial);
        if (mode.rm) expect(view.queryByTestId('shell-faden')).toBeNull();
        expect(view.queryByTestId('shell-back')).toBeNull();
        sweepSurface(view, mode.cs, `section-${initial}`);
      });
    }
  }
});
