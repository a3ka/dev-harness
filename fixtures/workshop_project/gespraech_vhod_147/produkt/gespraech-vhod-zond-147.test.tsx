// Исполняемый зонд экрана вход-меню Gespräch (контракт 147, v+1 цикл 2 —
// вердикт Crit147k2b класс РЕАЛЬНЫЙ_ПОТРЕБИТЕЛЬ): зона касания и токен
// press-long судятся на РЕАЛЬНЫХ компонентах дерева, а не зеркальными
// декларациями манифеста (прецеденты зондов 148/149). Субъекты:
//   mobile/src/bootstrap/tab-shell.tsx — вкладки shell-tab-* и вход
//     профиля shell-profile-entry (цели карты pressable ПАЧКИ, конечный
//     домен; цели этого состояния, не отрисованные в дереве, — вне
//     домена: до реализации меню gespraech-* не судимы зоной);
//   mobile/src/theme/motion-tokens.ts — токен press-long, потребляемый
//     UI движения продукта (145: модуль — единый источник чисел).
// Геометрия: зона = ЯВНАЯ рамка (width ?? minWidth; явная малая рамка
// краснеет и при большем полу — консервативно, прецедент зонд 148) +
// невидимое расширение hitSlop; без объявления зоны (ни рамки, ни пола,
// ни hitSlop) — 0, красно: реализация обязана нести настоящую hit-area
// (И-4, hitSlop/Pressable). Видимая рамка меньше зоны находкой НЕ
// является (слово владельца 2026-11-02) — судится зона, не рамка.
// Токен: press-long, используемый продуктом (MOTION_TOKENS), равен
// значению токена пакета D24-Kompakt-1.1 (docs/ux/05_Kompakt_D24/
// source/tokens.json motion.press-long; мутант 500→900 красен).
// Зонд не знает о мутациях батареи: каждая мутация роняет СВОЙ ассерт.
// Среда 145/RNTL: ОДИН render на тест, события ждутся (прецедент
// pilot.test); числа — только из носителей (токен/карта), не в зонде.
import fs from 'fs';
import path from 'path';
import React from 'react';
import { render, screen } from '@testing-library/react-native';
import { StyleSheet, View } from 'react-native';

import { TabShell } from '../tab-shell';
import { MOTION_TOKENS } from '../../theme/motion-tokens';

const TOKENY_PAKETA = path.join(
  __dirname, '..', '..', '..', '..',
  'docs', 'ux', '05_Kompakt_D24', 'source', 'tokens.json');
const EKRAN_PACHKI = path.join(
  __dirname, '..', '..', '..',
  'e2e-gespraech-vhod', 'ekran.json');

function px(znach: string): number {
  const m = znach.match(/^(\d+(?:\.\d+)?)px$/);
  if (m === null) {
    throw new Error('пакет: ждали Npx, получили ' + znach);
  }
  return parseFloat(m[1]);
}

function ms(znach: string): number {
  const m = znach.match(/^(\d+(?:\.\d+)?)ms$/);
  if (m === null) {
    throw new Error('токен: ждали Nms, получили ' + znach);
  }
  return parseFloat(m[1]);
}

interface Zona {
  readonly w: number;
  readonly h: number;
}

/** Зона нажатия цели: явная рамка (побеждает пол) + hitSlop; проценты —
 * от ширины профиля контейнера. */
function zonaCelej(id: string, shirinaProfilja: number): Zona {
  const el = screen.getByTestId(id);
  const props = (el as { props?: { style?: unknown; hitSlop?: unknown } })
    .props ?? {};
  const sloi = (StyleSheet.flatten([props.style]) ?? {}) as {
    width?: number | string;
    minWidth?: number | string;
    height?: number | string;
    minHeight?: number | string;
  };
  const slop: unknown = props.hitSlop;
  const dop =
    slop === undefined
      ? { x: 0, y: 0 }
      : typeof slop === 'number'
        ? { x: 2 * slop, y: 2 * slop }
        : {
            x: Number((slop as Record<string, number>).left || 0) +
              Number((slop as Record<string, number>).right || 0),
            y: Number((slop as Record<string, number>).top || 0) +
              Number((slop as Record<string, number>).bottom || 0),
          };
  const razmer = (znach: number | string | undefined): number => {
    if (typeof znach === 'number') {
      return znach;
    }
    if (typeof znach === 'string' && znach.endsWith('%')) {
      return (parseFloat(znach) / 100) * shirinaProfilja;
    }
    return 0;
  };
  return {
    w: razmer(sloi.width ?? sloi.minWidth) + dop.x,
    h: razmer(sloi.height ?? sloi.minHeight) + dop.y,
  };
}

describe('gespraech-vhod: зона касания и токен press-long на компоненте', () => {
  const PROFLI = [390, 393];

  const kartaCelej = (): { minimum: number; celi: string[] } => {
    const tok = JSON.parse(fs.readFileSync(TOKENY_PAKETA, 'utf8'));
    const ekran = JSON.parse(fs.readFileSync(EKRAN_PACHKI, 'utf8'));
    const celi: string[] = (ekran.prokhodimost.pressable as Array<
      { id: string }
    >).map((x) => x.id);
    if (celi.length === 0) {
      throw new Error('ekran.json пачки: пустой список pressable');
    }
    return { minimum: px(tok['touch-target'].min.$value as string), celi };
  };

  const proveritZony = (shirina: number, vid: string): string[] => {
    const nabor = kartaCelej();
    const narushenija: string[] = [];
    let sudimyh = 0;
    for (const id of nabor.celi) {
      if (screen.queryByTestId(id) === null) {
        continue; // цель этого состояния не отрисована — вне домена
      }
      sudimyh += 1;
      const zona = zonaCelej(id, shirina);
      if (!(zona.w >= nabor.minimum && zona.h >= nabor.minimum)) {
        narushenija.push(
          id + ' [' + vid + ']: зона ' + zona.w + 'x' + zona.h +
          ' < touch-target.min ' + nabor.minimum,
        );
      }
    }
    if (sudimyh === 0) {
      throw new Error('в дереве не отрисована НИ ОДНА цель карты пачки');
    }
    return narushenija;
  };

  for (const shirina of PROFLI) {
    const vid = 'профиль-' + String(shirina);
    it('зоны отрисованных целей не меньше touch-target.min (' + vid + ')', async () => {
      const view = await render(
        <View style={{ width: shirina }} testID={vid}>
          <TabShell />
        </View>,
      );
      expect(proveritZony(shirina, vid)).toEqual([]);
      view.unmount();
    });
  }

  it('токен press-long, используемый продуктом, равен токену пакета 1.1', () => {
    const paket = JSON.parse(fs.readFileSync(TOKENY_PAKETA, 'utf8'));
    const poPaketu = ms(
      (paket.motion as Record<string, { $value: string }>)['press-long']
        .$value,
    );
    const poProduktu = ms(MOTION_TOKENS['press-long']);
    expect(poProduktu).toBe(poPaketu);
  });
});
