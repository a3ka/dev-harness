FAIL
OBJECT=8b86533fda0d7d4864fe2521584153da2e993aba
СУД: repo=dev-harness; предмет=186; фаза=реализация v2 (РИСКОВЫЙ); роль=adversary; вызов=1/1; модель-план=по config/agent_models.json (adversary); сессия=Adv186Impl; модель-факт=openai-codex/gpt-6.1-terra; SHA=8b86533fda0d7d4864fe2521584153da2e993aba; предыдущий=verdicts/adversary/contracts-186-impl-v2.md (OBJECT 61b2b2bf8 — иная реализация, v+1 ещё не было); исключение=нет

# Суд реализации 186 v2 — adversary, вызов 1/1

Объект: tip `origin/wip/186/implementer-v2` = 8b86533fda0d7d4864fe2521584153da2e993aba (2 коммита `39b98241fc`, `8b86533fda`, автор обоих `implementer`). Замороженные поверхности не тронуты: `git diff --exit-code 'frozen/contracts/186/2^{commit}' 8b86533fda -- contracts/186-hranitel-arhitektury.md fixtures/workshop_project/architecture_steward_186/` → rc 0.

Позитивный контроль (честная реализация обязана быть зелёной) — пройден:
- `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --repo .` → rc 0, все клетки `ok` (probe 21 + door 61 + pin 5), в том числе `door l1_merge` сливает честный toy PR ровно одним `gh pr merge --merge --match-head-commit <head>`;
- `… --model` → rc 0; `… --stabs` → rc 0, 87 `caught`, ни одного `ZHIV`.

