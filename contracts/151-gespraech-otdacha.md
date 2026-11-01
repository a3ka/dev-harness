# Контракт 151 — тактильная отдача Gespräch (D 2.4)

КЛАСС ЗАДАЧИ: КОДОВЫЙ — контракт, красная батарея, затем модуль продукта и зависимость.
КЛАСС РИСКА: обычный — модуль выдаёт только локальную тактильную отдачу; не изменяет права/роли БД, авторизацию, безопасность, деньги, ПД/health-данные и согласия или юридически значимые действия. Сигнал «отправлено» не является отправкой дела (153).
КОНТЕКСТ: `docs/owner/2026-10-30-gespraech-otdacha.md` — прямое «да, запускай отдачу»; `docs/owner/2026-11-01-pauza-d24-ekrany.md` и `registry/pauzy.tsv` — экраны 147/148/149 и Start GA-01 на паузе до компактного пакета D 2.4 Final 3. Номер 151 — `registry/plan.tsv` и тег `id/CONTRACT/151`. В этой версии реализация НЕ зависит от формы экрана 147.

## Существующее

- Пакет дизайнера `Complior-D24-Gespraech-Final2-Motion.zip` → `haptics.json`: у GA-T28/T29/T35/T30/T33/T32/T34/T08/T37/T16/T17/T19/T20/T21/T22/T24 по одному сценарию, у GA-R2/R3 (включая 393) повторяющиеся записи в разные моменты. `earcons` — ОТДЕЛЬНЫЙ массив звука, не тактильная отдача. Оракул `fixtures/workshop_project/gespraech_otdacha_151/haptics.json` — запись полей scene/at/ios/android из этого источника; проба сверяет её с копией дизайнера в продукте до вызова субъекта.
- 145 (frozen 145/4): `mobile/src/lib/faden/` — знак, привязка к reducedMotion; `mobile/src/theme/motion-tokens.ts` — времена UI. Ни Faden, ни токены не исполняют `haptics.json`; повторный движок Faden здесь не нужен. 146 (frozen 146/1) валидирует движение ЭКРАННОЙ пачки, не тактильный эффект. Батарея 151 — отдельный шов, без экранного `ekran.json`.
- 147 (frozen 147/1) содержит меню/удержание в `mobile/src/features/conversation/` и `mobile/src/bootstrap/tab-shell.tsx`; 148 и 149 (frozen версии, PR продукта открыты) — вкладки и чат. На время паузы их код, frozen-пути, тесты, макеты и PR не правим. Продуктовая база `mobile/package.json` содержит Expo/Jest, но `expo-haptics` отсутствует; `mobile/jest.config.js` — `jest-expo` и `mobile/jest.setup.ts` — действующая среда канона. `registry/plan.tsv` выдал предмет, но реализации нет. Открытые PR Complior-mob #147/#148 — экраны, #149/#150 — демо; ни один не заменяет самостоятельный модуль 151.
- Гейты `scripts/pre_critic.sh`, `scripts/check_precision_gate.sh`, `scripts/check_provodka.sh` и батарея 153 дают лекало проверок контракта/CI. Здесь `fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh` запускает Jest В ПЕСОЧНИЦЕ с настоящим jest-expo продукта; не создаёт второй Jest-пресет или нативную сборку.

## Frontier и граница

Выбрано: один независимый модуль + карта из дизайна + продуктовый Jest-канон. Уже измерено: отсутствие expo-haptics в package.json, отсутствие модуля и пауза экранов. Вариант «внести вибрацию непосредственно в menu-machine/TabShell сейчас» отвергнут: сцены привяжутся к дизайну, который пересобирается, и нарушат паузу. Вариант «подменить feedback текстом/звуком» отвергнут: тактильный отклик не доказывается звуком и earcons имеют собственное условие беззвучного режима. Вариант «универсальный таймер внутри модуля» отвергнут: at — момент события в таймлайне, хост вызывает точку входа при наступлении события; повторное ожидание сдвинет GA-T35 и эталоны R2/R3. Вариант эмуляторного критерия сейчас отвергнут правилом OOM станции: численная карта и вызов SDK проверяются Jest, физическое ощущение — после снятия запрета.

## Предмет и инварианты первой реализации

Один результат сейчас: `mobile/src/lib/otdacha/index.ts` экспортирует `patternFor(scene, at)` и асинхронный `playHaptic(scene, at, policy)`; `mobile/package.json` и lockfile содержат установленную совместимую с Expo зависимость `expo-haptics`. Входы `scene` и `at` — идентификатор и момент из дизайнерского haptics.json, а не имя кнопки или номер кадра. `patternFor` возвращает `{ios, android}` из записи или `null` при отсутствующей паре; повторяющаяся сцена различается моментом. Это единственная точка тактильной отдачи для будущих экранов; без React-компонентов, подключения к меню или earcons в первой поставке.

