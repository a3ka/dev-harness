FAIL

# Адверсарий: закрытие закалки барьера контракта 005

Судимый предмет: HEAD `eab8806cb702e91ac7ea0cad7002a7cf5ba16133`
(`git rev-parse HEAD` до проб). Продуктовый код, барьер и фикстуры не менялись:
обманные деревья и наблюдатели находятся только в `tmp/adv005z/`.

## Позитивный контроль

На судимом HEAD выполнен неизменённый честный барьер:

```text
$ bash scripts/check_metering.sh
  ok   е: budget.json после rebuild равен свёртке calls.jsonl (непустой, побайтово)
  ok   к1: только статические node:-импорты в .../scripts/proxy/metering_proxy.ts
  ok   к2: child_process и внешних процессов в .../scripts/proxy/metering_proxy.ts нет
  ok   л.i: два порождённых вектора >2^53 (...) точны и отличимы от double
  ok   м: x-request-id прошёл client→upstream и в журнал дословно

барьер зелёный: 15 ветвей пройдены
```

Код возврата — 0. Следовательно, ниже краснота (е) — различающий контроль,
а не вечно-красный барьер.

## Повторные пробы

Каждый стаб запускался своим раннером из корня репозитория:

```text
python3 tmp/adv005z/run_barrier.py tmp/adv005z/<ветвь>
```

Раннер запускает ровно `/usr/bin/bash scripts/check_metering.sh` с рабочим
каталогом дерева стаба и сохраняет объединённый stdout/stderr в
`<ветвь>/barrier.out`.

### (е) — пойманная нейтрализация rebuild

**Стаб и вход.** В `tmp/adv005z/e/scripts/proxy/metering_proxy.ts` перед
нормальной свёрткой `rebuildBudget` внесено:

```ts
if (!cfg.data_dir.includes('tmp-selftest-')) {
  writeBudget(cfg.data_dir, {})
  return 0
}
```

Таким образом самотест остаётся честным, а обычный рабочий каталог ветви (е)
с непустым `calls.jsonl` получает пустой бюджет. Это намеренная нейтрализация
ровно одной проверяемой вещи — пересборки бюджета.

**Результат.** Команда вернула `exit=1`: барьер красный, то есть стаб пойман.
Сырой хвост `tmp/adv005z/e/barrier.out`:

```text
  ok   д: 502 при обрыве upstream, строка 11 полей status=502 tokens/usd=0
  ok   д
  FAIL е: budget.json после rebuild ≠ свёртке журнала: свёртка={"2026-08":{"ccfbcc":"0"}} budget={}
  FAIL е
  ok   ж: 503 на unpriced, upstream не вызван, строки нет
  ok   ж
  ok   з: буквальное значение секрета не найдено (обход без ./tmp и ./.git — объявленное исключение)
  ok   з
  ok   и: ротация в одном pid: T1→T2→401, role=bdbbcbgb
  ok   и
  ok   к1: только статические node:-импорты в /home/aka/Documents/dev-harness/tmp/adv005z/e/scripts/proxy/metering_proxy.ts
  ok   к1
  ok   к2: child_process и внешних процессов в /home/aka/Documents/dev-harness/tmp/adv005z/e/scripts/proxy/metering_proxy.ts нет
  ok   к2
  ok   л.п: 2026-01 и 2026-02 различимы в ОДНОМ живом процессе (pid 2502679 до и после)
  ok   л.о: usd P1=1200000 и P2=2400000 — разные тарифы по разным провайдерам одной модели
  ok   л.i: два порождённых вектора >2^53 (9007199254785069, 9500000000108723) точны и отличимы от double
  ok   л
  ok   м: x-request-id прошёл client→upstream и в журнал дословно
  ok   м

расхождений: 1 · прогон оставлен в /home/aka/Documents/dev-harness/tmp/adv005z/e/tmp/metering.cAdFi4
```

Маркер для этой пробы не нужен: наблюдаемое нарушение и есть отличающееся
`budget={}` против свёртки непустого журнала; барьер его отверг.

### (к1) — обход builtins-only через склейку в `Function`

**Стаб и вход.** В дереве
`tmp/adv005z/k1/scripts/proxy/metering_proxy.ts` в обработчик каждого запроса
вставлены:

