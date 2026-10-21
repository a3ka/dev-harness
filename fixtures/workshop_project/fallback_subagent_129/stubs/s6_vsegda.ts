// ОБМАННЫЙ СТАБ s6 (контракт 129): подмена ВСЕГДА — ребёнок стартует на
// запасной модели тира и при здоровом примарии. Различим в клетке c3.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

type Tier = { fallback?: unknown; autoFallback?: unknown };
const CFG = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'config', 'agent_models.json');

export default function register(pi: unknown): void {
  const p = pi as { on: (n: string, h: (ev: unknown) => unknown) => unknown };
  p.on('before_subagent_spawn', (ev: unknown) => {
    const e = ev as { modelRole?: string; patterns?: string[] };
    if (!e.modelRole) return undefined;
    const am = JSON.parse(readFileSync(CFG, 'utf8')) as { models: Record<string, string>; tiers: Record<string, Tier> };
    const t = am.tiers[e.modelRole];
    if (!t || t.autoFallback !== true || typeof t.fallback !== 'string') return undefined;
    return { model: [am.models[t.fallback.slice(1)], ...(e.patterns ?? [])] };
  });
}
