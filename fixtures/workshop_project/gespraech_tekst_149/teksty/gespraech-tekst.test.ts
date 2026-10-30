// Канон численной приёмки движения пачки gespraech-tekst (контракт 149).
// Исполняется продуктовым jest (jest-expo; rAF-часы и пресеты — 145):
//     npm --prefix mobile test -- --ci --runInBand --json --outputFile \
//         e2e-gespraech-tekst/jest-otchet.json gespraech
// Сверяет машину текст-чата против ПИННОВАННОЙ спеки дизайнера:
// docs/ux/04_Gespraech_D24/motion/motion-spec-gespraech.json (байты
// сверяет валидатор 132 v3 по dvizhenie.spec_sha256). Заголовки тестов —
// без численно-буквенных пар (урок 145 v4: аудит литералов в отчёте).
import { createChatMachine, PlanTrek, VremenaSobytij } from '../chat-machine';
import { readFileSync } from 'node:fs';

interface TrekSpeki {
  delayMs: number;
  durationMs: number;
  curve: string;
  reducedMs: number;
}

// cwd jest — mobile; источники дизайнера — в корне репо продукта
const spec = JSON.parse(readFileSync(
  '../docs/ux/04_Gespraech_D24/motion/motion-spec-gespraech.json',
  'utf8'));

const token = (imja: string): number => {
  const t = spec.tokens.filter((x: { name: string }) => x.name === imja)[0];
  const m = /^([0-9.]+)ms$/.exec(t.value);
  if (!m) {
    throw new Error('токен не в миллисекундах: ' + imja);
  }
  return Number(m[1]);
};

const mashina = createChatMachine({
  motionFast: token('motion-fast'),
  motionBase: token('motion-base'),
  motionMorph: token('motion-morph'),
});

interface Scena {
  id: string;
  tracks: Array<{ element: string; property: string;
                  delay: { ms: number }; duration: { ms: number };
                  curve: { token: string };
                  reduced_duration_ms: number }>;
  events: Array<{ element: string; at: { ms: number } }>;
}

const scena = (id: string): Scena =>
  spec.scenes.filter((x: Scena) => x.id === id)[0];

// таймлайн сцены плашки — из СОБЫТИЙ спеки (машина получает параметром)
const vremenaT32 = (): VremenaSobytij => {
  const po: Record<string, number> = {};
  for (const s of scena('GA-T32').events) {
    po[s.element] = s.at.ms;
  }
  return { otmetka: po['#b-mk'], vopros: po['#b-a'], chipy: po['#b-qr'] };
};

const plany = {
  t30: mashina.planT30(),
  t32: mashina.planT32(vremenaT32()),
  t37: mashina.planT37(),
};

// МУЛЬТИМНОЖЕСТВО треков сцены: элемент+свойство → список (сцены
// переходов к тексту несут два трека слоя морфа с одной парой
// элемент-свойство — появление в нуле и уход на морф-минус-быстрый)
const kartaSceny = (id: string): Map<string, TrekSpeki[]> => {
  const karta = new Map<string, TrekSpeki[]>();
  for (const t of scena(id).tracks) {
    const kljuch = t.element + '|' + t.property;
    if (!karta.has(kljuch)) {
      karta.set(kljuch, []);
    }
    karta.get(kljuch)!.push({
      delayMs: t.delay.ms, durationMs: t.duration.ms,
      curve: t.curve.token, reducedMs: t.reduced_duration_ms,
    });
  }
  return karta;
};

const soglaseny = (plany_sceny: PlanTrek[], karta: Map<string, TrekSpeki[]>):
    string[] => {
  const ostatok = new Map(karta);
  const net: string[] = [];
  for (const p of plany_sceny) {
    const spisok = ostatok.get(p.element + '|' + p.property) || [];
    const i = spisok.findIndex((e) => e.delayMs === p.delayMs
        && e.durationMs === p.durationMs && e.curve === p.curve
        && e.reducedMs === p.reducedMs);
    if (i < 0) {
      net.push(p.element + '|' + p.property);
    } else {
      spisok.splice(i, 1);
    }
  }
  for (const spisok of ostatok.values()) {
    for (const _ of spisok) {
      net.push('неполнота');
    }
  }
  return net;
};

