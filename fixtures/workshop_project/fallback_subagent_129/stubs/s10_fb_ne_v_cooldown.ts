// ОБМАННЫЙ СТАБ s10 (контракт 129): противоположное s9 — подмена только если
// запасная модель НЕ в cooldown (в процессе не было хода с ошибкой на ней).
// Различим от честной реализации в c2 и c6: у соседа запасная модель получила
// отказ (429 в c2, 400 в c6) — стаб не подменяет, ребёнок умирает на 1310.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

type Tier = { model?: unknown; fallback?: unknown; autoFallback?: unknown };
type AgentModels = { models?: Record<string, unknown>; tiers?: Record<string, Tier> };
type State = { exhaustedUntil: Map<string, number>; failed: Set<string> };

const CFG = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'config', 'agent_models.json');
const MAX_DELAY_MS = 300_000;
const STORE = Symbol.for('dev-harness.fallback-route.129.s10');
const g = globalThis as unknown as Record<symbol, State | undefined>;
const st: State = g[STORE] ?? (g[STORE] = { exhaustedUntil: new Map(), failed: new Set() });

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
    if (!m || m.role !== 'assistant' || m.stopReason !== 'error' || typeof m.provider !== 'string') return undefined;
    st.failed.add(`${m.provider}/${String(m.model)}`); // любой сбой селектора = его cooldown
    if (m.errorStatus !== 429) return undefined;
    const wait = /retry-after-ms=(\d+)/.exec(String(m.errorMessage ?? ''));
    if (!wait || Number(wait[1]) <= MAX_DELAY_MS) return undefined;
    st.exhaustedUntil.set(m.provider, Date.now() + Number(wait[1]));
    return undefined;
  });
  p.on('before_subagent_spawn', (ev: unknown) => {
    const e = ev as { modelRole?: unknown; patterns?: unknown };
    if (typeof e.modelRole !== 'string' || !Array.isArray(e.patterns) || typeof e.patterns[0] !== 'string') return undefined;
    const primary: string = e.patterns[0];
    const until = st.exhaustedUntil.get(primary.split('/')[0]);
    if (until === undefined || until <= Date.now()) return undefined;
    const fb = fallbackOf(e.modelRole);
    if (fb === undefined || fb.split('/')[0] === primary.split('/')[0]) return undefined;
    if (st.failed.has(fb)) return undefined; // дефект: cooldown запасной отменяет подмену
    return { model: [fb, ...e.patterns] };
  });
}
