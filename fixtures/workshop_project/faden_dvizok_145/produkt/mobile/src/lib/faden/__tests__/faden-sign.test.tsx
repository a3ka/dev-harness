// Продуктовый знаковый тест И-8 (контракт 145 v2) — ОБЯЗАТЕЛЬНЫЙ канон по
// арбитражу Astra (A.3/B.7). ЭТАЛОН-ФОРМА ПРОДУКТА батареи 145: байты файла
// равны пину батареи (клетка a05 — ЦЕЛОСТНОСТЬ теста, не исполнение TSX);
// ИСПОЛНЕНИЕ — jest-expo в CI продукта (job quality, `npm test -- faden`)
// и живая матрица батареи `--live-component --repo R` (режим L). Node-шим
// этот файл НЕ исполняет (это не движковый тест).
//
// v2 — канон ПОД СРЕДУ ПРОДУКТА (слово владельца 2026-10-29 ~13:20; среда
// продукта: RN 0.86.3, jest-expo ~57.0.6, @testing-library/react-native v14):
//   (1) react-native НЕ мокается: в RN 0.86 спред jest.requireActual('react-native')
//       активирует ленивые геттеры индекса и падает инвариантом
//       TurboModuleRegistry ('DevMenu'); пресет @react-native/jest-preset уже
//       подменяет AccessibilityInfo jest.fn-моками — тест управляет ИМИ
//       (spyOn + явный jest.Mock);
//   (2) rAF-часы: пресет RN реализует requestAnimationFrame как setTimeout(cb, 0)
//       — замер среды: advanceTimersByTime(768) даёт 769 кадров, а не 48; кадр
//       16 мс ставит продуктовый setup-файл (setupFilesAfterEnv в
//       mobile/jest.config.js), первый тест именованно проверяет сами часы;
//   (3) RNTL v14: render/rerender/unmount асинхронные — каждый awaited,
//       screen читается только после await.
// Матрица и оракол — БЕЗ ИЗМЕНЕНИЯ против v1 (B.7): монтирует поставленный
// FadenSign, берёт РЕАЛЬНЫЙ d SVG-пути (testID faden-sign-thread) и координаты
// точки (faden-sign-dot) из результата рендера и сравнивает байт-точно с
// независимым инстансом порта при ТОМ ЖЕ расписании времени/set (сглаживание
// учтено: живой инстанс ≠ мгновенный pose(state,{t})). Программа сама управляет
// часами (jest fake timers + rAF-часы 16 мс кадрового контракта компонента);
// реальные задержки/wall-clock оракулом НЕ являются.
//
// Матрица (B.7): 11 состояний × ОС false/true, моменты t=0 и t≈777 мс
// (48 кадров rAF × 16 мс); смена props.state по циклу всех 11 состояний на
// смонтированном компоненте И при активной ОС true (последняя — ловец
// принудительного forceReducedMotion живой матрицы L: при смене состояния
// полный set компонента несёт ОС-полярность, а не служебный проп);
// ОС false→true→false и true→false→true на
// различающем состоянии idle; для УД проверяются геометрические props
// (путь и точка), не только вызов API. Null/нет SVG/другой путь — именованный
// отказ ассерта (queryByTestId + expect, не «ненулевое число узлов»).
import React from 'react';
import { AccessibilityInfo } from 'react-native';
import { render, screen, act } from '@testing-library/react-native';
import { FadenSign } from '../FadenSign';
import { createInstance, path, dotXY, STATES } from '../faden-motion.ts';

const DT = 1000 / 60;
const KADRY_777 = 48; // управляемое время ≈777 мс: 48 кадров rAF × 16 мс
const KADRY_SHAG = 8; // кадры между сменами в цикле состояний/флага

// тест захватывает обработчик reduceMotionChanged, чтобы менять флаг сам
let osSlushatel: ((v: boolean) => void) | null = null;

beforeEach(() => {
  jest.useFakeTimers();
  jest.spyOn(AccessibilityInfo, 'isReduceMotionEnabled').mockReset();
  (AccessibilityInfo.addEventListener as jest.Mock).mockReset().mockImplementation(
    (_s: unknown, cb: (v: boolean) => void) => { osSlushatel = cb; return { remove: jest.fn() }; },
  );
  osSlushatel = null;
});