const trek = (pl: PlanTrek[], element: string, property: string) =>
  pl.filter((p) => p.element === element && p.property === property)[0];

describe('gespraech-tekst: численная приёмка движения', () => {
  test('план перехода из меню в письмо совпадает с треками сцены', () => {
    expect(soglaseny(plany.t30, kartaSceny('GA-T30'))).toEqual([]);
  });

  test('непрозрачный фон закрывает меню до построения чата', () => {
    const fon = trek(plany.t30, '#gnd', 'opacity');
    const nachala = plany.t30
      .filter((p) => p.element.startsWith('.L-chat2'))
      .map((p) => p.delayMs);
    expect(fon.delayMs + fon.durationMs)
      .toBeLessThanOrEqual(Math.min.apply(null, nachala));
  });

  test('морф пилюли письма в поле — длительность морфа на кривой морфа',
       () => {
    const mesta = plany.t30.filter((p) => p.element === '#morph'
        && ['left', 'top', 'w', 'h'].includes(p.property));
    expect(mesta).toHaveLength(4);
    for (const p of mesta) {
      expect(p.durationMs).toBe(token('motion-morph'));
      expect(p.curve).toBe('ease-morph');
      expect(p.reducedMs).toBe(0);
    }
    const pole = trek(plany.t30, '.L-chat2 .p-chatcomp-field', 'opacity');
    expect(pole.delayMs)
      .toBe(token('motion-morph') - token('motion-fast'));
  });

  test('темы-строка над полем появляется после поля', () => {
    const temy = trek(plany.t30, '.L-chat2 .p-topics', 'opacity');
    const pole = trek(plany.t30, '.L-chat2 .p-chatcomp-field', 'opacity');
    expect(temy.delayMs).toBe(token('motion-morph'));
    expect(pole.delayMs + pole.durationMs)
      .toBeLessThanOrEqual(temy.delayMs);
  });

  test('план перехода плашки в тему совпадает с треками сцены', () => {
    expect(soglaseny(plany.t32, kartaSceny('GA-T32'))).toEqual([]);
  });

  test('вопрос агента раньше чипов, чипы с приглашением — вместе', () => {
    const vopros = trek(plany.t32, '#b-a', 'reveal');
    const chipy = trek(plany.t32, '#b-qr', 'opacity');
    expect(vopros.delayMs).toBeLessThan(chipy.delayMs);
    expect(plany.t32.filter((p) => p.element === '#b-qr')).toHaveLength(2);
  });

  test('план возврата из голоса к тексту совпадает с треками сцены', () => {
    expect(soglaseny(plany.t37, kartaSceny('GA-T37'))).toEqual([]);
  });

  test('морф полосы голоса в поле и строка продолжения после морфа', () => {
    const mesta = plany.t37.filter((p) => p.element === '#morph'
        && ['left', 'top', 'w', 'h'].includes(p.property));
    expect(mesta).toHaveLength(4);
    for (const p of mesta) {
      expect(p.durationMs).toBe(token('motion-morph'));
      expect(p.curve).toBe('ease-morph');
      expect(p.reducedMs).toBe(0);
    }
    const pole = trek(plany.t37, '#a-text .p-chatcomp-field', 'opacity');
    expect(pole.delayMs)
      .toBe(token('motion-morph') - token('motion-fast'));
    const stroka = trek(plany.t37, '#b-end', 'opacity');
    expect(stroka.delayMs).toBe(token('motion-morph'));
  });

  test('при уменьшении движения полёта нет: перемещение мгновенно,'
       + ' видимое — не дольше быстрого токена', () => {
    for (const pl of [plany.t30, plany.t32, plany.t37]) {
      for (const p of pl) {
        if (p.property === 'opacity' || p.property === 'bg') {
          expect(p.reducedMs).toBeLessThanOrEqual(token('motion-fast'));
        } else {
          expect(p.reducedMs).toBe(0);
        }
      }
    }
  });

  test('поле ввода растёт до потолка строк, за потолком — прокрутка', () => {
    const potolok = mashina.poleStrokMaksimum();
    for (let n = 1; n <= potolok + 1; n++) {
      expect(mashina.poleRastjot(n)).toBe(n <= potolok);
      expect(mashina.poleSkrolluet(n)).toBe(n > potolok);
    }
  });
});
