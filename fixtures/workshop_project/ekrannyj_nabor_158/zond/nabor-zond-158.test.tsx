// Зонд экранного набора ekrannyj_nabor_158 (контракт 158, И-1/И-2): судит
// КАРТУ целей экрана хелперами helpery.ts на реальных компонентах референса.
// Копируется раннером в mobile/src/__nabor158__/ одноразовой копии R;
// исполняется jest референса (прецедент zhivoj_komponent 145).
//
// Режим — NABOR_158_REZHIM: 'karta' (по умолчанию: карта NABOR_158_KARTA) или
// 'sintetika' (12 способов зоны ≥44, ЛОЖНЫХ ОТКАЗОВ НЕТ — клетка f02).
// Трасса — построчно в файл NABOR_158_TRASSA (раннер читает её, не stdout):
//   ZOND <testID> <профиль> ok | ZOND <testID> <профиль> KRASNO <ПРИЧИНА>
//   IZMER <testID> <профиль> <ширина>x<высота>     (зона хозяина, px)
//   ZONA <идентификатор> ok | ZONA <идентификатор> KRASNO <ПРИЧИНА>
// Сама проверка карты НЕ роняет сьют: исход судит раннер по трассе.
import fs from 'fs';
import path from 'path';
import React from 'react';
import { Dimensions, View } from 'react-native';
import { fireEvent, render, screen } from '@testing-library/react-native';

import { TabShell } from '../bootstrap/tab-shell';
import { FirstRunScreen } from '../features/auth/first-run-screen';
import {
  a11yNadpis, interaktivnyjHozjain, otklyuchenaPoCepi, vidimajaNadpis,
  vidimostUzla, zonaKasanija,
} from './helpery';
import { SinteticheskijEkran, ZONY } from './sinteticheskij-ekran';

const REZHIM = process.env.NABOR_158_REZHIM ?? 'karta';
const TRASSA = process.env.NABOR_158_TRASSA ?? '';
const KARTA = process.env.NABOR_158_KARTA ?? '';
const VYSOTA: Record<string, number> = { '390': 844, '393': 852 };

const TOKENY = path.join(__dirname, '..', '..', '..', 'docs', 'ux',
  '05_Kompakt_D24', 'source', 'tokens.json');

function minimumZony(): number {
  try {
    const tok = JSON.parse(fs.readFileSync(TOKENY, 'utf8'));
    const m = String(tok['touch-target'].min.$value).match(/^(\d+(?:\.\d+)?)px$/);
    if (m) return parseFloat(m[1]);
  } catch {
    // токена нет — канонический минимум набора
  }
  return 44;
}

interface Sostojanie { id: string; vhod: string | null }
interface Tsel {
  testID: string;
  objazatelna: boolean;
  sostojanija: string[];
  nadpis: string | null;
  // Доступное имя цели-иконки (видимой надписи нет) — объявляется картой.
  accessibilityLabel?: string | null;
  postuslovie: { tip: string; znachenie: string };
}
interface Karta { profili: string[]; sostojanija: Sostojanie[]; tceli: Tsel[] }

const stroki: string[] = [];

/** Поиск по testID ВКЛЮЧАЯ скрытые узлы: существование — физический факт
 * дерева; видимость судит vidimostUzla (display:'none' не «исчезновение»). */
function najti(id: string) {
  return screen.queryByTestId(id, { includeHiddenElements: true });
}

function podpis(): string {
  return JSON.stringify(screen.toJSON());
}
function pisat(s: string): void {
  stroki.push(s);
}
function sohranit(): void {
  if (TRASSA) fs.writeFileSync(TRASSA, stroki.join('\n') + '\n', 'utf8');
}

/** Маркер копии: файл .firstrun рядом с зондом — копия содержит компонент
 * First-Run с настоящими целями (генератор f06–f08). Без маркера зонд
 * судит только экран оболочки. */
const PERVYJ_RUN = fs.existsSync(path.join(__dirname, '.firstrun'));

async function otrisovat(shirina: number, komandy: jest.Mock) {
  jest.spyOn(Dimensions, 'get').mockImplementation((() => ({
    width: shirina, height: VYSOTA[String(shirina)] ?? 844, scale: 3,
    fontScale: 1,
  })) as never);
  // Команды целей First-Run идут в тот же изолированный счётчик.
  const globalKommand = globalThis as unknown as {
    __nabor158_command?: (c: unknown) => void;
  };
  globalKommand.__nabor158_command = (c: unknown) => komandy(c);
  return render(
    <View style={{ width: shirina }}>
      <TabShell onCommand={komandy} />
      {PERVYJ_RUN ? <FirstRunScreen onEnter={() => undefined} /> : null}
    </View>,
  );
}

