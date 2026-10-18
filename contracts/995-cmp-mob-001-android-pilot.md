# Контракт 995 — CMP-MOB-001: Android-пилот e-mail/код → F02.01

КЛАСС: КОДОВЫЙ. Авторский контракт CMP-MOB-001; предмет issue #5 сохранён. Android-приёмка C следует после реализации, не подменяется авторскими моделями.

КОНТЕКСТ: GitHub `a3ka/Complior-mob#5` — источник работ и приёмки; перед раздачей читать полное тело через `gh issue view 5 --repo a3ka/Complior-mob --json body --jq .body`.
КОНТЕКСТ: `contracts/991-complior-repeticiya-p107-p111.md` — дисциплина H/B/C/T и Android evidence; несколько PR репетиции сюда не переносятся.
КОНТЕКСТ: `docs/owner/2026-10-17-plan-stancii.md` — независимый слот mob и ручной Merge.
КОНТЕКСТ: `fixtures/workshop_project/pilot_995/source.json` — до запуска субъекта снять в память copy/ожидания и хеши прочитанных источников.
КОНТЕКСТ: `fixtures/workshop_project/pilot_995/pilot.test.tsx` — исполняемый контракт публичного composition seam и наблюдаемых состояний.

## Существующее

Сверено на разрешённых read-only снимках: Complior-mob B=`f86eb2857966dc9f4c0ff8340dd5484077b6cb33`, Complior-back S=`f7b972913ec2af0df83ce58ea34dd688870fb0e9`. Это полные HEAD из `git rev-parse HEAD`, не названия веток. `source-access.txt` сохраняет историю предыдущего отказа SSH, не действующий блокер. HANDOFF ещё называет mob не начатым; дерево уже несёт авторскую пачку, реализация не раздана.

- `mobile/src/app/index.tsx` сейчас реэкспортирует StartScreen. AuthProvider/ApiClient/экранов auth ещё нет. Jest-expo и RNTL 14 уже стоят; тесты асинхронно await render/fireEvent. Новые зависимости Jest не нужны.
- `STRUCTURE.md` разделяет routes, auth, api, bootstrap, navigation и features/onboarding; `eslint.config.js` уже запрещает transport вне api/http и cross-feature imports. Повторный regex-guard не вводится: `transport_probe.py` исполняет существующий ESLint.
- `api/mock-5_8.json` содержит components схем OpenAPI, НЕ готовый session runtime. `api/api-examples.json` несёт STATIC_ILLUSTRATIVE_EXAMPLES Session/Disclosure; `capture.py` снимает их и точные copy keys. `schema_probe.py` валидирует значения через Draft202012Validator по этому графу, не по вручную написанным DTO.
- `api/frontend-consumer-bindings.json`: F03.A01/F03.A02 = IDP_FLOW, remote_operation_id=null, active_operation_ids=[]; getSession — read. `getDisclosure` = GET /v1/disclosures/{disclosure_id}. Новый REST endpoint входа недопустим.
- Прочитаны Mobile_Design_Data F03/F02, Screen_Matrix, UI_Copy_DE, backend `tests/acceptance-ux1175.json` UX175-F03.A01/F03.A02. Статусы backend остаются NOT_RUN; источник требует intent, no commit navigation, current scope, no duplicate effect/replay, no deprecated fallback.
- D2.2.5.1 `README.md` и screens/html/Splash/First-Run — визуальные референсы, не API/copy authority. Четыре ui.auth.* имеют PRODUCT_COPY_REVIEW_REQUIRED.
- `.github/workflows/mobile.yml` уже запускает quality (npm test/lint/typecheck/doctor), затем release APK и API36 Maestro. `.maestro/start.yaml` и `rehearsal.yaml` предполагают старый cold launch Start; явная миграция входа описана в §Пины и порядок поставки. `rehearsal-evidence.sh` требует успешный testcase `.maestro/rehearsal.yaml` и rehearsal-before/after PNG; этот гейт остаётся неизменным.
- `rehearsal_991/probe.py` — прецедент отдельного Jest в disposable checkout с проверкой исполненных assertions и различением rc1/rc2. Здесь тот же подход, ожидания/код проб снимаются в память до исполнения субъекта.

