// ЧЕСТНАЯ МОДЕЛЬ 128 (wait-guard) — образец для батареи red_wait_guard_128.sh,
// НЕ предмет. Предмет — .omp/extensions/wait-guard.ts (зона implementer);
// грамматика решений — contracts/128-wait-guard.md §Грамматика (единый источник),
// модель несёт её побайтово. Стабы батареи — подстановки якорей этого файла
// (поле stubs в source.json), поэтому якорные строки здесь уникальны.
import { execFile } from 'node:child_process';
import { basename, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

// Табло УСТАНОВКИ — по расположению расширения (прецедент spawn-guard.ts), не по cwd.
const HERE = dirname(fileURLToPath(import.meta.url));
const TABLO = join(HERE, '..', '..', 'ops', 'server', 'user', 'orch-tablo');
const DEFAULT_MIN = 8;
const TIMEOUT_MS = 20000;
const TOP_SESSION = /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{3}Z_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.jsonl$/;
const STOIT = /^ *СТОИТ ([0-9]+) мин /;
const ITOG = /^итог: стоит без хода — [0-9]+/;
const WARN_TABLO = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: табло недоступно';
const WARN_SESSION = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: сессия не опознана — wait не судим';
const WARN_BROKEN = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: внутренняя ошибка — wait не судим';

type Block = { block: true; reason: string };
type Context = { additionalContext: string };
type Tablo = { ok: true; stdout: string } | { ok: false; why: string };

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

function warnTablo(why: string): Context {
  return { additionalContext: `${WARN_TABLO} — ${why}; wait не судим` };
}

// Порог: WAIT_GUARD_MIN ∈ ^[1-9][0-9]{0,3}$, иначе (нет/пусто/не разобран) — 8.
function threshold(): number {
  const v = process.env.WAIT_GUARD_MIN;
  if (typeof v === 'string' && /^[1-9][0-9]{0,3}$/.test(v)) return Number(v);
  return DEFAULT_MIN;
}

// Ведущая сессия = файл сессии верхнего уровня (<время>Z_<uuid>.jsonl); субагент —
// <id>.jsonl в каталоге артефактов родителя (omp://tools/task.md); иначе — не опознана.
function sessionKind(ctx: unknown): 'orch' | 'sub' | 'unknown' {
  if (!isObject(ctx)) return 'unknown';
  const sm = ctx.sessionManager;
  if (!isObject(sm) || typeof sm.getSessionFile !== 'function') return 'unknown';
  const file: unknown = sm.getSessionFile();
  if (typeof file !== 'string' || !file.endsWith('.jsonl')) return 'unknown';
  return TOP_SESSION.test(basename(file)) ? 'orch' : 'sub';
}

function runTablo(): Promise<Tablo> {
  const { promise, resolve } = Promise.withResolvers<Tablo>();
  execFile('python3', [TABLO], { timeout: TIMEOUT_MS, maxBuffer: 4 * 1024 * 1024 }, (err, stdout) => {
    if (err) {
      resolve({ ok: false, why: err.killed ? `таймаут ${TIMEOUT_MS} мс` : `rc ${String(err.code)}` });
      return;
    }
    resolve({ ok: true, stdout: String(stdout) });
  });
  return promise;
}

export function judgeTablo(stdout: string, n: number): Block | Context | undefined {
  const lines = stdout.split('\n');
  const body = lines.filter((l) => l.trim() !== '');
  if (body.length === 0 || !ITOG.test(body[body.length - 1])) return warnTablo('вывод без строки итога');
  const stale: string[] = [];
  for (const line of lines) {
    const m = STOIT.exec(line);
    if (m !== null && Number(m[1]) >= n) stale.push(line.replace(/^ +/, ''));
  }
  if (stale.length === 0) return undefined;
  const header = `ОТКАЗ wait-guard: на табло строк СТОИТ ≥ ${n} мин — ${stale.length}; сделай ход по каждой до wait`;
  return { block: true, reason: [header, ...stale].join('\n') };
}

export default function register(pi: unknown): void {
  if (!isObject(pi) || typeof pi.on !== 'function') return;
  const on = pi.on as (name: string, h: (call: unknown, ctx: unknown) => unknown) => unknown;
  on.call(pi, 'tool_call', async (call: unknown, ctx: unknown) => {
    try {
      if (!isObject(call) || call.toolName !== 'wait') return undefined;
      const kind = sessionKind(ctx);
      if (kind === 'sub') return undefined;
      if (kind === 'unknown') return { additionalContext: WARN_SESSION };
      const t = await runTablo();
      if (!t.ok) return warnTablo(t.why);
      return judgeTablo(t.stdout, threshold());
    } catch {
      // Исключение tool_call-обработчика omp превращает в блок (fail-closed) —
      // страж простоя обязан быть fail-open с именованным предупреждением.
      return { additionalContext: WARN_BROKEN };
    }
  });
}
