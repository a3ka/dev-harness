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

ЗАКРЫТЫЕ ПЕРЕЧНИ (круг 3 по решению арбитража 999: грамматика объявленных портов шва и свойств примитивов, а не выборка известных обходов; Н-324/Н-325). Единственный источник грамматики — source.json: `tabs_order` (TABS, 4 вкладки) и `modes` (reducedMotion [false, true] × colorScheme [dark, light]); расширение перечня = расширение source.json. Состояния S = {tabs(section), profile(origin), deeplink(initial, return)}; действия A = {tab(to) ∀ to∈TABS, profile-entry, back}; режимы MODES = произведение `modes`. Клетки порождаются циклами по этим перечням (тесты nav/ui/copy и `case_list()` проб), не ручным списком; группировка координат в одну клетку допустима, пока имя несёт координаты и перечень не усечён.

- К1 навигация (инварианты 1, 5; порты initialSection/returnSection/reducedMotion/colorScheme/onCommand): `TAB_<FROM>_TO_<TO>_RM<0|1>_<CS>` — нажатие tab(to) ИЗ from в каждом режиме: selected ровно to, `section-to` и его заголовок из каталога, Back отсутствует, onCommand молчит (1.1); `PROFILE_RETURN_<FROM>_RM…_<CS>` — профиль: 0 вкладок, Back = global.back, после back — selected from, onCommand молчит (1.2); `DEEPLINK_RETURN_<A>_TO_<B>_RM…_<CS>` ∀ пар перечня, включая диагональ: Back виден до возврата, selected B после, Back исчезает, onCommand молчит (1.3); `NO_RETURN_<FROM>_RM…_<CS>` — без returnSection Back отсутствует (1.4); при rm=true — faden отсутствует, вкладки не disabled, действия A дают те же состояния, что при rm=false (1.5 — те же клетки на rm=1); статические TABS_ORDER, TAB_LABELS_IA, PROFILE_SECONDARY_NOT_TAB, TAB_SWITCH_NO_COMMAND, SECTION_CONTENT_COPY (1.6);
- К1.5-достижение (микро-круг по вердикту критика круга 3: отсутствие faden при rm=true наблюдается В ДОСТИГНУТОМ состоянии, а не только до действия): `MOTION_TAB_<FROM>_TO_<TO>_RM1_<CS>` — после нажатия tab(to), в состоянии section-to; `MOTION_PROFILE_<FROM>_RM1_<CS>` — в состоянии profile; `MOTION_DEEPLINK_<A>_BACK_<B>_RM1_<CS>` — после back, в return-состоянии section-ret; в каждой клетке shell-faden отсутствует при rm=true. Перечень маршрутов циклов выводится из КОДА эталона — `TAB_ORDER` из mobile/src/theme/tokens.ts и вторичный маршрут profile (наблюдается по shell-profile-entry), не вручную: новый маршрут в коде автоматически порождает клетки MOTION_*_RM1_*. Сторож `MOTION_ROUTE_GRAMMAR`: маршрут в коде вне грамматики source.json (либо утерянный объявленный) краснеет, пока грамматика не расширена — расширение перечня = расширение source.json;
- К2 примитивы (инварианты 2, 3): Button {primary, secondary} × {disabled false, true} × {dark, light} = 8 клеток BUTTON_* — в каждой role button, accessibilityState.disabled === disabled, press → onPress ровно 1 (enabled) / 0 (disabled), fiber-проводка === onPress при enabled, цвета подписи/заливки побайтово из source.json, подпись ≠ accent; Notice × {dark, light} = 2 (role alert, card/on-card, ≠ accent); TextField × {secure true, false} × {dark, light} = 4 — цвет label и самого TextInput = ink ≠ accent, заливка input = panel, secureTextEntry === secure для ОБЕИХ значений, value, onChangeText;
- К3 контейнеры (инвариант 3): 3.1 ближайший композит над host shell-safe-area — SafeAreaView из react-native-safe-area-context, над host shell-keyboard-container — KeyboardAvoidingView из react-native; 3.2 контент состояния (`section-<id>` | `profile-surface`) — потомок ОБОИХ хостов по testID host-fiber'ов; 3.3 каждый видимый хост {shell-back, shell-profile-entry, shell-tab-*} — потомок host shell-safe-area; наблюдается общим обходом поверхности (`surface_sweep.ts` → sweepSurface) в КАЖДОМ состоянии К1 × MODES и в клетках SHELL_CONTAINER_COMPOSITION / SHELL_CONTAINER_PROFILE (замена SAFE_KEYBOARD_CONTAINER);
- К4 copy/accent (инварианты 2, 4): 4.1 все непустые строковые листья toJSON ∈ каталогу source.json (10 текстов); 4.2 Back наблюдается поимённо (global.back) в состояниях profile и deeplink-до-возврата и отсутствует после; 4.3 ВСЕ host-Text/TextInput (обход дерева, не ручной список) имеют color ≠ accent[cs] — в light обязательно (ACCENT_NOT_TEXT_ON_LIGHT), в dark — ACCENT_NOT_TEXT_IN_DARK; клетки COPY_TABS_<FROM>_RM…_<CS> / COPY_PROFILE_… / COPY_DEEPLINK_… покрывают состояния × режимы, обход поверхности — остальные состояния К1;
- матрицы всех четырёх семей исполняют ВСЕ колонки на каждом мутанте; побочная краснота допустна только в явно объявленном `depends` (порождается генератором по грамматике `_cells(...)`, измеряется прогоном), краснота вне named ∪ depends и нецензурированная декларация — дефект матрицы.

