accept
OBJECT=885040c10e6e2b831d57274b6495b6d866344df9
СУД: репо=dev-harness; предмет=157; роль=adversary; вызов=6 (узкий, по слову владельца 23.11 — только блок isolated-оракула); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=verdicts/adversary/contracts-157-impl-v5.md (FAIL, архив archive/157/adversary-v5-fail-d8061c901a); класс риска=рисковый

Область: только закрытие блока v5 и названный регресс; это не новый полный суд. Метаданные среды называют фактическую модель, runtime/model-trace.tsv назначает adversary ту же модель. Автор дельты Arch157c, не этот судья. `git diff --stat 9f73d265a 885040c10` — только `fixtures/workshop_project/spawn_guard_157/probe.py`; `git diff 0f33bee8a 9f73d265a` — одна строка комментария в хуке. OBJECT зафиксирован, субъект и проверка не изменялись.

Для запусков заданы `TMPDIR=/tmp/dev-harness-verify/scratch-adv157s`, `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`, `PYTHONDONTWRITEBYTECODE=1`. TMPDIR без `/zones/`, как требует задание.

## Позитивный контроль

`npm run check:spawn-guard-157-family-selftest` на неизменённом OBJECT: rc=0, `KLETKI subject 59 KRASNYH 0`. В том числе `project-isolated-batch-first` зелёная. Событие судится подложной дверью, не настоящей дверью.

## Атака

Дословный стаб v5 (`probe.py:212-238`: удаляет и декларацию `isolated: boolean`, и запись в событие одним якорем): `python3 fixtures/workshop_project/spawn_guard_157/probe.py --mutant drop-isolated` → rc=1, `KLETKI subject 59 KRASNYH 55`; `CASE subject project-isolated-batch-first KRASNO: ('project-isolated-batch-first', 'door did not judge every batch item')`. Четыре клетки без вызова двери остаются зелёными. Это наблюдение закрывает конкретный зелёный обход v5.

Независимые соседние мутации текста хука выполнены без выбора ожидаемой схемы по тексту. Одновременно изменялись декларация и фактически сериализуемое поле: (1) `isolated: boolean` и ключ записи переименованы в `isolation`; (2) тип заменён на `isolated: string`, значение — на `String(o.isolated === true)`. Каждая мутация бралась от исходного OBJECT отдельно; временный исполняемый хук каждого случая создаётся и удаляется самой `run()`; исходное дерево не изменялось. Команда `python3 /tmp/dev-harness-verify/scratch-adv157s/trials.py` → rc процесса 0; напечатанные ниже rc = `int(bool(failed_cells))`, как у `probe.py`, а не код процесса драйвера:

```text
TRIAL drop-isolated rc=1
KLETKI drop-isolated 59 KRASNYH 55
TRIAL rename-field rc=1
KLETKI rename-field 59 KRASNYH 55
FIRST_RED CASE rename-field station-deny KRASNO: ('station-deny', 'door did not judge every batch item')
TRIAL string-field rc=1
KLETKI string-field 59 KRASNYH 55
FIRST_RED CASE string-field station-deny KRASNO: ('station-deny', 'door did not judge every batch item')
```

Для воспроизведения драйвер импортировал `probe.py` через `importlib.util`, читал `source = p.SOURCE.read_text()`, проверял кратность обоих заменяемых фрагментов `== 1`, затем отдельно подавал в `p.run(mutant, name)` следующие замены:

```python
# rename-field
source.replace('; isolated: boolean', '; isolation: boolean').replace(
    '      isolated: o.isolated === true,',
    '      isolation: o.isolated === true,')
# string-field
source.replace('; isolated: boolean', '; isolated: string').replace(
    '      isolated: o.isolated === true,',
    '      isolated: String(o.isolated === true),')
```

Изучен канал выбора схемы: `probe.py:305-312` строит ожидаемое событие из входных item и фиксированных ожидаемых флагов; `probe.py:440-453,473-490` без флагов вызывает `run` с `carries_isolated=True`, а историческую схему выбирает только по двум фиксированным полным commit-id, не по тексту хука. Литерал `ISOLATED_TYPE` используется для якоря мутации, не для ожидаемого события (`probe.py:75,217,243-245`). В испытанной области другого канала самоопределения схемы из текста хука не обнаружено. Типовая аннотация сама по себе стирается Node: проверялась именно наблюдаемая смена типа события, а не семантически эквивалентная смена одной аннотации.

## Регресс

- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs` → rc=0, `STABY 47 NEPOIMANNYH 0`; есть честный контроль актуального хука, после него отдельный стаб `drop-isolated` и остальные изоляционные стабы.
- Тот же временный `trials.py` последовательно вызывал `p.run(p.mutation(source, name), name)` на тексте реального OBJECT (не исторической модели); по одному мутанту, временные миры удалялись после каждого вызова. Процесс драйвера rc=0; ниже rc — вычисленный как у W `int(bool(failed_cells))`, и сырые итоги:

```text
TRIAL n6-constant-five rc=1
KLETKI n6-constant-five 59 KRASNYH 3
RED_CELLS project-batch-n6,project-batch-n7,project-batch-n8
TRIAL n7-odd-middle rc=1
KLETKI n7-odd-middle 59 KRASNYH 2
RED_CELLS project-batch-n7,project-batch-n8
TRIAL n8-even-middle rc=1
KLETKI n8-even-middle 59 KRASNYH 1
RED_CELLS project-batch-n8
TRIAL skip-last-six-plus rc=1
KLETKI skip-last-six-plus 59 KRASNYH 3
RED_CELLS project-batch-n6,project-batch-n7,project-batch-n8
TRIAL first-only rc=1
KLETKI first-only 59 KRASNYH 19
FIRST_RED CASE first-only project-isolated-batch-second KRASNO: ('project-isolated-batch-second', 'door did not judge every batch item')
TRIAL last-only rc=1
KLETKI last-only 59 KRASNYH 19
FIRST_RED CASE last-only project-isolated-batch-first KRASNO: ('project-isolated-batch-first', 'door did not judge every batch item')
```

- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc=0, `MODEL_KLETKI 244 KRASNYH 0` (модель двери, не установленная дверь).
- `bash -n scripts/zamok_predmeta.sh fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh && node --check .omp/extensions/spawn-guard.ts` → rc=0 (синтаксис, не статическая типизация).
- Разрешённый scratch после прогонов удалён; `du -sh "$PWD"` → `153M`.

## Блоки

В пределах назначенного узкого повтора доказанных блоков нет. Конкретный механизм самоопределения, доказанный в v5, закрыт; accept не утверждает полноту безопасности всего стража.

## НЕ ЗАЩИЩАЕТ

Восемь форм путей, принятых остаточным риском контрактом 157, здесь не атакованы по прямой границе задания; строк с ловцом adversary в этом остатке нет. N≥9 остаётся риском, переданным reviewer по коду. Проверка использует подложную дверь; модель 140 не подтверждает работу установленной двери. Отказ инструмента вне PATH, пустой вход и прочие общие классы новой широкой атакой не испытывались: слово владельца ограничило этот вызов конкретным блоком и регрессом.

## Советы

Нет.
