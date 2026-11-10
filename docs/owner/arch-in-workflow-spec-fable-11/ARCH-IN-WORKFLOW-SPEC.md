# Исполняемая архитектура в воркфлоу — спецификация механизма (проход 11)

2026-11-09. Автор — Fable (ревизор проходов 7–10). Предмет — КАК архитектура 2.4.1 (`Complior-back/architecture/`, влита `40b57a6`) входит в каждую роль и каждый шаг воркфлоу, какие проверки её держат, где они живут. Метки: **Факт** — измерено или прочитано (путь:строка); **Предложение** — моё решение с обоснованием и ценой; **Открыто** — решает владелец.

Прогоны этого прохода — на одноразовом клоне `out11/run/cb` (HEAD `6b62aa0` = main). Прототипы: `out11/run/arch_conform_proto.py` (проверка «код ↔ архитектура»), `out11/run/brief_compact.js` (сжатый бриф). Ни один чекаут, ветка, PR, реестр не менялись.

## 0. Что измерено до проектирования (перепроверка фактов консультанта)

| Утверждение консультанта | Проверка | Результат |
|---|---|---|
| `brief --component api.vehicle` = 514 строк | `npm run brief -- --component api.vehicle \| wc -l` | **Факт: 514.** Состав: шапка/размещение/обязанности/порты/зависимости/ресурсы — 37 строк; контракты — 51 (свой 15, соседей 36); **«Applicable architecture requirements» (JSON требований и политик) — 387 строк (75 %)**; каталог политик 15; хвост 24. Тезис «большинство — контракты соседей» **не подтверждён**: большинство — JSON требований. |
| Все операции `DRAFT (no schema)`; схем 7 из 96 | `check --base … --report`, `contractReadiness.records` | **Факт:** 330 записей операций: 234 `WIRE_CONTRACT_DECLARED` (схема — OpenAPI), **69 `LOGICAL_PAYLOAD_DESIGN_REQUIRED` (DRAFT)**, 21 `CONTEXT_LEVEL_INTERFACE`, 6 `LOGICAL_SCHEMAS_DECLARED`. Из 96 не-wire операций логические схемы у 6 (консультант: 7). Для `api.vehicle` все 4 операции контракта компонента — DRAFT, хотя те же `operationId` имеют wire-схемы в `contract.public-http`: логическая схема и wire-схема в модели не связаны. |
| `check --base` → rc 2; baseline PASS; implementationEvidence NOT_ASSESSED | прогон с digest `02fbb3cb…` | **Факт:** rc 2; shape/structural/variants/contracts/moduleLayout/documentCoverage/baseline — PASS; contractReadiness — DESIGN_INCOMPLETE; system — NOT_EVALUATED (3 latency); `implementationEvidence: NOT_ASSESSED`; `evidenceScope: ARCHITECTURE_MODELS_AND_DECLARED_SCENARIOS_ONLY`. Проверки «код ↔ архитектура» в пакете нет (README: «Checks accept architecture models only»). |
| `render` даёт `structure-policy.fragment.json`, не взаимозаменяемый с `structure-policy.json` | сравнение полей | **Факт:** формат другой (`complioros-structure-handoff/1`, по модулям), но содержание сегодня совпадает: `allowedDomains` 29 = 29 доменов политики (разность пуста), `loadOrder` = порядок слоёв, capabilities слоёв `lib/domain/application/api` побайтово равны. Адаптер — сравнение четырёх полей, ~40 строк. |
| А0 закрыт | `.harness/ROADMAP.md` А0; `.github/workflows/ci.yml` | **Факт:** А0-1 (пакет 1:1) и А0-4 (снимок + digest в переменной репо) — в main; **А0-2 (полоса `arch` в CI) — нет**: в `ci.yml` слова `architecture` нет. |
| Контекст агентов | `harness.project.json` `contextPack.rows`, `sourceCanon` | **Факт:** все 7 ролей получают одинаковый набор: `docs/architecture/INDEX.md`, `STRUCTURE.md`, `structure-policy.json`, `docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md`, `MODULE-MAP-SPEC.md`… **`architecture/` ни в contextPack, ни в sourceCanon нет** — цитировать её по норме `ИСТОЧНИК: путь@sha256 §раздел` сейчас нельзя: `check_sources_cited.py:12-13` требует `#`-заголовок раздела, у `module.js` их нет. |
| Пробелы архитектуры фиксируются | `.harness/ROADMAP.md` §5; `.harness/plans/probely.md` | **Факт:** реестр пробелов П-01…П-NN существует, но лежит в `.harness/` (служебный каталог харнесса, см. проход 10) и ведётся вручную разведками; владельца у него нет. |

Прототип проверки «код ↔ архитектура» на текущем коде (58 файлов `app/**`, `server/**`), против `snapshot.json` модели — §3.4.

## 1. Каждая роль и архитектура (роль × шаг)

### 1.1 Решение по составу ролей

**Предложение.** Новых ролей-исполнителей (`arch-changer`, `arch-conformer`, `arch-scaffolder` из прохода 9) **не заводить**. Обоснование по уставу «роль, которую заменяет механизм, обязана быть заменена»:

| Роль прохода 9 | Чем заменяется | Почему достаточно |
|---|---|---|
| `arch-changer` (правка модели) | L1 — **architect** в том же контракте (зона `architecture/app/**/module.js` компонента); L2/L3 — **хранитель архитектуры** (§8) | правка модели — это конструкция, то же ремесло, что контракт; уровень выводит `check --base`, а не человек |
| `arch-conformer` (суд код ↔ модель) | **CI-проверка `arch:conform`** (§3) + **reviewer** (строка `СВЕРКА-АРХИТЕКТУРЫ:`) + **critic** (сверка контракта с моделью до заморозки) | механическая часть — скрипту, семантическая — уже существующим судьям; второй критик — цена без новой ловли |
| `arch-scaffolder` (каркас) | **implementer** с брифом: `implementationPathHint` + `PLANNED_NOT_PRESENT` в брифе и есть каркас | отдельная роль ради `mkdir` и трёх файлов-заглушек не окупается |
| `arch-approver` (L3 по делегированию) | **владелец**; делегирование — строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в коммите снимка | снимок всё равно публикует владелец (digest — переменная репозитория, права админа) |

**Единственная новая постоянная роль — хранитель архитектуры** (§8). Это не исполнитель задачи, а владелец предмета «архитектура»: без него находки некому принимать.

### 1.2 Таблица роль × шаг

Обозначения входов: **Б** — сжатый бриф компонента (§2а; 79 строк без правил, 133 с инвариантами/правилами); **К** — отчёт `npm run check -- --base …` (`check-report.json`); **С** — отчёт `arch:conform` (§3) на конкретном OBJECT; **Д** — `npm run diff` модели кандидата против снимка (только если PR меняет `architecture/`); **Р** — реестр DRAFT/пробелов (§8.3).

