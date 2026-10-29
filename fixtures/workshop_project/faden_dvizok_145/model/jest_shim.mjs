// jest_shim.mjs — минимальный jest-совместимый шим батареи 145 (клетка a03).
// Исполняет ОБЯЗАТЕЛЬНЫЙ продуктовый движковый тест faden-motion.test.ts
// ЧИСТЫМ node (type-stripping, без jest-рантайма/npm/сети). По арбитражу
// Astra (A.1) значимость несёт сам канонический файл (побайтовое равенство
// пиннованному артефакту проверяет клетка a03 ДО запуска), а его ДЕЙСТВИТЕЛЬНОЕ
// исполнение здесь: честный порт — зелёный; мутанты подпроб (m1/m2, R+2 по 11
// состояниям), порча оракулов, отсутствие каталога — красные. Знаковый
// .tsx-тест шим НЕ исполняет (его целостность — клетка a05; живое исполнение —
// jest-expo CI качества и режим --live-component).
//
// Вызов: node jest_shim.mjs <testFile>   (cwd = mobile продукта/формы;
// FADEN_ORAKUL_DIR задаёт каталог оракулов — раннер клетки a03).
// Выход (stdout, последняя строка): JSON {"proshlo":N,"upalo":M,"testov":K,
// "pervaya_oshibka":"…"}; rc 0 — все тесты зелёны и тестов ≥ 1; rc 1 —
// падение/нет тестов/ошибка импорта; rc 2 — тестовый файл не найден.
// Классификация итогов подпроб a03: testov===0 — импорт/структура не грузятся
// (PROBA_NEISPRAVNA, не «убитый мутант»); upalo>0 && testov>0 — предметный
// отказ ассертом.
// Покрытие API (граница формы И-8; неизвестный матчер — TypeError с именем):
// describe/it/test/beforeEach/beforeAll, expect().{toBe,toEqual,toBeCloseTo,
// toContain,toMatch,toThrow,toBeNull,toBeUndefined,toBeDefined,toBeGreaterThan,
// toBeLessThan,toHaveLength} + .not, jest.fn; jest.mock/requireActual —
// запрещены движковому тесту (знаковый .tsx-тест шим не исполняет — это CI
// продукта, батарея судит его структурно клеткой a05).
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const fajl = process.argv[2];
if (!fajl || !fs.existsSync(fajl)) {
  console.error('NET_FAJLA_TESTA: ' + fajl);
  process.exit(2);
}

// ── сбор тестов ───────────────────────────────────────────────────────────────
const ochered = [];
const kontekst = [];
const BEFORE_EACH = [];
const BEFORE_ALL = [];

globalThis.describe = (imja, fn) => { kontekst.push(imja); try { fn(); } finally { kontekst.pop(); } };
globalThis.it = (imja, fn) => ochered.push({ imja: [...kontekst, imja].join(' › '), fn });
globalThis.test = globalThis.it;
globalThis.beforeEach = (fn) => BEFORE_EACH.push(fn);
globalThis.beforeAll = (fn) => BEFORE_ALL.push(fn);

globalThis.jest = {
  fn(impl) {
    const f = (...a) => { f.mock.calls.push(a); return impl ? impl(...a) : undefined; };
    f.mock = { calls: [] };
    f.mockReturnValue = (v) => { impl = () => v; return f; };
    f.mockResolvedValue = (v) => { impl = () => Promise.resolve(v); return f; };
    f.mockImplementation = (g) => { impl = g; return f; };
    f.mockReset = () => { f.mock.calls.length = 0; impl = undefined; return f; };
    return f;
  },
  mock() { throw new Error('SHIM_ZAPRESHCHEN: jest.mock недопустим в движковом тесте И-8'); },
  requireActual() { throw new Error('SHIM_ZAPRESHCHEN: jest.requireActual недопустим в движковом тесте И-8'); },
};

// ── expect ────────────────────────────────────────────────────────────────────
function glubokoRavno(a, b) {
  if (a === b) return true;
  if (typeof a !== typeof b || a === null || b === null || typeof a !== 'object') return false;
  if (Array.isArray(a) !== Array.isArray(b)) return false;
  const ka = Object.keys(a), kb = Object.keys(b);
  if (ka.length !== kb.length) return false;
  return ka.every(k => glubokoRavno(a[k], b[k]));
}
const MATCHERY = {
  toBe: (f, o) => f === o,
  toEqual: (f, o) => glubokoRavno(f, o),
  toBeCloseTo: (f, o, tochnost = 2) => typeof f === 'number' && typeof o === 'number' && Math.abs(f - o) < Math.pow(10, -tochnost) / 2,
  toContain: (f, o) => (typeof f === 'string' ? f.includes(o) : Array.isArray(f) && f.some(x => glubokoRavno(x, o))),
  toMatch: (f, o) => typeof f === 'string' && (typeof o === 'string' ? f.includes(o) : o instanceof RegExp && o.test(f)),
  toThrow: (f, o) => {
    if (typeof f !== 'function') return false;
    try { f(); return false; } catch (e) {
      return o == null ? true : (typeof o === 'string' ? String(e).includes(o) : o instanceof RegExp && o.test(String(e)));
    }
  },
  toBeNull: f => f === null,
  toBeUndefined: f => f === undefined,
  toBeDefined: f => f !== undefined,
  toBeGreaterThan: (f, o) => typeof f === 'number' && f > o,
  toBeLessThan: (f, o) => typeof f === 'number' && f < o,
  toHaveLength: (f, o) => f != null && f.length === o,
};
function sobratMatcher(fakt, inversiya) {
  const nabor = {};
  for (const [imenovanie, sudja] of Object.entries(MATCHERY)) {
    nabor[imenovanie] = (ozhidanie, ...dop) => {
      const polozhitelno = sudja(fakt, ozhidanie, ...dop);
      if (inversiya ? polozhitelno : !polozhitelno) {
        throw new Error(imenovanie + (inversiya ? ' (.not)' : '') + '(' + JSON.stringify(ozhidanie) + ') на факте ' + JSON.stringify(fakt));
      }
    };
  }
  return nabor;
}
globalThis.expect = (fakt) => {
  const nabor = sobratMatcher(fakt, false);
  nabor.not = sobratMatcher(fakt, true);
  return nabor;
};

// ── исполнение ────────────────────────────────────────────────────────────────
let proshlo = 0, upalo = 0;
let pervayaOshibka = '';
try {
  await import(pathToFileURL(path.resolve(fajl)).href);
  for (const h of BEFORE_ALL) await h();
  for (const t of ochered) {
    try {
      for (const h of BEFORE_EACH) await h();
      await t.fn();
      proshlo++;
    } catch (e) {
      upalo++;
      if (!pervayaOshibka) pervayaOshibka = t.imja + ': ' + String(e && e.message ? e.message : e).slice(0, 300);
    }
  }
} catch (e) {
  upalo++;
  pervayaOshibka = pervayaOshibka || ('IMPORT/OBRABOTKA: ' + String(e && e.message ? e.message : e).slice(0, 300));
}
console.log(JSON.stringify({ proshlo, upalo, testov: ochered.length, pervaya_oshibka: pervayaOshibka }));
process.exit(upalo === 0 && ochered.length > 0 ? 0 : 1);
