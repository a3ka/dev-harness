// Продуктовый движковый тест И-8 (контракт 145): реплей 21 сцены против
// docs-оракула пакета D 2.4 (PR Complior-mob#137, product main). ЭТАЛОН-ФОРМА
// ПРОДУКТА батареи 145. Исполним ДВУМЯ средами без правок:
//   1) jest-expo в CI продукта (job quality, `npm test -- faden`, cwd = mobile);
//   2) node-шим батареи (клетка a03: model/jest_shim.mjs, cwd = mobile, оракул
//      через FADEN_ORAKUL_DIR) — мутационная значимость: мутант порта обязан
//      краснить этот тест.
// Границы формы (И-8): без import.meta (babel-CJS), без jest.* API, без
// toMatchSnapshot; импорт порта — '../faden-motion.ts' (явное расширение);
// оракул — process.env.FADEN_ORAKUL_DIR, иначе <cwd>/../docs/ux/04_Gespraech_D24/motion;
// драйвер-запись — <cwd>/src/lib/faden/__tests__/faden-replay.json (байты = пин
// батареи); пины sha256 оракулов — литералами ниже (проверка в самом тесте).
import { readFileSync } from 'fs';
import { createHash } from 'crypto';
import { createInstance } from '../faden-motion.ts';

const ORAKUL_DIR = process.env.FADEN_ORAKUL_DIR || process.cwd() + '/../docs/ux/04_Gespraech_D24/motion';
const DRAJVER_PUT = process.cwd() + '/src/lib/faden/__tests__/faden-replay.json';
const PINY: Record<string, string> = {
  'faden-poses-gespraech.json': '9763fdc06b0c0a3c3138f7abac57bf5efbc714403f53d221c3b7c8d225c4f002',
  'input-tracks.json': '40e068c92e01e12676254ff40ae6315ad3474c76602d0dfb84cdd00975314b94',
  'motion-spec-gespraech.json': '064d7821428f425d431fbd1efd65cbec37263bb62ef974924746a07e769cd318',
};

const pozy = JSON.parse(readFileSync(ORAKUL_DIR + '/faden-poses-gespraech.json', 'utf8'));
const vhody = JSON.parse(readFileSync(ORAKUL_DIR + '/input-tracks.json', 'utf8'));
const drajver = JSON.parse(readFileSync(DRAJVER_PUT, 'utf8'));

// Допуски столбцов — 1 ед. viewBox (канон 96) на носителе столбца (И-3).
const DOPUSK: Record<string, number> = {
  R: 1.0, w: 1.0, g: 1.0, dotA: 1.0, dotRho: 1.0,
  sx: 1 / 60, dotScale: 1 / 11, dotOpacity: 1 / 96, check: 1 / 64, bead: 1 / 96,
};
const KOLONKI = ['R', 'w', 'g', 'sx', 'dotA', 'dotRho', 'dotScale', 'dotOpacity', 'check', 'bead'];
const DT = 1000 / 60;
const r3 = (v: number) => Math.round(v * 1000) / 1000;

function semplySceny(id: string, signaly: string[]): (number[] | null)[] {
  const zapis = vhody.scenes[id];
  if (!zapis) return signaly.map(() => null);
  const poVhodu: Record<string, number[][]> = {};
  for (const t of zapis.tracks) {
    if (t.input === 'amplitude' || t.input === 'envelope') (poVhodu[t.input] = poVhodu[t.input] || []).push(t.samples);
  }
  const indeksy: Record<string, number> = {};
  return signaly.map((vhod) => {
    const n = (indeksy[vhod] = indeksy[vhod] || 0);
    indeksy[vhod]++;
    const spisok = poVhodu[vhod] || [];
    return spisok[n] || null;
  });
}