| Шаг (AGENTS.md §Воркфлоу) | Роль | Что получает из архитектуры, когда, объём | Что ОБЯЗАНА сделать | Чем держится (механизм / cognitive-only) |
|---|---|---|---|---|
| 0. Постановка (слово владельца → предмет) | оркестратор | **Б** для компонентов-кандидатов (по словам задачи → `implementationPathHint`), **Р**: какие операции компонента DRAFT, какие схемы/контракты отсутствуют | (а) назвать в задании architect компоненты и ожидаемый уровень `АРХИТЕКТУРА: L1\|L2\|L3 <id,…>`; (б) если нужная операция в **Р** — DRAFT без схемы и это внутренняя операция — поставить **до** предмета шаг «схема» хранителю или включить его в контракт как L1; (в) L3 → сначала вопрос владельцу, предмет не открывать | `make_task.sh`: отказ `ARCH_LINE_MISSING`, если задание architect по кодовому предмету бэкенда не несёт `АРХИТЕКТУРА:` (харнесс) |
| 1. Контракт + красные тесты | architect | **Б с правилами (133)** для каждого названного компонента + сигнатуры соседей; `isolationKeys`/`writers` ресурсов; статус операций (DRAFT/wire); **Р** | (а) раздел контракта «## Архитектура»: компоненты, уровень, операции (существующие/новые), ресурсы и их писатели, зависимости; (б) **вывести красные клетки из модели**: по одной клетке на операцию контракта (вход/выход по схеме), на каждый `semanticInvariant` (негатив), на ресурс — мутация «второй писатель» (обманная заглушка пишет таблицу ресурса из чужого компонента → `arch:conform` красный), на `isolationKeys` — чужой `scope_id` не читается; (в) если операция DRAFT и предмет меняет её payload — **схема в `module.js` пишется в контракте до заморозки (L1)**; (г) `ЗОНА`-строки ⊆ `implementationPathHint` названных компонентов (иначе компонент не назван — §2б); (д) расхождение модели с деревом, найденное при чтении, — файл находки `architecture/findings/` (§8.4), не молчаливая подгонка контракта | `freeze_contract.sh`: отказ, если `ЗОНА` выходит за `implementationPathHint` компонентов из `АРХИТЕКТУРА:` (харнесс, через проектную команду `locate`); отказ, если контракт называет новую операцию без схемы в `module.js` (проектная проверка `check --strict-new-ops`, A-13 Астры) |
| 2. Суд контракта | critic | **Б** (133) тех же компонентов, **К** на HEAD контракта, **Д** (если контракт правит `architecture/`) | шестой обязательный вопрос к пяти из `roles/critic.md`: **«Контракт противоречит модели?»** — (а) каждая операция/инвариант/ресурс из «## Архитектура» имеет красную клетку (матрица клетка × инвариант — в контракте); (б) писатель таблицы в контракте ∈ `writers` ресурса, зависимость ∈ `consumes`, иначе — в контракте объявлен уровень L1/L2 и правка модели; (в) уровень, объявленный в контракте, не ниже выведенного `check --base` (секции `BASELINE_MISMATCH` → §2г); (г) DRAFT-операция без схемы при изменении payload — `БЛОКИРУЕТ` | `pre_critic.sh` нога (г): `check --base` rc 1 → критик не зовётся (харнесс); остальное — role-канал `roles/critic.md` |
| 3. Заморозка | дверь | — | как в шаге 1 (отказы `freeze_contract.sh`) | механизм |
| 4. Реализация | implementer | **Б без правил (79)** своего компонента: размещение, свой контракт, сигнатуры соседей, писатели ресурсов, `structure-policy.json` (пока адаптер не заменил его) | (а) код только в `implementationPathHint` (зона); (б) зависимости только из `consumes`, таблицы — только своего ресурса; (в) **перед push — `npm run arch:conform` локально**; красное по своему диффу → либо чинить код, либо стоп и доклад оркестратору «модель не позволяет …» (не править модель — вне зоны); (г) `PLANNED_NOT_PRESENT` каталог создаёт по хинту, имена операций — из контракта модели | `check_zones.sh` (харнесс); `arch:conform` в CI проекта (§3) |
| 4а/4б. Сборка, CI | architect / CI | **С** на запушенном HEAD (артефакт полосы) | «пачка зелёная» включает `arch:conform` в мягком режиме: **новых** находок против allow-листа нет | CI проекта (без харнесса); `check_ci_gate.sh` читает check-runs (харнесс) |
| 5. Адверсарий (рисковый класс) | adversary | **Б** (79) + **С** на OBJECT | классы заглушек дополняются архитектурными: второй писатель ресурса; прямой SQL из `app/api`; обход `consumes` (вызов чужого use case); чтение без `scope_id`. Проверяет **не код, а ловушку**: если заглушка проходит тесты и `arch:conform` молчит — находка против механизма (`СОВЕТ`→ хранителю или `БЛОКИРУЕТ`, если контракт обещал ловлю) | role-канал `roles/adversary.md §Классы заглушек` |
| 5. Ревьюер | reviewer | **Б** (79), **С** на OBJECT, **Д** (если PR правит `architecture/`) | строка вердикта **`СВЕРКА-АРХИТЕКТУРЫ:`** по компоненту: размещение / зависимости / писатели / операции — «соответствует» либо «расхождение: файл:строка, что»; если PR правит модель — **«модель не подогнана под код»**: правка объяснена в коммите уровнем и причиной, не «чтобы прошло»; L2/L3 без вердикта/`РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` — `FAIL` | role-канал `roles/reviewer.md §Сверка с архитектурой` (расширение существующей нормы `СВЕРКА-СТАНДАРТОВ:`); механически — `done_contract.sh` отказ без строки |
| 6. Арбитр | arbiter | **Б** (133), **К**, **С**, обе позиции | решает **инженерное**: «код прав или модель права» на L1/L2 (например, зависимость `api.disclosures → api.identity`: добавить в модель или убрать из кода); **не решает** L3 (данные/полномочия/ресурсы) — возвращает владельцу одним вопросом с рекомендацией | устав §Арбитр (харнесс) |
| 7. done + слияние | дверь | **К** на HEAD слияния | `done_contract.sh`: вердикт reviewer со строкой `СВЕРКА-АРХИТЕКТУРЫ:`; если PR менял защищённые секции — коммит снимка с `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`; полоса `arch` зелёная (или мягкая — на этапе В1) | механизм (харнесс + CI проекта) |
| 8. После done | хранитель архитектуры | **С** на main, **К**, находки среза, `git diff` модели за срез | обзор среза (§8.2): закрыть/отклонить находки, обновить **Р**, подготовить L2-пачку и предложение снимка владельцу | role-канал + расписание (одна сессия на срез) |

**Ответ на вопрос владельца ~11:05 («а архитектору… критику, ревьюеру знать не надо?»).** Да, надо, и теперь это сказано строкой в каждой роли: architect получает полный бриф с инвариантами и обязан вывести из них клетки; critic сверяет контракт с моделью шестым вопросом; reviewer сверяет код с моделью строкой `СВЕРКА-АРХИТЕКТУРЫ:`. Разница только в объёме: авторам и судьям контракта — 133 строки, исполнителю и судьям кода — 79.

## 2. Нерешённые вопросы — варианты, рекомендация, цена

### 2а. Бриф вместо `STRUCTURE.md` или вместе; как сжать 514 строк

**Факт (прогон `brief_compact.js`):**

| Компонент | `brief` пакета | сжатый без правил | сжатый с инвариантами/правилами/negative cases |
|---|---|---|---|
| api.vehicle | 514 | 79 | 133 |
| api.identity | 414 | 71 | — |
| api.missions | 590 | 82 | — |
| api.conversations | 454 | 80 | — |
| api.disclosures | 99 | 60 | — |

