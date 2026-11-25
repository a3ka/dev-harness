FAIL
OBJECT=cd07d3a9d09504f1a81c4d0466781fcc70798152
КЛАСС=кодовый; риск=обычный (подтверждён по закрытому перечню contracts/187-arhitektura-v-processe.md:4: дельта меняет двери процесса — разбор ответа locate, rc отказов, класс предмета; права/роли БД, авторизация, деньги, ПД/health и согласия, юридически значимые действия не затронуты; повышать не на чем)
СУД: repo=dev-harness; предмет=187 (187а v3: дверь разбирает ответ locate целиком); фаза=реализация; роль=reviewer; вызов=1/1 (полный); модель-план=anthropic/claude-opus-5-5 (trace /tmp/dev-harness-verify/orch/trace-rev-plan.tsv); сессия=Rev187v3; модель-факт=anthropic/claude-opus-5-5; OBJECT=cd07d3a9d09504f1a81c4d0466781fcc70798152; предыдущий=verdicts/critic/contracts-187-v3.md; исключение=нет

# Вердикт ревьюера — 187а v3, суд реализации, вызов 1/1

Контракт: `frozen/contracts/187/2` (тег локален на станции) → коммит `e698aae9d98c71bf077fd70e20d941e672acb735` = tip `origin/wip/187/architect`; текст прочитан `git show e698aae9d:contracts/187-arhitektura-v-processe.md` (214 строк).
Кандидат: `origin/wip/187/implementer` = `cd07d3a9d09504f1a81c4d0466781fcc70798152` (`git rev-parse` в одноразовом клоне `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev187v3/repo`, совпал с OBJECT). Родитель = `origin/main` = `0814d2f5a8980e6e8331f06b8e22911e5f57eade`. Один коммит, `user.name=implementer` (MiniMax-M3 по trace); судья — Anthropic Opus.
Дерево суда: OBJECT + ОДНОРАЗОВО наложенные `git checkout origin/wip/187/architect -- fixtures/workshop_project/architecture_process_187/ contracts/187-arhitektura-v-processe.md` (без коммита).

## Итог

FAIL по двум блокам. Обе ошибки узкие, каждую можно исправить в одном месте. Боль приоритета №1 (А1) на реальном контракте 181 снята: `ARCH_187A_OK` на OBJECT при `PATH_WITHOUT_COMPONENT` на родителе (см. сырой вывод). Батарея architect зелёная, все мои мутанты двери красны своими клетками, область правки чиста.

- [ ] **Р187v3-Б1 (блок, обязательство контракта).** `make_task` превращает rc 2 двери («нечем проверить») в rc 1.
  - Фрагмент: `scripts/make_task.sh:880` `arch187_check_text … || die "$ARCH187_REFUSAL"` и `:887` `arch187_model_prepare … || die "$ARCH187_REFUSAL"`. `die` всегда даёт `exit 1`, а `ARCH187_RC=2` библиотеки двери игнорируется.
  - Обязательство: контракт §«Дерево модели и зависимости» требует `ARCH_DEPS` «с rc 2 двери в любом режиме». §«Размещение путей (v3)» требует `ARCH_LOCATE_GRAMMAR` rc 2 «fail-closed». Зоны судит и `make_task` (§«Двери в целом»: «`make_task` судит задание и черновик контракта (класс, строка, зоны) и собирает бриф из пина»).
  - Наблюдение (моя проба `probe_rc2.py`, переиспользует строители миров батареи, тот же OBJECT): `door-real-deps rc=2`, `freeze-real-deps rc=2`, `precritic-real-deps rc=2`, **`task-real-deps rc=1`**; `door/freeze/precritic-grammar-broken rc=2`, **`task-grammar-broken rc=1`**. Пак не выдаётся (`nopack`), имя отказа верное. Расходится только rc, и только у одной из четырёх дверей. `freeze_contract`/`pre_critic` implementer научил передавать `ARCH187_RC`, а `make_task` пропустил.
  - Достижимость: да. На backend `make_task --arch-component` при недоступном npm (или с обрывом тела `locate`) отвечает rc 1, то есть «именованный отказ по существу» вместо «нечем проверить» (правило 7: отказ обязан говорить правду).
  - Батарея этого не ловит: `deps-door-refusal` идёт действием `door`, `locate-grammar-refusal` — действием `freeze`. Клетки `make_task` на rc 2 нет. Поэтому починке нужна красная клетка (зона architect, добавление по шагу 5–6 законно).
  - Измерено, что починка узкая. Две строки в `fix_mt` (`|| { printf 'ОТКАЗ: %s\n' "$ARCH187_REFUSAL" >&2; exit "${ARCH187_RC:-1}"; }` на :880 и :887) дают `task-real-deps rc=2`, `task-grammar-broken rc=2`, `nopack`; батарея `--repo` при этом `CELLS=68 FAILURES=0 SKIPPED=2`, rc 0.

