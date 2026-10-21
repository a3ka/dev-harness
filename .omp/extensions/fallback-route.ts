// fallback-route — маршрут подмены модели субагента при исчерпанном примарии тира
// (контракт 129, frozen/contracts/129/1).
//
// Замер причины (контракт §Предмет, логи omp 2026-10-21): сбой селектора в ЛЮБОЙ
// сессии процесса ставит провайдера в общий cooldown реестра моделей, которым
// пользуются и дети («runSubagent: reusing parent modelRegistry»). Кандидат цепочки
// тира в cooldown пропускается, а старт ребёнка cooldown НЕ проверяет — ребёнок,
// спавненный на исчерпанном примарии, умирает без единой попытки на запасной
// модели. Отсюда форма: подмена делается НА СПАВНЕ, до старта ребёнка.
//
// СИГНАЛ — ИСЧЕРПАНИЕ, а не любой сбой селектора: ход ассистента с
// stopReason "error", errorStatus 429 и заявленным ожиданием retry-after-ms=<N>,
// где N > 300000 (retry.maxDelayMs omp по умолчанию; .omp/config.yml его не задаёт).
// На этом пороге omp сам сдаётся без подмены. 400 валидации, 5xx и короткий 429
// (который omp ждёт сам) ИСЧЕРПАНИЕМ НЕ ЯВЛЯЮТСЯ и подмены не вызывают.
//
// Состояние запасной модели условием подмены не является ни в одну сторону:
// подмена — одна попытка на запасной модели БЕЗ сверки её состояния (инвариант 5,
// предел механизма). Её cooldown после чужого 429 или 400 подмену не отменяет, и
// запись исчерпания её провайдера для подмены не требуется.
//
// ЦЕЛЬ подмены — только `fallback` тира из config/agent_models.json (единственный
// источник назначений), причём провайдер цели обязан отличаться от провайдера
// исчерпанного примария: переход на другое семейство того же исчерпанного
// аккаунта — не подмена.
//
// Механизм не ставит своих повторов и новых ходов: он только переставляет список
// попыток ребёнка (`before_subagent_spawn` → `{model}`), дальше работает штатная
// машина omp.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

// Пин источника — РАСПОЛОЖЕНИЕ этого файла (прецедент spawn-guard.ts): config/
// agent_models.json УСТАНОВЛЕННОГО харнесса. process.cwd() — это проект сессии, он
// подменяем и неполон (у ребёнка в изолированном рабочем каталоге своя копия).
const CFG = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'config', 'agent_models.json');

// Порог исчерпания: omp бросает заявленное ожидание только когда оно превышает
// retry.maxDelayMs (по умолчанию 300000). Меняется вместе с .omp/config.yml.
const EXHAUSTION_WAIT_MS = 300_000;
const WAIT_MS_IN_ERROR = /retry-after-ms=(\d+)/;

type Tier = { model?: unknown; fallback?: unknown; autoFallback?: unknown };
type Roster = { models?: Record<string, unknown>; tiers?: Record<string, Tier> };
// Снимок хода ассистента: каждое поле проверяется на месте использования (typeof),
// граница — единственное место, где неизвестная форма события становится именованной.
type TurnSnapshot = {
  role?: unknown;
  stopReason?: unknown;
  errorStatus?: unknown;
  errorMessage?: unknown;
  provider?: unknown;
};
type SpawnEvent = { modelRole?: unknown; patterns?: unknown };

// Реестр исчерпаний ПРОЦЕССА, а не модуля: субагент грузит СВОЮ копию этого файла
// (изолированный рабочий каталог находит расширения обнаружением), поэтому
// состояние модуля изолированного ребёнка родителю не видно. Symbol.for даёт одно
// место на globalThis для всех копий расширения в процессе omp. Карта, а не
// объект: записи появляются во время работы процесса (провайдеры — из ходов).
const STATE = Symbol.for('dev-harness.fallback-route.exhausted.v1');
const g = globalThis as unknown as Record<symbol, Map<string, number> | undefined>;
const exhaustedUntil: Map<string, number> = g[STATE] ?? (g[STATE] = new Map<string, number>());

