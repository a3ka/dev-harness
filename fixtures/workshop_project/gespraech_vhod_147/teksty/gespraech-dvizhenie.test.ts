// Канон численной приёмки движения пачки gespraech-vhod (контракт 147).
// Исполняется продуктовым jest (jest-expo; rAF-часы и пресеты — 145),
//     npm --prefix mobile test -- --ci --runInBand --json --outputFile \
//         e2e-gespraech-vhod/jest-otchet.json gespraech
// Времена/кривые/УД наследуются из Final2 через Kompakt-1.1.
// Геометрия — производный scenes/tokens-spec и единый носитель geometrija-147.json
// в docs/ux/05_Kompakt_D24/motion (пины piny.json, red_geo_147.py харнесса).
// Заголовки тестов — без численно-буквенных пар (урок 145 v4).
import { createMenuMachine, PlanTrek } from '../menu-machine';
import { readFileSync } from 'node:fs';

interface TrekSpeki {
  delayMs: number;
  durationMs: number;
  curve: string;
  reducedMs: number;
}

// Ожидания загружаются ДО spec-субъекта. Порядок JSON-ключей не значим.
interface GeoScene {
  element?: string;
  from_rect?: string;
  to_rect?: string;
  rects?: Record<string, [number, number]>;
  adaptive?: {
    top: number; cap: number; min: number;
    start: Record<string, number>; end: Record<string, number>;
    S_from?: number[]; P_from?: number[]; P_to?: number[];
  };
}
const geometry: { scenes: Record<string, GeoScene> } = JSON.parse(readFileSync(
  '../docs/ux/05_Kompakt_D24/motion/geometrija-147.json', 'utf8'));
// cwd jest — mobile; источники дизайнера — в корне репо продукта
const spec = JSON.parse(readFileSync(
  '../docs/ux/05_Kompakt_D24/motion/motion-spec-gespraech-kompakt-147.json',
  'utf8'));

const token = (imja: string): number => {
  const t = spec.tokens.filter((x: { name: string }) => x.name === imja)[0];
  const m = /^([0-9.]+)ms$/.exec(t.value);
  if (!m) {
    throw new Error('токен не в миллисекундах: ' + imja);
  }
  return Number(m[1]);
};

const mashina = createMenuMachine({
  motionFast: token('motion-fast'),
  motionBase: token('motion-base'),
  staggerTight: token('motion-stagger-tight'),
  pressLong: token('press-long'),
});

interface Scena {
  id: string;
  tracks: Array<{ element: string; property: string;
                  delay: { ms: number }; duration: { ms: number };
                  curve: { token: string };
                  reduced_duration_ms: number }>;
}

const scena = (id: string): Scena =>
  spec.scenes.filter((x: Scena) => x.id === id)[0];

const kartaSceny = (id: string): Map<string, TrekSpeki> => {
  const karta = new Map<string, TrekSpeki>();
  for (const t of scena(id).tracks) {
    karta.set(t.element + '|' + t.property, {
      delayMs: t.delay.ms, durationMs: t.duration.ms,
      curve: t.curve.token, reducedMs: t.reduced_duration_ms,
    });
  }
  return karta;
};

const soglaseny = (plany: PlanTrek[], karta: Map<string, TrekSpeki>):
    string[] => {
  const net: string[] = [];
  for (const p of plany) {
    const e = karta.get(p.element + '|' + p.property);
    if (!e || e.delayMs !== p.delayMs || e.durationMs !== p.durationMs
        || e.curve !== p.curve || e.reducedMs !== p.reducedMs) {
      net.push(p.element + '|' + p.property);
    }
  }
  return net;
};

