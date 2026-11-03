// Исполняемый суд 13 целей пачки на реальном дереве: размер, наличие,
// доступность и наблюдаемое действие в каждом состоянии. Значения токенов
// поступают из пакета; компонент должен следовать их изменению, а не лишь
// совпадать с текущим числом.
//
// Зона касания судится на ИНТЕРКТИВНОМ узле — ближайшем сам-или-предке,
// принимающем жест, — а не на узле с testID: testID может висеть на
// декоративном ребёнке шире узкого Pressable (Crit147k2c Б1). Порог
// press-long измеряется на фейк-часах ТОЧНО, с допуском измерительного
// интерфейса 1 мс такта advanceTimersByTime: окна ±100 мс пропускали
// сдвиг «токен + 50 мс» (Crit147k2c Б2); фейк-часы детерминированы,
// целочисленная граница таймера флейка не даёт.
import fs from 'fs';
import path from 'path';
import React from 'react';
import { fireEvent, render, screen, userEvent } from '@testing-library/react-native';
import { StyleSheet, View } from 'react-native';
import type { TestInstance } from 'test-renderer';

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

/** Интерактивный узел цели: ближайший сам-или-предок, принимающий жест —
 * прямой press-обработчик (onPress/onLongPress/onPressIn/onPressOut) или
 * touch-респондер (тот же признак, по которому userEvent/fireEvent
 * доставляют нажатие вверх по дереву). Реальная зона касания — геометрия
 * ЭТОГО узла с учётом его hitSlop/padding/minHeight. */
function interaktivnyjUzel(id: string): TestInstance {
  let uzel: TestInstance | null = screen.getByTestId(id);
  while (uzel !== null) {
    const props = (uzel as { props?: Record<string, unknown> }).props ?? {};
    const prjamoj = props.onPress != null || props.onLongPress != null ||
      props.onPressIn != null || props.onPressOut != null;
    const respondent = typeof props.onStartShouldSetResponder === 'function' &&
      props.onStartShouldSetResponder() === true;
    if (prjamoj || respondent) {
      return uzel;
    }
    uzel = uzel.parent;
  }
  throw new Error(
    'цель ' + id + ': нет интерактивного узла (press-обработчик/респондер) вверх по дереву');
}

/** Нижняя граница эффективной hit-area ИНТЕРКТИВНОГО узла: width/height и
 * minWidth/minHeight одновременно действуют как max; padding добавляется
 * только если явной ширины/высоты нет, hitSlop расширяет границу во всех
 * случаях. */
function zonaUzla(uzel: TestInstance, shirinaProfilja: number): Zona {
  const props = (uzel as { props?: { style?: unknown; hitSlop?: unknown } })
    .props ?? {};
  const sloi = (StyleSheet.flatten([props.style]) ?? {}) as Record<string, number | string>;
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
    if (typeof znach === 'number') return znach;
    if (typeof znach === 'string' && znach.endsWith('%')) {
      return (parseFloat(znach) / 100) * shirinaProfilja;
    }
    return 0;
  };
  const baza = (a: string, m: string, start: string, end: string, axis: string): number =>
    Math.max(razmer(sloi[a]), razmer(sloi[m]),
      razmer(sloi[a]) ? 0 :
        razmer(sloi[start] ?? sloi[axis] ?? sloi.padding) +
        razmer(sloi[end] ?? sloi[axis] ?? sloi.padding));
  return {
    w: baza('width', 'minWidth', 'paddingLeft', 'paddingRight', 'paddingHorizontal') + dop.x,
    h: baza('height', 'minHeight', 'paddingTop', 'paddingBottom', 'paddingVertical') + dop.y,
  };
}