Атаки выполнялись в одноразовом SSH-клоне `/tmp/dev-harness-verify/adv186impl-20261116` (ssh://git@github.com/a3ka/dev-harness.git, detached на OBJECT), toy-миры батареи `door_probe.world()`, harness удалён до вердикта. Остаток Arb186V1 (cognitive-only: Unicode-пробелы, гомоглифы, CR/LF) не повторялся.

## Н-1 БЛОКИРУЕТ — слияние без поля `модель-факт=`: значение читается из подстроки чужого имени поля

ОБЯЗАТЕЛЬСТВО: contracts/186-hranitel-arhitektury.md (frozen 186/2) §Дельта v+1, строка «СРАВНЕНИЕ» — поле `модель-факт=` единственной строки `СУД: ` равно ПОЛНОЙ строке назначенной модели; строка СУД обязана НЕСТИ это поле.
СОСТОЯНИЕ: замена уже имеющейся предметной операции — разбора поля `модель-факт=` в `scripts/merge_architecture_pr.sh` (`fields = sud[0].split('модель-факт=')`). Источник входа — тело GitHub review от логина критика на head (тот же канал, что и вся поверхность v+1 «подмена модель-факт»: подделка/ошибка публикации вердикта); строка СУД по грамматике критика многословная (`repo=…; предмет=…; фаза=…; …`), поэтому поле с посторонним именем — рядовое состояние тела review. Источник ошибочного механизма — split по подстроке без проверки левой границы имени поля.
НАБЛЮДЕНИЕ (репро в toy-мире батареи, назначенная критику `zai/glm-5.3`):

```
$ python3 - <<'PY'   # toy-мир l1_merge, тело review: accept\nСУД: repo=architecture; ложная-модель-факт=zai/glm-5.3; SHA=<head>
N1_wrong_field: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 7c6d7e8eb38fba6bd12b682825a1a75f62f528ed' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', '7c6d7e8eb38fba6bd12b682825a1a75f62f528ed']
PY
```

То же на реальной грамматике СУД (`замечание=модель-факт=zai/glm-5.3`, `роль-модель-факт=zai/glm-5.3` при фактической Terra) — слияние; контроль на честном поле `модель-факт=` с чужим фактом — `NO_CRITIC_ACCEPT_ON_HEAD` rc 1. Строка `СУД: repo=architecture; ложная-модель-факт=zai/glm-5.3; SHA=<head>` поля `модель-факт=` НЕ несёт — дверь слила PR без attestации модели критика.
ОБХОД (батарея слепа к этому классу): мутация контрольной двери — переименование поля в разборе (`модель-факт=` → `ложная-модель-факт=`) — проходит все 61 door-клетку зелёно (67 клеток, красна только несвязанная `no_git`): `mutant wrong_field cases=67 failed=1 details=['no_git:1:CHECKOUT_NOT_AT_PR_HEAD']`. В батарее нет клетки с переименованным/чужим именем поля (есть только `model_second_field` — два честных поля, она ловит `len(fields)!=2`, но не подстроку в чужом имени).
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: значение берётся только из поля, чьё имя ограничено слева началом строки СУД или разделителем поля (`;` с опциональными пробелами), а не из вхождения подстроки `модель-факт=` внутри чужого имени; входы `ложная-модель-факт=`, `замечание=модель-факт=` — красные клетки (`NO_CRITIC_ACCEPT_ON_HEAD`, слияния нет).

## Н-2 БЛОКИРУЕТ — реестр resolved от пути вызова (симлинк), а не от файла скрипта

ОБЯЗАТЕЛЬСТВО: frozen 186/2 §Дельта v+1, строка «ПУТЬ РЕЕСТРА» — путь разрешается ОТ ФАЙЛА скрипта, не от cwd; каталог `config/` — сосед `scripts/` В ДЕРЕВЕ ХАРНЕССА САМОЙ ДВЕРИ. Задание суда прямо называет вектор «подмена пути реестра (cwd, симлинк, относительный BASH_SOURCE)».
СОСТОЯНИЕ: `SCRIPT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"` в `scripts/merge_architecture_pr.sh` — без каноникализации симлинков: при запуске по симлинку `SCRIPT_ROOT` — каталог ССЫЛКИ, и дверь читает чужой `config/agent_models.json`, соседний с ней.
НАБЛЮДЕНИЕ (репро): реестр дерева скрипта назначает критику `zai/glm-5.3`; рядом с симлинком лежит чужой реестр с назначением `openai-codex/gpt-6.1-terra`; факт в review — `openai-codex/gpt-6.1-terra`:

```
$ bash other/scripts/merge_architecture_pr.sh <toy-проект> 42   # other/scripts/merge_architecture_pr.sh → symlink на дверь
N2_symlink_registry: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 7c6d7e8eb38fba6bd12b682825a1a75f62f528ed' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', '7c6d7e8eb38fba6bd12b682825a1a75f62f528ed']
```

Дверь слила при `модель-факт ≠` назначенной модели её собственного дерева — реестр подменён каталогом ссылки. Контроль: тот же вход без симлинка (дверь из своего дерева) — `NO_CRITIC_ACCEPT_ON_HEAD` rc 1, слияния нет.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: SCRIPT_ROOT разрешается канонически от файла скрипта (симлинки раскрыты до реального пути, напр. `readlink -f`); запуск по симлинку с чужим соседним реестром — красная клетка (`CRITIC_MODEL_UNRESOLVED` либо отказ по несравнению с назначением реального дерева), слияния нет.

## Н-3 БЛОКИРУЕТ — алиас-цикл: неразрешимое назначение принимается за модель и пропускает слияние

ОБЯЗАТЕЛЬСТВО: frozen 186/2 §Дельта v+1, строки «ЦЕПОЧКА» и «ОТКАЗ»: цепочка завершается ПОЛНОЙ строкой модели; неразрешимый алиас → именованный отказ `CRITIC_MODEL_UNRESOLVED` rc 1, слияния нет.
СОСТОЯНИЕ: `assigned_critic_model()` в `scripts/merge_architecture_pr.sh` возвращает `models[семейство]` без проверки, что результат — строка модели, а не алиас: самоссылочный реестр (`models.glm = "@glm"`) даёт `critic_model='@glm'` — строку-алиас, не модель.
НАБЛЮДЕНИЕ (репро):

```
$ # toy-реестр: models.glm='@glm' (алиас-цикл), факт 'zai/glm-5.3'
N3_alias_cycle_refusal_name: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' merge=None        # должен быть CRITIC_MODEL_UNRESOLVED
$ # тот же реестр, факт '@glm' (строка-алиас в модель-факт)
N3b_alias_cycle_merge: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 6a347729fc69194e0f5b04c768d2d15c04b396a7' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', '6a347729fc69194e0f5b04c768d2d15c04b396a7']
```

На неразрешимом назначении дверь слила PR (факт равен строке-алиасу, не полной строке модели) — это вторая цель атаки задания («слить при неразрешимом назначении вместо CRITIC_MODEL_UNRESOLVED rc 1») в достижимом состоянии ошибочной ротации реестра. Источник ошибочного механизма — отсутствие терминальной проверки разрешения.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: разрешение считается завершённым только строкой, не являющейся алиасом (не начинающейся с `@`, либо однократное развёртывание с контролем); алиас-цикл/алиас-в-алиас → `CRITIC_MODEL_UNRESOLVED` rc 1 без слияния — красные клетки (факт честный и факт=`@…`).

## Обманные заглушки против батареи (сырой вывод)

Мутации контрольной двери `door_control.py` в toy-мирах, все клетки CASES (67):

```
mutant exit1    cases=67 failed=61   # «всегда отказ» пойман на всех негативных клетках, позитивные красны
mutant exit127  cases=67 failed=67
mutant hardcoded ('zai/glm-5.3' вместо assigned_critic_model()) cases=67 failed=13
    # registry_terra, registry_sol, accept_fact_glm, accept_fact_fallback, accept_fact_same_family,
    # accept_fact_superstring, registry_missing, registry_invalid_json, registry_no_critic_role,
    # registry_no_tier, registry_alias_unresolvable, registry_model_empty, no_git — пойман
mutant neutralize_accept ('if not accepted:' → 'if False:') cases=67 failed=26  # пойман
mutant wrong_field (переименование поля в разборе) cases=67 failed=1 ['no_git'] # СЛЕПА — см. Н-1
```

## Проверенные векторы без находок (сырой вывод)

- подмена факта при честном разборе: `foreign_fact` (`openai-codex/gpt-6.1-terra` при назначенной `zai/glm-5.3`) → `rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' merge=None`; `real_sud_terra_fact` (реальная грамматика СУД) → rc 1;
- decoy в значении другого поля при честном `модель-факт=` (`примечание=см. модель-факт=zai/glm-5.3 в трейсе; модель-факт=<terra>`) → rc 1 `NO_CRITIC_ACCEPT_ON_HEAD` (ловится `len(fields)!=2`); пробел в имени поля (`модель-факт =`) → rc 1;
- сломанный реестр: BOM → `CRITIC_MODEL_UNRESOLVED` rc 1; `models.glm` = null/42/[] → `CRITIC_MODEL_UNRESOLVED` rc 1; отсутствие файла/невалидный JSON/нет roles.critic/нет тира/пустая модель — покрыты клетками батареи, все rc 1 `CRITIC_MODEL_UNRESOLVED`, слияния нет;
- env: `ARCH_CRITIC_MODEL=openai-codex/gpt-6.1-terra` — эффекта нет (слияние по назначенной glm законно; переопределение удалено); `ARCH_CRITIC_LOGINS='  Critic  '` — работает;
- отсутствие `gh` в PATH → rc 2 `DOOR_INFRA_ERROR` (нечем судить, не слияние); пустой список check-runs → rc 1 `CI_NOT_GREEN_ON_HEAD`;
- разрешение назначения ДО сетевых вызовов — соблюдено (`critic_model` вычислен до первого `gh`), ровно один `gh pr merge --merge --match-head-commit` во всех слияниях (merge-log — один JSON).

## Советы (не блокируют)

- СОВЕТ: пустое значение `ARCH_CRITIC_LOGINS` молча подменяется дефолтом `critic` (`${ARCH_CRITIC_LOGINS:-critic}` срабатывает и на пустой строке): оператор, задавший «никто», получает слияние (`logins_empty: rc=0 … СЛИТО`). Контракт семантику пустого значения не определяет; стоит различить пусто (отказ/нечем судить) и не задано.
- СОВЕТ: JSON реестра с дублями ключей разбирается по последнему вхождению (`registry_dup_keys: rc=0 СЛИТО`) — поведение парсера не оговорено контрактом; при ротациях реестра дубль ключа `model` в тире невидим для двери.

## Вердикт

Три блокирующие находки: дверь сливает L1 PR без поля `модель-факт=` (Н-1), по подменённому симлинком реестру при `факт ≠` назначенной (Н-2) и на неразрешимом алиас-цикле вместо `CRITIC_MODEL_UNRESOLVED` (Н-3). Все три воспроизведены живым прогоном в одноразовом клоне; батарея против тех же классов слепа (Н-1 показан мутацией: 66/67 зелёных). Обязательства v+1 выполнены в честных ветках (позитивный контроль зелёный), но инвариант «слияние только при `модель-факт=` = ПОЛНАЯ строка назначенной модели реестра самой двери» нарушен на достижимых состояниях вне остатка Arb186V1. Правка — за автором; после неё обязательны красные клетки на входах Н-1/Н-2/Н-3 в батарею (она их сейчас не имеет).

