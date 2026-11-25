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
//
// ВТОРАЯ ВЕТВЬ ТОГО ЖЕ ФАЙЛА (контракт 215, frozen/contracts/215/1): отказ
// провайдера ПО СОДЕРЖАНИЮ (закрытый список маркеров) переводит ТЕКУЩУЮ сессию
// субагента на объявленную запасную модель тира и продолжает исходное задание
// (setModel + followUp в message_end). Это дополнение к 129, а не отмена его
// запрета подмены на прочих ошибках: ветви 429/срок/подмена-на-спавне выше не
// меняются, реестр исчерпаний 129 содержимым-отказом не трогается. Подробности —
// в разделе «ОТКАЗ ПО СОДЕРЖАНИЮ» ниже.
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
  model?: unknown;
};
type SpawnEvent = { modelRole?: unknown; patterns?: unknown };
// Запись сессии (sessionManager): session_init несёт роль и цепочку повтора,
// model_change — модель-факт omp. Формы проверяются на месте использования.
type SessionEntry = {
  id?: unknown;
  type?: unknown;
  model?: unknown;
  modelRole?: unknown;
  retryFallback?: { chain?: unknown } | null;
};
// Модель-факт omp (ctx.models.current/resolve): провайдер и идентификатор модели.
type ModelFact = { provider?: unknown; id?: unknown };
type ExtensionContext = {
  sessionManager?: { getEntries?: () => unknown };
  models?: { current?: () => ModelFact | undefined; resolve?: (selector: string) => ModelFact | undefined };
};

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

// message_end — сигнал ИСЧЕРПАНИЯ. Снимок хода: payload события (`message`).
// Запись — на провайдера хода, до «сейчас + N»; ход любой сессии процесса
// (родителя, ребёнка, изолированного ребёнка) засчитывается, потому что реестр
// общий.
function noteExhaustion(event: unknown): void {
  const turn = (event as { message?: TurnSnapshot } | null)?.message;
  if (turn === undefined) return;
  if (turn.role !== 'assistant' || turn.stopReason !== 'error' || turn.errorStatus !== 429) return;
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
  const list = patterns as string[];
  if (!list.every((p) => typeof p === 'string')) return undefined;
  const primary: string = list[0];
  const exhaustedProvider = providerOf(primary);
  if (exhaustedProvider === undefined) return undefined;
  const until = exhaustedUntil.get(exhaustedProvider);
  if (until === undefined || until <= Date.now()) return undefined;
  const target = fallbackSelector(role);
  if (target === undefined) return undefined;
  const targetProvider = providerOf(target);
  if (targetProvider === undefined || targetProvider === exhaustedProvider) return undefined;
  return {
    model: [target, ...list],
    note: `fallback-route: провайдер ${exhaustedProvider} исчерпан (429) → ${target}`,
  };
}

// ── 215: ОТКАЗ ПО СОДЕРЖАНИЮ → ЗАПАСНАЯ МОДЕЛЬ ТИРА ───────────────────────────
// (контракт 215, frozen/contracts/215/1). Расширение маршрута 129, НЕ второй
// маршрутизатор: ветви 129 (исчерпание 429, подмена на спавне) не меняются.
//
// СИГНАЛ — провайдерский отказ ПО СОДЕРЖАНИЮ и только он: закрытый список
// маркеров в errorMessage хода со stopReason=error. errorId и статус сигналом
// НЕ являются: 400/403/500 и errorId 53248 к списку ничего не добавляют.
//
// ДЕЙСТВИЕ — конечный переход ВНУТРИ сессии: на объявленную запасную модель тира
// (config/agent_models.json; autoFallback=true; цель в session_init.retryFallback.chain;
// провайдер цели ≠ провайдера отказавшей модели) и продолжение ТОГО ЖЕ задания
// followUp-ходом. Повторный содержимый отказ запасной завершает задание исходной
// ошибкой и записью причины CONTENT_FALLBACK_EXHAUSTED. Отказ НЕ распространяется
// на другие задания (реестр исчерпаний 129 не трогается) и аккаунт исчерпанным
// не объявляется.

// ЗАКРЫТЫЙ список сигналов (инвариант И1): одно предложение и два
// самостоятельных токена. Граница токена — начало/конец строки либо символ вне
// ASCII [A-Za-z0-9_]: «notcyber_policyx» сигналом НЕ является.
const CONTENT_SENTENCE = 'This content was flagged for possible cybersecurity risk';
const CONTENT_TOKENS = ['cyber_policy', 'content_filter'];
const TOKEN_EDGE = /[^A-Za-z0-9_]/;
// Продолжение исходного задания: требования задания не меняются (отказ провайдера
// не даёт права переписывать задание).
const CONTINUE_ON_FALLBACK = 'Continue the original task on the configured fallback. Do not change its requirements.';

// Содержимый отказ — ровно закрытый список и ничего кроме.
function isContentRefusal(message: string): boolean {
  if (message.includes(CONTENT_SENTENCE)) return true;
  for (const token of CONTENT_TOKENS) {
    let at = message.indexOf(token);
    while (at >= 0) {
      const before = at > 0 ? message.charAt(at - 1) : '';
      const after = at + token.length < message.length ? message.charAt(at + token.length) : '';
      if ((before === '' || TOKEN_EDGE.test(before)) && (after === '' || TOKEN_EDGE.test(after))) return true;
      at = message.indexOf(token, at + 1);
    }
  }
  return false;
}

