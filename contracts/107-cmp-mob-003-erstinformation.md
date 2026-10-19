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
- `mobile/src/i18n/ui-copy.ts`: 10 ключей 002 (IA-вкладки, заголовки F04/F08/F19/F16, global.back); ключей disclosure.*/F02 нет. Каталог `docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json` несёт disclosure.checking/pending/failed/retry/updated/missing/not_applicable (+exit вне клеток), frame.F02.03/05/08.title/body, action.F02.A01/A02 — verbatim-источник круга 2 (missing/not_applicable введены в клетки С3); review_status у всех ключей сохранён (EDITORIAL_DRAFT/PRODUCT_COPY_REVIEW_REQUIRED).
- Грамматика `BrokerOS_Mobile_Design_Data.json#ux_refinements_v1_14/contracts/erstinformation_route`: delivery_values, screen_flow.F02.08.states = CHECKING/PENDING/CURRENT_CONFIRMED/FAILED/OUTDATED, branches, evidence_rule («view/checkbox/download click is not delivery proof»), legacy_data_rule (delivered — display-only). Screen Matrix F02.03/F02.05/F02.08: read-операции getDisclosureGate/getAuthorizedDocumentVersion/getDisclosureDelivery — TARGET_SPEC_ONLY; runtime показ unknown/unavailable.
- `mobile/src/features/onboarding/`: только welcome-screen.tsx (пилот 995). Таб-shell 002 (`bootstrap/tab-shell.tsx`), ui-примитивы Button/Notice/TextField, theme — прецедент композиции с портами.
- `mobile/src/mocks/runtime.ts`: mock ApiClient с getSession/getDisclosure из pilot-responses.json; SYNTHETIC-маркер evidence — прецедент. `api/frontend-consumer-bindings.json#actions/F02.A02`: PUBLIC_OPERATION, remote_operation_id getDisclosure, волна W0, authoritative_effect NONE_READ_ONLY; route_contract_ref → erstinformation_route.
- `.maestro/` (после 002): сценарии cmp-mob-002-*; паттерн имён по STRUCTURE §7. `mobile.yml`: quality + android-e2e с H-checkout (995/999) — паттерн пинов 107 повторяет.
- Заявленная оговорка issue: mock не доказывает реальную доставку; NOT_RUN→PASS только с HTTP_REQUEST_RESPONSE/SQL_BEFORE_AFTER/PROVIDER_CALL_COUNT соответствующего SWITCH/бэкенда (бэкенд CMP-BCK-008/024 — вне этого контракта).

## Предмет и граница

Один результат: экраны Erstinformation по грамматике erstinformation_route — F02.03 (ответственный маклер: responsible_entity, документ/версия, разрешённый источник), F02.05 (чтение точной версии с возвратом), F02.08 (разнесение CHECKING/PENDING/FAILED/OUTDATED/CURRENT_CONFIRMED с точной копией disclosure.* и evidence-картой); шов ApiClient расширяется операциями acknowledgeDisclosure/getDisclosureGate; mock несёт сценарии состояний × версий; явное подтверждение вызывает acknowledgeDisclosure, открытие PDF — нет; ack версии N при требуемой N+1 не продолжает бизнес-шаг и перечитывает evidence; getDisclosureGate потребляется только при W1a admission. ОДИН PR в a3ka/Complior-mob, без Merge. Implementer — согласованная модель MiniMax; после реализации — Maestro Android и независимые adversary/reviewer на одном C.

Вне предмета: реальная HTTP-доставка (CMP-BCK-008/024), F02.A01/A03 прочие действия, Betreuungsumfang (F02.06), завершение onboarding, ServiceMandate как сущность, биометрия. Pilot-семейство 995 (features/auth, bootstrap/pilot-app.tsx) не рестайлится; frozen-пробы 995/999 не переписываются. Copy signoff CMP-MOB-089 и device evidence CMP-MOB-090 этим PR не объявляются завершёнными.

## Инварианты

