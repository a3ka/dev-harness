// ОБМАННЫЙ СТАБ s5 (контракт 129): «подмена» на ТУ ЖЕ модель — ребёнок
// снова стартует на исчерпанном примарии. Различим в клетке c2.
const STORE = Symbol.for('dev-harness.fallback-route.129.s5');
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
    return { model: [primary, ...(e.patterns ?? [])], note: 'route: same model' };
  });
}
