accept

# 116 v2 — один scoped-круг по n116-tsc-batareja

OBJECT=d31e42eb0401225f8ced0ac8108b3fefd4613780

Судья: Critic116v2, openai-codex/gpt-6-astra. Предмет — закоммиченная дельта кандидата относительно `origin/main` = `d1f720088b1d9bdfa7b89f1e35ea4798f8987c93`; текст базового контракта побайтово равен `frozen/contracts/116/1`. Рабочая копия создана `cp -r /tmp/dev-harness-verify/Architect116v2/repo /tmp/dev-harness-verify/Critic116v2/repo`. HEAD копии равен OBJECT; все 12 изменённых файлов равны блобам HEAD.

**Блокирующих находок: 0. Советов к судимой дельте: 0.** Не найдено состояния в проверенной границе, которое удовлетворяет новому критерию, но теряет прежнюю проверку токенов/пинования. Это accept типобезопасной коррекции и согласованного перепина, НЕ приёмка мобильного продукта и НЕ свидетельство состоявшейся заморозки 116/2.

Все записи ограничены `/tmp/dev-harness-verify/Critic116v2/`. Чужие репозитории не изменялись. Коммиты, push, freeze не выполнялись — прямо запрещены заданием этого круга; публикация вердикта на ветку предмета остаётся операцией оркестратора.

## Набор и граница суда

Набор полон: предмет `contracts/116-cmp-mob-005-mission.md:9–10`, критерии с rc-командами `:29–38`, исполнители/ЗОНА `:40–48`, модель угроз `:59–76`. Прочитаны пакет двери 095, consult24b, отчёты Architect116v2/Impl116tsc, прежние вердикты critic 116 и три арбитража. Решение `675465e2` НЕ переоткрывается. Старые CI-membership, PNG и граница static/runtime не пересуживались.

Пять вопросов гейта, только по дельте:

1. **Сила критерия (`:26,38`).** Четыре локальные правки теста исчерпывают diff; все прочие байты, включая тела 19 клеток, assertions и ожидаемые значения, прежние. `?. ... ?? []` при отсутствующем className возвращает пустой массив, но неизменённое `toEqual(TOKENY_F05_07)` краснеет. Это доказано исполнением, не только чтением. Перенос отсутствующего токена на родительский View также не проходит.
2. **Доказуемость (`:32–33,38`).** W --model/--stabs исполнены. Новый файл прошёл строгий tsc в продуктовой и модельной копиях; продуктовый Jest исполнил 19/19. Реальные отрицательные входы отвергнуты своим механизмом: Jest — assertion, старые байты теста — static pin, испорченные носители — ORACLE_TAMPERED. Новый текст не заменяет обязательные runtime-доказательства зелёной статикой.
3. **Молчаливые решения (`:38`).** Новый полный sha256 измерен; типы названы и экспортируются продуктом/моделью. Текст вносит только новый пин и описание формы v2, без альтернативы «или», отключения проверок или нового усмотрения исполнителя.
4. **Границы (`:41–48`).** Все 12 изменённых файлов — контракт и mission_116, то есть зона architect. scripts/, tsconfig, продуктовый workflow и продуктовые исходники в дельте кандидата отсутствуют. Продуктовая доставка нового пина/checkout H остаётся в существующей зоне implementer, после принятия и публикации.
5. **Норма.** Новых противоречий AGENTS.md в этой дельте не найдено. Разрешающая строка в теле OBJECT есть дословно (ниже). Штатные стабы и шесть собственных мутаций исполнены. Счёт структуры source.json сопоставлен с независимым счётом строк вывода. Precision выполнен rc 0. Новых ЗОНА/семейств case-файлов дельта не вводит.

## Неизменность и согласованность

Команда:

```text
python3 -B /tmp/dev-harness-verify/Critic116v2/run.py integrity /tmp/dev-harness-verify/Critic116v2/repo python3 -B /tmp/dev-harness-verify/Critic116v2/integrity.py
```

Сырой вывод предметных проверок, rc 0:

