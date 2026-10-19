import React from 'react';
import { fireEvent, render } from '@testing-library/react-native';

import { TabShell } from '../bootstrap/tab-shell';
import { TAB_ORDER } from '../theme/tokens';
import { MODES, TABS } from './surface_sweep';

// 999 CMP-MOB-002, микро-круг К1.5 (вердикт критика круга 3): отсутствие
// shell-faden при rm=true наблюдается В ДОСТИГНУТОМ состоянии (после
// tab(to), в profile, после back в return-состояние), а не только до
// действия. Список маршрутов циклов выводится из КОДА эталона — TAB_ORDER
// из mobile/src/theme/tokens.ts и вторичный маршрут profile (наблюдается
// по shell-profile-entry), не вручную: новый маршрут в коде автоматически
// порождает клетки MOTION_*_RM1_*, а маршрут вне грамматики source.json
// краснеет сторожем MOTION_ROUTE_GRAMMAR (расширение перечня = расширение
// source.json). На честной модели код-перечень совпадает с грамматикой.
const CODE_TABS = TAB_ORDER as readonly string[];
const RM1_MODES = MODES.filter((mode) => mode.rm);

describe('999 nav', () => {
  it('MOTION_ROUTE_GRAMMAR', async () => {
    expect([...CODE_TABS]).toEqual([...TABS]);
    const view = await render(<TabShell />);
    expect(view.getByTestId('shell-profile-entry')).toBeTruthy();
  });

  // К1.5 в состоянии section-to после нажатия tab(to) из from.
  for (const mode of RM1_MODES) {
    for (const from of CODE_TABS) {
      for (const to of CODE_TABS) {
        it(`MOTION_TAB_${from.toUpperCase()}_TO_${to.toUpperCase()}_RM1_${mode.cs.toUpperCase()}`, async () => {
          const view = await render(
            <TabShell initialSection={from} reducedMotion={true} colorScheme={mode.cs} />,
          );
          await fireEvent.press(view.getByTestId(`shell-tab-${to}`));
          expect(view.queryByTestId('shell-faden')).toBeNull();
        });
      }
    }
  }

  // К1.5 в состоянии profile (обход критика круга 3: исключение route === 'profile').
  for (const mode of RM1_MODES) {
    for (const from of CODE_TABS) {
      it(`MOTION_PROFILE_${from.toUpperCase()}_RM1_${mode.cs.toUpperCase()}`, async () => {
        const view = await render(
          <TabShell initialSection={from} reducedMotion={true} colorScheme={mode.cs} />,
        );
        await fireEvent.press(view.getByTestId('shell-profile-entry'));
        expect(view.getByTestId('profile-surface')).toBeTruthy();
        expect(view.queryByTestId('shell-faden')).toBeNull();
      });
    }
  }

  // К1.5 в return-состоянии section-ret после back из deeplink(initial, ret).
  for (const mode of RM1_MODES) {
    for (const initial of CODE_TABS) {
      for (const ret of CODE_TABS) {
        it(`MOTION_DEEPLINK_${initial.toUpperCase()}_BACK_${ret.toUpperCase()}_RM1_${mode.cs.toUpperCase()}`, async () => {
          const view = await render(
            <TabShell initialSection={initial} returnSection={ret} reducedMotion={true} colorScheme={mode.cs} />,
          );
          const back = view.queryByTestId('shell-back');
          if (back) {
            await fireEvent.press(back);
          }
          expect(view.queryByTestId('shell-faden')).toBeNull();
        });
      }
    }
  }
});