Сжатие: свой контракт целиком; у соседей — только `kind → компонент via порт [ресурс]` и список имён операций; ресурсы одной строкой (owner/writers/readers/keys/class/store); требования — `id (kind, status): title`, при `--with-rules` плюс `attributes.invariants|rules|negativeCases` (это и есть сырьё для красных клеток: «Only the vehicle owner accepts VIN meaning», «NEG: Write model output directly as fact_record»). Выброшено: JSON-обёртки, `Model fitness: NOT_EVALUATED`, каталог политик с rationale, «Development handoff».

| Вариант | Плюс | Минус | Цена |
|---|---|---|---|
| А. Бриф **вместе** со `STRUCTURE.md`/`structure-policy.json` | ничего не ломает сейчас | два источника про слои/домены | 0 |
| Б. Бриф **вместо** `STRUCTURE.md`, `structure-policy.json` остаётся машинным, сверяется с фрагментом (§3.3) | один человеческий источник — модель | `STRUCTURE.md` цитируется в контрактах и `structure-policy.json` (`description`) | адаптер-проверка ~40 строк + правка contextPack (1 строка) |
| В. Бриф вместо обоих, `structure-policy.json` генерируется из фрагмента | единственный источник | загрузчик бэкенда читает формат `structure-policy.json`; генерация = изменение продукта (пауза) | генератор + норма «не править руками» |

**Предложение: Б сейчас, В — после А1.** Бриф компонента (сжатый, с правилами для architect/critic/arbiter, без — для implementer/adversary/reviewer) заменяет `STRUCTURE.md` в contextPack; `structure-policy.json` остаётся источником для загрузчика и держится проверкой «фрагмент = политика» (измерено: сегодня равны). Реализация сжатия — **в пакете `architecture/` (проект)**: `brief --compact [--with-rules]` — доделка Астры A-14 (~2 часа; прототип готов), **не** харнесс-скрипт: бриф нужен любому инструменту и человеку.

### 2б. Как определяются модули предмета

**Факт:** `logicalModules[].implementationPathHint` однозначно отображает каталог → компонент для `app/application/*`, `app/domain/*`, `server/src/`, `server/infrastructure/email/` …; `app/api/<домен>/` компонента **не имеет** (`module.app.api.ownedComponents = []`), `server/src/auth/` — тоже; `server/src/command-transport.js` попадает в `module.server.src` → `api.loader`, а `api.transport` = только `server/src/http.js`.

| Вариант | Риск |
|---|---|
| 1. Контракт называет (`АРХИТЕКТУРА: L1 api.disclosures`) | автор забыл/назвал меньше — компонент без суда |
| 2. Вычисляются по `ЗОНА`-путям через `implementationPathHint` | путь без компонента (`app/api/*`, `server/src/auth/`) → пусто; `server/src/*.js` → ложно `api.loader` |
| 3. **Оба со сверкой** | — |

**Предложение: 3.** Контракт называет; дверь заморозки вычисляет `locate(ЗОНА-пути)` и требует: вычисленное ⊆ названное (лишние названные допустимы — это зависимости); путь без компонента — именованный отказ `PATH_WITHOUT_COMPONENT: app/api/disclosures/` с выходом: (а) правило отображения `app/api/<d>/ → application-компонент домена d` (в прототипе так и сделано — это **L1-дополнение модели**: поле `httpDescriptorsFor` у модуля `module.app.api`, или фиксированная конвенция в `locate`), (б) для `server/src/auth/` — компонент (L2, хранитель). Команда `locate` — в пакете `architecture/` (`checks/cli.js locate --path …`, ~30 строк; проект). Цена: 1–2 часа Астре/хранителю + 1 нога в `freeze_contract.sh` (харнесс).

### 2в. Операции в DRAFT (нет схемы)

**Факт:** 69 DRAFT — все внутренние (контракты компонентов и worker/documents). У публичных операций payload задан OpenAPI (`wireContract`), но логическая схема компонента с ним не связана: `createInsuredAsset` одновременно `WIRE_CONTRACT_DECLARED` в `contract.public-http` и `DRAFT` в `contract.api.vehicle`. A-13 Астры (новая операция без схемы = отказ) ещё не в чекере.

| Вариант | Кто/когда | Плюс | Минус |
|---|---|---|---|
| 1. Схема в том же PR, пишет architect до заморозки (L1) | контракт | критик судит схему вместе с клетками; схема = часть красного теста | удлиняет контракт на ~0,5–1 ч на операцию |
| 2. Отдельный шаг до кода (хранитель, по реестру Р) | между срезами | предмет стартует с готовой схемой | хранитель должен угадать следующий предмет; очередь |
| 3. Код по DRAFT, схема потом | — | быстро | схема списывается с кода — модель узаконивает код; против A-13 и устава (критерий, подогнанный под код) |

**Предложение: 1 + 2, 3 запрещён для НОВЫХ и ИЗМЕНЯЕМЫХ операций.** Правило: implementer вправе писать код по операции только если (а) у неё wire-схема и предмет payload не меняет, либо (б) native-схема есть в `module.js` на замороженном HEAD. Хранитель закрывает DRAFT **впрок** по реестру для операций ближайшего среза (Э2: `api.disclosures.*`, `api.transport.command/query/subscribe`) — это и есть «отдельный шаг до кода», но без нового агента. Для публичных операций логическая схема = ссылка на wire (`wireSchemaRef`) — одна строка на операцию, не дублирование payload (**Открыто для Астры:** добавить поле связи wire ↔ логической операции; сейчас 4 операции vehicle «DRAFT» формально при полной схеме в OpenAPI). Механизм: `check --strict-new-ops` (A-13) в полосе `arch` — новая операция в `module.js` без схемы → rc 1; красный тест — контракт добавляет операцию без схемы → полоса красная.

### 2г. Код расходится с архитектурой

**Факт (прототип, §3.4):** на текущем коде расхождений 6 + 7 + 3 + 3 (без неразрешённых таблиц); среди них настоящая архитектурная задолженность (`api.identity` пишет `app.mission` — входная Mission `PARTNER_LINK`, упраздняется в Э4) и настоящие пробелы модели (`api.disclosures/api.invitations` не объявляют зависимость на `api.identity`, хотя дескрипторы зовут `application.session`).

Правило выбора «чинить код или модель» — по статусу и уровню:

| Ситуация | Кто прав по умолчанию | Действие | Уровень |
|---|---|---|---|
| Секция модели `accepted`/защищённая (writers, isolationKeys, authority, layout) и код нарушает | модель | чинить код; если нельзя в этом предмете — находка + allow-лист с номером предмета-должника | — |
| Модель `draft`/`proposed`, код прошёл тесты и ревью, расхождение — связь/операция/описание | код | architect правит `module.js` в том же PR, коммит `arch(L1): …` с причиной | L1 |
| Расхождение — границы (новый компонент/модуль, `location`, слой, `parent`, несовместимый контракт) | спор | находка → хранитель; правка отдельным коммитом, вердикт критика, новый снимок при слиянии | L2 |
| Расхождение — данные/полномочия/ресурсы/размещение/сценарии | владелец | ACP-файл находки с вопросом одной строкой; код ждёт или идёт по модели | L3 |

