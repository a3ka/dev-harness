accept
OBJECT=27cd1700402ddec361963f0b2f71809e5a3e4826
КЛАСС=doc/role (КЛАСС РИСКА: обычный — подтверждён; дельта трогает только CI-проводку: registry/ci-steps.tsv, registry/ci-zamery.tsv, .github/workflows/ci.yml)
СУД: repo=dev-harness; предмет=188; фаза=реализация (v2); роль=reviewer; вызов=2 (scoped-исправительный повтор по Б-1 вызова 1); модель-план=anthropic/claude-opus-5-5 (тир audit); сессия=Rev188V2b; модель-факт=anthropic/claude-opus-5-5; автор дельты=orchestrator (27cd170040); контракт=frozen/contracts/188/2; PR #994 (wip/int-188/implementer); предыдущий=Rev188V2 FAIL (OBJECT cde1eb8b0e, Б-1) + verdicts/review/contracts-188-impl-v1.md (accept, OBJECT 3e2dff82a7); бюджет ревьюера исчерпан (1 полный + 1 scoped)

# Вердикт reviewer — 188 v2, реализация, вызов 2 (scoped по Б-1)

Находки: `.review/2026-11-16-02.md`. Файл лежит в клоне `/tmp/dev-harness-verify/Rev188V2b/.review/` и не закоммичен: задание запрещает push и запись в общий чекаут, вердикт оформляет оркестратор.

| Класс | Находка | Чья зона |
|---|---|---|
| — | Б-1 вызова 1 ЗАКРЫТ: guard 188 подключён, `check_provodka 188` rc 0 | orchestrator |
| Наблюдение | Н-3: режимы `--repo .` и `--stabs` в строке шага машинно не удерживаются | architect/owner (038), не дельта 188 |
| Наблюдение | Н-4: строка `4 8 0` в ci-zamery — шаблон, а не замер (CI: 0 с) | orchestrator/owner, конвенция дерева |
| Наблюдение | Н-5: `check_ci_weights` rc 1 на main из-за чужих ключей 118/123 | orchestrator, было до предмета |
| перенос | С-1, Н-1, Н-2 вызова 1 дельта не касается | как в вызове 1 |

Блокирующих находок нет.

Клон: `/tmp/dev-harness-verify/Rev188V2b`, источник только `ssh://git@github.com/a3ka/dev-harness.git`, checkout OBJECT, свой `.git`. Рабочие деревья: `.git/wt-prev` — cde1eb8b0e, `.git/wt-main` — origin/main b3b7ff81ad. Мои инструменты: `/tmp/dev-harness-verify/Rev188V2b-tools/{mut.sh,provall.sh}`. Коммитов я не создавал.

## Кандидат и подлинность

```
$ git rev-parse HEAD origin/main origin/wip/188/implementer-int1116
27cd1700402ddec361963f0b2f71809e5a3e4826
b3b7ff81ade178aa9a15443e0e8969c2dd34bf6a
27cd1700402ddec361963f0b2f71809e5a3e4826
$ git log -3 --format='%H %an <%ae> / %cn <%ce> P=%P'
27cd1700… orchestrator <orchestrator@dev-harness.local> / orchestrator <orchestrator@dev-harness.local> P=cde1eb8b0e…
cde1eb8b0e… orchestrator … P=b3b7ff81ad… 1adddb10af…
$ gh pr view 994 → head=27cd1700402ddec361963f0b2f71809e5a3e4826 state=OPEN mergeable=MERGEABLE commits=1adddb10af,cde1eb8b0e,27cd170040
```

## (1) Дельта и область правки

```
$ git diff --numstat cde1eb8b0e 27cd170040
6	6	.github/workflows/ci.yml
1	0	registry/ci-steps.tsv
1	0	registry/ci-zamery.tsv
$ git show frozen/contracts/188/2:contracts/188-roli-po-arhitekture.md | grep 'ЗОНА orchestrator'
80:ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
```