1. `mobile/src/api/api-client.ts` несёт четыре операции (getSession, getDisclosure, acknowledgeDisclosure, getDisclosureGate); грамматика DeliveryState (пять экранных состояний F02.08 + серверные MISSING/UNKNOWN из erstinformation_route.delivery_values), Applicability (REQUIRED/NOT_REQUIRED/UNKNOWN) и Admission, типы DisclosureGateSnapshot/AcknowledgeDisclosureResult определены в ЭТОМ модуле в одном месте — потребители (экран, mock, пробы) не переизобретают констант.
2. `mobile/src/features/onboarding/erstinformation.tsx` — порты-инъекция по прецеденту tab-shell: gate-снимок (тип допускает null — snapshot может отсутствовать) и disclosure-payload подаются снаружи; экран не знает транспорта и не ветвится по test-env.
3. F02.08 разносит состояния: CHECKING→disclosure.checking, PENDING→disclosure.pending, FAILED→disclosure.failed + retry, OUTDATED→disclosure.updated. CURRENT_CONFIRMED доказывается ПОЛНОСТЬЮ: серверное состояние CURRENT_CONFIRMED ∧ applicability REQUIRED ∧ required_document_id == disclosure.document_ref ∧ пригодное evidence (delivery_evidence_ref — непустая строка, checked_at непуст) ∧ ТОЧНОЕ равенство disclosure.version === required_document_version (не «payload < required»: payload новее требуемого — тоже не доказательство). Любое нарушение → disclosure.updated (OUTDATED), без evidence-карты и без continue.
4. Открытие документа (action.F02.A02) показывает точную версию payload и ДЕРЖИТ её при смене payload/gate во время чтения (pin версии открытия); возврат к F02.03 сохраняет responsible_entity/документ; открытие не вызывает acknowledgeDisclosure и не создаёт mandate.
5. Явное подтверждение (предлагается только при серверном CURRENT_CONFIRMED ∧ applicability REQUIRED) вызывает acknowledgeDisclosure(disclosure_ref, version); порт `onAcknowledge` возвращает `void | Promise<AcknowledgeDisclosureResult | void>`; экран наблюдает ЗАВЕРШЕНИЕ Promise операции и ПОСЛЕ него перечитывает gate (onRecheck) — и при успешном current-ack, и при версии, ушедшей во время незавершённого ack, и при ОТКАЗЕ операции (http-runtime до CMP-BCK-008/024 отвечает именованным отказом — rejected Promise; перечень исходов конечен: {accepted:true, accepted:false, reject}; эталон гасит rejection терминальным `.catch` ПОСЛЕ recheck — unhandled rejection не остаётся); смена версии во время ack не продолжает бизнес-шаг; delivered без подтверждения сервером не обозначается подписью.
6. Continue (action.F02.A01) доступен только при admission=W1A ∧ полном доказательстве инварианта 3; W0 не показывает continue (W0 чтение/ack не снимает более поздний gate); никакой автопереход не совершается без нажатия; побочные эффекты действий разделены: open → только onOpenDocument; confirm → только onAcknowledge с последующим recheck; continue → только onContinue.
7. `mobile/src/i18n/ui-copy.ts` — verbatim-подмножество каталога (16 ключей 107: disclosure.checking/pending/failed/retry/updated/missing/not_applicable, frame.F02.03/05/08, action.F02.A01/A02, global.back); новых немецких формулировок не вводится. Надпись confirm-кнопки `acknowledge` — ASCII-плейсхолдер со статусом PRODUCT_COPY_REVIEW_REQUIRED (copy signoff CMP-MOB-089), не production-copy.
8. Серверная грамматика за пределами пяти экранных состояний отображается безопасным fallback без доказательства: delivery MISSING → disclosure.missing; delivery UNKNOWN → disclosure.checking; applicability NOT_REQUIRED → disclosure.not_applicable без gate-действий; отсутствующий snapshot (gate=null) → fallback без краха, без evidence/confirm/continue.
9. Источник V-правил F02.V02/F04 (сброс принятия обновлённой версии; delivered без accepted_at не подпись) — `docs/ux/01_UX_Source_of_Truth/BrokerOS_Mobile_Design_Data.json:860–880` (variants с document_version/accepted_at и delivered/accepted_at; развёрнутые datasets :1037, :1097); правила закрыты инвариантами 3 и 5.

## Проверяемый шов

`mobile/src/features/onboarding/erstinformation.tsx` экспортирует `Erstinformation` с портами `gate` (допускает null), `disclosure`, `admission`, `onAcknowledge` (`void | Promise<AcknowledgeDisclosureResult | void>`), `onRecheck`, `onOpenDocument`, `onContinue`. `mocks/disclosure-mock.ts` — сценарии состояний × версий для расширенного mock ApiClient (`mocks/runtime.ts`). Ожидания проб снимаются в память (source.json, байты теста) до запуска субъекта; привязка мутант↔ветвь живёт только в коде проб (`MUTANTS`), не в прозе контракта (Н-39). Модель architect в `fixtures/workshop_project/erstinfo_107/model/` — честный эталон; в PR не копируется.