function postuslovieVypolneno(post: { tip: string; znachenie: string }): boolean {
  if (post.tip !== 'perehod') return true;
  if (post.znachenie.startsWith('!')) {
    return najti(post.znachenie.slice(1)) === null;
  }
  return najti(post.znachenie) !== null;
}

async function voyti(sost: Sostojanie, karta: Karta): Promise<boolean> {
  if (sost.vhod === null) return true;
  const el = najti(sost.vhod);
  if (el === null) return false;
  await fireEvent.press(el);
  const vhodnaja = karta.tceli.find((c) => c.testID === sost.vhod);
  return vhodnaja === undefined ? true : postuslovieVypolneno(vhodnaja.postuslovie);
}

interface Itog { prichina: string | null; izmer: string }

async function proverit(tsel: Tsel, shirina: number, komandy: jest.Mock,
                        minimum: number): Promise<Itog> {
  const el = najti(tsel.testID);
  if (el === null) return { prichina: 'TSEL_OTSVTSTVUET', izmer: '' };
  if (otklyuchenaPoCepi(el)) return { prichina: 'TSEL_VYKLYUCHENA', izmer: '' };
  const hozjain = interaktivnyjHozjain(el);
  if (hozjain === null) return { prichina: 'BEZ_HOZJAINA', izmer: '' };
  const vysota = VYSOTA[String(shirina)] ?? 844;
  const zona = zonaKasanija(hozjain, shirina);
  const izmer = `${zona.w}x${zona.h}`;
  if (!vidimostUzla(hozjain, shirina, vysota) || !vidimostUzla(el, shirina, vysota)) {
    return { prichina: 'TSEL_NEVIDIMA', izmer };
  }
  if (tsel.nadpis !== null && !vidimajaNadpis(hozjain, tsel.nadpis, shirina, vysota)) {
    return { prichina: 'NADPIS_NEVIDIMA', izmer };
  }
  // Цель-иконка (видимой надписи нет): обязательное доступное имя — картой.
  if (tsel.accessibilityLabel != null &&
      !a11yNadpis(el, hozjain, tsel.accessibilityLabel)) {
    return { prichina: 'NADPIS_NEVIDIMA', izmer };
  }
  if (zona.w < minimum || zona.h < minimum) {
    return { prichina: 'ZONA_MENSHE_NORMY', izmer };
  }
  const raneeVyzovy = komandy.mock.calls.length;
  const podpisDo = podpis();
  await fireEvent.press(el);
  const post = tsel.postuslovie;
  if (post.tip === 'vyzov') {
    if (komandy.mock.calls.length === raneeVyzovy) {
      return { prichina: 'NET_DEJSTVIJA', izmer };
    }
    const poslednij = komandy.mock.calls[komandy.mock.calls.length - 1][0] as
      { kind?: string };
    if (komandy.mock.calls.length !== raneeVyzovy + 1 ||
        poslednij.kind !== post.znachenie) {
      return { prichina: 'DEJSTVIE_CHUZHOE', izmer };
    }
    return { prichina: null, izmer };
  }
  if (postuslovieVypolneno(post)) return { prichina: null, izmer };
  return {
    prichina: podpis() === podpisDo ? 'NET_DEJSTVIJA' : 'DEJSTVIE_CHUZHOE',
    izmer,
  };
}

