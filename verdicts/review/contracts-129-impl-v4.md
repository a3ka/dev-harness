accept
OBJECT=7200e248c2e150147cffdbca0edbe947915798f3
СУД: repo=dev-harness; предмет=129; фаза=реализация (правка наблюдателя батареи, круг 2, scoped); роль=reviewer; вызов=2 (scoped-исправительный по санкции оркестратора, AGENTS.md шаг 7); модель=anthropic/claude-opus-5-5 (тир audit); сессия=Rev129V2; SHA=7200e248c2; предыдущий=Rev129V1 FAIL (verdicts/review/contracts-129-impl-v3.md, OBJECT 20c352f82b, блок Б-1); исключение=санкция scoped.

Резюме. Б-1 закрыт по существу. Адаптер теперь требует только `status`, то есть ровно то, что читает наблюдатель; `id` и `agent` не читаются ни в адаптере, ни в `judge`. Мутант id→name судится зелёным. Совет С-1 взят: словарь статусов и форма yield перенесены в адаптер, их дрейф даёт rc 2 с названием поля. Ложной зелени дельта не добавляет: она добавляет только отказы. Клетки и стабы не ослаблены. Батарея на станции с omp 18.18.8 зелёная во всех режимах, `--ext ''` красный по контракту. Блоков нет. Три совета (С-2 перенесён, С-3, С-4) записаны в `.review/2026-11-16-02.md` (status: ready).

КЛАСС РИСКА: обычный (`registry/risk-legacy.tsv`, слово владельца 2026-11-16, подтверждён Rev129V1). Дельта касается только наблюдателя стенда, повышать класс не нужно.

## Находки

- **С-3 — совет.** В `battery.py:182` `STATUS_VALUE` нет значения `merge failed`. Это настоящее значение omp 18.18.8: в бинаре (`result-summary.ts`, `iw()`) `e.aborted ? "cancelled" : e.exitCode === 0 && e.error ? "merge failed" : e.exitCode === 0 ? "completed" : \`failed (exit ${e.exitCode})\``. Ребёнок стенда запускается с `isolated: True`. Зонд → `('rc2', 'формат omp изменился: status=merge failed')`: значение неизменённого omp названо изменённым форматом. Исход — rc 2 вместо FAIL rc 1, ложной зелени нет. Живьём это не достигается: ребёнок не пишет файлов. Поэтому совет.
- **С-4 — совет.** Ни одно из изменений дельты не закреплено в `--parser`. Три мутанта дают `--parser` rc 0 «parser=15 red=0»:
  - откат Б-1;
  - удаление проверки `STATUS_VALUE`;
  - мягкий `read_yield`.

  На 18.18.8 субъект при этих мутантах тоже зелёный. Регресс пройдёт все закоммиченные проверки. Совет: добавить три случая `parser_cases` с привязкой к наивным стабам.
- **С-2 — совет, перенос из вызова 1.** Не тронут. Ветвь `max_child_turns` живьём не покрашена.
- Н-1 — наблюдение. `STATUS_VALUE` проверяет статус каждого блока `<task-result>`, в том числе соседа, хотя наблюдатель читает статус только того блока, что несёт M129. Блоком по Б-1 это не считаю: `status` наблюдатель читает, а форма события едина для всех экземпляров, и сдвиг словаря у соседа — это сдвиг формата omp. Зонд: у соседа `status="aborted"` → `('rc2', 'формат omp изменился: status=aborted')`.

## По пунктам задания

**(1) Б-1 закрыт.**
- `TASK_RESULT_NEED = ('status',)`.
- В `judge` (`:242-266`) нет ни одного обращения к `id` или `agent`. Из адаптера `judge` получает только `(status, body)`, `read_yield` берёт из тела `model`.
- Зонды (`probe.py`, через `_outcome`):
  - `id->name` → None (зелёное);
  - без id и agent → None;
  - `agent->role` → None;
  - `status->outcome` → `('rc2', 'формат omp изменился: status')`.
- Docstring соответствует коду.

**(2) Принцип владельца.**
- Grep по каталогу `fallback_subagent_129/`: строки с id omp (`Child129-…`, `(?:-\d+)?`, `a.get('id')`) встречаются только:
  - в тестовых транскриптах `_tr`/`parser_cases`;
  - в наивных стабах `stub_po_id`, `stub_po_prefiksu_id`, `stub_molchit_na_formate`, `_blocks`;
  - в комментариях.
- На пути суда (`resolve_child` → `judge` → `read_yield`) id нет.
- Знание формата omp собрано в адаптере: `read_task_results` (тег, `status`, словарь) и `read_yield` (форма yield). Константы `TASK_RESULT_*`/`STATUS_VALUE`/`YIELD_JSON` стоят рядом с ними.

