accept
OBJECT=3859873d49d59209948c8eb0f907208d55023fc2
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; адверсарий не вызывался — frozen 182/1)
СУД: repo=dev-harness; предмет=182; фаза=реализация (перед слиянием PR #726); роль=reviewer; вызов=2/2 (scoped-повтор после FAIL вызова 1); сессия=Rev182v2 (харнесс-сессия c907157c); модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; автор=implementer minimax/MiniMax-M3; контракт=frozen/contracts/182/1 (tag d3bb84c0, commit 9681a6cb); кандидат слияния=origin/wip/182/orchestrator f907b999fe600f08245c877d2253dfc5793796c8 (PR #726); батарея=origin/wip/182/architect 23b6a6dafe5a2245bb9af569616226f0162d1f0f (PR #760); предыдущий=verdicts/review/contracts-182-impl-v1.md

# Вердикт reviewer — 182 «Срез «где мы по плану» после перезапуска», реализация, вызов 2/2

## Итог

Реализация **допускается** к слиянию через PR #726.

- **Р-1 закрыт.** `scripts/orch_plan_slice.sh` разбирает ROADMAP только внутри единственного
  generated-блока. Если маркеров нет, их больше одного или порядок перевёрнут — отказ
  `PLAN_ROADMAP_RASHOZHDENIE` с rc 1 и пустым stdout.
- **Регресса нет.**
  - батарея architect: 11/11 и 5/5;
  - мои 13 миров дают ожидаемое;
  - живой срез по origin/main сходится с моей независимой мерой: 108 строк, 0 расхождений;
  - гейты на дереве PR #726 зелёные.
- **Р-3 закрыт** (причины отказа названы раздельно).
- **Р-4 остаётся советом.**
- **Р-2 закрыт батареей architect.** Это вне ОБЪЕКТА; см. условие слияния в Р-5.

Scoped-повтор, а не полный суд заново: проверены закрытие Р-1, отсутствие регресса и пункты (1)–(5)
задания.

## Объект и кандидат

```
git fetch origin wip/182/implementer wip/182/orchestrator wip/182/architect wip/182/reviewer
origin/wip/182/implementer  = 3859873d49d59209948c8eb0f907208d55023fc2  (== OBJECT)
origin/wip/182/orchestrator = f907b999fe600f08245c877d2253dfc5793796c8  (PR #726)
origin/wip/182/architect    = 23b6a6dafe5a2245bb9af569616226f0162d1f0f  (PR #760)
origin/main                 = 8aff93c7e763126ba1e9104b3329b1aae5742547
merge-base(OBJECT, main) = merge-base(PR, OBJECT) = 98f9f7b77fbfcfb18f403197361c430e118c52ff
git log main..OBJECT:
  3859873d implementer 182: разбор ROADMAP только из generated-блока, отказ при структурной ошибке
  6e678dc7 implementer 182: норма роли — срез плана после успешного brief (roles/orchestrator.md)
  6dab594f implementer 182: CLI-срез плана из опубликованного origin/main
git log main..PR: f907b999 orchestrator (CI + regen), dfa70949/e5150e5f/970fb8ab implementer
git range-diff 98f9f7b77..OBJECT 98f9f7b77..dfa70949 → три пары, различие только строкой
  «(cherry picked from commit …)» в сообщениях
git diff --stat 3859873d dfa70949 → пусто, rc=0 (деревья OBJECT и третьего коммита PR совпадают)
blob scripts/orch_plan_slice.sh: OBJECT == dfa70949 == PR == f4114c4d6847
blob roles/orchestrator.md:      OBJECT == dfa70949 == PR == 7e30197fe05e
```

## Чем проверял

Прогоны мои, в одноразовом клоне `/tmp/dev-harness-verify/Rev182v2/repo`. Вывод сокращён до
значимых строк, rc приведены полностью.

### (1) Батарея architect против дерева реализации

Дерево: OBJECT + `git checkout origin/wip/182/architect -- fixtures/workshop_project/plan_restart_182/`.

- `red_plan_restart_182.sh --repo .`:
  - GREEN published, frozen, pause, done, roadmap, no-stale, local-isolation, structural,
    source-mismatch, missing-generated-block, outside-generated-block;
  - `CELLS=11 GREEN=11`, **rc=0**.
- `--stabs`:
  - 11× GREEN;
  - `STAB handoff caught: no-stale`, `STAB stale caught: no-stale`, `STAB local caught: local-isolation`,
    `STAB no-roadmap caught: roadmap`, `STAB head caught: published`;
  - `STABS=5 CAUGHT=5`, **rc=0**.
- `--model`: `CELLS=11 GREEN=11`, **rc=0**.

**Красное.** Тот же `--repo .` с `scripts/orch_plan_slice.sh` из `6e678dc7` (до исправления; блоб
`be649424f28c` — тот же, что у FAIL-объекта v1 6670235d6):

```
RED missing-generated-block: rc=0 stdout='PLAN_SNAPSHOT: origin/main=49095238…\nPLAN: 147 | ROADMAP=3/'
RED outside-generated-block: rc=0 stdout='PLAN_SNAPSHOT: origin/main=3a352122…\nPLAN: 147 | ROADMAP=3/'
CELLS=11 GREEN=9
rc=1
```

Барьер E/F краснеет на сломанной реализации и зеленеет на исправленной.

### (2) Мои миры

Throwaway `worlds.py` лежит вне репозитория. Каждый мир — свежий bare-origin и клон. Источники —
реальные `registry/plan.tsv`, `ROADMAP.md`, `registry/pauzy.tsv`, `registry/contracts.tsv` с
origin/main 8aff93c7; затем одна мутация. Мутируемый id — первая строка плана, `082`.

| мир | OBJECT rc | stdout | stderr (причина) | до исправления (6e678dc7) rc |
|---|---|---|---|---|
| honest (без мутации) | 0 | 109 строк (SNAPSHOT + 108 PLAN) | — | 0 |
| **E** ROADMAP без обоих маркеров, таблица цела | **1** | пуст | `generated-блок ROADMAP отсутствует или повреждён (маркеры BEGIN/END не по одному или перевёрнуты)` | **0 (109 строк)** |
| **F** строка 082 только в таблице до BEGIN | **1** | пуст | `нет строки generated-блока ROADMAP: 082` | **0 (109 строк)** |
| ровно два BEGIN | 1 | пуст | `generated-блок … отсутствует или повреждён …` | **0** |
| два END | 1 | пуст | то же | 1 |
| BEGIN после END (маркеры переставлены) | 1 | пуст | то же | **0** |
| только BEGIN, END удалён | 1 | пуст | то же | **0** |
| пустой блок (между маркерами ничего) | 1 | пуст | `нет строки generated-блока ROADMAP: 082` | 1 |
| строка 082 перенесена после END | 1 | пуст | `нет строки generated-блока ROADMAP: 082` | 1 |
| строка plan.tsv из 5 полей | 1 | пуст | `строка plan.tsv не из шести полей: 082` | 1 |
| id 082 без записи в contracts.tsv | 1 | пуст | `нет записи в registry/contracts.tsv: 082` | 1 |
| этап в plan ≠ этапу в блоке | 1 | пуст | `plan.tsv расходится с generated-блоком ROADMAP: 082` | 1 |
| A: локальный неопубликованный коммит (+строка `999 local` в plan) и локальный annotated `done/contracts/082/1`; HEAD b500ec50 ≠ origin/main 4bd5c87e | 0 | 109 строк, SNAPSHOT=origin/main | — | 0 |

Во всех отказах (rc=1):

- `stdout_lines=0`;
- одна строка stderr с префиксом `PLAN_ROADMAP_RASHOZHDENIE:`; вторая обобщённая строка из v1 (Р-3) больше не печатается.

В мире A — ровно одна строка 999, опубликованная: `PLAN: 999 | ROADMAP=3/до V-2 | STATUS=черновик`.
Строки `local` в срезе нет; `done082=False`, потому что локальный тег не подтверждает статус.

Пять миров были зелёными до исправления: E, F, два BEGIN, BEGIN после END, только BEGIN. Все пять
теперь дают отказ.

Дополнительно проверил граничный случай: строка plan.tsv из шести пустых полей → rc=1, stdout
пуст. Находки нет.

### Honest — живой срез

Команда: `bash impl/scripts/orch_plan_slice.sh --repo <клон>` (origin = github a3ka/dev-harness).
Своя мера — `measure.py` (throwaway): `git fetch --tags` + `git tag --merged origin/main`. Это другой
механизм, чем `ls-remote`+`rev-list` у CLI. Плюс `pauzy.tsv` с origin/main и приоритет
done > ПАУЗА > frozen > черновик.

```
cli_rc=0 stdout_lines=109 stderr=''
cli_first=PLAN_SNAPSHOT: origin/main=8aff93c7e763126ba1e9104b3329b1aae5742547
expected_snapshot=… match=True
rows_expected=108 rows_got=108 mismatch=0
status_counts=done:64 frozen:12 ПАУЗА:9 черновик:23
ZHDYOT_lines=0
```

Здесь rows_expected — моя мера, rows_got — вывод CLI. Сверены id, `пара/этап` и STATUS по каждой
строке. Девять строк ПАУЗА несут условие возврата из pauzy.tsv дословно, например
`PLAN: 116 | … | STATUS=ПАУЗА | NEXT=до 153 (freigabe-kvittancija)`.

### (3) Область правки

- **Дифф исправления.** `git diff --stat 6e678dc7 3859873d` → `scripts/orch_plan_slice.sh | 61 +++++----`, 1 файл, +47 −14.
- **Почему от 6e678dc7, а не от 6670235d6.** Объекта 6670235d6 на origin больше нет: ветку перебазировали, `git fetch origin 6670235d6` → «couldn't find remote ref». Эквивалентность доказана блобами: `6e678dc7:scripts/orch_plan_slice.sh` = `be649424f28c`, `6e678dc7:roles/orchestrator.md` = `7e30197fe05e`. Это те же блобы, что v1 записал для 6670235d6. Значит, дифф 6670235d6..3859873d по файлам предмета — только `scripts/orch_plan_slice.sh`. Остальное в полном диффе — сдвиг базы main 74da5935 → 98f9f7b77, не работа implementer.
- **`roles/orchestrator.md` не менялась.**
  - `git diff --quiet 6e678dc7 3859873d -- roles/orchestrator.md` → rc=0;
  - норма-строка ПРОВОДКИ (contract:142) дословно: `grep -cF` → 1 в `roles/orchestrator.md` (OBJECT) и 1 в `.omp/agents/orchestrator.md` (PR).
- **Implementer не трогал фикстуры и контракт.** `git log 98f9f7b77..PR -- fixtures/ contracts/` → пусто. Батарею E/F/HEAD добавил architect своим коммитом 23b6a6da в своей ветке.
- **Атомарность.** Исправление — один коммит, один файл, сообщение «182: …».

### (4) Гейты на дереве PR #726 (f907b999)

- `bash scripts/check_ceilings.sh .` → «потолки в порядке», **rc=0**.
- `bash scripts/check_provodka.sh . contracts/182-plan-posle-perezapuska.md` → **rc=0**.
- `node scripts/gen-harness.ts --check` → «харнес соответствует roles/ (12 ролей)», **rc=0**.
- `bash scripts/gen_ci_steps.sh --check` → **rc=0**.
- CI-шаг: `registry/ci-steps.tsv:303 step check:plan-restart-182-family-selftest 4 … --repo . && … --stabs && bash -n scripts/orch_plan_slice.sh`, `ci-zamery.tsv:105 … 4 8 0`.
- Регресс по батареям:
  - PR со своей (frozen v1) батареей: `CELLS=9 GREEN=9`, rc=0;
  - PR с батареей architect: `CELLS=11 GREEN=11`, rc=0;
  - `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` на PR: rc=0.
- Режим проекта (996): `check_project_sources.sh --repo . --contract contracts/182-plan-posle-perezapuska.md --stage done` → rc=0 на HEAD=f907b999 (PR) и на HEAD=3859873d (OBJECT).
- Слияние с текущим main: `git merge-tree --write-tree origin/main origin/wip/182/orchestrator` → rc=0, конфликтов нет; main ушёл на 1 коммит. Для `…/architect` — тоже rc=0.

### (5) Р-3 / Р-4

- **Р-3 закрыт.** Исполнением в мирах (2) причины отказа раздельны:
  - «не из шести полей»;
  - «нет строки generated-блока»;
  - «расходится»;
  - «нет записи в registry/contracts.tsv»;
  - структурная ошибка блока.

  При rc 1 у awk обобщённая вторая строка больше не печатается (`:230-237`).
- **Р-4 — совет, без изменений.** Ни эта правка, ни правки architect его не касаются: `:121` по-прежнему собирает все строки блока, а `:198-201` сверяет только строки плана. Исполнением не перепроверял: дифф эту логику не трогает. Это вне буквы И-1.

## Проверки роли

1. **Область правки.**
   - OBJECT против вызова 1 — только `scripts/orch_plan_slice.sh` в ЗОНЕ implementer; путь тот же, что v1 сверил по `zones_match_path`.
   - Норма роли не тронута.

   — соответствует.
2. **Сырой вывод.** Выше; вывод автора не переиспользовал. — соответствует.
3. **Проверки не подогнаны.** Фикстуры правил только architect (23b6a6da, вне ОБЪЕКТА); implementer их не касался. — соответствует.
4. **Красное предъявлено.**
   - Батарея E/F на реализации до исправления: `GREEN=9/11`, rc=1.
   - Мои миры: 5 из 12 мутаций были зелёными до исправления, теперь все дают rc=1.
   - Гейты проводки и gen:harness на OBJECT без PR-обвязки по-прежнему красны: `check_provodka` rc=1 «guard не подключён», `gen-harness --check` rc=1. На PR они зелёные. `check_ceilings` на OBJECT теперь rc=0: база 98f9f7b77 уже несёт потолок 73728.

   — соответствует.
5. **Атомарность.** Три коммита implementer по одному на шаг, каждый со ссылкой «182:». Коммит orchestrator — отдельно. — соответствует.
6. **Норма не тронута молча.** `roles/orchestrator.md` в исправлении не менялась. — соответствует.
7. **Заявленное = сделанное.**
   - «11 клеток / 5 стабов» — мой прогон: 11/11 и 5/5.
   - «108 строк» — моя мера: 108 = 108, 0 расхождений.
   - «47+/14−, 1 файл» — `diff --stat` ✓.
   - «отказ `PLAN_ROADMAP_RASHOZHDENIE` при структурной ошибке» — миры E, два BEGIN, два END, BEGIN после END, только BEGIN ✓.

## Находки

- [x] **Р-1 (вызов 1: блок) — ЗАКРЫТ.** Как устроено теперь (`scripts/orch_plan_slice.sh:98-133`):
  - маркеры считаются точным сравнением строки;
  - при `nb != 1 || ne != 1 || bl >= el` разбор завершается с кодом 3, и CLI отвечает `die "PLAN_ROADMAP_RASHOZHDENIE: generated-блок ROADMAP отсутствует или повреждён …"`;
  - строки вне `inblock` не разбираются.

  Обязательства frozen 182/1 И-1 (сверка с одноимённой строкой generated-блока) и И-4 (структурная ошибка — именованный отказ) выполнены. Доказательство — миры E/F и четыре структурных мира выше, плюс клетки architect.
- [x] **Р-2 (вызов 1: совет architect) — закрыт вне ОБЪЕКТА.** В 23b6a6da `world()` делает локальный коммит поверх origin/main. Мутант `head` пойман клеткой `published` (`STAB head caught: published`).
- [x] **Р-3 (совет) — закрыт.** См. (5).
- [ ] **Р-4 (совет; вне буквы И-1; адресат — владелец/architect).** Лишняя строка в блоке и иной порядок строк блока отказа не дают. Без изменений против v1.
- [ ] **Р-5 (условие слияния для оркестратора; не находка против implementer).**
  - Сливать только через PR #726. Отдельно OBJECT красен по `check_provodka` и `gen-harness --check` (п. 4 проверок роли).
  - Клетки E/F и стаб `head` живут в PR #760 (architect), а не в PR #726. CI-шаг 182 на дереве #726 гоняет frozen-v1 батарею 9/9; закрытие Р-1 охраняется в CI только после слияния #760.
  - С батареей #760 дерево #726 даёт 11/11, rc=0 (п. 4); оба PR сливаются с main без конфликтов.
- [ ] **Р-6 (совет; 050; адресат — implementer, не блокирует).**
  - Фрагмент: `:128-133` и `:230-237`. Код 3 отделяет структурную ошибку от «прочего сбоя awk». Вторая ветвь (`не разобран generated-блок`, `не собран срез`) срабатывает только при аварии самого awk, и ни одна строка приёмки её не требует.
  - Более простая форма: один `die` на любой ненулевой код разбора блока. [INFERENCE] Она проходит те же строки приёмки, потому что вторая ветвь достижима только при аварии awk; простую форму я не прогонял.
  - Отсутствующего свойства нет, поэтому это совет, не блок.

## Паразитная сложность (контракт 050) — по артефактам диффа исправления

- **Проверка единственности блока (`:99-127`, ветвь `exit 3`).**
  1. Свойство: И-1 (только generated-блок), И-4 (структурная ошибка — отказ).
  2. Состояние: счётчики маркеров внутри awk; наружу выходит только rc и названная причина в stderr; побочных файлов нет.
  3. Совместных правок: 1 файл, плюс клетки architect.
  4. Глубина: интерфейс не вырос — те же `--repo` и rc 0/1/2, новых env и флагов нет.
  5. Потребители — клетки `missing-generated-block` и `outside-generated-block`. Грамматику маркеров повторяет `P84_RM_BEGIN/END` из `scripts/lib_plan.sh:36-37`: строки совпадают байт-в-байт, повтор унаследован от v1 (совет v1 п. 050/5).

  → **ESSENTIAL.**
- **Раздельные причины в `fail()` и ветвь `slice_rc` (`:176-183`, `:196-202`, `:230-237`).**
  1. Свойство: И-4 «именованный отказ», плюс совет Р-3.
  2. Состояние явное — stderr.
  3. Совместных правок: 1 файл.
  4. Интерфейс не растёт.
  5. Потребитель — человек-читатель отказа, строки приёмки сверяют только префикс.

  → ESSENTIAL для разделения причин. Ветвь «прочий rc» — ACCIDENTAL-мелочь без блока (Р-6).

## ПРОВОДКА (контракт 038)

- **guard.** `scripts/orch_plan_slice.sh` подключён шагом CI 182; `check_provodka` rc=0 на PR. Guard по-прежнему барьер именно этого предмета.
- **role.** Строка дословна (см. (3)).
- **ПРОВОДКА-ЭНФОРСМЕНТ.** Формат блока guard теперь доказывает полностью — оговорка v1 «кроме Р-1» снята.

— соответствует.

## Режим проекта (контракт 996)

`check_project_sources.sh --stage done` → rc=0 на текущих HEAD: OBJECT 3859873d и кандидата f907b999.

## СВЕРКА-СТАНДАРТОВ

Неприменимо: `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`. Без изменений против v1.

## Мобильный экран

Неприменимо.

## Применимость accept

Accept привязан к блобу `scripts/orch_plan_slice.sh` = `f4114c4d6847` и `roles/orchestrator.md` =
`7e30197fe05e`; эти блобы одинаковы в OBJECT 3859873d, dfa70949 и PR f907b999. Любая правка этих
блобов, а также поведения, критерия или заявленной границы риска делает этот accept неприменимым.
