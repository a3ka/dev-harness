accept
Реализация 119 (Complior-back, ветка cmp-bck-315/import, HEAD d10612a3eff5c729653f0fe746e09486980ad83a, база 0ed762b8cb) принята против замороженного 119/1 (`frozen/contracts/119/1` = 4f7079039; блоб контракта на теге == main: y; каталог батареи с тега не менялся: пусто). Все пункты §Приёмка, которые можно исполнить, перезапущены мной в одноразовых клонах; счётные утверждения отчёта перемерены своей мерой (PyYAML/jq/python multiset, а не grep/awk оракула) и совпали.
ОДНАКО СЛИЯНИЕ В main Complior-back БЕЗ РЕШЕНИЯ ПО П-1/П-2 СДЕЛАЕТ КРАСНЫМИ ДВА ОБЯЗАТЕЛЬНЫХ lane CI. Это дефект контракта (зона), а не реализации: нужен 119 v+1 либо отдельный предмет до слияния (см. §Заявки).

Судимое: OBJECT d10612a3eff5c729653f0fe746e09486980ad83a; клоны /tmp/dev-harness-verify/Rev119/{repo,repo2} (`git clone --local` из Impl119/back); клон implementer'а не изменён.

## 1. Область правки (дифф ⊂ ЗОНА)

`git diff --name-status 0ed762b8cb..HEAD` → 28 файлов, все под `docs/`, `tests/tools/`, `tests/spec-3.15/`, `structure-policy.json`, `FILES.sha256`. app/, server/, migrations/, tests/spec-3.14/, tests/historical-server/ — пусто (`git diff --name-only 0ed762b8cb -- app server` → []; `git diff --name-status 0ed762b8cb -- migrations/` → []).
- structure-policy.json: изменена одна строка (добавлена запятая) + одна новая строка-ключ `tests/spec-3.15/` — ровно в пределах ПЕРЕСЕЧЕНИЯ.
- Удалённые артефакты: `evidence/contracts/20261021T033922.399464Z/{contract-validation,manifest}.json` (корневой `evidence/` — ВНЕ зоны) и `docs/evidence/ux175/20261021T033913.003348Z/results.json` ДОБАВЛЕНЫ промежуточным коммитом 1251379 и УДАЛЕНЫ коммитом 4d5517c. В итоговом диффе их нет. → находка R-5 (замечание).
- Авторство: у всех 4 коммитов `implementer <implementer@dev-harness.local>`; в каждой теме есть «119».

## 2. Сырой вывод: приёмка перезапущена мной (rc)

| п. | Команда | rc | Вывод |
|---|---|---|---|
| 1/7 | `IMPORT315_119_BACK=…/Rev119/repo bash red_import315_119.sh` | 0 | `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product` / `ИТОГ 119 (продукт): rc=0` (55 с; git status до/после 0/0, индекс тот же) |
| 7 | `LC_ALL=C bash import315_oracle.sh …/Rev119/repo` | 0 | та же строка IMPORT315_OK |
| 2 | `red_import315_119.sh --model` | 0 | `ИТОГ 119: клеток 23, зелёных 23, красных 0` |
| 3 | `--cell net-takoj-kletki` | 2 | `ОТКАЗ: неизвестная клетка` |
| 4 | `IMPORT315_119_ORACLE=stab_vsegda_zelenyj.sh … --model` | 1 | `зелёных 1, красных 22` |
| 4 | `…stab_vsegda_krasnyj.sh … --model` | 1 | `зелёных 1, красных 22` |
| 5 | контрмодель `sed '/ADDITIV-315-BEG/,/ADDITIV-315-END/d'` → `--cell d13-sql-izmenen` | 1 | клетка КРАСНАЯ, факт `rc=0 IMPORT315_OK … pin=toy`: слепота контрмодели к аддитивности видна |
| 7 | `python3 tests/tools/generate_derived.py --check` (чистое дерево) | 0 | `Derived files: 675 (расхождений: 0)` |
| 7 | `python3 tests/spec-3.15/validate_import_315.py` | 0 | `PASS_STATIC … 233 (ядро 163 + extension 70), схем 566, потребителей 123 (53 + 70), известных проблем 14, known-failures=0 failures=[]` |
| 7 | `jq '{failure_ids,fingerprints}' tests/tools/contract-validator-known-failures.json` | 0 | `{"failure_ids":[],"fingerprints":{}}`; файл относительно базы не менялся |
| 8 | `pre_critic.sh` / `check_precision_gate.sh` / `check_threat_model.sh` (клон харнесса) | 0/0/0 | `дверь зелёная` / `OK` / `ЗАЩИЩАЕТ 7, НЕ ЗАЩИЩАЕТ 7` |
| 6 | Б1 live_b1.sh | NOT_RUN мной | обходы круга 1/2 покрыты клетками d2/d11/d12/d18–d23 прогона п.2 (все зелёные) |