**Уровень выводит механизм, не автор** (`check --base`, `checks/baseline.js:27-57` — защищённые секции: `policies, authority, resources, repositoryLayout, systemModel, changeScenarios, moduleBoundaries(id, parentModule, implementationPathHint, specificationPath, locationReason, ownedComponents, applicationProfiles, capabilities, moduleFormat, loadOrder, prohibited, allowedDomains), elementBoundaries(id, kind, parent, context, layer)`):
- **L1** — `baseline PASS`, `incompatibleContracts` пусто, DRAFT не вырос. **Факт (прогон):** добавление `consumes.identity → app.application.session.api` в `disclosures/module.js` → `baselineStatus: PASS`, findings `[]`; `arch:conform` DEPENDENCY_UNDECLARED 6 → 2.
- **L2** — `BASELINE_MISMATCH: moduleBoundaries | elementBoundaries` или несовместимый контракт.
- **L3** — `BASELINE_MISMATCH: policies | authority | resources | repositoryLayout | systemModel | changeScenarios`.

**Кто вправе править `architecture/`:**

| Уровень | Пишет | Судит | Утверждает | След |
|---|---|---|---|---|
| L1 | architect предмета (зона `architecture/app/<путь компонента>/module.js`) или хранитель | critic (в суде контракта) / reviewer (в суде кода) | заморозка/done | коммит `arch(L1)` в PR предмета |
| L2 | хранитель (или architect по поручению хранителя) | critic — отдельный вердикт на дельту | слияние = новый снимок; **digest публикует владелец** (переменная репозитория — права админа) | коммит `arch(L2)` отдельно от кода + `diff`-отчёт |
| L3 | хранитель готовит дельту; **коммитит владелец** (или сессия по его слову) | critic — вердикт на дельту | `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` + новый снимок + digest | ACP-находка → коммит владельца |

**Факт, меняющий цену L2:** `moduleBoundaries`/`elementBoundaries` — защищённые секции, поэтому **любой L2 требует нового снимка и нового digest, а digest меняет только владелец**. Чтобы владелец не публиковал снимок на каждый новый компонент — **Предложение:** L2 собираются хранителем в пачку и утверждаются **один раз на срез** (конец Э-этапа); предмет, которому L2 нужен раньше, идёт на кандидатском снимке с полосой `arch` мягкой и allow-строкой «ждёт снимка № N». **Открыто (владелец):** делегировать публикацию digest сессии-оркестратору по строке `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в коммите снимка (техническая возможность: шаг CI с `environment: architecture-baseline` и ручным approve владельца — тогда «approve» и есть слово владельца, без ручного редактирования переменной).

### 2д. Кто решает спорное

**Факт:** устав `AGENTS.md §Арбитр`: «арбитр решает “как правильно”, владелец — “чего мы хотим”». Вписываю в механизм:

| Класс спора | Решает | Как вызывается | Механизм |
|---|---|---|---|
| L1: код vs модель (связь, операция, описание, схема) | арбитр | второй `FAIL` по одной причине (устав шаг 6) | вердикт арбитра — закоммиченный файл; хранитель исполняет |
| L2: границы компонентов/модулей, совместимость контрактов | арбитр по инженерии; владелец — если решение меняет порядок работ (ROADMAP) или стоит денег | то же; хранитель вносит в пачку снимка | то же |
| L3: данные (классификация, владение, isolationKeys), полномочия, ресурсы, размещение, сценарии | **только владелец** | хранитель — файл находки с одним вопросом и рекомендацией; оркестратор задаёт | `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в коммите; `check_charter.sh`/merge gate |
| «Какой инструмент/формат» (чем проверять код) | хранитель предлагает, арбитр при споре | — | — |
| Что DRAFT закрывать первым | оркестратор по ROADMAP; хранитель исполняет | — | реестр Р |

Арбитру запрещено решать L3 — он возвращает вопрос владельцу (как уже в `roles/arbiter.md §Почему не владелец`, зеркально).

## 3. Проверка «код ↔ архитектура» — проект

### 3.1 Что проверяется (классы находок)

| Класс | Что сравнивается | Источник в коде | Источник в модели | Статус точности сейчас |
|---|---|---|---|---|
| `DEPENDENCY_UNDECLARED` | компонент файла использует другой компонент | инъецированные имена `application.<d>`, `application['<d>']`, `domain.<d>` (в VM-модулях `require` запрещён — `structure-policy.json vm_forbidden_globals`) | `relationships[from=comp]` | **высокая**: 6/6 находок — настоящие (дескрипторы disclosures/invitations зовут `application.session`) |
| `DEPENDENCY_TARGET_UNMODELLED` | цель зависимости — каталог без компонента | то же | `logicalModules` | 0 находок |
| `WRITER_NOT_DECLARED` | кто пишет таблицу ресурса | SQL-литералы `INSERT INTO\|UPDATE\|DELETE FROM <schema.table>` | `resources[].writers` + отображение таблица → ресурс | **высокая по классу, но отображение — эвристика**: модель не называет таблиц ресурсов; частично есть `aggregate.*.attributes.physicalMapping` («app.insured_asset with asset_type=VEHICLE») |
| `WRITE_TABLE_UNMAPPED` | таблица без ресурса | то же | — | 19: `app.resource`, `control.party/principal/legal_entity/retention_class/schema_migration`, `app.command_receipt`, `app.outbox_event`, `app.operation`, `app.goal_version`, `app.transient_handoff` — технические/реестровые таблицы, у модели нет ресурса «транспорт/реестры» |
| `WRITE_FROM_UNMODELLED_FILE` | запись из файла без компонента | то же | `logicalModules` | 3: `server/src/auth/adapter.js` пишет `app.scope`, `app.access_context` — у `server/src/auth/` нет компонента |
| `OPERATION_UNKNOWN` | `operationId` дескриптора неизвестен модели | `operationId: '…'` в `app/api/**` | все `contracts[].operations` | 0 (все 18 есть в `contract.public-http`) |
| `OPERATION_NOT_IN_OWNER_CONTRACT` | операция не в контракте компонента-владельца | то же | `contracts[owner=comp]` | 7: `getDisclosure*` ×3, `*PartnerInvitation` ×2, `getSession`, `logoutSession` — контракты компонентов называют логические операции (`resolveAuthority`, `prepareDisclosure`), не wire-имена |
| `PLACEMENT_UNDECLARED` / `PLACEMENT_STATUS_STALE` | файл вне всех `implementationPathHint`; `PLANNED_NOT_PRESENT` при наличии файлов | дерево | `logicalModules[].repositoryObservation` | 0 на текущем дереве |
| `SCOPE_KEY_ABSENT` | SQL по `app.*` без `scope_id` (`tenantId` модели) | SQL-литералы | `resources[].isolationKeys` | **низкая**: 11 находок, из них ≥ 9 — таблицы без `scope_id` по замыслу (`app.scope`, реестры шаблонов, `transient_handoff`, `accepted_origin`) и комментарий. Нужны метаданные «таблица → ключи» — не включать в первую версию |
| `SCHEMA_MISMATCH` (запрос/ответ против схем модели) | валидаторы `app/schemas/` против native-схем | — | `schemas` | **не реализуемо сейчас**: логических схем 6, wire-схемы уже держит `app/schemas/` из OpenAPI (производные). Станет возможным после связи wire ↔ логическая операция (§2в) |

### 3.2 Как (инструмент)

