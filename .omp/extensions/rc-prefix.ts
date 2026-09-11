// Расширение omp: носитель env PI_SHELL_PREFIX — pipefail + 141-маппинг.
// Контракт 025 §Пачка B-1, Б-3 фикс-круга.
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
//   set -o pipefail; trap 'n=${#PIPESTATUS[@]} rc=$?; [ "$rc" -eq 141 ] && [ "$n" -gt 1 ] && exit 0; exit $rc' EXIT;
// Семантика: rc пайплайна = rc ПЕРВОГО упавшего элемента (false|true → ОШИБКА).
// Маппинг 141 → 0 СРАБАТЫВАЕТ ТОЛЬКО для пайплайнов (PIPESTATUS имеет >1 элемента —
// writer-стадия умерла от SIGPIPE, читатель закрыл рано): yes|head / grep -q /
// git log|grep -q идут как УСПЕХ. Явный `exit 141` (PIPESTATUS = (141)) и
// произвольные коды (exit 7 → 7) НЕ ТРОНУТЫ — настоящая краснота контракта
// адверсария 0e2ce58/B-025-3 умирает (форма fix-круга 2).
//
// КРИТИЧНО про n=${#PIPESTATUS[@]} rc=$? в одной строке: первая команда
// trap-тела СБРАСЫВАЕТ PIPESTATUS в (exit_code_текущей_команды), поэтому
// захват n и rc ОБЯЗАН быть одним statement (через пробел, не `;`) — оба
// выражения разворачиваются ДО любых присвоений, иначе n станет 1, rc=0.
// Префикс НЕ ставит set -e.
//
// Фикстура red_pipefail_prefiks.sh проверяет побайтовое совпадение значения
// через node-import + default() + сравнение process.env.PI_SHELL_PREFIX.

const PREFIX = "set -o pipefail; trap 'n=${#PIPESTATUS[@]} rc=$?; [ \"$rc\" -eq 141 ] && [ \"$n\" -gt 1 ] && exit 0; exit $rc' EXIT;";

export default function setupRcPrefix(): void {
  process.env.PI_SHELL_PREFIX = PREFIX;
}