Затронутые барьеры продукта (скоуп-регресс, HEAD против базы 0ed762b8cb, repo2):

| Проверка | HEAD rc | База rc |
|---|---|---|
| check_backend_structure.py | 0 «соответствует, файлов 47» | 0 |
| check_backend_standards.py --root . | 0 «соответствует» | 0 |
| verify_handoff.py | 0 | 0 |
| validate_alignment_11782_31422.py | 0 PASS_STATIC | 0 |
| validate_invitation_target_31421.py | 0 PASS | 0 |
| verify_ux175.py | 0 | 0 |
| **tests/spec-3.14/validate_contract_v3_9.py** | **1 FAIL_STATIC, 393 отказа** | 0 PASS_STATIC, 0 |

Нормы продукта docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md в диффе не трогались; оба барьера, которые их исполняют, зелёные.

## 3. Счётные утверждения: моя мера (count.sh — PyYAML/python, не grep/awk оракула)

- Операции: в published 233, в базе 163, в extension 70; `cur == base ∪ ext` True; base∩ext = 0; семантически изменённых базовых операций 0 (сравнение разобранных объектов).
- Схемы: 566 = 496 + 70, набор ключей сходится; изменённых базовых схем 0. components.parameters: 11 = 10 + 1 (PlatformContract), изменённых базовых 0.
- Consumers: в базе 53 (уникальных 53), сейчас 123. Потеряно 0, сохранено дословно (jq -Sc) 53, новых 70; мультимножество python: lost 0, new 70. Новые: 68 `AWAITING_FRONTEND_ACTION_ID NOT_RUN null` + 2 `INTERNAL_SERVICE NOT_RUN null`, adoption_status нет ни у одной. new-consumers.json дословно равен `new_operation_consumers` бандла (70/70, identical True).
- operation-index: полных строк базовых операций изменено 0; изменились только `source_sha256` и `operation_count`. api-examples: 248 базовых строк, потеряно или изменено 0.
- physical-model: tables 29, owner_role отсутствует у 0; sha256 равен файлу бандла. Extension sha256 `46c2e9a5…` равен бандлу. core.openapi.yaml sha256 равен published @0ed762b8cb (`3357412c…`). docs/history/3_14/{yaml, VERSION_MANIFEST, bindings, index} побайтово равны git-базе. bundle-VERSION_MANIFEST, bundle-baseline-lock и delivery-plan равны байтам бандла.
- FILES.sha256: 675 строк = вывод генератора «675 files».

## 4. Не переписаны ли проверки под код

- validate_alignment_11782_31422.py и validate_invitation_target_31421.py. Число вызовов require/ok: база 44/16, HEAD 44/16. Построчный `git diff -U0` показывает только смену путей `docs/contracts/*`, `docs/VERSION_MANIFEST.json` → `docs/history/3_14/*` и докстринг. Ни одно утверждение или литерал (163, 19, 3.14.2.2, 173…) не изменён. Источник — ASTRA §6.2 шаг 8 («направить на исторический snapshot»). → R-3 (совет).
- known-failures.json не изменён. validate_import_315.py и known-issues-315.json — новые; базы для сравнения нет.
- Красное своей мерой, мутациями, которых нет у проб оракула (mutations.sh, repo2, после каждой reset):
  m1 удаление ПОСЛЕДНЕЙ базовой consumer-записи → validator rc 1;
  m2 смена adoption_status базовой записи #10 → rc 1;
  m3 новая запись с confirmed_5_8_4 → rc 1;
  m4 вставка строки в блок базовой операции revokeApproval → validator rc 1 и `--check` rc 1;
  m5 непустой known-failures → rc 1;
  m6 устаревший operation-index → `--check` rc 1, писатель rc 0 с diff [] после записи, повторный `--check` rc 0;
  m7 правка extension (добавлена схема) → `--check` rc 1 (4 расхождения);
  m8 `manifest.operations=232` → validator rc 1 и `--check` rc 1.
  Чистое дерево: rc 0/0; финальный porcelain 0.
- В generate_derived.py и validate_import_315.py нет распознавания проб: grep `oracle|probe|stale|[0]` даёт только штатные STALE-списки и индексы примеров, а не маркеры проб оракула.

## 5. Находки (каждая с классом)

