// stand-in продуктовых Jest-тестов срока (118 v2 круг 3, РЕШЕНИЕ арбитра
// А-1/А-3): 13 клеток класса срока на НАСТОЯЩИХ `/` (app/index) и маршруте
// /start ((tabs)/[section]), сессия инъецируется через composition-шов
// @pilot/runtime → runtime.api.getSession (публичный шов, тот же, что у
// release APK e2e); модель-копия вместо поверхности запрещена. Файл —
// implementer 118 и держится ПОБАЙТОВО равным этому носителю (sha256-пин
// SROK_TESTY_FORMA_SHA256 в proverka происхождения); исполнение судит
// ОТЧЁТ jest --json (шаг CI `npm test -- --json --outputFile=` ДО checker'а,
// флаг --jest-otchet): каждая клетка ровно один раз со status passed,
// pending/todo/failed — именованный отказ (SROK_KLETKA_NE_ISPOLNENA,
// SROK_OTCHET_S_PENDING/SROK_OTCHET_S_TODO; skip-обход БЛ-А1 закрыт
// по построению). Клетки «истёкшая между mount и действием» жмут БЕЗ
// ререндера: судится чтение порта В МОМЕНТ действия обработчиками
// pilot-app (demo, continue), не снимком рендера (БЛ-А2, арбитраж 118 v2
// §Q1 третий факт); прежний rerender-вариант сохранён отдельной клеткой.
import { act, fireEvent, render, screen } from '@testing-library/react-native';
import React from 'react';

import { runtime } from '@pilot/runtime';

import Root from '../../app/index';
import TabRoute from '@/app/(tabs)/[section]';

// Параметры маршрута — управляемая среда клетки (прецедент
// start-route-dopusk.test.tsx): реальный expo-router в jest не
// поднимается (ESM standard-navigation вне transform-allowlist),
// публичный шов пробы — useLocalSearchParams.
const mockEnv = {
  params: { section: 'start' } as { section?: string | string[] },
};
jest.mock('expo-router', () => ({
  useLocalSearchParams: () => mockEnv.params,
}));

/** Далёкая дата вычисляется от текущих часов, не литералом пачки. */
const budushchee = () => new Date(Date.now() + 3_153_600_000_000).toISOString();
const proshloe = () => new Date(Date.now() - 3_153_600_000_000).toISOString();

function sessija(expires_at: string) {
  return {
    principal_ref: 'example',
    display_name: 'x',
    auth_time: proshloe(),
    expires_at,
    locale: 'de-DE',
    disclosure_requirements: [],
  };
}

async function prochitat_sessiju() {
  await act(async () => {});
}

afterEach(() => {
  jest.restoreAllMocks();
});