- [ ] **Р187v3-Б2 (блок: правило 7 AGENTS.md «не приём по догадке» + паразитная сложность 050 с тремя частями).** Ветвь «статус не назван или незнаком» в `arch187_locate` угадывает класс по rc и на ответе вне грамматики даёт ЗЕЛЁНЫЙ результат.
  - Фрагмент: `scripts/check_architecture_contract.sh:313-323` (`*)` в `case "$status"`). Если тело — JSON-объект с массивом `matches`, а `status` нет или он незнаком, класс выводится из rc `locate`. При rc 0 и пустом объединении получается `empty`, то есть конформ.
  - Отсутствующее свойство: класс ответа по контракту задаётся `status` и `matches` (§«Размещение путей», четыре класса (а)–(г)). Демаркация 019 (§«Снятия и границы v3») называет конформными только тела с полями `scope/path/status/matches[].components/implementationEvidence`. Источник пина выдаёт `status` всегда: `tooling/checks/workflow.js:87` `status: matches.length === 1 ? 'DECLARED' : 'UNRESOLVED'` (клон `/tmp/dev-harness-verify/arch-pin4`). Ни одна строка приёмки и ни одна клетка батареи эту ветвь не требуют. Toy-CLI всех миров печатает `status` (`workflow_probe.py:463,486`).
  - Наблюдение (моя проба `probe_nostatus.sh`): тело без `status`, два претендента с пустыми компонентами, rc 0 → OBJECT: `ARCH_187A_OK`, rc 0. Тот же ответ со `status: UNRESOLVED` по контракту (г) — `PATH_WITHOUT_COMPONENT`. Получается fail-open на ответе вне грамматики, хотя сама функция объявляет «fail-closed: догадываться нельзя».
  - Более простая форма проходит те же строки приёмки (измерено). `mut_h` заменяет ветвь именованным отказом `ARCH_LOCATE_GRAMMAR`/`ARCH187_RC=2`. Результат: `--repo` → `CELLS=68 FAILURES=0 SKIPPED=2` rc 0; с `ARCH187_REAL_ROOT=/tmp/dev-harness-verify/arch-pin4` → `CELLS=68 FAILURES=0 SKIPPED=0`, `live-real-pin`/`live-real-union` GREEN, rc 0. `probe_nostatus.sh` на `mut_h` даёт rc 2 `ARCH_LOCATE_GRAMMAR`. Текст отказа в починке стоит уточнить («ответ locate вне грамматики…»): тело формально парсится, и формулировка «не парсится как JSON» на этом входе неточна.
  - Нужна красная клетка «тело без `status`» (зона architect).

Советы (не блокируют):
- С1. `arch187_intersects`, цикл в `arch187_line` и цикл id в `make_task.sh` трижды повторяют рез списка по запятым. Это одна грамматика в трёх копиях. Есть простая форма — одна функция-итератор. Строк приёмки, которые она бы не прошла, нет, но фрагмент маленький и дефекта не несёт.
- С2. Комментарий `check_architecture_contract.sh:315` «декарено» — опечатка. При починке Б2 ветвь всё равно уходит.
- С3 (порядок приземления, оркестратору). Ветка implementer самостоятельно на `origin/main` красна старой батареей main: `--repo .` на чистом OBJECT даёт `CELLS=34 FAILURES=1` (`freeze-foreign`: ожидание v1 по дисковой эвристике, снятой контрактом v2 С2). Приземлять только вместе с фикстурами architect v3 в одном дереве.