## Предмет и граница

Один результат: Android mock cold launch → Splash/First-Run → F03.01 e-mail → F03.02 demo-код → F02.01 с ролью AI и Demo. DIRECT unknown/incomplete не открывает защищённый Start. ОДИН PR в a3ka/Complior-mob, без Merge. Implementer — согласованная модель MiniMax; после реализации настоящий Android e2e, независимые adversary и reviewer на одном C.

Вне предмета: backend CMP-BCK-008, приглашения F01, полноценная биометрия, другие устройства, новые action/route IDs, отдельный A07, доказательство реальной доставки, production длина/срок кода. Mock не блокируется отсутствием backend. Copy signoff CMP-MOB-089 и device evidence CMP-MOB-090 этим PR не объявляются завершёнными.

## Инварианты реализации

1. ApiClient использует типы OpenAPI 5.8.2; AuthProvider отделяет identity от HTTP. EXPO_PUBLIC_API_MODE=mock|http, mock по умолчанию dev/тесты/CI. HTTP не симулирует успешный вход при недоступном IdP/backend. Экран использует ApiClient, не fetch; pending-intent — данные, не команда на выполнение.
2. Splash/First-Run следует D2.2.5.1; TextField/Button/Notice нативные, copy по ключам из source.json. F03.V01 неверного кода не создаёт сессию; смена e-mail инвалидирует отложенные результаты старого challenge. После AuthProvider заново прочитать getSession/getDisclosure; DIRECT unknown/incomplete ведёт в F02.01.
3. Sent только после confirmed resend; countdown только из достоверного retryAfterSeconds существующего auth flow. Mock маркирует такие состояния SYNTHETIC. Отсутствие cooldown не превращается в придуманный таймер. Полное значение кода не попадает в сообщения агента/console/артефакты; secureTextEntry, очищение после входа, redaction диагностики.
4. F03.V02 открывает F03.04, A07 вложен в состояние «нет доступа». Безопасный возврат ко входу; восстановление без capability не объявляет успеха. Stale/revoked/missing scope не дают авторизованного перехода. Навигация/перезапуск не выполняют business command, приглашения не принимаются.
5. Runtime mock values `mobile/src/mocks/pilot-responses.json` = объект с getSession/getDisclosure, значения по неизменённым схемам api/. CI реально исполняет schema validation, а не проверяет наличие файла. Входы модели конформны: synthetic адреса .invalid, произвольный непрозрачный код, типизированные ответы/отказы auth и допустимые Session/Disclosure. Контрпример валиден при инвариантности к значениям и расхождении на конформном входе; не требуется принимать новую грамматику вне этих портов.

## Проверяемый шов

`mobile/src/bootstrap/pilot-app.tsx` экспортирует `PilotApp` с необязательными auth/api/entry портами из `pilot.test.tsx`. Без props он использует отгружаемый runtime; `src/app/index.tsx` открывает ту же композицию. F03 остаётся features/auth, F02 — features/onboarding, pending-intent — navigation.

Build seam STRUCTURE.md:163–167: bootstrap импортирует только alias `@pilot/runtime`, экспорт `runtime: {auth: AuthProvider, api: ApiClient}`. Metro выбирает `src/mocks/runtime.ts` либо `src/bootstrap/http-runtime.ts`; Jest выбирает те же файлы по EXPO_PUBLIC_API_MODE до загрузки приложения. Общий тип — `src/bootstrap/runtime-contract.d.ts`, TypeScript paths разрешает alias в этот контракт, не в mock. Неизвестный mode отклоняет сам bootstrap с `PILOT_API_MODE_UNSUPPORTED` (включая загрузку в Jest); HTTP без capability показывает `auth-unavailable`, не авторизованный экран. Mock по умолчанию только dev/тесты; release CI явно задаёт mock.

