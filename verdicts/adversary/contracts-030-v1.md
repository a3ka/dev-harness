# Adversary 030, круг 1 — FAIL

Судья: `adversary` (отдельное семейство). Предмет: замороженный контракт 030/1 (`f7c7ddc`), реализация на `bbe0d4d`.

## Вердикт

**FAIL.** Три приёмочных пробы зелёны на HEAD, но как минимум три неверные реализации проходят соответствующую проверку. Это дефекты проверок, не предмета. До исправления пробы 030 нельзя закрыть `reviewer 030 → done/030`.

## Именованные обходы

### A-030-1 — `hub` выдаётся только тестовому секрету окружения

**Обход =** базовый `TOOLS` не содержит `hub` в реальной ведущей сессии, но добавляет его только при `ZAI_API_KEY=x`. Это нарушает инвариант 1 части 1: базовый инвентарь обязан содержать `hub` безусловно.

Контрреализация `workshop`:

```bash
#!/usr/bin/env bash
set -eu
TOOLS="read,edit,write,bash,grep,glob,lsp,web_search,task,todo"
if [ "${ZAI_API_KEY:-}" = x ]; then TOOLS="$TOOLS,hub"; fi
if [ "${1:-}" = --fable ]; then
  TOOLS="read,grep,glob,bash,web_search,task,todo"
fi
exec omp --tools "$TOOLS"
```

На копии репозитория она прошла:

```text
bash fixtures/workshop_inventory/red_inventar_hub.sh
rc=0
```

При этом построенные внешние варианты `pos`, `k1`, `k2`, `v1`–`v5`, `b1`, `cr` были только «пропущены: инвентарь класса не сошёлся», а не сделали пробу недостоверной. Главный живой запуск тоже принял реализацию, потому что `rt_tree` жёстко назначает `ZAI_API_KEY=x`.

Нейтрализация тестового условия показывает нарушение:

```text
PATH=<каталог-со-стабом-omp>:$PATH ZAI_API_KEY=production ./workshop
read,edit,write,bash,grep,glob,lsp,web_search,task,todo
rc=0
```

В операнде нет `hub`. Значит проверка не отличает постоянный инвентарь от поведения, подогнанного под её собственный sentinel, и разрешает полностью пропустить всю батарею внешних деревьев.

### A-030-2 — QA carve-out работает для `write`, но ломает `edit`

**Обход =** `xd://report_issue` разрешён у непиннованной сессии только в `write` и bash-ветви, а `edit` для той же пары `(xd://report_issue, null)` блокируется. Это нарушает часть 2, инвариант 5: решение для пары путь/пинн одинаково в edit/write-ветви и bash-операндной ветви.

Контрреализация CLI-стража возвращала `pass` только для:

```text
write + xd://report_issue + worktree:null
bash  + tee xd://report_issue + worktree:null
```

и `block` для `edit + xd://report_issue + worktree:null`. Она прошла приёмку:

```text
bash fixtures/qa_kanal_xd/red_kanal_qa_report_issue.sh
rc=0
```

но настоящий запрещённый вход дал:

```text
node .omp/extensions/path-guard.ts --judge \
  '{"tool":"edit","args":{"path":"xd://report_issue"},"worktree":null,"actual":null}'
{"decision":"block"}
rc=0
```

Проба 2/3 называет ветвь «edit/write», но посылает только `tool:"write"`; ни один `edit`-вход carve-out не проверяет. Дополнительно она не требует рабочую factory-регистрацию расширения. Существующий старый `scripts/drill_path_guard.sh` зелёный на HEAD (25 прежних входов), однако не закрывает новую точную QA-границу 030.

### A-030-3 — GC распознаёт константные имена игрушки вместо инварианта

**Обход =** жнец сохраняет только `wip/031/architect`, `wip/030/young23`, `wip/030/no-log`, удаляет/сохраняет остальные ветки по именам и обрабатывает `--wip-grace-hours 3` только для `young23`. Он не вычисляет количество reflog-событий и mtime, поэтому свежая пустая слитая ветка с любым другим именем реапится. Это нарушает часть 3, инварианты 1–4.