// ── оракул: независимый инстанс ПОРТА с расписанием канонического FadenSign ───
// mount-set(reducedMotion:false) → set(ОС-полярность) [промис] → на каждый кадр
// advanceTime(DT)+set({}); смена props.state → set({state,size,emotion,rm}).
// Это ТО ЖЕ расписание операций, что у компонента, — потому равенство байт-точно.
function orakul(nachalnoe: string) {
  let sost = nachalnoe;
  const inst = createInstance({ state: sost, size: 'large', autoplay: false });
  const polnyjSet = (rm: boolean) => inst.set({ state: sost, size: 'large', emotion: 'neutral', reducedMotion: rm });
  return {
    mount: () => polnyjSet(false),
    os: (rm: boolean) => polnyjSet(rm),
    // смена состояния: полный set с ТЕКУЩЕЙ полярностью ОС (при rm=true
    // ловит принудительный forceReducedMotion — см. тест смены состояния
    // при активной УД)
    sostojanie: (s: string, rm = false) => { sost = s; polnyjSet(rm); },
    kadr: () => { inst.advanceTime(DT); inst.set({}); },
    put: () => path(inst.pose()),
    tochka: () => dotXY(inst.pose()),
  };
}

// ── наблюдения результата рендера ─────────────────────────────────────────────
// RNTL ReactTestInstance.props — индексированная запись хост-пропсов; чтение
// через narrowing (правило проекта: без инлайн-кастов формы объекта).
function putZnaka(): string {
  const nit = screen.queryByTestId('faden-sign-thread');
  expect(nit).not.toBeNull();
  if (!nit) throw new Error('NET_PUTI: faden-sign-thread не смонтирован');
  const props: unknown = nit.props;
  expect(props && typeof props === 'object' && 'd' in props && typeof (props as Record<string, unknown>).d === 'string').toBe(true);
  return String((props as Record<string, unknown>).d);
}
function tochkaZnaka(): [unknown, unknown] {
  const tochka = screen.queryByTestId('faden-sign-dot');
  expect(tochka).not.toBeNull();
  if (!tochka) throw new Error('NET_TOCHKI: faden-sign-dot не смонтирован');
  const props: unknown = tochka.props;
  expect(props && typeof props === 'object' && 'cx' in props && 'cy' in props).toBe(true);
  const p = props as Record<string, unknown>;
  return [p.cx, p.cy];
}
async function kadry(n: number) {
  await act(async () => { jest.advanceTimersByTime(16 * n); });
}
async function smontirovat(sostojanie: string, rm: boolean) {
  (AccessibilityInfo.isReduceMotionEnabled as jest.Mock).mockReturnValue(Promise.resolve(rm));
  const o = orakul(sostojanie);
  const derevo = await render(React.createElement(FadenSign, { state: sostojanie, testID: 'faden-sign' }));
  await act(async () => {}); // промис ОС → set(полярность)@0
  o.mount(); o.os(rm);      // то же расписание, что у компонента
  return { o, derevo };
}