```text
HEAD=d31e42eb0401225f8ced0ac8108b3fefd4613780
DELTA_FILES=12; ALL_IN_ARCHITECT_ZONE; WORKTREE_EQUALS_HEAD
TEST_DELTA=4 exact local-type edits; CELLS=19; ALL_OTHER_BYTES_UNCHANGED; no any/ts-ignore/ts-nocheck
TEST_SHA256=dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9
CONTRACT_DIFF=only line 38; BASE_EQUALS_FROZEN; OLD_CRITERION_PREFIX_SUFFIX_UNCHANGED
CONTRACT_INSERT=dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9; v2 n116-tsc-batareja: типобезопасная форма прежних 19 клеток — типизированный аргумент мока отправки (OutgoingMessage), turns?: readonly ConversationTurnData[], безопасное чтение optional className (отсутствие ожидаемого токена остаётся красным); assertions, PNG и граница статик/runtime не менялись
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/116-cmp-mob-005-mission.md — v2: узкая коррекция типов замороженной батареи (tsc types_probe), смысл предмета не меняется (слово владельца 2026-10-24 ~10:15 UTC «а», форк n116-tsc-batareja)
SOURCE_FIELDS_CHANGED=kejsy,statika_tekst,povedenie_proba,povedenie_proba_sha256
STATIC+SOURCE+S40_S47_PINS=consistent; STUB_OTHER_BYTES_UNCHANGED=8/8
PODMENA_EXPECTATION={'rc': 1, 'stdout': [], 'prichiny': ['PRICHINA\tPROBA_POVEDENIJA_PODMENENA\te0d2899856c5b9b3ce8ce13aa4e6c046af2bb5d595d1e827c0441aa3ed1fa3d4'], 'subekt': 'statika'}
OLD_PIN_PREFIX_MATCHES=0 (all fixture files)
PROBE_LOAD_SOURCE=accepted; ORACLE_TAMPERED absent
SOURCE_COUNTS CASE=51 RED=41 GREEN=10 STUB=35 LINKS=38
model LOG_COUNTS CASE_OK=51 STAB_KRASEN=0 KADR=7
stabs LOG_COUNTS CASE_OK=51 STAB_KRASEN=38 KADR=0
SCRIPTS_CHANGED=0
RC=0
```

Метод не опирается на заявление автора: старый blob преобразован ровно четырьмя разрешёнными заменами и сравнен с новым целиком. Изменение статической пробы и каждого s40–s47 равно исключительно замене старого полного sha на новый. Из `source.kejsy` изменено только ожидаемое значение хеша для `povedenie-proba-podmenena`; его согласованность подтверждена исполненным W. Поиск `873cf35b` по всем файлам mission_116 (включая байты, не только gitignore-видимые тексты) дал 0; отдельно специализированный grep полного/сокращённого пина также не нашёл совпадений.

## Штатная батарея, precision и scoped-регресс

CWD: `/tmp/dev-harness-verify/Critic116v2/repo`; TMPDIR и кеши — в собственной зоне. Команды запущены через `run.py`, сохраняющий исходный stdout/stderr и rc.

```text
bash fixtures/workshop_project/mission_116/red_mission_116.sh --model
RC=0
```

51/51 `CASE ... ok`; 7 KADR. Сырой хвост:

```text
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
```

```text
bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs
RC=0
```

51/51 CASE; 38/38 связей KRASEN, непойманных 0. Сырой вывод затронутой семьи:

```text
STAB s40_proba_otsutstvuet_propuskaet.py povedenie-proba-otsutstvuet KRASEN
STAB s41_proba_podmenena_propuskaet.py povedenie-proba-podmenena KRASEN
STAB s42_ci_bez_shaga_propuskaet.py ci-shag-otsutstvuet KRASEN
STAB s43_ci_shag_ne_gejtit_propuskaet.py ci-shag-ne-gejtit KRASEN
STAB s44_ci_coe_posle_run_propuskaet.py ci-coe-posle-run KRASEN
STAB s45_ci_if_false_posle_run_propuskaet.py ci-if-false-posle-run KRASEN
STAB s46_ci_echo_podmena_propuskaet.py ci-echo-podmena KRASEN
STAB s47_ci_run_kommentarij_propuskaet.py ci-run-kommentarij KRASEN
SVJAZI 38
```

Полные неизменённые выводы: `../../evidence/model.log`, `../../evidence/stabs.log` относительно этого файла (абсолютный корень evidence: `/tmp/dev-harness-verify/Critic116v2/evidence/`). Эти результаты не переаттестуют старые s19–s28: известный остаток из accept v1 вне данного круга.

```text
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116v2/repo contracts/116-cmp-mob-005-mission.md
OK
RC=0
```

`verify_antiplacebo --scope` **не запускался: затронутого зарегистрированного ключа нет**. У селектора ключ — `scripts/<key>.sh` с барьерной шапкой (`scope_select.sh:53,130–155`); scripts/ в дельте нет, поиск ссылок mission_116/red_mission_116 по scripts/ и registry не дал совпадений. `fixtures/workshop_project/.probe-only` объявляет прямое предъявление многосубъектных проб вне case-глоба. Прямой scoped-регресс здесь — два режима W выше. Неизвестный ключ не выдуман, полный прогон не запускался.

## Типы и исполняемые 19 клеток

