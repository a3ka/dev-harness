accept
Реализация 119 v2 (OBJECT 5e2e32c8dcd0cc0664764fa541441164f5920a04, Complior-back `cmp-bck-315/import`) принята. Блокирующих находок нет: обходов не найдено, зона не превышена, расхождений с предметом нет. Есть три дефекта батареи (зона architect), один остаток продукта вне зоны и четыре совета. Все находки — в `/tmp/dev-harness-verify/Rev119v2/review.md` (reslop, status: ready).

Судья: Rev119v2 (reviewer). Контракт: frozen/contracts/119/2 (ecf5697932ef). Клон: /tmp/dev-harness-verify/Rev119v2/back @ OBJECT, мутации в одноразовых клонах, удалены.

## (а) Зоны и пересечения
- `git diff --name-only 0ed762b8cb..OBJECT | grep -Ev '<ЗОНА v2 дословно>'` → вывод пуст, grep rc=1. Файлов вне зоны нет.
- v2-коммит `5e2e32c` (один, автор `implementer`) трогает 8 файлов: FILES.sha256, app/schemas/{openapi,source}.json, published, operation-index.json, spec-3.14 валидатор, spec-3.15 валидатор, generate_derived.py. Все в зоне.
- `git diff --stat 0ed762b8cb..OBJECT -- tests/tools/gen-contracts.js tests/tools/contract-validator-known-failures.json migrations/ server/ app/src` → пусто: писатель app/schemas, реестр подавлений и миграции 001–014 не тронуты.
- Своя мера (yaml-объекты, другой способ, чем текстовые блоки оракула): базовых операций 163, изменено или потеряно 0; базовых схем 496, изменено 0; ReasonCode равен базовому; новый параметр только PlatformContract; итог 233/566.
- app/schemas — чистая пересборка: `json.load(openapi.json) == yaml.safe_load(published)` (канон) True; `source_sha256` = sha256 published = `c610b3ea…6717ad8`. Писатель восстанавливает те же байты: проба оракула gencontracts-ne-pishet зелёная при доступном npm-дереве.

## (б) Приёмка п.9 v2 — сырые rc (свой клон)
- `python3 tests/spec-3.14/validate_contract_v3_9.py` → rc=0, `status PASS_STATIC`, checks 2540, failures=[] (длина 0).
- `node tests/tools/gen-contracts.js --check` → rc=0, «производный контракт совпадает с корневым».
- `python3 tests/tools/generate_derived.py --check` на чистом дереве → rc=0, «Derived files: 675 (расхождений: 0)». После прогона валидатора в дереве → rc=1 «УСТАРЕЛО: FILES.sha256» из-за `evidence/`; это остаток О-1, он был ещё в базе.
- `python3 tests/spec-3.15/validate_import_315.py` → rc=0, «операций 233 (ядро 163 + extension 70), схем 566, потребителей 123 (53 + 70), известных проблем 14, known-failures=0».
- `known-failures.json`: `failure_ids: []`, `fingerprints: {}`.
- Оракул на OBJECT, `NODE_PATH=<npm-дерево Impl119/back>`, без симлинка → rc=0 `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product`.
- Оракул без npm-дерева на чистом дереве → rc=1 `gencontracts-rashozhdenie`. Это ложный диагноз, дефект батареи Б-1(а).
- Оракул с симлинком `node_modules` в судимом дереве → rc=1 `vosproizvodimost` (`cp: -r not specified`). Тоже ложный диагноз, Б-1(в).
- Повторный прогон оракула без очистки → rc=1 `files-sha256-rashozhdenie`: оракул сам оставил `evidence/`, это Б-2.
- `bash fixtures/workshop_project/import315_119/red_import315_119.sh --model` → rc=0, «ИТОГ 119: клеток 34, зелёных 34, красных 0». Это включает d34 (перестановка operationId → `schemas-proekcija`) и d33.

Оценка блокера Impl119v2: это дефект батареи, а не реализации. При npm-дереве, достижимом через NODE_PATH, оракул на OBJECT даёт rc 0. Точные входы и что чинить — в Б-1 review.md. Сам я наблюдал (а) и (в); (б) — замер Impl119v2, не повторял.

