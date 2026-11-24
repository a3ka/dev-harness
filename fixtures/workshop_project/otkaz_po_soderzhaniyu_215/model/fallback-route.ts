// Executable reference 215; quota path remains the established 129 mechanism.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
type Model = { provider: string; id: string };
type Turn = { role?: string; stopReason?: string; errorStatus?: number; errorMessage?: string; provider?: string; model?: string };
type Entry = { id?: string; type?: string; modelRole?: string; retryFallback?: { chain?: string[] } };
type Event = { message?: Turn; messages?: Turn[]; willContinue?: boolean; modelRole?: string; patterns?: string[] };
type Context = { sessionManager: { getEntries(): Entry[] }; models: { current(): Model | undefined; resolve(selector: string): Model | undefined } };
type API = { on(name: string, handler: (event: Event, ctx: Context) => unknown): void; setModel(model: Model): Promise<boolean>; appendEntry(kind: string, data: object): void; sendUserMessage(text: string, options: { deliverAs: string }): void };
type Roster = { models?: Record<string, string>; tiers?: Record<string, { fallback?: string; autoFallback?: boolean }> };
const CFG = join(dirname(fileURLToPath(import.meta.url)), '../../config/agent_models.json');
const MARKERS = ['This content was flagged for possible cybersecurity risk', 'cyber_policy', 'content_filter'];
const KEY = Symbol.for('dev-harness.fallback-route.129');
const global = globalThis as unknown as Record<symbol, Map<string, number> | undefined>;
const exhausted: Map<string, number> = global[KEY] ?? (global[KEY] = new Map());
function roster(): Roster {
  try { return JSON.parse(readFileSync(CFG, 'utf8')) as Roster; } catch { return {}; }
}
function fallback(role: string): string | undefined {
  const cfg = roster();
  const tier = cfg.tiers?.[role.replace(/^@/, '')];
  if (tier?.autoFallback !== true || typeof tier.fallback !== 'string') return;
  return cfg.models?.[tier.fallback.replace(/^@/, '')];
}
export default function register(pi: API): void {
  pi.on('message_end', (event) => {
    const m = event.message;
    if (m?.role !== 'assistant' || m.stopReason !== 'error' || m.errorStatus !== 429) return;
    const wait = /retry-after-ms=(\d+)/.exec(String(m.errorMessage ?? ''));
    if (wait && Number(wait[1]) > 300000 && typeof m.provider === 'string')
      exhausted.set(m.provider, Date.now() + Number(wait[1]));
  });
  pi.on('before_subagent_spawn', (event) => {
    if (typeof event.modelRole !== 'string' || !Array.isArray(event.patterns)) return;
    const primary = event.patterns[0];
    if (typeof primary !== 'string') return;
    const until = exhausted.get(primary.split('/')[0]);
    const target = fallback(event.modelRole);
    if (until && until > Date.now() && target && target.split('/')[0] !== primary.split('/')[0])
      return { model: [target, ...event.patterns], note: `fallback-route: quota → ${target}` };
  });
  // Per-session state: a content judgement must not poison another task/provider.
  const seen = new Set<string>();
  pi.on('message_end', async (event, ctx) => {
    const m = event.message;
    if (m?.role !== 'assistant' || m.stopReason !== 'error' || typeof m.errorMessage !== 'string') return;
    if (!MARKERS.some((marker) => marker.includes(' ') ? m.errorMessage!.includes(marker) : m.errorMessage!.split(/[^A-Za-z0-9_]+/).includes(marker))) return;
    const init = [...ctx.sessionManager.getEntries()].reverse().find((x) => x.type === 'session_init');
    const chain = init?.retryFallback?.chain;
    if (!Array.isArray(chain) || typeof init?.modelRole !== 'string') return;
    const target = fallback(init.modelRole);
    if (!target || !chain.includes(target)) return;
    const current = `${m.provider}/${m.model}`;
    seen.add(current);
    if (seen.has(target) || target.split('/')[0] === m.provider) {
      pi.appendEntry('fallback-route-215', { reason: 'CONTENT_FALLBACK_EXHAUSTED', from: current });
      return;
    }
    const live = ctx.models.current();
    if (`${live?.provider}/${live?.id}` !== current) return;
    seen.add(target);
    const model = ctx.models.resolve(target);
    if (!model || !await pi.setModel(model)) return;
    const modelChangeId = [...ctx.sessionManager.getEntries()].reverse().find((entry) => entry.type === 'model_change')?.id;
    pi.appendEntry('fallback-route-215', { reason: 'CONTENT_FALLBACK_SWITCH', from: current, target, modelChangeId });
    pi.sendUserMessage('Continue the original task on the configured fallback. Do not change its requirements.', { deliverAs: 'followUp' });
  });
}