- И-1. Вся карта из оракула: основной набор GA-T содержит 16 разных сцен; эталонные GA-R2/R2-393/R3/R3-393 имеют свои моменты, а не перезаписывают предыдущие. Выбор платформы: iOS light/medium → `impactAsync(Light|Medium)`, selection → `selectionAsync()`, warning/success/error → `notificationAsync(Warning|Success|Error)`; Android VIRTUAL_KEY/CONTEXT_CLICK/LONG_PRESS/CLOCK_TICK/REJECT/CONFIRM → `performAndroidHapticsAsync` с одноимённым `AndroidHaptics` enum. Никаких `Vibration.vibrate()` и синтетических звуков. Неизвестный ключ или момент → `null`, вызов SDK отсутствует.
- И-2. `policy = { platform: 'ios'|'android', enabled: boolean, vibrationEnabled: boolean, quietMode: boolean }`; для КАЖДОЙ записи карты и ОБЕИХ платформ вызов SDK ровно один при `enabled && vibrationEnabled && !quietMode`, иначе вызовов нет. Политика обязательна и поступает от вызывающего хоста (платформа из `Platform.OS`, флаги из применимых пользовательских/системных настроек); модуль не фабрикует «разрешено» при неизвестном системном флаге. Нативный SDK дополнительно подчиняется запрету Taptic Engine/vibration на устройстве, даже если прикладная политика разрешает. Продукт не воспроизводит earcons: беззвучный режим не превращается в звук; интеграция источника флагов с экраном — условная часть ниже.
- И-3. Модуль НЕ строит собственный таймер: GA-T35 испускается при вызове на `at=500` после распознанного удержания, не на touch-down; для GA-T21/T22 и повторных эталонов тот же принцип. Ранний вызов `at=0` вместо 500 даёт `null`. Асинхронное завершение передаёт завершение Expo-вызова; отключённое состояние завершает без вызова SDK.
- И-4. Реальная зависимость зарегистрирована одновременно в `mobile/package.json` и `mobile/package-lock.json`; продуктовый Jest-сьют с моками только `expo-haptics` проходит в измеренном Expo/Jest-пресете. Модель батареи не переносится в продукт, runtime-шов — реальный модуль, а не тестовый ответвитель.

## Подключение — только после снятия паузы

По будущему слову о снятии строки 147 в `registry/pauzy.tsv`, после сверки нового D 2.4 Final 3 и зоны ПЕРЕСЕЧЕНИЯ: menu-open, удержание распознано после порога, старт голоса и выбор из 147 зовут `playHaptic` при своём событии; 149+ зовут тот же модуль для темы/микрофона/предупреждения/успеха/ошибки. Это НЕ входит в первую реализацию, её --repo-критерий и текущие зоны implementer. Красные клетки будущего подключения: `MENU_OPEN_EVENT`, `HOLD_RECOGNIZED_NOT_DOWN`, `VOICE_STARTED_EVENT`, `TOPIC_SELECTED_EVENT`, `MICROPHONE_ON_OFF_EVENT`, `WARNING_SUCCESS_ERROR_EVENT` — не запускаются и не считаются зелёными этим контрактом; для них потребуется адресная v+1 с новыми зонами/живыми экранами, без изменения текущего оракула карты. Экранный Jest и живой UI-тест без паузы сейчас был бы ложным обещанием.

## Приёмка

`W` = `bash fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh`; `R` — продукт с установленным `mobile/node_modules` и designer-copy `docs/ux/04_Gespraech_D24/motion/haptics.json`. Для --model/--stabs требуется `--runtime R` либо `MOB_151_RUNTIME=R`. Проба исполняет канон в одноразовом temp-проекте на РЕАЛЬНЫХ `jest.config.js`/`jest.setup.ts`/node_modules R, не модифицирует R; oracle.json копируется ДО импорта subject. В --repo копируется весь каталог модуля; ожидания читаются из оракула, не из subject. Конформные входы: все строки `haptics` с точным scene+at и булевы флаги обоих значений; неконформные ключи/время — обязательная тишина. Валидный контрпример: инвариантен к значениям временного корня и расходится с честной моделью на конформной записи или обязательном отрицательном входе. Неизвестное состояние ОС без достоверной политики не считается конформным «enabled».

