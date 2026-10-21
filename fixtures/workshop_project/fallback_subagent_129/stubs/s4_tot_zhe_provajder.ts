// ОБМАННЫЙ СТАБ s4 (контракт 129): подмена на модель ТОГО ЖЕ провайдера, что
// исчерпанный примарий (другое семейство того же аккаунта). 1310 — стена
// аккаунта: различим от честной реализации в клетке c2.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const CFG = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'config', 'agent_models.json');
const STORE = Symbol.for('dev-harness.fallback-route.129.s4');
const g = globalThis as unknown as Record<symbol, Map<string, number> | undefined>;
const ex: Map<string, number> = g[STORE] ?? (g[STORE] = new Map<string, number>());

export default function register(pi: unknown): void {
  const p = pi as { on: (n: string, h: (ev: unknown) => unknown) => unknown };
  p.on('message_end', (ev: unknown) => {
    const m = (ev as { message?: Record<string, unknown> }).message;
    const wait = /retry-after-ms=(\d+)/.exec(String(m?.errorMessage ?? ''));
    if (m?.errorStatus === 429 && wait && Number(wait[1]) > 300_000 && typeof m.provider === 'string') ex.set(m.provider, Date.now() + Number(wait[1]));
    return undefined;
  });
  p.on('before_subagent_spawn', (ev: unknown) => {
    const e = ev as { patterns?: string[] };
    const primary = e.patterns?.[0];
    if (!primary || (ex.get(primary.split('/')[0]) ?? 0) <= Date.now()) return undefined;
    const am = JSON.parse(readFileSync(CFG, 'utf8')) as { models: Record<string, string> };
    const prov = primary.split('/')[0];
    const twin = Object.values(am.models).find((s) => s.split('/')[0] === prov && s !== primary);
    return twin ? { model: [twin, ...(e.patterns ?? [])] } : undefined;
  });
}
