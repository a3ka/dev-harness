# СДАЧА 143 v6 — lane-дельта пяти операций 216

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-143-v5.md

База: `5e5a274c35750f8f29319f39bae43780af1446db`, v5, PR станции #1141.
Предыдущая фаза v5 принята Crit143V5b на `180352174bc136f35e3f57bc780e1d4eaa610d84`;
v6 не исправительный круг того FAIL и не новый номер. Задание с уточнением
приёмки разрешает только lane-дельту; прежний критерий общего rc 0 R216 снят
оркестратором ДО этой пачки. Текст v5 сохранён, зона frozen143/4 не расширена.
Н-39: стабы привязаны кодом `lane_v6_acceptance.py`, не прозой контракта.

## Двери

- pre-critic · bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md · 0 · 0
- provodka · bash scripts/check_provodka.sh . contracts/143-mob-ci-razdelenie.md · 0 · 0
- battery-model · bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model · 0 · 0
- battery-stabs · bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs · 0 · 0
- battery-syntax · bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --syntax · 0 · 0

## Карта классов

- К-01 · чисто · вход: пять команд дверей выше; форма прежнего контракта/ПРОВОДКА сохраняется, нового CI step нет · - · -
- К-02 · чисто · вход: уточнение задания; 163 A/B; 216 fa6678d216; PR #1141/#283/#252; 165 моба read-only, чужая реализация не добавлена · - · -
- К-03 · чисто · вход: исходные каноны 141/995 не правятся, полный --repo R остаётся rc 1 с точным перечнем, 197/3 не меняется · - · -
- К-04 · чисто · вход: только contracts/143-mob-ci-razdelenie.md и fixtures/workshop_project/mob_ci_143/; канон 216 захвачен в nositeli с постоянным SHA256 · - · -
- К-05 · чисто · вход: контракт v6 приёмка 1–5 — команды prepare, --repo R, inline --repo, model/stabs/syntax и двери со своими rc · - · -
- К-06 · чисто · вход: повреждённый оракул/запуск/таймаут драйвера — rc 2; предметный несовпавший route/body остаётся rc 1 своей клетки · - · -
- К-07 · чисто · вход: реальный npm/dispatcher/bash/selector в MATRIX_SEL_RUN; реконструкция compatibility.py216 предъявлена реальной 216, 23 CASE OK · - · -
- К-08 · чисто · вход: --stabs запускает 88 новых адресных негативных привязок, затем все прежние matrix/legacy стабы без снятия клеток · - · -
- К-09 · чисто · вход: демаркация И-20 — inline либо bounded canon пяти lanes; 11 собственных положительных ветвей, маршрут/тело/dispatcher/lifecycle/cwd/env/name/id имеют отдельные негативные пары · - · -
- К-10 · чисто · вход: selector-output сверяет единственный matrix GITHUB_OUTPUT, selection.json и независимый ожидаемый выбор; полный --repo R rc/поимённый остаток сохранены · - · -
- К-11 · чисто · вход: nositeli/lanes-216.json SHA256 e502c44d93bd93e090ba4e2be80462bfc753a961af10dd0efc310f37b8831511 проверяется до чтения субъекта; expected не перечитывается с диска R · - · -
- К-12 · чисто · вход: YAML safe_load + структурный прежний sweep; script сравнивается с каноном, без парсера bash/JS; синтаксис AST/bash -n/node --check · - · -
- К-13 · н/п · новые секретные входы не вводятся; PILOT_DEMO_CODE и прежняя защита неизменны · - · -
- К-14 · чисто · вход: split set -eu + set -o pipefail зелён на каждой lane-ветви; inline fda1fc871960b8061d8e6f6d12f2cc38f5834cee зелён 396/396 и 79/79 · - · -
- К-15 · чисто · вход: stdout --model/--stabs и --repo R ниже; 11 ветвей перечислены LANE_CELLS, негативные привязки считает код, остаток RESIDUAL не выводится из субъекта · - · -
- К-16 · чисто · вход: риск health-required не снижен; общий rc 0 R216 не обещан, ловец исходного остатка Critic/Reviewer216 явно назван · - · -
- К-17 · н/п · продуктовые API/БД/операции188 не меняются; тестовый транспорт пяти существующих CI-операций · - · -

## Дельта

- К-03 · граница · fixtures/workshop_project/mob_ci_143/lane_v6_acceptance.py --model · 0 · 0
- К-08 · канон/инструмент · fixtures/workshop_project/mob_ci_143/lane_v6_acceptance.py --stabs · 0 · 0

Способ — канон/инструмент: новые bodies/маршруты сравниваются с одной
иммутабельной моделью 216, затем используются прежние предметные клетки.
Нового самописного оракула формата нет. Остаток по 141/995 — граница,
разрешённая уточнением задания; это НЕ снятие красных полного --repo.
Таблица клетка → защита → форма — контракт И-20; привязки стаба → ветвь
исполняются только кодом. Исторический шов 143/197 v5 не меняется.

## Воспроизведение честного R