1. Дано: без реализации и без R; когда `W`; тогда rc 1 `SUBJECT_ABSENT`. Дано R до реализации; когда `W --repo R`; тогда rc 1 `SUBJECT_ABSENT`. Нет установленной Jest-среды для модели → rc 2 `INFRASTRUCTURE`, а не зелень или ложная краснота продукта.
2. Дано R с установленной средой; когда `W --model --runtime R`; тогда rc 0, `CASE 544 GREEN 544 RED 0` (30 записей × 2 платформы × [pattern + 8 политик] + 4 неизвестных пары); `W --stabs --runtime R` → rc 0, `SVJAZI 11 CASE 544`: каждая обманка валится собственной именованной клеткой (привязка только в коде probe.py), включая отложенный лишний вызов после выключения и двойной эффект после положительного вызова; пустая матрица даёт rc 2. Парный негатив: изменённый mapping, игнорирование любого флага, ранний вызов или пропуск повторного момента → соответствующая клетка `KRASNO`.
3. Дано R с установленным `expo-haptics`, модулем и lockfile; когда `W --repo R`; тогда rc 0, `CASE 544 GREEN 544 RED 0`. Парный негатив: отсутствует dependency/package-lock → rc 1 `DEPENDENCY_ABSENT`; отсутствует модуль → rc 1 `SUBJECT_ABSENT`; несоответствие дизайн-копии оракулу → rc 2 `ORACLE_DESIGN_DRIFT`. Ключ/момент вне карты всегда не испускает эффект.
4. Правило ворот: `bash scripts/pre_critic.sh --repo . contracts/151-gespraech-otdacha.md`, `bash scripts/check_ceilings.sh`, `bash scripts/check_precision_gate.sh . contracts/151-gespraech-otdacha.md`, `bash scripts/check_zones.sh` → rc 0. `bash scripts/check_provodka.sh . contracts/151-gespraech-otdacha.md` до CI-строки оркестратора → rc 1 (`guard не подключён`), после CI-строки → rc 0.

## Зоны и порядок

ЗОНА architect: contracts/151-gespraech-otdacha.md fixtures/workshop_project/gespraech_otdacha_151/
ЗОНА implementer: mobile/src/lib/otdacha/ mobile/package.json mobile/package-lock.json
ПЕРЕСЕЧЕНИЕ implementer: mobile/package.json — 145 зона зависимостей Faden; только добавить expo-haptics, сохранять все чужие зависимости.
ПЕРЕСЕЧЕНИЕ implementer: mobile/package-lock.json — 145 зона lockfile; только следствие установки expo-haptics, без изменения чужих зависимостей.
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 новая строка батареи 151 после реализации, без изменения чужих строк.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 добавить только шаг selftest 151; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 новая строка 151, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 новая строка 151, чужие шаги неизменны.

Порядок: architect — W красен, W --model и --stabs зелены на реальном Jest-пресете → critic → freeze → implementer — только зона модуля/зависимости, W --repo R зелён → orchestrator подключает selftest с реальным установленным R (команды --repo и --stabs; setup среды явно) → независимый суд. Зоны экранов 147/148/149 на паузе, их «подключение» не входит в done первой поставки.

ПРЕДПОСЫЛКИ:
- setting продукт: Expo SDK 57, установленный jest-expo и зависимости `mobile/node_modules` для исполнения канона; `expo-haptics` добавляет implementer через совместимую Expo-установку с lockfile, новых секретов/variables/environments нет.
- setting CI-харнесса: Node, Python, Jest-пресет реального продукта R и его designer-copy доступны через явный R; эмулятор и нативная сборка не нужны. Без R модель возвращает rc 2, CI не должен маскировать это пропуском.
- setting пауза: перед любым подключением перечитать `registry/pauzy.tsv`; до снятия строк 147/148/149 экранные зоны read-only.

ПРОВОДКА:
- guard=fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh
ПРОВОДКА-ЭНФОРСМЕНТ: только предметное поведение модуля и карта дизайнера; новой нормы ролей или устава нет. CI-проводка оркестратором после реализации, изолированная Jest-среда — обязательная предпосылка шага.

## Модель угроз

ЗАЩИЩАЕТ:
- ошибочную платформу, силу/тип, время и потерянные повторные записи дизайнерской карты; вызов SDK при выключенной прикладной политике; отсутствие dependency и тестовый плацебо-модуль;
- ложную зелень от пустого Jest и от переписывания subject-ом карты на диске: ожидания oracle.json сняты и скопированы ДО импорта subject, статус каждой клетки судит независимый раннер; стабы привязаны в коде probe.py.
НЕ ЗАЩИЩАЕТ:
- физическое ощущение на телефоне, достоверность источника системных флагов/переключателя iOS silent (Expo Haptics не предоставляет JS-getter), будущие экранные вызовы при паузе, звук earcons; ловец — живое устройство и новая адресная v+1 после снятия паузы. Native OS может дополнительно подавлять эффект при запрещённом Taptic Engine/режиме экономии; Jest доказывает вызов SDK, не физический импульс.

## Незаполненные требования:
нет
