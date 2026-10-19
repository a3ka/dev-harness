# Контракт 107 — CMP-MOB-003: Erstinformation и доказательство выдачи актуальной версии

КЛАСС: КОДОВЫЙ. Авторский контракт CMP-MOB-003; предмет issue #7 сохранён. Android-приёмка (Maestro) следует после реализации C, не подменяется авторскими моделями.

КОНТЕКСТ: GitHub `a3ka/Complior-mob#7` — источник работ и приёмки; перед раздачей читать полное тело через `gh issue view 7 --repo a3ka/Complior-mob --json body --jq .body`.
КОНТЕКСТ: `contracts/999-cmp-mob-002-navigatsiya.md` — дисциплина H/B/C/T, disposable R, пробы с --matrix, пины H в mobile.yml; frozen-семейства проб 995/999 не переписываются.
КОНТЕКСТ: `fixtures/workshop_project/erstinfo_107/source.json` — оракул: копия каталога и грамматика erstinformation_route, снятые с дерева B ДО запуска субъекта; проб-тесты несут те же значения побайтово из этого файла.

## Нарезка предмета (frontier)

Три варианта рассматривались до первой редакции:

1. **Один контракт = весь предмет** (F02.03/F02.05/F02.08, шов ApiClient ×4 операции, mock-сценарии, копия каталога, maestro-сценарий; один PR) — **выбран**. Боль: P0 W0 срез F02 блокирует онбординг-цепочку; расщепление «экран/шов» порождает слой без обратной связи (норма вертикального слайса 050), а «ack отдельно от чтения» не наблюдаем без обеих сторон семантики (открытие ≠ подтверждение).
2. Два контракта (шов+mock / экраны) — отвергнут: экран без ack-семантики не проверяет главный риск предмета (ложное подтверждение), шов без экрана не имеет потребителя в строке приёмки.
3. Срез без ack (только чтение и статусы) — отвергнут: сужает предмет против issue (работа 6 и два критерия приёмки прямо требуют ack-семантики и W1a-gate).

Критерий выбора: вертикальный слайс 050 + граница «ОДИН PR» из issue (Kind: SLICE).

## Существующее

