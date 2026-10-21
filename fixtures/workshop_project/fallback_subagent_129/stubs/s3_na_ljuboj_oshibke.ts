// ОБМАННЫЙ СТАБ s3 (контракт 129): подмена на ЛЮБОЙ ошибке — провайдер
// считается исчерпанным по любому ходу с ошибкой (включая 400 валидации).
// Различим от честной реализации в клетке c4 (400 соседа на примарии).
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

type Tier = { fallback?: unknown; autoFallback?: unknown };
const CFG = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'config', 'agent_models.json');
const STORE = Symbol.for('dev-harness.fallback-route.129.s3');
const g = globalThis as unknown as Record<symbol, Map<string, number> | undefined>;
const bad: Map<string, number> = g[STORE] ?? (g[STORE] = new Map<string, number>());

export default function register(pi: unknown): void {
  const p = pi as { on: (n: string, h: (ev: unknown) => unknown) => unknown };
  p.on('message_end', (ev: unknown) => {
    const m = (ev as { message?: Record<string, unknown> }).message;
    if (m?.role === 'assistant' && m.stopReason === 'error' && typeof m.provider === 'string') bad.set(m.provider, Date.now() + 3_600_000);
    return undefined;
  });
  p.on('before_subagent_spawn', (ev: unknown) => {
    const e = ev as { modelRole?: string; patterns?: string[] };
    const primary = e.patterns?.[0];
    if (!primary || !e.modelRole || (bad.get(primary.split('/')[0]) ?? 0) <= Date.now()) return undefined;
    const am = JSON.parse(readFileSync(CFG, 'utf8')) as { models: Record<string, string>; tiers: Record<string, Tier> };
    const t = am.tiers[e.modelRole];
    if (!t || t.autoFallback !== true || typeof t.fallback !== 'string') return undefined;
    return { model: [am.models[t.fallback.slice(1)], ...(e.patterns ?? [])] };
  });
}
