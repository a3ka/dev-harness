FAIL
OBJECT=8b741e83189ac5f3e43682b8631a26f009c67be8
КЛАСС=рисковый
СУД: сессия=Adv157d; модель-план=openai-codex/gpt-5.6-terra (advisor; fallback anthropic/claude-opus-5-5, autoFallback); модель-факт=openai-codex/gpt-5.6-terra; вызов=3/…

## Вердикт

БЛОКИРУЕТ — W не отличает от честного хука выборочное усечение третьего,
последнего либо всех внутренних элементов поддерживаемого batch из четырёх и
более задач. Нарушено обязательство frozen-контракта 157/1 §«Инварианты и
границы», п. 2: каждое принятое `task` зовёт прежнюю дверь; в событие двери
должен войти весь нормализованный список задач. Это не один из восьми принятых
остаточных классов (все восемь описывают форму пути), не duplicate-only batch и
не повтор прежних блоков: роли различны, раскладка проектной сессии обычная,
дельта добавила только клетки длины 2 и 3.

КЛАСС ПРИЧИНЫ: неполный домен длины batch в W. В `probe.py` максимум —
`project-batch-three`; ни одна из 25 клеток не подаёт четыре задачи.

СОСТОЯНИЕ: поддерживаемая самим хуком форма `input.tasks`, проектная сессия
`<P>/home/.omp/profiles/dev/agent/sessions/<хвост>`, установленный алфавит и
один четырёхэлементный вход (одна строка):

```json
{"tasks":[{"agent":"architect"},{"agent":"implementer"},{"agent":"critic"},{"agent":"adversary"}]}
```

Честный OBJECT наблюдаемо обрабатывает эту форму: одноразовая клетка
`four-honest` завершилась `KLETKI four-honest 1 KRASNYH 0`, rc=0.

ОБХОД: в копии принятого hook заменена уже существующая предметная операция
сериализации `JSON.stringify({ tasks: taskItems(call.input) })`. Мутанты
сохраняют прежнюю операцию для batch длины до трёх, а при четвёртом элементе:

* удаляют индекс 2;
* удаляют последний элемент;
* передают только первый и последний.

Это источник ошибочного механизма — замена существующей передачи списка в
дверь, а не добавленная в стороне ветвь. Каждый мутант оставляет штатный W
зелёным:

```text
KLETKI skip-third-four-plus 25 KRASNYH 0   rc=0
KLETKI skip-last-four-plus 25 KRASNYH 0    rc=0
KLETKI first-last-four-plus 25 KRASNYH 0   rc=0
```

Но на том же установленном шве одноразовая четырёхэлементная клетка наблюдает
фактическую передачу неполного события и краснеет ровно по проверке двери:

```text
CASE four-skip-third four-skip-third KRASNO: ('four-skip-third', 'door did not judge every batch item')
KLETKI four-skip-third 1 KRASNYH 1   rc=1
CASE four-skip-last four-skip-last KRASNO: ('four-skip-last', 'door did not judge every batch item')
KLETKI four-skip-last 1 KRASNYH 1    rc=1
CASE four-first-last four-first-last KRASNO: ('four-first-last', 'door did not judge every batch item')
KLETKI four-first-last 1 KRASNYH 1   rc=1
```

Ожидание — дверь получает сериализованный список всех четырёх задач в исходном
порядке; фактически получает соответственно три, три либо две. Поэтому дверь
не судит пропущенные задачи, хотя batch принят алфавитом. Закрывающее свойство:
W должна добавить четырёхэлементную клетку с различными ролями установленного
алфавита, независимым ожидаемым event до запуска и точным сравнением полного
упорядоченного списка; каждый из трёх мутантов обязан дать rc=1. Класс шире
примеров: любая выборочная потеря внутреннего или хвостового элемента batch
длиной ≥4.

## Закрытие прежних обходов и позитивные контроли

Честные controls зелёные:

```text
$ python3 fixtures/workshop_project/spawn_guard_157/probe.py
KLETKI subject 25 KRASNYH 0
rc=0
$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --model
KLETKI model 25 KRASNYH 0
rc=0
$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --revision cf4054e8e
KLETKI subject 25 KRASNYH 0
rc=0
$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --revision 'cf4054e8e^'
KLETKI subject 25 KRASNYH 13
rc=1
$ python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs
STABY 16 NEPOIMANNYH 0
rc=0
```

Ранее названные обходы закрыты исполнением на OBJECT: `adv157-pass-without-door`
краснит только `project-batch-adversary`; усечение до двух —
`project-batch-three`; reviewer-first — `project-batch-reviewer-first`. Каждый
отдельный `--mutant` дал `KLETKI subject 25 KRASNYH 1`, rc=1. `--list` не
является режимом этой батареи: usage вернул rc=2; это не выдано за успешную
проверку.

## Что не удалось сломать и чем проверено

* Независимость oracle: `case()` строит `expected_event`, ожидаемый argv и
  снимки состояния до `subprocess.run`; исходник hook передаётся в временную
  установленную копию. В этой дельте чтение ожидания после запуска не найдено.
* Неверные формы входа fail-closed до двери: `tasks:null` и строка дают
  `THROW tasks не массив`; не-объектный batch-элемент и нестроковый `agent`
  также бросают; `role` без `agent`, регистровый и пробельный `agent` дают
  именованный отказ. Пустой `tasks` и поля `isolated`/`worktree` не дают
  локального разрешения вне нормального пути: первый проходит дальше к двери,
  второй сохраняет валидный `agent`.
* Смешанный batch с валидными `architect` и `reviewer` принимается одинаково
  (`undefined`) до предметной двери; маршрутизация определяется живой сессией,
  а не полем задачи.
* Отсутствующий в PATH Node не считается успехом W:
  `PATH=/tmp/dev-harness-empty-path /usr/bin/python3 .../probe.py` напечатал
  `NOT_IMPLEMENTED: node absent`, rc=2.
* Зашитый корень, env-подмена корня, отказы двери и её rc=2, а также старые
  batch-обходы ловятся 16 штатными стабами. Смежные регрессии зелёные:
  `bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh`,
  `bash fixtures/_krasnye_104.sh`, `npm run check:ceilings` и
  `npm run check:gen` завершились rc=0.

Контракт совпадает с frozen/157/1; проверенная реализация
`.omp/extensions/spawn-guard.ts` байтово совпадает с `cf4054e8e`. Неизменённая
заплата не объявляется дефектной: блокирует недостаточность новой дельты
батареи для достижимой поддерживаемой формы batch.