Не входит (совет круга 3, не блокер; переоткрывается только ссылкой на вердикт арбитража): нажатие вкладки/профиля при заданном `returnSection` (судьба Back и returnTo); присутствие faden при rm=false; dark-гейт shell как отдельное требование (наблюдается клеткой, модель выполняет); fontFamily DM Sans в стилях (инвариант 6 требует только файлы+OFL); физический рендер safe-area/клавиатуры (NOT_RUN до C); порядок и гранулярность клеток при сохранённой грамматике.

## Приёмочный критерий

R — disposable копия Complior-mob (B или C) под /tmp/dev-harness-verify с `npm ci` в `mobile/`; пробы — Python 3 stdlib, отдельная установка не нужна. Нет Jest/артефактов отчёта → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B без реализации; `python3 fixtures/workshop_project/nav_999/nav_probe.py --repo R` → rc1 NAV_SHELL_ABSENT; `ui_probe.py --repo R` → rc1 UI_PRIMITIVES_ABSENT; `shell_static_probe.py --repo R` → rc1 STATIC_THEME_ABSENT; `copy_probe.py --repo R` → rc1 COPY_MODULE_ABSENT. Четыре именованных отказа — краснота предмета на до-предметном дереве.
- Дано B с эталонной моделью (те же команды с `--model`); либо дано честное C — все четыре пробы → rc0 с построчным перечнем case: nav 238 (TABS_ORDER, TAB_LABELS_IA, PROFILE_SECONDARY_NOT_TAB, TAB_SWITCH_NO_COMMAND, SECTION_CONTENT_COPY, TAB_<A>_TO_<B>_RM<0|1>_<DARK|LIGHT> по декартову произведению перечня вкладок на себя × режимы, PROFILE_RETURN_<A>_RM…_<CS>, NO_RETURN_<A>_RM…_<CS>, DEEPLINK_RETURN_<A>_TO_<B>_RM…_<CS>, MOTION_ROUTE_GRAMMAR, MOTION_TAB_<A>_TO_<B>_RM1_<CS>, MOTION_PROFILE_<A>_RM1_<CS>, MOTION_DEEPLINK_<A>_BACK_<B>_RM1_<CS>), ui 18 (BUTTON_<SCHEME>_<VARIANT> и BUTTON_<SCHEME>_<VARIANT>_DISABLED по произведению {primary, secondary} × {disabled} × {dark, light}, NOTICE_DARK, NOTICE_LIGHT, TEXTFIELD_<SCHEME>_SECURE_<0|1>, SHELL_CONTAINER_COMPOSITION, SHELL_CONTAINER_PROFILE, ACCENT_NOT_TEXT_ON_LIGHT, ACCENT_NOT_TEXT_IN_DARK), static 6 (TOKENS_MATCH, LITERAL_PALETTE, FONTS_PRESENT, FONTS_OFL, NO_WEB_BUNDLE, DEEP_LINK_SCHEME), copy 51 (COPY_TEXT, REVIEW_STATUS, DEPRECATED_KEY, COPY_TABS_<A>_RM…_<CS>, COPY_PROFILE_<A>_RM…_<CS>, COPY_DEEPLINK_<A>_RM…_<CS>). `--case K` возвращает фактический rc одного case.
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный; каждый мутант из `MUTANTS` даёт отказ на своей именованной ветви; МАТРИЦА ИСПОЛНЯЕТ ВСЕ КОЛОНКИ КАЖДОЙ пробы на каждом мутанте — побочная краснота допустна только в объявленном `depends` (nav 20, ui 18, static 7, copy 5 мутантов, включая 12 декоев арбитража: 7 критика + X1–X5 арбитра, и 4 декоя микро-круга К1.5 — route-exception-profile, route-exception-post, route-exception-schutz, route-added-outside-grammar; состав пар и depends — только в коде проб); якорь мутанта неуникален → rc2.
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
- от скрытой пятой вкладки, слепого deep link, тихой Mission при переключении и инвалидации действий reduced motion: исчерпывающая таблица переходов по закрытой грамматике портов (вкладки × состояния × действия × режимы, круг 3 по арбитражу), пары мутант↔ветвь объявлены только в коде проб;
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

