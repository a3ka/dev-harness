FAIL
OBJECT=bb344b215f735411b41c350fd2f7f5dbdb15d15d
КЛАСС=КОДОВЫЙ
СУД: сессия=Adv157; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; вызов=1

## Вердикт

БЛОКИРУЕТ — W не отличает реализацию, которая пропускает предметный суд для
поддерживаемого batch-спавна с допустимой ролью `adversary`, от исправной
заплаты. Это нарушение обязательства контракта 157 §«Инварианты и границы» пп.
2–3: каждое принятое `task` вызывает прежнюю дверь, а конформный вход — `task`
из установленного алфавита. Это не один из восьми принятых остаточных классов:
раскладка проектной сессии и путь к двери остаются обычными, меняется только
поддерживаемая форма `input.tasks`.

КЛАСС ПРИЧИНЫ: неполный домен входа батареи. `probe.py` создаёт установленный
конфиг только с `architect` и во всех 18 клетках передаёт flat-вход с одним
`agent`; роль `adversary` действительно входит в установленный `config/agent_models.json`.
Сам хук объявляет и разбирает поддерживаемую batch-форму `input.tasks`.

СОСТОЯНИЕ: проектная сессия обычной формы
`<P>/home/.omp/profiles/dev/agent/sessions/<хвост>`; установленный алфавит
`architect, adversary`; один `tool_call task` с двумя элементами `tasks`:
сначала `architect`, затем `adversary`.

ОБХОД: в копию `spawn-guard.ts` непосредственно после
`const roots = stateRoots(sessionFile);` добавлен рабочий стаб:

```ts
if (taskItems(call.input).some((item) => item.agent === 'adversary')) return undefined;
```

Он не меняет ни одну из 18 клеток W, поскольку ни одна не представляет
допустимый `adversary` и не использует batch. Поэтому W остаётся зелёной:

```text
$ python3 fixtures/workshop_project/spawn_guard_157/probe.py
KLETKI subject 18 KRASNYH 0
rc=0
```

Для наблюдения обхода создана одноразовая установка с тем же стабом, указанным
алфавитом, тестовой дверью, которая записывает факт вызова, и живым подложным
`ctx.sessionManager.getSessionFile()`. Команда подала описанный batch:

```text
$ ADV157_DOOR_LOG="$PWD/tmp/adv157/door.log" node tmp/adv157/batch-driver.mjs \
    "$PWD/tmp/adv157/installed/.omp/extensions/spawn-guard.ts" \
    "$PWD/tmp/adv157/project/home/.omp/profiles/dev/agent/sessions/Adv157.jsonl"
{"pass":true}
DOOR=NOT_CALLED
rc=0
```

Следовательно, оба допустимых задания проходят, а дверь не судит ни одно;
будущие спавны получают обход предметного замка. Источник входа — поддерживаемый
кодом `input.tasks` (он же проверяется замороженной 104-батареей), а источник
ошибочного механизма — ранний `return undefined` выше вызова `spawnSync`.

Закрывающее свойство: W должна иметь отдельную batch-клетку с минимум двумя
ролями действительного установленного алфавита, включая `adversary`, и
проверять вызов двери и сериализованный список всех задач. После этого приведённый
стаб обязан дать rc=1.

## Сырые контрольные замеры

Позитивный контроль честной минимальной реализации и установленной заплаты:

```text
$ python3 fixtures/workshop_project/spawn_guard_157/probe.py
KLETKI subject 18 KRASNYH 0
rc=0

$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --model
KLETKI model 18 KRASNYH 0
rc=0

$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --revision cf4054e8e
KLETKI subject 18 KRASNYH 0
rc=0

$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --revision 'cf4054e8e^'
KLETKI subject 18 KRASNYH 7
rc=1

$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs
KLETKI model 18 KRASNYH 0
STAB_ZHIV не напечатан
rc=0

$ bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh && \
  bash fixtures/_krasnye_104.sh
PROB VSEGO 15 KRASNYH 0
ИТОГ 104: rc=0
rc=0
```

Заплата `cf4054e8e` на этих наблюдаемых 18 клетках соответствует обязательствам
о проектном/станционном корне, отказах двери, чужой сессии, malformed-session,
алфавите и четырёхсегментном субагенте. Отдельной неконформности самой заплаты
в достижимом и не принятом остаточном классе этим вызовом не найдено.

## Прочие выполненные атаки

* Отказ, выглядящий успехом: стаб `if (r.status === 1) return undefined;`
  дал `KLETKI subject 18 KRASNYH 10`, rc=1 — W его ловит.
* Зашитая константа: подстановка проектного `sost` на
  `/tmp/adv157-constant-state` дала семь проектных красных клеток, rc=1 — W
  сравнивает корень и argv двери.
* Правильный ответ на не тот вопрос: подстановка `--zhurnaly` на префикс
  проекта вместо `agent/sessions` дала семь проектных красных клеток, rc=1.
* Инструмент вне PATH: при `PATH=/tmp/adv157-empty-path` хук вернул
  `{"block":true,"reason":"ОТКАЗ: страж замка сломан (fail-closed): дверь не исполнена"}`;
  rc команды 0, ложного пропуска нет.
* Пустой batch: с `input: {tasks: []}` тестовая дверь вернула `EMPTY_DENY`;
  хук наблюдаемо вызвал её (`DOOR_CALLED`) и вернул
  `{"block":true,"reason":"EMPTY_DENY"}`, rc=0. Пустой вход не дал
  локального bypass.
* Нейтрализация проектной ветви подтверждена штатным красным контролем
  `--revision 'cf4054e8e^'`: семь проектных клеток красны, rc=1.

Одноразовые копии и драйверы этих атак удалены после замеров.

## Проверка неподгонки ожиданий

Дыры «ожидание вычислено после вызова» не найдено. В `probe.py` ожидаемый
исход и argv формируются в `case()` до `subprocess.run`, снимки состояния —
также до вызова; исходник хука передаётся только как копия во временную
установку. Зелёный batch-стаб поэтому не является самоподгонкой oracle, а
реальным пропуском неиспытанной поддерживаемой формы ввода.
