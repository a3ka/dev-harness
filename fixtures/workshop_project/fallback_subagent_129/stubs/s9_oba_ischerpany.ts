// ОБМАННЫЙ СТАБ s9 (контракт 129): обход критика круга 1 дословно — честная
// модель, но подмена только при записанном исчерпании ОБОИХ провайдеров
// (примария и запасной модели). Различим от честной реализации в клетке c6:
// у соседа запасная модель получила 400 (cooldown без исчерпания) — стаб не
// подменяет, ребёнок умирает на 1310 примария. В c2 (запасная тоже 429) зелен.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

type Tier = { model?: unknown; fallback?: unknown; autoFallback?: unknown };
type AgentModels = { models?: Record<string, unknown>; tiers?: Record<string, Tier> };

const CFG = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'config', 'agent_models.json');
const MAX_DELAY_MS = 300_000;
const STORE = Symbol.for('dev-harness.fallback-route.129.s9');
const g = globalThis as unknown as Record<symbol, Map<string, number> | undefined>;
const exhaustedUntil: Map<string, number> = g[STORE] ?? (g[STORE] = new Map<string, number>());

function fallbackOf(tierName: string): string | undefined {
  const am = JSON.parse(readFileSync(CFG, 'utf8')) as AgentModels;
  const tier = am.tiers?.[tierName];
  if (!tier || tier.autoFallback !== true || typeof tier.fallback !== 'string') return undefined;
  if (!tier.fallback.startsWith('@')) return undefined;
  const sel = am.models?.[tier.fallback.slice(1)];
  return typeof sel === 'string' ? sel : undefined;
}

export default function register(pi: unknown): void {
  const p = pi as { on?: (name: string, h: (ev: unknown, ctx: unknown) => unknown) => unknown };
  if (typeof p.on !== 'function') return;
  p.on('message_end', (ev: unknown) => {
    const m = (ev as { message?: Record<string, unknown> }).message;
    if (!m || m.role !== 'assistant' || m.stopReason !== 'error' || m.errorStatus !== 429) return undefined;
    const wait = /retry-after-ms=(\d+)/.exec(String(m.errorMessage ?? ''));
    if (!wait || Number(wait[1]) <= MAX_DELAY_MS || typeof m.provider !== 'string') return undefined;
    exhaustedUntil.set(m.provider, Date.now() + Number(wait[1]));
    return undefined;
  });
  p.on('before_subagent_spawn', (ev: unknown) => {
    const e = ev as { modelRole?: unknown; patterns?: unknown };
    if (typeof e.modelRole !== 'string' || !Array.isArray(e.patterns) || typeof e.patterns[0] !== 'string') return undefined;
    const primary: string = e.patterns[0];
    const until = exhaustedUntil.get(primary.split('/')[0]);
    if (until === undefined || until <= Date.now()) return undefined;
    const fb = fallbackOf(e.modelRole);
    if (fb === undefined || fb.split('/')[0] === primary.split('/')[0]) return undefined;
    if (!((exhaustedUntil.get(fb.split('/')[0]) ?? 0) > Date.now())) return undefined; // дефект
    return { model: [fb, ...e.patterns] };
  });
}
