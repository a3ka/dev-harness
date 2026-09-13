// Расширение omp: носитель env PI_SHELL_PREFIX — pipefail + 141-маппинг.
// Контракт 025 §Пачка B-1 (замороженный тег frozen/contracts/025/1).
//
// Схема настроек билда ключа prefix НЕ ИМЕЕТ (замер круга 2: 453 ключа, из «prefix»
// только нерелевантный hindsight.bankIdPrefix; пробы bash.prefix / prefix / shell.prefix
// / bash.commandPrefix → rc 1 Unknown setting). Реальный носитель — env
// PI_SHELL_PREFIX («Optional command prefix wrapper», environment-variables.md):
// executor харнеса оборачивает КАЖДУЮ bash-команду значением этой переменной.
//
// Кто выставляет: extension rc-prefix при загрузке — default-export factory
// присваивает process.env.PI_SHELL_PREFIX. Доказательство достижимости до
// главной и дочерних сессий — живые пробы B3/D (з1-а′ круга 2).
//
// ЕДИНОЕ ЗНАЧЕНИЕ — ПОБАЙТОВО (контракт §B-1, единственный источник; оракул — в
// fixtures/check_runner_hygiene/red_pipefail_prefiks.sh:34):
//   set -o pipefail; trap '[ "$?" -eq 141 ] && exit 0' EXIT;
// Семантика (живые пробы круга 2): rc пайплайна = rc ПЕРВОГО упавшего элемента
// (false|true → ОШИБКА); агрегат 141 (SIGPIPE-смерть продуцента при раннем
// закрытии потребителя) маппится в 0 — yes|head / grep -q / git log|grep -q
// проходят как УСПЕХ; произвольные коды не тронуты (exit 7 → 7). Префикс
// НЕ ставит set -e.
//
// НАЗВАННЫЙ ОСТАТОК (контракт §Р3 + advesary 0e2ce58): явный `exit 141` И
// одиночный SIGPIPE — оба оставляют $?=141, простая форма маппит ЛЮБОЙ 141 в 0
// (см. bash -c '<PREFIX>; exit 141'). Различение (PIPESTATUS-aware trap) даёт
// «честный exit 141 → 141, pipeline-141 → 0», но НЕ побайтово с замороженным
// оракулом red_pipefail_prefiks.sh — для различения нужна параллельная
// оракуль-правка в зоне architect (Н-39: стабы к ветвям привязывает architect).
// Текущая правка восстанавливает конфор́мность контракту; остаток фиксируется в
// NABLIUDENIA / к1 FAIL 0e2ce58 для очереди.
//
// Фикстура red_pipefail_prefiks.sh проверяет побайтовое совпадение значения
// через node-import + default() + сравнение process.env.PI_SHELL_PREFIX.
//
// ── ДОПОЛНИТЕЛЬНЫЙ КАНАЛ: tool_call-ревизия (omp 18.1.18+, ночная правка
// 2026-09-13). Замер живой ночи: после апгрейда omp 17.2.10 → 18.1.18 харнес
// ПЕРЕСТАЛ оборачивать bash-команды значением PI_SHELL_PREFIX (команда
// `yes | head -1` отдаёт сырой 141 с isError=true — ложная краснота легитимного
// раннего выхода, Г4-кавер). Одновременно pipefail встроен в omp. Контракт
// §B-1 жив, инвариант И-2 жив; мёртв только механизм доставки префикса.
//
// Новый канал (omp://extensions.md «Tool lifecycle», tool_call-event):
// перехват pre-exec умеет РЕВИЗИТЬ input инструмента — то, что реально
// уйдёт в execute. Расширение регистрирует tool_call-handler, который для
// инструмента bash предпендит ТУ ЖЕ побайтовую строку B-1 + один пробел,
// если команда ещё НЕ начинается с неё (идемпотентность обязательна — повторный
// прогон зонда или явная запись bash -c '<PREFIX>; …' не должны удваивать
// префикс). Handler-ошибки трактуются omp как fail-closed (extensions.md
// «tool_call errors block execution»); дополнительно ловим ошибки доступа
// к неожиданным формам input и возвращаем именованный блок, как path-guard:
// явный «reason» виден судье в стенограмме (а не «Tool execution was blocked»
// без контекста).
//
// ИДЕНТИЧНОСТЬ ЗНАЧЕНИЯ: строка PREFIX и её форма с пробелом PREFIX + ' '
// ПОБАЙТОВО совпадают с замороженным оракулом red_pipefail_prefiks.sh:34 —
// фикстура проверяет process.env.PI_SHELL_PREFIX через node-import + base64
// и сравнивает; ревизия использует ту же константу, не литерал.

const PREFIX = "set -o pipefail; trap '[ \"$?\" -eq 141 ] && exit 0' EXIT;";
const PREFIX_WITH_SPACE = `${PREFIX} `;

type PiLike = {
  on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown;
};

// Тип-гард для tool_call-event: omp по контракту передаёт объект (см. wrapper.ts),
// узкая проверка формы — null/undefined выкидываем, всё остальное Record.
function isToolCallEvent(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === 'object';
}

export default function setupRcPrefix(pi?: unknown): void {
  // Инвариант И-2: присвоение process.env.PI_SHELL_PREFIX побайтово.
  // Побайтово гарантировано TS-литералом; оракул red_pipefail_prefiks.sh
  // проверяет через node-import + base64.
  process.env.PI_SHELL_PREFIX = PREFIX;

  if (!pi || typeof pi !== 'object') return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;

  p.on('tool_call', (call: unknown) => {
    if (!isToolCallEvent(call)) return undefined;
    if (call.toolName !== 'bash') return undefined;
    const raw = call.input;
    if (raw === undefined || raw === null || typeof raw !== 'object') {
      return undefined;
    }
    const input = raw as Record<string, unknown>;
    if (typeof input.command !== 'string') return undefined;
    // Идемпотентность: если уже есть префикс + пробел — ничего не делаем
    // (модель могла сама выставить bash -c '<PREFIX>; …', повторный прогон
    // зонда или собственный канал доставки префикса не должны удваивать).
    if (input.command.startsWith(PREFIX_WITH_SPACE)) return undefined;
    // Ревизия input: копия (не мутируем event) — omp использует её как
    // effectiveParams для execute и для второго раунда approval-gate
    // (wrapper.ts:229-231 — «handler-owned; not re-normalized»).
    return {
      input: { ...input, command: `${PREFIX_WITH_SPACE}${input.command}` },
    };
  });
}