**Компромисс STATUS_VALUE (fail-closed против ложной зелени).** Словарь только добавляет отказы. Мутант mB, удаляющий проверку, возвращает прежнее поведение: `startswith`, при сдвиге FAIL rc 1. Значит, ложной зелени словарь внести не может. Цена — честное новое значение в соседней версии omp. Например, `status=Completed` → rc 2, и стенд перестаёт судить, пока не обновлён адаптер. Это прямо требует принцип владельца «нераспознанный формат → rc 2». Это лучше, чем угадывать: `startswith('completed')` судил бы новое значение вроде `completed (merged)` наугад. Словарь измерен живьём, и в источнике 18.18.8 есть ровно четыре формы: три измерены, `merge failed` нет (см. С-3). Живой `--stabs` (13 пар) и субъект/модель (12 клеток) прошли без единого rc 2: все живые статусы входят в словарь. `failed (exit 137)` судится как failed, `\d+` покрывает любой код. Подход принимаю. Единственная неточность — пропущенное значение источника (С-3, совет).

**(3) Не ослаблено.** Своя мера — python по `source.json`, `parser_cases()` и `cells(am)`, а не вывод батареи: stubs 11, pairs 13, parser_cases 15, kills 13, naive 5, cells 6. В дельте `parser_cases`, `source.json` и стабы не менялись (`git diff 20c352f82b 7200e248c2 --name-only` → только `battery.py`). Проверка «нет маркера стенда в ответе ребёнка» не удалена: её поглотил `YIELD_JSON`, который требует `"marker": "M129"` прямо перед `"model"`. Это строже прежнего, и мутант mC подтверждает, что прежняя форма мягче.

