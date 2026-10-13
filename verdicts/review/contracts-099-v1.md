FAIL

Восемь блокирующих находок. Полный список с чекбоксами — `.review/2026-10-13-01.md` (Р1-1…Р1-8,
неблокирующие Н-1…Н-6).

1. Слияние делает красными три ключа CI, которые на main зелёные:
   - `check:ceilings` — Р1-1 [implementer];
   - `check:nabludenia` — Р1-4 [architect];
   - анти-плацебо секция 2: +2 расхождения — Р1-2 [implementer], Р1-3 [architect].
2. Решение 1г2 обходится шагом кандидата до материализации в джобе `ci` (Р1-5). Предъявлено живьём:
   после `git replace` дословная команда материализации отдаёт lane-заглушку, rc 0 при контроле rc 1.
   Клетка л при этом зелёная.
3. Нога производителя из Решения 2 инертна и не имеет красного входа (Р1-6).
4. Один файл лежит вне зоны (Р1-7). Отчёт implementer о регрессии 071 не совпадает с деревом (Р1-8).

# Reviewer 099, круг 1 (гейт перед слиянием)

- **Предмет.** `frozen/contracts/099/1` → коммит `430522ce`. Блоб контракта `aff103f7` одинаков на теге
  и на слиянии.
- **Судимые коммиты.**
  - architect: `c18eacd4` (поверх `430522ce`, база `28eb17fd`).
  - implementer: `9fba3fb2` + `39bf3efa` (база `601b4534`).
  - Адверсарий: `d69e6ab0` (круг 1, BLOCKS) → `94bf98e2` (круг 2, ACCEPT).
- **Клон.** `/tmp/dev-harness-verify/rev099-c1`, одноразовый. SSH-origin в песочнице отсутствует, поэтому
  клон снят с локального дерева с теми же refs. `checkout c18eacd4` + `merge --no-ff 39bf3efa` →
  `2b18cf75`. Worktree сравнения:
  - `rev099-base` — main `94bf98e2`;
  - `rev099-arch` — `c18eacd4`;
  - `rev099-impl` — `39bf3efa`;
  - пробы: `rev099-replace`, `rev099-cellL`, `rev099-a407`.
  После переноса результата всё удалено.

| артефакт на слиянии | блоб |
|---|---|
| scripts/pr_dopusk.sh | 7b7e0ecb |
| scripts/check_sud_model.sh | f2632337 |
| .github/workflows/ci.yml | aba1d0eb |
| roles/orchestrator.md | 80377368 |
| config/ci_parity_exceptions.txt | 77a4a058 |
| fixtures/zashchita_main_099/red_perehodnyj_gheit_perechen.sh | 09a0ee67 |
| NABLIUDENIA_ARCHITECT.md | e356c1e2 |

Новая редакция любого из этих блобов принятие этого вердикта не наследует.

## Сырой вывод (своя мера)