ЗАКРЫТЫЕ ПЕРЕЧНИ (круг 3, арбитраж `verdicts/arbitration/contracts-107-perechen-v1.md`): критерий — ЗАКРЫТОЕ произведение осей, записанных в этом контракте, а не поштучные мутанты. Единственный источник грамматики — source.json: `delivery_states` (5 состояний F02.08 screen_flow), `versions` (EQ: 2/2, STALE: 2/3), `admissions` (W0/W1A), `evidence_fields` (К5′: ref {valid,null,empty} × checked_at {valid,empty} × document {same,other} × applicability {REQUIRED,UNKNOWN} × version {EQ,NOT_EQUAL}; singleton-патчи — в `evidence_fields.invalid_single_patches`), `server_grammar` (delivery_values сервера 6 значений, applicability_values 3, отображение MISSING/UNKNOWN/NOT_REQUIRED/snapshot_absent); расширение перечня = расширение source.json. Клетки порождаются циклами по этим перечням (erstinfo.test.tsx: `for admission × combo of evidence_fields`, `for admission × state × axis × action`, `for admission × moved × outcome`, `for admission × state × axis`), не ручным списком. Итого поведенческая семья 265 клеток, статическая 22; арбитражное ядро К5′+К6′+К7′+К9′ = 229 (К5′ 96 + К6′ 100 + К7′ 12 + К9′ 21). НЕ входит в перечень (обход не роняет круг): двойной/конкурентный ack; реальная HTTP-доставка (CMP-BCK-008/024); app-маршруты и http-runtime (Maestro на C); поля snapshot_required сверх клиентского типа; resume/reconcile/replay/outage; copy signoff; состав декоев сверх П5 арбитража; гранулярность it при сохранённой грамматике; значения полей за пределами объявленных (undefined, не-строки — TypeScript).