Auth порт: begin(email) → challenge/evidence либо unavailable; verify(challenge,code) → authenticated|invalid|stale|revoked|missing_scope; resend(challenge) → confirmed/evidence/optional retryAfterSeconds; recover() → unavailable либо подтверждённый исход. Это локальный DI-контракт, не wire endpoint IdP. Api порт: getSession/getDisclosure и запрещённый здесь execute; entry DIRECT, onboarding unknown/incomplete, opaque pendingIntent. Demo AuthProvider и ApiClient реализованы только в mocks; интерфейсы — auth/api. Mock demo-code в `src/mocks/demo-code.ts` равен synthetic `secret` из frozen H/pilot.test.tsx; это не production длина/срок. Native PRIVATE_FILE содержит то же значение; runtime_probe передаёт его только тесту, не задаёт production auth-порты.

`runtime.test.tsx` загружает настоящий root route БЕЗ props; call-through observers снимают результаты реально вызванных runtime.auth/api, не подменяя их. Это проверяет исполнение выбранных объектов, а не существование файлов. `schema_probe` сначала валидирует снимок pilot-responses.json, затем требует равенства ему реально возвращённых Session/Disclosure. Ожидания и исполняемые тесты снимаются в память до субъекта.

TestIDs — automation-семантика, не новые route/action IDs. Матрицы привязывают обманки к наблюдаемым ветвям только в коде probe.py/runtime_probe.py. `model.tsx`/`runtime-model.ts` в PR не копируются; композиция не должна иметь отдельную тестовую реализацию. Эти два запрета — **cognitive-only**: остаточный риск семантически переписанной копии/ветвления по test-env; ловец reviewer сверяет root/bootstrap/auth/api/mocks и отсутствие тестового ответвления. Исполняемые runtime-пробы ловят конкретный C′, но не объявлены доказательством отсутствия любого плагиата.

## Приёмочный критерий