```
$ bash fixtures/_krasnye_099.sh            # слияние 2b18cf75
стаб-пак: 12/12 поймано
— battery_stubs.sh: rc=0
случаев 18, провалено 0
ЗЕЛЕНО: red_huk_task_spavna … ЗЕЛЕНО: red_sud_model_materializatsija   (10 строк ЗЕЛЕНО)
ИТОГ 099: rc=0
RC_099=0
$ ls fixtures/zashchita_main_099/red_*.sh | wc -l
10
# стабы: battery_stubs.sh сам требует total==12 (:368); перечислено 12 строк «пойман» (m9 снят арбитражем, :3)

$ bash fixtures/_krasnye_098.sh | md5sum    # main 94bf98e2 / слияние
40880ed6cdc2f31ebbc93b498c40de99  base rc=1
40880ed6cdc2f31ebbc93b498c40de99  merged rc=1     # 098 не тронут: stdout байт-в-байт

$ npm run -s check:ci-parity               # слияние
workflow-команд: 17 · скриптов в приёмке: 72 · объявленных исключений: 26 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
RC_PARITY=0

$ bash fixtures/_krasnye_022.sh
bash: fixtures/_krasnye_022.sh: No such file or directory      RC_022=127   (Н-1)
$ bash scripts/verify_antiplacebo.sh --scope land_agent         # замена меры 016/022
барьеров: 1 · фикстур: 9 · предъявлено красным повторным прогоном: 9

$ bash fixtures/_krasnye_071.sh
main 94bf98e2:           ОТКАЗ: п3а: rc=0 (ожидался 1) …                    BASE_RC_071=1
слияние:                 ОТКАЗ: само-проверка: toy-мир не зелёный на check:nabludenia rc=1   RC_071=1
implementer 39bf3efa:    ОТКАЗ: само-проверка: toy-мир не зелёный на check:ceilings rc=1     IMPL_TIP_RC_071=1
слияние + маски Р1-4,Р1-1: ОТКАЗ: п3а … ok: п2а…п2д                          SCRATCH2_RC_071=1  (= main)

$ npm run -s check:ceilings
main: потолки в порядке BASE_CEIL=0 · architect: ARCH_CEIL=0
implementer/слияние: FAIL персона …/roles/orchestrator.md: 53265 байт > потолка 51200   rc=1
$ npm run -s check:nabludenia
main: BASE_RC_NAB=0 · implementer: IMPL_TIP_RC_NAB=0 · architect/слияние: FAIL А-407: статус не объявлен rc=1
$ verify_antiplacebo.sh --scope land_agent  (секция 2)
main: расхождений 1 (dokazatelstva_098) · architect: 2 (+zashchita_main_099) · implementer: 2 (+pr_dopusk.sh) · слияние: 3

# Р1-5, проба /tmp/dev-harness-verify/rev099-replace (кандидат подменил scripts/run_ci_lane.sh)
== без replace (контроль A099-M1): материализация восстанавливает
lane: неизвестный ключ: adversary-unknown-099
control rc=1
== с replace, поставленным шагом кандидата ДО материализации
#!/usr/bin/env bash
exit 0
attack rc=0

# клетка л, своя нейтрализация (rev099-cellL)
V0 честный ci.yml               → ЗЕЛЕНО rc=0
V1 ci.yml из 9fba3fb2           → КРАСНО … job antiplacebo, ci  rc=1
V2 base.sha → head.sha          → КРАСНО … job antiplacebo, ci  rc=1
```

## Семь вопросов гейта

1. **Область.**
   - implementer — 12 файлов: 11 по зоне + `config/ci_parity_exceptions.txt` вне зоны (Р1-7).
   - architect от `28eb17fd` — 16 файлов: контракт, `fixtures/zashchita_main_099/*` (13),
     `fixtures/_krasnye_099.sh`, `.omp/extensions/spawn-guard.ts` и процессный
     `NABLIUDENIA_ARCHITECT.md`.
   - c18eacd4 — 2 файла: клетка perechen и NABLIUDENIA_ARCHITECT.md. Зона соблюдена.
2. **Сырой вывод.** Приёмка, 098, parity и стабы у implementer и адверсария подтверждены своей мерой.
   Отчёт о 071 ложный (Р1-8). Живые пробы приёмки 4 не предъявлены (Н-5).
3. **Проверки не переписаны под код.** implementer `fixtures/` и контракт не трогал. Правка клетки
   architect'ом после заморозки (c18eacd4) аддитивна: добавлен вход л, удалено 2 строки комментария.
   Красный предъявлен мной (V1/V2). Вход уже обязательства (Р1-5).
4. **Красное предъявлено.** Вход л — да. Ноги производителя (Решение 2) — нет (Р1-6).
5. **Атомарность.** Соблюдена: implementer 2 коммита (реализация и правка по A099-M1), architect 1.
6. **Норма.** `roles/orchestrator.md` изменён по Решению 7 и ПЕРЕСЕЧЕНИЮ. Содержание совпадает с
   Решениями 6/7, но нарушен потолок (Р1-1). Других нормативных документов дифф не трогает.
7. **Заявленное = сделанное.**
   - «10/10» — 10 по `ls`, 10 строк ЗЕЛЕНО.
   - «12/12» — 12 по счёту стабов и проверке total.
   - «0 расхождений» — 0.
   - «071 п3а, п1/п2а-п2д зелёные» — ЛОЖНО на 39bf3efa (Р1-8).
   - Адверсарий: «новый обход не воспроизведён» — опровергнуто (Р1-5, Н-6).

## Адверсарий круга 2: закрытие A099-M1

