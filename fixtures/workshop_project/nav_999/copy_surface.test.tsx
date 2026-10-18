import React from 'react';
import { fireEvent, render, within } from '@testing-library/react-native';

import { TabShell } from '../bootstrap/tab-shell';
import source from './source.json';
import { MODES, TABS, leaves } from './surface_sweep';

// 999 CMP-MOB-002, круг 3 (решение арбитража 999, К4): поверхность shell не
// показывает текстов вне каталога BrokerOS_UI_Copy_DE. Перечень состояний —
// грамматика TABS × S × MODES из source.json: каждая вкладка, профиль
// (вход и возврат), deep link с возвратом (до и после) — в КАЖДОМ режиме
// (reducedMotion × colorScheme). В каждом состоянии собираются ВСЕ строковые
// листья дерева (toJSON) и сверяются с каталогом; Back наблюдается поимённо
// (global.back) там, где виден, и отсутствует после возврата.
const CATALOG: Record<string, true> = {};
for (const entry of Object.values(source.copy) as { text: string }[]) {
  CATALOG[entry.text] = true;
}

function expectCatalogOnly(view: { toJSON: () => unknown }, state: string) {
  const out: string[] = [];
  leaves(view.toJSON(), out);
  const visible = out.filter((value) => value.length > 0);
  expect(visible.length).toBeGreaterThan(0);
  for (const leaf of visible) {
    // Именованный отказ: точный текст вне каталога на поверхности состояния.
    expect(CATALOG[leaf] ?? false).toBe(true);
  }
  return visible;
}

describe('999 copy', () => {
  for (const mode of MODES) {
    for (const from of TABS) {
      // Состояние A: вкладки — каждая вкладка открыта переключением, из from.
      it(`COPY_TABS_${from.toUpperCase()}_${mode.rm ? 'RM1' : 'RM0'}_${mode.cs.toUpperCase()}`, async () => {
        const view = await render(
          <TabShell initialSection={from} reducedMotion={mode.rm} colorScheme={mode.cs} />,
        );
        expectCatalogOnly(view, `tabs/${from}`);
        for (const to of TABS) {
          await fireEvent.press(view.getByTestId(`shell-tab-${to}`));
          expectCatalogOnly(view, `tabs/${to}`);
        }
      });

      // Состояние B: профиль — Back видим и равен каталогу; после возврата —
      // тексты снова из каталога, раздел сохранён.
      it(`COPY_PROFILE_${from.toUpperCase()}_${mode.rm ? 'RM1' : 'RM0'}_${mode.cs.toUpperCase()}`, async () => {
        const view = await render(
          <TabShell initialSection={from} reducedMotion={mode.rm} colorScheme={mode.cs} />,
        );
        await fireEvent.press(view.getByTestId('shell-profile-entry'));
        expect(view.getByTestId('profile-surface')).toBeTruthy();
        expect(within(view.getByTestId('shell-back')).getByText(source.copy['global.back'].text)).toBeTruthy();
        expectCatalogOnly(view, 'profile');
        await fireEvent.press(view.getByTestId('shell-back'));
        expect(view.queryByTestId('shell-back')).toBeNull();
        expectCatalogOnly(view, `profile-return/${from}`);
      });

      // Состояние C: deep link с возвратом — Back видим до возврата (поимённо),
      // после возврата исчезает; поверхность каталогична в обоих положениях.
      it(`COPY_DEEPLINK_${from.toUpperCase()}_${mode.rm ? 'RM1' : 'RM0'}_${mode.cs.toUpperCase()}`, async () => {
        for (const ret of TABS) {
          const view = await render(
            <TabShell initialSection={from} returnSection={ret} reducedMotion={mode.rm} colorScheme={mode.cs} />,
          );
          expect(within(view.getByTestId('shell-back')).getByText(source.copy['global.back'].text)).toBeTruthy();
          expectCatalogOnly(view, `deeplink/${from}`);
          await fireEvent.press(view.getByTestId('shell-back'));
          expect(view.queryByTestId('shell-back')).toBeNull();
          expectCatalogOnly(view, `deeplink-return/${ret}`);
        }
      });
    }
  }
});
