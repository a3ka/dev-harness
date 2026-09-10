#!/usr/bin/env bash
# КРАСНОЕ 025-И-2 (пачка B-1): pipefail+141-маппинг — носитель rc-prefix.ts.
# СУБЪЕКТ: .omp/extensions/rc-prefix.ts — мини-модуль extension: его factory
# (загрузчик харнеса вызывает его при старте сессии) присваивает
# process.env.PI_SHELL_PREFIX. ДОКАЗАНО ЖИВЫМИ ПРОБАМИ этой пачки (§Зонд №1,
# пробы C2/C3/D): executor харнеса оборачивает КАЖДУЮ bash-команду значением
# этой переменной («Optional command prefix wrapper», environment-variables.md;
# bash-tool-runtime.md «If prefix is configured, it wraps the command»), и
# присвоение от extension доходит до ГЛАВНОЙ сессии и ДОЧЕРНИХ task-сессий.
# Схема настроек билда НЕ ИМЕЕТ ключа prefix (453 ключа, пробы bash.prefix /
# prefix / shell.prefix → rc 1 Unknown setting — замер круга 1): config-ключ
# как носитель невозможен, мёртвая строка «prefix: …» в .omp/config.yml —
# плацебо и умирает здесь (фикстура config.yml НЕ читает вовсе).
# СЕГОДНЯ: модуль отсутствует → rc 1 именованный. ПОСЛЕ реализации: rc 0.
#
# ГРАММАТИКА (заморожена контрактом 025 §Пачка B-1): модуль экспортирует
# default-factory БЕЗ внешних зависимостей; вызов factory присваивает
# process.env.PI_SHELL_PREFIX побайтово. Оракул значения — в ЭТОЙ фикстуре
# (правило 8); семантика (false|true→1, yes|head→0, произвольные коды не
# тронуты) мерится живым зондом probe025_dochernij_vector.sh (И-6/§B-3).
# Декой-формы вердикта 72049b0 (process.exit(0)-модуль, модуль-комментарий,
# мёртвый prefix: в config.yml) умирают: env после вызова factory пуст либо
# не совпал побайтово.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/rc-prefix.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-И-2: механизм отсутствует — %s не существует; rc пайплайна остаётся кодом хвоста (форма Н-84 «false | true → rc 0») во всех сессиях, включая дочерние\n' "$SUBJ" >&2
  exit 1
fi

# ЕДИНОЕ ЗНАЧЕНИЕ (единый источник — код субъекта; оракул — здесь):
ORACLE='set -o pipefail; trap '\''[ "$?" -eq 141 ] && exit 0'\'' EXIT;'

out="$(ORACLE="$ORACLE" SUBJ="$SUBJ" node --input-type=module -e '
const ORACLE = process.env.ORACLE;
const mod = await import("file://" + process.env.SUBJ);
if (typeof mod.default !== "function") {
  console.error("КРАСНОЕ 025-И-2: модуль не экспортирует factory-функцию — присвоение префикса невозможно");
}
mod.default();
const v = process.env.PI_SHELL_PREFIX;
if (v === undefined) {
  console.error("КРАСНОЕ 025-И-2: вызов factory не присвоил process.env.PI_SHELL_PREFIX — префикс мёртв (декой: модуль без присвоения)");
  process.exit(1);
}
if (v !== ORACLE) {
  console.error("КРАСНОЕ 025-И-2: значение PI_SHELL_PREFIX расходится с оракулом контракта побайтово:\n  получено: " + JSON.stringify(v) + "\n  оракул:   " + JSON.stringify(ORACLE));
  process.exit(1);
}
console.log("prefix-ok");
' 2>&1)"; rc=$?

if [ "$rc" -ne 0 ] || [ "$out" != "prefix-ok" ]; then
  printf '%s\n' "$out" >&2
  exit 1
fi
exit 0