describe('gespraech-vhod: численная приёмка движения', () => {
  test('план открытия совпадает с треками сцены открытия меню', () => {
    expect(soglaseny(mashina.planOpen(), kartaSceny('GA-T28'))).toEqual([]);
  });

  test('план закрытия совпадает с треками сцены закрытия меню', () => {
    expect(soglaseny(mashina.planClose(), kartaSceny('GA-T31'))).toEqual([]);
  });

  test('пилюли меню появляются сверху вниз, первым разговор с агентом',
       () => {
    const zaderzhki = mashina.planOpen()
      .filter((p) => p.property === 'opacity'
             && p.element.includes('li:nth-child'))
      .map((p) => p.delayMs);
    expect(zaderzhki).toEqual([...zaderzhki].sort((a, b) => a - b));
    expect(zaderzhki).toHaveLength(4);
    const pervaja = mashina.planOpen().filter(
      (p) => p.element.endsWith('li:nth-child(1)')
           && p.property === 'opacity')[0];
    expect(pervaja.delayMs).toBeLessThan(zaderzhki[1]);
  });

  test('меню читается целиком к трёхсотой миллисекунде', () => {
    const koncy = mashina.planOpen()
      .filter((p) => p.property === 'opacity'
             && p.element.includes('li:nth-child'))
      .map((p) => p.delayMs + p.durationMs);
    expect(Math.max.apply(null, koncy)).toBeLessThanOrEqual(300);
  });

  test('полёт знака к вопросу — морф базовой длительности на кривой морфа',
       () => {
    const morf = mashina.planOpen().filter((p) => p.element === '#mkg');
    expect(morf).toHaveLength(4);
    for (const p of morf) {
      expect(p.durationMs).toBe(token('motion-base'));
      expect(p.curve).toBe('ease-morph');
      expect(p.reducedMs).toBe(0);
    }
  });

  test('удержание центральной кнопки до порога даёт голос, раньше — меню',
       () => {
    const porog = token('press-long');
    expect(mashina.planHold()[0].to).toBeCloseTo(1.06, 5);
    expect(mashina.planHold()[0].durationMs).toBe(porog);
    expect(mashina.planHold()[0].curve).toBe('linear');
    expect(mashina.holdResult(porog - 1)).toBe('menu');
    expect(mashina.holdResult(porog)).toBe('voice');
    expect(soglaseny(mashina.planVoice(), kartaSceny('GA-T35'))).toEqual([]);
  });

  test('при уменьшении движения полёта нет: перемещение мгновенно, видимое'
       + ' — не дольше быстрого токена', () => {
    for (const p of mashina.planOpen()) {
      if (p.property === 'opacity') {
        expect(p.reducedMs).toBeLessThanOrEqual(token('motion-fast'));
      } else {
        expect(p.reducedMs).toBe(0);
      }
    }
  });
});

describe('gespraech-vhod: компактная геометрия движения', () => {
  const titles: Record<string, string> = {
    'GA-T28': 'открытие меню', 'GA-T29': 'меню в голос',
    'GA-T30': 'меню в поле', 'GA-T31': 'закрытие меню',
    'GA-T33': 'ждущий Vorgang в карточку',
  };
  for (const [id, expected] of Object.entries(geometry.scenes)) {
    test(titles[id], () => {
      const scene = spec.scenes.find((s: {id: string}) => s.id === id);
      expect(scene).toBeDefined();
      for (const [property, pair] of Object.entries(expected.rects || {})) {
        const tracks = scene.tracks.filter((t: {element: string; property: string}) =>
          t.element === expected.element && t.property === property);
        expect(tracks).toHaveLength(1);
        const k = ({left: 'x', top: 'y', w: 'w', h: 'h'} as Record<string,string>)[property];
        expect(tracks[0].from).toEqual({rect: expected.from_rect, k});
        expect(tracks[0].to).toEqual({rect: expected.to_rect, k});
        for (const theme of ['dark', 'light']) {
          expect(tracks[0].resolved[theme]).toEqual({from: pair[0], to: pair[1]});
        }
      }
      if (expected.adaptive) {
        const a = scene.adaptive;
        const e = expected.adaptive;
        expect(a.top).toBe(e.top);
        expect(a.caps).toEqual([[-1000000000, e.cap]]);
        expect(a.rule).toContain('S = max(' + e.min + ', min(cap, P − 64))');
        expect(a.rule).toContain('P − 64 < ' + e.min + ';');
        expect(a.timeline[0]).toMatchObject(e.start);
        expect(a.end).toMatchObject(e.end);
        if (e.S_from) {
          const rows = a.timeline.filter((t: {kind: string}) => t.kind === 'retarget');
          expect(rows).toHaveLength(e.S_from.length);
          rows.forEach((t: Record<string, number>, i: number) => {
            expect(t).toMatchObject({cap: e.cap, S_to: e.cap,
              S_from: e.S_from![i], P_from: e.P_from![i], P_to: e.P_to![i]});
          });
        }
      }
    });
  }
});