- К1 flow (инвариант 3; 10): `FLOW_<DS>_VM_<EQ|STALE>` — произведение состояний × версионной оси: notice структурно (testID) и текстом каталога; CURRENT_CONFIRMED_EQ — evidence-карта, notice отсутствует; CURRENT_CONFIRMED_STALE — disclosure.updated, evidence отсутствует.
- К2 ack (инварианты 4–5; 8): `ACK_EXPLICIT_CURRENT`, `ACK_PDF_OPEN_NOT_ACK`, `ACK_ABSENT_<DS>` ×4, `ACK_STALE_NO_CONTINUE` (cont=0, recheck=1), `FAILED_RETRY_ACTION`.
- К3 документ (инвариант 4; 5): `DOC_OPEN_EXACT_VERSION`, `DOC_RETURN_PRESERVES`, `BROKER_CARD_FIELDS`, `DOC_PINS_VERSION_<W0|W1A>` — смена payload/gate версии 3 во время чтения не подменяет надпись Version 2 (С4).
- К4 gate/автопереход (инвариант 6; 4): `NO_AUTO_CONTINUE_ON_VIEW`, `W1A_CONTINUE_EXPLICIT`, `NO_GATE_IN_W0`, `COPY_TITLES_FROM_CATALOG`.
- К5′ доказательство (Б1→арбитраж, инвариант 3; 96): `EVIDENCE_PROD_<adm>_REF<r>CHK<c>DOC<d>APPL<a>VER<v>` — ПРОИЗВЕДЕНИЕ ЗНАЧЕНИЙ полей evidence (не одиночные patch'и): 48 комбинаций × 2 admission; ровно одна валидна — evidence-карта и continue ⇔ W1A; остальные 47 → disclosure.updated без evidence-карты и без continue. «Любое нарушение» инварианта 3 доказано произведением: мутант, различающий подмножества полей, различим своей клеткой.
- К6′ действия (Б2→арбитраж, инварианты 4–6, issue #7 работа 5; 100): `ACTION_VECTOR_<adm>_<state>_<axis>_<action>` для action ∈ {OPEN,RETRY,CONFIRM,CONTINUE,BACK} × 5 состояний × 2 осей × 2 admission. (а) доступность ровно по правилу: retry ⇔ FAILED; confirm ⇔ CURRENT_CONFIRMED; continue ⇔ W1A ∧ CURRENT_CONFIRMED ∧ EQ; open/back всегда (back — в F02.05 после открытия); (б) после нажатия полный вектор эффектов (open, ack, recheck, cont) равен ожидаемому: open→(1,0,0,0), retry→(0,0,1,0), confirm→(0,1,1,0) после settlement, continue→(0,0,0,1), back→(0,0,0,0). `ACTION_*` и `FAILED_RETRY_ACTION` круга 2 растворены в этих клетках.
- К7′ время и исход ack (Б3→арбитраж, инвариант 5; 12): `ACK_OUTCOME_<adm>_MOVED<0|1>_<ACCEPTED|NOT_ACCEPTED|REJECT>` — исход × версия ушла (gate → STALE до settlement) × admission. В каждой: события `ack-start → settled → recheck` (до settlement recheck = 0, после — ровно 1), `cont = 0`, continue виден ⇔ W1A ∧ ¬moved (после reject дальнейшее решает перечитанный gate, не исход ack). Исход reject обязателен (контракт :96 — http-runtime именованный отказ); эталон гасит rejection терминальным `.catch` после finally. `ACK_VERSION_CHANGES`/`ACK_RECHECKS` круга 2 растворены.
- К8′ серверная грамматика (С3, инвариант 8; как на OBJECT круга 2; 8): `DELIVERY_MISSING/DELIVERY_UNKNOWN/APPLICABILITY_NOT_REQUIRED` × обе admission — безопасный notice, без evidence/confirm/continue; `SNAPSHOT_ABSENT_<adm>` ×2 — gate=null без краха, без evidence/continue. Не оспорено, не меняется.
- К9′ mock/runtime → экран (Б4→арбитраж; 21): (а) `MOCK_SCREEN_<adm>_<state>_<axis>` ×20 — настоящий `@/mocks/disclosure-mock`.gateFor ПОДАЁТСЯ В ЭКРАН, наблюдается заявленное состояние (notice/evidence) и continue ⇔ W1A ∧ CURRENT_CONFIRMED ∧ EQ; (б) `RUNTIME_GATE_SNAPSHOT` — настоящий `@/mocks/runtime`.api.getDisclosureGate сверяется `toEqual` ПОЛНОМУ объявленному снимку (все поля DisclosureGateSnapshot из api-client.ts, не 5 из 7) и подаётся в экран: evidence-карта с checked_at, continue при W1A; `MOCK_ACK_RECORDS`, `RUNTIME_ACK_EXECUTES` — как в круге 2 (вне 229). Граница К9′: mocks/runtime.ts / mocks/disclosure-mock.ts через порты (зона проб), НЕ app/-маршруты и НЕ http-runtime (композиция C — Maestro).
- Статическая семья (22): `COPY_KEY_<key>` для каждого ключа оракула (16), `STATIC_API_SEAM_<OP>` ×4, `STATIC_MOCK_SCENARIOS`, `STATIC_MOCK_RUNTIME_WIRED`.
- Матрицы обеих проб исполняют ВСЕ колонки на каждом мутанте; побочная краснота допустима только в явно объявленном depends, red-набор каждого мутанта измеряется полным прогоном. Круг 3 добавляет пять декоев арбитража П5 (`evidence-coabsent-fallback`, `retry-business-transition`, `recheck-before-settlement`, `recheck-success-only`, `runtime-incomplete-gate`) — патчи байт-в-байт из вердикта арбитра (мера арбитра :39–47), ack-патчи адаптированы к эталону с терминальным `.catch`, смысл байт-в-байт; depends порождаются генераторами по грамматике клеток.

## Приёмочный критерий

R — disposable копия Complior-mob (B или C) под /tmp/dev-harness-verify с `npm ci` в `mobile/`; пробы — Python 3 stdlib. Нет Jest/артефактов отчёта → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B без реализации; `python3 fixtures/workshop_project/erstinfo_107/erstinfo_static_probe.py --repo R` → rc1 ERSTINFO_MODULE_ABSENT; `erstinfo_probe.py --repo R` → rc1 ERSTINFO_COMPONENT_ABSENT. Два именованных отказа — краснота предмета на до-предметном дереве.
- Дано B с эталонной моделью (`--model`); либо дано честное C — обе пробы → rc0 с построчным перечнем case: статическая 22/22, поведенческая 265/265 (семьи К1–К4, К5′–К9′, MOCK_ACK_RECORDS/RUNTIME_ACK_EXECUTES + статическая выше; арбитражное ядро К5′+К6′+К7′+К9′ = 229).
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный; каждый мутант даёт отказ на своей именованной ветви; побочная краснота только в объявленном depends; мутантов 23 (поведенческая семья: 18 круга 2, включая admission-all-states, navigation-side-effects, false-evidence, ack-recheck-lost, mock-constant-no-ack, runtime-unimplemented + 5 декоев арбитража П5) + 4 (статическая семья); якорь мутанта неуникален → отказ. СМЫСЛ `--matrix` — самопроверка набора проб и эталона на мутантах (матрица временно замещает файлы продукта моделью), НЕ свидетельство честности C; честность C — обычные пробы без `--model` на дереве PR.
- Дано честная модель/С; свидетели круга 1 (`verdicts/critic/contracts-107-krug1-fail.md`: witness.test.tsx 61 клетка, api-witness.test.tsx 2 клетки) — rc0, красных нет; свидетели круга 2 (`witness.test.tsx` 17 клеток, `runtime-witness.test.tsx`): на полной модели 16/17 + 1/1 rc0 — клетка `runtime-composed-current-evidence` самого witness.test.tsx красна дефектом matcher'а свидетеля (`toHaveTextContent` на View; арбитраж З-1: «ошибка matcher'а критика, им же отозвана»; чистое различение этой клетки — runtime-witness.test.tsx критика: модель rc0, мутант runtime-incomplete-gate rc1); на каждом из пяти декоев П5 — rc1 краснотой именованных клеток перечня (evidence-combination ×4; retry-is-read-only ×2; ack-settlement-order ×2; rejected-ack ×2; runtime-composed ×1), combined-проба критика (4 мутанта вместе) — rc1. Их клетки вошли в семьи К5′–К9′.
- Дано C; `git status --short --untracked-files=all` в R после проб не содержит следов workspace/мутаций (пробы восстанавливают дерево).
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0, исполнены quality/android-e2e, включая frozen-прогоны 995/999 и пробы 107 из H; Maestro-сценарий `cmp-mob-003-erstinformation.yaml` (открыть документ, увеличить текст, вернуться — версия и responsible_entity сохранены) — NOT_RUN до C (отложенная приёмка); на C предъявляется фактический прогон flow, не только `gh pr checks`.
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

ЗОНА implementer: mobile/src/features/onboarding/ mobile/src/mocks/ mobile/src/api/api-client.ts mobile/src/i18n/ui-copy.ts mobile/src/app/ mobile/src/bootstrap/http-runtime.ts .github/workflows/mobile.yml mobile/.maestro/

Композиция (владелец — implementer): в `mobile/src/app/` существующие route-файлы меняются только для подключения входа Erstinformation onboarding-цепочки, новые route-файлы Erstinformation добавляются по STRUCTURE §7 (допустимы `(entry)/` wrappers); `mobile/src/bootstrap/http-runtime.ts` расширяет объект ApiClient операциями acknowledgeDisclosure/getDisclosureGate (до CMP-BCK-008/024 — с явным именованным отказом, не тихим заглушка-нуль), подача gate/disclosure в экран — через порты. Красные пробы тестируют экран через порты напрямую; композиция наблюдается Maestro-сценарием на C.

`api/generated/` — read-only (типы при необходимости объявляются в api-client.ts, не в generated); pilot-семейство 995 (features/auth, bootstrap/pilot-app.tsx, metro/jest config, bootstrap/__tests__) — read-only для этого PR (http-runtime.ts — исключение, см. выше); docs/, design/, api/ — read-only.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: пробы исполняют настоящий Jest/RNTL на disposable R и разбирают JSON-отчёт поимённо; пустой отчёт — именованный отказ/INFRASTRUCTURE, не зелёное;
- от ложного подтверждения: открытие PDF и рендер подтверждённого состояния наблюдаются раздельно от onAcknowledge; ack без нажатия ловится клетками NO_AUTO/ACK_PDF;
- от ложного доказательства (Б1, К5′): произведение ЗНАЧЕНИЙ полей evidence — 96 клеток; CURRENT_CONFIRMED без полного доказательства не показывает evidence-карту и continue; точное равенство версий, не сравнение «меньше»;
- от подтверждения устаревшей версии: версионная ось EQ/STALE замкнута в грамматике, CURRENT_CONFIRMED при несовпадении — красная клетка;
- от запрещённых переходов по произведению (Б2, К6′): каждое действие × полный вектор эффектов × состояние × версия × admission — 100 клеток; continue только W1A×CURRENT_CONFIRMED×EQ; доступность и эффекты разделены по правилу;
- от потери recheck и тихого отказа (Б3, К7′): управляемый Promise × три исхода {accepted, notAccepted, reject} × ушедшая версия — 12 клеток; порядок ack-start → settled → recheck наблюдаем в двух точках; rejected Promise гасится эталоном, не тихим нулем;
- от декларативного mock (Б4, К9′): настоящие @/mocks/disclosure-mock и @/mocks/runtime без mock-подмены методов; каждый mock-сценарий ПОДАЁТСЯ В ЭКРАН (20 клеток), runtime-снимок сверяется toEqual ПОЛНОМУ типу и тоже подаётся в экран;
- от подмены копии: точные ключи/тексты/review_status из оракула; notice наблюдается структурно (testID) и текстом;
- от тихого gate в W0: admission-ось замкнута, continue в W0 отсутствует структурно;
- от второй грамматики: DeliveryState/Applicability/Admission определены в api-client.ts одноместно, пробы сверяют байты;
- от мертвой матрицы: каждая проба исполняет все колонки на каждом мутанте, depends измерены прогоном, unexpected_red — дефект.

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

## Источники круга 2 (вместо вопросов круга 1)

1. **Копи-разрыв confirm-кнопки** — остаётся заявленным ограничением: ключа каталога для явного подтверждения нет; надпись — ASCII-плейсхолдер `acknowledge` со статусом PRODUCT_COPY_REVIEW_REQUIRED, закрывается copy signoff CMP-MOB-089 (владелец); семантика ack проверяется клетками К2/К6/К7 независимо от текста кнопки.
2. **F02.V02/F02.V04** — источник найден и вшит (инвариант 9): `docs/ux/01_UX_Source_of_Truth/BrokerOS_Mobile_Design_Data.json:860–880` (variants document_version/accepted_at, delivered/accepted_at; datasets :1037, :1097).
3. **Routes/композиция** — закрыты зоной: `mobile/src/app/` и `mobile/src/bootstrap/http-runtime.ts` в ЗОНА implementer с оговорками выше; владелец композиции — implementer, наблюдение — Maestro на C.

## Фактический замер авторской пачки (круг 3)

Снимок B=`76ac10fa`; disposable-дерево R=`/tmp/dev-harness-verify/Architect107r3/mob` (копия mob арбитра, node_modules перенесены из его npm ci). Замер 2026-10-19, после правок по арбитражу `verdicts/arbitration/contracts-107-perechen-v1.md` (П1–П6). Все rc — из прогонов этого замера.

- B без модели: `erstinfo_static_probe.py --repo R` → rc1 ERSTINFO_MODULE_ABSENT; `erstinfo_probe.py --repo R` → rc1 ERSTINFO_COMPONENT_ABSENT.
- B с эталонной моделью (`--model`): статическая rc0 (22/22), поведенческая rc0 (265/265; ядро К5′+К6′+К7′+К9′ = 229).
- Матрицы: `erstinfo_probe.py --matrix` → rc0 (23 мутанта = 18 круга 2 + 5 декоев П5, defects 0, unexpected_red=none); `erstinfo_static_probe.py --matrix` → rc0 (4 мутанта, defects 0).
- Свидетели круга 1 на новой модели: witness.test.tsx → rc0 (61/61), api-witness.test.tsx → rc0 (2/2).
- Свидетели круга 2 на новой модели: witness.test.tsx → rc1 (16/17; красная только `runtime-composed-current-evidence` — дефект matcher'а самого свидетеля, арбитраж З-1 «им же отозвана»; его же runtime-witness.test.tsx → rc0 1/1 — чистое различение клетки). На каждом из декоев П5 — rc1 именованными клетками перечня (evidence-combination ×4 / retry-is-read-only ×2 / ack-settlement-order ×2 (+ rejected-ack ×2 побочно от разорванного chain) / rejected-ack ×2 / runtime-composed ×1); combined-проба критика (4 мутанта вместе): статическая rc0, поведенческая rc1 (21 RED), witness-паттерн rc1 (9 RED из 13).
- После прогонов `git status --short --untracked-files=all` в R — 0 строк (дерево восстановлено).
- Метагейт: `bash scripts/pre_critic.sh --repo <h> contracts/107-cmp-mob-003-erstinformation.md` → rc0 (см. доклад круга 3).