async function sudKarty(): Promise<void> {
  const karta: Karta = JSON.parse(fs.readFileSync(KARTA, 'utf8'));
  const minimum = minimumZony();
  const itogi = new Map<string, Itog>();
  for (const profil of karta.profili) {
    const shirina = Number(profil);
    for (const sost of karta.sostojanija) {
      const spisok = karta.tceli.filter((c) => c.sostojanija.includes(sost.id));
      // чужие цели состояния обязаны отсутствовать (слияние состояний)
      {
        const komandy = jest.fn();
        const vid = await otrisovat(shirina, komandy);
        const dostignuto = await voyti(sost, karta);
        for (const c of karta.tceli) {
          const klyuch = `${c.testID}|${profil}`;
          if (itogi.has(klyuch) && itogi.get(klyuch)!.prichina !== null) continue;
          if (!dostignuto) {
            if (c.sostojanija.includes(sost.id) &&
                najti(c.testID) === null) {
              itogi.set(klyuch, { prichina: 'SOSTOJANIE_NEDOSTIZHIMO', izmer: '' });
            }
            continue;
          }
          if (!c.sostojanija.includes(sost.id) &&
              najti(c.testID) !== null) {
            itogi.set(klyuch, { prichina: 'SOSTOJANIE_SLITO', izmer: '' });
          }
        }
        await vid.unmount();
      }
      for (const c of spisok) {
        const klyuch = `${c.testID}|${profil}`;
        if (itogi.has(klyuch) && itogi.get(klyuch)!.prichina !== null) continue;
        const komandy = jest.fn();
        const vid = await otrisovat(shirina, komandy);
        const dostignuto = await voyti(sost, karta);
        let itog: Itog;
        if (!dostignuto && najti(c.testID) === null) {
          itog = { prichina: 'SOSTOJANIE_NEDOSTIZHIMO', izmer: '' };
        } else {
          itog = await proverit(c, shirina, komandy, minimum);
        }
        if (!itogi.has(klyuch) || itogi.get(klyuch)!.prichina === null) {
          itogi.set(klyuch, itog);
        }
        await vid.unmount();
      }
    }
  }
  // Различие профилей: цель исправна на одном профиле и неисполнима на
  // другом — DEJSTVIE_NA_PROFILE_NET; одинаково неисполнима везде —
  // TSEL_BEZ_HOZJAINA (нет хозяина) либо TSEL_VYKLYUCHENA (нет доставки).
  const OTLOZHENNYE: Record<string, string> = {
    BEZ_HOZJAINA: 'TSEL_BEZ_HOZJAINA',
    NET_DEJSTVIJA: 'TSEL_VYKLYUCHENA',
  };
  for (const c of karta.tceli) {
    const ispravnyj = karta.profili.some(
      (p) => itogi.get(`${c.testID}|${p}`)?.prichina === null);
    for (const profil of karta.profili) {
      const it = itogi.get(`${c.testID}|${profil}`);
      if (it === undefined || it.prichina === null ||
          OTLOZHENNYE[it.prichina] === undefined) continue;
      it.prichina = ispravnyj ? 'DEJSTVIE_NA_PROFILE_NET' : OTLOZHENNYE[it.prichina];
    }
  }
  for (const profil of karta.profili) {
    for (const c of karta.tceli) {
      const it = itogi.get(`${c.testID}|${profil}`);
      if (it === undefined) continue;
      pisat(it.prichina === null ? `ZOND ${c.testID} ${profil} ok` :
        `ZOND ${c.testID} ${profil} KRASNO ${it.prichina}`);
      if (it.izmer) pisat(`IZMER ${c.testID} ${profil} ${it.izmer}`);
    }
  }
}

async function sudSintetiki(): Promise<void> {
  const minimum = minimumZony();
  const shirina = 390;
  const vid = await render(
    <View style={{ width: shirina }}>
      <SinteticheskijEkran />
    </View>,
  );
  for (const z of ZONY) {
    const el = najti('nabor158-' + z);
    let prichina: string | null = null;
    if (el === null) {
      prichina = 'TSEL_OTSVTSTVUET';
    } else {
      const hozjain = interaktivnyjHozjain(el);
      if (hozjain === null) {
        prichina = 'BEZ_HOZJAINA';
      } else {
        const zona = zonaKasanija(hozjain, shirina);
        if (zona.w < minimum || zona.h < minimum) prichina = 'ZONA_MENSHE_NORMY';
        else if (!vidimostUzla(hozjain, shirina)) prichina = 'TSEL_NEVIDIMA';
        else if (!vidimajaNadpis(hozjain, 'Z', shirina)) prichina = 'NADPIS_NEVIDIMA';
      }
    }
    pisat(prichina === null ? `ZONA ${z} ok` : `ZONA ${z} KRASNO ${prichina}`);
  }
  await vid.unmount();
}

describe('набор 158: зонд карты целей', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });
  it('судит ' + REZHIM, async () => {
    try {
      if (REZHIM === 'sintetika') await sudSintetiki();
      else await sudKarty();
    } finally {
      sohranit();
    }
  }, 600000);
});