## (1) Область правки

`git diff --stat origin/main...cd07d3a9d`:
```
 scripts/check_architecture_contract.sh | 372 +++++++++++++++++++++++++--------
 scripts/done_contract.sh               |   9 +-
 scripts/freeze_contract.sh             |  17 +-
 scripts/make_task.sh                   |  15 +-
 scripts/pre_critic.sh                  |  24 ++-
 5 files changed, 336 insertions(+), 101 deletions(-)
```
Своей мерой: `sort` путей диффа против `sed -n 's/^ЗОНА implementer: //p'` блоба `e698aae9d:contracts/187-…` — одни и те же 5 путей. `git diff --name-only … -- fixtures/ contracts/` → 0 строк. ЗОНА implementer в `frozen/contracts/187/1` та же.
Что удалено (все `-`-строки двери прочитаны):
- `sed -n 1p` в `arch187_locate`. Это корень боли А1, удалён по v3.
- Дисковая эвристика `[ -e "$repo/$p" ] → ARCH_ZONE` и наследование компонента каталога неразмещённым файлом. Удалены по v2 С2 и v3 (г).
- Флаг `--model-only` и `model_only`. Удалены по §pre_critic «ПОЛНЫЙ режим». Потребителей флага вне `contracts/` и `verdicts/` в дереве нет (grep `model-only|arch187_code_subject` → 0).
- `.clone` из lock (v2 С4), имена `ARCH_PIN` для нет-клона/нет-пина вместо `ARCHITECTURE_NET` (v2 расхождение (3)), обязательность `ОПЕРАЦИЯ:` (v2 С3), подстрочный `grep NOT_EVALUATED` (v2 канон), прямой `node cli.js brief` (v2 расхождение (4)).
Все удаления предписаны контрактом. Пересечения 072/094/095/103/170 не сужены: правки `pre_critic`, `freeze_contract`, `done_contract` лежат только внутри блоков 187а и вооружаются лишь при `arch187_scope` (repoId=Complior-back и lock). Новая ветка `make_task` — `elif [ "$_arch187" = "1" ]` (только в режиме 187а). Выход `pre_critic` rc 2 соответствует его объявленной грамматике («2 — нечем проверить», `pre_critic.sh:44-46`). Соседние батареи — ниже, rc 0.

## (2) Сырой вывод (мои прогоны, дерево OBJECT + наложенные фикстуры architect)

| команда | итог | rc |
|---|---|---|
| `red_architecture_process_187.sh` (без аргументов) | `CELLS=68 STABS=0 FAILURES=0 SKIPPED=2` | 0 |
| `… --repo .` | `CELLS=68 STABS=0 FAILURES=0 SKIPPED=2` (SKIP: `live-real-pin`, `live-real-union` — «ARCH187_REAL_ROOT не задан») | 0 |
| `ARCH187_REAL_ROOT=/tmp/dev-harness-verify/arch-pin4 … --repo .` | `CELLS=68 STABS=0 FAILURES=0 SKIPPED=0`; `GREEN live-real-pin: rc=0 … ARCH_187A_OK`, `GREEN live-real-union: rc=0 … ARCH_187A_OK` | 0 |
| `… --model` | `CELLS=68 STABS=0 FAILURES=0 SKIPPED=0` | 0 |
| `… --stabs` | `CELLS=68 STABS=70 FAILURES=0 SKIPPED=0` | 0 |
| `… --repo parent` (скрипты родителя `0814d2f5a`, те же фикстуры) | `CELLS=68 STABS=0 FAILURES=30 SKIPPED=2` | 1 |
| `… --wiring .` (чистый OBJECT) | — | 0 |
| `gen_ci_steps.sh --check` | — | 0 |
| `check_provodka.sh . contracts/187-…` | — | 0 |

Счёт своей мерой, не выводом батареи. `--stabs` разобран python-счётчиком строк `STAB `: 70 строк, 70 `caught`, 0 `ZHIV`, 70 уникальных имён, 62 различные ловящие клетки; GREEN-строк 68 из 68. Красное множество родителя перечислено поимённо из строк `RED`: 30 имён, и это ровно 17 + 4 + 9 клеток контракта §Приёмочный критерий. `line-duplicate` и `pin-foreign-hex` на родителе GREEN, как и обещано контрактом.