// Записи сессии — публичный sessionManager; неизвестная форма — пустой список.
function sessionEntries(ctx: unknown): SessionEntry[] {
  const context = ctx as ExtensionContext | undefined;
  const manager = context?.sessionManager;
  if (manager === undefined || typeof manager.getEntries !== 'function') return [];
  const entries = manager.getEntries();
  return Array.isArray(entries) ? (entries as SessionEntry[]) : [];
}

// Последняя запись заданного типа (session_init, model_change).
function lastEntry(entries: SessionEntry[], type: string): SessionEntry | undefined {
  for (let i = entries.length - 1; i >= 0; i -= 1) {
    const entry = entries[i];
    if (entry !== undefined && entry !== null && entry.type === type) return entry;
  }
  return undefined;
}

// Модель-факт omp → полный selector «провайдер/модель».
function selectorOf(fact: ModelFact | undefined): string | undefined {
  if (fact === undefined || fact === null) return undefined;
  const provider = fact.provider;
  const id = fact.id;
  if (typeof provider !== 'string' || typeof id !== 'string') return undefined;
  if (provider === '' || id === '') return undefined;
  return `${provider}/${id}`;
}

// Квиток расширения о переходе: customType=fallback-route-215, причина и полные
// selector. modelChangeId — id НАСТОЯЩЕГО model_change сессии, не намерение.
function appendReceipt(api: PiLike, reason: string, from: string, target?: string, modelChangeId?: string): void {
  if (typeof api.appendEntry !== 'function') return;
  const data: Record<string, string> = { reason, from };
  if (target !== undefined) data.target = target;
  if (modelChangeId !== undefined) data.modelChangeId = modelChangeId;
  api.appendEntry('fallback-route-215', data);
}

// message_end — содержимый отказ: ранний конечный переход на запасную модель тира
// и продолжение ТОГО ЖЕ задания. Отказ без цепочки/autoFallback/разрешённой цели
// не порождает ни нового хода, ни записи: исходный отказ сохраняется.
async function routeContentRefusal(api: PiLike, event: unknown, ctx: unknown): Promise<void> {
  const turn = (event as { message?: TurnSnapshot } | null)?.message;
  if (turn === undefined) return;
  if (turn.role !== 'assistant' || turn.stopReason !== 'error') return;
  const message = turn.errorMessage;
  if (typeof message !== 'string' || message === '') return;
  if (!isContentRefusal(message)) return;

  const init = lastEntry(sessionEntries(ctx), 'session_init');
  if (init === undefined) return;
  const role = init.modelRole;
  if (typeof role !== 'string') return;
  const chain = init.retryFallback?.chain;
  if (!Array.isArray(chain)) return;
  const target = fallbackSelector(role);
  if (target === undefined || !chain.includes(target)) return;

  const provider = turn.provider;
  const model = turn.model;
  if (typeof provider !== 'string' || typeof model !== 'string') return;
  const current = `${provider}/${model}`;

  const context = ctx as ExtensionContext | undefined;
  const live = selectorOf(context?.models?.current?.());
  if (live === undefined) return;
  // И3: сессия УЖЕ на запасной — повторный содержимый отказ: исчерпание.
  if (live === target) {
    appendReceipt(api, 'CONTENT_FALLBACK_EXHAUSTED', current);
    return;
  }
  // Чужой или устаревший ход: не наш сессионный модель-факт — молчим.
  if (live !== current) return;
  // И2: провайдер цели обязан отличаться от провайдера отказавшей модели.
  const targetProvider = providerOf(target);
  const currentProvider = providerOf(current);
  if (targetProvider === undefined || currentProvider === undefined) return;
  if (targetProvider === currentProvider) return;

  const resolved = context?.models?.resolve?.(target);
  if (resolved === undefined || resolved === null) return;
  const resolvedSelector = selectorOf(resolved);
  if (resolvedSelector === undefined) return;
  if (typeof api.setModel !== 'function') return;
  // Модель-факт omp ПЕРЕДАЁТСЯ ЦЕЛИКОМ (тот же объект, что вернул resolve) —
  // setModel сверяется с реестром моделей по самому факту, а не по паре полей.
  const changed = await api.setModel(resolved);
  if (!changed) return;

  // Квиток: id настоящего model_change САМОЙ смены (на целевой модели).
  const change = lastEntry(sessionEntries(ctx), 'model_change');
  const modelChangeId = change !== undefined && change.model === target && typeof change.id === 'string'
    ? change.id
    : undefined;
  appendReceipt(api, 'CONTENT_FALLBACK_SWITCH', current, target, modelChangeId);
  if (typeof api.sendUserMessage === 'function') {
    api.sendUserMessage(CONTINUE_ON_FALLBACK, { deliverAs: 'followUp' });
  }
}

type PiLike = {
  on?: (name: string, handler: (event: unknown, ctx?: unknown) => unknown) => unknown;
  setModel?: (model: unknown) => unknown;
  appendEntry?: (kind: string, data: object) => unknown;
  sendUserMessage?: (text: string, options: { deliverAs: string }) => unknown;
};

export default function register(pi: unknown): void {
  const api = pi as PiLike;
  if (typeof api.on !== 'function') return;
  api.on('message_end', (event: unknown) => {
    noteExhaustion(event);
    return undefined;
  });
  api.on('before_subagent_spawn', route);
  // 215: тот же шов message_end, что и сигнал исчерпания, — ранний переход на
  // запасную модель тира при отказе по содержанию.
  api.on('message_end', async (event: unknown, ctx?: unknown) => {
    await routeContentRefusal(api, event, ctx);
  });
}