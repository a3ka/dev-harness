// Расширение omp: носитель env PI_SHELL_PREFIX — pipefail + 141-маппинг.
// Контракт 025 §Пачка B-1.
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
// ЕДИНОЕ ЗНАЧЕНИЕ — ПОБАЙТОВО (контракт §B-1, единственный источник):
//   set -o pipefail; trap '[ "$?" -eq 141 ] && exit 0' EXIT;
// Семантика (живые пробы круга 2): rc пайплайна = rc ПЕРВОГО упавшего элемента
// (false|true → ОШИБКА); агрегат 141 (SIGPIPE-смерть продуцента при раннем
// закрытии потребителя) маппится в 0 — yes|head / grep -q / git log|grep -q
// проходят как УСПЕХ; произвольные коды не тронуты (exit 7 → 7); голая
// SIGPIPE-смерть остаётся 141. Префикс НЕ ставит set -e.
//
// Фикстура red_pipefail_prefiks.sh проверяет побайтовое совпадение значения
// через node-import + default() + сравнение process.env.PI_SHELL_PREFIX.

const PREFIX = "set -o pipefail; trap '[ \"$?\" -eq 141 ] && exit 0' EXIT;";

export default function setupRcPrefix(): void {
  process.env.PI_SHELL_PREFIX = PREFIX;
}
