// Расширение omp: носитель env PI_SHELL_PREFIX + tool_result-патчер (141 → 0).
// Контракт 025 §Пачка B-1 (замороженный тег frozen/contracts/025/1).
//
// Схема настроек билда ключа prefix НЕ ИМЕЕТ (замер круга 2: 453 ключа, из «prefix»
// только нерелевантный hindsight.bankIdPrefix; пробы bash.prefix / prefix /
// shell.prefix / bash.commandPrefix → rc 1 Unknown setting). Реальный носитель — env
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
// ── ИСТОРИЯ КАНАЛОВ ДОСТАВКИ pipefail-ПОДАВЛЕНИЯ (omp 18.1.18+, замер 2026-09-13) ─
// Круг 2 (commit b11aa9a): env PI_SHELL_PREFIX + tool_call-ревизия
//   (pi.on('tool_call', …) с возвратом {input:{command:'<PREFIX> '+…}}).
//   Ночная правка 2026-09-13 на бинаре 18.1.18:
//     - env-канал МЁРТВ: команды НЕ оборачиваются значением PI_SHELL_PREFIX
//       (харнес 18.1.18 перестал выставлять commandPrefix-обёртку; одновременно
//       pipefail встроен в omp явно). Улика: `yes | head -1` отдаёт сырой 141
//       с isError=true (ложная краснота легитимного раннего выхода, Г4-кавер).
//     - tool_call-ревизия МЁРТВА на бинаре 18.1.18: handler стреляет (маркер
//       FIRED-<pid> в /tmp/revprobe/), но правка input не доезжает до execute —
//       команда исполняется без префикса, даёт сырой 141. Мёртвая ветка,
//       утверждающая поведение — ложная мера: удалена целиком.
//
// Круг 3 (эта правка): tool_result-патч — носитель сменился С инвазивного
// pre-exec (tool_call-ревизия) НА реактивный post-exec (tool_result-маппинг).
//
// tool_result-патч: если event.toolName === 'bash' && event.details?.exitCode
// === 141, возвращаем { isError: false, details: { ...event.details, exitCode:
// 0 } }. Агрегат 141 (SIGPIPE в пайплайне) маппится в 0 — вызов перестаёт
// быть ошибкой; модель видит isError=false, executor фиксирует
// details.exitCode=0. Видимый код остаётся судье через маркер B-2 [exit=141]:
// exit-marker.ts грузится РАНЬШЕ по алфавиту файлов (.omp/extensions/exit-marker.ts
// < rc-prefix.ts) и патчит content с маркером [exit=N] на основе details.exitCode
// ДО того, как rc-prefix зануляет exitCode; omp runner.ts:1280-1304 мерджит
// возвраты handler'ов последовательно (currentEvent.details переприсваивается
// целиком, content не трогается rc-prefix'ом) — финал: content=[exit=141],
// isError=false, details.exitCode=0. Параллельный пример с exit 7 → 7
// (не 141) НЕ тронут; false|true → exit 1 НЕ тронут. Только 141, только bash.
//
// Доказательство достижимости tool_result-канала: живая проба ночи 2026-09-13
// (трейс в .zones/dev/.omp/profiles/dev/agent/sessions/-tmp-revprobe/
// 2026-09-13T02-10-00-698Z_01a09887-*.jsonl): command "yes | head -1" → вызов
// handler'а → возврат {isError:false, details:{...exitCode:0}} → в стенограмме
// сессии details.exitCode=0 при isError=false. Маркер PATCHED-141 в /tmp/revprobe/.
// Источник формы события: dump в /tmp/revprobe/RES-296918 (до патча), RES-297052
// (exit 7 не тронут, контроль избирательности).

const PREFIX = "set -o pipefail; trap '[ \"$?\" -eq 141 ] && exit 0' EXIT;";

type PiLike = {
  on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown;
};

export default function setupRcPrefix(pi?: unknown): void {
  // Инвариант И-2: присвоение process.env.PI_SHELL_PREFIX побайтово.
  // Побайтово гарантировано TS-литералом; оракул red_pipefail_prefiks.sh
  // проверяет через node-import + base64.
  process.env.PI_SHELL_PREFIX = PREFIX;

  if (!pi || typeof pi !== 'object') return;
  const p = pi as PiLike;
  if (typeof p.on !== 'function') return;

  p.on('tool_result', (event: unknown) => {
    if (event === null || typeof event !== 'object') return undefined;
    const e = event as Record<string, unknown>;
    if (e.toolName !== 'bash') return undefined;
    const details = e.details;
    if (details === null || typeof details !== 'object') return undefined;
    const d = details as Record<string, unknown>;
    if (d.exitCode !== 141) return undefined;
    return {
      isError: false,
      details: { ...d, exitCode: 0 },
    };
  });
}