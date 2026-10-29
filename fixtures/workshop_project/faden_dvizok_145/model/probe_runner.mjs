// probe_runner.mjs — движок клеток батареи 145 «faden-dvizok» (сторона ПРОВЕРЯЮЩЕГО).
// Исполняется чистым node (без npm/сети/эмулятора). Ожидания грузятся в память ДО
// вызова субъекта из model/ батареи (правило 8): строки поз, входы, спек, драйвер,
// референс-движок. Субъект — ТОЛЬКО модуль движка (+токены/+драйвер-запись) и не
// читается как источник ожиданий.
//
// Аргументы:
//   --model <dir>             каталог модели батареи (референс+оракул+драйвер)
//   --subject <файл>          движок субъекта (.ts ESM или .js IIFE референса)
//   --subject-tokens <файл>   модуль токенов субъекта (.ts)
//   --subject-driver <файл>   драйвер-запись субъекта (.json)
//   --mode model|repo         режим (допуск строк: model=0.002 [границы round3
//                             экспортёра, замер 45/6680], repo=допуск столбцов
//                             из source.json — 1 ед. viewBox на носителе столбца)
//   --source <source.json>    единый источник допусков
//   --repo-root <dir>         корень продукта (для A-оси; задаёт probe.py)
//   --produkt-canon <dir>     эталон produkt-форма батареи — канон обязательных
//                             тестов (a03/a05 сравнивают байты; сама форма
//                             пиннена sha256 в source.json:.piny)
//   --seed <N>                seed сеяных входов p14/p15 (дефолт 145; судья
//                             вправе менять — «порт, знающий выборку», ловится)
//   --perechen                напечатать перечень клеток JSON-строкой и выйти
//
// Выход: построчные JSON {"kletka","ok","prichina","detali"}; rc 0 всегда
// (вердикт сводит probe.py). Каждая клетка именует причину отказа.
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import crypto from 'node:crypto';
import os from 'node:os';
import { spawnSync } from 'node:child_process';

const DT = 1000 / 60;
const KOLONKI = ['R', 'w', 'g', 'sx', 'dotA', 'dotRho', 'dotScale', 'dotOpacity', 'check', 'bead'];
const KLETKI_S = ['GA-T29', 'GA-T35', 'GA-T33', 'GA-T32', 'GA-T34', 'GA-T08', 'GA-T27', 'GA-T37', 'GA-T16', 'GA-T17', 'GA-T18', 'GA-T19', 'GA-T20', 'GA-T21', 'GA-T22', 'GA-T23', 'GA-T24', 'GA-R2', 'GA-R2-393', 'GA-R3', 'GA-R3-393'];
const KLETKI_P = ['p01-sostojanija-tiry', 'p02-emocii', 'p03-prime', 'p04-tab', 'p05-path-svg', 'p06-morph', 'p07-adaptive', 'p08-voicebars', 'p09-tierfor', 'p10-bezier', 'p11-katalog', 'p12-instance-sglazhivanie', 'p13-instance-restart', 'p14-pose-sejanye-vhody', 'p15-instance-sejanye-vhody'];
const KLETKI_D = ['d01-ud-pozy', 'd02-ud-instance', 'd03-ud-sceny'];
const KLETKI_T = ['t01-tokemy'];
// I-ось — тестовый источник состояний (§4 бэкенд-разбора; слово 29.10 ~00:55)
const KLETKI_I = ['i01-istochnik-funkcija', 'i02-istochnik-vydumannaja-faza'];
const KLETKI_A = ['a01-drajver-zapis', 'a02-fajly-komponenta', 'a03-jest-dvizhok-kanon', 'a05-jest-znak-celesnost'];
const VSE_KLETKI = [...KLETKI_S.map(id => 's-' + id.toLowerCase()), ...KLETKI_P, ...KLETKI_D, ...KLETKI_T, ...KLETKI_I, ...KLETKI_A];

// ── аргументы ─────────────────────────────────────────────────────────────────
function argy() {
  const a = { mode: 'model' };
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--perechen') a.perechen = true;
    else if (argv[i] === '--sostojanija') a.sostojanija = true;
    else if (argv[i] === '--model') a.model = argv[++i];
    else if (argv[i] === '--subject') a.subject = argv[++i];
    else if (argv[i] === '--subject-tokens') a.subjectTokens = argv[++i];
    else if (argv[i] === '--subject-driver') a.subjectDriver = argv[++i];
    else if (argv[i] === '--subject-istochnik') a.subjectIst = argv[++i];
    else if (argv[i] === '--mode') a.mode = argv[++i];
    else if (argv[i] === '--source') a.source = argv[++i];
    else if (argv[i] === '--repo-root') a.repoRoot = argv[++i];
    else if (argv[i] === '--produkt-canon') a.produktCanon = argv[++i];
    else if (argv[i] === '--seed') a.seed = argv[++i];
    else { console.error('NEIZVESTNYJ_ARGUMENT: ' + argv[i]); process.exit(2); }
  }
  return a;
}
const A = argy();
if (A.perechen) { console.log(JSON.stringify(VSE_KLETKI)); process.exit(0); }

const src = JSON.parse(fs.readFileSync(A.source, 'utf8'));
const DOPUSK = src.dopusk_stolbcov;
const MODEL = fs.realpathSync(A.model);
const pozy = JSON.parse(fs.readFileSync(path.join(MODEL, 'oracle/faden-poses-gespraech.json'), 'utf8'));
const vhody = JSON.parse(fs.readFileSync(path.join(MODEL, 'oracle/input-tracks.json'), 'utf8'));
const spec = JSON.parse(fs.readFileSync(path.join(MODEL, 'oracle/motion-spec-gespraech.json'), 'utf8'));
const drajver = JSON.parse(fs.readFileSync(path.join(MODEL, 'drajver.json'), 'utf8'));
const TOKENA_SPEKA = Object.fromEntries(spec.tokens.map(t => [t.name, t.value]));

