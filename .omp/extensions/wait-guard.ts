// Страж простоя — контракт 128: вызов инструмента `wait` ВЕДУЩЕЙ сессии оркестратора
// получает отказ, пока на табло установки есть строки СТОИТ не моложе порога;
// перечень строк едет в reason отказа, чтобы ход был виден сразу.
//
// ПИН ТАБЛО — РАСПОЛОЖЕНИЕ расширения (<каталог расширения>/../.. — прецедент
// spawn-guard.ts, §Существующее п.2), не cwd сессии и не переменная окружения:
// у сессии может быть свой ops/server/user/orch-tablo (клетка c20-ustanovka), и
// читать его — значит судить чужой мир.
//
// ЛИЧНОСТЬ вызова — форма имени файла сессии (контракт 037 §Существующее п.3):
// верхний уровень `<время>Z_<uuid>.jsonl` — ведущая сессия; иной basename с
// суффиксом `.jsonl` — субагент (omp://tools/task.md), его wait не судим.
// ctx.hasUI и переменные окружения — не различение: hasUI — свойство режима
// запуска (RPC/print), env наследуется субагентами.
//
// FAIL-OPEN по табло, но не молча: недоступное/упавшее/пустое/оборванное табло и
// неопознанный ctx — проход с ИМЕНОВАННЫМ предупреждением в additionalContext
// (прецедент fail-open gate-draft.ts). Исключение обработчика tool_call omp
// превращает в блок (omp://extensions.md), поэтому ловец — именованная строка.
import { execFile } from 'node:child_process';
import { basename, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const TABLO = join(HERE, '..', '..', 'ops', 'server', 'user', 'orch-tablo');
const DEFAULT_MIN = 8;
const TIMEOUT_MS = 20000;
const MAX_BUFFER = 8 * 1024 * 1024;
// Грамматика порога: WAIT_GUARD_MIN читается на КАЖДЫЙ вызов, вне грамматики — 8
// (ручка владельца без правки кода; «≥» — паритет с правилом сторожа).
const MIN_ENV = /^[1-9][0-9]{0,3}$/;
const TOP_SESSION = /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{3}Z_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.jsonl$/;
// Судимая строка — предметная и PR-форма (`СТОИТ <N> мин …`); «СТОИТ ПОТОК»
// несёт не минуты у строки, а простой потока (Frontier А) — не судится.
const STOIT_ROW = /^ *СТОИТ ([0-9]+) мин /;
// Пригодность табло: последняя непустая строка — итог с цифрой. Хвост «→ сделай
// следующий шаг…» печатается тем же print — судим по началу строки.
const ITOG_ROW = /^итог: стоит без хода — [0-9]+/;

const WARN_TABLO = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: табло недоступно';
const WARN_SESSION = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: сессия не опознана';
const WARN_BROKEN = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: внутренняя ошибка — wait не судим';

type Block = { block: true; reason: string };
type Note = { additionalContext: string };
type Verdict = Block | Note | undefined;
type Tablo = { usable: true; stdout: string } | { usable: false; why: string };
type Caller = 'lead' | 'subagent' | 'unknown';

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

function warn(prefix: string, why: string): Note {
  return { additionalContext: `${prefix} — ${why}; wait не судим` };
}

// Личность вызова по имени файла сессии: верхний уровень — ведущая, иной
// basename с .jsonl — субагент (молчаливый проход, табло не запускается), всё
// прочее (нет sessionManager/getSessionFile, значение не строка или не .jsonl) —
// не опознано: проход с предупреждением, тоже без запуска табло.
function callerOf(ctx: unknown): Caller {
  if (!isObject(ctx)) return 'unknown';
  const sm = ctx.sessionManager;
  if (!isObject(sm) || typeof sm.getSessionFile !== 'function') return 'unknown';
  const file: unknown = sm.getSessionFile();
  if (typeof file !== 'string' || !file.endsWith('.jsonl')) return 'unknown';
  return TOP_SESSION.test(basename(file)) ? 'lead' : 'subagent';
}

// Табло заново на КАЖДЫЙ судимый wait: без кэша и без паузы после отказа —
// после хода по строке следующий wait судится по свежему табло.
function readTablo(): Promise<Tablo> {
  const { promise, resolve } = Promise.withResolvers<Tablo>();
  execFile('python3', [TABLO], { timeout: TIMEOUT_MS, maxBuffer: MAX_BUFFER }, (err, stdout) => {
    if (err) {
      resolve({ usable: false, why: err.killed ? `таймаут ${TIMEOUT_MS} мс` : `rc ${String(err.code)}` });
      return;
    }
    resolve({ usable: true, stdout: String(stdout) });
  });
  return promise;
}

// Пригодное табло → перечень устаревших строк и заголовок §Грамматика;
// непригодное (пусто, нет итога) → проход с предупреждением, его вывод не судим.
export function judgeTablo(stdout: string, min: number): Verdict {
  const rows = stdout.split('\n').filter((l) => l.trim() !== '');
  if (rows.length === 0) return warn(WARN_TABLO, 'пустой вывод');
  if (!ITOG_ROW.test(rows[rows.length - 1])) return warn(WARN_TABLO, 'вывод без строки итога');
  const stale: string[] = [];
  for (const row of stdout.split('\n')) {
    const m = STOIT_ROW.exec(row);
    if (m !== null && Number(m[1]) >= min) stale.push(row.replace(/^ +/, ''));
  }
  if (stale.length === 0) return undefined;
  const header = `ОТКАЗ wait-guard: на табло строк СТОИТ ≥ ${min} мин — ${stale.length}; сделай ход по каждой до wait`;
  return { block: true, reason: [header, ...stale].join('\n') };
}

// Один вызов wait ведущей сессии. Не бросает никогда.
async function judgeWait(call: unknown, ctx: unknown): Promise<Verdict> {
  try {
    if (!isObject(call) || call.toolName !== 'wait') return undefined;
    const caller = callerOf(ctx);
    if (caller === 'subagent') return undefined;
    if (caller === 'unknown') return warn(WARN_SESSION, 'нет файла сессии оркестратора');
    const t = await readTablo();
    if (!t.usable) return warn(WARN_TABLO, t.why);
    // Порог читается на этом вызове: ручка владельца без перезапуска.
    const envMin = process.env.WAIT_GUARD_MIN;
    const min = typeof envMin === 'string' && MIN_ENV.test(envMin) ? Number(envMin) : DEFAULT_MIN;
    return judgeTablo(t.stdout, min);
  } catch {
    return { additionalContext: WARN_BROKEN };
  }
}

type PiLike = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };

export default function register(pi: unknown): void {
  if (!isObject(pi)) return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', (call: unknown, ctx: unknown) => judgeWait(call, ctx));
}