Дельта — ровно эти три пути, и все они входят в ЗОНУ orchestrator 188/2. Автор коммита — orchestrator. ПЕРЕСЕЧЕНИЯ соблюдены:
- 083 и др. по `ci-steps.tsv`: добавлена одна строка шага 188, чужие строки не тронуты (+1/−0).
- 114 по `ci-zamery.tsv`: добавлен один замер 188 (+1/−0).
- 002…996 по `ci.yml`: изменён только сгенерированный блок lanes.

Своя мера по `ci.yml`, другой командой: собрал мультимножество `keys:` по lanes до и после.

```
cde1eb8b0e keys= 153 dups= []
27cd170040 keys= 154 dups= []
$ diff keys-cde1eb8b0e keys-27cd170040
70a71
> check:roles-architecture-188-family-selftest
$ (строки diff ci.yml вне `keys:`) → rc=1 (нет таких)
```

Ключи по lanes только перераспределены, добавлен один ключ 188 в lane l4, дублей нет. Посторонних правок в `ci.yml` нет: файл совпадает с генерацией.

```
$ bash scripts/gen_ci_steps.sh --check   → rc=0
$ bash scripts/gen_ci_steps.sh --write   → rc=0
$ git status --porcelain | wc -l          → 0
```

Запуск чекера в CI (для сведения): job `legkij` выполнил `check:zones` на этом head и завершился SUCCESS. Локальный `bash scripts/check_zones.sh` по всей истории не уложился в 600 с, поэтому как свидетельство не засчитан. Мера зоны здесь своя: numstat против строки ЗОНА.

## (2) Шаг подключён, вызывает guard 188 в обоих режимах и действительно что-то проверяет

```
registry/ci-steps.tsv:310
step	check:roles-architecture-188-family-selftest	4	bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --repo . && bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --stabs
```

Строка выполняет требование контракта (стр. 188 §CI-проводка): `step` вызывает `red_roles_architecture_188.sh --repo .`, а не внутренний `probe.py`. Guard — батарея именно предмета 188, а не произвольный скрипт из дерева.

Точную команду шага я исполнил так же, как `run_ci_lane.sh:65`, через `bash -c "$cmd"`.

```
STEP rc=0 ms=93
CELLS=22 GREEN=22
STABS=13 CAUGHT=13
GREEN_LINES=22 CAUGHT_LINES=13 ZHIV=0
```

Та же команда на ролях main (`.git/wt-main`, b3b7ff81ad) краснеет:

```
GREEN implementer-glm/pair
CELLS=22 GREEN=1
step-on-main rc=1
```

Значит, против нереализованных ролей шаг даёт красное, а по `&&` до `--stabs` дело не доходит.

В CI PR #994 (run 43857790839, job l4, SUCCESS) шаг действительно выполнялся:

```
+ bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --repo . && bash …/red_roles_architecture_188.sh --stabs
CELLS=22 GREEN=22
STABS=13 CAUGHT=13
замер: check:roles-architecture-188-family-selftest 0
```

Мутации делал каждую в отдельном worktree от OBJECT (`Rev188V2b-tools/mut.sh`). Для изоляции г1 весов в копию TSV добавлены замеры двух чужих ключей без замера, подробнее в Н-5.

```
MUT baseline    provodka rc=0 | gen--check rc=0 | weights rc=0 «ok: веса по замеру: 113 ключей»
MUT cmd_true    provodka rc=1 «guard не подключён: …red_roles_architecture_188.sh не вызывается…» | gen--check rc=1 «команда вне грамматики: true» | weights rc=0
MUT no_stabs    provodka rc=0 | gen--check rc=0 | weights rc=0      ← Н-3
MUT no_repo     provodka rc=0 | gen--check rc=0 | weights rc=0      ← Н-3
MUT commented   provodka rc=1 «guard не подключён» | gen--check rc=1 (diff lanes) | weights rc=0
MUT step_gone   provodka rc=1 «guard не подключён» | gen--check rc=1 (diff lanes) | weights rc=0
MUT lane_gone   provodka rc=0 | gen--check rc=1 (diff l4)           ← ручная правка ci.yml ловится генератором
MUT zamer_gone  weights rc=1 «нет замера: check:roles-architecture-188-family-selftest»
MUT weight_52   gen--check rc=1 | weights rc=1 «вес не по замеру: check:roles-architecture-188-family-selftest (реестр 52, замер 4)»
```

