accept

СУД: repo=dev-harness; предмет=143; фаза=контракт — закрытие находки Critic143 v4 `0817e26ed` (scoped вызов 6); роль=critic; вызов=6/6 (сверх капа 5 по слову владельца 2026-11-09 ~13:04 UTC через консультанта: ровно вызов 6, строго scoped к finding 0817e26ed — новый критерий исполняет настоящий шаг sel, сверяет GITHUB_OUTPUT с selection, именованно отвергает второй writer `matrix=`/hardcoded matrix после честного селектора; повтор той же причины — стоп, седьмой вызов запрещён); модель-план=zai/glm-5.3; сессия=Critic143ScopedSixth; модель-факт=zai/glm-5.3 (workstation; совпадение семейства с автором отказом не является — контракт 166, §Независимость); SHA=49b27bdf79d9b671785c116d7d47a6d7bcff5973 (tip `wip/143/architect`, сверен до вызова); предыдущий=FAIL `verdicts/critic/contracts-143-v4-fail.md` (commit 0817e26ed, OBJECT b0ee5335b); исключение=нет. Оговорка §Счёт: записи СУД до вызова на достижимых ref (origin/main, все heads/worktrees) нет — санкция владельца зеркалена в задании судьи дословно и повторена здесь; оркестратору отразить строку в HANDOFF.

## Область и дельта

OBJECT `49b27bdf7` = merge `d53958817` (red cell 762625345 + v3 0205e323d) и `a40676325` (v4 на main). Дельта к отклонённому кандидату v4 `b0ee5335b` — ровно закрытие находки: `contracts/143-mob-ci-razdelenie.md` (+11: абзац закрытия `:325`, вторая строка приёмки `:341`, пулет second-writer `:342`, числа 21/14/21 в `:343`, ЗАЩИЩАЕТ v4 `:348`), `matrix_v3.py` (+45: `selector_output_case` — исполнение фактического run-блока sel, стаб `matrix-second-writer`, счётчики +8/+15), `matrix_inventory_v4.py` (пин продукта `88e9cc8`, режим `--second-writer`), `model/matrix-select-v3.cjs`/`matrix-aggregate-v3.cjs` (union v3-файлов из 49271a91d/5abc05c0e, существующая семья mob_ci_143 — новых семей и ЗОНА-строк нет, precision-gate основания нет). Все пути в ЗОНА architect `:165`; probe.py не тронут (подстрочная проба осталась предусловием, производство проверяет новая клетка). Н-39 соблюдён: привязка стаба — код matrix_v3.py, контракт несёт инвариант `:325` и rc-команды `:340`–`:343`.

## Исполняемые проверки — сырой вывод (клон /tmp/dev-harness-verify/Crit143V6/repo, detached OBJECT)

```
$ bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md        # rc 0
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
КРИТИК: дверь зелёная
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model           # rc 0
  … КЛЕТКА selector-output ЗЕЛЕНА … клеток 21, зелёных 21, красных 0; клеток 80, зелёных 80
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs           # rc 0
  СТАБ matrix-second-writer @ selector-output КРАСЕН: MATRIX_OUTPUT_WRITERS: 2
  стабов 14, привязок 21, живых 0; клеток 80/80; стабов 62, привязок 78, непойманных 0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Impl143v3/mob   # rc 0
  … КЛЕТКА selector-output ЗЕЛЕНА … клеток 11, зелёных 11, красных 0; клеток 79, зелёных 79, красных 0
$ python3 fixtures/workshop_project/mob_ci_143/matrix_inventory_v4.py --product /tmp/dev-harness-verify/Impl143v3/mob          # rc 0 (внутренний rc 1)
  клеток 11: 10 зелёных, 1 красная (MATRIX_DAG); клеток 79: 74 зелёных, 5 красных
  y01/y02/i02/i04: MATRIX_OUTPUT_REQUIRED; i03: выходы […] ≠ канон […] (нет выхода работнику: ['matrix'])
$ python3 …/matrix_inventory_v4.py --product …/Impl143v3/mob --second-writer    # rc 0 (внутренний rc 1)
  КЛЕТКА selector-output КРАСНА: MATRIX_OUTPUT_WRITERS: 2; 11: 10 зелёных, 1 красная; 79: 79 зелёных, 0 красных
$ bash scripts/check_zones.sh <корень OBJECT-клона>                             # rc 0
  только ok-строки; итог: замороженных контрактов: 158 · объявленных авторов: 5 · коммитов в диапазонах: 49409 · проверено по зонам: 12295
$ bash scripts/check_threat_model.sh <корень> contracts/143-mob-ci-razdelenie.md # rc 0
  секция валидна (ЗАЩИЩАЕТ 11, НЕ ЗАЩИЩАЕТ 10)
```