// ── загрузка движка: референс (IIFE через vm) и субъект (ESM .ts | IIFE .js) ───
function zagaruziIIFE(put) {
  const VNOW = { v: 0 };
  function elem() {
    return { style: { setProperty() {} }, setAttribute() {}, appendChild() {}, removeAttribute() {}, childNodes: [], innerHTML: '' };
  }
  const sandbox = {
    document: { createElementNS: () => elem(), createElement: () => elem() },
    performance: { now: () => VNOW.v },
    requestAnimationFrame: () => 0, cancelAnimationFrame: () => {},
    Math, Object, Array, JSON, String, Number, parseFloat, parseInt,
    console: { log() {} },
  };
  sandbox.window = sandbox;
  vm.createContext(sandbox);
  vm.runInContext(fs.readFileSync(put, 'utf8'), sandbox, { filename: put });
  if (!sandbox.CompliorFaden) throw new Error('нет window.CompliorFaden');
  return { F: sandbox.CompliorFaden, VNOW };
}
function instancIzFadena(F, VNOW) {
  const sozdaj = (o) => {
    VNOW.v = 0;   // свежие часы на каждый инстанс — как экспортёр пакета (сцена = свежий прогон; knife-edge границ u>=1 не должен зависеть от порядка клеток)
    const el = { innerHTML: '', appendChild() {} };
    const inst = F.mount(el, Object.assign({ autoplay: false }, o || {}));
    return {
      set: (p) => inst.set(p),
      advanceTime: (dt) => { VNOW.v += dt; },
      tick: (dt) => inst.tick(dt),
      pose: () => inst.pose(),
      reset: (ms) => inst.reset(ms),
      options: () => inst.options(),
    };
  };
  sozdaj._chasy = VNOW;
  return sozdaj;
}
async function zagruzitiSubjekt(put) {
  const url = 'file://' + encodeURI(fs.realpathSync(put)).replace(/#/g, '%23').replace(/\?/g, '%3F');
  let mod = null, osibkaImporta = '';
  try { mod = await import(url); } catch (e) { osibkaImporta = String(e).slice(0, 200); }
  if (mod && mod.createInstance !== undefined && typeof mod.pose === 'function') {
    const TREBUEMYE = ['VERSION', 'STATES', 'EMOTIONS', 'TIERS', 'TIMING', 'CANON', 'LABEL', 'TONE', 'CHECK', 'pose', 'path', 'svg', 'colors', 'dotXY', 'morph', 'adaptive', 'voiceBars', 'tierFor', 'bezier', 'createInstance'];
    for (const imja of TREBUEMYE) if (mod[imja] === undefined) throw new Error('NET_EXPORTA: ' + imja);
    const api = {};
    for (const imja of TREBUEMYE) api[imja] = mod[imja];
    return { api, createInstance: mod.createInstance, vid: 'esm' };
  }
  try {
    const { F, VNOW } = zagaruziIIFE(put);
    return { api: F, createInstance: instancIzFadena(F, VNOW), vid: 'iife' };
  } catch (e2) {
    throw new Error('MODUL_NE_ZAGRUZHAET: import: ' + (osibkaImporta || 'нет ESM-экспорта') + ' | vm: ' + String(e2).slice(0, 160));
  }
}

const referenc = (() => { const { F, VNOW } = zagaruziIIFE(path.join(MODEL, 'faden-motion.js')); return { api: F, createInstance: instancIzFadena(F, VNOW) }; })();
// перечень состояний знака из ПИННОВАННОГО референса — единый источник для
// живой матрицы L (probe.py --live-component) и подпробы a03(д)
if (A.sostojanija) { console.log(JSON.stringify(referenc.api.STATES)); process.exit(0); }
let sub = null;
try { sub = await zagruzitiSubjekt(A.subject); } catch (e) { sub = { osibka: String(e) }; }

// ── тестовый источник состояний (I-ось; §4 бэкенд-разбора, слово 29.10 ~00:55):
//    референс — пиннованный model/istochnik-sostojanij.mjs (ожидания в памяти
//    ДО субъекта), субъект — файл продукта (repo) | эталон модели (model/stabs)
function urlModulja(put) {
  return 'file://' + encodeURI(fs.realpathSync(put)).replace(/#/g, '%23').replace(/\?/g, '%3F');
}
const referencIst = await import(urlModulja(path.join(MODEL, 'istochnik-sostojanij.mjs')));
let subIst = null;
try {
  if (!A.subjectIst || !fs.existsSync(A.subjectIst)) throw new Error('ISTOCHNIK_OTSVTSTVUET: ' + (A.subjectIst || '—'));
  const mod = await import(urlModulja(A.subjectIst));
  if (typeof mod.fadenInput !== 'function') throw new Error('NET_EXPORTA: fadenInput');
  subIst = mod;
} catch (e) { subIst = { __osibka: String(e).slice(0, 240) }; }

// ── сигналы сцены: порядок драйвера, сэмплы из input-tracks (по входу, по порядку)
function semplySceny(id, signaly) {
  const zapis = vhody.scenes[id];
  if (!zapis) return signaly.map(() => null);
  const poVhodu = {};
  for (const t of zapis.tracks) if (t.input === 'amplitude' || t.input === 'envelope') (poVhodu[t.input] = poVhodu[t.input] || []).push(t.samples);
  const indeksy = {};
  return signaly.map(vhod => {
    const n = (indeksy[vhod] = (indeksy[vhod] || 0));
    indeksy[vhod]++;
    const spisok = poVhodu[vhod] || [];
    return spisok[n] || null;
  });
}

// ── реплей сцены (единый для субъекта и референса) ─────────────────────────────
function replay(api, createInstance, id, rm) {
  const z = drajver.sceny[id];
  const rjady = pozy.scenes[id].rows;
  const semply = semplySceny(id, z.signaly);
  const perekl = new Map(z.tiry);
  const inst = createInstance(Object.assign({}, z.nachalnye, rm ? { reducedMotion: true } : {}));
  for (let p = 0; p < drajver.progrev_kadrov; p++) { inst.advanceTime(DT); inst.set({}); }
  let evi = 0;
  const kadry = [];
  for (let i = 0; i < rjady.length; i++) {
    const t = rjady[i][0];
    inst.advanceTime(DT);
    while (evi < z.sobytiya.length && z.sobytiya[evi].at <= t) {
      inst.set(rm ? Object.assign({}, z.sobytiya[evi].set, { reducedMotion: true }) : z.sobytiya[evi].set);
      evi++;
    }
    for (let s = 0; s < z.signaly.length; s++) {
      const vhod = z.signaly[s];
      const znach = rm ? (vhod === 'amplitude' ? 0.5 : 0.6) : (semply[s] ? semply[s][i] : 0);
      inst.set({ [vhod]: znach });
    }
    inst.set({});
    kadry.push(inst.pose());
    if (perekl.has(i)) inst.set({ size: perekl.get(i) });
  }
  return kadry;
}
const r3okrugl = v => Math.round(v * 1000) / 1000;
function stroka(p) { return KOLONKI.map(k => r3okrugl(p[k])); }

// ── вывод клеток ───────────────────────────────────────────────────────────────
const itogi = [];
function kletka(id, ok, prichina, detali) { itogi.push({ kletka: id, ok: !!ok, prichina: ok ? '' : prichina, detali: detali || {} }); }

const DOPUSK_MODELI = 0.002;   // границы round3 экспортёра (замер: 45 строк из 6680)
const EPS_SVOISTVO = 1e-12;    // свойства-инварианты внутри одного движка

function svodkaKletokS(id) {
  if (sub.osibka) return { ok: false, prichina: sub.osibka, detali: {} };
  const rjady = pozy.scenes[id].rows;
  const kadrySub = replay(sub.api, sub.createInstance, id, false);
  const predel = j => (A.mode === 'model' ? DOPUSK_MODELI : DOPUSK[KOLONKI[j]]);
  let pervyj = null, chislo = 0;
  for (let i = 0; i < rjady.length; i++) {
    const vych = stroka(kadrySub[i]);
    let ploho = false;
    for (let j = 0; j < 10; j++) {
      const d = Math.abs(vych[j] - rjady[i][j + 1]);
      if (d > predel(j)) {
        if (!pervyj) pervyj = { i, t: rjady[i][0], kol: KOLONKI[j], vych: vych[j], orakul: rjady[i][j + 1], d };
        ploho = true; break;
      }
    }
    if (kadrySub[i].tone !== rjady[i][11]) {
      if (!pervyj) pervyj = { i, t: rjady[i][0], kol: 'tone', vych: kadrySub[i].tone, orakul: rjady[i][11], d: 0 };
      ploho = true;
    }
    if (ploho) chislo++;
  }
  const kadryRef = replay(referenc.api, referenc.createInstance, id, false);
  const tochechnye = [];
  for (const [proc, ms] of drajver.sceny[id].tochki_proc) {
    let idx = -1, otkl = Infinity;
    for (let i = 0; i < rjady.length; i++) {
      const d = Math.abs(rjady[i][0] - ms);
      if (d < otkl) { otkl = d; idx = i; }
    }
    // момент «Кадры» не всегда лежит в сетке 60 fps (25 % окна даёт 662,5 мс):
    // берём ближайший кадр в пределах полуцелого кадра — так же семплировал лабораторный рендер
    if (idx < 0 || otkl > DT / 2 + 1e-9) { tochechnye.push({ proc, ms, ok: false, prichina: 'NET_KADRA_TOCHKI' }); continue; }
    const ps = sub.api.path(kadrySub[idx]), pr = referenc.api.path(kadryRef[idx]);
    tochechnye.push({ proc, ms, t: rjady[idx][0], ok: ps === pr, prichina: ps === pr ? '' : 'PATH_RASKHODITSYA' });
  }
  const detali = { kadrov: rjady.length, strok_s_oshibkoj: chislo, pervyj_narushitel: pervyj, tochki: tochechnye.map(x => ({ proc: x.proc, ms: x.ms, ok: x.ok })) };
  if (pervyj) return { ok: false, prichina: 'STROKA_' + pervyj.i + '_t=' + pervyj.t + '_' + pervyj.kol + ': субъект ' + pervyj.vych + ' != оракул ' + pervyj.orakul + ' (отклонение ' + pervyj.d.toFixed(4) + ')', detali };
  const p = tochechnye.find(x => !x.ok);
  if (p) return { ok: false, prichina: p.prichina + ' (точка ' + p.proc + '%, ' + p.ms + ' мс)', detali };
  return { ok: true, prichina: '', detali };
}

function setka(nazvanie, sluchai, zov) {
  if (sub.osibka) return { ok: false, prichina: sub.osibka };
  let pervyj = null;
  for (const sl of sluchai) {
    const a = zov(sub.api, sl), b = zov(referenc.api, sl);
    if (a === null || typeof a === 'undefined') { if (!pervyj) pervyj = { sl: JSON.stringify(sl), a: 'null', b: JSON.stringify(b) }; continue; }
    const sa = JSON.stringify(a), sb = JSON.stringify(b);
    if (sa !== sb && !pervyj) pervyj = { sl: JSON.stringify(sl), a: sa, b: sb };
  }
  return pervyj ? { ok: false, prichina: nazvanie + ': ' + pervyj.sl + ' → субъект ' + pervyj.a.slice(0, 120) + ' != референс ' + pervyj.b.slice(0, 120) } : { ok: true };
}

// ── S-ось ──────────────────────────────────────────────────────────────────────
for (const id of KLETKI_S) {
  const sv = svodkaKletokS(id);
  kletka('s-' + id.toLowerCase(), sv.ok, sv.prichina, sv.detali);
}

// ── P/D/T-оси ─────────────────────────────────────────────────────────────────
if (sub.osibka) {
  for (const id of [...KLETKI_P, ...KLETKI_D, ...KLETKI_T]) kletka(id, false, sub.osibka);
} else {
  {
    const sluchai = [];
    for (const st of referenc.api.STATES) for (const ti of Object.keys(referenc.api.TIERS)) for (const rm of [false, true])
      for (const t of [0, 100, 333, 1000, 5000]) for (const [amplitude, envelope] of [[0, 0], [0.9, 0.5]])
        sluchai.push({ state: st, o: { t, size: ti, reducedMotion: rm, amplitude, envelope } });
    const sv = setka('p01', sluchai, (api, s) => api.pose(s.state, s.o));
    kletka('p01-sostojanija-tiry', sv.ok, sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const sluchai = [];
    for (const em of Object.keys(referenc.api.EMOTIONS)) for (const st of ['idle', 'listening', 'understanding', 'speaking', 'done', 'uncertain'])
      for (const t of [0, 620, 3000]) sluchai.push({ state: st, o: { t, size: 'large', emotion: em, amplitude: 0.6, envelope: 0.4 } });
    const sv = setka('p02', sluchai, (api, s) => api.pose(s.state, s.o));
    kletka('p02-emocii', sv.ok, sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const sluchai = [];
    for (const st of ['idle', 'listening', 'working', 'done']) for (const ti of ['mini', 'large', 'tab']) for (const p of [0.25, 0.5, 1]) for (const rm of [false, true])
      sluchai.push({ state: st, o: { t: 400, size: ti, prime: p, reducedMotion: rm, amplitude: 0.8 } });
    const sv = setka('p03', sluchai, (api, s) => api.pose(s.state, s.o));
    const rost = sub.api.pose('listening', { t: 400, size: 'mini', prime: 1, amplitude: 0 }).dotScale > sub.api.pose('listening', { t: 400, size: 'mini', prime: 0, amplitude: 0 }).dotScale;
    kletka('p03-prime', sv.ok && rost, sv.ok ? (rost ? '' : 'SVOISTVO: dotScale не растёт по prime') : sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const sluchai = [];
    for (const st of referenc.api.STATES) sluchai.push({ state: st, o: { t: 2000, size: 'tab', amplitude: 0.9, envelope: 0.8 } });
    const sv = setka('p04', sluchai, (api, s) => api.pose(s.state, s.o));
    const mertvy = sub.api.pose('listening', { t: 2000, size: 'tab', amplitude: 0.9 }).dotScale === sub.api.pose('listening', { t: 2000, size: 'tab', amplitude: 0 }).dotScale;
    const statichen = sub.api.pose('idle', { t: 0, size: 'tab' }).w === sub.api.pose('idle', { t: 9000, size: 'tab' }).w;
    kletka('p04-tab', sv.ok && mertvy && statichen, sv.ok ? (mertvy ? (statichen ? '' : 'SVOISTVO: tab не статичен во времени (drift)') : 'SVOISTVO: tab применяет живой вход') : sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const pozySetki = [];
    for (const st of ['idle', 'listening', 'speaking', 'working', 'done', 'error']) for (const ti of ['mini', 'medium', 'large']) for (const rm of [false, true]) for (const p of [0, 0.7])
      pozySetki.push({ state: st, o: { t: 700, size: ti, reducedMotion: rm, amplitude: 0.6, envelope: 0.5, prime: p } });
    const sv = setka('p05-path', pozySetki, (api, s) => api.path(api.pose(s.state, s.o)));
    const svDot = setka('p05-dotXY', pozySetki, (api, s) => api.dotXY(api.pose(s.state, s.o)));
    const svSvg = setka('p05-svg', pozySetki.slice(0, 12), (api, s) => api.svg(api.pose(s.state, s.o), { theme: 'dark', px: 96 }));
    const cveta = [];
    for (const theme of ['dark', 'light', 'css']) for (const surface of ['ground', 'card', 'voice']) cveta.push({ theme, surface });
    const svCveta = setka('p05-colors', cveta, (api, s) => api.colors(s.theme, s.surface));
    const svod = [sv, svDot, svSvg, svCveta];
    const ok = svod.every(x => x.ok);
    kletka('p05-path-svg', ok, ok ? '' : svod.find(x => !x.ok).prichina, { pozy: pozySetki.length, cveta: cveta.length });
  }
  {
    const sluchai = [];
    const from = { x: 10, y: 20, s: 28 }, to = { x: 100, y: 300, s: 232 };
    for (const t of [0, 50, 112.5, 225, 337.5, 450, 900]) {
      sluchai.push({ from, to, t, o: {} }, { from, to, t, o: { delay: 100 } }, { from, to, t, o: { duration: 200 } },
        { from, to, t, o: { reducedMotion: true } }, { from, to, t, o: { docked: true } });
    }
    sluchai.push({ from: to, to: from, t: 225, o: {} });
    const sv = setka('p06', sluchai, (api, s) => api.morph(s.from, s.to, s.t, s.o));
    kletka('p06-morph', sv.ok, sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const sluchai = [
      { H: 844, T: 60, A: 0, C: 0 }, { H: 844, T: 60, A: 400, C: 0 }, { H: 844, T: 60, A: 664, C: 0 },
      { H: 844, T: 60, A: 600, C: 60 }, { H: 844, T: 60, A: 0, C: 700 }, { H: 852, T: 119, A: 284, C: 200 },
      { H: 844, T: 60, A: 0, C: 0, cap: 160 }, { H: 844, T: 60, A: 0, C: 0, cap: 96 }, { H: 844, T: 60, A: 0, C: 700, cap: 232 },
      { H: 844, T: 60, A: 0, C: 0, docked: true }, { H: 844, T: 60, A: 0, C: 0, fit: true }, { H: 844, T: 60, A: 300, C: 100, fit: true },
      { H: 844, T: 60, A: 663.9, C: 0 }, { H: 844, T: 60, A: 664.1, C: 0 }, {},
    ];
    const sv = setka('p07', sluchai, (api, s) => api.adaptive(s));
    kletka('p07-adaptive', sv.ok, sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const sluchai = [];
    for (const [id, zapis] of Object.entries(vhody.scenes)) {
      for (const b of zapis.tracks.filter(t => t.input === 'bars')) {
        const N = b.samples.length;
        for (const dolja of [0.15, 0.5, 0.9]) {
          const k = Math.floor(N * dolja);
          sluchai.push({ nazvanie: id + '@' + k, samples: b.samples.slice(0, k), o: { n: 28 } });
        }
      }
    }
    sluchai.push({ nazvanie: 'tishina', samples: new Array(200).fill(0), o: { n: 28 } });
    sluchai.push({ nazvanie: 'pik', samples: (() => { const s = new Array(40).fill(0); s[38] = 1; return s; })(), o: { n: 10 } });
    sluchai.push({ nazvanie: 'stepen', samples: new Array(40).fill(0.5), o: { n: 5, step: 4 } });
    sluchai.push({ nazvanie: 'n-menshe', samples: [0.9, 0.8, 0.7, 0.1, 0.2], o: {} });
    const sv = setka('p08', sluchai, (api, s) => api.voiceBars(s.samples, s.o));
    kletka('p08-voicebars', sv.ok, sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const sluchai = [];
    for (const s of [0, 28, 59, 59.9, 60, 96, 119, 120, 160, 199, 200, 232, 239, 240, 288, 500]) for (const docked of [false, true]) sluchai.push({ s, docked });
    const sv = setka('p09', sluchai, (api, x) => api.tierFor(x.s, x.docked));
    kletka('p09-tierfor', sv.ok, sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const sluchai = [];
    for (const cb of [[0.2, 0.7, 0.2, 1], [0.32, 0.72, 0, 1]]) {
      for (let x = -0.25; x <= 1.25001; x += 0.05) sluchai.push({ cb, x: Math.round(x * 100) / 100 });
    }
    const sv = setka('p10', sluchai, (api, s) => api.bezier(...s.cb)(s.x));
    kletka('p10-bezier', sv.ok, sv.prichina, { sluchaev: sluchai.length });
  }
  {
    const polja = ['VERSION', 'STATES', 'EMOTIONS', 'TIERS', 'TIMING', 'CANON', 'LABEL', 'TONE', 'CHECK'];
    let pervyj = null;
    for (const polje of polja) {
      const a = JSON.stringify(sub.api[polje]), b = JSON.stringify(referenc.api[polje]);
      if (a !== b && !pervyj) pervyj = { polje, a, b };
    }
    kletka('p11-katalog', !pervyj, pervyj ? 'KATALOG_' + pervyj.polje + ': субъект ' + pervyj.a.slice(0, 140) + ' != референс ' + pervyj.b.slice(0, 140) : '', { polej: polja.length });
  }
  {
    function mikroreplej(api, createInstance, skript) {
      const inst = createInstance({ state: 'idle', size: 'large', autoplay: false });
      inst.advanceTime(DT * 90); inst.set({});
      const kadry = [];
      for (let i = 0; i < skript.dlina; i++) {
        inst.advanceTime(DT);
        const pat = skript.kadr ? skript.kadr(i) : {};
        if (Object.keys(pat).length) inst.set(pat);
        inst.set({});
        kadry.push(inst.pose());
      }
      return kadry;
    }
    const skripty = {
      ataka: { dlina: 70, kadr: i => ({ state: i < 30 ? 'listening' : 'idle', amplitude: i < 30 ? 1 : 0 }) },
      env: { dlina: 70, kadr: i => ({ state: i < 30 ? 'speaking' : 'idle', envelope: i < 30 ? 1 : 0 }) },
      prime: { dlina: 40, kadr: i => ({ prime: i < 20 ? 1 : 0 }) },
      tab: { dlina: 40, kadr: i => ({ size: 'tab', state: 'listening', amplitude: 1 }) },
    };
    let pervyj = null;
    for (const [imja, sk] of Object.entries(skripty)) {
      const a = mikroreplej(sub.api, sub.createInstance, sk);
      const b = mikroreplej(referenc.api, referenc.createInstance, sk);
      for (const i of [0, 3, 10, 29, 33, 45, sk.dlina - 1].filter(x => x < sk.dlina)) {
        const sa = JSON.stringify(KOLONKI.map(k => a[i][k])), sb = JSON.stringify(KOLONKI.map(k => b[i][k]));
        if (sa !== sb && !pervyj) pervyj = { imja, i, a: sa, b: sb };
      }
    }
    kletka('p12-instance-sglazhivanie', !pervyj, pervyj ? 'INSTANS_' + pervyj.imja + '_kadr_' + pervyj.i + ': субъект ' + pervyj.a + ' != референс ' + pervyj.b : '', { skriptov: Object.keys(skripty).length });
  }
  {
    function restarter(api, createInstance) {
      const inst = createInstance({ state: 'idle', size: 'large' });
      inst.advanceTime(DT * 90); inst.set({});
      inst.advanceTime(DT * 200); inst.set({});
      inst.set({ state: 'needs_action' });
      const kadry = [];
      for (let i = 0; i < 24; i++) { inst.advanceTime(DT); inst.set({}); kadry.push(inst.pose()); }
      return kadry;
    }
    const a = restarter(sub.api, sub.createInstance), b = restarter(referenc.api, referenc.createInstance);
    let pervyj = null;
    for (let i = 0; i < a.length && !pervyj; i++) {
      const sa = JSON.stringify(KOLONKI.map(k => a[i][k])), sb = JSON.stringify(KOLONKI.map(k => b[i][k]));
      if (sa !== sb) pervyj = { i, a: sa, b: sb };
    }
    kletka('p13-instance-restart', !pervyj, pervyj ? 'RESTART_kadr_' + pervyj.i + ': субъект ' + pervyj.a + ' != референс ' + pervyj.b : '');
  }
  {
    // p14: СЕЯНЫЕ непиннованные входы — pose()/path() порта против референса
    // (блокер критика 1/2: мутация ВНЕ сетки 60 fps/кейфреймов/таблиц). Сэмплер
    // детерминирован (mulberry32; seed — параметр раннера, дефолт 145: судья
    // перезапускает с иным --seed, и «порт, знающий seed», ловится сменой seed).
    // Ожидание вычисляется РЕФЕРЕНСОМ ДО субъекта (в память; не таблица):
    // 240 случайных t (3 десятичных, [0,6000] мс) + плотное миллисекундное
    // окно 1000 точек ×3 состояния (позиция окна — от seed).
    function mulberry32(z) { return function () { z |= 0; z = z + 0x6D2B79F5 | 0; var x = Math.imul(z ^ z >>> 15, 1 | z); x = x + Math.imul(x ^ x >>> 7, 61 | x) ^ x; return ((x ^ x >>> 14) >>> 0) / 4294967296; }; }
    const chisloSeeda = Number(A.seed);
    const seed = Number.isFinite(chisloSeeda) ? (chisloSeeda | 0) : 145;
    const rnd = mulberry32(seed);
    const stany = referenc.api.STATES, tiry = Object.keys(referenc.api.TIERS), emociji = Object.keys(referenc.api.EMOTIONS);
    const sluchai = [];
    for (let i = 0; i < 240; i++) {
      const t = Math.round(rnd() * 6000000) / 1000;
      const o = { t, size: tiry[Math.floor(rnd() * tiry.length)] };
      if (rnd() < 0.4) o.emotion = emociji[Math.floor(rnd() * emociji.length)];
      if (rnd() < 0.25) o.prime = Math.round(rnd() * 100) / 100;
      o.amplitude = Math.round(rnd() * 100) / 100;
      o.envelope = Math.round(rnd() * 100) / 100;
      o.reducedMotion = rnd() < 0.2;
      sluchai.push({ state: stany[Math.floor(rnd() * stany.length)], o });
    }
    const rl = mulberry32(seed ^ 0x5bd1e995);
    const oknoNachalo = Math.round(rl() * 5000000) / 1000;
    for (const st of ['idle', 'listening', 'working']) for (let j = 0; j < 1000; j++)
      sluchai.push({ state: st, o: { t: Math.round((oknoNachalo + j) * 1000) / 1000, size: 'large', amplitude: 0.5, envelope: 0.4 } });
    const ozhidanija = sluchai.map(s => ({ p: JSON.stringify(referenc.api.pose(s.state, s.o)), d: referenc.api.path(referenc.api.pose(s.state, s.o)) }));
    let pervyj = null;
    for (let i = 0; i < sluchai.length && !pervyj; i++) {
      const p = sub.api.pose(sluchai[i].state, sluchai[i].o);
      if (JSON.stringify(p) !== ozhidanija[i].p) pervyj = { i, vid: 'pose', sl: JSON.stringify(sluchai[i]).slice(0, 140), a: JSON.stringify(p).slice(0, 120) };
      else if (sub.api.path(p) !== ozhidanija[i].d) pervyj = { i, vid: 'path', sl: JSON.stringify(sluchai[i]).slice(0, 140), a: '' };
    }
    kletka('p14-pose-sejanye-vhody', !pervyj, pervyj ? 'VNE_SETKI_' + pervyj.vid + ' (случай ' + pervyj.i + ' из ' + sluchai.length + '): ' + pervyj.sl + ' → субъект ' + (pervyj.a || 'path-строка') + ' != референс (ожидание вычислено референсом до субъекта)' : '', { sluchaev: sluchai.length, seed: String(seed), okno_ms: oknoNachalo });
  }
  {
    // p15: СЕЯНЫЕ инстанс-скрипты — пути инстанса ВНЕ драйвер-записи и сетки
    // DT (блокер критика 1/2: «и пути инстанса» на непиннованных временах).
    // 6 скриптов × 100 кадров: случайные dt (3 десятичных, ≠ DT), случайные
    // set-патчи; ожидание — референс ДО субъекта. Ловит мутации, отличные от
    // референса только при dt ∉ {0, DT} — таких входов нет ни в реплее, ни в
    // p12/p13/d-клетках.
    function mulberry32b(z) { return function () { z |= 0; z = z + 0x6D2B79F5 | 0; var x = Math.imul(z ^ z >>> 15, 1 | z); x = x + Math.imul(x ^ x >>> 7, 61 | x) ^ x; return ((x ^ x >>> 14) >>> 0) / 4294967296; }; }
    const chisloSeeda = Number(A.seed);
    const seed = Number.isFinite(chisloSeeda) ? (chisloSeeda | 0) : 145;
    const rs = mulberry32b(seed ^ 0x9e3779b9);
    const stany = referenc.api.STATES, tiry = Object.keys(referenc.api.TIERS), emociji = Object.keys(referenc.api.EMOTIONS);
    const skripty = [];
    for (let s = 0; s < 6; s++) {
      const nachalnye = { state: stany[Math.floor(rs() * stany.length)], size: tiry[Math.floor(rs() * tiry.length)], autoplay: false };
      if (rs() < 0.5) nachalnye.emotion = emociji[Math.floor(rs() * emociji.length)];
      const kadry = [];
      for (let f = 0; f < 100; f++) {
        const dt = Math.round((0.001 + rs() * 45) * 1000) / 1000;
        const pat = {};
        if (rs() < 0.06) pat.state = stany[Math.floor(rs() * stany.length)];
        if (rs() < 0.5) pat.amplitude = Math.round(rs() * 100) / 100;
        if (rs() < 0.4) pat.envelope = Math.round(rs() * 100) / 100;
        if (rs() < 0.15) pat.prime = Math.round(rs() * 100) / 100;
        if (rs() < 0.04) pat.size = tiry[Math.floor(rs() * tiry.length)];
        kadry.push({ dt, pat });
      }
      skripty.push({ nachalnye, kadry });
    }
    function progoni(createInstance, sk) {
      const inst = createInstance(Object.assign({}, sk.nachalnye));
      for (let p = 0; p < 90; p++) { inst.advanceTime(DT); inst.set({}); }
      const vydachi = [];
      for (const kadr of sk.kadry) { inst.advanceTime(kadr.dt); if (Object.keys(kadr.pat).length) inst.set(kadr.pat); inst.set({}); vydachi.push(JSON.stringify(inst.pose())); }
      return vydachi;
    }
    const ozhidanija = skripty.map(sk => progoni(referenc.createInstance, sk));
    let pervyj = null;
    for (let s = 0; s < skripty.length && !pervyj; s++) {
      const fakt = progoni(sub.createInstance, skripty[s]);
      for (let i = 0; i < fakt.length; i++) if (fakt[i] !== ozhidanija[s][i]) { pervyj = { s, i, a: fakt[i].slice(0, 140), b: ozhidanija[s][i].slice(0, 140) }; break; }
    }
    kletka('p15-instance-sejanye-vhody', !pervyj, pervyj ? 'INSTANS_VNE_SETKI: скрипт ' + pervyj.s + ' кадр ' + pervyj.i + ' (сеяный dt ∉ сетке DT): субъект ' + pervyj.a + ' != референс ' + pervyj.b : '', { skriptov: skripty.length, kadrov: skripty[0].kadry.length, seed: String(seed) });
  }
  {
    const sluchai = [];
    for (const st of referenc.api.STATES) for (const ti of ['mini', 'medium', 'large']) for (const t of [0, 700, 100000])
      sluchai.push({ state: st, o: { t, size: ti, reducedMotion: true, amplitude: 0.8, envelope: 0.7 } });
    const sv = setka('d01', sluchai, (api, s) => api.pose(s.state, s.o));
    let statichny = true;
    for (const st of referenc.api.STATES) for (const ti of ['mini', 'medium', 'large']) {
      const a = sub.api.pose(st, { t: 700, size: ti, reducedMotion: true, amplitude: 0.8, envelope: 0.7 });
      const b = sub.api.pose(st, { t: 100000, size: ti, reducedMotion: true, amplitude: 0.8, envelope: 0.7 });
      for (const k of KOLONKI) if (Math.abs(a[k] - b[k]) > EPS_SVOISTVO) statichny = false;
    }
    kletka('d01-ud-pozy', sv.ok && statichny, sv.ok ? (statichny ? '' : 'SVOISTVO: поза УД зависит от времени') : sv.prichina, { sluchaev: sluchai.length });
  }
  {
    function mikroUd(api, createInstance) {
      const inst = createInstance({ state: 'listening', size: 'large', reducedMotion: true });
      inst.advanceTime(DT); inst.set({});
      const kadry = [];
      for (let i = 0; i < 120; i++) {
        inst.advanceTime(DT);
        inst.set({ amplitude: 0.5, envelope: 0.6 });
        inst.set({});
        kadry.push(inst.pose());
      }
      inst.set({ state: 'working' });
      kadry.push(inst.pose());
      inst.advanceTime(DT); inst.set({});
      kadry.push(inst.pose());
      inst.set({ state: 'done' });
      kadry.push(inst.pose());
      return kadry;
    }
    const a = mikroUd(sub.api, sub.createInstance), b = mikroUd(referenc.api, referenc.createInstance);
    let pervyj = null;
    for (let i = 0; i < a.length && !pervyj; i++) {
      const sa = JSON.stringify(KOLONKI.map(k => a[i][k])), sb = JSON.stringify(KOLONKI.map(k => b[i][k]));
      if (sa !== sb) pervyj = { i, a: sa, b: sb };
    }
    // свойство УД: структурные столбцы (не зависят от входа) не движутся ВООБЩЕ
    // после схода (кадры 60–119); входные (dotA/dotRho/dotScale) догоняют константу
    // с затухающей покадровой дельтой (≤ 1e-8 к кадру 110) — хвост атаки, не движение
    const STRUKTURNYE = ['R', 'w', 'g', 'sx', 'bead', 'check', 'dotOpacity', 'stroke'];
    const statichen = a.slice(60, 120).every((p, i) => STRUKTURNYE.every(k => p[k] === a[60][k]))
      && [110, 111, 112, 113, 114, 115, 116, 117].every(i => ['dotA', 'dotRho', 'dotScale'].every(k => Math.abs(a[i + 1][k] - a[i][k]) <= 1e-8));
    const doneSrazu = a[a.length - 1].check === 1 && a[a.length - 1].dotOpacity === 0;
    const beadFiksen = Math.abs(a[121].bead - 0.35) < 1e-9;
    kletka('d02-ud-instance', !pervyj && statichen && doneSrazu && beadFiksen,
      pervyj ? 'UD_kadr_' + pervyj.i + ': субъект ' + pervyj.a + ' != референс ' + pervyj.b : (!statichen ? 'SVOISTVO: УД-инстанс движется на константных входах' : (!doneSrazu ? 'SVOISTVO: done не сразу финальная форма' : 'SVOISTVO: bead не 0.35 при УД')),
      { kadrov: a.length });
  }
  {
    let pervyj = null, scenaPervaya = '';
    for (const id of KLETKI_S) {
      const a = replay(sub.api, sub.createInstance, id, true);
      const b = replay(referenc.api, referenc.createInstance, id, true);
      for (let i = 0; i < a.length && !pervyj; i++) {
        const sa = JSON.stringify(KOLONKI.map(k => r3okrugl(a[i][k]))), sb = JSON.stringify(KOLONKI.map(k => r3okrugl(b[i][k])));
        if (sa !== sb) { pervyj = { i, a: sa, b: sb }; scenaPervaya = id; }
      }
    }
    kletka('d03-ud-sceny', !pervyj, pervyj ? 'UD_SCENA_' + scenaPervaya + '_kadr_' + pervyj.i + ': субъект ' + pervyj.a + ' != референс ' + pervyj.b : '', { scen: KLETKI_S.length, orakul: 'референс-реплей (строк пакета для УД нет — суд порт==референс)' });
  }
  {
    let prichina = '';
    let toks = null;
    try {
      const url = 'file://' + encodeURI(fs.realpathSync(A.subjectTokens)).replace(/#/g, '%23').replace(/\?/g, '%3F');
      const mod = await import(url);
      if (!mod.MOTION_TOKENS) prichina = 'NET_EXPORTA: MOTION_TOKENS';
      else toks = mod.MOTION_TOKENS;
    } catch (e) { prichina = 'TOKENY_NE_ZAGRUZHAJUTSJA: ' + String(e).slice(0, 160); }
    if (toks && !prichina) {
      const imena = Object.keys(toks), imenaSpeka = Object.keys(TOKENA_SPEKA);
      const lishnie = imena.filter(x => !(x in TOKENA_SPEKA));
      const otsutstv = imenaSpeka.filter(x => !(x in toks));
      const inye = imenaSpeka.filter(x => x in toks && toks[x] !== TOKENA_SPEKA[x]);
      if (lishnie.length) prichina = 'LISHNIJ_TOKEN: ' + lishnie.join(',');
      else if (otsutstv.length) prichina = 'NET_TOKENA: ' + otsutstv.join(',');
      else if (inye.length) prichina = 'ZNACHENIE_TOKENA: ' + inye.map(x => x + '=' + toks[x] + ' (спек ' + TOKENA_SPEKA[x] + ')').join('; ');
    }
    kletka('t01-tokemy', !prichina, prichina, { tokienov_v_speke: Object.keys(TOKENA_SPEKA).length });
  }
}

// ── I-ось: тестовый источник состояний (§4 бэкенд-разбора; слово 29.10 ~00:55) ─
// Факты СИНТЕТИЧЕСКИЕ (G11: пилот без живого бэкенда); интерфейс факта — тот же,
// что даст бэкенд: session/turn/generation, mission/operation (когда есть),
// причина (error), следующий участник (next). Ожидания вычисляет ПИННОВАННЫЙ
// эталон referencIst В ПАМЯТИ ДО субъекта (правило 8), сравнение — JSON-строк.
{
  const KORR_1 = { session: 'sess-145-synth-1', turn: 3, generation: 'gen-145-synth-7', mission: 'mission-synth-145', operation: 'op-synth-145-2', next: 'user' };
  const KORR_2 = { session: 'sess-145-synth-2', turn: 9, generation: 'gen-145-synth-11', next: 'agent' }; // до Mission — mission/operation нет (G02)
  const kl = (state) => ({ side: 'client', state, ...KORR_1 });
  const sr = (state, korr) => ({ side: 'server', state, ...(korr || KORR_1) });
  const er = (side, reason) => ({ side, state: 'error', ...(reason ? { reason } : {}), ...KORR_1 });
  const FAKTY_KONF = [
    kl('idle'), kl('listening'), kl('speaking'),
    sr('understanding'), sr('working'), sr('waiting'), sr('needs_action'), sr('ready'), sr('done'), sr('uncertain'),
    sr('working', KORR_2), // инвариантность к корреляциям: то же состояние, иные ids
    er('client', 'microphone'), er('client', 'transport'), er('client', 'processing'), er('client', 'business'),
    er('server', 'microphone'), er('server', 'transport'), er('server', 'processing'), er('server', 'business'),
  ];
  const FAKTY_OTKAZ = [
    kl('thinking'), sr('thinking'), kl('READY'), sr('listened'),
    ...['understanding', 'working', 'waiting', 'needs_action', 'ready', 'done', 'uncertain'].map(s => kl(s)),
    ...['idle', 'listening', 'speaking'].map(s => sr(s)),
    { side: 'backend', state: 'working', ...KORR_1 }, { side: '', state: 'idle', ...KORR_1 },
    { side: 'client', state: 'error', ...KORR_1 }, { side: 'server', state: 'error', ...KORR_1 },
    { side: 'client', state: 'error', reason: 'timeout', ...KORR_1 }, { side: 'server', state: 'error', reason: 'network', ...KORR_1 },
    null, 'idle',
  ];
  const klon = (f) => JSON.parse(JSON.stringify(f === undefined ? null : f));
  const bezKopii = (f) => JSON.stringify(f);
  // i01 — ЧИСТАЯ функция состояние→вход движка: конформные факты, чистота,
  // инвариантность к корреляциям, патч ведёт движок; алфавиты сторон покрывают
  // ровно STATES канона (единый источник — движок 1.3)
  {
    let prichina = '';
    if (subIst.__osibka) prichina = subIst.__osibka;
    else if (sub.osibka) prichina = 'DVIZHOK_NEDOSTUPEN: ' + sub.osibka;
    else {
      const POLJA = ['FADEN_FACT_SIDES', 'FADEN_CLIENT_STATES', 'FADEN_SERVER_STATES', 'FADEN_ERROR_REASONS'];
      for (const polje of POLJA) {
        if (bezKopii(subIst[polje]) !== bezKopii(referencIst[polje])) { prichina = 'ALFAVIT_' + polje + ': субъект ' + bezKopii(subIst[polje]) + ' != эталон ' + bezKopii(referencIst[polje]); break; }
      }
      if (!prichina) {
        const obiedinenie = [...referencIst.FADEN_CLIENT_STATES, ...referencIst.FADEN_SERVER_STATES, 'error'].sort();
        const kanon = [...referenc.api.STATES].sort();
        if (obiedinenie.length !== kanon.length || obiedinenie.some((s, i) => s !== kanon[i]))
          prichina = 'ALFAVIT_NE_POKRYVAET_STATES: ' + obiedinenie.join(',') + ' != ' + kanon.join(',');
      }
      if (!prichina) {
        const ozhidanija = FAKTY_KONF.map(f => bezKopii(referencIst.fadenInput(klon(f))));
        for (let i = 0; i < FAKTY_KONF.length && !prichina; i++) {
          const fakt = klon(FAKTY_KONF[i]);
          const a1 = bezKopii(subIst.fadenInput(klon(FAKTY_KONF[i])));
          const a2 = bezKopii(subIst.fadenInput(klon(FAKTY_KONF[i])));
          if (a1 !== ozhidanija[i]) prichina = 'VYHOD_' + i + ': субъект ' + a1.slice(0, 140) + ' != эталон ' + ozhidanija[i].slice(0, 140);
          else if (a1 !== a2) prichina = 'NE_CHISTAJA: повторный вызов даёт иной выход (факт ' + i + ')';
          else if (bezKopii(fakt) !== bezKopii(FAKTY_KONF[i])) prichina = 'MUTIRUET_FAKT: факт ' + i + ' изменён вызовом';
        }
      }
      if (!prichina) {
        const pat = (fact) => subIst.fadenInput(klon(fact));
        // два ОДИНАКОВЫХ прогона по одному инстансу (общие часы VNOW делают
        // два живых инстанса несимметричными; паттерн p12/p13): прогон A —
        // set(патч), прогон B — set({state}); кадры обязаны совпасть
        const progon = (vvedenie) => {
          const inst = sub.createInstance({ state: 'idle', size: 'large' });
          for (let k = 0; k < 30; k++) { inst.advanceTime(DT); inst.set({}); }
          vvedenie(inst);
          const kadry = [];
          for (let k = 0; k < 30; k++) { inst.advanceTime(DT); inst.set({}); kadry.push(bezKopii(KOLONKI.map(c => inst.pose()[c]))); }
          return kadry;
        };
        for (const st of referenc.api.STATES) {
          const faktK = FAKTY_KONF.find(f => f && f.state === st);
          const r = pat(faktK);
          if (!r.ok) { prichina = 'VYHOD_NE_OK: ' + st + ' → ' + bezKopii(r).slice(0, 120); break; }
          if (bezKopii(r.patch) !== bezKopii({ state: st })) { prichina = 'PATCH_NE_TOLKO_SOSTOJANIE: ' + st + ' → ' + bezKopii(r.patch); break; }
          const poz1 = progon(inst => inst.set(r.patch));
          const poz2 = progon(inst => inst.set({ state: st }));
          if (poz1.some((p, k) => p !== poz2[k])) { prichina = 'PATCH_NE_VODIT_DVIZHOK: ' + st + ' — поза после set(патч) != позы после set({state})'; break; }
        }
      }
    }
    kletka('i01-istochnik-funkcija', !prichina, prichina, { konformnyh_faktov: FAKTY_KONF.length, chistota: 'повторный вызов + неизменность факта', korelljacii: 'инвариантны (два набора корреляций)', dvizhok: '11 состояний set(патч) == set({state})' });
  }
  // i02 — «выдуманная фаза» — поимённый ОТКАЗ: неизвестное имя, состояние не той
  // стороны (параметризованно ×10), неизвестная сторона, error без причины,
  // причина вне набора, нефакт; выход субъекта == эталону ПОБАЙТОВО (JSON)
  {
    let prichina = '';
    if (subIst.__osibka) prichina = subIst.__osibka;
    else {
      const ozhidanija = FAKTY_OTKAZ.map(f => bezKopii(referencIst.fadenInput(klon(f))));
      for (let i = 0; i < FAKTY_OTKAZ.length && !prichina; i++) {
        const fakt = subIst.fadenInput(klon(FAKTY_OTKAZ[i]));
        const vid = bezKopii(fakt);
        if (vid !== ozhidanija[i]) prichina = 'VYDUMANNAA_PROSHLA_' + i + ': ' + bezKopii(FAKTY_OTKAZ[i]).slice(0, 120) + ' → субъект ' + vid.slice(0, 120) + ' != эталон ' + ozhidanija[i].slice(0, 120);
        else if (fakt && fakt.ok !== false) prichina = 'OTKAZ_NE_IMENOVAN_' + i + ': отказ обязан быть {ok:false, refusal:VYDUMANNAA_FAZA:*}';
        else if (fakt && !String(fakt.refusal || '').startsWith('VYDUMANNAA_FAZA:')) prichina = 'OTKAZ_NE_IMENOVAN_' + i + ': ' + String(fakt.refusal).slice(0, 120);
      }
    }
    kletka('i02-istochnik-vydumannaja-faza', !prichina, prichina, { otkazov: FAKTY_OTKAZ.length, semejstvo: 'не-та-сторона ×10 (клиент↔сервер)', vidy: 'neizvestnoe_sostojanie/nevernaja_storona/neizvestnaja_storona/net_prichiny/prichina_vne_nabora/nefakt' });
  }
}

// ── A-ось (арбитраж Astra A.1–A.5) ────────────────────────────────────────────
if (A.mode === 'repo') {
  const ozidaemyj = src.piny['drajver.json'];
  const fakt = A.subjectDriver ? crypto.createHash('sha256').update(fs.readFileSync(A.subjectDriver)).digest('hex') : null;
  kletka('a01-drajver-zapis', fakt === ozidaemyj, fakt ? 'DRAJVER_IZMENEN: sha256 ' + fakt + ' != пин ' + ozidaemyj : 'DRAJVER_OTSVTSTVUET: ' + (A.subjectDriver || '—'), {});
  const REPO = fs.realpathSync(A.repoRoot);
  const fajly = ['mobile/src/ui/faden/FadenSign.tsx', 'mobile/src/ui/faden/index.ts', 'mobile/src/ui/faden/__tests__/faden-motion.test.ts', 'mobile/src/ui/faden/__tests__/faden-sign.test.tsx'];
  const netu = fajly.filter(f => !fs.existsSync(path.join(REPO, f)));
  kletka('a02-fajly-komponenta', netu.length === 0, netu.length ? 'NET_FAJLA: ' + netu.join(',') : '', { ispolnenie: 'CI продукта (jest, job quality) + режим L; клетка — наличие' });

  const KANON = fs.realpathSync(A.produktCanon || path.resolve(MODEL, '..', 'produkt'));
  const hesh = (bajty) => crypto.createHash('sha256').update(bajty).digest('hex');

  // a05 (A.3): ЦЕЛОСТНОСТЬ обязательного знакового теста — побайтовое
  // равенство продуктового файла пиннованному каноническому артефакту батареи
  // (сам канон пиннен в source.json:.piny — порча проверяющей стороны ловится
  // ДО клеток, rc 2 ORACLE_TAMPERED). Клетка НЕ исполняет TSX: живое исполнение
  // — jest-expo (job quality) и режим L; подмена файла мёртвыми ассертами/
  // недостижимым блоком/чем угодно иным отклоняется одним общим свойством.
  {
    const putTesta = path.join(REPO, 'mobile/src/ui/faden/__tests__/faden-sign.test.tsx');
    const putKanona = path.join(KANON, 'mobile/src/ui/faden/__tests__/faden-sign.test.tsx');
    const detali = { chto: 'целостность обязательного файла (байты == канону); исполнение — jest-expo (quality) + --live-component, не node-шим' };
    if (!fs.existsSync(putTesta)) {
      kletka('a05-jest-znak-celesnost', false, 'NET_FAJLA_TESTA: ' + putTesta, detali);
    } else {
      const bajty = fs.readFileSync(putTesta);
      const kanonBajty = fs.readFileSync(putKanona);
      kletka('a05-jest-znak-celesnost', bajty.equals(kanonBajty),
        bajty.equals(kanonBajty) ? '' : 'TEST_IZMENEN: sha256 ' + hesh(bajty) + ' != канон ' + hesh(kanonBajty) + ' — обязательный знаковый тест ≠ пиннованному артефакту батареи', detali);
    }
  }

  // a03 (A.1/A.2): ПОЛНЫЙ канонический движковый тест — побайтовое равенство
  // обязательного файла канону + ДЕЙСТВИТЕЛЬНОЕ node-исполнение (шим) против
  // порта субъекта + детерминированные подпробы: (а) честный прогон зелён;
  // (б) несуществующий FADEN_ORAKUL_DIR → отказ чтения; (в) порча КАЖДОГО из
  // трёх оракулов одним байт-изменением с сохранением JSON-синтаксиса → отказ
  // соответствующего sha-пина; (г) мутанты m1/m2; (д) параметризованное
  // семейство R+2 по ВСЕМ 11 состояниям (достижимость посещением драйвер-
  // записи доказана ДО прогонов). Мутант, не закраснивший ЧИСЛЕННОЕ сравнение
  // (ZELEN_POD_MUTANTOM), и мутант, не загрузившийся (PROBA_NEISPRAVNA), —
  // отказы пробы, не успех. Regex-эвристика expect(<литерал>) удалена:
  // значимость несёт сам исполняемый канон, а не распознавание текста.
  {
    const putTesta = path.join(REPO, 'mobile/src/ui/faden/__tests__/faden-motion.test.ts');
    const putKanona = path.join(KANON, 'mobile/src/ui/faden/__tests__/faden-motion.test.ts');
    if (!fs.existsSync(putTesta)) {
      kletka('a03-jest-dvizhok-kanon', false, 'NET_FAJLA_TESTA: ' + putTesta, {});
    } else {
      const bajty = fs.readFileSync(putTesta);
      const kanonBajty = fs.readFileSync(putKanona);
      if (!bajty.equals(kanonBajty)) {
        kletka('a03-jest-dvizhok-kanon', false, 'TEST_IZMENEN: sha256 ' + hesh(bajty) + ' != канон ' + hesh(kanonBajty) + ' — обязательный движковый тест (реплей 21 сцена/6680 строк) ≠ пиннованному артефакту батареи', { test: putTesta, port: A.subject, kanon: putKanona });
      } else {
        const cwdMobile = path.join(REPO, 'mobile');
        const ORAKUL = path.join(MODEL, 'oracle');
        const portUrl = 'file://' + encodeURI(fs.realpathSync(A.subject)).replace(/#/g, '%23').replace(/\?/g, '%3F');
        const IMENA_PORTA = ['VERSION', 'STATES', 'EMOTIONS', 'TIERS', 'TIMING', 'CANON', 'LABEL', 'TONE', 'CHECK', 'pose', 'path', 'svg', 'colors', 'dotXY', 'morph', 'adaptive', 'voiceBars', 'tierFor', 'bezier', 'CompliorFaden'];
        const teloObertki = (teloMutanta) => {
          const stroki = [`// мутант подпробы батареи 145 (клетка a03): обёртка над портом субъекта`, `import * as M from '${portUrl}';`, teloMutanta];
          for (const n of IMENA_PORTA) stroki.push(`export const ${n} = M.${n};`);
          return stroki.join('\n') + '\n';
        };
        const zapusk = (testFajl, mutaciya, orakulDir) => {
          let vrem = null, cel = testFajl;
          if (mutaciya) {
            vrem = fs.mkdtempSync(path.join(os.tmpdir(), 'faden-a03-'));
            fs.writeFileSync(path.join(vrem, 'faden-motion.ts'), teloObertki(mutaciya));
            fs.mkdirSync(path.join(vrem, '__tests__'), { recursive: true });
            fs.copyFileSync(testFajl, path.join(vrem, '__tests__/faden-motion.test.ts'));
            cel = path.join(vrem, '__tests__/faden-motion.test.ts');
          }
          const r = spawnSync(process.execPath, [path.join(MODEL, 'jest_shim.mjs'), cel], {
            cwd: cwdMobile, env: Object.assign({}, process.env, { FADEN_ORAKUL_DIR: orakulDir }),
            encoding: 'utf8', timeout: 120000,
          });
          let svod = null;
          const strokiSvoda = (r.stdout || '').split('\n').filter(l => l.trim().startsWith('{'));
          if (strokiSvoda.length) { try { svod = JSON.parse(strokiSvoda[strokiSvoda.length - 1]); } catch { } }
          if (vrem) fs.rmSync(vrem, { recursive: true, force: true });
          return { rc: r.status, svod, stderr: (r.stderr || '').trim().slice(0, 200) };
        };
        const podproby = [];
        const dobavit = (imja, ok, prichina) => { podproby.push({ imja, ok, prichina: ok ? '' : prichina }); };
        // (а) честный порт + пиннованные данные → зелёный прогон шима
        const chestnyj = zapusk(putTesta, null, ORAKUL);
        if (chestnyj.rc !== 0 || !chestnyj.svod || chestnyj.svod.upalo > 0 || chestnyj.svod.testov < 1) {
          dobavit('chestnyj-progon', false, 'JEST_DVIZHOK_NE_ZELEN: ' + ((chestnyj.svod && chestnyj.svod.pervaya_oshibka) || chestnyj.stderr || 'rc=' + chestnyj.rc));
        } else dobavit('chestnyj-progon', true);
        // (б) несуществующий каталог оракулов → ожидаемый отказ чтения
        const netKataloga = path.join(os.tmpdir(), 'faden-a03-net-orakula-' + process.pid + '-' + Date.now());
        const bezKataloga = zapusk(putTesta, null, netKataloga);
        const sled = String((bezKataloga.svod && bezKataloga.svod.pervaya_oshibka) || '') + ' ' + (bezKataloga.stderr || '');
        if (bezKataloga.rc === 0 || !bezKataloga.svod || bezKataloga.svod.upalo === 0 || !/ENOENT|EACCES|ENOTDIR|EISDIR/.test(sled)) {
          dobavit('net-kataloga-orakulov', false, 'ORAKUL_NE_OTKLONYAET: без каталога оракулов тест не отказался чтением (' + sled.slice(0, 120) + ')');
        } else dobavit('net-kataloga-orakulov', true);
        // (в) порча каждого из трёх оракулов: +1 к первому числовому значению,
        // JSON-синтаксис сохранён → отказ обязан именовать пин (sha), не парсинг
        const isportitPervoeChislo = (put) => {
          const tekst = fs.readFileSync(put, 'utf8');
          const m = tekst.match(/("[^"]*"\s*:\s*)(-?\d+)(\.\d+)?/);
          if (!m) return false;
          const novoje = tekst.slice(0, m.index + m[1].length) + String(Number(m[2]) + 1) + (m[3] || '') + tekst.slice(m.index + m[0].length);
          JSON.parse(novoje);
          fs.writeFileSync(put, novoje);
          return true;
        };
        for (const imja of ['faden-poses-gespraech.json', 'input-tracks.json', 'motion-spec-gespraech.json']) {
          const vrem = fs.mkdtempSync(path.join(os.tmpdir(), 'faden-a03-oracle-'));
          fs.cpSync(path.join(MODEL, 'oracle'), vrem, { recursive: true });
          let prichina = '';
          try {
            if (!isportitPervoeChislo(path.join(vrem, imja))) prichina = 'MUTACIJA_NE_PRIMENILAS: нет числового значения в ' + imja;
            else {
              const pin = src.piny['oracle/' + imja];
              const z = zapusk(putTesta, null, vrem);
              if (z.rc === 0 || !z.svod || z.svod.upalo === 0 || z.svod.testov === 0) prichina = 'SHA_NE_OTKLONYAET: порча ' + imja + ' не краснит тест ассертом';
              else if (!String(z.svod.pervaya_oshibka).includes(pin)) prichina = 'SHA_NE_IMENOVAN: отказ при порче ' + imja + ' не называет пин: ' + String(z.svod.pervaya_oshibka).slice(0, 120);
            }
          } catch (e) { prichina = 'PROBA_NEISPRAVNA: ' + imja + ': ' + String(e).slice(0, 120); }
          dobavit('porcha-orakula:' + imja, !prichina, prichina);
          fs.rmSync(vrem, { recursive: true, force: true });
        }
        // (г) мутанты m1/m2 — set-перехват createInstance (любой порт И-1)
        const MUTANTY = [
          ['m1-usilenie-amplitudy', 'export const createInstance = (o = {}) => {\n  const inst = M.createInstance(o);\n  const origSet = inst.set.bind(inst);\n  inst.set = (patch) => { if (patch && typeof patch.amplitude === \'number\' && patch.amplitude > 0) patch = Object.assign({}, patch, { amplitude: 1 }); return origSet(patch); };\n  return inst;\n};'],
          ['m2-zamena-waiting', 'export const createInstance = (o = {}) => {\n  const inst = M.createInstance(o);\n  const origSet = inst.set.bind(inst);\n  inst.set = (patch) => { if (patch && patch.state === \'waiting\') patch = Object.assign({}, patch, { state: \'idle\' }); return origSet(patch); };\n  return inst;\n};'],
        ];
        for (const [imja, telo] of MUTANTY) {
          const z = zapusk(putTesta, telo, ORAKUL);
          if (!z.svod || z.svod.testov === 0) dobavit('mutant:' + imja, false, 'PROBA_NEISPRAVNA: мутант не загрузился: ' + ((z.svod && z.svod.pervaya_oshibka) || z.stderr));
          else if (z.rc === 0 || z.svod.upalo === 0) dobavit('mutant:' + imja, false, 'ZELEN_POD_MUTANTOM: ' + imja + ' — канонический реплей не чувствует мутант порта');
          else dobavit('mutant:' + imja, true);
        }
        // (д) параметризованное семейство: у createInstance().pose() только в
        // выбранном текущем состоянии R+2 (выше допуска 1) — ОДИН механизм на
        // все 11 состояний; достижимость посещением драйвер-записи доказана
        const poseshcheny = new Set();
        for (const z of Object.values(drajver.sceny)) {
          poseshcheny.add(z.nachalnye.state);
          for (const e of z.sobytiya) if (e.set && e.set.state) poseshcheny.add(e.set.state);
        }
        const nedostizhimy = referenc.api.STATES.filter((s) => !poseshcheny.has(s));
        if (nedostizhimy.length) {
          dobavit('semejstvo-R+2', false, 'MUTANT_NEDOSTIZHIM: состояния не посещаются драйвер-записью: ' + nedostizhimy.join(','));
        } else {
          for (const sostojanie of referenc.api.STATES) {
            const telo = 'export const createInstance = (o = {}) => {\n' +
              '  const inst = M.createInstance(o);\n' +
              '  let tekushchee = (o && o.state) || \'idle\';\n' +
              '  const origSet = inst.set.bind(inst);\n' +
              '  inst.set = (patch) => { if (patch && patch.state !== undefined) tekushchee = patch.state; return origSet(patch); };\n' +
              '  const origPose = inst.pose.bind(inst);\n' +
              '  inst.pose = () => { const p = origPose(); return tekushchee === ' + JSON.stringify(sostojanie) + ' ? Object.assign({}, p, { R: p.R + 2 }) : p; };\n' +
              '  return inst;\n' +
              '};';
            const z = zapusk(putTesta, telo, ORAKUL);
            if (!z.svod || z.svod.testov === 0) dobavit('R+2:' + sostojanie, false, 'PROBA_NEISPRAVNA: мутант состояния ' + sostojanie + ' не загрузился: ' + ((z.svod && z.svod.pervaya_oshibka) || z.stderr));
            else if (z.rc === 0 || z.svod.upalo === 0) dobavit('R+2:' + sostojanie, false, 'ZELEN_POD_MUTANTOM: R+2 в состоянии ' + sostojanie + ' не краснит численное сравнение реплея (допуск R=1, мутация 2)');
            else dobavit('R+2:' + sostojanie, true);
          }
        }
        const pervyjSboj = podproby.find(p => !p.ok);
        kletka('a03-jest-dvizhok-kanon', !pervyjSboj, pervyjSboj ? pervyjSboj.imja + ': ' + pervyjSboj.prichina : '',
          { test: putTesta, port: fs.realpathSync(A.subject), kanon: putKanona, testov: chestnyj.svod ? chestnyj.svod.testov : null, podproby: podproby.map(p => p.imja + (p.ok ? '' : ' ✗')), ispolnenie: 'node-шим model/jest_shim.mjs против порта субъекта; живой рантайм — jest-expo (quality) + --live-component' });
      }
    }
  }
} else {
  kletka('a01-drajver-zapis', true, '', { zamechanie: 'субъект = модель; пин проверен каноном ДО клеток' });
  kletka('a02-fajly-komponenta', true, '', { zamechanie: 'субъект = модель; компонент — продукт, судится CI продукта и режимом L' });
  kletka('a03-jest-dvizhok-kanon', true, '', { zamechanie: 'субъект = модель; канон+исполнение+подпробы судятся в --repo (и стаб-матрицей produkt-формы)' });
  kletka('a05-jest-znak-celesnost', true, '', { zamechanie: 'субъект = модель; целостность знакового теста судится в --repo' });
}

for (const z of itogi) console.log(JSON.stringify(z));