**Факт:** продуктовый код — VM-выражения без `require` + CommonJS в `server/`; связи выражаются именами слоёв, инъецированными загрузчиком; SQL — строковые литералы. Поэтому «импорт-граф» классический (madge/dependency-cruiser) бесполезен; нужен разбор идентификаторов `application.X` и SQL-литералов. В проекте уже есть семейство regex-анализаторов на Python (`tests/tools/check_backend_structure.py` 553 строки, `generate_module_map.py` — уже извлекает `writer_candidate` и `operation_candidate`, 873 и 731 совпадений).

**Предложение:** `tests/tools/check_arch_conformance.py` (проект; прототип 160 строк — `out11/run/arch_conform_proto.py`): вход — `architecture/output/model.json` (из `npm run snapshot`/`render`) и дерево; выход — JSON-отчёт + rc. Вторая ступень (после А1) — AST через acorn в Node, если regex даст ложные срабатывания на комментариях (один такой случай зафиксирован: `SCOPE_KEY_ABSENT` на строке 6 комментария). Не класть в пакет `architecture/checks/` — README пакета держит инвариант «checks accept architecture models only», и это правильно: модель не должна зависеть от языка продукта.

### 3.3 Адаптер `structure-policy.fragment.json` ↔ `structure-policy.json`

**Факт:** сегодня совпадают `allowedDomains` (29 = 29), `loadOrder`, capabilities четырёх слоёв. **Предложение:** `tests/tools/check_structure_policy_sync.py` — сравнение этих четырёх полей после `npm run render`; расхождение → rc 1 с именем поля. Это держит норму «не правишь `allowedDomains`/`prohibited`/`loadOrder` без зеркала». Красный тест: добавить домен только в `structure-policy.json` → красный. Цена: 1 час.

### 3.4 Прототип на текущем коде (точность сейчас)

**Факт (прогон `arch_conform_proto.py cb snapshot.json`):** 58 файлов, 20 без компонента (`app/api/*`, `app/config`, `app/schemas`, `server/lib`, `server/main.js`, `server/src/auth/*`, миграции), 18 `operationId`, 32 ссылок на слои, 40 SQL-записей.

| Класс | Находок | Настоящих (по чтению) | Что значит |
|---|---|---|---|
| DEPENDENCY_UNDECLARED | 6 | 6 | модель: добавить `consumes.identity` у `api.disclosures` и `api.invitations` (L1). Прогон: после правки только `disclosures/module.js` остались ровно 2 находки — обе `api.invitations`; вторая такая же правка закрывает класс |
| OPERATION_NOT_IN_OWNER_CONTRACT | 7 | 7 (как расхождение именования) | модель: либо wire-имена в контрактах компонентов, либо поле `wireOperations` (L1) |
| WRITER_NOT_DECLARED | 3 | 3 | `api.identity → app.mission` (долг Э4); `api.synthetic-email → auth.message_outbox` (ресурс `resource.auth-message` принадлежит `container.delivery`, а писатель в `container.api`) — **вопрос владельцу/Астре (L3: ресурс)** |
| WRITE_FROM_UNMODELLED_FILE | 3 | 3 | `server/src/auth/` без компонента (L2: хранитель) |
| WRITE_TABLE_UNMAPPED | 19 | — | модели нужен список технических таблиц/ресурс «транспорт» или `physicalTables` у ресурсов (**L3: `resources` защищена**) |
| SCOPE_KEY_ABSENT | 11 | ≤ 2 | исключить из v1 |

**Красный тест механизма (прогон):** обманная заглушка `app/application/vehicle/evil-stub.js` (зовёт `application.missions['mission-core']` и пишет `INSERT INTO app.mission`) → +1 `DEPENDENCY_UNDECLARED`, +1 `WRITER_NOT_DECLARED`; после удаления — исходные числа. Механизм предъявлен красным.

### 3.5 Где живёт, режимы

- **Проект:** `tests/tools/check_arch_conformance.py`, allow-лист `tests/tools/arch-conformance-baseline.json` (известные находки с номером предмета-должника и причиной), шаг в `run_backend_ci.py --lane checks` (уже есть Python-полоса) или новая полоса `arch` вместе с `check --base` (А0-2). Команда для любого инструмента/человека: `npm run arch:conform` → `python3 tests/tools/check_arch_conformance.py --model architecture/output/model.json`.
- **Мягкий режим (сейчас):** rc 0, если множество находок ⊆ allow-листа; **новая находка → rc 1** (ratchet). Так полоса полезна с первого дня, не блокируя долг.
- **Жёсткий режим:** по классам — класс переводится в hard, когда его allow-лист пуст (ожидаемо `DEPENDENCY_*` и `OPERATION_*` — после L1-правок первого обзора хранителя, 1–2 дня; `WRITER_*` — после Э4).
- **Харнесс не нужен**: проверка читает модель и дерево; `.harness/` не трогает.

## 4. Граница проект / харнесс

| Предмет механизма | Проект (`Complior-back`) | Харнесс (`dev-harness`) | Другой харнесс / человек |
|---|---|---|---|
| Модель, снимок, чекер | `architecture/**`, `baseline/approved.json`, digest в переменной репозитория | — | читает README; `npm run check/brief/snapshot/diff` |
| Сжатый бриф | `architecture` CLI `brief --compact [--with-rules]` | `make_task.sh`: строка `MAP: <вывод brief>` в задании роли (генерация в пак, не чтение файла) | запускает команду сам; человек читает 79–133 строки |
| Определение компонентов по путям | `architecture` CLI `locate --path` | нога `freeze_contract.sh`: `ЗОНА` ⊆ хинтов `АРХИТЕКТУРА:` | команда доступна напрямую |
| Проверка код ↔ архитектура | `tests/tools/check_arch_conformance.py` + allow-лист + CI | `check_ci_gate.sh` читает check-run; судьи цитируют отчёт | CI проекта красный/зелёный без харнесса |
| Адаптер фрагмент ↔ policy | `tests/tools/check_structure_policy_sync.py` + CI | — | то же |
| Правила для агентов (нейтрально) | `AGENTS.md` проекта: «кодовый предмет называет компоненты архитектуры; код в `implementationPathHint`; расхождение — файл в `architecture/findings/`; уровни L1/L2/L3 и кто утверждает» — без слов «оркестратор», «freeze», «ЗОНА» | `roles/*.md`: шестой вопрос критика, `СВЕРКА-АРХИТЕКТУРЫ:` ревьюера, классы заглушек адверсария, строка `АРХИТЕКТУРА:` в контракте | человек следует `AGENTS.md`, пишет находку файлом |
| Реестр находок/DRAFT | `architecture/findings/*.md`, `architecture/REGISTER.md` (генерируемая сводка DRAFT из `check`) | хранитель как роль харнесса читает/пишет туда через PR | issue/PR/файл — любым инструментом |
| Двери (freeze/done/merge gate по снимку) | ветка `main` защищена; CI обязателен | `freeze_contract.sh`, `done_contract.sh`, `check_charter.sh` | их двери — их дело; проект требует только зелёный CI и `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` для снимка (проверяет CI проекта, не харнесс: шаг «снимок изменился → в коммите строка владельца») |

Проверка условия владельца: проект знает только о (а) модели и чекере, (б) двух своих Python-проверках в CI, (в) нейтральных правилах в `AGENTS.md`, (г) каталоге находок. Ни один файл проекта не ссылается на `dev-harness`, `.harness/`, роли или скрипты харнесса. **Открыто:** реестр пробелов `probely.md` сегодня в `.harness/plans/` — по плану прохода 10 переезжает; здесь предлагаю ему место `architecture/findings/` (не `docs/`), потому что его читатель — хранитель архитектуры.