Нейтрализация клетки л честная, я воспроизвёл её сам. Поимка конкретной заглушки `exit 0`
показана ручной командой `git checkout`, а не швом workflow. Шов обходится шагом кандидата до
материализации (Р1-5). Поэтому A099-M1 закрыт только для формы атаки «кандидат заменил скрипт», но
не для свойства 1г2 «все шаги исполняются кодом M^1».

## ПРОВОДКА (038)

- guard=`fixtures/_krasnye_099.sh` существует и подключён прямым шагом `ci.yml:231`. Это барьер
  именно этого предмета. Но подключение до лендинга противоречит строке ПРОВОДКА-ЭНФОРСМЕНТ
  (Н-4, вопрос architect).
- role=`roles/orchestrator.md` несёт все пять норм Решений 6/7.
- Поведенческая норма идёт role-каналом, хук З-7 — guard-каналом. Обоснование честное.

## Паразитная сложность (050): пять ответов на артефакт

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель/дубль | класс |
|---|---|---|---|---|---|---|
| scripts/pr_dopusk.sh (+378) | Р1/Р2, З-2…З-6 | API через `PR_DOPUSK_API` и аргумент, refs; явное | 1 (+реестры) | `<корень> --pr N`, 1 env, rc 0/1/2 против 378 строк — глубокий | 6 клеток; переиспользует 071 `--object` и 098 per-name | ESSENTIAL (Р1-2 — шапка) |
| scripts/check_sud_model.sh (+245) | Р4/Р5, З-7/З-8 | читает agent_models.json/трассу по аргументам | 1 | 3 режима, rc 0/1/2 | клетки + нога check_staged | ESSENTIAL |
| config/transition_defects_099.tsv | Р2, З-6 | данные; читается по M^1 | 1 | — | дверь | ESSENTIAL (Н-3) |
| config/transition_producers_099.tsv (0 байт) | Р2 «каждое имя покрыто» | пустая → нога молча выключена | 1 | — | ни одной клетки | Р1-6 |
| land_agent.sh `--pr` (+87) | Р3, З-1 | флаг; явное | 1 | 1 флаг | клетка З-1; 016 без флага цел (9/9) | ESSENTIAL |
| gitw_preflight_071.sh `--object` (+42) | Р1д | флаг; явное | 1 | 1 флаг | pr_dopusk | ESSENTIAL |
| check_staged.sh нога (+35) | Р5 | трасса models_actual | 1 | нет новых флагов | З-8 | ESSENTIAL |
| check_no_leak.sh нога (+66) | Р6, З-9 | нет нового | 1 | нет новых флагов | З-9 | ESSENTIAL |
| ci.yml: 2 шага материализации + шаг 099 | 1г2 + ПЕРЕСЕЧЕНИЕ | нет | ci.yml + exceptions | — | клетка л; parity | ESSENTIAL, порядок — Р1-5 |
| package.json ключ check:zashchita-main-family-selftest | ПЕРЕСЕЧЕНИЕ (ключ = команде шага) | нет | 2 | — | parity | ESSENTIAL |
| ci_parity_exceptions.txt (+2) | оплата шага 1г2 | нет | 1 | — | parity | ESSENTIAL, зона — Р1-7 |
| .omp/extensions/spawn-guard.ts | Р4, хук З-7 | алфавит в одном месте | 1 | 1 обработчик | клетка хука 18/18 | ESSENTIAL |
| семья fixtures/zashchita_main_099 + раннер (один артефакт) | приёмка 1-3 | toy-миры /tmp с вычисткой | — | — | ci.yml:231 | ESSENTIAL (Р1-3 — маркер) |
| roles/orchestrator.md (+23) | Р7 | нет | 1 | — | ПРОВОДКА role | ESSENTIAL (Р1-1 — потолок) |

Находок класса ACCIDENTAL нет. Блокеры выше — нарушения обязательств и барьеров, а не сложность.

## Итог

FAIL. Слияние блокируют Р1-1…Р1-8. Починка по норме 050 (оркестратор раздаёт):

- implementer — Р1-1, Р1-2, Р1-5 (порядок шагов ci.yml), Р1-6 (таблица и отказ на пустой);
- architect — Р1-3, Р1-4, Р1-5 (вход л), Р1-6 (красный вход);
- владелец/architect — Р1-7 (санкция зоны);
- implementer — Р1-8 (перепрогон 071 с сырым выводом).
