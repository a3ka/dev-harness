# Контракт 999 — CMP-MOB-002: навигация Start · Vorgänge · Schutz · Post и токены D2.2.5.1

КЛАСС: КОДОВЫЙ. Авторский контракт CMP-MOB-002; предмет issue #6 сохранён. Android-приёмка следует после реализации C, не подменяется авторскими моделями.

КОНТЕКСТ: GitHub `a3ka/Complior-mob#6` — источник работ и приёмки; перед раздачей читать полное тело через `gh issue view 6 --repo a3ka/Complior-mob --json body --jq .body`.
КОНТЕКСТ: `contracts/995-cmp-mob-001-android-pilot.md` — дисциплина H/B/C/T, disposable R, прецедент композиционного шва bootstrap и CI-пинов; frozen-семейство проб 995 не переписывается.
КОНТЕКСТ: `docs/owner/2026-10-17-plan-stancii.md` — независимый слот mob, ручной Merge.
КОНТЕКСТ: `fixtures/workshop_project/nav_999/source.json` — оракул: копия каталога и токены, снятые с дерева B ДО запуска субъекта; проб-тесты несут те же значения побайтово из этого файла.

## Нарезка предмета (frontier)

Три варианта рассматривались до первой редакции:

1. **Один контракт = весь предмет** (shell, токены, ui-примитивы, copy, deep link, reduced motion; один PR) — **выбран**. Боль: пакет FOUNDATION P0 W0 блокирует срезы F04/F08/F19/F16 — каждый следующий PR садится на этот shell; Н-324 (цена: три круга судей 995, таблица переходов достраивалась по находкам) закрывается здесь механизмом — исчерпывающая матрица переходов в красных тестах с первой редакции.
2. Два контракта (токены+ui / навигация) — отвергнут: предмет issue = один PR; theme без потребителя-навигации — слой без обратной связи (норма вертикального слайса 050: контракт, сдающий один слой для многих предметов, не заводится).
3. Навигация с минимальным токен-набором tab bar, ui-примитивы следующим срезом — отвергнут: работа 3 issue явно требует Button/Notice/TextField в этом пакете; вынос сужает предмет против issue.

Критерий выбора: вертикальный слайс 050 + граница «ОДИН PR» из issue; боль Н-324 закрывается механизмом (исчерпывающая матрица в коде проб), а не нарезкой.

## Существующее

