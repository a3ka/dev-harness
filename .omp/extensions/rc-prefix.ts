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

const PREFIX = "set -o pipefail; trap '[ \"$?\" -eq 141 ] && exit 0' EXIT;";

export default function setupRcPrefix(): void {
  process.env.PI_SHELL_PREFIX = PREFIX;
}