- **R-1 (дефект контракта → 119 v+1 или новый предмет; блокирует СЛИЯНИЕ, не реализацию).** Обязательный lane `package` (`@contract-validator` → tests/spec-3.14/validate_contract_v3_9.py) после импорта красный.
  - Моя мера: HEAD rc 1 FAIL_STATIC, 393 отказа = 70 ext-операций × {consumer_resolution, problem, contract_scope_policy, response_example} + 37 × {request_example, command_idempotency, cas} + current_exact_version + all_illustrative_body_examples_generated. Отказов по базовым операциям 0. На базе rc 0, 0 отказов.
  - Спрятать отказы в known-failures нельзя по самому контракту (failure_ids=[]), к тому же `run_backend_ci.py` запрещает расширять базу относительно origin/main.
  - Обязанность идёт от слова владельца п.2 («валидатор known-failures=0») и ASTRA §6.2 шаг 6. Зона 119 не включает tests/spec-3.14/. Это заявка implementer'а №2: она обоснована, это не дефект реализации.
- **R-2 (дефект контракта → новый предмет или решение владельца app/; блокирует СЛИЯНИЕ).** Lane `backend` «производный контракт = корневой OpenAPI» (`node tests/tools/gen-contracts.js --check`) после импорта будет красным.
  - Моя мера: app/schemas/source.json `source_sha256=3357412c…`, а published на HEAD = `0cb42f7b…`.
  - Сам gen-contracts.js не запущен: в клоне нет node_modules. Красный rc — [INFERENCE] из несовпадения sha.
  - app/ исключён словом владельца п.3, хотя по ASTRA §6.2 шаг 3 app/schemas — выход той же цепочки генерации. Это заявка №1: обоснована, не дефект реализации. Нужен отдельный предмет «регенерация app/schemas под 3.15» (владелец app/) либо явное ПЕРЕСЕЧЕНИЕ app/schemas/ (только производные) в v+1.
- **R-3 (совет, принятый остаток).** Два версионных валидатора теперь судят неизменный снимок 3.14. Против АКТИВНОГО дерева их утверждения («backend action IDs», паритет deprecated и delivery_wave индекса) стали константой. Сейчас покрытие держится косвенно: `--check` (index производен от published) плюс поблочная аддитивность. Мера: actions текущих bindings == history: y. Путь разрешён §6.2 шаг 8; в 120 или следующем предмете стоит мигрировать current-утверждения явно.
- **R-4 (вопрос владельцу / v+1, не дефект реализации).** Активный VERSION_MANIFEST несёт `package_version 3.14.2.2, openapi 5.8.4` при 233 операциях, а снимок history тоже 3.14.2.2 при 163. Два манифеста одной версии описывают разное содержимое. ASTRA §6.2 шаг 4 говорит «обновить package/API versions», бандл объявляет `3.15 / 5.9.0`. В замороженных инвариантах 119 целевого значения нет: implementer не мог его выбрать без слова владельца. Нужна строка владельца, какое значение (3.15? смешанный профиль 5.8.4 + 5.9.0), и запись её в v+1 или 120.
- **R-5 (замечание по атомарности, принятый остаток).** Коммит 1251379 вносит вне зоны корневой `evidence/contracts/…` и timestamp-артефакт ux175, 4d5517c их удаляет. В итоговом диффе их нет.
  - Squash для очистки истории НЕ рекомендую: инвариант оракула «родитель первого core-коммита = 0ed762b8cb» при squash или rebase на c525fd8d43 ломается ([INFERENCE] по тексту инварианта; не прогонял).
  - Сливать надо настоящим merge.
- **R-6 (дефект контракта, принятый остаток).** `provenance/KNOWN-ISSUES-DECLARED.json` не взят из бандла. В бандле такого файла нет: моя мера `find … -iname '*known*'` → 0 из 46 файлов. Файл собран из ASTRA §5.2 с честной пометкой в `comment`. Следствие: проверка «⊇ declared» не независима от пина (declared = те же 11 id). Раскладка контракта предполагала файл бандла, которого нет; в v+1 надо назвать его «декларацией из отчёта».
- **R-7 (вне зоны, совет для интеграции).** В корневом STRUCTURE.md строка 18 перечисляет только `tests/spec-3.14/`; нет `tests/spec-3.15/`, `docs/history/`, `docs/plans/`. Файл вне зоны 119; check_backend_structure зелёный, так что это дрейф описания, а не барьер.
- **R-8 (дефект батареи, зона architect, совет).** import315_oracle.sh сортирует под `LC_ALL=C`, но `comm` вызывает в унаследованной локали. На продукте (en_US.UTF-8) это 12 строк `comm: … not in sorted order`. Моя мера (comm_locale.sh): на данных продукта множества совпадают в C и en_US (lost 0 / kept 53 / new 70), все 53 пробы с удалением одной записи пойманы в обеих локалях, то есть ложного зелёного нет. Чинится `LC_ALL=C` на `comm` (или export в шапке). Предмет архитектора, на приёмку 119 не влияет.

