# Контракт 108 — CMP-MOB-004: Start — Personal Agent и адаптивное рабочее пространство

КЛАСС: КОДОВЫЙ. Авторский контракт CMP-MOB-004; предмет issue #8 сохранён. Android-приёмка (Maestro) следует после реализации C, не подменяется авторскими моделями.

КОНТЕКСТ: GitHub `a3ka/Complior-mob#8` — источник работ и приёмки; перед раздачей читать полное тело через `gh issue view 8 --repo a3ka/Complior-mob --json body --jq .body`.
КОНТЕКСТ: `contracts/999-cmp-mob-002-navigatsiya.md` и `contracts/107-cmp-mob-003-erstinformation.md` — дисциплина H/B/C/T, disposable R, пробы с --matrix, пины H в mobile.yml; frozen-семейства проб 995/999 не переписываются.
КОНТЕКСТ: `verdicts/critic/contracts-107-krug1-fail.md`, `verdicts/critic/contracts-107-krug2-fail.md`, `verdicts/arbitration/contracts-107-perechen-v1.md` — оси доказательства (полное произведение значений полей, действия × полный вектор эффектов, порядок событий, настоящий mock/runtime с полным снимком) применены с первой редакции; критерий построен ЗАКРЫТЫМ произведением осей, не поштучными мутантами. Круг 1 критика 108 (9 осей, 15 обходов) закрыт этим же способом: произведение диагностик расширено до ui_state × admission(вкл. null) × mission_state × действие с полным вектором ПОСЛЕ каждого шага, переходы (ACL/недоступность/смена данных), структура на достигнутых состояниях, независимый оракул литералами, точная замкнутость enum, текст кадра на поверхности; каждый из 15 обходов — именованная красная клетка пробы (см. §Закрытие осей круга 1).
КОНТЕКСТ: `fixtures/workshop_project/start_108/source.json` — оракул: копия каталога и грамматика Start (features/F04), снятые с дерева B ДО запуска субъекта; проб-тесты несут те же значения побайтово из этого файла.

## Нарезка предмета (frontier)

Три варианта рассматривались до первой редакции:

1. **Один контракт = весь предмет** (F04.01–F04.07 экраны Start, шов ApiClient + listMissions, mock-сценарии, маэстро-сценарий; один PR) — **выбран**. Боль: P0 W0 срез F04 — стартовая поверхность всего продукта; расщепление «экран/шов» порождает слой без обратной связи (норма вертикального слайса 050), а resume без listMissions не наблюдаем (открытие доступного дела ≠ отображение заглушки).
2. Два контракта (шов+mock / экран) — отвергнут: экран без listMissions-грамматики не проверяет главный риск предмета (продолжение недоступного дела по протухшему ACL-снимку), шов без экрана не имеет потребителя в строке приёмки.
3. Срез без resume (только presence+composer) — отвергнут: сужает предмет против issue (работа 4 и критерий приёмки «revoked ACL убирает прежнее содержание ResumeBrief» прямо требуют оси ACL).

Критерий выбора: вертикальный слайс 050 + граница «ОДИН PR» из issue (Kind: SLICE).

## Существующее