Сверено на read-only снимке Complior-mob `f0d8e54e181853473e23c7df3dc623bbb7faecdf` (HEAD main после merge PR#108, `git rev-parse HEAD`; снят `gh repo clone` — ssh-ключ станции видит только dev-harness). Полные HEAD, не имена веток.

- `mobile/src/app/`: `_layout.tsx` — голый Stack; `index.tsx` реэкспортирует PilotApp (995). Табов, `theme/`, `ui/`, `i18n/`, `assets/fonts/` нет — предмет на B отсутствует.
- Токены D2.2.5.1: `docs/ux/02_.../design-system/project/tokens.json` (sha256 в source.json): 8 требуемых имён с dark/light. DM Sans `DMSans-Variable.ttf` + `OFL-DMSans.txt` лежат в design snapshot; web-bundle `components/bundle.js` — React 18, для RN запрещён.
- Copy: IA-вкладки — `ia115.nav.START`="Start", `ia117.nav.VORGAENGE`="Vorgänge" (канон), `ia115.nav.HEUTE` — deprecated do_not_use, `ia115.nav.SCHUTZ`, `ia115.nav.POST`; заголовки разделов `frame.F04/F08/F19/F16.01.title`; `action.F12.A01`="Profil bearbeiten", `global.back`="Zurück" — существующие ключи для вторичного маршрута и возврата. review_status у всех ключей сохранён (PRODUCT_COPY_/EDITORIAL_DRAFT_REVIEW_REQUIRED).
- `STRUCTURE.md`: `app/` — только маршруты; группы `(tabs)` допустимы, профиль/поиск/настройки — вторичные маршруты; `theme/` — нативная проекция токенов, не второй набор; `ui/` использует theme; copy — производные runtime-ключи в `i18n/`, источник read-only; `start-screen.tsx` с literal styles назван миграции в CMP-MOB-002; kebab-case; feature→feature запрещён.
- Эквиваленты переиспользуются, новых зависимостей нет: jest-expo + RNTL 14.1.0, react-native-safe-area-context ~5.7.0, Pressable/KeyboardAvoidingView ядра; Jest/Metro runtime-alias 995 не трогается. Пробы 999 — отдельный подход 995 (`stale_probe`-прецедент: disposable workspace, JSON-отчёт, именованные rc).
- `mobile.yml` после 995: quality (включая frozen-прогоны 995 на disposable R) и android-e2e с H-checkout; паттерн пинов 999 повторяет. `.maestro/start.yaml`, `rehearsal.yaml`, rehearsal-evidence gate и component RNTL 991/995 (`start-screen.test.tsx`, `rehearsal.test.tsx`, `pilot.test.tsx` + `source.json` байт-заморозка) не меняются.
- `app.json` несёт `"scheme": "complior"` — deep link-основа уже есть.

## Предмет и граница

Один результат: Expo Router shell с четырьмя каноническими вкладками в порядке Start/Vorgänge/Schutz/Post, профиль — вторичный маршрут; темы dark/light как проекция D2.2.5.1; Button/Notice/TextField/safe-area/keyboard контейнеры; точные ключи каталога с сохранением review_status; deep link и возврат к исходному разделу; reduced motion. ОДИН PR в a3ka/Complior-mob, без Merge. Implementer — согласованная модель MiniMax; после реализации — настоящий Android e2e и независимые adversary/reviewer на одном C.

Вне предмета: содержимое функциональных кадров разделов и API-сценарии срезов (F04/F08/F19/F16), контекстный агент как отдельный экран, Mission-машина, биометрия. Заявленная оговорка: pilot-поверхности 995 (`features/auth/`, `features/onboarding/`, `bootstrap/pilot-app.tsx`, `mocks/`, `api/`, `auth/`) не рестайлятся этим PR — их миграция на токены принадлежит срезам F02/F03; scan-зона инварианта палитры объявлена в коде проб. Copy signoff CMP-MOB-089 и device evidence CMP-MOB-090 этим PR не объявляются завершёнными.

## Инварианты

1. Четыре вкладки в порядке Start/Vorgänge/Schutz/Post; метки — тексты IA-ключей (ia115.nav.START, ia117.nav.VORGAENGE, ia115.nav.SCHUTZ, ia115.nav.POST), не заголовки кадров; ia115.nav.HEUTE не используется; профиль открывается как вторичный маршрут (action.F12.A01) и не появляется пятой основной вкладкой.
2. `mobile/src/theme/tokens.ts` — проекция источника: восемь имён ground/ink/panel/card/on-card/primary/on-primary/accent с dark и light значениями побайтово из source.json; hex-литералы палитры в зонах 002 (app, ui, navigation, tab-shell, start-screen) запрещены — только theme/; accent — заливка с тёмным текстом, не лаймовый текст на светлом фоне — правило наблюдается на самих примитивах (подпись каждого примитива в каждой теме ≠ accent) и на поверхности shell.
3. Button (primary/secondary, disabled), Notice (role alert), TextField (label, secureTextEntry), safe-area и keyboard-контейнеры реализованы на токенах; контейнеры наблюдаются по композиции (настоящий SafeAreaView из react-native-safe-area-context и KeyboardAvoidingView из react-native присутствуют как компоненты, подмена обычным View с сохранением testID красна); TestID — automation-семантика шва, не новые route/action IDs.
4. `mobile/src/i18n/ui-copy.ts` — verbatim-подмножество BrokerOS_UI_Copy_DE.json: точные ключи, точные тексты, review_status у каждого ключа; новые немецкие формулировки не вводятся.
5. Deep link (scheme complior сохраняется) открывает раздел с сохранением возврата к исходному; reduced motion убирает декоративное движение, не изменяя доступные действия; переключение вкладки не создаёт Mission и не отправляет команду (порт-наблюдатель onCommand молчит).
6. Существующий вход 995 сохраняется; frozen-семейство проб 995 остаётся зелёным на C; DM Sans идёт в `mobile/assets/fonts/` с OFL, web-bundle React 18 из design snapshot в RN не импортируется.

## Проверяемый шов

`mobile/src/bootstrap/tab-shell.tsx` экспортирует `TabShell` с необязательными портами `initialSection`, `returnSection`, `reducedMotion`, `colorScheme`, `onCommand` — прецедент `pilot-app.tsx`. `app/_layout.tsx` монтирует ту же композицию (Expo Router tabs по STRUCTURE), `app/index.tsx` 995 не ломается. Разделы показывают заголовки `frame.*.01.title` из i18n-модуля. Ожидания проб снимаются в память (source.json, байты тестов) до запуска субъекта; привязка мутант↔ветвь живёт только в коде проб (`MUTANTS`/`depends`), не в прозе контракта (Н-39). Модель architect в `fixtures/workshop_project/nav_999/model/` — честный эталон для красных тестов; в PR не копируется, композиция не имеет тестового ответвления.

ЗАКРЫТЫЕ ПЕРЕЧНИ (Н-324/Н-325: клетки порождаются перебором по перечню из source.json, не списком известных обходов; расширение перечня = расширение source.json, единственный источник грамматики):

- навигация — перечень вкладок `tabs_order` × свойства: initialSection (клетка на вкладку), selected при переключении (все четыре, включая Start), возврат из профиля (клетка на вкладку), deep link `DEEPLINK_RETURN_<initial>_TO_<return>` — декартово произведение перечня на себя (16 клеток, включая диагональ) плюс `DEEPLINK_NO_RETURN` (возврат не задан — Back отсутствует);
- примитивы — декартово произведение {Button primary, Button secondary, Notice, TextField} × {dark, light}: в каждой клетке наблюдаются все заявленные свойства (role/alert, проводка onPress до хоста — fiber-тождество колбэка потребителя у Pressable, точные цвета подписи и заливки из source.json, secureTextEntry, акцентный гейт «подпись ≠ accent»); проводка onPress наблюдается fiber-ом, потому что fireEvent.press в RNTL 14 всплывает до пропсов вызова и не различает отвязанный обработчик;
- контейнеры — fiber-тождество композиции: ближайший композит над хостом shell-safe-area — SafeAreaView из react-native-safe-area-context, над shell-keyboard-container — KeyboardAvoidingView из react-native; подмена `const SafeAreaView = View` / локальным View-шейдоу красна при сохранённых testID;
- copy поверхности — закрытый перечень состояний (каждая вкладка переключением, профиль, deep link с возвратом): в каждом состоянии ВСЕ строковые листья дерева сверяются с каталогом source.json (10 текстов), Back наблюдается поимённо в состояниях, где он видим;
- матрицы copy/static (как и nav/ui) исполняют ВСЕ колонки на каждом мутанте; побочная краснота допустна только в явно объявленном `depends` (измерена прогоном), краснота вне named ∪ depends и нецензурированная декларация — дефект матрицы.

## Приёмочный критерий

R — disposable копия Complior-mob (B или C) под /tmp/dev-harness-verify с `npm ci` в `mobile/`; пробы — Python 3 stdlib, отдельная установка не нужна. Нет Jest/артефактов отчёта → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B без реализации; `python3 fixtures/workshop_project/nav_999/nav_probe.py --repo R` → rc1 NAV_SHELL_ABSENT; `ui_probe.py --repo R` → rc1 UI_PRIMITIVES_ABSENT; `shell_static_probe.py --repo R` → rc1 STATIC_THEME_ABSENT; `copy_probe.py --repo R` → rc1 COPY_MODULE_ABSENT. Четыре именованных отказа — краснота предмета на до-предметном дереве.
- Дано B с эталонной моделью (те же команды с `--model`); либо дано честное C — все четыре пробы → rc0 с построчным перечнем case: nav 32 (TABS_ORDER, TAB_LABELS_IA, PROFILE_SECONDARY_NOT_TAB, TAB_SWITCH_SELECTS_SECTION, TAB_SWITCH_NO_COMMAND, DEEPLINK_NO_RETURN, INITIAL_START/VORGAENGE/SCHUTZ/POST, DEEPLINK_RETURN_<A>_TO_<B> по декартову произведению перечня вкладок, PROFILE_RETURN_START/VORGAENGE/SCHUTZ/POST, REDUCED_MOTION_ACTIONS, SECTION_CONTENT_COPY), ui 11 (BUTTON_DARK_PRIMARY, BUTTON_DARK_SECONDARY, BUTTON_LIGHT_PRIMARY, BUTTON_LIGHT_SECONDARY, BUTTON_DISABLED_STATE, NOTICE_DARK, NOTICE_LIGHT, TEXTFIELD_DARK, TEXTFIELD_LIGHT, SAFE_KEYBOARD_CONTAINER, ACCENT_NOT_TEXT_ON_LIGHT), static 6 (TOKENS_MATCH, LITERAL_PALETTE, FONTS_PRESENT, FONTS_OFL, NO_WEB_BUNDLE, DEEP_LINK_SCHEME), copy 4 (COPY_TEXT, REVIEW_STATUS, DEPRECATED_KEY, COPY_SURFACE_CATALOG). `--case K` возвращает фактический rc одного case.
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный; каждый мутант из `MUTANTS` даёт отказ на своей именованной ветви; МАТРИЦА ИСПОЛНЯЕТ ВСЕ КОЛОНКИ КАЖДОЙ пробы на каждом мутанте — побочная краснота допустна только в объявленном `depends` (nav 12, ui 11, static 7, copy 4 мутантов; состав пар и depends — только в коде проб); якорь мутанта неуникален → rc2.
- Дано C; `git status --short` в R после проб не содержит следов workspace/мутаций (пробы восстанавливают дерево).
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0, исполнены quality/android-e2e, включая frozen-прогоны 995 и пробы 999 из H; Android/Maestro-сценарий навигации — четыре вкладки, Back, deep link — NOT_RUN до C (отложенная приёмка).
- Дано авторская пачка; `bash scripts/pre_critic.sh --repo . contracts/999-cmp-mob-002-navigatsiya.md` → rc0. Реальные rc предметных прогонов приложены в §Фактический замер.

## Пины и порядок поставки

После critic/freeze оркестратор разрешает `frozen/contracts/999/1^{commit}` в полный SHA H и append-only записывает его с B и ContextPack в issue #6 ДО раздачи implementer. mobile.yml получает те же H-checkout шаги по образцу 995: quality исполняет четыре пробы 999 из H на disposable R (Python 3.12, без pip-зависимостей) до npm test/lint/typecheck/doctor; frozen-шаги 995 сохраняются дословно. Android-e2e и Maestro-гейты не ослабляются; новый Maestro-сценарий навигации (имя `cmp-mob-002-<scenario>.yaml` по STRUCTURE §7) добавляется implementer'ом с локальным предполётом: полный прогон workflow-шагов на станции до PR (Н-311), эмулятор — `sg kvm -c` (Н-318). Реализация не передаёт файлы модели в PR и не ветвится по test-env.

## Зоны и исполнители

ЗОНА architect: contracts/999-cmp-mob-002-navigatsiya.md fixtures/workshop_project/nav_999/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
fixtures/workshop_project/nav_999/ — новый подкаталог существующей architect-зоны; коллизий с живыми заморозками нет, чужие файлы не меняются.

Пути implementer отсчитываются от Complior-mob:

ЗОНА implementer: mobile/src/app/ mobile/src/ui/ mobile/src/theme/ mobile/src/i18n/ mobile/src/bootstrap/tab-shell.tsx mobile/src/features/start/start-screen.tsx mobile/assets/fonts/ .github/workflows/mobile.yml mobile/.maestro/

`(tabs)`-группы и route-файлы — по STRUCTURE §4; `start-screen.tsx` — миграция стилей на theme (§6 STRUCTURE), тест-семантика 991/995 сохраняется. Pilot-семейство 995 (features/auth, features/onboarding, bootstrap/pilot-app.tsx, mocks, api, auth, metro/jest config, bootstrap/__tests__) — read-only для этого PR. docs/, design/, api/ — read-only.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: пробы исполняют настоящий Jest/RNTL на disposable R и разбирают JSON-отчёт поимённо; статические пробы сверяют байты и sha256 с оракулом, снятым до субъекта;
- от второй палитры и дрейфа токенов: побайтовое сравнение с источником + hex-scan зон 002;
- от дыр в покрытии примитивов: декартово произведение примитив × тема с наблюдением каждого заявленного свойства в каждой клетке, включая акцентный гейт на самих примитивах; отвязанный onPress ловится fiber-тождеством проводки (fireEvent.press всплывает и проводку не различает);
- от контейнера-пустышки с сохранённым testID: fiber-тождество композиции SafeAreaView/KeyboardAvoidingView (подмена обычным View красна);
- от подмены копии: точные ключи/тексты/review_status из source.json, deprecated-алиас отвергается; каждый видимый текст поверхности (включая Back) сверяется с каталогом перебором состояний закрытого перечня;
- от скрытой пятой вкладки, слепого deep link, тихой Mission при переключении и инвалидации действий reduced motion: исчерпывающая матрица переходов по закрытому перечню вкладок с первой редакции (Н-324/Н-325), пары мутант↔ветвь объявлены только в коде проб;
- от ложного доказательства независимости: матрицы ВСЕХ четырёх проб исполняют все колонки на каждом мутанте и сравнивают красноту с явно объявленными зависимостями;
- от утечки web-bundle React 18 в RN: import-scan design-snapshot путей.

НЕ ЗАЩИЩАЕТ:
- от визуального качества вне assertions (контраст beyond accent-правила, типографика) — cognitive-only, ловец reviewer по PNG/нативному запуску;
- от «одного primary CTA на экран» как дизайн-правило для будущих срезов: примитив несёт вариант, правило enforced содержимыми срезами; ловец reviewer на C;
- от злонамеренного кода с общим uid: независимые судьи, immutable H, CI evidence;
- от настоящей доставки deep link на устройстве до C: Android-приёмка отложена, NOT_RUN.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: потребляется действующая норма закрытия роли. Новая общая норма не вводится; локальная приёмка исполняется оркестратором/судьями и CI Complior-mob. Пробы 999 исполняются в CI Complior-mob из H-checkout; не добавлять в CI dev-harness зависимость от чужого checkout/SDK.

## Отложенная продуктовая приёмка

- Android/Maestro: четыре вкладки, вторичный маршрут, Back/deep link на release APK — NOT_RUN до C; станционный предполёт `sg kvm -c` (Н-318), полный локальный прогон CI-шагов до PR (Н-311).
- Проверка устройства dark/light/увеличенный шрифт (читаемость, клавиатура) — NOT_RUN до C; RNTL покрывает композицию safe-area/keyboard и accent-правило, не физический рендер.
- Copy signoff CMP-MOB-089, device evidence CMP-MOB-090 — владелец.

## Фактический замер авторской пачки (круг 2, закрытие FAIL критика)

Снимок B=`f0d8e54e181853473e23c7df3dc623bbb7faecdf`, disposable-деревья `/tmp/dev-harness-verify/arch999b/{btree,ref}`; `btree` — нетронутый B с npm ci, `ref` — B + эталонная модель по путям поставки. Замер 2026-10-18.

- B без модели: `nav_probe.py --repo btree` → rc1 NAV_SHELL_ABSENT; `ui_probe.py` → rc1 UI_PRIMITIVES_ABSENT; `shell_static_probe.py` → rc1 STATIC_THEME_ABSENT; `copy_probe.py` → rc1 COPY_MODULE_ABSENT.
- B с эталонной моделью (`--model`): nav rc0 (32/32), ui rc0 (11/11), static rc0 (6/6, шрифты скопированы пробой из docs-снапшота R), copy rc0 (4/4, включая живой RNTL-рендер поверхности).
- Эталон `ref`: те же четыре пробы без `--model` → rc0 каждый.
- Матрицы на `ref` → rc0 все четыре: honest nav 32/32, ui 11/11, static 6/6, copy 4/4; мутанты nav 12, ui 11, static 7, copy 4 — named RED у каждого, depends измерены полным прогоном всех колонок, unexpected_red=none у всех.
- Обходы круга 1 (11 независимых + combined, дословные замены критика): каждый независимый обход даёт rc1 своей пробе (nav: start-never-selected 10 красных клеток, profile-loses-origin 3, initial-post-broken 6, return-only-schutz 12; ui: button-accent-text 4, button-missing-combinations 2, notice-dark-role-missing 1, textfield-dark-password-visible 1, safe-area-is-view 1, keyboard-is-view 1; copy: back-copy-invented 1). Combined (шесть одновременных мутаций критика): nav rc1 (18 красных клеток), ui rc1 (5), copy rc1 (1), static rc0 — статических мутаций в combined нет; все `--matrix` на combined ненулевые.
- После всех прогонов `git status --short --untracked-files=all` в btree пуст; ref восстановлен к базовому состоянию (байты модели идентичны кругу 1).
- Метагейты: `bash scripts/pre_critic.sh --repo . contracts/999-cmp-mob-002-navigatsiya.md` → rc0 (после `git fetch origin --tags` в клоне); `bash scripts/check_threat_model.sh . contracts/999-cmp-mob-002-navigatsiya.md` → rc0; `bash scripts/check_precision_gate.sh . contracts/999-cmp-mob-002-navigatsiya.md` → OK. Они не заменяют предмет.