R — disposable копия Complior-mob C под /tmp/dev-harness-verify с npm ci; P — Python с jsonschema==4.26.0; H — принятый харнесс. Команды из H. Нет инструмента/исполненных assertions → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B; `python3 fixtures/workshop_project/pilot_995/probe.py --repo R` → rc1 PILOT_ABSENT. Дано C с frozen CI-тестом; та же команда с `--check-frozen` → rc0 и все CASES; дрейф test/source → rc1 FROZEN_BYTES_MISMATCH. `frozen_matrix.py --repo R` → rc0: оба исторических имени CI-теста сосуществуют с независимой пробой без записи поверх них, изменённая копия отвергается. В C каноническое имя — pilot.test.tsx.
- Дано модели; `python3 fixtures/workshop_project/pilot_995/probe.py --repo R --matrix` → rc0 при совпадении всех ожиданий MUTANTS. DIRECT, invalid, resend, change-email, recovery, stale/revoked/missing-scope, secret, replay, default-offline имеют собственные assertions; `--model M --case K` возвращает фактический rc.
- Дано отгружаемый root C, без подменённых портов; `python3 fixtures/workshop_project/pilot_995/runtime_probe.py --repo R` → rc0: mock/default с верным кодом открывает F02; неверный оставляет auth-invalid без сессии; http без capability показывает auth-unavailable; banana отклоняется PILOT_API_MODE_UNSUPPORTED; фактически вызваны runtime.auth/api и возвращены проверяемые значения. Нарушение → rc1 с именем case. Та же команда с `--matrix` → rc0, все MUTANTS красны на своих ветвях; `--model M --case K` — фактический rc.
- Дано runtime C; `P fixtures/workshop_project/pilot_995/schema_probe.py --repo R` → rc0 только при валидности обеих схем И равенстве возвращённых приложению ответов снимку pilot-responses.json. Неправильный тип → rc1 MOCK_SCHEMA_INVALID:<operation>; отсутствие → rc1 MOCK_RESPONSES_ABSENT; мёртвый валидный файл/отсутствие runtime binding/другой runtime ответ → rc1 RUNTIME_RESPONSES_MISMATCH. `--matrix` → rc0, независимо различены неправильные типы в файле и живом runtime при валидном файле. Schema/hash сняты до субъекта; дрейф → rc2 SCHEMA_SOURCE_CHANGED.
- Дано C; `python3 fixtures/workshop_project/pilot_995/transport_probe.py --repo R` → rc0; fetch/global.fetch → rc1 no-restricted-globals. `--matrix` → rc0: alias зелён, прямой bootstrap→mocks красен import/no-restricted-paths неизменённого ESLint B. Полный npm lint/typecheck остаётся обязательным CI.
- Дано release APK C/mock; `maestro --device SERIAL test --format junit --output OUT/report.xml --test-output-dir OUT fixtures/workshop_project/pilot_995/pilot.yaml` → rc0: cold launch/ввод/F02, после restart First-Run→auth-email без F02, pilot-first-run/welcome/restart PNG. APK B → ненулевой rc на first-run-continue; parser/SDK/эмуляторная ошибка не засчитывается. PILOT_DEMO_CODE вне лога; публикация только через redacting runner из §Пины. PNG не показывает полный код. No replay доказывает RNTL REPLAY, не отсутствующие Maestro testID.
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` и review jobs/logs/JUnit → rc0 и исполнены quality/android-e2e, все пилотные assertions, schema/runtime/flow. Skipped/continue-on-error/нет assertion/PNG/APK → отказ с именем свидетельства. Cognitive-only: effective workflow и H-пины, ловец reviewer. Никакой placeholder регистрации в dev-harness CI.
- Дано synthetic trace; reviewer сверяет UX175-F03.A01/F03.A02 → no commit/replay, stale/revoked, intent, SYNTHETIC. Без HTTP_REQUEST_RESPONSE/SQL_BEFORE_AFTER/PROVIDER_CALL_COUNT соответствующего SWITCH/backend — NOT_RUN; backend PASS на mock → BACKEND_EVIDENCE_MISSING. Cognitive-only, ловец reviewer.
- Дано авторская пачка; `bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md` → rc0. Реальные rc предметных прогонов приложены отдельно.

## Пины и порядок поставки

После critic/freeze оркестратор разрешает `frozen/contracts/995/1^{commit}` в полный SHA H и append-only записывает его с B/S, ContextPack и hashes в issue #5 ДО раздачи implementer. H не равен движущейся main; SHA ещё несуществующей заморозки не выдумывается. mobile.yml получает публичный a3ka/dev-harness через actions/checkout с этим буквальным SHA. Далее implementer → один PR C → эмулятор → adversary/reviewer → доклад владельцу, БЕЗ merge. Новый C требует новых evidence; для run: tree T, SDK/AVD/Maestro, run/attempt, APK/JUnit/PNG IDs/SHA256.

Quality сохраняет npm test/lint/typecheck/doctor. В `bootstrap/__tests__/pilot.test.tsx` и `source.json` лежат байты H. До npm test CI исполняет `cmp` каждой копии с соответствующим H-файлом; несовпадение останавливает job. Затем в disposable R выполняются `probe.py --check-frozen`, `runtime_probe.py`, `schema_probe.py` из H (все с `--repo R`, Python requirements из H). Не переносить Python runtime_probe в mocks: он запускает Jest, а не становится production импортом. Изолированные временные test-каталоги удаляются; существующий CI-тест не перезаписывается. Сверка байтов дополнительно встроена в `--check-frozen`.

Native mobile.yml вызывает из H `python3 fixtures/workshop_project/pilot_995/maestro_probe.py --repo C --apk ABS_APK --code-file PRIVATE_FILE --out C/mobile/maestro-out` вместо прямого ci-e2e. Runner снимает script/legacy flow bytes до исполнения, вызывает существующий ci-e2e в приватном cwd с абсолютным APK и frozen pilot.yaml; script управляет эмулятором, отдельный вызов после его завершения недопустим. В checkout публикуется только redacted maestro-out, затем неизменный rehearsal-evidence gate/upload. PRIVATE_FILE вне checkout/artifacts; output path новый. `native_matrix.py --scratch SCRATCH` → rc0 только при совпадении ROWS/redaction; синтетические APK/PNG не Android evidence.

Frozen pilot.yaml живёт в H, НЕ в публичной mobile/.maestro: cloud продолжает общие start/rehearsal без кода; полная pilot-проверка — mobile.yml. **Миграция 991:** start.yaml проверяет First-Run/start.png. rehearsal.yaml сохраняет имя testcase и rehearsal-before/after PNG, но действие — First-Run→e-mail→demo-entry→F03.02; после restart незавершённый challenge возвращается к auth-email через First-Run, если показан. Before — до действия, after — после confirmed begin. Pilot отдельно проверяет успешный код и безопасный restart; bypass route IDs не вводятся.

Без правок остаются component RNTL `features/start/__tests__/start-screen.test.tsx` и `rehearsal.test.tsx`, quality/android-e2e jobs, Maestro version gate, scripts/rehearsal-evidence.sh в обоих workflows; mobile-cloud-e2e не меняется. Дано C; scoped Jest этих component tests + все Maestro flows и rehearsal-evidence gate → rc0; нет rehearsal testcase/PNG → отказ существующего гейта. История 991 не переписывается. Actual C — NOT_RUN.

Splash/First-Run, визуальное сходство с D2.2.5.1 и немецкий copy — **cognitive-only**: остаточный риск кратковременного/визуального дефекта вне assertions, reviewer сверяет источник и PNG/нативный запуск. Copy signoff остаётся владельцу. RNTL-модель визуальной приёмкой не является.

## Зоны и исполнители

ЗОНА architect: contracts/995-cmp-mob-001-android-pilot.md fixtures/workshop_project/pilot_995/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/pilot_995/ — 105 новый подкаталог существующей architect-зоны; чужие файлы не меняются.

Пути implementer отсчитываются от Complior-mob, не dev-harness:

ЗОНА implementer: mobile/src/app/ mobile/src/features/auth/ mobile/src/api/ mobile/src/auth/ mobile/src/mocks/ mobile/.maestro/ .github/workflows/mobile.yml mobile/src/bootstrap/pilot-app.tsx mobile/src/bootstrap/__tests__/ mobile/src/features/onboarding/welcome-screen.tsx mobile/src/navigation/pending-intent.ts mobile/metro.config.js mobile/jest.config.js mobile/package.json mobile/tsconfig.json mobile/src/bootstrap/http-runtime.ts mobile/src/bootstrap/runtime-contract.d.ts

`bootstrap/pilot-app.tsx` и `__tests__/` — composition/шов (STRUCTURE.md:60,143–155); `features/onboarding/welcome-screen.tsx` — F02 (60–77,111); `navigation/pending-intent.ts` — данные (61,157). Дополнения по STRUCTURE.md:163–167: `metro.config.js` — resolver.resolveRequest alias с делегированием; `jest.config.js` — тот же выбор в тестах; `package.json` — удалить прежний inline jest config, зависимости не добавлять; `tsconfig.json` + `bootstrap/runtime-contract.d.ts` — общий тип alias вне mocks; `bootstrap/http-runtime.ts` — HTTP composition. `mocks/runtime.ts`/`mocks/demo-code.ts`/`mocks/pilot-responses.json` уже покрыты mocks-зоной. Другие bootstrap/config файлы не разрешены. ESLint B неизменён; api/docs/design read-only, mobile-cloud-e2e и настройки GitHub вне зоны.

**ФОРК/РЕШЕНИЕ — инженерный, решён architect:** принимается resolver composition STRUCTURE.md, не прямой bootstrap→mocks и не demo внутри bootstrap. Расширены только перечисленные необходимые пути. `transport_probe --matrix` предъявляет alias с type mapping зелёным, прямой импорт mocks красным действующим ESLint B. Приоритет STRUCTURE над PROPOSED issue-зоной сохраняется; решения о copy/риске/деньгах не принимаются.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: настоящие RNTL transitions, проверка набора assertions, схемы из source, предметные отрицательные контроли;
- от подмены mock production-доказательством: SYNTHETIC/NOT_RUN и отдельная backend evidence;
- от неподтверждённого sent/cooldown и продолжения старого e-mail: deferred response probes;
- от подмены ожиданий диском субъекта: source и test bytes снимаются в память до запуска.

НЕ ЗАЩИЩАЕТ:
- от злонамеренного кода с общим uid и подделки Jest internals: независимые суды, immutable H, CI evidence, не credential sandbox;
- от визуального дефекта вне assertions, доставки кода, настоящего backend/IdP и production auth;
- от пропуска cognitive-only сверок: ловец reviewer и ручной Merge владельца.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: потребляется действующая норма закрытия роли. Новая общая норма не вводится; локальная приёмка этой задачи исполняется оркестратором/судьями и CI Complior-mob. Внешние пробы НЕ объявлены guard-каналами dev-harness: текущий check_provodka требует для них отсутствующую локальную CI-проводку. На ещё не принятую правку 994 контракт не опирается.

## Отложенная продуктовая приёмка

- Android red на APK B, green на release APK C, PNG review и реальные PR jobs — NOT_RUN: C ещё не реализован, `adb devices -l` не показывает устройства. Это обязательная приёмка implementer/судей после freeze, не блокер авторской матрицы.
- Native runner исполняется командой `python3 fixtures/workshop_project/pilot_995/maestro_probe.py --device SERIAL --code-file PRIVATE_FILE --out NEW_OUT`; код читается из приватного файла, frozen flow запускается в приватном временном каталоге, stdout/stderr/XML/JSON перед публикацией редактируются по точному значению. Контрмодели доказывают этот путь без эмулятора; PNG требуют secureTextEntry и визуальной сверки на C. Прямой Maestro из §Приёмочный критерий описывает внутренний вызов runner, не разрешает upload сырых artifacts.
- Backend/IdP HTTP_REQUEST_RESPONSE, SQL_BEFORE_AFTER, PROVIDER_CALL_COUNT — NOT_RUN: mock-предмет не доказывает production auth/backend. Copy signoff остаётся владельцу.

## Фактический замер авторской пачки

R=`/tmp/dev-harness-verify/architect995/mob`, P=`/tmp/dev-harness-verify/architect995/venv/bin/python`. Read-only c995/critic995r1 не изменялись. Следующие команды исполнены из H, путь F=`fixtures/workshop_project/pilot_995`:

- `python3 F/probe.py --repo R --matrix` → rc0, runs=18, mismatches=0; сохранены все исходные CASES/MUTANTS.
- `python3 F/runtime_probe.py --repo R --matrix` → rc0, honest: все 6 CASES rc0; 7 MUTANTS rc1 по собственным причинам, runs=8, mismatches=0.
- `python3 F/frozen_matrix.py --repo R` → rc0, checked=3: оба имени CI-теста rc0/preserved=true; drift rc1 FROZEN_BYTES_MISMATCH.
- `P F/schema_probe.py --repo R --matrix` → rc0, checked=6: schema и runtime honest rc0; wrong-session/wrong-disclosure rc1 отдельно в данных и живом runtime при валидном файле.
- `python3 F/transport_probe.py --repo R --matrix` → rc0, checked=5: honest/alias rc0; fetch/global rc1 no-restricted-globals; bootstrap-mocks rc1 import/no-restricted-paths.
- `python3 F/native_matrix.py --scratch /tmp/dev-harness-verify/architect995` → rc0, checked=16, redaction=true; Android NOT_RUN.
- Repro критика `critic995r1/make_bypass.py critic995r1/dh COPY` исполнен на новой disposable копии B: C′ runtime_probe rc1 (SHIPPED_INVALID/HTTP_UNAVAILABLE/UNKNOWN_MODE/RUNTIME_RESPONSES красны; валидный вход зелён). C″ с runtime principal_ref=42 при неизменённом валидном pilot-responses.json: schema_probe rc1 RUNTIME_RESPONSES_MISMATCH. У C″ нет alias binding; отдельный wrong-session runtime-мутант выше доказывает расхождение principal_ref при существующем binding.

Обязательные метагейты: `bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md` и `bash scripts/check_threat_model.sh . contracts/995-cmp-mob-001-android-pilot.md`; фактические rc в докладе. Они не заменяют предмет.