## Фактический замер авторской пачки (круг 3, исполнение решения арбитража)

Снимок B=`f0d8e54e181853473e23c7df3dc623bbb7faecdf`; disposable-деревья `/tmp/dev-harness-verify/arch999c/{btree,ref}`; `btree` — нетронутый B с npm ci, `ref` — B + эталонная модель по путям поставки (модель и зона implementer не менялись: З-0 арбитража — модель полна). Замер 2026-10-18, коммит круга 3.

- B без модели: `nav_probe.py --repo btree` → rc1 NAV_SHELL_ABSENT; `ui_probe.py` → rc1 UI_PRIMITIVES_ABSENT; `shell_static_probe.py` → rc1 STATIC_THEME_ABSENT; `copy_probe.py` → rc1 COPY_MODULE_ABSENT.
- B с эталонной моделью (`--model`): nav rc0 (165/165), ui rc0 (18/18), static rc0 (6/6), copy rc0 (51/51).
- Эталон `ref`: те же четыре пробы без `--model` → rc0 каждый.
- Матрицы на `ref` → rc0 все четыре: honest nav 165/165, ui 18/18, static 6/6, copy 51/51; мутанты nav 16, ui 18, static 7, copy 5 — named RED у каждого, depends порождены генератором по грамматике и измерены полным прогоном всех колонок, unexpected_red=none у всех.
- 12 декоев арбитража по отдельности на `ref` (патчи байт-в-байт из арбитражных констант measure.py): каждый даёт rc1 своей семье и rc1 именованной клетке — transition-post-vorgaenge → nav/TAB_POST_TO_VORGAENGE_RM0_DARK; reduced-motion-emits-command → nav/TAB_START_TO_VORGAENGE_RM1_DARK; nav-gated-by-colorScheme → nav/TAB_START_TO_POST_RM0_LIGHT; copy-invented-under-reducedMotion → nav/TAB_START_TO_VORGAENGE_RM1_DARK; secondary-disabled-ignored → ui/BUTTON_DARK_SECONDARY_DISABLED; input-accent-text → ui/TEXTFIELD_DARK_SECURE_1; textfield-always-secure → ui/TEXTFIELD_DARK_SECURE_0; containers-detached → ui/SHELL_CONTAINER_COMPOSITION; tabbar-outside-safe-area → ui/SHELL_CONTAINER_COMPOSITION; profile-not-in-keyboard-container → ui/SHELL_CONTAINER_PROFILE; nonstart-accent-title → ui/ACCENT_NOT_TEXT_ON_LIGHT; light-copy-invented → copy/COPY_TABS_START_RM0_LIGHT.
- Combined критика (шесть одновременных мутаций круга 2, конструирование арбитража): nav rc1, ui rc1, copy rc1, static rc0 — статических мутаций в combined нет.
- Прежние обходы круга 1 и status-lost не регрессировали: именованные ветви RED в матрицах (входят в nav 16 / ui 18 / copy 5).
- После всех прогонов `git status --short --untracked-files=all` в btree пуст; ref возвращён к базовому состоянию (эталонные файлы модели, 6 строк статуса).
- Метагейты: `bash scripts/pre_critic.sh --repo . contracts/999-cmp-mob-002-navigatsiya.md` → rc0 (после `git fetch origin --tags` в клоне); `bash scripts/check_threat_model.sh . contracts/999-cmp-mob-002-navigatsiya.md` → rc0; `bash scripts/check_precision_gate.sh . contracts/999-cmp-mob-002-navigatsiya.md` → OK. Они не заменяют предмет.