Итог по пункту:
- Подключение проверяется по-настоящему: если подменить команду на `true`, закомментировать строку или удалить её, `check_provodka` краснеет.
- Если выкинуть `--stabs` или `--repo .`, `check_provodka` остаётся зелёным. Причина в устройстве `guard_is_wired` (`scripts/check_provodka.sh:369–455`, контракт 038): он ищет имя скрипта как слово и режимы не различает (см. Н-3).
- На OBJECT оба режима есть, это видно исполнением и в логе CI.

Вес и замер согласованы: в реестре вес 4, в ci-zamery замер 4 (`4\t8\t0`). Отношение 1 ≤ 3, г2 `check_ci_weights` в изоляции даёт rc 0 на 113 ключах, покрытие и дрейф ловятся (zamer_gone, weight_52). Сама цифра замера своей мерой не воспроизводится (см. Н-4).

## (3) `check_provodka 188` rc 0 на новом SHA, без подгонки

```
$ bash scripts/check_provodka.sh . contracts/188-roli-po-arhitekture.md → rc=0
$ git diff --stat 'frozen/contracts/188/2^{commit}' HEAD -- contracts/188-roli-po-arhitekture.md fixtures/workshop_project/roles_architecture_188 → (пусто) rc=0
$ git diff --stat cde1eb8b0e 27cd170040 -- roles .omp/agents fixtures contracts → (пусто) rc=0
```

Контракт и батарея на OBJECT побайтно равны тегу 188/2. Ни ПРОВОДКА, ни оракул не подгонялись.