```ts
const __advK1Load = Function("return " + "im" + "port('file:///.../outside-node.mjs')")
// в handleRequest:
void __advK1Load()
```

`outside-node.mjs` выполняет `appendFileSync` в `import.marker`. Вход —
обычный набор запросов default-барьера; после очистки маркера повторный запуск
оставил семь строк `loaded`. Значит дерево стаба на этом входе реально
загружает модуль по `file:` URL, не `node:` builtin.

**Результат.** `python3 .../run_barrier.py .../k1` вернул `exit=0`; это обход:
барьер зелёный при нарушенном контракте builtins-only. Сырой хвост
`tmp/adv005z/k1/barrier.out`:

```text
  ok   ж: 503 на unpriced, upstream не вызван, строки нет
  ok   ж
  ok   з: буквальное значение секрета не найдено (обход без ./tmp и ./.git — объявленное исключение)
  ok   з
  ok   и: ротация в одном pid: T1→T2→401, role=cbcjbcbc
  ok   и
  ok   к1: только статические node:-импорты в /home/aka/Documents/dev-harness/tmp/adv005z/k1/scripts/proxy/metering_proxy.ts
  ok   к1
  ok   к2: child_process и внешних процессов в /home/aka/Documents/dev-harness/tmp/adv005z/k1/scripts/proxy/metering_proxy.ts нет
  ok   к2
  ok   л.п: 2026-01 и 2026-02 различимы в ОДНОМ живом процессе (pid 2510758 до и после)
  ok   л.о: usd P1=1200000 и P2=2400000 — разные тарифы по разным провайдерам одной модели
  ok   л.i: два порождённых вектора >2^53 (9007199254772359, 9500000000096481) точны и отличимы от double
  ok   л
  ok   м: x-request-id прошёл client→upstream и в журнал дословно
  ok   м

барьер зелёный: 15 ветвей пройдены
```

Сырой `tmp/adv005z/k1/import.marker` после очистки и повторного запуска:

```text
loaded
loaded
loaded
loaded
loaded
loaded
loaded
```

### (к2) — обход builtins-only и запрета внешнего процесса через вычисляемые свойства

**Стаб и вход.** В дереве
`tmp/adv005z/k2/scripts/proxy/metering_proxy.ts` вставлены:

```ts
const __advK2Process = process['getBuiltin' + 'Module']('node:' + 'child_' + 'process')
// в handleRequest:
__advK2Process?.['exec' + 'FileSync']('/bin/sh', ['-c', 'printf process-created\\n >> .../process.marker'])
```

Вход — тот же обычный набор запросов default-барьера. Следовательно, стаб
разрешает `node:child_process` и реально вызывает `/bin/sh`, хотя буквальных
`child_process` и `execFileSync(` в исходнике нет.

**Результат.** После очистки маркера раннер вернул `exit=0`: барьер зелёный
при нарушенном builtins-only/запрете внешнего процесса. Сырой хвост
`tmp/adv005z/k2/barrier.out`:

```text
  ok   ж: 503 на unpriced, upstream не вызван, строки нет
  ok   ж
  ok   з: буквальное значение секрета не найдено (обход без ./tmp и ./.git — объявленное исключение)
  ok   з
  ok   и: ротация в одном pid: T1→T2→401, role=ccibbbdc
  ok   и
  ok   к1: только статические node:-импорты в /home/aka/Documents/dev-harness/tmp/adv005z/k2/scripts/proxy/metering_proxy.ts
  ok   к1
  ok   к2: child_process и внешних процессов в /home/aka/Documents/dev-harness/tmp/adv005z/k2/scripts/proxy/metering_proxy.ts нет
  ok   к2
  ok   л.п: 2026-01 и 2026-02 различимы в ОДНОМ живом процессе (pid 2518346 до и после)
  ok   л.о: usd P1=1200000 и P2=2400000 — разные тарифы по разным провайдерам одной модели
  ok   л.i: два порождённых вектора >2^53 (9007199254793811, 9500000000133113) точны и отличимы от double
  ok   л
  ok   м: x-request-id прошёл client→upstream и в журнал дословно
  ok   м

барьер зелёный: 15 ветвей пройдены
```

Сырой `tmp/adv005z/k2/process.marker` после очистки: 