## Red-before и атаки критика (одноразовые копии продукта 88e9cc8; diff каждой — одна правка)

Red-before (та же мутация второго писателя, что у обёртки):
```
$ git -C repo checkout b0ee5335b; <копия+echo 'matrix={"include":[{"screen":{"id":"podmena"}}]}' >> "$GITHUB_OUTPUT" после честного вызова>
$ bash …/red_mob_ci_143.sh --repo mutant-before        # rc 0 — ЛОЖНАЯ ЗЕЛЕНЬ (10/10 + 79/79): находка 0817e26ed воспроизведена на родителе
$ git -C repo checkout 762625345
$ bash …/red_mob_ci_143.sh --repo mutant-before        # rc 1 — КЛЕТКА selector-output КРАСНА: MATRIX_OUTPUT_WRITERS: 2
```
Красная клетка закоммичена ДО merge (762625345, «red cell preserved»), в OBJECT дожила.

Мои мутации против красного (батарея OBJECT, каждый вход — отдельная копия):
```
A  v4-дословная атака, строка ВНУТРИ блока `} >> "$GITHUB_OUTPUT"`:  rc 1 — selector-output КРАСНА: MATRIX_OUTPUT_WRITERS: 2 (11: 10/1; 79: 79/0)
B  второй шаг с тем же id: sel, дописывающий matrix=:               rc 1 — selector-output КРАСНА: MATRIX_SEL_STEP_COUNT (11: 10/1; 79: 75/4 — четыре клетки probe-клаузулой)
C  единственный пишущий лжёт (скрипт эмитит podmena, selection.json честен):  rc 1 — selector-output КРАСНА: MATRIX_OUTPUT_DIVERGENCE (+ selector: MATRIX_OUTPUT_ABSENT)
D  согласованно лгущий скрипт (selection.json и эмиcсия оба podmena):         rc 1 — selector-output КРАСНА: MATRIX_OUTPUT_DIVERGENCE
```

Мутации оракула (только в клоне, после каждой — restore, дерево чисто):
```
O1  убрать счётчик писателей (len(emitted)!=1):   --stabs rc 1 — STAB_ZHIV matrix-second-writer @ selector-output — механизм закреплён красным
O2  убрать независимое ожидание (== expected):    --stabs rc 0, --model rc 0 — нога не закреплена (совет 1)
O3  убрать счётчик sel-шагов (len(steps)!=1):     --stabs rc 0, но вход B всё равно rc 1 четырьмя клетками probe — клаузула закреплена однократно (совет 2)
```

## Механические сверки — полным списком