describe('118 срок сессии на production-поверхностях', () => {
  it('srok-istekla-koren: истёкшая сессия → Erstinformation закрыта', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija(proshloe()) as never);
    const view = await render(<Root />);
    await prochitat_sessiju();
    await act(async () => {
      fireEvent.press(screen.getByTestId('first-run-continue'));
    });
    await act(async () => {
      fireEvent.press(screen.getByTestId('auth-demo-entry'));
    });
    // истёкшая сессия → W0: Erstinformation закрыта, путь B (F03.02)
    expect(screen.queryByTestId('erstinfo_gate_null')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-istekla-start: истёкшая сессия → прямой /start даёт First-Run', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija(proshloe()) as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-rovno-sejchas: срок равен текущему моменту → недопуск', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija(new Date().toISOString()) as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-nerazborchivaja: неразбираемая дата (NaN) → недопуск', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija('not-a-date') as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-mezhdu-mount-dejstviem: истёкшая между mount и НАЖАТИЕМ demo → недопуск', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija(budushchee()) as never);
    const view = await render(<Root />);
    await prochitat_sessiju();
    await act(async () => {
      fireEvent.press(screen.getByTestId('first-run-continue'));
    });
    let sejchas = Date.now();
    const shpion = jest.spyOn(Date, 'now').mockImplementation(() => sejchas);
    sejchas += 3_153_600_000_000; // срок истёк ПОСЛЕ монтирования
    // БЕЗ ререндера: судится чтение порта обработчиком НАЖАТИЯ (БЛ-А2),
    // не снимком рендера — на render-time-крючке клетка красна.
    await act(async () => {
      fireEvent.press(screen.getByTestId('auth-demo-entry'));
    });
    expect(screen.queryByTestId('erstinfo_gate_null')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    shpion.mockRestore();
    view.unmount();
  });

  it('srok-mezhdu-render-continue: истёкшая между render и НАЖАТИЕМ continue → недопуск', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija(budushchee()) as never);
    const view = await render(<Root />);
    await prochitat_sessiju();
    await act(async () => {
      fireEvent.press(screen.getByTestId('first-run-continue'));
    });
    await act(async () => {
      fireEvent.press(screen.getByTestId('auth-demo-entry'));
    });
    // демо доведено до current-снимка (шаг источника gate), continue доступен
    for (let shag = 0; shag < 6; shag += 1) {
      await act(async () => {
        fireEvent.press(screen.getByTestId('erstinfo_next_variant'));
      });
    }
    expect(screen.getByTestId('erstinfo_continue_start')).toBeOnTheScreen();
    let sejchas = Date.now();
    const shpion = jest.spyOn(Date, 'now').mockImplementation(() => sejchas);
    sejchas += 3_153_600_000_000; // срок истёк ПОСЛЕ рендера Erstinformation
    // БЕЗ ререндера: press continue — admission обязан читаться в момент
    // действия, назначение Start не открывается просроченной сессией.
    await act(async () => {
      fireEvent.press(screen.getByTestId('erstinfo_continue_start'));
    });
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    shpion.mockRestore();
    view.unmount();
  });

  it('srok-rerender-start: истёкшая между mount и ререндером /start → First-Run', async () => {
    let sejchas = Date.now();
    const shpion = jest.spyOn(Date, 'now').mockImplementation(() => sejchas);
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija(budushchee()) as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('section-start')).toBeOnTheScreen();
    sejchas += 3_153_600_000_000; // срок истёк ПОСЛЕ монтирования
    await act(async () => {
      view.rerender(<TabRoute />);
    });
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    shpion.mockRestore();
    view.unmount();
  });

  it('srok-pustaja: пустая строка срока → недопуск', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija('') as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-otsutstvuet-pole: поле срока отсутствует → недопуск', async () => {
    const bez_sroka = sessija(budushchee()) as Record<string, unknown>;
    delete bez_sroka['expires_at'];
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => bez_sroka as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-nestrokovaja: нестроковое значение срока → недопуск', async () => {
    const chislom = { ...sessija(budushchee()), expires_at: 12345 } as never;
    jest.spyOn(runtime.api, 'getSession').mockImplementation(async () => chislom);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-offset-zona: дата с offset зоны разбирается Date.parse → допуск', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija('2099-12-31T00:00:00+02:00') as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('section-start')).toBeOnTheScreen();
    view.unmount();
  });

  it('srok-ranishe-auth-time: срок раньше auth_time → недопуск', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija('2020-01-01T00:00:00Z') as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('first-run-continue')).toBeOnTheScreen();
    expect(screen.queryByTestId('section-start')).toBeNull();
    expect(screen.queryByTestId('start-screen')).toBeNull();
    expect(screen.queryByTestId('start_tabs')).toBeNull();
    view.unmount();
  });

  it('srok-svezhaja-demo: свежая демо-сессия → допуск W1A есть', async () => {
    jest
      .spyOn(runtime.api, 'getSession')
      .mockImplementation(async () => sessija(budushchee()) as never);
    const view = await render(<TabRoute />);
    await prochitat_sessiju();
    expect(screen.getByTestId('section-start')).toBeOnTheScreen();
    view.unmount();
  });
});