```text
process-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-creatednprocess-createdn
```

Это 400 байт, то есть ровно `process-createdn` 25 раз; отсутствие перевода
строки — свойство намеренно переданной shell-строки, а не отсутствие запуска.

### (л.i) — честно ровно на входе барьера, ложно на соседнем int64-входе

**Стаб.** В `tmp/adv005z/li/scripts/proxy/metering_proxy.ts` перед расчётом
внесено:

```ts
if (inRateMicro > 9_000_000_000_000_000n && tokensIn !== 1_000_000_000) {
  return 0n
}
```

**Зелёный вход барьера.** Его (л.i) порождает ставки выше $2^{53}$, но держит
`tokensIn = 1_000_000_000`; поэтому стаб выполняет настоящую ветку. Раннер
вернул `exit=0`. Сырой хвост `tmp/adv005z/li/barrier.out`:

```text
  ok   ж: 503 на unpriced, upstream не вызван, строки нет
  ok   ж
  ok   з: буквальное значение секрета не найдено (обход без ./tmp и ./.git — объявленное исключение)
  ok   з
  ok   и: ротация в одном pid: T1→T2→401, role=bbifbbbc
  ok   и
  ok   к1: только статические node:-импорты в /home/aka/Documents/dev-harness/tmp/adv005z/li/scripts/proxy/metering_proxy.ts
  ok   к1
  ok   к2: child_process и внешних процессов в /home/aka/Documents/dev-harness/tmp/adv005z/li/scripts/proxy/metering_proxy.ts нет
  ok   к2
  ok   л.п: 2026-01 и 2026-02 различимы в ОДНОМ живом процессе (pid 2526971 до и после)
  ok   л.о: usd P1=1200000 и P2=2400000 — разные тарифы по разным провайдерам одной модели
  ok   л.i: два порождённых вектора >2^53 (9007199254889835, 9500000000143213) точны и отличимы от double
  ok   л
  ok   м: x-request-id прошёл client→upstream и в журнал дословно
  ok   м

барьер зелёный: 15 ветвей пройдены
```

**Наблюдаемый дефект на другом допустимом входе.** Наблюдатель
`node tmp/adv005z/li/observe_wrong_numeric.mjs` подаёт `tokensIn=999999999`,
`tokensOut=0`, `inRateMicro=9007199254740993`, `outRateMicro=0` и отдельным
целочисленным оракулом считает ожидаемую цену. Сырой вывод-маркер:

```text
status=200
observed_usd=0
expected_usd=9007199245733793746
```

Итак, в состоянии дерева «стаб li на входе 999999999/9007199254740993»
барьер ранее зелёный, но контракт int64-арифметики нарушен: вместо точного
положительного результата записан ноль. Это зашитая развилка на известный
фиксированный `tokensIn` барьера.

## Повтор причины и обязательный арбитраж

**ПОВТОР №2 причины «греп defeatable».** Первый замер уже зафиксирован в
`verdicts/adversary/milestone-005.md`, разделах «(к1) динамический импорт не-node
модуля не наблюдается» и «(к2) внешний процесс скрывается динамическим доступом
к builtin»: тогда проверка пропустила динамические формы. Настоящие k1/k2
доказывают ту же инженерную причину второй раз, более узко — строковой склейкой
и `Function`/вычисляемыми свойствами. Статический grep видит буквальный текст,
но не исполняемую семантику; для builtins-only это не является защитой.

**АРБИТР: `arbiter` (роль `roles/arbiter.md`) должен быть созван без согласия
автора.** Вопрос арбитража: «достаточен ли статический grep как верификация
builtins-only, либо барьер обязан рантайм-энфорсментом (или эквивалентной
исполняемой проверкой) доказать, что обработка запроса не загружает не-`node:`
модули и не создаёт внешний процесс через динамическое обращение?» Мандат —
установить обязательный способ верификации, а не переписать его автору в этом
вердикте.

## Вердикт

FAIL. (е) теперь правильно краснеет на нейтрализации, но k1, k2 и li — три
наблюдаемые неверные реализации, которые проходят весь барьер зелёным. Закрытие
контрактного барьера невозможно до исправления автором и решения названного
арбитража по повторной причине k1/k2.