Продуктовая одноразовая копия: `/tmp/dev-harness-verify/Critic116v2/product`, базовый product HEAD `ec6210ed52901626ce3976e1605eed1d34ed2b84`. Скрин восстановлен из его committed blob (исходная экспериментальная копия архитектора сохраняла мутацию токена); установлен ровно новый тест из OBJECT. Ни один assertion, конфиг tsc/Jest или продуктовый тип ради зелени не менялся.

Команды из `product/mobile`:

```text
node node_modules/typescript/bin/tsc --noEmit --incremental false
RC=0
node node_modules/typescript/bin/tsc --noEmit --incremental false --listFilesOnly
TSC_LIST_FILES_CONTAINS_PINNED_TEST=true RC=0
node node_modules/jest/bin/jest.js src/features/conversation/__tests__/mission-116.test.tsx --ci --runInBand --cacheDirectory /tmp/dev-harness-verify/Critic116v2/jest-cache --json --outputFile /tmp/dev-harness-verify/Critic116v2/evidence/product-honest.json
Test Suites: 1 passed, 1 total
Tests:       19 passed, 19 total
RC=0
```

`TSC_LIST_FILES_CONTAINS_PINNED_TEST` — вывод драйвера после проверки списка tsc, не строка самого tsc. Полные логи: `product-tsc.log`, `product-honest.log`, `runtime.log`; поимённый результат — `product-honest.json`.

Отдельная модельная type-копия из `Impl116/exp-model` → собственный `type-model`, без изменения старого tsconfig/модели; новый тест установлен из OBJECT. Команда:

```text
python3 -B /tmp/dev-harness-verify/Critic116v2/model_types.py
MODEL_SCREEN_EQUALS_COMMITTED_REFERENCE=true
TEST_SHA256=dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9
COMMAND: node node_modules/typescript/bin/tsc --noEmit --incremental false
RC=0
```

## Три собственные мутации исполняемого субъекта

Драйвер:

```text
python3 -B /tmp/dev-harness-verify/Critic116v2/product_attacks.py
```

Каждая мутация меняет только продуктовый экран; пинованный тест неизменён. После прогона экран восстановлен. Исполняется ВСЯ семья 19 клеток, не фильтр по имени. CWD = `product/mobile`. Во всех трёх случаях отказ — конкретное равенство токенов, не ошибка загрузки, TypeScript или исключение на `.split`.

### М1 — удалить panel у собственного блока

`testID="mission_frame_f05_07" className="panel on-card line ink-muted"` → `className="on-card line ink-muted"`.

Команда и сырой фрагмент вывода (полный — `evidence/remove-token.log`):

```text
node node_modules/jest/bin/jest.js src/features/conversation/__tests__/mission-116.test.tsx --ci --runInBand --cacheDirectory /tmp/dev-harness-verify/Critic116v2/jest-cache --json --outputFile /tmp/dev-harness-verify/Critic116v2/evidence/remove-token.json
  ● 116 mission RENDER_F05_07_DRAFT_FRAME — кадр без PNG F05.07: блок, строки каталога, токены декларации

    expect(received).toEqual(expected) // deep equality

    - Expected  - 1
    + Received  + 0

      Array [
        "ink-muted",
        "line",
        "on-card",
    -   "panel",
      ]

Test Suites: 1 failed, 1 total
Tests:       1 failed, 18 passed, 19 total
RC=1
```

### М2 — удалить className целиком

Тот же testID/видимость/строки сохранены, атрибут className отсутствует. Проверяет непосредственно изменённый optional-путь.

Команда и сырой фрагмент (полный — `evidence/missing-classname.log`):

```text
node node_modules/jest/bin/jest.js src/features/conversation/__tests__/mission-116.test.tsx --ci --runInBand --cacheDirectory /tmp/dev-harness-verify/Critic116v2/jest-cache --json --outputFile /tmp/dev-harness-verify/Critic116v2/evidence/missing-classname.json
  ● 116 mission RENDER_F05_07_DRAFT_FRAME — кадр без PNG F05.07: блок, строки каталога, токены декларации

    expect(received).toEqual(expected) // deep equality

    - Expected  - 6
    + Received  + 1

    - Array [
    -   "ink-muted",
    -   "line",
    -   "on-card",
    -   "panel",
    - ]
    + Array []

Test Suites: 1 failed, 1 total
Tests:       1 failed, 18 passed, 19 total
RC=1
```

### М3 — токен в смежном контейнере вместо своего

Собственный блок без panel обёрнут в `<View className="panel">`. Попытка удовлетворить требование присутствием токена у предка/в дереве, а не на обязательном блоке. Видимый текст и testID сохранены.

Команда и сырой фрагмент (полный — `evidence/parent-token.log`):