describe('FadenSign (И-8): рендер знака против независимого инстанса порта', () => {
  it('rAF-часы среды (setup-файл продукта): ровно n кадров за advanceTimersByTime(16·n)', () => {
    // пресет RN даёт rAF = setTimeout(cb, 0) — тогда за 16·n мс срабатывает
    // кадр на каждую миллисекунду (замер: 769 за 768 мс), и арифметика
    // «48 кадров × 16 мс» ложна; без setup-файла этот тест именованно красен
    let kadrov = 0;
    let id = 0;
    const petlja = () => { kadrov += 1; id = requestAnimationFrame(petlja); };
    id = requestAnimationFrame(petlja);
    jest.advanceTimersByTime(16 * 3);
    cancelAnimationFrame(id);
    expect(kadrov).toBe(3);
  });

  it('контрольная точка УД различает полярности (idle@t≈777: путь И точка)', () => {
    // без различающей контрольной точки проверки ОС-привязки пусты (арбитраж:
    // у working при t=777 path и dotXY НЕ различают ОС — bead меняется; idle
    // различает и путь, и точку)
    const zhivoj = orakul('idle'); zhivoj.mount(); zhivoj.os(false);
    for (let i = 0; i < KADRY_777; i++) zhivoj.kadr();
    const statichnyj = orakul('idle'); statichnyj.mount(); statichnyj.os(true);
    for (let i = 0; i < KADRY_777; i++) statichnyj.kadr();
    expect(statichnyj.put()).not.toBe(zhivoj.put());
    expect(JSON.stringify(statichnyj.tochka())).not.toBe(JSON.stringify(zhivoj.tochka()));
  });

  it('11 состояний × обе полярности ОС: d байт-точен при t=0 и t≈777, точка тоже', async () => {
    for (const rm of [false, true]) {
      for (const sost of STATES) {
        const { o, derevo } = await smontirovat(sost, rm);
        expect(putZnaka()).toBe(o.put()); // t=0
        await kadry(KADRY_777);
        for (let i = 0; i < KADRY_777; i++) o.kadr();
        expect(putZnaka()).toBe(o.put()); // t≈777
        const [cx, cy] = tochkaZnaka();
        const [ox, oy] = o.tochka();
        expect(cx).toBe(ox);
        expect(cy).toBe(oy);
        await derevo.unmount();
      }
    }
  });

  it('смена props.state на смонтированном компоненте: цикл всех 11 состояний', async () => {
    const { o, derevo } = await smontirovat('idle', false);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    for (const sost of STATES) {
      await derevo.rerender(React.createElement(FadenSign, { state: sost, testID: 'faden-sign' }));
      await act(async () => {});
      o.sostojanie(sost);
      await kadry(KADRY_SHAG);
      for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
      expect(putZnaka()).toBe(o.put());
    }
    await derevo.unmount();
  });

  it('смена props.state при АКТИВНОЙ ОС true: путь остаётся УД-позой нового состояния', async () => {
    // ловец живой матрицы L (os-flag-prinuditelno-false): при смене
    // props.state честный компонент пишет полный set с reducedMotion=ОС,
    // принудительный false — с false; на idle@t≈777 УД-поза и анимированная
    // различаются путём И точкой (контрольная точка выше), мутант красен
    const { o, derevo } = await smontirovat('idle', true);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    await derevo.rerender(React.createElement(FadenSign, { state: 'working', testID: 'faden-sign' }));
    await act(async () => {});
    o.sostojanie('working', true);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    await derevo.rerender(React.createElement(FadenSign, { state: 'idle', testID: 'faden-sign' }));
    await act(async () => {});
    o.sostojanie('idle', true);
    await kadry(KADRY_777);
    for (let i = 0; i < KADRY_777; i++) o.kadr();
    expect(putZnaka()).toBe(o.put());
    const [cx, cy] = tochkaZnaka();
    const [ox, oy] = o.tochka();
    expect(cx).toBe(ox);
    expect(cy).toBe(oy);
    await derevo.unmount();
  });

  it('ОС false→true→false на idle: путь и точка следуют флагу (управляемое время)', async () => {
    const { o, derevo } = await smontirovat('idle', false);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    await act(async () => { if (osSlushatel) osSlushatel(true); });
    o.os(true);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    expect(putZnaka()).toBe(o.put());
    await act(async () => { if (osSlushatel) osSlushatel(false); });
    o.os(false);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    const [cx, cy] = tochkaZnaka();
    const [ox, oy] = o.tochka();
    expect(putZnaka()).toBe(o.put());
    expect(cx).toBe(ox);
    expect(cy).toBe(oy);
    await derevo.unmount();
  });

  it('ОС true→false→true на idle: путь и точка следуют флагу (управляемое время)', async () => {
    const { o, derevo } = await smontirovat('idle', true);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    await act(async () => { if (osSlushatel) osSlushatel(false); });
    o.os(false);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    expect(putZnaka()).toBe(o.put());
    await act(async () => { if (osSlushatel) osSlushatel(true); });
    o.os(true);
    await kadry(KADRY_SHAG);
    for (let i = 0; i < KADRY_SHAG; i++) o.kadr();
    const [cx, cy] = tochkaZnaka();
    const [ox, oy] = o.tochka();
    expect(putZnaka()).toBe(o.put());
    expect(cx).toBe(ox);
    expect(cy).toBe(oy);
    await derevo.unmount();
  });
});