## 5. Поток одной задачи целиком — Э2

**Факт (`.harness/ROADMAP.md` §2 Э2):** 2.1 транспортная дельта ACCESS_CONTEXT (`server/src/command-transport.js`: resolver AccessContext, owner-stream `(scope_id, owner_kind, owner_id)` в outbox вместо `mission_id`, повторная проверка допуска после lock); 2.2 Р4 — журнал показа и пошаговый gate (`app.disclosure_ack` append-only, `presentation_id`, `read-gate` с `intended_step`, publisher четырёх kinds).

### 5.1 Задача без правки границ — Р4 (2.2), ожидаемо L1

| Шаг | Кто | Читает из архитектуры | Пишет | Какая проверка что ловит |
|---|---|---|---|---|
| 0 | владелец → оркестратор | `brief --compact api.disclosures` (60 строк); реестр Р: `prepareDisclosure/acknowledgeDisclosure/requestDelivery` — DRAFT; wire-операции `getDisclosureGate`, `issueHarnessDisclosurePresentation`, `recordHarnessDisclosureExposure` (дельта h317) не в контракте компонента | задание architect: `АРХИТЕКТУРА: L1 api.disclosures (+ api.identity как зависимость)` | `make_task.sh` — отказ без строки |
| 1 | architect | бриф с правилами: `resource.disclosure` (owner/writer `api.disclosures`, keys `tenantId,userId`, class personal); `consumes`: только postgresql (нет `api.identity`!) | контракт «## Архитектура»: операции — добавить в `contract.api.disclosures` `getDisclosureGate(intended_step)`, `issuePresentation`, `recordExposure` со схемами (L1, `module.js` в зоне architect); зависимость `consumes.identity` (L1, закрывает 3 из 6 находок прототипа); клетки: по операции — схема входа/выхода; инвариант «модель нельзя вызвать без актуального показа» → негатив; «второй писатель `app.disclosure_ack`» → обманная заглушка в `app/api/` пишет напрямую → `arch:conform` WRITER_NOT_DECLARED; cross-scope чтение журнала → 404 | `freeze`: `ЗОНА app/application/disclosures/, app/api/disclosures/, architecture/app/application/disclosures/module.js, migrations/019_*` ⊆ хинтов `api.disclosures` (+ `app/api/<d>` по конвенции); `check --strict-new-ops` — новые операции без схемы → отказ |
| 2 | critic | тот же бриф; `check --base` на HEAD контракта (ожидаемо baseline PASS → L1 подтверждён) | вердикт: шестой вопрос — писатель `app.disclosure_ack` ∈ writers (да); зависимость объявлена (да, в контракте); клетка на каждый инвариант (матрица) | `pre_critic`: `check` rc ≠ 1 |
| 3 | дверь | — | `frozen/…` | — |
| 4 | implementer | бриф без правил; `structure-policy.json` | код в `app/application/disclosures/`, дескрипторы, миграция; `npm run arch:conform` локально до push | `check_zones.sh`; `arch:conform` в CI: новых находок нет (allow-лист не растёт) |
| 5 | adversary (Р4 рисковый: юридически значимое) | бриф + отчёт conform | заглушки: писатель журнала из `app/api/` (должен быть пойман conform); «показ» без `presentation_id`; обновление текста стирает прошлое доказательство → клетка append-only | role-канал |
| 5 | reviewer | бриф, conform на OBJECT, `diff` модели (PR правит `module.js`) | `СВЕРКА-АРХИТЕКТУРЫ: api.disclosures — размещение соответствует; зависимости соответствуют (consumes.identity добавлен в модели коммитом arch(L1) с причиной, не подгонка); писатели — соответствует; операции — 3 добавлены со схемами` | `done_contract.sh` — без строки нет done |
| 7 | дверь | `check --base` на main: baseline PASS, DRAFT 69 → 66 | `done/…`, слияние | полоса `arch` мягкая |
| 8 | хранитель | conform на main; `git diff architecture/` за срез | обновляет реестр Р; отмечает, что `api.disclosures` закрыт по схемам | — |

### 5.2 Задача, требующая правки архитектуры (L2) — транспортная дельта 2.1

**Факт:** код предмета — `server/src/command-transport.js`; в модели `api.transport` = `server/src/http.js` (`module.transport`), а `server/src/` целиком — `api.loader`. Контракт `contract.api.transport` (`command/query/subscribe`, DRAFT) описывает именно команду/квитанцию/подписку. Расположение компонента не совпадает с файлом → `arch:conform` отнесёт правки к `api.loader`, а `semanticInvariants` транспорта не будут судимы. Это **L2**: `implementationPathHint`/`ownedComponents` — секция `moduleBoundaries`.

| Шаг | Кто | Что происходит |
|---|---|---|
| 0 | оркестратор | бриф `api.transport` (DRAFT ×3) и `api.loader`; видит, что файл предмета не в хинте `api.transport` → задание: `АРХИТЕКТУРА: L2 api.transport` + запрос хранителю |
| 0′ | хранитель | готовит L2-дельту **до** контракта: `module.transport` получает `location`/хинт на `server/src/command-transport.js` (или `server/src/transport/` с переносом — тогда это ещё и код: нет, пауза; остаёмся на файле) + `locationReason`; схемы `command/query/subscribe` (L1 заодно) с owner-key `(scope_id, owner_kind, owner_id)`; `npm run diff` → отчёт; коммит `arch(L2): transport owns command-transport.js` в отдельной ветке; critic — вердикт на дельту (шестой вопрос); слияние дельты → `check --base` на main: `BASELINE_MISMATCH: moduleBoundaries` — **полоса `arch` красная до нового снимка** |
| 0″ | владелец | публикует снимок: `npm run snapshot -- --out architecture/baseline/approved.json`, коммит со строкой `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: architecture/baseline/approved.json L2 transport`, обновляет `ARCH_BASELINE_DIGEST` (или approve в environment — §2г Открыто). Если не хочет сейчас — предмет 2.1 идёт с allow-строкой «ждёт снимка», полоса мягкая |
| 1–7 | как в 5.1 | architect получает уже верный бриф `api.transport` с хинтом на свой файл; клетки — из `semanticInvariant` транспорта и схем `command` (две одинаковые команды → одна запись; kill до commit — ни receipt, ни outbox — это из ROADMAP, становится инвариантом контракта модели) |
| 8 | хранитель | обзор: `WRITE_TABLE_UNMAPPED` для `app.command_receipt`/`app.outbox_event` → предложение ресурса «transport» (L3: `resources`) владельцу одной строкой |

Разница с L1: правка модели идёт **отдельным коммитом до контракта**, судится отдельно, требует снимка владельца; код предмета модель не трогает.

## 6. Порядок внедрения и предметы

Переложено с учётом: всё в `architecture/`; пилот `vehicle` — после Э2–Э5 (слово ~11:05); минимальный первый шаг, полезный на Э2.