## Фактический замер микро-круга К1.5 (2026-10-19, вердикт критика круг 3)

Снимок B=`f0d8e54e181853473e23c7df3dc623bbb7faecdf`; деревья `/tmp/dev-harness-verify/Architect999m/{R,ref}`: R — нетронутый B (npm ci готов), ref — B + эталонная модель (8 файлов MODEL_FILES) + DM Sans/OFL в `mobile/assets/fonts` (static-матрица без `--model` читает шрифты из дерева, как в круге 3).

- R без модели: nav → rc1 NAV_SHELL_ABSENT; ui → rc1 UI_PRIMITIVES_ABSENT; static → rc1 STATIC_THEME_ABSENT; copy → rc1 COPY_MODULE_ABSENT.
- Четыре пробы на R с `--model` → rc0; nav 238/238 (165 прежних не тронуты + 73 новых MOTION: ROUTE_GRAMMAR 1, TAB 32, PROFILE 8, DEEPLINK_BACK 32), ui 18/18, static 6/6, copy 51/51.
- Матрицы на ref → rc0 все четыре: nav 20 мутантов (16 прежних + 4 новых), ui 18, static 7, copy 5; у каждого мутанта named RED, depends_red точны, unexpected_red=none.
- Новые декои микро-круга К1.5: `route-exception-profile` (патч критика круга 3 `(!reducedMotion || route === 'profile')`) → named RED `MOTION_PROFILE_START_RM1_DARK`, все 8 `MOTION_PROFILE_*` красны, а ПРЕЖНИЕ клетки на нём зелёны — дыра была именно в наблюдении после действия; `route-exception-post` (`section === 'post'`) → named RED `MOTION_TAB_START_TO_POST_RM1_DARK`; `route-exception-schutz` (`section === 'schutz'`) → named RED `MOTION_DEEPLINK_START_BACK_SCHUTZ_RM1_DARK`; `route-added-outside-grammar` (честная пятая вкладка `heute` в TAB_ORDER + ключи каталога, БЕЗ дефекта faden) → named RED `MOTION_ROUTE_GRAMMAR` + depends `PROFILE_SECONDARY_NOT_TAB` (5 вкладок) — сторож: честный новый маршрут краснеет, пока грамматика source.json не расширена, клетки для него уже порождены циклами по код-перечню.
- После всех прогонов `git status --short --untracked-files=all` в R пуст (0 строк); ref несёт только эталонные файлы (8 модели + 2 шрифта).
- Метагейты в клоне ветки: `pre_critic.sh` → rc0 («дверь зелёная»), `check_threat_model.sh` → rc0 (8/4 буллета), `check_precision_gate.sh` → OK.

## Незаполненные требования:
- Принятый остаток К1.5 (слово владельца 2026-10-19 ~12:05 UTC): анимации переходов есть по умолчанию; при системной настройке reducedMotion анимаций нет НИГДЕ (включая возврат из profile), и ВСЕ вкладки, включая выбранную, остаются нажимаемыми (не disabled) — эталонные клетки обходов krug4/krug5 не покрывают; проверяет адверсарий на коде реализации.