## 6. Заявки на выход из зоны и открытые вопросы — решение

| Вопрос | Класс | Что нужно |
|---|---|---|
| Заявка 1: app/schemas (gen-contracts.js) | дефект контракта (R-2) | новый предмет или решение владельца app/ ДО слияния в main; иначе lane backend красный |
| Заявка 2: tests/spec-3.14/validate_contract_v3_9.py | дефект контракта (R-1) | 119 v+1 (ПЕРЕСЕЧЕНИЕ на миграцию валидатора на смешанные профили, ASTRA §6.2 шаг 6) или отдельный предмет ДО слияния; known-failures не трогать |
| package_version 3.14.2.2 | вопрос владельцу (R-4) | слово владельца о целевом значении → v+1/120 |
| KNOWN-ISSUES-DECLARED из отчёта | принятый остаток (R-6) | уточнить формулировку в v+1 |
| база 0ed762b8cb против c525fd8d43 | принятый остаток с инструкцией | Мой прогноз (merge_forecast.sh): настоящий `merge --no-ff` в c525fd8d43 проходит без конфликтов; FILES.sha256 автослиянием уже согласован (`--check` rc 0, 682 файла; писатель ничего не меняет); оракул на слиянии rc 0 IMPORT315_OK. Сливать merge, не squash/rebase (R-5); после merge прогнать генератор (no-op) |

## 7. Паразитная сложность (050) — по артефактам диффа

- tests/spec-3.15/validate_import_315.py:
  1) инвариант «валидатор поведенчески» (validator-kreven, пробы а/б);
  2) состояния нет, читает дерево, вывод failures + rc;
  3) при правке свойства меняются вместе с ним оракул и пин (архитектор), рост 0;
  4) интерфейс: без аргументов, rc 0/1; за ним 197 строк проверок — глубокий;
  5) потребитель — п.7 приёмки и пробы оракула.
  Частично повторяет логику оракула, но контракт требует валидатор на стороне дерева. ESSENTIAL.
- tests/spec-3.15/known-issues-315.json:
  1) Б5 (⊇ 11 id пина);
  2) данные, явные;
  3) 1 файл;
  4) н/п;
  5) оракул known-issues-nepolnyj.
  ESSENTIAL.
- tests/tools/generate_derived.py (+`--check`, текстовое слияние extension):
  1) Б2 «единый генератор с --check»;
  2) STALE — явный список, печатается;
  3) 1 файл, второго writer'а нет;
  4) +1 флаг, за ним вся генерация — глубокий;
  5) оракул и CI `@derived`.
  ESSENTIAL.
- docs/sources/backend-3.15/* (9 файлов, одна семья): (1) каждый назван в §Раскладка (core, extension, lock, new-consumers, declared-counts, provenance×4); (2) данные; (3) генератор читает core, extension и new-consumers; (5) оракул и генератор. ESSENTIAL.
- docs/history/3_14/* (4 файла): (1) yaml и манифест требует инвариант истории. bindings и index сверх буквы контракта, но их читают validate_import_315.py и перенаправленные валидаторы как базу без git; (3) неизменяемы. ESSENTIAL (более простая форма «читать git-базу» не годится для валидатора дерева без истории — в CI copy `@derived` делается `git init`).
- docs/data/physical-model.json, docs/plans/delivery-plan-3.15.json, docs/CHANGE_REGISTER_3_15_RU.md: §Раскладка / §6.1. Байты бандла; у change register добавлена шапка происхождения. ESSENTIAL.
- Ключ манифеста `import_3_15`: читает validate_import_315.py (extension_sha256). ESSENTIAL.
- ACCIDENTAL-находок нет.

## 8. ПРОВОДКА

guard=`fixtures/workshop_project/import315_119/red_import315_119.sh` существует; он барьер именно этого предмета. `--model` rc 0 (23/23), стаб-оракулы ловятся в обе стороны. Проводка в CI харнесса — интеграционный коммит оркестратора за реализацией (ПРОВОДКА-ЭНФОРСМЕНТ контракта); до него это не блокер.

## Скрипты моих прогонов
/tmp/dev-harness-verify/Rev119/{count.sh, battery.sh, product_checks.sh, cv_classify.sh, misc.sh, mutations.sh, merge_forecast.sh, item8.sh, comm_locale.sh}

Путь вердикта: /tmp/dev-harness-verify/Rev119/verdict.md