Боль А1 на точном входе (мир `/tmp/dev-harness-verify/Arch187v3/world181`, контракт 181 Complior-back: `АРХИТЕКТУРА: L2 api.auth,resource.identity`, `ЗОНА implementer: server/src/auth/adapter.js tests/auth/grant-writers.js tests/ci-fixtures/auth004/check_auth_sessions.js tests/architecture/conformance-baseline.json tests/tools/run_backend_ci.py FILES.sha256`; `ARCHITECTURE_ROOT=/tmp/dev-harness-verify/arch-pin4`, без NODE_PATH — дверь сама делает `npm ci`):
```
ARCH_187A_OK: архитектура сходится с закреплённой моделью
DOOR_RC_181_OBJECT=0
PATH_WITHOUT_COMPONENT: путь server/src/auth/adapter.js не размещён ни в модели, ни в продукте
DOOR_RC_181_PARENT=1
```

Свои мутанты по КОДУ двери (копии дерева, правка одной строки `scripts/check_architecture_contract.sh`, `bash -n` ok; прогон `--repo mut_X`):

| мутант | правка | `FAILURES` | красные клетки | rc |
|---|---|---|---|---|
| (а) `sed -n 1p` | первая строка тела как компонент (поведение до v3) | 17 | `locate-json-conform`, `locate-json-foreign`, `zone-comma-list`, `path-unplaced-product`, `check-green-status-field`, `brief-npm-doorway`, `locate-union-conform`, `locate-union-foreign`, **`locate-real-contract`**, `locate-declared-empty`, `locate-outside-universe`, `zone-locate-not-heuristic`, `locate-grammar-refusal`, `locate-declared-empty-worker`, `locate-outside-provenance`, `locate-outside-structure`, `path-unplaced-empty-claimants` (сырой отказ ровно бэкенда: «компоненту {») | 1 |
| (б) DECLARED-пустой → `placed` | | 3 | `locate-real-contract`, **`locate-declared-empty`**, **`locate-declared-empty-worker`** | 1 |
| (в) UNRESOLVED-несколько → `unresolved` | | 2 | `path-unplaced-product`, **`path-unplaced-empty-claimants`** | 1 |
| (г) обрыв тела → `unresolved`, rc 0 | | 1 | **`locate-grammar-refusal`** (rc=0, ожидался 2) | 1 |
| (д) эвристика вида пути `docs/*\|*.md\|*.json\|*.sha256` → пропуск | | 1 | **`zone-locate-not-heuristic`** | 1 |
| (е) вернуть `grep -q NOT_EVALUATED` в `check` | | 1 | **`check-green-status-field`** | 1 |
| (ж) только `matches[0].components[0]` вместо объединения | | 1 | **`locate-union-conform`** | 1 |
| (h) ветвь `*)` статуса → `ARCH_LOCATE_GRAMMAR` (более простая форма, Б2) | | 0 (и с `ARCH187_REAL_ROOT`: `SKIPPED=0`, обе живые GREEN) | — | 0 |

(г), (д), (е), (ж) ловятся ровно своей клеткой. (б) и (в) ловятся ровно клетками своего класса; (б) дополнительно краснит боль-клетку `locate-real-contract`, в зоне которой есть тестовый шов. (а) краснит всё JSON-семейство; клетка `locate-real-contract` в нём есть.

Пробы rc дверей (`probe_rc2.py`, Б1):
```
door-real-deps: rc=2 nopack :: ARCH_DEPS: зависимости модели недоступны (npm ci --ignore-scripts)
freeze-real-deps: rc=2 nopack :: ОТКАЗ: ARCH_DEPS: зависимости модели недоступны (npm ci --ignore-scripts)
precritic-real-deps: rc=2 nopack :: ОТКАЗ: дверь архитектуры 187а красна: ARCH_DEPS: …
task-real-deps: rc=1 nopack :: ОТКАЗ: ARCH_DEPS: зависимости модели недоступны (npm ci --ignore-scripts)
door-grammar-broken: rc=2 nopack :: ARCH_LOCATE_GRAMMAR: ответ locate не парсится как JSON (app/broken/model.js)
freeze-grammar-broken: rc=2 nopack :: ОТКАЗ: ARCH_LOCATE_GRAMMAR: …
precritic-grammar-broken: rc=2 nopack :: ОТКАЗ: дверь архитектуры 187а красна: ARCH_LOCATE_GRAMMAR: …
task-grammar-broken: rc=1 nopack :: ОТКАЗ: ARCH_LOCATE_GRAMMAR: ответ locate не парсится как JSON (app/broken/model.js)
```
С двухстрочной починкой `make_task` (`fix_mt`): `task-real-deps: rc=2`, `task-grammar-broken: rc=2`, батарея `CELLS=68 FAILURES=0 SKIPPED=2` rc 0.
Проба Б2 (`probe_nostatus.sh`): OBJECT — `ARCH_187A_OK`, `DOOR_RC_NOSTATUS_TWO_MATCHES=0`; `mut_h` — `ARCH_LOCATE_GRAMMAR …`, `DOOR_RC_NOSTATUS_TWO_MATCHES=2`.

## (3) Неподгонка

В коммите OBJECT нет путей `fixtures/` и `contracts/` (0 строк). Фикстуры 187 на `origin/wip/187/architect` от `origin/main` правились только автором `architect` (`git log --format=%an` по каталогу: `aaf46a81`, `a2d4e0ee`, `6702d1c2`, `2d1ead23`, `0261e4ab` — все architect). Батарея проверялась своими мутантами: она красна на всех семи сломах двери и на родителе — 30 клеток. Подгонки нет.

## (4) Потребители

- `make_task`: `arch187_class` по черновику контракта (CBYTES), затем `arch187_check_text <task|черновик> task`, затем бриф `arch187_brief` через `npm --prefix`. Клетки `task-*`/`brief-*` GREEN. Расхождение rc — Б1.
- `freeze_contract`: `arch187_class` по HEAD-блобу, затем `arch187_check_text … contract`, выход `ARCH187_RC`. Отказ стоит до записи тега: в клетках `freeze-*` с ожиданием 1/2 тега `frozen/contracts/777/*` нет (наблюдатель батареи).
- `pre_critic`: `check_architecture_contract.sh --repo "$BASE" "$CONTRACT"` в полном режиме, без `--model-only`; rc 1 → 1, rc 2 → 2.
- `done_contract`: `arch187_class` по HEAD-блобу; при rc 1 → `die` (ARCH_CLASS_MISSING), при 0 — прежние ноги ARCH_REVIEW/ARCH_CI.
- `bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md` → `КРИТИК: дверь зелёная`, rc 0 (харнесс вне режима 187а — `ARCH_187A_SKIP`).
- Живая дверь на пине `bfc3f459`: `live-real-pin`/`live-real-union` GREEN; контракт 181 — `ARCH_187A_OK`.

## (5) Гейты и соседи (rc)

`check_consumers.sh . contracts/187-…` 0; `check_precision_gate.sh . contracts/187-…` 0 (`OK`); `check_ceilings.sh .` 0; `check_threat_model.sh . contracts/187-…` 0 (ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 6); `_krasnye_072` 0; `_krasnye_094` 0; `_krasnye_095` 0; `_krasnye_103` 0; `red_arch_component_170.sh --model` 0 и `--repo .` 0 (25/25 `ok`). `_krasnye_038`: rc 1 на чистом OBJECT и rc 1 на чистом родителе `0814d2f5a`, вывод совпадает (`итог: 37 файлов, расхождений 37 (режим ожидания rc=1)`). Это существовало до коммита, OBJECT тут ни при чём.
`check_zones.sh .` на HEAD=OBJECT (чистый клон, detached `cd07d3a9d`): `замороженных контрактов: 172 · объявленных авторов: 5 · коммитов в диапазонах: 60550 · проверено по зонам: 18339`, rc 0 (817 с).

## (6) Соответствие архитектуре, класс риска, 050, стандарты

Риск: оставляю «обычный». Меняются только двери процесса и rc. Права, авторизация, деньги и ПД не затронуты, перечень строки :4 не задет.
Форма модуля: одна реализация правил — библиотека `ARCH187_LIB=1` — и четыре двери-импортёра. Это тот же приём, что у `next_id.sh`; второй конвенции нет.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефактам диффа — (1) свойство · (2) состояние · (3) файлы вместе · (4) глубина · (5) потребитель:
- `arch187_class` (замена `arch187_code_subject`): (1) ARCH_CLASS_MISSING на 4 дверях · (2) явное: rc 0/1/2 + `ARCH187_REFUSAL` · (3) 5 файлов, как и до диффа · (4) глубокий · (5) клетки `*-class-missing`. ESSENTIAL.
- `arch187_hex40`: (1) 40-hex → ARCHITECTURE_NET/ARCH_PIN · (2) нет · (3) 1 · (4) узкий, но точный · (5) `pin-symbolic`, `pin-foreign-hex`. ESSENTIAL.
- `arch187_intersects`: (1) объединение компонентов и рез по запятым · (2) нет · (3) 1, но грамматика запятых живёт ещё в двух местах (С1) · (4) ок · (5) `zone-comma-list`, union-клетки. ESSENTIAL (совет С1).
- `arch187_locate`, четыре класса + однострочный id + `unplaced`: (1) v3 (а)–(г), совместимость 170/187-1 · (2) явное: `ARCH187_LOCATE_CLASS/COMPS`, rc · (3) 1 · (4) глубокий · (5) 9 клеток v3. ESSENTIAL. Ветвь `*)` по неизвестному статусу: (1) свойства нет · (2) догадка по rc · (5) потребителя нет → ACCIDENTAL. Есть все три части (фрагмент :313-323, отсутствующее свойство, более простая форма `mut_h` проходит те же строки), поэтому это блок Б2.
- `ARCH187_RC` (глобальная): (1) rc 2 для ARCH_DEPS/ARCH_LOCATE_GRAMMAR · (2) неявное, побочный канал библиотеки · (3) 3 импортёра обязаны его читать, читают 2 → Б1 · (5) `deps-door-refusal`, `locate-grammar-refusal`. ESSENTIAL как свойство, дефект — в потребителе.
- Кэш дерева в `arch187_model_prepare` (повторно не разворачивать): (1) прямого свойства нет; (4) экономит второй `git archive` + `npm ci` с сетью на вызов (суд зон, затем бриф). Цена неявной глобали `ARCH187_MODEL_DIR` меньше двойного `npm ci`. ESSENTIAL по стоимости.
- Ветка `make_task` `elif _arch187 → ARCH_COMPONENT_NET`: (1) v2 расхождение (2) · (5) `component-required-no-local`. ESSENTIAL.
- `pre_critic` rc 2 и `freeze_contract` `exit ${ARCH187_RC}`: (1) rc 2 в любом режиме · (5) `locate-grammar-refusal` (freeze). ESSENTIAL.

ПРОВОДКА (038): `guard=fixtures/…/red_architecture_process_187.sh` и `guard=scripts/check_architecture_contract.sh` существуют. Оба — отдельные `step` в `registry/ci-steps.tsv:304-305` и ключи в `ci.yml`; `--wiring .` 0, `gen_ci_steps --check` 0. Guard — барьер именно этого предмета. ПРОВОДКА-ЭНФОРСМЕНТ обоснована: двери судят byte-структуру и rc, роли — предмет 188.
СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (прочитан целиком), сверять дифф не с чем.
sourceCanon (996): не объявлен для предмета харнесса, сверки карты нет.

## Что нужно для accept (scoped-исправительный вызов)

1. implementer: Б1 — `make_task.sh:880,887` передают `ARCH187_RC`. Б2 — ветвь `*)` в `arch187_locate` даёт именованный отказ, а не догадку (текст отказа — «вне грамматики ответа»).
2. architect (своя зона, добавление красных клеток после freeze законно): клетки `make_task` на rc 2 (ARCH_DEPS и обрыв тела) и клетка «тело `locate` без `status`» → rc 2. На OBJECT обе красные, после починки — зелёные.
3. Повторный суд — только по этим двум путям и новым клеткам.
