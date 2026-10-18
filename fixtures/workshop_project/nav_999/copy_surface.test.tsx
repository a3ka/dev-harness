import React from 'react';
import { fireEvent, render, within } from '@testing-library/react-native';

import { TabShell } from '../bootstrap/tab-shell';
import source from './source.json';

// 999 CMP-MOB-002: поверхность shell не показывает текстов вне каталога
// BrokerOS_UI_Copy_DE. Перечень состояний закрыт: вкладки (каждый раздел),
// профиль, deep link с возвратом. В каждом состоянии собираются ВСЕ строковые
// листья дерева (toJSON) и сверяются с каталогом source.json; Back наблюдается
// поимённо в состояниях, где он виден.
const TABS = source.tabs_order as readonly string[];
const CATALOG: Record<string, true> = {};
for (const entry of Object.values(source.copy) as { text: string }[]) {
  CATALOG[entry.text] = true;
}

function stringLeaves(node: unknown, out: string[]): void {
  if (typeof node === 'string') {
    out.push(node);
    return;
  }
  if (Array.isArray(node)) {
    node.forEach((child) => stringLeaves(child, out));
    return;
  }
  if (node && typeof node === 'object' && 'children' in (node as Record<string, unknown>)) {
    stringLeaves((node as { children: unknown }).children, out);
  }
}

function expectCatalogOnly(view: { toJSON: () => unknown }, state: string) {
  const leaves: string[] = [];
  stringLeaves(view.toJSON(), leaves);
  const visible = leaves.filter((value) => value.length > 0);
  expect(visible.length).toBeGreaterThan(0);
  for (const leaf of visible) {
    // Именованный отказ: точный текст вне каталога на поверхности состояния.
    expect(CATALOG[leaf] ?? false).toBe(true);
  }
  return visible;
}

describe('999 copy', () => {
  it('COPY_SURFACE_CATALOG', async () => {
    // Состояние A: вкладки — каждый раздел открыт переключением.
    const tabs = await render(<TabShell />);
    for (const id of TABS) {
      if (id !== 'start') {
        await fireEvent.press(tabs.getByTestId(`shell-tab-${id}`));
      }
      expectCatalogOnly(tabs, `tabs/${id}`);
    }
    // Состояние B: профиль — вторичный маршрут; Back видим и равен каталогу.
    const profile = await render(<TabShell initialSection="schutz" />);
    await fireEvent.press(profile.getByTestId('shell-profile-entry'));
    expect(profile.getByTestId('profile-surface')).toBeTruthy();
    expectCatalogOnly(profile, 'profile');
    expect(within(profile.getByTestId('shell-back')).getByText(source.copy['global.back'].text)).toBeTruthy();
    await fireEvent.press(profile.getByTestId('shell-back'));
    // Возврат из профиля — тексты снова из каталога, раздел сохранён.
    expectCatalogOnly(profile, 'profile-return');
    expect(profile.getByTestId('section-schutz')).toBeTruthy();
    // Состояние C: deep link с возвратом — Back видим до возврата.
    const deeplink = await render(<TabShell initialSection="vorgaenge" returnSection="post" />);
    expect(within(deeplink.getByTestId('shell-back')).getByText(source.copy['global.back'].text)).toBeTruthy();
    expectCatalogOnly(deeplink, 'deeplink');
    await fireEvent.press(deeplink.getByTestId('shell-back'));
    expectCatalogOnly(deeplink, 'deeplink-return');
  });
});