Контрреализация прошла фиксированную игрушку:

```text
WORK=/tmp/dev-harness-verify/adv030-gc-work \
BARRIER=/tmp/dev-harness-verify/adv030-gc-stub.sh \
bash fixtures/gc_agent_branches/red_gonka_svezhij_spavn_vyzhivaet.sh
rc=0
```

Отдельный живой репозиторий с одной свежей пустой достижимой веткой подтвердил нарушение:

```text
# main содержит пустой base; wip/999/fresh только что создана от main
/tmp/dev-harness-verify/adv030-gc-stub.sh --root <repo>
fresh merged wip/999/fresh was reaped
rc=0
```

Фикстура жёстко пинует все имена и возраста одной игрушки. Она не повторяет сценарий с новым именем/новым расположением и потому принимает зашитую константу вместо требуемого вычисления по reflog.

## Позитивный контроль и обязательные классы

На честном HEAD все три замороженные предъявления зелёные:

```text
bash fixtures/workshop_inventory/red_inventar_hub.sh                 rc=0
bash fixtures/qa_kanal_xd/red_kanal_qa_report_issue.sh              rc=0
bash fixtures/gc_agent_branches/red_gonka_svezhij_spavn_vyzhivaet.sh rc=0
```

Проверены дополнительные классы:

* отказ не принят за успех: страж `process.exit(1)` дал у QA-пробы `BAD_JSON`, `rc=1`;
* инструмент вне `PATH` не принят за успех: при node-free `PATH` QA-проба выдала `NOT_IMPLEMENTED: нет node`, `rc=2`;
* пустой вход GC (`--root` без `wip/*`) дал ожидаемый нулевой реап (`ЗАВИСШИХ ВЕТОК НЕТ`, `rc=0`), не маскируя предъявленную ветку;
* правильный ответ не на тот вопрос выявлен A-030-2 (`write` проверен вместо требуемой симметрии `edit/write`);
* нейтрализация выявлена A-030-1 и A-030-3.

## Прогоны заморозки и окружения

```text
git diff --exit-code frozen/contracts/030/1 HEAD -- contracts/030-*.md
rc=0

bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness
основной чекаут чист
rc=0

bash scripts/drill_path_guard.sh
ok real: 25 предъявлений judge ... верны; фабрика регистрирует tool_call handler ...
rc=0

bash scripts/verify_antiplacebo.sh --scope gc_agent_branches
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7
rc=0
```

Попытка буквально включить в `--scope` все три названия из задания дала:

```text
bash scripts/verify_antiplacebo.sh --scope qa_kanal_xd workshop_inventory gc_agent_branches
FAIL scope_select отказал (код 1)
rc=1
```

Причина воспроизводима из `scope_select.sh`: `qa_kanal_xd` и `workshop_inventory` — легальные `.probe-only` каталоги, не ключи барьеров; единственный допустимый scoped-ключ этой пачки — `gc_agent_branches`. Это наблюдение не отменяет FAIL: scoped anti-placebo не является проверкой трёх приёмочных проб.

## Требуемая правка автора

1. В пробе hub сделать зависимость `hub` от тестового окружения невозможной: проверять как минимум два непредсказуемых/контрастных значения окружения либо убрать тестовый credential sentinel; пропуск всей заявленной батареи внешних деревьев должен быть `rc=2`, не зелёным.
2. В QA-пробу добавить `edit` точного `xd://report_issue` у непинна → `pass` и симметричные граничные `edit`-входы; также проверять factory-путь расширения для нового carve-out.
3. В GC-пробе породить второй свежий пустой достижимый WIP с новым, непредсказуемым именем и независимым worktree/mtime; повторить на нём default/N/fail-closed свойства так, чтобы имя не могло быть константой.

После этих правок требуется новый adversary-прогон. Вердикт не является `accept` и не закрывает норму.