Сверено на read-only снимке Complior-mob `76ac10fa` (HEAD main после merge PR#111; `git rev-parse HEAD`). Полные HEAD, не имена веток.

- `mobile/src/api/api-client.ts` (sha256 в source.json): ТОЛЬКО getSession/getDisclosure; acknowledgeDisclosure и getDisclosureGate отсутствуют — предмет на B отсутствует. `api/generated/api-5_8.ts` — Disclosure {disclosure_ref, document_ref, digest, acknowledged, kind?, responsible_organisation_ref?, version?, delivery_proofs?}.
- `mobile/src/i18n/ui-copy.ts`: 10 ключей 002 (IA-вкладки, заголовки F04/F08/F19/F16, global.back); ключей disclosure.*/F02 нет. Каталог `docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json` несёт disclosure.checking/pending/failed/retry/updated (+missing/exit/not_applicable вне клеток), frame.F02.03/05/08.title/body, action.F02.A01/A02 — verbatim-источник; review_status у всех ключей сохранён (EDITORIAL_DRAFT/PRODUCT_COPY_REVIEW_REQUIRED).
- Грамматика `BrokerOS_Mobile_Design_Data.json#ux_refinements_v1_14/contracts/erstinformation_route`: delivery_values, screen_flow.F02.08.states = CHECKING/PENDING/CURRENT_CONFIRMED/FAILED/OUTDATED, branches, evidence_rule («view/checkbox/download click is not delivery proof»), legacy_data_rule (delivered — display-only). Screen Matrix F02.03/F02.05/F02.08: read-операции getDisclosureGate/getAuthorizedDocumentVersion/getDisclosureDelivery — TARGET_SPEC_ONLY; runtime показ unknown/unavailable.
- `mobile/src/features/onboarding/`: только welcome-screen.tsx (пилот 995). Таб-shell 002 (`bootstrap/tab-shell.tsx`), ui-примитивы Button/Notice/TextField, theme — прецедент композиции с портами.
- `mobile/src/mocks/runtime.ts`: mock ApiClient с getSession/getDisclosure из pilot-responses.json; SYNTHETIC-маркер evidence — прецедент. `api/frontend-consumer-bindings.json#actions/F02.A02`: PUBLIC_OPERATION, remote_operation_id getDisclosure, волна W0, authoritative_effect NONE_READ_ONLY; route_contract_ref → erstinformation_route.
- `.maestro/` (после 002): сценарии cmp-mob-002-*; паттерн имён по STRUCTURE §7. `mobile.yml`: quality + android-e2e с H-checkout (995/999) — паттерн пинов 107 повторяет.
- Заявленная оговорка issue: mock не доказывает реальную доставку; NOT_RUN→PASS только с HTTP_REQUEST_RESPONSE/SQL_BEFORE_AFTER/PROVIDER_CALL_COUNT соответствующего SWITCH/бэкенда (бэкенд CMP-BCK-008/024 — вне этого контракта).

## Предмет и граница

Один результат: экраны Erstinformation по грамматике erstinformation_route — F02.03 (ответственный маклер: responsible_entity, документ/версия, разрешённый источник), F02.05 (чтение точной версии с возвратом), F02.08 (разнесение CHECKING/PENDING/FAILED/OUTDATED/CURRENT_CONFIRMED с точной копией disclosure.* и evidence-картой); шов ApiClient расширяется операциями acknowledgeDisclosure/getDisclosureGate; mock несёт сценарии состояний × версий; явное подтверждение вызывает acknowledgeDisclosure, открытие PDF — нет; ack версии N при требуемой N+1 не продолжает бизнес-шаг и перечитывает evidence; getDisclosureGate потребляется только при W1a admission. ОДИН PR в a3ka/Complior-mob, без Merge. Implementer — согласованная модель MiniMax; после реализации — Maestro Android и независимые adversary/reviewer на одном C.

Вне предмета: реальная HTTP-доставка (CMP-BCK-008/024), F02.A01/A03 прочие действия, Betreuungsumfang (F02.06), завершение onboarding, ServiceMandate как сущность, биометрия. Pilot-семейство 995 (features/auth, bootstrap/pilot-app.tsx) не рестайлится; frozen-пробы 995/999 не переписываются. Copy signoff CMP-MOB-089 и device evidence CMP-MOB-090 этим PR не объявляются завершёнными.

## Инварианты

1. `mobile/src/api/api-client.ts` несёт четыре операции (getSession, getDisclosure, acknowledgeDisclosure, getDisclosureGate); грамматика DeliveryState/Applicability/Admission и типы DisclosureGateSnapshot/AcknowledgeDisclosureResult определены в ЭТОМ модуле в одном месте — потребители (экран, mock, пробы) не переизобретают констант.
2. `mobile/src/features/onboarding/erstinformation.tsx` — порты-инъекция по прецеденту tab-shell: gate-снимок и disclosure-payload подаются снаружи; экран не знает транспорта и не ветвится по test-env.
3. F02.08 разносит состояния: CHECKING→disclosure.checking, PENDING→disclosure.pending (ожидание, не успех), FAILED→disclosure.failed + повтор проверки (disclosure.retry), OUTDATED→disclosure.updated; CURRENT_CONFIRMED показывается ТОЛЬКО при совпадении версии disclosure с требуемой И наличии evidence (delivery_evidence_ref, checked_at); старая версия при подтверждённом сервере → disclosure.updated, не подтверждение.
4. Открытие документа (action.F02.A02, frame.F02.05.title) показывает точную версию payload (не требуемую) и возвращает к F02.03 с сохранением responsible_entity/документа; открытие не вызывает acknowledgeDisclosure и не создаёт mandate.
5. Явное подтверждение (только при CURRENT_CONFIRMED) вызывает acknowledgeDisclosure(disclosure_ref, version); ack устаревшей версии не продолжает бизнес-шаг и перечитывает evidence; delivered без подтверждения сервером не обозначается подписью/подтверждением.
6. Continue-действие (action.F02.A01) доступно только при admission=W1A и подтверждённой текущей версии; W0 не показывает continue (W0 чтение/ack не снимает более поздний gate); никакой автопереход не совершается без нажатия.
7. `mobile/src/i18n/ui-copy.ts` — verbatim-подмножество каталога: точные ключи, тексты, review_status; новых немецких формулировок не вводится (исключение — плейсхолдер confirm-кнопки вне каталога, см. Вопросы владельцу).

## Проверяемый шов

`mobile/src/features/onboarding/erstinformation.tsx` экспортирует `Erstinformation` с портами `gate`, `disclosure`, `admission`, `onAcknowledge`, `onRecheck`, `onOpenDocument`, `onContinue`. `mocks/disclosure-mock.ts` — сценарии состояний × версий для расширенного mock ApiClient (`mocks/runtime.ts`). Ожидания проб снимаются в память (source.json, байты теста) до запуска субъекта; привязка мутант↔ветвь живёт только в коде проб (`MUTANTS`), не в прозе контракта (Н-39). Модель architect в `fixtures/workshop_project/erstinfo_107/model/` — честный эталон; в PR не копируется.

ЗАКРЫТЫЕ ПЕРЕЧНИ. Единственный источник грамматики — source.json: `delivery_states` (5 состояний F02.08 screen_flow), `versions` (EQ: 2/2, STALE: 2/3), `admissions` (W0/W1A); расширение перечня = расширение source.json. Клетки порождаются циклами по этим перечням (тест erstinfo.test.tsx, `for (const state of STATES) for (const axis of AXES)`), не ручным списком.

- К1 flow (инварианты 3, 5): `FLOW_<DS>_VM_<EQ|STALE>` — 10 клеток по произведению состояний × версионной оси: notice-ключ структурно (testID) и текстом из каталога; CURRENT_CONFIRMED_EQ — evidence-карта (evidence_ref, checked_at), notice отсутствует; CURRENT_CONFIRMED_STALE — disclosure.updated, evidence отсутствует.
- К2 ack (инварианты 4, 5): `ACK_EXPLICIT_CURRENT` (confirm → onAcknowledge(ref, 2) ровно один), `ACK_PDF_OPEN_NOT_ACK` (открытие → onOpenDocument(doc, 2), onAcknowledge НЕ вызван, F02.05 виден), `ACK_ABSENT_<DS>` для четырёх не-confirmed состояний (confirm не предлагается), `ACK_STALE_NO_CONTINUE` (ack N при N+1: cont=0, recheck=1), `FAILED_RETRY_ACTION` (retry → recheck=1, ack пуст).
- К3 документ (инвариант 4): `DOC_OPEN_EXACT_VERSION` (F02.05 показывает Version 2 при требуемой 3), `DOC_RETURN_PRESERVES` (back → F02.03, responsible_entity и документ сохранены), `BROKER_CARD_FIELDS` (entity, entity_id, source_ref, checked_at).
- К4 gate/автопереход (инвариант 6): `NO_AUTO_CONTINUE_ON_VIEW` (рендер W1A не вызывает cont/ack), `W1A_CONTINUE_EXPLICIT` (нажатие continue → cont=1), `NO_GATE_IN_W0` (W0: continue отсутствует), `COPY_TITLES_FROM_CATALOG` (заголовки F02.03/F02.08/A02 текстами каталога).
- Статическая семья: `COPY_KEY_<key>` для каждого ключа оракула (14), `STATIC_API_SEAM_<OP>` для четырёх операций шва, `STATIC_MOCK_SCENARIOS`, `STATIC_MOCK_RUNTIME_WIRED`.
- Матрицы обеих проб исполняют ВСЕ колонки на каждом мутанте; побочная краснота допустна только в явно объявленном depends, red-набор каждого мутанта измеряется полным прогоном.

## Приёмочный критерий

R — disposable копия Complior-mob (B или C) под /tmp/dev-harness-verify с `npm ci` в `mobile/`; пробы — Python 3 stdlib. Нет Jest/артефактов отчёта → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B без реализации; `python3 fixtures/workshop_project/erstinfo_107/erstinfo_static_probe.py --repo R` → rc1 ERSTINFO_MODULE_ABSENT; `erstinfo_probe.py --repo R` → rc1 ERSTINFO_COMPONENT_ABSENT. Два именованных отказа — краснота предмета на до-предметном дереве.
- Дано B с эталонной моделью (`--model`); либо дано честное C — обе пробы → rc0 с построчным перечнем case: статическая 20/20, поведенческая 25/25 (перечни К1–К4 + статическая семья выше).
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный; каждый мутант даёт отказ на своей именованной ветви; побочная краснота только в объявленном depends; мутантов 13 (поведенческая семья) + 4 (статическая семья); якорь мутанта неуникален → rc2.
- Дано C; `git status --short --untracked-files=all` в R после проб не содержит следов workspace/мутаций (пробы восстанавливают дерево).
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0, исполнены quality/android-e2e, включая frozen-прогоны 995/999 и пробы 107 из H; Maestro-сценарий `cmp-mob-003-erstinformation.yaml` (открыть документ, увеличить текст, вернуться — версия и responsible_entity сохранены) — NOT_RUN до C (отложенная приёмка).
- Дано авторская пачка; `bash scripts/pre_critic.sh --repo <корень-worktree-h> contracts/107-cmp-mob-003-erstinformation.md` → rc0. Реальные rc предметных прогонов приложены в §Фактический замер.

## Пины и порядок поставки

После critic/freeze оркестратор разрешает `frozen/contracts/107/1^{commit}` в полный SHA H и append-only записывает его с B и ContextPack в issue #7 ДО раздачи implementer. mobile.yml получает те же H-checkout шаги по образцу 999: quality исполняет обе пробы 107 из H на disposable R (Python 3, без pip-зависимостей) до npm test/lint/typecheck/doctor; frozen-шаги 995/999 сохраняются дословно. Android-e2e и Maestro-гейты не ослабляются; новый Maestro-сценарий добавляется implementer'ом с локальным предполётом (Н-311), эмулятор — `sg kvm -c` (Н-318). Реализация не передаёт файлы модели в PR и не ветвится по test-env.

## Зоны и исполнители

ЗОНА architect: contracts/107-cmp-mob-003-erstinformation.md fixtures/workshop_project/erstinfo_107/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

fixtures/workshop_project/erstinfo_107/ — новый подкаталог существующей architect-зоны; коллизий с живыми заморозками нет, чужие файлы не меняются.

Пути implementer отсчитываются от Complior-mob:

ЗОНА implementer: mobile/src/features/onboarding/ mobile/src/mocks/ mobile/src/api/api-client.ts mobile/src/i18n/ui-copy.ts .github/workflows/mobile.yml mobile/.maestro/

`api/generated/` — read-only (типы при необходимости объявляются в api-client.ts, не в generated); pilot-семейство 995 (features/auth, bootstrap/pilot-app.tsx, metro/jest config, bootstrap/__tests__) — read-only для этого PR; docs/, design/, api/ — read-only.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: пробы исполняют настоящий Jest/RNTL на disposable R и разбирают JSON-отчёт поимённо; пустой отчёт — именованный отказ/INFRASTRUCTURE, не зелёное;
- от ложного подтверждения: открытие PDF и рендер подтверждённого состояния наблюдаются раздельно от onAcknowledge; ack без нажатия ловится клетками NO_AUTO/ACK_PDF;
- от подтверждения устаревшей версии: версионная ось EQ/STALE замкнута в грамматике, CURRENT_CONFIRMED при несовпадении — красная клетка;
- от подмены копии: точные ключи/тексты/review_status из оракула; notice наблюдается структурно (testID) и текстом;
- от тихого gate в W0: admission-ось замкнута, continue в W0 отсутствует структурно;
- от второй грамматики: DeliveryState/Applicability/Admission определены в api-client.ts одноместно, пробы сверяют байты;
- от мертвой матрицы: каждая проба исполняет все колонки на каждом мутанте, depends измерены прогоном, unexpected_red — дефект rc2.

НЕ ЗАЩИЩАЕТ:
- от реальной HTTP-доставки Erstinformation: mock SYNTHETIC, NOT_RUN→PASS только с evidence соответствующего SWITCH/бэкенда (вне контракта);
- от визуального качества (типографика PDF-viewer, контраст) — cognitive-only, ловец reviewer на C;
- от нативной гонки cold-start в Maestro — сценарий C с барьером по образцу 999 (assertVisible перед действием);
- от злонамеренного кода с общим uid: независимые судьи, immutable H, CI evidence.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: потребляется действующая норма закрытия роли. Новая общая норма не вводится; локальная приёмка исполняется оркестратором/судьями и CI Complior-mob. Пробы 107 исполняются в CI Complior-mob из H-checkout; подключение — шаг quality в .github/workflows/mobile.yml (зона implementer) по образцу 999; в registry/ci-steps.tsv харнесса НЕ регистрируется (нет npm-ключа; python3 stdlib).

## Отложенная продуктовая приёмка

- Maestro Android (cmp-mob-003-erstinformation.yaml): открыть документ, увеличить текст, вернуться — версия и responsible_entity сохранены — NOT_RUN до C; станционный предполёт Н-311/Н-318.
- Трассировка UX175-F02.A02 (intent, stale/revoked, replay) — на честном бэкенде после CMP-BCK-008/024; mock-прогоны маркируются SYNTHETIC.
- Copy signoff CMP-MOB-089, device evidence CMP-MOB-090 — владелец.

## Вопросы владельцу/консультанту

1. **Копи-разрыв confirm-кнопки.** В каталоге BrokerOS_UI_Copy_DE.json НЕТ ключа для явного подтверждения выдачи (есть disclosure.checking/pending/failed/retry/updated/missing/exit/not_applicable; withdrawal.confirm — чужой домен). Модель несёт ASCII-плейсхолдер `acknowledge`; нужен ключ каталога от copy signoff CMP-MOB-089 либо слово владельца о допустимом ключе. До решения клетка ACK_* проверяет семантику, не текст кнопки.
2. **F02.V02/F02.V04.** Issue ссылается на правила вида (сброс принятия обновлённой версии; delivered без accepted_at не подпись) без пути источника; модель закрывает их инвариантом 3/5 (версионная ось + отсутствие подписи вне CURRENT_CONFIRMED+evidence). Если V-правила живут в отдельном документе UX — указать путь для сверки.
3. **Routes.** STRUCTURE допускает `(entry)/` route wrappers для onboarding; модель держит экран компонентом с портами (прецедент 999), route-обёртки — решение implementer в зоне `mobile/src/features/onboarding/` + существующих app-маршрутов; новые route-файлы вне зоны — отдельное слово.

## Фактический замер авторской пачки

Снимок B=`76ac10fa`; disposable-дерево `/tmp/dev-harness-verify/Architect107/R` (npm ci в mobile/). Замер 2026-10-19.

- B без модели: `erstinfo_static_probe.py --repo R` → rc1 ERSTINFO_MODULE_ABSENT; `erstinfo_probe.py --repo R` → rc1 ERSTINFO_COMPONENT_ABSENT.
- B с эталонной моделью (`--model`): статическая rc0 (20/20), поведенческая rc0 (25/25).
- Матрицы: `erstinfo_probe.py --matrix` → rc0 (13 мутантов, defects 0; depends_red у шести мутантов, unexpected_red=none); `erstinfo_static_probe.py --matrix` → rc0 (4 мутанта, defects 0).
- После прогонов `git status --short --untracked-files=all` в R — 0 строк (дерево восстановлено).
- Метагейт: `bash scripts/pre_critic.sh --repo <h> contracts/107-cmp-mob-003-erstinformation.md` → rc0 (см. доклад).