## (в) Подгонка проверок под код
- Батарея и пин не изменены: `git diff --stat frozen/contracts/119/2 HEAD -- fixtures/workshop_project/import315_119/ contracts/119-…md` пуст.
- Алфавиты валидатора совпадают с бандлом, не придуманы. Audience extension бандла = {PARTNER_MOBILE 52, INTERNAL 2, CONSUMER 16} = `EXTENSION_AUDIENCES`; binding_status = {AWAITING_FRONTEND_ACTION_ID, INTERNAL_SERVICE} = пин; Problem = единственный PMProblem; x-cas-required булев 70/70; core-метаданных на extension 0/70; примеров в extension бандла 0/70. Это честный перевод ASTRA §6.2 шаг 6 «сохранив CAS, scope, error, consumer», а не подгонка под зелёное.
- Ветки ядра не тронуты: в диффе `else`/`elif` дословно прежние. Маркер ядра проверяется построчно `<oid>_contract_profile`, по тексту ровно один, то есть строже, чем раньше.
- Денормализация spec-3.15 обходом не является: снимается только точная строка маркера уровня операции и только при сравнении extension-блоков. Ядро и ReasonCode сравниваются по сырому тексту (стр. 167/200), лишний маркер ловит spec-3.14.
- Красное предъявлено своими мутациями (spec-3.14 валидатор, rc и первые failure_ids):
  - c1 ядро `- 5.8.x`→`- 5.9.0`: rc=1, `getSession_contract_profile`
  - c2 ядру добавлен `- 5.9.0`: rc=1, `getSession_contract_profile`
  - c3 у ядра снят маркер: rc=1, `getSession_contract_profile`
  - m2 extension `['5.8.x']`: rc=1, `createPartnerOnboarding_contract_profile`
  - m3 у extension снят маркер: rc=1, то же
  - m4 дубль маркера extension: rc=1, то же
  - m5 audience BROKER: rc=1, `createPartnerOnboarding_contract_scope_policy`
  - m6 x-operation-class на extension: rc=1, `_profile_isolation` + `_policy_consistency`
  - m7 binding_status CONFIRMED в index: rc=1, `decidePartnerOnboarding_source_consumers` / `_consumer_resolution`
  - m8 `x-cas-required: maybe`: rc=1, `decidePartnerOnboarding_cas`
  - m0 чистое дерево: rc=0
  
  Мутация m1 первого прогона была no-op (неверный шаблон под блочный маркер ядра). Её заменили c1–c3. Первый прогон мутаций выдал rc=1 на всех из-за `mkdir exist_ok=False`, был признан недействительным и повторён.
- Атомарность: v2 — один коммит со ссылкой «119 v2». Нормативные документы реализацией не тронуты.
- R-4/R-6/R-7 — остаточные риски контракта, их не блокирую.

## ПРОВОДКА (038)
Guard `fixtures/workshop_project/import315_119/red_import315_119.sh` существует, --model rc 0 34/34, это барьер именно этого предмета. Подключение в CI харнесса по контракту делает оркестратор интеграционным коммитом после реализации, поэтому это не блокер.

## Паразитная сложность (050): пять вопросов по новым артефактам диффа
- `generate_derived.py: stamp_extension_profile` + `OPERATION_ID_WIDTH`. (1) Свойство: маркер профиля extension в published (пробы spec314-noop, ASTRA §6.2 ш.6). (2) Состояния нет; версия берётся из заголовка источника, видна в выходе. (3) При смене грамматики маркера меняются три файла: генератор, spec-3.14 `declared_markers`, spec-3.15 `PROFILE_MARKER_RE`; дифф их не умножил, связь введена этим свойством. (4) Интерфейс — функция с двумя аргументами, CLI не менялся, модуль глубокий. (5) Потребитель — п.9 и оракул. Итог: ESSENTIAL.
- `validate_contract_v3_9.py: declared_markers`. (1) Ровно один маркер по тексту; повтор ключа в YAML неотличим разбором (проба 2 оракула — вставка на acknowledgeDisclosure). (2) Состояния нет. (3) Один файл. (4) Текст → dict, работа скрыта. (5) Потребитель — п.9 и оракул; повторяет текстовый разбор operationId из spec-3.15, но там другая цель. Итог: ESSENTIAL.
- `load_extension_profile / profile_of / profile_marker`. (1) Смешанные профили п.9. (2) Читает два файла дерева при импорте модуля (extension sha закреплён пином). (3)–(5): один файл, потребитель п.9. Итог: ESSENTIAL.
- `extension_problem_ref / extension_consumer_resolution / extension_bodies / extension_cas`. (1) «Сохранить CAS, scope, error, consumer» для профиля extension (ASTRA §6.2 ш.6, пересечение v2). (2) Состояния нет. (3) Один файл. (4) Узкие предикаты. (5) Потребитель п.9, красное — m5/m7/m8. Итог: ESSENTIAL. Ветка `_policy_consistency` extension избыточна, совет С-1. Блокировать не может: свойство не потеряно, потеряна только простота.
- `example_exemption` в `all_illustrative_body_examples_generated`. (1) Без него п.9 красен на 70 телах без примеров в бандле. (2) Состояния нет. (3) Один файл. (4)–(5) Потребитель п.9. Итог: ESSENTIAL, отложенный долг — С-4.
- `document_operations`. Рефактор единственного разбора paths: интерфейс не вырос. Итог: ESSENTIAL (нужен двум вызывающим).
- `validate_import_315.py: _header_version, PROFILE_MARKER_RE, EXTENSION_TEXT`. (1) Сверка блоков extension при маркере писателя. (2) Состояния нет. (3) Связан с генератором (см. выше). (5) Третий читатель `info.version`, совет С-2. Итог: ESSENTIAL по свойству, форма — совет.

## Находки и классы
- Б-1 — дефект батареи, architect. Ложный диагноз при отсутствии или недостижимости npm-дерева. Реализацию не блокирует.
- Б-2 — дефект батареи, architect. Оракул пишет evidence в судимое дерево и не воспроизводим. Реализацию не блокирует.
- Б-3 — совет, architect: `comm` вне `LC_ALL=C`.
- О-1 — остаток продукта вне зоны: `.gitignore` для `evidence/`.
- С-1…С-4 — советы implementer.

Уборка: клоны мутаций удалены, evidence/ в клоне вычищен, pyc в основном чекауте харнесса не оставлен (import315_119 без `__pycache__`).