| № | Предмет | Проект / харнесс | Красный тест (механизм предъявляется красным) | Цена | Когда |
|---|---|---|---|---|---|
| В0 | **Полоса `arch` в CI (А0-2)**: `npm ci` в `architecture/`, `check --base baseline/approved.json --base-digest $ARCH_BASELINE_DIGEST`, `render` + `git diff --exit-code` на `structure-policy.fragment.json`; мягкая | проект | в клоне правка `system/authority.js` без снимка → `BASELINE_MISMATCH`, rc 1 → полоса красная | 2 ч | сразу, до Э2 |
| В1 | **`check_arch_conformance.py` + allow-лист + шаг в полосе `checks`/`arch`**; классы v1: DEPENDENCY_*, WRITER_*, WRITE_FROM_UNMODELLED_FILE, OPERATION_*, PLACEMENT_* | проект | заглушка из §3.4 (`evil-stub.js`) → rc 1 при пустом приращении allow-листа; удаление заглушки → rc 0 | 1 день (прототип есть) | до старта Э2 |
| В2 | **`brief --compact [--with-rules]` и `locate --path`** в пакете (Астра A-14/A-15) | проект (`architecture/`) | `brief --compact api.vehicle` ≤ 150 строк, содержит все 4 операции и 3 инварианта (тест в `checks/test/`); `locate app/application/vehicle/x.js` → `api.vehicle`, `locate app/api/vehicle/x.js` → `api.vehicle`, `locate server/src/auth/x.js` → `PATH_WITHOUT_COMPONENT` | 3–4 ч | до Э2 |
| В3 | **`check_structure_policy_sync.py`** (§3.3) | проект | домен добавлен только в `structure-policy.json` → rc 1 | 1 ч | с В1 |
| В4 | **Харнесс: строка `АРХИТЕКТУРА:` обязательна в кодовом контракте бэкенда; `make_task` печатает бриф в пак роли; `freeze` сверяет `ЗОНА` ⊆ хинтов; `pre_critic` нога `check` rc ≠ 1; `done` требует `СВЕРКА-АРХИТЕКТУРЫ:`** | харнесс | фикстуры: контракт без строки → `ARCH_LINE_MISSING`; `ЗОНА app/application/session/` при `АРХИТЕКТУРА: api.disclosures` → отказ заморозки; вердикт ревьюера без строки → отказ done | 1 день | до Э2 (один контракт харнесса) |
| В5 | **Роли**: critic — шестой вопрос; reviewer — `СВЕРКА-АРХИТЕКТУРЫ:`; adversary — архитектурные классы заглушек; architect — вывод клеток из брифа; `AGENTS.md` харнесса — абзац «Архитектура — вход и дверь» | харнесс (role/charter-каналы по ПРОВОДКЕ) | cognitive-only + механические ноги В4 | 2 ч | с В4 |
| В6 | **Хранитель архитектуры**: `roles/architecture-steward.md` (харнесс), `architecture/findings/README.md` + первый обзор: закрыть L1-находки В1 (consumes identity, wire-имена операций), подготовить L2-пачку (`server/src/auth/` компонент, `command-transport.js` в `api.transport`), реестр DRAFT для Э2 | оба | обзор № 1 коммитом: allow-лист В1 уменьшился на ≥ 6 строк без правки кода (только модель L1) и `check --base` остался PASS | 1 день | до Э2 |
| В7 | **Схемы операций Э2 впрок** (хранитель): `api.disclosures` ×3 + новые Р4; `api.transport` ×3 | проект | `check` DRAFT 69 → ≤ 63; `--strict-new-ops` красный на операции без схемы | 1 день | начало Э2 |
| В8 | **Э2 по механизму** (5.1, 5.2) — первый срез через архитектуру | — | меры: вызовы критика, круги, часы против базы 152–154; новых находок conform в allow-листе — 0 | — | Э2 |
| В9 | **Снимок № 2** (L2-пачка Э2) — владелец | проект | `check --base` PASS с новым digest; старый digest → `BASELINE_DIGEST_MISMATCH` | 15 мин владельца | конец Э2 |
| В10 | Э3–Э5 по механизму; `WRITER_*` в жёсткий режим после Э4 (уходит `api.identity → app.mission`) | — | allow-лист класса пуст → класс hard | — | Э3–Э5 |
| В11 | **Пилот `vehicle`** (бывший А1): валидаторы из native-схем, `SCHEMA_MISMATCH`, каркас `app/domain/vehicle/` по хинту | проект | валидатор отвергает тело вне схемы модели; conform ловит дескриптор без операции | 1–2 нед. | после Э5 |
| В12 | `structure-policy.json` производный от фрагмента (вариант В §2а); полоса `arch` блокирующая после 5 зелёных слияний | проект | ручная правка policy → `git diff` красный | 1 день | после пилота |

Минимальный первый шаг, дающий пользу на Э2: **В0 + В1 + В2 + В4** (≈ 3 дня): с первого контракта Э2 architect получает бриф 60–133 строк вместо 514 + `STRUCTURE.md`, дверь заморозки не пропускает контракт без компонентов, CI ловит второго писателя и необъявленную зависимость.

## 7. Открытые решения владельца (коротко, с рекомендацией)

1. Новых ролей-исполнителей не заводить; одна постоянная роль — хранитель архитектуры (§8). **Рекомендую да.**
2. Хранитель — на модели Астры (`@gpt-astra`, тир `plan`), не Fable. **Рекомендую Астру** (§8.1).
3. Бриф компонента заменяет `STRUCTURE.md` в контексте агентов; `structure-policy.json` остаётся машинным и сверяется с фрагментом. **Рекомендую да.**
4. Код по DRAFT-операции запрещён для новых/изменяемых операций: схема в `module.js` до заморозки (L1) или впрок хранителем. **Рекомендую да.**
5. L2 собираются в пачку и утверждаются снимком **раз на срез**; предмет раньше снимка — на мягкой полосе с allow-строкой. **Рекомендую да.**
6. Публикация digest: вручную владельцем в переменной репозитория **или** approve в GitHub environment (слово = клик). **Рекомендую environment** — тот же акт воли, меньше ручной работы.
7. Канал находок — файлы `architecture/findings/` в репозитории проекта (не issues: на станции `gh` без токена, файл работает оффлайн и для человека). **Рекомендую файлы**; зеркало в issues — по желанию.
8. Ресурсы модели получают `physicalTables` (или отдельный список технических таблиц) — секция `resources` защищена, значит это ваш снимок. **Рекомендую да, одним снимком вместе с В9.**
9. Ресурс `resource.auth-message`: владелец `container.delivery`, а писатель в коде — `server/infrastructure/email/worker.js` (`container.api`). Кто прав? **Рекомендую: код (Р2/153 — outbox в API-контейнере), модель L3 — поправить владельца ресурса.**
10. Conversation: `userId` для M1 / участники / гибрид — `CASE-PARTICIPANTS-ANSWER.md`. **Рекомендую гибрид** (ключи модели + явное поле участия без логики).

## 8. Кто ведёт архитектуру постоянно — хранитель архитектуры

**Факт:** сегодня — никто. Автор модели — Астра с владельцем (`architecture/DECISIONS.md`, `REVIEW-RESPONSE.md`); я — ревизор проходов 7–10; роли прохода 9 реактивны. Реестр пробелов `probely.md` ведётся разведками по случаю. 69 DRAFT, 6 схем, расхождения §3.4 — лежат без владельца.

### 8.1 Кто