Сверено на read-only снимке Complior-mob `76ac10fac668a1036371c4b392061ce9b3277ebc` (HEAD main после merge PR#111; подтверждён `gh api repos/a3ka/Complior-mob/commits/main --jq .sha`). Полные HEAD, не имена веток.

- `mobile/src/api/api-client.ts` (sha256 в source.json): ТОЛЬКО getSession/getDisclosure; listMissions и типы MissionBrief/MissionState/MissionPage отсутствуют — предмет на B отсутствует. `api/generated/api-5_8.ts` — read-only, Session/Disclosure.
- OpenAPI 5.8.2 (`api/BrokerOS_Unified_OpenAPI_v3.yaml`): listMissions — GET /v1/missions, W0, q/cursor/limit/state-фильтры; ответ MissionPage{items: MissionSnapshot[]≤50, next_cursor?}; описание операции: «ACL filters hits/counts/cursors before serialization». MissionSnapshot.state — замкнутый enum из 10 значений (RECEIVED…CANCELLED).
- `api/frontend-consumer-bindings.json#actions/F04.A01,A02,A03`: все три CLIENT_NATIVE, CLIENT_NAVIGATION, authoritative_effect NONE_AT_THIS_UI_STEP; A01/A02 читают getSession, A03 читает listMissions; «opening a view does not grant access».
- Дизайн-данные `docs/ux/01_UX_Source_of_Truth/BrokerOS_Mobile_Design_Data.json#features/F04`: frames F04.01–F04.15; canonical_components AgentPresence/ConversationComposer/MissionCard/MissionResumeBrief; data (avatar_state idle/working/unavailable, active_mission_id, resume_mission_id MIS-CAR-01, unread/needs_user, canvas_widget_ids); variants F04.V01 (нет дел), V02 (продолжение: avatar working), V03 (unavailable), V04 (reduce_motion); rule: «Presence 55–65% в покое, не более одной contextual state card», «Список дел не заменяет стартовый экран с аватаром», «без портфельных KPI», «Новые карточки появляются в устойчивых слотах». Screen Matrix CS01/F04.01: «спокойная фраза только в пределах подтверждённых текущих Vorgänge, без общего обещания полноты защиты»; миссия «Нет до meaningful input».
- Каталог `BrokerOS_UI_Copy_DE.json`: 13 ключей 108 (frame.F04.01/02/03/06/07 title+body, action.F04.A01/A02/A03) с review_status; ключа недоступности агента в каталоге НЕТ — состояние unavailable показывается структурно, без изобретённого текста (copy signoff CMP-MOB-089).
- `mobile/src/i18n/ui-copy.ts`: 10 ключей 002 (IA-вкладки, заголовки F04.01/F08/F19/F16, F12.A01, global.back); frame.F04.01.title уже используется tab-shell как заголовок секции Start.
- `mobile/src/features/start/`: скелет 991/002 (start-screen.tsx «Prüfung starten» + legacy-тесты rehearsal.test.tsx/start-screen.test.tsx) — не подключён к TabShell (tab-shell.tsx:269 рендерит только заголовок секции); заменяется предметом 108. Замороженная семья nav_999 (shell_static_probe) проверяет start-screen.tsx только на hex-литералы/токены темы — новая поставка тему сохраняет, замороженные пробы не переписываются.
- `mobile/src/mocks/runtime.ts`: mock ApiClient getSession/getDisclosure из pilot-responses.json (getSession.locale 'de-DE'); SYNTHETIC-evidence — прецедент. `mobile/src/ui/`: button/notice/text-field — прецедент композиции.
- Заявленная оговорка issue: mock не доказывает реальную выдачу; NOT_RUN→PASS только с HTTP_REQUEST_RESPONSE/SQL_BEFORE_AFTER/PROVIDER_CALL_COUNT соответствующего SWITCH/бэкенда (бэкенд CMP-BCK-008/009 — вне этого контракта).

## Предмет и граница

Один результат: экран Start по грамматике features/F04 — AgentPresence (ui/agent-presence) с состояниями idle/working/unavailable, единый ConversationComposer (ui/conversation-composer) с сохраняемым черновиком, MissionResumeBrief (ровно одна контекстная карточка) из listMissions; кадры F04.01 (спокойное присутствие), F04.02 (ожидание ввода), F04.03 (Listening — UI-состояние), F04.06 (продолжение той же Mission), F04.07 (единый композер); шов ApiClient расширяется операцией listMissions (W0) с клиентскими типами MissionBrief/MissionState/MissionPage; действия: F04.A01 (Написать → F05.01, только навигация), F04.A02 (Поговорить → F06.01, БЕЗ микрофона/voice session до W2/capability), F04.A03 (Продолжить дело → открытие доступного дела из listMissions; отзыв ACL убирает прежнее содержание brief); пустой Start — присутствие и один композер, не список пустых групп; KPI-дашборда нет; unavailable честен и с сохранённым контекстом; reduced motion сохраняет действия и устойчивые слоты. ОДИН PR в a3ka/Complior-mob, без Merge.

Вне предмета: реальная HTTP-выдача миссий (CMP-BCK-008/009), голосовой runtime W2 и микрофон, F05/F06/F09-экраны назначения переходов, кадры F04.04/F04.05 (рабочий canvas/структурированный результат — стадии активной Mission-беседы, в W0-срезе поставляются каналом F05; см. §Вопросы), F04.08–F04.15, Vorgänge-группы CS09, KPI-виджеты. Pilot-семейство 995 (features/auth, bootstrap/pilot-app.tsx, metro/jest config, bootstrap/__tests__) не рестайлится; frozen-пробы 995/999 не переписываются. Copy signoff CMP-MOB-089 и device evidence CMP-MOB-090 этим PR не объявляются завершёнными.

## Инварианты

1. `mobile/src/api/api-client.ts` несёт три операции (getSession, getDisclosure, listMissions); типы MissionBrief {mission_id, state, updated_at}, MissionState (ровно 10 значений OpenAPI) и MissionPage {items, next_cursor?} определены в ЭТОМ модуле одним местом — потребители (экран, mock, пробы) не переизобретают перечней; LISTENING не является значением MissionState (Listening — UI-состояние экрана).
2. `mobile/src/features/start/start-screen.tsx` — порты-инъекция по прецеденту tab-shell: missions (тип допускает null — listMissions недоступен → безопасный fallback без brief/resume, без краха), avatarState, reducedMotion подаются снаружи; экран не знает транспорта и не ветвится по test-env; аудио/mикрофонных импортов экран не несёт.
3. Пустой Start (missions [] или null) показывает AgentPresence и РОВНО один ConversationComposer; start-empty-groups не рендерится никогда; KPI-дашборд не рендерится никогда; контекстных карточек не более одной; присутствие не заменяется списком дел ни в одном состоянии × движении × доступности.
4. MissionResumeBrief виден ⇔ в missions есть доступное дело (ACL фильтрует listMissions ДО сериализации — доступность = присутствие в items); бриф показывает mission_id, state, updated_at; resume-кнопка (action.F04.A03) ⇔ доступное дело есть; нажатие → onResume(mission_id) и ТОЛЬКО его; исчезновение дела из items (отзыв ACL) убирает прежнее содержание brief и resume без остаточных приватных строк (mission_id не остаётся на экране).
5. F04.A01 write: всегда доступен; нажатие → onWrite и только; из Listening возвращает к тексту (кадр F04.02). F04.A02 talk: всегда доступен; вход в голосовой канал видим; нажатие → onTalk и только + UI-состояние Listening (кадр F04.03 «Ich höre zu.»); микрофон/voice session НЕ запрашиваются ни в одном состоянии (порт-наблюдатель onMicrophoneRequested никогда не вызывается); Listening — чистое UI-состояние: missions/эффекты не меняются, каналы не создают конкурирующую Mission.
6. Черновик композера сохраняется при смене avatarState/missions (включая отзыв ACL) и при смене канала (Listening → write): Maestro-критерий «написать → вернуться → продолжить; mission_id и черновик сохранены» — клиентская половина.
7. F04.V03: avatarState unavailable — присутствие сохраняется со структурным индикатором состояния (не выглядит работающим процессом: индикатор working не показывается), композер/действия/brief/черновик сохраняются (контекст сохранён). F04.V04: reducedMotion=true — все действия и слоты карточек (testID presence/composer/brief) неизменны.
8. `mobile/src/i18n/ui-copy.ts` — verbatim-подмножество каталога (+12 ключей 108 к существующим 10; frame.F04.01.title уже был); новых немецких формулировок не вводится; review_status сохранён. Индикатор состояния присутствия — ASCII/структурный, не production-copy.
9. `mobile/src/mocks/start-mock.ts` — сценарии presence × state для listMissions (грамматика source.json); `mocks/runtime.ts` расширяется listMissions (до CMP-BCK-008/009 — mock, SYNTHETIC-маркировка ответов не выдаётся за реальную доставку); настоящий runtime.api исполняет getSession/listMissions.

## Проверяемый шов

`mobile/src/features/start/start-screen.tsx` экспортирует `StartScreen` с портами `missions` (допускает null), `avatarState`, `reducedMotion`, `onWrite`, `onTalk`, `onResume(missionId)`, `onMicrophoneRequested` (запрещённый наблюдатель — честный экран не вызывает его никогда). `ui/agent-presence/agent-presence.tsx` экспортирует AgentPresence (AvatarState), `ui/conversation-composer/conversation-composer.tsx` — ConversationComposer. `mocks/start-mock.ts` — сценарии для расширенного mock ApiClient. Ожидания проб снимаются в память (source.json, байты теста) до запуска субъекта; привязка мутант↔ветвь живёт только в коде проб (`MUTANTS`), не в прозе контракта (Н-39). Модель architect в `fixtures/workshop_project/start_108/model/` — честный эталон; в PR не копируется.

ЗАКРЫТЫЕ ПЕРЕЧНИ (замкнуты арбитражем 108 — `verdicts/arbitration/contracts-108-pravila-e-p-v1.md`, Решение 2). Единственный источник грамматики — source.json: `avatar_states` (3), `missions_presence` (2), `motion` (2), `ui_states` (3: CALM/INPUT/LISTENING с кадрами F04.01/F04.02/F04.03), `actions` (3), `effects` (4: write/talk/resume/mic), `mission_states` (10 значений OpenAPI), `copy` (13 ключей), `fixed` (mission_id MIS-CAR-01, updated_at, draft_text), `server_grammar` (missions_absent → безопасный fallback; mission_availability = присутствие в items); admission = missions_presence ∪ {NULL} (3 значения). Клетки порождаются циклами по этим перечням (start.test.tsx: `for avatar × presence × motion`, `for action × avatar × presence × motion`, `for ui × action × admission`, `for ui × to × avatar`, `for state × motion`, `for from × to` включая from===to, `for presence × state`, `for {FIXED,ALT}³`), не ручным списком; ручные исключения из цикла (диагональ) не допускаются. ДВА ПРАВИЛА НА ВЕСЬ ТЕСТ. Правило Э (эффекты): каждая клетка, выполняющая хотя бы один шаг (press/focus/changeText/rerender), заканчивается `toEqual` ПОЛНОГО вектора эффектов {write, talk, resume, mic} — write = число нажатий write, talk = число нажатий talk, resume = список id по нажатиям resume, mic = 0 всегда; чтение части вектора не допускается. Правило П (поля): каждая клетка, где brief ожидаем видимым, сверяет все три поля `start-brief-mission-id`/`start-brief-state`/`start-brief-updated-at` exact-литералом (FIXED/ALT/состояние клетки) И наличие `start-action-resume`; где невидимым — тройное отсутствие (`start-resume-brief` null, `start-action-resume` null, `queryByText(mission_id)` null). Итого поведенческая семья 324 клетки, статическая 22. Арифметика поведенческой: STRUCTURE 12 + STRUCTURE_AFTER 24 + BRIEF_STATE 10 + BRIEF_FIELDS 8 + RESUME_EFFECT 20 + ADMISSION_LOST 18 + MISSIONS_NULL 3 + ACTION 36 + ACTION_FROM 27 + SNAPSHOT_REFRESH 100 + FRAME 9 + DRAFT_PRESERVED 3 + DRAFT_AVATAR 6 + DRAFT_ADMISSION 2 + MOCK_SCENARIO 20 + MOCK_SCENARIO_SETTER 1 + ORACLE_MISSION_STATES 1 + RUNTIME_SCENARIO 20 + RUNTIME_LIST_EMPTY 1 + RUNTIME_LIST_PRESENT 1 + RUNTIME_SESSION_EXECUTES 1 + RUNTIME_SNAPSHOT_FULL 1 = 324 (число — для сверки; авторитет — циклы по грамматике). Статической: COPY_KEY 13 + STATIC_API_SEAM 3 + STATIC_MISSION_STATE_ENUM + STATIC_MOCK_SCENARIOS + STATIC_MOCK_RUNTIME_WIRED + STATIC_NO_VOICE_ENUM + STATIC_NO_AUDIO_IMPORTS + STATIC_ORACLE_LITERALS = 22.

- К1 структура (инварианты 3, 7): `STRUCTURE_<avatar>_<presence>_<motion>` ×12 — произведение 3×2×2 на начальном рендере: присутствие есть всегда, ровно один композер, ≤1 контекстная карточка, empty-groups/KPI/voice-session отсутствуют, brief ⇔ PRESENT, unavailable не выглядит working, слоты стабильны в обоих движениях.
- К1′ структура на достигнутых состояниях (инварианты 3, 5, 7): `STRUCTURE_AFTER_<INPUT|LISTENING>_<avatar>_<presence>_<motion>` ×24 — то же произведение ПОСЛЕ взаимодействия (фокус композера / talk): присутствие не исчезает, запрещённые элементы (empty-groups/KPI) не появляются, бриф/mission_id наблюдаются на достигнутом состоянии.
- К2 бриф (инвариант 4): `BRIEF_STATE_<state>` ×10 — бриф несёт полное состояние (все 10 значений enum), mission_id, updated_at И кадр F04.06 текстом каталога (title+body на поверхности, не только в ui-copy.ts).
- К2′ поля брифа из порта (арбитраж 108 D): `BRIEF_FIELDS_<id>_<state>_<ts>` ×8 — произведение ЗНАЧЕНИЙ полей {FIXED, ALT}³ (смешанные поля — внутри перечня; одна ALT-пара доказывает 2 точки из 8): поданный снимок отражается дословно (правило П), resume-аргумент = поданный mission_id (правило Э).
- К2″ resume-эффект: `RESUME_EFFECT_<state>_<motion>` ×20 — произведение 10×2: полный вектор эффектов {write:0, talk:0, resume:[mission_id], mic:0} в каждой клетке.
- К2″′ ∪ К8 потеря доступа (арбитраж 108 B): `ADMISSION_LOST_<ui>_<to>_<avatar>` ×18 — произведение ui(3: CALM/INPUT/LISTENING) × to{EMPTY,NULL} × avatar(3); растворяет прежние ACL_REVOKED ×3 / ACL_REVOKED_LISTENING ×3 / MISSIONS_NULL_TRANSITION ×3 (переход PRESENT→EMPTY/null на ЛЮБОМ достигнутом ui-состоянии): прежнее содержание brief/resume/mission_id убрано (правило П), присутствие/композер живы, полный вектор ПОСЛЕ перехода (правило Э; talk=1 только при достигнутом LISTENING).
- К8 недоступность: `MISSIONS_NULL_<avatar>` ×3 (null при первом render) — безопасный fallback без остаточной карточки (правило П).
- К3″ обновление снимка (арбитраж 108 A): `SNAPSHOT_REFRESH_<from>_<to>` ×100 — ПОЛНЫЙ квадрат 10×10 всех упорядоченных пар состояний, ВКЛЮЧАЯ диагональ from===to (повторный снимок того же состояния — штатное событие listMissions; ручное `continue` из цикла исключено): при неизменной кардинальности экран показывает ПОДАННОЕ состояние до и после rerender (правило П), вектор эффектов нулевой (правило Э).
- К3 действия (инвариант 5): `ACTION_<action>_<avatar>_<presence>_<motion>` ×36 — произведение 3×3×2×2 из CALM: доступность по правилу, полный вектор эффектов, voice-session нет.
- К3′ действия из достигнутых состояний (инвариант 5): `ACTION_FROM_<ui>_<action>_<admission>` ×27 — произведение 3×3×3 (admission EMPTY/PRESENT/NULL): полный вектор эффектов проверен ПОСЛЕ достижения ui-состояния и ПОСЛЕ действия (порядок событий: снимок до последнего действия ничего не доказывает); resume ⇔ PRESENT, mic всегда 0.
- К4 UI-состояния кадров (инварианты 5, 8): `FRAME_<CALM|INPUT|LISTENING>_<avatar>` ×9 — кадры F04.01/F04.02/F04.03 копией каталога; INPUT по фокусу; LISTENING по talk: бриф на месте, выход write возвращает F04.02, полный вектор эффектов проверен ПОСЛЕ выхода.
- К5 черновик (инвариант 6): `DRAFT_PRESERVED_<AVATAR_CHANGE|ACL_CHANGE|LISTENING_ROUNDTRIP>` ×3 + `DRAFT_AVATAR_<from>_TO_<to>` ×6 (все переходы avatar, включая unavailable) + `DRAFT_ADMISSION_<EMPTY|NULL>` ×2 — черновик переживает смену avatarState/доступности/канала.
- К6 mock/runtime (инвариант 9): `ORACLE_MISSION_STATES` ×1 (перечень мока == оракулу source.json); `MOCK_SCENARIO_<presence>_<state>` ×20 + `MOCK_SCENARIO_SETTER`; `RUNTIME_SCENARIO_<presence>_<state>` ×20 — настоящий `@/mocks/runtime`.api.listMissions по ВСЕМ сценариям, и тот же `page.items` подаётся в `<StartScreen missions={page.items} avatarState="idle" />` БЕЗ onResume/обработчиков (путь runtime → экран; правило П: PRESENT — все три поля exact по state, EMPTY — тройное отсутствие); `RUNTIME_LIST_EMPTY`, `RUNTIME_LIST_PRESENT`, `RUNTIME_SESSION_EXECUTES`, `RUNTIME_SNAPSHOT_FULL` — runtime без mock-подмены методов, полный снимок в экран (RUNTIME_SNAPSHOT_FULL — все три поля после render, правило П).
- Статическая семья (22): `COPY_KEY_<key>` ×13, `STATIC_API_SEAM_<GETSESSION|GETDISCLOSURE|LISTMISSIONS>` ×3, `STATIC_MISSION_STATE_ENUM` — ТОЧНОЕ равенство множества (разбор RHS `export type MissionState =` до `;`, ровно 10 значений source.json), `STATIC_MOCK_SCENARIOS`, `STATIC_MOCK_RUNTIME_WIRED`, `STATIC_NO_VOICE_ENUM` (MissionState без LISTENING), `STATIC_NO_AUDIO_IMPORTS` (экраны Start без аудио-импортов), `STATIC_ORACLE_LITERALS` (start.test.tsx несёт fixed/различающую пару литералами и НЕ импортирует MISSION_ID/UPDATED_AT из мока — страж независимости оракула, правило 8).
- Матрицы обеих проб исполняют ВСЕ колонки на каждом мутанте; depends каждого мутанта — red-набор, измеренный полным прогоном до заморозки; краснота вне named ∪ depends — дефект матрицы.

НЕ ВХОДИТ в перечень (арбитраж 108, «что НЕ блокирует круг 3»): регрессионные стражи самого теста H (поздний Object.assign, импорт через алиасы, иные правки байтов проверяющего — H пинится SHA); произвольные истории взаимодействий сверх одного достигнутого ui-состояния и одного перехода; повторные/конкурентные нажатия; переходы avatar во время LISTENING/INPUT; произведения «достигнутое ui × смена снимка» сверх ADMISSION_LOST; реальная HTTP-выдача (CMP-BCK-008/009); app-композиция (tab-shell, http-runtime) и Maestro (зона implementer/C); F04.04/F04.05, terminal-состояния resume, формулировка unavailable — владелец (§Вопросы); гранулярность it и имена клеток при сохранённой грамматике; типы значений вне объявленных (undefined, не-строки).

## Закрытие осей круга 1 критика (9 осей → 15 обходов)

Каждая ось закрыта КОНЕЧНЫМ произведением клеток (числа выше) и правилами Э/П, не поштучными условиями. Каждый из 15 обходов круга 1 и 4 обходов круга 2 (оси 2а/2б/6 + совет о смешанных полях, арбитраж 108) — мутант в `MUTANTS` соответствующей пробы с именованной красной клеткой; привязка мутант↔именованная ветвь↔depends живёт ТОЛЬКО в коде проб (`start_probe.py: MUTANTS`, `start_static_probe.py: matrix`), измерена полным прогоном до заморозки и в прозе контракта не дублируется (Н-39):

1. Независимость оракула снимка → ORACLE_MISSION_STATES ×1 + литеральный fixed/ALT в тесте + STATIC_ORACLE_LITERALS (статич.).
2. Произведение ui_state × admission × mission_state × действие × эффекты → ACTION_FROM ×27 + RESUME_EFFECT ×20 + правило Э.
3. ACL/fallback/обновление снимка при переходах → ADMISSION_LOST ×18 + SNAPSHOT_REFRESH ×100 (полный квадрат) + правила Э/П на переходах.
4. Присутствие и запрещённые элементы после взаимодействия → STRUCTURE_AFTER ×24.
5. Зависимость полей brief от переданного снимка → BRIEF_FIELDS ×8 (произведение значений, включая смешанные) + правило П.
6. Настоящий runtime по всем сценариям → RUNTIME_SCENARIO ×20 с подачей page.items в экран + правило П.
7. Черновик × unavailable-переход → DRAFT_AVATAR ×6 + DRAFT_ADMISSION ×2.
8. Замкнутость wire-enum → STATIC_MISSION_STATE_ENUM (точное равенство).
9. Каталог copy ↔ отображение на поверхности → BRIEF_STATE ×10 с текстами F04.06.

Круг 2 (замкнут арбитражем 108, Решения 1–2): эффекты после КАЖДОГО шага и снимок ВСЕМИ полями — правила Э и П на весь тест; четыре мутанта критика круга 2 включены в `MUTANTS` декоями байт-в-байт с измеренным depends (П5).

## Приёмочный критерий

R — disposable копия Complior-mob (B или C) под /tmp/dev-harness-verify с `npm ci` в `mobile/`; пробы — Python 3 stdlib. Нет Jest/артефактов отчёта → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B без реализации; `python3 fixtures/workshop_project/start_108/start_static_probe.py --repo R` → rc1 START_SEAM_ABSENT; `start_probe.py --repo R` → rc1 START_SEAM_ABSENT. Именованный отказ — краснота предмета на до-предметном дереве.
- Дано B с эталонной моделью (`--model`); либо дано честное C — обе пробы → rc0 с построчным перечнем case: статическая 22/22, поведенческая 324/324 (семьи К1, К1′, К2, К2′, К2″, К2″′∪К8 (ADMISSION_LOST+MISSIONS_NULL), К3, К3′, К3″, К4, К5, К6 + статическая выше; правила Э/П во всех клетках).
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный; каждый мутант даёт отказ на своей именованной ветви; побочная краснота только в объявленном depends; мутантов 36 (поведенческая семья: 18 исходных + 14 круга 1 + 4 декоя круга 2 по арбитражу 108, патчи байт-в-байт) + 5 (статическая: 4 исходных + wire-enum-not-closed); якорь мутанта неуникален → отказ. СМЫСЛ `--matrix` — самопроверка набора проб и эталона на мутантах (матрица временно замещает файлы продукта моделью), НЕ свидетельство честности C; честность C — обычные пробы без `--model` на дереве PR.
- Дано C; `git status --short --untracked-files=all` в R после проб не содержит следов workspace/мутаций (пробы восстанавливают дерево).
- Дано C; `npm run lint`, `npm run typecheck`, `npm test` в R/mobile зелёные: legacy-тесты 991 (features/start/__tests__/rehearsal.test.tsx, start-screen.test.tsx) удалены вместе со скелетом — их семантика (Prüfung starten) заменена предметом 108; замороженные harness-пробы 995/999 и nav_999 shell_static (hex/тема start-screen.tsx) проходят на новой поставке без правок проб.
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0, исполнены quality/android-e2e, включая frozen-прогоны 995/999 и пробы 108 из H; Maestro-сценарий `cmp-mob-004-start.yaml` (написать → вернуться → продолжить Mission; mission_id и черновик сохранены) — NOT_RUN до C (отложенная приёмка); на C предъявляется фактический прогон flow, не только `gh pr checks`.
- Дано авторская пачка; `bash scripts/pre_critic.sh --repo <корень-worktree-h> contracts/108-cmp-mob-004-start.md` → rc0. Реальные rc предметных прогонов приложены в §Фактический замер.

## Пины и порядок поставки

После critic/freeze оркестратор разрешает `frozen/contracts/108/1^{commit}` в полный SHA H и append-only записывает его с B и ContextPack в issue #8 ДО раздачи implementer. mobile.yml получает те же H-checkout шаги по образцу 999/107: quality исполняет обе пробы 108 из H на disposable R (Python 3, без pip-зависимостей) до npm test/lint/typecheck/doctor; frozen-шаги 995/999 сохраняются дословно. Android-e2e и Maestro-гейты не ослабляются; новый Maestro-сценарий добавляется implementer'ом с локальным предполётом (Н-311), эмулятор — `sg kvm -c` (Н-318). Реализация не передаёт файлы модели в PR и не ветвится по test-env.

## Зоны и исполнители

ЗОНА architect: contracts/108-cmp-mob-004-start.md fixtures/workshop_project/start_108/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

fixtures/workshop_project/start_108/ — новый подкаталог существующей architect-зоны; коллизий с живыми заморозками нет, чужие файлы не меняются.

Пути implementer отсчитываются от Complior-mob:

ЗОНА implementer: mobile/src/features/start/ mobile/src/ui/agent-presence/ mobile/src/ui/conversation-composer/ mobile/src/mocks/ mobile/src/api/api-client.ts mobile/src/i18n/ui-copy.ts mobile/src/app/ mobile/src/bootstrap/http-runtime.ts mobile/src/bootstrap/tab-shell.tsx .github/workflows/mobile.yml mobile/.maestro/

Композиция (владелец — implementer): TabShell подключает StartScreen в секцию start (заголовок секции frame.F04.01.title сохранён — замороженный nav_999 SECTION_CONTENT_COPY продолжает проходить); `http-runtime.ts` расширяет объект ApiClient операцией listMissions (до CMP-BCK-008/009 — с явным именованным отказом, не тихой заглушкой-нуль), подача missions/avatarState в экран — через порты; legacy-тесты 991 в features/start/__tests__/ удаляются вместе со скелетом и заменяются пробой 108 + собственными тестами экрана. Красные пробы тестируют экран через порты напрямую; композиция наблюдается Maestro-сценарием на C.

`api/generated/` — read-only (типы объявляются в api-client.ts, не в generated); pilot-семейство 995 (features/auth, bootstrap/pilot-app.tsx, metro/jest config, bootstrap/__tests__) — read-only для этого PR (http-runtime.ts/tab-shell.tsx — исключения, см. выше); docs/, design/, api/ — read-only.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: пробы исполняют настоящий Jest/RNTL на disposable R и разбирают JSON-отчёт поимённо; пустой отчёт — именованный отказ/INFRASTRUCTURE, не зелёное;
- от подмены присутствия списком дел и KPI-дашбордом: произведение avatar × presence × motion на начальном рендере (К1) И на достигнутых INPUT/LISTENING (К1′) наблюдает присутствие/ровно один композер/≤1 карточку/отсутствие empty-groups и KPI в каждой клетке, до и после взаимодействия;
- от продолжения недоступного дела: доступность resume = присутствие в listMissions-items; отзыв ACL наблюдается переходом PRESENT→EMPTY из CALM (К2″′ ACL_REVOKED) И на достигнутом LISTENING (ACL_REVOKED_LISTENING), переходом PRESENT→null (MISSIONS_NULL_TRANSITION); остаточные приватные строки ловятся queryByText(mission_id);
- от запрещённых побочных эффектов: каждое действие × полный вектор эффектов (write/talk/resume/mic) × произведение состояний из CALM (К3) И из каждого ui_state × admission включая null (К3′ ACTION_FROM) И по всем mission_states × motion (RESUME_EFFECT); вектор проверен ПОСЛЕ каждого шага — порядок событий не маскирует эффект последнего действия;
- от запуска микрофона до W2: порт-наблюдатель onMicrophoneRequested не вызывается ни в одной клетке (включая write из LISTENING и talk из INPUT/null); аудио-импорты и wire-enum LISTENING ловятся статической семьёй;
- от ложного Listening: К4 наблюдает Listening как чистое UI-состояние (бриф и эффекты не меняются, выход к тексту возвращает кадр F04.02, полный вектор ПОСЛЕ выхода);
- от потери черновика: К5 переживает ВСЕ переходы avatarState (произведение from×to, включая unavailable) и admission-переходы (EMPTY/NULL), а не только idle→working;
- от декларативного mock: К6 исполняет НАСТОЯЩИЕ @/mocks/start-mock и @/mocks/runtime без mock-подмены методов; runtime.api.listMissions проверен по ВСЕМ сценариям presence × state (RUNTIME_SCENARIO), снимок равен ПОЛНОМУ объявленному типу MissionBrief и подаётся в экран;
- от подмены копии: точные ключи/тексты/review_status из оракула (13 ключей); кадры и бриф F04.06 наблюдаются ТЕКСТОМ каталога на поверхности, не только наличием ключа в ui-copy.ts;
- от второй грамматики: MissionState/MissionBrief/MissionPage определены в api-client.ts одноместно; STATIC_MISSION_STATE_ENUM — ТОЧНОЕ равенство множества (лишнее значение enum ловится, не только недостающее); варианты доступны только через source.json;
- от зависимого оракула: ожидания проб — литералы source.json в самом тесте, НЕ экспорты субъекта; ORACLE_MISSION_STATES сверяет перечень мока с оракулом; STATIC_ORACLE_LITERALS стережёт регресс «импорт констант из мока» (правило 8: истина проверяющего не берётся у проверяемого);
- от протухшего снимка экрана: SNAPSHOT_REFRESH ×100 — ПОЛНЫЙ квадрат упорядоченных пар состояний (включая from===to) при неизменной кардинальности, правило П до и после rerender; BRIEF_FIELDS ×8 — произведение значений полей {FIXED,ALT}³ (фиксированные строки и производные поля вместо чтения порта ловятся, включая смешанные комбинации);
- от мертвой матрицы: каждая проба исполняет все колонки на каждом мутанте (36 behavior + 5 static), depends измерены прогоном, unexpected_red — дефект.

НЕ ЗАЩИЩАЕТ:
- от реальной HTTP-выдачи миссий: mock SYNTHETIC, NOT_RUN→PASS только с evidence соответствующего SWITCH/бэкенда (вне контракта);
- от визуальной пропорции Presence 55–65% и типографики — cognitive-only (RNTL не меряет раскладку), ловец reviewer на C по дизайн-спецификации D2.2.5.1;
- от нативной гонки cold-start в Maestro — сценарий C с барьером по образцу 999 (assertVisible перед действием);
- от голосового runtime W2: вход в канал видим, но сам канал и capability-гейт — вне W0-среза;
- от злонамеренного кода с общим uid: независимые судьи, immutable H, CI evidence.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: потребляется действующая норма закрытия роли. Новая общая норма не вводится; локальная приёмка исполняется оркестратором/судьями и CI Complior-mob. Пробы 108 исполняются в CI Complior-mob из H-checkout; подключение — шаг quality в .github/workflows/mobile.yml (зона implementer) по образцу 999/107; в registry/ci-steps.tsv харнесса НЕ регистрируется (нет npm-ключа; python3 stdlib).

## Отложенная продуктовая приёмка

- Maestro Android (cmp-mob-004-start.yaml): написать → вернуться → продолжить Mission; mission_id и черновик сохранены — NOT_RUN до C; станционный предполёт Н-311/Н-318.
- Трассировка UX175-F04.A01/A02/A03 (intent, отсутствие commit на навигации, stale/revoked, replay) — на честном бэкенде после CMP-BCK-008/009; mock-прогоны маркируются SYNTHETIC.
- Copy signoff CMP-MOB-089 (включая формулировку состояния unavailable — сейчас структурный индикатор), device evidence CMP-MOB-090 — владелец.

## Вопросы владельцу

1. Кадры F04.04/F04.05 (рабочий canvas, структурированный результат — agent_stage 2): в этом срезе они не рендерятся спокойным Start (стадия активной беседы, канал F05). Подтвердить границу или потребовать кадры в 108.
2. Правило доступности resume «присутствует в listMissions.items» (ACL-фильтрация OpenAPI) не различает terminal-состояния (COMPLETED/CANCELLED): бриф показывает состояние, resume доступен. Подтвердить или дать терминальное правило отдельным предметом.
3. Индикатор состояния присутствия (idle/working/unavailable) — структурный ASCII до copy signoff CMP-MOB-089; немецкая формулировка недоступности в каталоге отсутствует.

## Фактический замер авторской пачки (круг 3, П1–П6 арбитража 108)

Снимок B=`76ac10fac668a1036371c4b392061ce9b3277ebc` (clean, `git rev-parse HEAD` сверен); disposable-дерево `/tmp/dev-harness-verify/Architect108r3/R` (node_modules от npm ci). Замер 2026-10-19, после арбитража 108 (`verdicts/arbitration/contracts-108-pravila-e-p-v1.md`, Решение 3, П1–П6); рабочее дерево `wip/108/architect` от родителя `74b589568fea85e925d5aea9cafd9e46a961ac96`.

- B без модели: `start_static_probe.py --repo R` → rc1 START_SEAM_ABSENT; `start_probe.py --repo R` → rc1 START_SEAM_ABSENT.
- B с эталонной моделью (`--model`): статическая rc0 (22/22), поведенческая rc0 (honest 324/324) — модель БЕЗ правок выполняет закрытый перечень (З-2 арбитра подтверждён).
- Матрицы: `start_probe.py --matrix` → rc0 (36 мутантов, defects 0, unexpected_red=none); `start_static_probe.py --matrix` → rc0 (5 мутантов, defects 0).
- depends всех 36 поведенческих мутантов измерены полным прогоном ДО записи в `MUTANTS` (red-наборы `drv.py` → redsets.json; компактные выражения сверены с замером программно, расхождений 0).
- Все 15 обходов круга 1 И 4 обхода круга 2 (оси 2а/2б/6 + совет о смешанных полях) воспроизведены методом критика (модель+мутация в R, ОБЫЧНЫЕ пробы без флагов): behavior-обходы → behavior rc1 с именованной RED-клеткой (static rc0 — UI-мутация в статике не наблюдаема, Н-39); `wire-enum-not-closed` → static rc1 STATIC_MISSION_STATE_ENUM (behavior rc0). Прогон: bypasses 19, failures 0.
- После прогонов `git status --short --untracked-files=all` в R — 0 строк (дерево восстановлено).
- Метагейт: `bash scripts/pre_critic.sh --repo <h> contracts/108-cmp-mob-004-start.md` → rc0 («дверь зелёная»).