// Провайдер селектора omp `provider/id` (первый срез до `/`). Без `id` части
// селектора провайдер не определить — судить нечего, подмены нет.
function providerOf(selector: string): string | undefined {
  const slash = selector.indexOf('/');
  return slash > 0 ? selector.slice(0, slash) : undefined;
}

// Запасная модель тира: единственный источник — config/agent_models.json. Тир идёт
// по modelRole спавна (`@slow` и `slow` — одна роль), помечается autoFallback,
// ссылается на семейство `@…`, а селектор семейства берётся из models.
function fallbackSelector(modelRole: string): string | undefined {
  let roster: Roster;
  try {
    roster = JSON.parse(readFileSync(CFG, 'utf8')) as Roster;
  } catch {
    return undefined; // источника нет/побит — спавн идёт как есть
  }
  const tier = roster.tiers?.[modelRole.startsWith('@') ? modelRole.slice(1) : modelRole];
  if (!tier || tier.autoFallback !== true || typeof tier.fallback !== 'string') return undefined;
  const selector = roster.models?.[tier.fallback.startsWith('@') ? tier.fallback.slice(1) : tier.fallback];
  return typeof selector === 'string' ? selector : undefined;
}

// message_end — сигнал ИСЧЕРПАНИЯ. Снимок хода: payload события (`message`) либо
// сам payload, если снимок приходит без обёртки. Запись — на провайдера хода, до
// «сейчас + N»; ход любой сессии процесса (родителя, ребёнка, изолированного
// ребёнка) засчитывается, потому что реестр общий.
function noteExhaustion(event: unknown): void {
  const snapshot = (event as { message?: TurnSnapshot } | null)?.message;
  const turn: TurnSnapshot = snapshot ?? (event as TurnSnapshot);
  if (turn?.role !== 'assistant' || turn.stopReason !== 'error' || turn.errorStatus !== 429) return;
  const wait = WAIT_MS_IN_ERROR.exec(String(turn.errorMessage ?? ''));
  if (wait === null || Number(wait[1]) <= EXHAUSTION_WAIT_MS) return;
  if (typeof turn.provider !== 'string' || turn.provider === '') return;
  exhaustedUntil.set(turn.provider, Date.now() + Number(wait[1]));
}

// before_subagent_spawn — единственное место решения. Возвращённый список —
// порядок попыток ребёнка, остаток — его цепочка omp. Молчание = спавн как есть.
function route(event: unknown): { model: string[]; note: string } | undefined {
  const spawn = event as SpawnEvent | null;
  const role = spawn?.modelRole;
  const patterns = spawn?.patterns;
  if (typeof role !== 'string' || !Array.isArray(patterns) || patterns.length === 0) return undefined;
  if (!patterns.every((p) => typeof p === 'string')) return undefined;
  const [primary, ...tail] = patterns as string[];
  const exhaustedProvider = providerOf(primary);
  if (exhaustedProvider === undefined) return undefined;
  const until = exhaustedUntil.get(exhaustedProvider);
  if (until === undefined || until <= Date.now()) return undefined;
  const target = fallbackSelector(role);
  if (target === undefined || target === primary) return undefined;
  const targetProvider = providerOf(target);
  if (targetProvider === undefined || targetProvider === exhaustedProvider) return undefined;
  return {
    model: [target, ...tail.filter((p) => p !== target)],
    note: `fallback-route: провайдер ${exhaustedProvider} исчерпан (429) → ${target}`,
  };
}

type PiLike = { on?: (name: string, handler: (event: unknown) => unknown) => unknown };

export default function register(pi: unknown): void {
  const api = pi as PiLike;
  if (typeof api.on !== 'function') return;
  api.on('message_end', (event: unknown) => {
    noteExhaustion(event);
    return undefined;
  });
  api.on('before_subagent_spawn', route);
}