Рабочий pwd:
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t7a75072ca/m`.
Все прогоны: `TMPDIR=/tmp/dev-harness-verify/scratch-arch143` (без /zones/).
SSH clone моба отказал Repository not found; read-only gh API подтвердил
`fa6678d2163b5c96e5a8a5f71a194c8a7c4e4e79`. Полный одноразовый клон с
собственным .git получен HTTPS через gitw и credential helper gh; push нет.
Доставка WORKTREE из задания не использовалась как cwd.

`lane_v6_acceptance.py --prepare <mobile-git> <R>` исполняет тот же порядок,
что compatibility.py216: clone --no-hardlinks --no-checkout → checkout
`55d9be4484bf058d655a2eef6b558ab21d9393d9` → b.model(generated,b.oracle()) →
наложение generated в R → настоящий run.sh216 --repo R --base полного SHA.
Ни исходный mobile clone, ни источник продукта не меняются. Контроль rc 0,
вывод — 23 CASE OK (revision/node/identity/selection/events/inventory/dispatcher).
`--capture` воспроизводит nositeli/lanes-216.json только при совпадении
оригинального SHA256; чужие frozen-пины не перепинируются.

Inline-контроль — отдельный clone того же mobile-git с checkout
`fda1fc871960b8061d8e6f6d12f2cc38f5834cee`; ни GIT_DIR/GIT_WORK_TREE aliases,
ни эксперименты в основном чекауте не использовались.

## Сырые результаты и замеры

КРАСНОЕ-ДО — измерение предыдущего Architect143 из задания (повторно не
запускалось для подтверждения): v5 на честном R — 405/397/8 и 79/69/10, rc 1.
Lane-дельта там: selector шаги2/3, build шаги3/7, selector-output MATRIX_SEL_RUN,
y01/y02/y16/i02/i04/i05. Прочие красные — исходный внешний остаток.

ЗЕЛЁНОЕ-ПОСЛЕ lane-дельты — свежий полный --repo R из этой пачки (9.19 с;
повтор через исправленный драйвер точного остатка — 11.46 с вместе с парами):

```
КЛЕТКА legacy КРАСНА: LEGACY_JOB_CHANGED
КЛЕТКА workflow-quality-run-step-3 КРАСНА: WORKFLOW_CONTROL_workflow-quality-run-step-3
КЛЕТКА workflow-quality-run-step-6 КРАСНА: WORKFLOW_CONTROL_workflow-quality-run-step-6
клеток 405, зелёных 402, красных 3
клеток 79, зелёных 75, красных 4
КЛЕТКА y12-avd-namespace: e2e-first-run без PORT КРАСНА
КЛЕТКА y13-odin-uroven-vosstanovlenija: e2e-first-run: маркеров ПОВТОР 0, канон 1 КРАСНА
КЛЕТКА y23-ispolnenie-povtora: e2e-first-run: нет шага с веткой повтора (ПОВТОР: в run) КРАСНА
КЛЕТКА p01-P-nabor: нет checkout .harness до шага запуска maestro_probe.py — P не исполняется этим workflow КРАСНА
RC 1
RESIDUAL_EXACT legacy,p01-P-nabor,workflow-quality-run-step-3,workflow-quality-run-step-6,y12-avd-namespace,y13-odin-uroven-vosstanovlenija,y23-ispolnenie-povtora
LANE_DELTA_GREEN 11
LANE_CONTROLS 11 NEGATIVE_BINDINGS 88
```

Драйвер L --repo R rc 0 — только точный остаток плюс честные и отрицательные
пары. Внутренняя полная батарея по-прежнему rc 1, что видно строкой RC 1.
Первая версия самого драйвера имела неверные полные имена y12/y13 и ждала
положительные legacy-строки, которые CLI не печатает: вернула rc 1
RESIDUAL_MISMATCH при уже правильном предмете. Исправлена проверка, не продукт:
legacy-положительные ветви теперь исполняются явно. Повтор rc 0 выше.

Свежий inline --repo (10.35 с):

```
клеток 396, зелёных 396, красных 0
клеток 79, зелёных 79, красных 0
```

rc 0. Свежий --model rc 0 (23.98 с):

```
LANE_CONTROLS 11 NEGATIVE_BINDINGS 0
клеток 397, зелёных 397, красных 0
модель-197 (lane-транспорт): клеток 5, зелёных 5, красных 0
клеток 80, зелёных 80, красных 0
модель-197 (lane-транспорт): клеток 79, зелёных 79, красных 0
```

Свежий --stabs rc 0 (58.37 с), прежние census не изменены:

```
LANE_CONTROLS 11 NEGATIVE_BINDINGS 88
стабов 413, привязок 422, живых 0
стабов 66, привязок 82, непойманных 0
```

Новые bindings отдельно добавлены, не включены задним числом в исторические
413/422 и 66/82. Честный эквивалент каждого lane проходит перед мутациями.
`--syntax` rc 0: `SYNTAX_143_OK`. Двери листа запускаются ниже через check_sdacha;
фактический итог прогонов/sha — доклад сдачи, не заранее выдуманный вывод.

## Граница и процесс

rc 0 на R 216 требует отдельного согласования канона 141/995 (вне v6;
ловец — Critic/Reviewer 216, внешний остаток). Зоны architect неизменны;
freeze и owner-строка не создавались; live CI продукта не выдаётся за
локальный replay. Новых процессных Н-записей в wip не заведено: журнал А-NN
разрешён только коммитом main, вне выданной зоны; передаточное наблюдение
оркестратору — исходный общий rc 0 смешивал lane-дельту с внешним остатком,
уточнение задания разделило эти два обещания до этой пачки.

## Итог обязательных дверей

`check_provodka.sh . contracts/143-mob-ci-razdelenie.md` — rc 0.
`pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md` — rc 0,
110.35 с, `КРИТИК: дверь зелёная`.
`check_sdacha.sh . contracts/143-mob-ci-razdelenie.md --run` — rc 0,
100.08 с: `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=2)`.
Это фактические прогоны, не ожидаемые коды. Ряды дверей после них неизменны.
Импортные bytecode-кэши, созданные прямым shebang-прогоном листа, удалены;
драйвер запрещает их повторное создание. Дерево TMPDIR удаляется перед сдачей.