1. `:340` honest `88e9cc8`: rc 0, матричные 11/11 (включая selector-output на настоящем run-блоке), продуктовые 79/79 без красных, инвентарные y01/y02/i02/i04 зелёны внутри 79 — наблюдено.
2. `:341` обёртка без флага: rc 0 ⇔ внутренний rc 1; 11: 10/1 (MATRIX_DAG); 79: 74/5; четыре клетки поимённо MATRIX_OUTPUT_REQUIRED, i03 — канон выходов — наблюдено дословно.
3. `:342` `--second-writer`: rc 0 ⇔ внутренний rc 1; `MATRIX_OUTPUT_WRITERS: 2`, остальные матричные 10/10, продуктовые 79/79 — наблюдено; «два шага с id: sel краснят selector-output причиной MATRIX_SEL_STEP_COUNT» — наблюдено (атака B).
4. `:343` `--model`/`--stabs` rc 0; 21/21 = прежние 20 + selector-output; v2 80/80; 14 субъектов/21 привязка/0 живых (= len(STUBS)+8/+15); legacy 62/78/0 — наблюдено.
5. Пин продукта `88e9cc8` в обёртке (PRODUCT_REVISION_UNEXPECTED иначе) — сверен: HEAD продуктового клона 88e9cc8, дерево чисто.
6. check_zones: rc 0 (только ok, итоговая строка; логика выхода — fails==0). check_threat_model rc 0 (11/10).
7. КЛАСС РИСКА `:3` и ЗОНА-строки `:165`–`:169` не менялись; новых ЗОНА-строк и новых семей case-файлов в дельте нет — precision-gate не запускался за неимением основания.
8. Расхождений счётных утверждений `:340`–`:343` с живыми прогонами нет.

## Закрытие находки 0817e26ed

ОБЯЗАТЕЛЬСТВО: `:325` — ровно один писатель matrix в фактическом GITHUB_OUTPUT шага sel, последнее значение = matrix той же selection.json = независимому ожиданию; `:348` — исполнение фактического шага на --repo. НАБЛЮДЕНИЕ закрытия: на родителе b0ee5335b та же мутация проходила всю батарею rc 0 (наблюдено выше), в OBJECT — rc 1 именованной причиной во всех вариантах класса (дописанная строка внутри блока и после, второй sel-шаг, а также оба варианта лжи селектора — DIVERGENCE); честный 88e9cc8 остаётся rc 0; механизм закреплён красным (O1 → STAB_ZHIV). Закрывающее свойство из v4 (исполнение run-блока по образцу connected_v3 + именованный отказ двух входов + честный rc 0) исполнено полностью; «в четырёх клетках» из черновика свойства заменено центральной клеткой selector-output — суть (rc 1 именованной причиной, честный rc 0) соблюдена, реализация не предписывалась.

## Советы (не блокируют)

1. СОВЕТ matrix_v3.py `selector_output_case` — нога независимого ожидания (`== expected`, демо-карта на двух экранах) не закреплена красным: O2 проходит --stabs/--model rc 0; вход «согласованно лгущий скрипт» ловится только целым оракулом (моя атака D). Закрыть стабом/входом обёртки по усмотрению автора.
2. СОВЕТ там же — клаузула `MATRIX_SEL_STEP_COUNT` закреплена однократно (вход B отвергается и probe-клаузулой len(sel)==1 из v4; O3 проходит --stabs rc 0). Родственен С-1 v4; глубина защиты есть, пин по усмотрению.
3. СОВЕТ §Счёт — записи СУД вызовов 4–6 в HANDOFF на достижимых ref нет (найдена только 3/5); санкция вызова 6 зеркалена в задании судьи и в этой строке СУД выше — оркестратору дописать по форме.

## Вывод

Scope вызова 6 исчерпан: finding 0817e26ed закрыт исполнением настоящего шага sel, тройной сверкой GITHUB_OUTPUT ↔ selection.json ↔ независимого ожидания и именованным отказом второго писателя во всех исполненных вариантах; red-before доказан (ложная зелень на родителе → красная клетка 762625345 → OBJECT), честный продукт rc 0, --model/--stabs rc 0 с точными числами, check_zones/check_threat_model rc 0, зоны и замороженные поверхности не тронуты. Блокирующих находок нет; советы выше едут с accept. Повторной причины для FAIL нет — седьмой вызов не требуется.