**(4) Независимый прогон на станции.** Ниже: клон `/tmp/dev-harness-verify/Rev129V2` (ssh://git@github.com/a3ka/dev-harness.git, checkout OBJECT = origin/wip/129/architect), omp/18.18.8.

**(5) Область правки.**
- `git diff 20c352f82b 7200e248c2 --name-only` → `fixtures/workshop_project/fallback_subagent_129/battery.py`. Это внутри ЗОНЫ architect: `git show frozen/contracts/129/2^{commit}:contracts/129-fallback-subagent.md | grep ^ЗОНА` → `ЗОНА architect: contracts/129-fallback-subagent.md fixtures/workshop_project/fallback_subagent_129/`.
- `git diff --stat 20c352f82b 7200e248c2 -- contracts .omp …/source.json …/model` → пусто.
- Blob контракта на OBJECT совпадает с тегом: 6a23c8a8.
- Один коммит (`rev-list --count` = 1), автор `architect <architect@dev-harness.local>`, ссылка на предмет 129. Атомарно.
- `git merge-tree --write-tree origin/main(3e1e5941) HEAD` → rc 0, без конфликтов.

## Сырой вывод

```
HEAD=7200e248c2e150147cffdbca0edbe947915798f3 omp=omp/18.18.8 which=/home/harness/.local/bin/omp
=== battery.py
ok c1-zhivoj-perehod … ok c6-zapasnaja-validacija (6 ok)
cells=6 red=0
rc=0
=== battery.py --model
(6 ok)
cells=6 red=0
rc=0
=== battery.py --parser
ok pr1 … ok pr15 (15 ok)
parser=15 red=0 stub_checks=13 caught=13
rc=0
=== battery.py --ext ''
ok c1-zhivoj-perehod
FAIL c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: <output> [stub-zai/glm] 429 [1310][…][stub129 M129] …
ok c3-zdorovyj-primary
ok c4-validacija-soseda
ok c5-vse-ischerpany
FAIL c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: <output> [stub-zai/glm] 429 [1310][…][stub129 M129] …
cells=6 red=2
rc=1
=== battery.py --stabs
caught s1-bez-cepochki in c1-zhivoj-perehod: ребёнок failed (exit 1), ожидался completed: …
caught s2-tolko-sessija in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s2-tolko-sessija in c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: …
caught s3-na-ljuboj-oshibke in c4-validacija-soseda: ребёнок завершил на модели gpt-sol, ожидалась glm
caught s4-tot-zhe-provajder in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s5-ta-zhe-model in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s6-vsegda in c3-zdorovyj-primary: ребёнок завершил на модели gpt-sol, ожидалась glm
caught s7-cikl in c5-vse-ischerpany: нет результата с маркером M129
caught s8-lokalnoe-sostojanie in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s9-oba-ischerpany in c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: …
caught s10-fb-ne-v-cooldown in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s10-fb-ne-v-cooldown in c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: …
caught s11-krome-ischerpannoj-zapasnoj in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
stubs=11 pairs=13 uncaught=0
rc=0
=== battery.py --subject /nonexistent
NOT_IMPLEMENTED: у субъекта /nonexistent нет config/agent_models.json
rc=2
=== PATH без omp (env PATH=/usr/bin:/bin)
NOT_IMPLEMENTED: нет omp в PATH — стенд без реального omp не судит
rc=2
=== зонды (probe.py; judge через _outcome; None = зелёное)
honest-18.18.8                             -> None
id->name                                   -> None
id+agent dropped                           -> None
agent->role                                -> None
status->outcome                            -> ('rc2', 'формат omp изменился: status')
status=done                                -> ('rc2', 'формат omp изменился: status=done')
status=merge failed (omp 18.18.8 iw())     -> ('rc2', 'формат omp изменился: status=merge failed')
status=failed (exit 137)                   -> None
status=Completed (case)                    -> ('rc2', 'формат omp изменился: status=Completed')
yield-yaml                                 -> ('rc2', 'формат omp изменился: yield')
yield-model-before-marker                  -> ('rc2', 'формат omp изменился: yield')
yield-wrong-model                          -> 'ребёнок завершил на модели gpt-sol, ожидалась fam-f'
sibling status drift only                  -> ('rc2', 'формат omp изменился: status=aborted')
=== мутанты кода, --parser (копии вне клона)
mA revert Б-1: NEED=(id,agent,status)                rc=0 parser=15 red=0 stub_checks=13 caught=13
mB drop STATUS_VALUE check                           rc=0 parser=15 red=0 stub_checks=13 caught=13
mC read_yield lenient (model anywhere, no refusal)   rc=0 parser=15 red=0 stub_checks=13 caught=13
mD NEED=() (status optional)                         rc=1 KeyError: 'status'
=== своя мера
stubs 11 pairs 13 / parser_cases 15 kills 13 naive 5 / cells 6
=== omp 18.18.8, источник статуса (strings бинаря, result-summary.ts iw())
const r = e.aborted ? "cancelled" : e.exitCode === 0 && e.error ? "merge failed" : e.exitCode === 0 ? "completed" : `failed (exit ${e.exitCode})`;
```

## Красное предъявлено

- `--ext ''` → rc 1, «cells=6 red=2» (c2, c6) — как в контракте.
- Все 13 пар `--stabs` красные.
- Новые отказы дельты краснеют на зондах: status=done, status→outcome, yield-YAML и yield в обратном порядке → rc 2 с названием поля.
- В дереве новые отказы не закреплены (С-4, совет). Требованием accept вызова 1 это не было.

## Паразитная сложность (050), по артефактам дельты

- **`TASK_RESULT_NEED` сужен до `('status',)`.**
  - (1) Требование: адаптер требует ровно то, что читается (слово владельца; Б-1).
  - (2) Состояния нет.
  - (3) Одно место.
  - (4) Интерфейс сузился.
  - (5) Потребитель — `read_task_results`. ESSENTIAL, сложность убавилась.
- **`STATUS_VALUE` + отказ `status=<значение>`.**
  - (1) Требование: «нераспознанный формат → rc 2» (слово владельца 2026-11-16).
  - (2) Состояние явное: строка отказа называет значение.
  - (3) Новое значение статуса — правка одной константы.
  - (4) Интерфейс адаптера не изменился.
  - (5) Потребители — `judge` через адаптер и живой прогон. Грамматику не дублирует: `startswith` в `judge` — это ожидание клетки, а не формат. ESSENTIAL. Более простая форма (без словаря) возвращает ложный FAIL вместо rc 2 и нарушает слово владельца.
- **`YIELD_JSON` + `read_yield`.**
  - (1) Требование то же. Форму yield рисует omp.
  - (2) Состояние явное: отказ `yield`.
  - (3) Число мест не выросло: две регулярки в `judge` свернулись в одну функцию адаптера.
  - (4) Одна функция, body → model.
  - (5) Потребитель — `judge`. ESSENTIAL.

## ПРОВОДКА (038)

Канал контракта — role-строка orchestrator «батарея на станции с omp до land, вызов и rc строкой в задание судьи». Строка в задании есть, мой независимый прогон приведён выше. Guard — сама батарея, барьер этого предмета. Дельта ПРОВОДКУ не меняет.

## СВЕРКА-СТАНДАРТОВ

Неприменимо: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` / `docs/CODING-STANDARDS.md` (grep по `AGENTS.md` клона на OBJECT пуст).

## Итог

accept на OBJECT 7200e248c2. Принятие не наследуется другой редакцией `battery.py`: если architect возьмёт С-3 или С-4, это новый кандидат, и затронутый путь предъявляется судье заново.