```text
node node_modules/jest/bin/jest.js src/features/conversation/__tests__/mission-116.test.tsx --ci --runInBand --cacheDirectory /tmp/dev-harness-verify/Critic116v2/jest-cache --json --outputFile /tmp/dev-harness-verify/Critic116v2/evidence/parent-token.json
  ● 116 mission RENDER_F05_07_DRAFT_FRAME — кадр без PNG F05.07: блок, строки каталога, токены декларации

    expect(received).toEqual(expected) // deep equality

    - Expected  - 1
    + Received  + 0

      Array [
        "ink-muted",
        "line",
        "on-card",
    -   "panel",
      ]

Test Suites: 1 failed, 1 total
Tests:       1 failed, 18 passed, 19 total
RC=1
```

Сырой итог драйвера:

```text
OWN_RUNTIME_MUTATIONS=3 CAUGHT=3; PINNED_TEST_UNCHANGED; PRODUCT_SCREEN_RESTORED
RC=0
```

## Ещё три собственные мутации пина/носителей

Драйвер: `python3 -B /tmp/dev-harness-verify/Critic116v2/pin_attacks.py` → rc 0. Честный pack/repo построены настоящими `probe.build_pack/build_repo`, не заглушкой статической проверки; полная CLI `statika_text.py` на честном входе дала rc 0. Оракул кандидата не редактировался: его испорченные варианты — отдельная копия `tmp/pin-oracle`.

### М4 — старый тест при новом пине

В продуктовый вход установлен blob `origin/main:fixtures/workshop_project/mission_116/teksty/povedenie.test.stand-in.tsx`, статическая проба остаётся новой.

```text
COMMAND: python3 -B /tmp/dev-harness-verify/Critic116v2/repo/fixtures/workshop_project/mission_116/teksty/statika_text.py --pack /tmp/dev-harness-verify/Critic116v2/tmp/pin-input/pack --repo /tmp/dev-harness-verify/Critic116v2/tmp/pin-input/repo
PRICHINA	PROBA_POVEDENIJA_PODMENENA	873cf35be05a8ae8dcfff682100c992c9ee59096c0fe8a261f7eae56de871bdb
RC=1
```

### М5 — заменить source.povedenie_proba_sha256 на 64 нуля

```text
COMMAND: bash /tmp/dev-harness-verify/Critic116v2/tmp/pin-oracle/red_mission_116.sh --model
ORACLE_TAMPERED: sha пробы поведения != пин source.json
RC=2
```

### М6 — изменить файл-носитель без source

После восстановления source к файлу теста добавлен `// mutation`; встроенные байты и пин оставлены честными.

```text
COMMAND: bash /tmp/dev-harness-verify/Critic116v2/tmp/pin-oracle/red_mission_116.sh --model
ORACLE_TAMPERED: carrier teksty/povedenie.test.stand-in.tsx
RC=2

OWN_PIN_MUTATIONS=3 CAUGHT=3; committed oracle untouched
```

Полный сырой вывод — `evidence/pin-attacks.log`, по отдельности `pin-honest.log`, `mutation-old-test-new-pin.log`, `mutation-source-pin.log`, `mutation-test-carrier.log`.

## Честность экспериментального окружения и пределы

Два дополнительных опыта не засчитаны как зелёный модельный Jest и не скрыты:

- `runtime.py` после успешных product tsc/Jest подставил только reference screen в текущую продуктовую композицию; 19/19 красных из-за отсутствующего значения каталога: `TypeError: Cannot read properties of undefined (reading 'text')` на `uiCopyDe['frame.F05.01.title'].text`. Полный сырой вывод — `model-honest.log`, `runtime.log` (драйвер rc 1).
- `model_attacks.py` подставил также `model/ui-copy.ts`; 17/19 прошли, две структурные клетки красны: `Unable to find an element with text: Nachricht senden`; текущий продуктовый composer требует передаваемые подписи, которых reference-композиция не передаёт. Полные выводы — `complete-model-honest.log`, `model-attacks.log` (rc 1). Эта смешанная композиция не является проверенной честной модельной средой; её краснота не названа дефектом кандидата и не использована как мутационное доказательство.

Вместо подгонки модельных зависимостей мутации выполнены на уже доказанном честном продуктовом субъекте (19/19 до мутаций); модельная типобезопасность отдельно доказана в прежней изолированной type-среде, с побайтовым равенством reference screen. Утверждения «reference Jest 19/19 в текущей продуктовой композиции» здесь нет.

Граница визуальной проверки: настоящий телефон, эмулятор и новые screenshots не запускались; PNG-пиксельная приёмка не предмет этого перепина. GitHub required-checks, членство job и runtime-связь одного C/run не проверялись заново и остаются обязательными при продуктовой приёмке по `:38`. Старые пять ошибок tsc из отчёта Impl116tsc для повторного подтверждения не запускались. Новых постоянных тестов/правок реализации нет; скрипты и копии внутри собственной зоны оставлены только как воспроизводимые судейские улики.