describe('gespraech-vhod: исполнимые цели и токены пакета', () => {
  const PROFLI = [390, 393];
  const kartaCelej = (): { minimum: number; celi: string[] } => {
    const tok = JSON.parse(fs.readFileSync(TOKENY_PAKETA, 'utf8'));
    const ekran = JSON.parse(fs.readFileSync(EKRAN_PACHKI, 'utf8'));
    const celi: string[] = (ekran.prokhodimost.pressable as Array<
      { id: string }
    >).map((x) => x.id);
    if (celi.length === 0 || new Set(celi).size !== celi.length) {
      throw new Error('ekran.json пачки: список целей пуст или содержит дубликат');
    }
    return { minimum: px(tok['touch-target'].min.$value as string), celi };
  };

  for (const shirina of PROFLI) {
    it('все цели доступны и действуют: профиль ' + shirina, async () => {
      const nabor = kartaCelej();
      const seen = new Set<string>();
      const commands = jest.fn();
      const view = await render(
        <View style={{ width: shirina }}>
          <TabShell onCommand={commands} />
        </View>,
      );
      const cel = (id: string) => {
        expect(nabor.celi).toContain(id);
        const element = screen.getByTestId(id);
        seen.add(id);
        let node: TestInstance | null = element;
        while (node !== null) {
          expect(node.props.disabled).not.toBe(true);
          expect(node.props.accessibilityState?.disabled).not.toBe(true);
          expect(node.props.pointerEvents).not.toBe('none');
          node = node.parent;
        }
        // Зона касания — геометрия ИНТЕРКТИВНОГО узла (узла, который
        // получает жест), в том числе когда testID висит на его ребёнке
        // (Crit147k2c Б1). Контрфактический токен не переопределяет
        // валидную при исходном пакете явную рамку, padding или hitSlop
        // интерактивного узла; целям без такого независимого размера
        // источник обязан менять живую зону.
        const uzol = interaktivnyjUzel(id);
        const style = (StyleSheet.flatten([uzol.props.style]) ?? {}) as
          Record<string, number | string>;
        const fixed = ['width', 'height', 'padding', 'paddingHorizontal',
          'paddingVertical', 'paddingLeft', 'paddingRight', 'paddingTop',
          'paddingBottom'].some((key) => style[key] !== undefined) ||
          uzol.props.hitSlop !== undefined;
        if (process.env.GESPRAECH147_METAMORF !== '1' || !fixed) {
          const zona = zonaUzla(uzol, shirina);
          expect(zona.w).toBeGreaterThanOrEqual(nabor.minimum);
          expect(zona.h).toBeGreaterThanOrEqual(nabor.minimum);
        }
        return element;
      };
      await fireEvent.press(cel('shell-profile-entry'));
      expect(screen.getByTestId('profile-surface')).toBeTruthy();
      await fireEvent.press(screen.getByTestId('shell-back'));
      expect(screen.getByTestId('section-start')).toBeTruthy();
      for (const tab of ['vorgaenge', 'schutz', 'post', 'start']) {
        await fireEvent.press(cel('shell-tab-' + tab));
        expect(screen.getByTestId('section-' + tab)).toBeTruthy();
      }
      await fireEvent.press(cel('gespraech-vorgaenge-ansehen'));
      await fireEvent.press(cel('gespraech-menu-ansehen'));
      expect(screen.getByTestId('section-vorgaenge')).toBeTruthy();
      await fireEvent.press(screen.getByTestId('shell-tab-start'));
      await fireEvent.press(cel('gespraech-mitte'));
      expect(screen.getByTestId('gespraech-menu')).toBeTruthy();
      await fireEvent.press(cel('gespraech-menu-close'));
      expect(screen.queryByTestId('gespraech-menu')).toBeNull();
      for (const action of ['sprechen', 'schreiben', 'foto', 'dokument']) {
        await fireEvent.press(screen.getByTestId('gespraech-mitte'));
        await fireEvent.press(cel('gespraech-menu-' + action));
        expect(commands).toHaveBeenLastCalledWith({ kind: action });
      }
      const paket = JSON.parse(fs.readFileSync(TOKENY_PAKETA, 'utf8'));
      const expected = ms(paket.motion['press-long'].$value);
      expect(ms(MOTION_TOKENS['press-long'])).toBe(expected);
      const mitte = cel('gespraech-mitte');
      // Фактический порог UI, а не окно вокруг токена (Crit147k2c Б2):
      // удержание до expected−1 мс не даёт voice, удержание ровно до
      // expected — даёт. Любой сдвиг порога ≥ 1 мс (в т.ч. «токен + 50»)
      // различим; погрешность измерения — 1 мс такта фейк-часов, флейка
      // на границе нет (целочисленные часы; таймер Pressability —
      // setTimeout(delayLongPress + delayPressIn), delayPressIn = 0).
      jest.useFakeTimers();
      const user = userEvent.setup({
        advanceTimers: jest.advanceTimersByTime,
      });
      const before = commands.mock.calls.length;
      await user.longPress(mitte, { duration: expected - 1 });
      expect(commands).toHaveBeenCalledTimes(before);
      await user.longPress(mitte, { duration: expected });
      expect(commands).toHaveBeenLastCalledWith({ kind: 'voice' });
      jest.useRealTimers();
      expect([...seen].sort()).toEqual([...nabor.celi].sort());
      view.unmount();
    });
  }
});