// Реплей сцены по драйвер-записи (семантика экспортёра пакета; сцена = свежий
// инстанс, часы с нуля, 90 кадров прогрева, события/сигналы/тир — по записи).
function replay(id: string) {
  const z = drajver.sceny[id];
  const rjady = pozy.scenes[id].rows;
  const semply = semplySceny(id, z.signaly);
  const perekl = new Map(z.tiry);
  const inst = createInstance(Object.assign({}, z.nachalnye));
  for (let p = 0; p < drajver.progrev_kadrov; p++) { inst.advanceTime(DT); inst.set({}); }
  let evi = 0;
  const kadry: Record<string, number | string>[] = [];
  for (let i = 0; i < rjady.length; i++) {
    const t = rjady[i][0];
    inst.advanceTime(DT);
    while (evi < z.sobytiya.length && z.sobytiya[evi].at <= t) { inst.set(z.sobytiya[evi].set); evi++; }
    for (let s = 0; s < z.signaly.length; s++) {
      const vhod = z.signaly[s];
      const znach = semply[s] ? semply[s][i] : 0;
      inst.set({ [vhod]: znach });
    }
    inst.set({});
    kadry.push(inst.pose() as Record<string, number | string>);
    if (perekl.has(i)) inst.set({ size: perekl.get(i) });
  }
  return kadry;
}

describe('faden-motion (И-8): движок знака против docs-оракула D 2.4', () => {
  it('оракул продукта: sha256 трёх файлов совпадает с пинами', () => {
    for (const imja of Object.keys(PINY)) {
      const hesh = createHash('sha256').update(readFileSync(ORAKUL_DIR + '/' + imja)).digest('hex');
      expect(hesh).toBe(PINY[imja]);
    }
  });

  it('реплей 21 сцены: все 6680 строк в допуске столбцов, тон — точно', () => {
    const sceny = Object.keys(drajver.sceny);
    expect(sceny.length).toBe(21);
    let vsehStrok = 0, ploho = 0;
    let pervyjNarushitel = '';
    for (const id of sceny) {
      const rjady = pozy.scenes[id].rows;
      const kadry = replay(id);
      expect(kadry.length).toBe(rjady.length);
      for (let i = 0; i < rjady.length; i++) {
        vsehStrok++;
        for (let j = 0; j < KOLONKI.length; j++) {
          const k = KOLONKI[j];
          const otkl = Math.abs(r3(kadry[i][k] as number) - rjady[i][j + 1]);
          if (otkl > DOPUSK[k]) {
            ploho++;
            if (!pervyjNarushitel) pervyjNarushitel = id + ' кадр ' + i + ' (t=' + rjady[i][0] + ') столбец ' + k + ': ' + r3(kadry[i][k] as number) + ' != оракул ' + rjady[i][j + 1] + ' (отклонение ' + otkl + ')';
            break;
          }
        }
        if (kadry[i].tone !== rjady[i][11]) {
          ploho++;
          if (!pervyjNarushitel) pervyjNarushitel = id + ' кадр ' + i + ': тон ' + kadry[i].tone + ' != оракул ' + rjady[i][11];
        }
      }
    }
    expect(vsehStrok).toBe(6680);
    expect('строк с превышением: ' + ploho + (pervyjNarushitel ? '; первый: ' + pervyjNarushitel : '')).toBe('строк с превышением: 0');
  });

  it('непрерывность позы по t: иголки вне сеток запрещены', () => {
    // дополнение к реплею: поза зависит от t непрерывно — на шаге 0.25 мс
    // (вне сетки 60 fps) скачок столбца > 1 ед. viewBox = мутант-«иголка»,
    // которого покадровый реплей может не заметить (форма клетки p14 батареи)
    const stany = ['idle', 'listening', 'speaking', 'working', 'done'];
    let rezov = 0;
    for (const st of stany) {
      const inst = createInstance({ state: st, autoplay: false });
      inst.advanceTime(DT); inst.set({});
      const p0 = inst.pose() as Record<string, number>;
      inst.advanceTime(0.25); inst.set({});
      const p1 = inst.pose() as Record<string, number>;
      for (const k of KOLONKI) {
        if (Math.abs((p1[k] as number) - (p0[k] as number)) > 1.0) rezov++;
      }
    }
    expect('скачков > 1 ед. viewBox на 0.25 мс: ' + rezov).toBe('скачков > 1 ед. viewBox на 0.25 мс: 0');
  });
});