Мутация role-канала: удалил литерал 188 из `roles/implementer-glm.md` (DROP: «Обнаружив расхождение модели и работы, создай находку командой `node tooling/checks/cli.js…»).

```
MUT role_literal_glm provodka rc=1 :: проводка: норма-строка не найдена в role-файле: roles/implementer-glm.md
```

Role-каналы по-прежнему судятся, и зелёный цвет даёт не только guard.

Регресс ПРОВОДКИ по всем контрактам, cde1eb8b0e против OBJECT (`Rev188V2b-tools/provall.sh`):

```
CHANGED contracts/188-roli-po-arhitekture.md base=1 obj=0
CONTRACTS=137 SAME=136 CHANGED=1
RED_OBJ (и base=1): 061, 078, 084, 094, 095, 097, 098, 116, 148, 150, 152, 154, 165, 168, 184 — все красны и до дельты
```

Дельта изменила только 188, с красного на зелёный. Ни один контракт не покраснел.

## (4) Пункты (1)–(6) вызова 1 не нарушены

`git diff cde1eb8b0e 27cd170040 -- roles .omp/agents` пуст. Область implementer (16 путей, коммит 1adddb10af), тексты ролей, производные `.omp/agents`, батарея и контракт не менялись. Поэтому замеры вызова 1 переносятся без изменений:
- своя мера COORDS=21 OK=21, пара glm body_equal;
- удаления 21/21 EXACT;
- потолки, `check:gen`, 998 role_pair_glm.

Статус находок вызова 1:
- Атомарность: коммит orchestrator 27cd170040 ссылается на предмет 188 и Б-1 и не содержит ничего, кроме проводки.
- Норма: нормативные документы не тронуты.

## (5) CI PR #994 на head 27cd170040 (для сведения, не гейт)

run 43857790839:
- SUCCESS: klass, legkij (включая check:zones), obshchij, ap1–ap5, l2, l3, l4 (включая шаг 188), l5, l6, l7;
- SKIPPED: vorota;
- IN_PROGRESS на момент вердикта: l1.

## Находки

- **Н-3 (наблюдение, не дельта 188).** Режимы guard в строке шага держит только текст реестра и суд. Ни `check_provodka`, ни `gen_ci_steps --check` их не проверяют: мутации no_stabs и no_repo дают rc 0 у обоих. Это свойство механизма 038 (подключение по имени) и общее для всех семей, например 186. ПРОВОДКА 188 и стр. 188 контракта выполнены. Если владелец захочет удерживать режимы машинно, это отдельный предмет для architect.
- **Н-4 (наблюдение, конвенция дерева).** Строка `check:roles-architecture-188-family-selftest\t4\t8\t0` перенесена из v1 (0b5a387d) и не является измерением.
  - В CI шаг занял 0 с (`замер: … 0`, l4), локально 93 мс; заявленные «медиана 4 по 8 наблюдениям» своей мерой не воспроизводятся.
  - Та же форма `4 8 0` есть ещё у 7 строк, всего строк с окном 0 — 33. Например, у `check:architecture-door-187` тоже `4 8 0` при 0 с в CI.
  - Единственный потребитель, `check_ci_weights`, строку сейчас принимает.
  - После пересъёмки `measure_ci_weights` вес 4 против замера 0 даст г2 «вес не по замеру» (4 > 3·1).
  - Свойства контракта 188 строка не нарушает, поэтому не блок.
- **Н-5 (наблюдение, было до предмета).** `bash scripts/check_ci_weights.sh` даёт rc 1 «нет замера: check:erstinformation-118-family-selftest check:sverka-maketa-123-family-selftest» одинаково на main b3b7ff81ad, на cde1eb8b0e и на OBJECT.
- **С-1, Н-1, Н-2 вызова 1** дельта не касается, они переносятся.

## Паразитная сложность (050)

- **Строка шага `check:roles-architecture-188-family-selftest`.**
  1. Её требует ПРОВОДКА 188/2 (guard) и стр. 188 контракта.
  2. Состояние явное: это строка реестра.
  3. При правке свойства меняется одна строка плюс генерация; сверх нужного дифф ничего не добавил.
  4. Интерфейс тот же, что у соседних семей (186, 182).
  5. Потребители — `check_provodka` (третья локация) и `run_ci_lane`. Новой грамматики нет.
  - Итог: ESSENTIAL.
- **Строка ci-zamery 188.**
  1. Покрытие г1 контракта 114: без неё `check_ci_weights` даёт «нет замера» (мутация zamer_gone).
  2. Состояние явное.
  3–5. Форма как у дерева.
  - Итог: ESSENTIAL. Честность самой цифры — Н-4.
- **Перераспределение lanes в `ci.yml`.** Это производный вывод `gen_ci_steps --write`, сверяется `--check`. Итог: ESSENTIAL.

## Сверки

- СВЕРКА-СТАНДАРТОВ: неприменимо. `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md`; дельта — реестр CI и генерат.
- СВЕРКА-АРХИТЕКТУРЫ: неприменимо. Это предмет doc/role станции, кодовой модели архитектуры в дельте нет.
- ПРОВОДКА:
  - guard — `fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh`, подключён через `registry/ci-steps.tsv:310` (lane l4); это барьер именно предмета 188;
  - 21 role-канал судится (мутация role_literal_glm → rc 1);
  - `check_provodka` rc 0 на OBJECT;
  - ПРОВОДКА-ЭНФОРСМЕНТ честно ограничивает guard наличием строк, а поведенческие нормы проведены role-каналами.
- sourceCanon / режим проекта 996: неприменимо, это станция, а не проект.
- Мобильный экран: неприменимо.

## Итог

accept по OBJECT 27cd1700402ddec361963f0b2f71809e5a3e4826. Б-1 вызова 1 закрыт:
- дельта — ровно три пути ЗОНЫ orchestrator;
- `ci.yml` равен генерации;
- шаг 188 вызывает guard 188 в режимах `--repo .` и `--stabs`; он красный на ролях main и зелёный на OBJECT, в том числе в CI l4;
- `check_provodka 188` rc 0; подмена, комментирование и удаление шага краснят его;
- регресса ПРОВОДКИ нет (136/137 без изменений, 188: 1→0);
- область implementer не изменилась.

Н-3, Н-4 и Н-5 слияние не блокируют. Бюджет ревьюера по 188 v2 исчерпан. Если после этого accept изменятся поведение, критерий или граница, accept к изменённому кандидату не применяется.
