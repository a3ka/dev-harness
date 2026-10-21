// ОБМАННЫЙ СТАБ s8 (контракт 129): честная модель, но хранилище исчерпания —
// состояние МОДУЛЯ, не процесса. Изолированный ребёнок грузит свою копию файла
// расширения (свой экземпляр модуля): его запись об исчерпании родитель не видит.
// Различим в клетке c2 при живой топологии (task.isolation + isolated: true).
// Честная модель контракта 129 (fallback-subagent) — ЭТАЛОН ДЛЯ БАТАРЕИ, не
// продукт: доказывает выполнимость приёмки. Реализация исполнителя живёт в
// .omp/extensions/fallback-route.ts и судится той же батареей.
//
// Замер (стенд omp 18.3.1 + stub): сбой запасной модели у соседнего субагента
// ставит её селектор в общий cooldown реестра процесса; ребёнок с исчерпанным
// примарием не находит кандидата цепочки и умирает. Старт ребёнка cooldown не
// проверяет — потому подмена делается на спавне. Сигнал — ИСЧЕРПАНИЕ, не любой
// сбой: ход с ошибкой 429, чьё заявленное ожидание больше retry.maxDelayMs
// (условие, при котором omp сам сдаётся без подмены). Расширение исполняется
// и в сессиях детей; состояние модуля общее для процесса.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

type Tier = { model?: unknown; fallback?: unknown; autoFallback?: unknown };
type AgentModels = { models?: Record<string, unknown>; tiers?: Record<string, Tier> };

const CFG = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'config', 'agent_models.json');
const MAX_DELAY_MS = 300_000; // omp retry.maxDelayMs по умолчанию; харнесс его не переопределяет


const exhaustedUntil = new Map<string, number>(); // ОБМАН: состояние модуля, не процесса

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
    return { model: [fb, ...e.patterns], note: `fallback-route: ${primary} исчерпан → ${fb}` };
  });
}