**Предложение:** роль `architecture-steward` (хранитель архитектуры) — **постоянная роль харнесса, субагент по расписанию** (одна сессия на обзор), модель **Астра (`@gpt-astra`, тир `plan`, fallback `@fable`)**. Почему Астра: она автор модели и держит в контексте решения Word v2.5 → 2.4.1 (`reference/coverage.json`, `DECISIONS.md`); цена ошибки «не понял, почему так» у чужой модели выше, чем независимость. Независимость обеспечена не моделью, а тем, что хранитель **не пишет код и не судит предметы**: его дельты судит critic (другая модель), снимок публикует владелец. Fable остаётся ревизором механизма (по вызову владельца), не хранителем: ревизор, ведущий предмет, — сторона.

### 8.2 Обязанности

| Обязанность | Когда | Выход | Механизм |
|---|---|---|---|
| Приём находок (`architecture/findings/NNN-*.md` от любой роли и человека) | непрерывно; разбор — в обзоре | статус в файле находки: `принята L1/L2/L3 | отклонена: причина | вопрос владельцу` | файл без статуса старше одного среза → строка в отчёте обзора (скрипт `findings_status.py`, rc 1) |
| Обзор после каждого среза (`done` последнего предмета Э-этапа) | 1 сессия на срез | `architecture/reviews/<дата>-<Э>.md`: что изменилось в модели за срез (`diff`), что показал `arch:conform` на main, какие находки закрыты, L2-пачка на снимок, DRAFT-реестр на следующий срез | обзор — коммит; отсутствие обзора после `done` этапа — находка оркестратора |
| L1-правки модели вне предмета (связи, описания, wire-имена операций, схемы впрок) | по реестру, до предмета, которому нужны | PR `arch(L1): …`, judged by critic (шестой вопрос), слияние | `check --base` PASS, `--strict-new-ops` |
| L2-дельты и пачка снимка | конец среза | ветка `arch/l2-<Э>`, `diff`-отчёт, вердикт critic, предложение владельцу «снимок № N: что входит, что меняет» одной страницей | `BASELINE_MISMATCH` до снимка — полоса красная ровно до акта владельца |
| L3-вопросы владельцу | по мере находок | один файл — один вопрос — одна рекомендация (как `out7/OWNER-QUESTIONS…`) | `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` |
| Реестр DRAFT и недостающих контрактов | генерируется (`check` → `contractReadiness.unresolved`), хранитель расставляет приоритеты по ROADMAP | `architecture/REGISTER.md`: операция, компонент, нужен для Э?, кто закрывает, срок «до контракта X» | `REGISTER.md` сверяется с `check` в CI (устаревший реестр — красный) |
| Сверка Word/3.17/4.1 ↔ модель при решениях владельца | при каждом слове владельца, меняющем архитектуру | строка в `DECISIONS.md` + дельта | — |

### 8.3 Канал находок — нейтральный к харнессу

**Предложение:** `architecture/findings/<NNN>-<slug>.md`, грамматика фиксирована (6 полей): `Компонент/ресурс`, `Наблюдение` (файл:строка или команда с выводом), `Ожидание модели` (поле модели), `Предлагаемый уровень` (L1/L2/L3 — предварительно; окончательно выводит `check`), `Автор` (роль или человек), `Статус`. Номер — из механизма (`next_id`-подобный счётчик в проекте: `ls findings | tail` недопустим по правилу 5 → простой `node architecture/checks/cli.js finding new <slug>` создаёт файл с номером = max+1 под lock, или номер PR). Почему не issues: (а) на станции `gh` требует токен (проверено: «set GH_TOKEN»), (б) находка должна жить рядом с моделью и переживать смену хостинга, (в) человек и любой инструмент умеют написать файл. Проверка условия «проект о харнессе не знает»: грамматика не содержит ролей харнесса — поле «Автор» свободное.

### 8.4 Как находка становится правкой

```mermaid
flowchart LR
  F[находка: файл architecture/findings] --> S[хранитель: разбор, уровень по check --base]
  S -->|L1| P1[PR arch(L1) хранитель/architect] --> C1[critic: шестой вопрос] --> M1[слияние; baseline PASS]
  S -->|L2| P2[ветка arch/l2-Э, diff] --> C2[critic: вердикт на дельту] --> O2[владелец: снимок + digest] --> M2[слияние]
  S -->|L3| Q[вопрос владельцу одной строкой] --> O3[РАЗРЕШИЛ-ВЛАДЕЛЕЦ + снимок]
  S -->|отклонена| R[статус в файле, причина]
  S -->|спор| A[арбитр инженерное / владелец воля]
```

Кто пишет: L1 — хранитель или architect предмета; L2 — хранитель; L3 — хранитель готовит, коммитит владелец. Кто судит: critic (всегда другая модель, чем автор дельты — Астра vs GLM/Codex по `agent_models.json`). Кто утверждает: L1 — слияние по вердикту; L2/L3 — владелец снимком.

### 8.5 Цена и как не превратить в бюрократию

- Цена: одна сессия хранителя на срез (Э-этап ≈ 1–3 недели) ≈ 2–4 часа модели `plan`; L1 впрок — по 0,5–1 ч на операцию; обзор — 1 ч. На Э2–Э5 ≈ 4 обзора + ~15 схем ≈ 20–30 часов модели за два месяца.
- Против бюрократии: (а) находка — файл из 6 строк, без формы заявки; (б) L1 **не ждёт** хранителя — architect правит в своём PR; (в) хранитель не судья предметов и не дверь: ни один `freeze/done` не ждёт его подписи; (г) снимок — раз на срез, не на правку; (д) реестр генерируется, не ведётся руками; (е) обзор привязан к `done` этапа, не к календарю; (ж) если находок за срез ноль — обзор одной строкой.
- Связь с §2г/§2д: хранитель — исполнитель решений, не их источник: L1 решает проверка и critic, L2 — critic + владелец снимком, L3 — владелец; спор — арбитр. Хранитель предлагает и оформляет.

## Приложение A. Что из прохода 9 отменено или изменено

| Проход 9 | Проход 11 | Причина |
|---|---|---|
| описание рядом с кодом + `architecture/` для системного контура | всё в `architecture/` | слово владельца ~01:40 |
| три роли `arch-changer/conformer/scaffolder` | ни одной; хранитель как владелец предмета | §1.1; роли без механизма ловли |
| пилот `vehicle` первым (А1) | после Э2–Э5 (В11) | слово владельца ~11:05 |
| `arch_level.sh` в харнессе | уровень читается из секций `check --base` (проект), харнесс только читает | граница проект/харнесс |
| бриф «≤ 300 строк» | измерено: 79/133 | прогон |

## Приложение B. Факты прототипа (воспроизводимо)

```
cd out11/run/cb/architecture && npm ci && npm run snapshot -- --out ../../snapshot.json
cd ../.. && python3 arch_conform_proto.py cb snapshot.json conform-report.json
# {"DEPENDENCY_UNDECLARED":6,"OPERATION_NOT_IN_OWNER_CONTRACT":7,"SCOPE_KEY_ABSENT":11,
#  "WRITE_TABLE_UNMAPPED":19,"WRITER_NOT_DECLARED":3,"WRITE_FROM_UNMODELLED_FILE":3}
node brief_compact.js cb/architecture api.vehicle | wc -l            # 79
node brief_compact.js cb/architecture api.vehicle --full-requirements | wc -l   # 133
```
