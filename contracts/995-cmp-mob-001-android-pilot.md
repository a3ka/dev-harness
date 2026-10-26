# Контракт 995 — CMP-MOB-001: Android-пилот e-mail/код → F02.01

КЛАСС: КОДОВЫЙ. Авторский контракт CMP-MOB-001; предмет issue #5 сохранён. Android-приёмка C следует после реализации, не подменяется авторскими моделями.
КЛАСС РИСКА: рисковый — основание «безопасность»: в диагностике и журналах обеих попыток проходит секрет значения кода доступа (PILOT_DEMO_CODE); публикация — только redacted, утечка — отдельная красная клетка батареи v+1.

КОНТЕКСТ: GitHub `a3ka/Complior-mob#5` — источник работ и приёмки; перед раздачей читать полное тело через `gh issue view 5 --repo a3ka/Complior-mob --json body --jq .body`.
КОНТЕКСТ: `contracts/991-complior-repeticiya-p107-p111.md` — дисциплина H/B/C/T и Android evidence; несколько PR репетиции сюда не переносятся.
КОНТЕКСТ: `docs/owner/2026-10-17-plan-stancii.md` — независимый слот mob и ручной Merge.
КОНТЕКСТ: `fixtures/workshop_project/pilot_995/source.json` — до запуска субъекта снять в память copy/ожидания и хеши прочитанных источников.
КОНТЕКСТ: `fixtures/workshop_project/pilot_995/pilot.test.tsx` — исполняемый контракт публичного composition seam и наблюдаемых состояний.
КОНТЕКСТ: `verdicts/consultant/995-obryv-emulyatora-astra-v1.md` §3/§6/§7–§11 (консультация Astra, read-only 26.10; слово владельца 2026-10-26 ~15:30 Берлин «да, принимаем» — план целиком; копия с `owner/astra-995` в `/tmp/dev-harness-verify/orch/astra995.md`) — ТЗ v+1: единственный владелец эмулятора/повтора — `mobile/scripts/ci-e2e.sh`, redacted диагностика обеих попыток у P, причинный замер §10.
КОНТЕКСТ: серия на голове PR #124 (run 40321887036): 3 success / 5; попытки 4–5 (job 121594516324, 121599449453) красные на native 995 — 7/7 мгновенных падений по обрыву adb-транспорта, артефакт попытки 5 `maestro.log`: «ПОВТОР» повторяет Maestro на ТОМ ЖЕ эмуляторе (`adb reconnect offline`), перезапуска эмулятора нет.

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

## Инварианты v+1 (перезапуск собственного эмулятора и один повтор набора)

Субъекты v+1: S = `mobile/scripts/ci-e2e.sh` (продукт; ЗОНА implementer, копия байт-в-байт из модели `fixtures/workshop_project/pilot_995/restart/model/ci-e2e.sh`, sha256 `d8841d6b6fa4528e664668343db493401f58f9d559577444c4fe7db9bf8b3fdb`); P = `fixtures/workshop_project/pilot_995/maestro_probe.py` (харнесс, ЗОНА architect по frozen 995/1 «fixtures/workshop_project/pilot_995/»; правку P вносит архитектор пачкой v+1 — внесена, байты равны модели `restart/model/maestro_probe.py`, sha256 `9a556b48cf4f84a988ba520e6e9ec7389004f461173a8202c6dfb34528803749`; живой файл сверяется клеткой zhyvoj-p-kanon). Номера 6+ продолжают нумерацию инвариантов 1–5.

6. Единственный владелец эмулятора и повтора — S. Ни P (приватный cwd/редакция/публикация), ни mobile.yml, ни 139/141 не заводят своего повтора набора 995 и не управляют эмулятором. Шаговый повтор 141 и перепин 139 v+1 не меняются этой пачкой.
7. Право на повтор: rc≠0 полного набора И каноническая сигнатура обрыва adb-транспорта — одна строка канона 117/141/139 `device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException` (в тексте S ровно 1 вхождение, обрывки вне канона запрещены) — в артефактах ТЕКУЩЕЙ попытки (её maestro-журнал, её JUnit, её test-вывод; не эхо, не прошлые попытки, не просроченные артефакты workspace, не diagnostics), И каждый провал JUnit сам транспортный. Смешанный лог (продуктовая неудача + сигнатура) и пустой вывод повтор не дают; продуктовый отказ не повторяется и не стирается.
8. Повтор — ровно один: диагностика ДО остановки → остановка ТОЛЬКО собственного эмулятора по owned PID (TERM → ограниченное ожидание выхода → KILL того же PID; без широких завершателей по маске, без разрыва сервера adb, без переподключения офлайн-устройства, без чужих PID) → новая инкарнация эмулятора (новый PID, тот же AVD/порт; жив owned PID — `kill -0` на входе готовности и непосредственно (без единого вызова наружу между проверкой и действием) перед КАЖДЫМ состояние-меняющим вызовом инкарнации — замкнутый алфавит: `adb shell settings put`, `adb install`, `maestro`; смерть owned PID, назначенная в ЛЮБОЙ точке между вызовами инкарнации, не даёт ни одного состояние-меняющего вызова — именованный красный (свип смерти батареи, арбитраж `verdicts/arbitration/contracts-995-v2-arbitraz.md`); мёртвый owned PID при отвечающем serial — чужой/старый процесс на порту — новой инкарнацией не считается, готовность/установка/набор по нему не выполняются, EMULATOR_START сам по себе инкарнацию не подтверждает; готовность — реальная wall-clock граница 390 с И потолок итераций; установка с проверкой итога; стабильность транспорта тремя подряд проверками) → один повтор полного набора. Второй красный — итоговый красный: RECOVERED при втором зелёном, EXHAUSTED при втором красном; третьей попытки нет. Смерть owned PID ПОСЛЕ старта второго набора итог не маскирует: действует результат второго набора.
9. Диагностика обеих попыток (причинный замер §10 Astra): до набора и при отказе — ДО любой остановки — снимок с полями utc/monotonic, run/github_attempt/local_attempt/pokolenie, serial/avd/port, emulator_pid/старт/журнал инкарнации, netns, adb-сервер, guest boot_id, PID adbd, доступная память, cgroup memory/cpu и PSI, ограниченный logcat до набора и при отказе, полный журнал эмулятора инкарнации, maestro-вывод, копия JUnit. Недоступное поле честно помечается. Публикация: финальные JUnit/PNG — ОДНОЙ (финальной) попытки в вершине `maestro-out/`; текстовая диагностика всех попыток — `maestro-out/diagnostics/attempt-1|2/`; кадры нефинальных попыток не публикуются; просроченные артефакты публикация стирает. Секрет (PILOT_DEMO_CODE) снимается редактированием со ВСЕХ текстовых каналов обеих попыток; P печатает краткое redacted событие RECOVERED/EXHAUSTED; при истечении бюджета `--timeout` P останавливает только собственное дерево процессов (сессия) и всё равно публикует собранное.
10. Отказы готовности инкарнации — именованные (память станции, загрузка за 390 с, установка APK, стабилизация транспорта, готовность после перезапуска, смерть owned PID новой инкарнации в любой точке до второго набора): Maestro не запускается, RECOVERED не объявляется, повтор по ним не расходуется, исходный rc сохраняется. Cleanup останавливает только owned PID после сохранения диагностики и не меняет итог.

Красная батарея `fixtures/workshop_project/pilot_995/restart/` судит поведение настоящего S replay-ем в замкнутом PATH (подложные adb/emulator/avdmanager/maestro/pkill; журнал вызовов — оракул; имена прогонов и кадров порождает раннер) и пробу P поверх модели S; оракул `source.json` в памяти до вызова субъекта; прежние клетки/стабы 995 байт-неизменны. Ось «владение инкарнацией» (критик, круг 1 FAIL): смерть подложного emulator назначает раннер — сразу после EMULATOR_START при продолжающем отвечать stale serial (свидетель критика дословно), между готовностью и вторым набором (по boot-диагностике попытки 2), после старта второго набора (по строке MAESTRO 2); свип смерти: точка смерти — каждый вызов замкнутого алфавита внутри второй инкарнации (включая тело boot-цикла), N выводится чистым replay на каждом прогоне, ожидание одно и вычислено до вызова субъекта; свидетели — критик 1/2 (`s-bez-zhizni`), критик 2/2 (`s-zhizn-perenesena`), арбитр (`s-zhizn-ne-pered-nastrojkami`); ожидания вычислены до вызова субъекта. Команды приёмки v+1 (W = `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh`):

- `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh` → rc 1 → красная: SUBJECT_ABSENT
- `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model` → rc 0 (30/30, три прогона подряд rc 0 — порождаемые входы не меняют исход; N свипа печатается и одинаков)
- `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs` → rc 0, контроль 30/30, SVJAZI 44, живых 0 (режим CI харнесса без omp/сети)
- `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --repo <корень продукта>` до правки S → rc 1 (красный перечень входов); после байт-в-байт правки → rc 0

замер: `ls -1 fixtures/workshop_project/pilot_995/restart/model/* | wc -l` = 2 census fixtures/workshop_project/pilot_995/restart/model/*
замер: `ls -1 fixtures/workshop_project/pilot_995/restart/nositeli/* | wc -l` = 2 census fixtures/workshop_project/pilot_995/restart/nositeli/*

## Проверяемый шов

`mobile/src/bootstrap/pilot-app.tsx` экспортирует `PilotApp` с необязательными auth/api/entry портами из `pilot.test.tsx`. Без props он использует отгружаемый runtime; `src/app/index.tsx` открывает ту же композицию. F03 остаётся features/auth, F02 — features/onboarding, pending-intent — navigation.

Build seam STRUCTURE.md:163–171: bootstrap импортирует только alias `@pilot/runtime`, экспорт `runtime: {auth: AuthProvider, api: ApiClient}`. Metro выбирает `src/mocks/runtime.ts` либо `src/bootstrap/http-runtime.ts`; механизм — `bundle_probe.py`, две Android export/source-map проверки независимо от Jest. Jest выбирает те же файлы по EXPO_PUBLIC_API_MODE до загрузки приложения. Интерфейсы живут в `src/api/api-client.ts` (ApiClient) и `src/auth/` (AuthProvider); `src/bootstrap/runtime-contract.d.ts` только собирает из них `runtime: {auth: AuthProvider; api: ApiClient}`. TypeScript paths разрешает alias в этот контракт, не в mock. `mocks/runtime.ts` импортирует типы из `@/api`/`@/auth`, не из bootstrap. Источник OpenAPI-типов: ручные типы двух операций в `src/api/` со ссылками на компоненты Session/Disclosure read-only `api/mock-5_8.json` 5.8.2; зависимости не добавлять. Неизвестный mode отклоняет сам bootstrap с `PILOT_API_MODE_UNSUPPORTED` (включая загрузку в Jest); HTTP без capability показывает `auth-unavailable`, не авторизованный экран. Mock по умолчанию только dev/тесты; release CI явно задаёт mock.

Auth порт: begin(email) → challenge/evidence либо unavailable; verify(challenge,code) → authenticated|invalid|stale|revoked|missing_scope; resend(challenge) → confirmed/evidence/optional retryAfterSeconds; recover() → unavailable либо подтверждённый исход. Это локальный DI-контракт, не wire endpoint IdP. Api порт: getSession/getDisclosure и запрещённый здесь execute; entry DIRECT, onboarding unknown/incomplete, opaque pendingIntent. Demo AuthProvider и ApiClient реализованы только в mocks; интерфейсы — auth/api. Demo-код в `src/mocks/demo-code.ts` — литерал, равный synthetic `secret` из frozen H/pilot.test.tsx; это не production длина/срок. Ни runtime_probe, ни CI не передают его субъекту через env. PRIVATE_FILE с тем же значением читает только Maestro-runner.

`runtime.test.tsx` загружает настоящий root route БЕЗ props; call-through observers снимают результаты реально вызванных runtime.auth/api, не подменяя их. Это проверяет исполнение выбранных объектов, а не существование файлов. `schema_probe` сначала валидирует снимок pilot-responses.json, затем требует равенства ему реально возвращённых Session/Disclosure. Ожидания и исполняемые тесты снимаются в память до субъекта.

TestIDs — automation-семантика, не новые route/action IDs. Матрицы привязывают обманки к наблюдаемым ветвям только в коде проб. `model.tsx`/`runtime-model.ts` в PR не копируются; композиция не должна иметь отдельную тестовую реализацию. Эти два запрета — **cognitive-only**: остаточный риск семантически переписанной копии/ветвления по test-env; ловец reviewer сверяет root/bootstrap/auth/api/mocks и отсутствие тестового ответвления. Исполняемые runtime-пробы ловят конкретный C′, но не объявлены доказательством отсутствия любого плагиата.

**Cognitive-only, чек-лист П4 арбитража 995:** ApiClient/AuthProvider, происхождение типов и раскладка F03/F02 по слоям механически не проверяются; поведение данных держат schema_probe/runtime_probe. Ловец reviewer проверяет:
1. `src/api/api-client.ts` экспортирует интерфейс ApiClient; getSession/getDisclosure возвращают типы из названных выше компонентов `api/mock-5_8.json`, не `unknown`/`any`.
2. В `src/auth/` лежит интерфейс AuthProvider, Demo-реализации там нет.
3. `mocks/runtime.ts` и `bootstrap/http-runtime.ts` аннотированы этими интерфейсами.
4. F03 лежит в `features/auth/`, F02 — в `features/onboarding/welcome-screen.tsx`, pending-intent — в `navigation/pending-intent.ts`.

## Приёмочный критерий

R — disposable копия Complior-mob C под /tmp/dev-harness-verify с npm ci; P — Python с jsonschema==4.26.0; H — принятый харнесс. Команды из H. Нет инструмента/исполненных assertions → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B; `python3 fixtures/workshop_project/pilot_995/probe.py --repo R` → rc1 PILOT_ABSENT. Дано C с frozen CI-тестом; та же команда с `--check-frozen` → rc0 и все CASES; дрейф test/source → rc1 FROZEN_BYTES_MISMATCH. `frozen_matrix.py --repo R` → rc0: оба исторических имени CI-теста сосуществуют с независимой пробой без записи поверх них, изменённая копия отвергается. В C каноническое имя — pilot.test.tsx.
- Дано модели; `python3 fixtures/workshop_project/pilot_995/probe.py --repo R --matrix` → rc0 при совпадении всех ожиданий MUTANTS. DIRECT, invalid, resend, change-email, recovery, stale/revoked/missing-scope, secret, replay, default-offline имеют собственные assertions; `--model M --case K` возвращает фактический rc.
- Дано отгружаемый root C, без подменённых портов; `python3 fixtures/workshop_project/pilot_995/runtime_probe.py --repo R` → rc0: mock/default с верным кодом открывает F02; неверный оставляет auth-invalid без сессии; http без capability показывает auth-unavailable; banana отклоняется PILOT_API_MODE_UNSUPPORTED; фактически вызваны runtime.auth/api и возвращены проверяемые значения. Нарушение → rc1 с именем case. Та же команда с `--matrix` → rc0, все MUTANTS красны на своих ветвях; `--model M --case K` — фактический rc. PILOT_DEMO_CODE удаляется также из унаследованного env Jest.
- Дано C; `python3 fixtures/workshop_project/pilot_995/bundle_probe.py --repo R` → rc0: реальные `expo export --platform android --source-maps --clear` в режимах http/mock; sources всех карт нормализованы к `src/…`. HTTP не содержит `src/mocks/` и содержит `src/bootstrap/http-runtime.ts`; mock содержит `src/mocks/runtime.ts`, не содержит HTTP runtime. Нарушение → rc1 BUNDLE_HTTP_HAS_MOCKS/BUNDLE_HTTP_RUNTIME_ABSENT/BUNDLE_MOCK_HAS_HTTP_RUNTIME/BUNDLE_MOCK_RUNTIME_ABSENT; B без seam → rc1 BUNDLE_SEAM_ABSENT. Export rc≠0/нет карт → rc2 INFRASTRUCTURE. Вывод export — временный каталог вне R; после пробы `git status --short` в чистом R пуст (gitignored .expo допустим). `--matrix` → rc0 при совпадении всех ожиданий кода; `--model M` возвращает фактический rc.
- Дано runtime C; `P fixtures/workshop_project/pilot_995/schema_probe.py --repo R` → rc0 только при валидности обеих схем И равенстве возвращённых приложению ответов снимку pilot-responses.json. Неправильный тип → rc1 MOCK_SCHEMA_INVALID:<operation>; отсутствие → rc1 MOCK_RESPONSES_ABSENT; мёртвый валидный файл/отсутствие runtime binding/другой runtime ответ → rc1 RUNTIME_RESPONSES_MISMATCH. `--matrix` → rc0, независимо различены неправильные типы в файле и живом runtime при валидном файле. Schema/hash сняты до субъекта; дрейф → rc2 SCHEMA_SOURCE_CHANGED.
- Дано C; `python3 fixtures/workshop_project/pilot_995/transport_probe.py --repo R` → rc0; fetch/global.fetch → rc1 no-restricted-globals. `--matrix` → rc0: alias зелён, прямой bootstrap→mocks красен import/no-restricted-paths неизменённого ESLint B. Полный npm lint/typecheck остаётся обязательным CI.
- Дано release APK C/mock; `maestro --device SERIAL test --format junit --output OUT/report.xml --test-output-dir OUT fixtures/workshop_project/pilot_995/pilot.yaml` → rc0: cold launch/ввод, неверный код → auth-invalid видим/F02.01 не видим, очистка поля/верный код → F02; после restart First-Run→auth-email без F02, pilot-first-run/welcome/restart PNG. APK B → ненулевой rc на first-run-continue; parser/SDK/эмуляторная ошибка не засчитывается. PILOT_DEMO_CODE вне лога; публикация только через redacting runner из §Пины. PNG не показывает полный код. No replay доказывает RNTL REPLAY, не отсутствующие Maestro testID.
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` и review jobs/logs/JUnit → rc0 и исполнены quality/android-e2e, все пилотные assertions, schema/runtime/bundle/flow. Skipped/continue-on-error/нет assertion/PNG/APK → отказ с именем свидетельства. Cognitive-only: effective workflow и H-пины, ловец reviewer. Никакой placeholder регистрации в dev-harness CI.
- Дано synthetic trace; reviewer сверяет UX175-F03.A01/F03.A02 → no commit/replay, stale/revoked, intent, SYNTHETIC. Без HTTP_REQUEST_RESPONSE/SQL_BEFORE_AFTER/PROVIDER_CALL_COUNT соответствующего SWITCH/backend — NOT_RUN; backend PASS на mock → BACKEND_EVIDENCE_MISSING. Cognitive-only, ловец reviewer.
- Дано авторская пачка; `bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md` → rc0. Реальные rc предметных прогонов приложены отдельно.

## Пины и порядок поставки

После critic/freeze оркестратор разрешает `frozen/contracts/995/1^{commit}` в полный SHA H и append-only записывает его с B/S, ContextPack и hashes в issue #5 ДО раздачи implementer. H не равен движущейся main; SHA ещё несуществующей заморозки не выдумывается. mobile.yml получает публичный a3ka/dev-harness через actions/checkout с этим буквальным SHA. Далее implementer → один PR C → эмулятор → adversary/reviewer → доклад владельцу, БЕЗ merge. Новый C требует новых evidence; для run: tree T, SDK/AVD/Maestro, run/attempt, APK/JUnit/PNG IDs/SHA256.

Quality сохраняет npm test/lint/typecheck/doctor. В `bootstrap/__tests__/pilot.test.tsx` и `source.json` лежат байты H. До npm test CI исполняет `cmp` каждой копии с соответствующим H-файлом; несовпадение останавливает job. Затем в disposable R выполняются `probe.py --check-frozen`, `runtime_probe.py`, `bundle_probe.py`, `schema_probe.py` из H (все с `--repo R`, Python requirements из H). Не переносить Python runtime_probe в mocks: он запускает Jest, а не становится production импортом. Изолированные временные test-каталоги удаляются; существующий CI-тест не перезаписывается. Сверка байтов дополнительно встроена в `--check-frozen`.

Native mobile.yml вызывает из H `python3 fixtures/workshop_project/pilot_995/maestro_probe.py --repo C --apk ABS_APK --code-file PRIVATE_FILE --out C/mobile/maestro-out` вместо прямого ci-e2e. Runner снимает script/legacy flow bytes до исполнения, вызывает существующий ci-e2e в приватном cwd с абсолютным APK и frozen pilot.yaml; script управляет эмулятором, отдельный вызов после его завершения недопустим. В checkout публикуется только redacted maestro-out, затем неизменный rehearsal-evidence gate/upload. PRIVATE_FILE вне checkout/artifacts; output path новый. `native_matrix.py --scratch SCRATCH` → rc0 только при совпадении ROWS/redaction; синтетические APK/PNG не Android evidence.

Frozen pilot.yaml живёт в H, НЕ в публичной mobile/.maestro: cloud продолжает общие start/rehearsal без кода; полная pilot-проверка — mobile.yml. **Миграция 991:** start.yaml проверяет First-Run/start.png. rehearsal.yaml сохраняет имя testcase и rehearsal-before/after PNG, но действие — First-Run→e-mail→demo-entry→F03.02; после restart незавершённый challenge возвращается к auth-email через First-Run, если показан. Before — до действия, after — после confirmed begin. Pilot отдельно проверяет неверный/успешный код и безопасный restart; bypass route IDs не вводятся.

Без правок остаются component RNTL `features/start/__tests__/start-screen.test.tsx` и `rehearsal.test.tsx`, quality/android-e2e jobs, Maestro version gate, scripts/rehearsal-evidence.sh в обоих workflows; mobile-cloud-e2e не меняется. Дано C; scoped Jest этих component tests + все Maestro flows и rehearsal-evidence gate → rc0; нет rehearsal testcase/PNG → отказ существующего гейта. История 991 не переписывается. Actual C — NOT_RUN.

Splash/First-Run, визуальное сходство с D2.2.5.1 и немецкий copy — **cognitive-only**: остаточный риск кратковременного/визуального дефекта вне assertions, reviewer сверяет источник и PNG/нативный запуск. Copy signoff остаётся владельцу. RNTL-модель визуальной приёмкой не является.

## Зоны и исполнители

ЗОНА architect: contracts/995-cmp-mob-001-android-pilot.md fixtures/workshop_project/pilot_995/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/pilot_995/ — 105 новый подкаталог существующей architect-зоны; чужие файлы не меняются.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/pilot_995/ — 118 v+1: maestro_probe.py этой директории правится architect-пачкой v+1 (байты = модели restart/), прежние клетки/стабы байт-неизменны; чужие файлы не меняются.

Пути implementer отсчитываются от Complior-mob, не dev-harness:

ЗОНА implementer: mobile/src/app/ mobile/src/features/auth/ mobile/src/api/ mobile/src/auth/ mobile/src/mocks/ mobile/.maestro/ .github/workflows/mobile.yml mobile/src/bootstrap/pilot-app.tsx mobile/src/bootstrap/__tests__/ mobile/src/features/onboarding/welcome-screen.tsx mobile/src/navigation/pending-intent.ts mobile/metro.config.js mobile/jest.config.js mobile/package.json mobile/tsconfig.json mobile/src/bootstrap/http-runtime.ts mobile/src/bootstrap/runtime-contract.d.ts mobile/scripts/ci-e2e.sh
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 замер self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 строка step self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 проводка self-test батареи 995 — интеграционный коммит оркестратора в окне freeze..done, форма чужих шагов не меняется

`bootstrap/pilot-app.tsx` и `__tests__/` — composition/шов (STRUCTURE.md:60,143–155); `features/onboarding/welcome-screen.tsx` — F02 (60–77,111); `navigation/pending-intent.ts` — данные (61,157). Дополнения по STRUCTURE.md:163–167: `metro.config.js` — resolver.resolveRequest alias с делегированием; `jest.config.js` — тот же выбор в тестах; `package.json` — удалить прежний inline jest config, зависимости не добавлять; `tsconfig.json` + `bootstrap/runtime-contract.d.ts` — общий тип alias вне mocks; `bootstrap/http-runtime.ts` — HTTP composition. `mocks/runtime.ts`/`mocks/demo-code.ts`/`mocks/pilot-responses.json` уже покрыты mocks-зоной. Другие bootstrap/config файлы не разрешены. ESLint B неизменён; api/docs/design read-only, mobile-cloud-e2e и настройки GitHub вне зоны.

**ФОРК/РЕШЕНИЕ — инженерный, решён architect:** принимается resolver composition STRUCTURE.md, не прямой bootstrap→mocks и не demo внутри bootstrap. Расширены только перечисленные необходимые пути. `transport_probe --matrix` предъявляет alias с type mapping зелёным, прямой импорт mocks красным действующим ESLint B. Приоритет STRUCTURE над PROPOSED issue-зоной сохраняется; решения о copy/риске/деньгах не принимаются.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: настоящие RNTL transitions, проверка набора assertions, схемы из source, предметные отрицательные контроли и Metro bundle graph;
- от подмены mock production-доказательством: SYNTHETIC/NOT_RUN и отдельная backend evidence;
- от неподтверждённого sent/cooldown и продолжения старого e-mail: deferred response probes;
- от подмены ожиданий диском субъекта: source и test bytes снимаются в память до запуска, demo-код не передаётся субъекту через env.

НЕ ЗАЩИЩАЕТ:
- от злонамеренного кода с общим uid и подделки Jest internals: независимые суды, immutable H, CI evidence, не credential sandbox;
- от визуального дефекта вне assertions, доставки кода, настоящего backend/IdP и production auth;
- от пропуска cognitive-only сверок: ловец reviewer и ручной Merge владельца;
- от неполного ApiClient/AuthProvider или иной раскладки слоёв при зелёных пробах — принятый остаток арбитража 995, ловец reviewer по чек-листу П4.

### v+1 (restart)

ЗАЩИЩАЕТ:
- от повтора без перезапуска: журнал вызовов требует EMULATOR_STOP текущего PID ДО второго EMULATOR_START и второго набора; «фиктивный echo» и повтор на том же эмуляторе различаются журналом и rc;
- от подмены инкарнации чужим/старым устройством (критик, круг 1): мёртвый owned PID нового эмулятора при отвечающем serial — ни одного состояние-меняющего вызова после смерти в любой точке инкарнации (свип N точек, N из прогона) и именованный отказ; EMULATOR_START сам по себе инкарнацию не подтверждает; смерть после старта второго набора итог не маскирует;
- от повтора «чего попало»: 4 альтернативы канона; продуктовый провал, смешанный лог, пустой вывод, просроченный артефакт workspace, INSTALL_FAILED-текст — НЕ повторяются;
- от третьей попытки, от зелёного итога при втором красном, от стирания первой попытки (обе диагностики + финал одной попытки), от публикации кадров нефинальных попыток;
- от широких остановок: субъект обязан останавливать только owned PID; широкие завершатели по маске, разрыв сервера adb и переподключение офлайн запрещены и текстом, и журналом вызовов;
- от утечки секрета в новой диагностике: P редактирует все текстовые каналы обеих попыток, PNG не расширяют поиск финальных evidence (вершина maestro-out);
- от потери диагностики при зависании: exception-safe сбор (включая --timeout) до удаления приватного cwd, остановка собственного дерева процессов сессией.

НЕ ЗАЩИЩАЕТ:
- от первопричины обрыва (судьба qemu/adbd/ресурсы раннера): перезапуск — переживание, не лечение корня; различитель — первый причинный замер §10 в живом CI; общий adb-сервер и ANDROID_AVD_HOME двух раннеров остаются станции (решение владельца №6, после первого замера);
- от исполнения живых Maestro/эмулятора/avdmanager: replay подложен батарее; ловец — продуктовый CI (шаг 995 native) и один живой smoke на станции;
- от содержательной истинности классификации JUnit при незнакомом формате провалов Maestro (провал без текста канона в failure/error-сегменте трактуется продуктовым — fail-closed, повтор не даётся);
- от per-command таймаутов отдельных adb-вызовов внутри готовности (граница — wall-clock 390 с загрузки, итерационные потолки и внешний бюджет job/P);
- достижимое состояние НЕ ЗАКРЫТО автоматом: owned PID жив, но порт слушает чужой процесс (эмулятору не достался порт, а он не вышел) — serial отвечает чужой инкарнацией, kill -0 проходит; сверка owned PID с процессом, слушающим порт (ss/lsof), вне замкнутого алфавита модели и батареи, в replay не различима и в модель не внесена; остаток закрывается живой практикой: инвариант 9 публикует полный журнал эмулятора инкарнации (отказ привязки порта виден в нём) и guest boot_id/adbd_pid отвечающего устройства — разбор по диагностике живого CI;
- от дрейфа формы mobile.yml и чужих шагов (зона 141): батарея судит только mobile/scripts/ci-e2e.sh, P и их канон байт.
- от смерти owned PID между `kill -0` и самим действием (окно одного вызова): в shell неустранимо и субъектом не наблюдаемо; свип назначает смерть между вызовами инкарнации и это окно не предъявляет; ловец — диагностика инв. 9 (журнал эмулятора инкарнации, guest boot_id/adbd_pid) в живом CI.
- от смерти owned PID ПЕРВОЙ инкарнации до первого набора при чужом процессе на порту: проверка перед набором стоит только для повтора (n > 1) — тот же класс, вне спора v+1 (арбитраж 995 v2, Q1.5); цена закрытия — безусловная проверка перед каждым набором и свип поколения 1; v+2 или слово владельца.
- от субъекта, подогнанного под форму свипа (различающего точки по трассе батареи): в замкнутом PATH субъект k не знает; не форма честной реализации; ловцы — `kanon-bajt` (байт-равенство модели) и ревьюер.

ПРЕДПОСЫЛКИ:
- setting батарея самодостаточна: python3 и замкнутый PATH; без сети, gh, omp, эмулятора и SDK (режим --stabs).
- setting продуктовый CI ничего нового не требует: пин H (dev-harness на SHA заморозки), PRIVATE_FILE кода и APK уже обязательны шагом «Maestro runner для CMP-MOB-001»; новых секретов/variables/environments нет.
- setting budget --timeout P (по умолчанию 1800 с) не превышает timeout-minutes job android-e2e (40 мин); изменение лимитов — только с измерением.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»
- guard=fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh

ПРОВОДКА-ЭНФОРСМЕНТ: норма владельца «перезапуск собственного эмулятора и ровно один повтор полного набора в mobile/scripts/ci-e2e.sh по канонической сигнатуре обрыва adb-транспорта, продуктовый отказ не повторяется и не стирается, redacted диагностика обеих попыток; новая инкарнация подтверждается живым owned PID перед каждым состояние-меняющим вызовом инкарнации (свип смерти)» получает механический гейт: батарея красна на живом продукте без правки (22 входа, включая смерть нового owned PID при отвечающем stale serial — свидетель критика), зелена на моделях и матрице обманных стабов (SVJAZI 44, живых 0), судит байт-канон S и живого P. Режим CI харнесса — `--stabs` (без omp, сети и чужого checkout; ~76 с). Проводка self-test в registry/ci-steps.tsv/ci-zamery.tsv/ci.yml — интеграционный коммит ОРКЕСТРАТОРА в окне freeze..done (как 139/141); до ленда шаг CI несёт `--stabs` явно. Безфлаговый red-режим (`--repo <корень продукта>`) красен ДО байт-в-байт правки S; порча моделей/носителей/привязок — rc 2 ORACLE_TAMPERED.

## Отложенная продуктовая приёмка

- Android red на APK B, green на release APK C, PNG review и реальные PR jobs — NOT_RUN: C ещё не реализован, `adb devices -l` не показывает устройства. Это обязательная приёмка implementer/судей после freeze, не блокер авторской матрицы.
- Native runner исполняется командой `python3 fixtures/workshop_project/pilot_995/maestro_probe.py --device SERIAL --code-file PRIVATE_FILE --out NEW_OUT`; код читается из приватного файла, frozen flow запускается в приватном временном каталоге, stdout/stderr/XML/JSON перед публикацией редактируются по точному значению. Контрмодели доказывают этот путь без эмулятора; PNG требуют secureTextEntry и визуальной сверки на C. Прямой Maestro из §Приёмочный критерий описывает внутренний вызов runner, не разрешает upload сырых artifacts.
- Backend/IdP HTTP_REQUEST_RESPONSE, SQL_BEFORE_AFTER, PROVIDER_CALL_COUNT — NOT_RUN: mock-предмет не доказывает production auth/backend. Copy signoff остаётся владельцу.

## Фактический замер v+1 (restart)

Клон работы: harness `/tmp/dev-harness-verify/Architect995v2b/repo` (ветка wip/995/architect-v2d, один squash-коммит поверх main `72f7a7628`; база — OBJECT критика `8ae962ff6`), продукт read-only `…/Architect995v2b/mob` @ `52a5cf5468408c54fda96825cd93ad6ecdaa7c90` (голова PR #124; ci-e2e.sh sha256 `21715b69…ee7` — старый S). Числа из вывода команд этой пачки (исправление FAIL критика, вызов 1/2):

- W без флага → rc 1 SUBJECT_ABSENT, 29 KRASNO; `--repo` без субъекта → rc 1 SUBJECT_ABSENT (29 красных); `--repo` на живом продукте (старый S, новый P уже в дереве харнесса) → rc 1, 21 красный / 8 ok — в их числе новые входы оси «владение инкарнацией»: inkarnacija-mertva-na-starte и inkarnacija-mertva-pered-vtorym (старый S ставит APK и запускает второй набор — свидетель критика дословно), inkarnacija-mertva-vo-vtorom (rc 1: старый S вовсе без перезапуска).
- Свидетель критика на батарее: стаб `s-bez-zhizni` (модель критика «EMULATOR_START достаточен») на входе (а) → RC 0, `EMULATOR_STOP <новый PID>` ПЕРЕД `ADB_INSTALL rc=0` и `MAESTRO 2 rc=0`, RECOVERED True — форма «СЫРОЙ ВЫВОД ВЫПОЛНЕННОЙ АТАКИ» вердикта; прежняя модель (байты OBJECT `8ae962ff6`) на входах (а),(б) → rc 0 при ожидаемом 1 (красная).
- `W --model` → rc 0 29/29 ×3 подряд; `W --stabs` → rc 0, контроль 29/29, SVJAZI 41, живых 0 (~58 с, вместе с контролем --model тем же прогоном ~86 с); порча модели S / модели P / носителя → rc 2 ORACLE_TAMPERED (пин); stab_vhod: неизвестный вход → rc 2, пустые привязки → rc 2 «проверка исчезает» (проверка добавлена этой пачкой), чужой валидный вход → стаб ZHIV в `--stabs` → rc 1.
- Параллельная изоляция (СОВЕТ критика): СТАРАЯ батарея (HEAD `8ae962ff6`) — 5 раундов × 2 одновременных `--model`: 1 из 10 экземпляров rc 1 (раунд 2, vtoroj-krasnyj-produkt; в том прогоне p-timeout прошёл). Дефект реален; исправления раннера (не модели): (1) `pokolenie()` adb-стаба учитывает стартующего — форк есть, строки EMULATOR_START ещё нет — эмулятора (гонка fork→printf отдавала чужое поколение первому поколение-чувствительному adb-вызову готовности: класс p-timeout); (2) `sleep 1` (окно TERM→KILL остановки OWNED PID) — реальные 0.05 с вместо мгновенного: TERM-обработка эмулятора успевает дописать EMULATOR_STOP до KILL (класс vtoroj-krasnyj-produkt). НОВАЯ батарея: 10/10 rc 0, p-timeout ok в каждом экземпляре.
- Счёт кодом (source.json): kejsy 29 (s-replay 19, struktura 4, nositel 2, p-replay 4), stab_vhod 25 (S 20 / P 5), связей 41, канон сигнатур — 1 строка/1 вхождение в модели S; прежние 26 клеток и 23 стаба байт-неизменны (diff source.json — только добавления трёх клеток, двух привязок и пина модели).
- Соседние unchanged: `native_matrix.py --scratch` → rc 0 checked=16 (P не менялся); 141 `--stabs` → rc 0 SVJAZI 61; 139 `--stabs` → rc 0 SVJAZI 60; `git diff --name-only 72f7a7628..HEAD` — только contracts/995-…md и fixtures/workshop_project/pilot_995/.
- Гейты: pre_critic (--repo клон харнесса) rc 0 «дверь зелёная», PREDPOSYLKI_OK settings=3; precision rc 0 (клон обязан нести теги: `git fetch --tags`); spec_ready rc 0; ceilings rc 0; provodka rc 0 на копии с одной ci-steps-строкой `check:ci-e2e-restart-995-family-selftest` (вес 90, `--stabs`).
- НЕ проверено здесь: живой CI/эмулятор, frozen_matrix на живом продукте (нет node_modules в read-only клоне — среда, не регресс), серия ≥5 на новой голове — приёмка implementer/судей после freeze (§11 Astra: серия на одном новом head, оба раннера, 0 инфраструктурных красных после одного локального восстановления).
- Свип смерти (арбитраж `verdicts/arbitration/contracts-995-v2-arbitraz.md`, исполнение перечня A–F пачкой v2c поверх `814a71169`): клетка `inkarnacija-smert-svip` (boot поколения 2 «pozdno»); трасса `vyzovy` отдельным файлом, N выводится чистым replay. На новой модели `d8841d6b…` красных 0 (N=20 с «pozdno», N=18 без); на модели OBJECT `edb0cf0a…` (одноразовая копия, перепин) красные k=1..6 из N=20 с «pozdno» и k=1..4 из N=18 без — settings put на отвечающем чужом serial после смерти, находка арбитра (замер 4); ОРИГИНАЛЬНАЯ контрмодель критика 2/2 (байты `3d72a9ad…`, перепин) — красная ровно свип: 4 красных k=2..5 из N=18 без «pozdno» (замер 5 арбитража воспроизведён) и k=2..7 из N=20 с ним; применённая к НОВОЙ модели (`mutate995.py` + перепин) — красная ровно свип: k=7 (`settings put` → `adb install -r` после смерти); стабы `s-zhizn-ne-pered-nastrojkami`/`s-bez-zhizni` красны на первом k; N=0 (старый S, `--repo` @ `52a5cf5468`) — красная «нет второй инкарнации».

## Фактический замер авторской пачки

R=`/tmp/dev-harness-verify/architect995/mob`, P=`/tmp/dev-harness-verify/architect995/venv/bin/python`, F=`fixtures/workshop_project/pilot_995`. Read-only снимки c995 и репро критиков не изменялись. Логи scoped-прогонов — `architect995/*-r3.log`, сводка — `architect995/evidence-r3.json`.

- `python3 F/probe.py --repo R --matrix` → rc0, runs=18, mismatches=0; сохранены все исходные CASES/MUTANTS.
- `python3 F/runtime_probe.py --repo R --matrix` → rc0, runs=9, mismatches=0; honest проходит все CASES, env-code красен на SHIPPED_INVALID/auth-invalid. Прогон также имел унаследованный PILOT_DEMO_CODE.
- `python3 F/bundle_probe.py --repo R --matrix` → rc0, checked=3, mismatches=0, 52.5 s: honest зелён в обоих режимах, оба Metro-мутанта красны на своих режимах. `--repo R` на B → rc1 BUNDLE_SEAM_ABSENT. После проб `git status --short` в R пуст.
- `python3 F/frozen_matrix.py --repo R` → rc0, checked=3: оба имени CI-теста rc0/preserved=true; drift rc1 FROZEN_BYTES_MISMATCH.
- `P F/schema_probe.py --repo R --matrix` → rc0, checked=6: schema и runtime honest rc0; wrong-session/wrong-disclosure rc1 отдельно в данных и живом runtime при валидном файле.
- `python3 F/transport_probe.py --repo R --matrix` → rc0, checked=5: honest/alias rc0; fetch/global rc1 no-restricted-globals; bootstrap-mocks rc1 import/no-restricted-paths.
- `python3 F/native_matrix.py --scratch /tmp/dev-harness-verify/architect995` → rc0, checked=16, redaction=true; Android NOT_RUN. Frozen pilot.yaml теперь требует неверный код/auth-invalid/отсутствие F02 до очистки поля и верного кода.
- П5(в), неизменённый ESLint B: временный `src/mocks/type-proof.ts` с `import type { ApiClient } from '@/api/api-client'` → rc0; тот же файл с `../bootstrap/runtime-contract` → rc1 `import/no-restricted-paths`. Имена/формы интерфейса одинаковы; временные файлы восстановлены/удалены.
- П6: B (tsconfig types=["jest"] без node) + frozen pilot.test.tsx/source.json + model.tsx как pilot-app.tsx, `node node_modules/typescript/bin/tsc --noEmit` → rc0, TS2304 отсутствует. Frozen-тесты используют globalThis.
- C3 воспроизведён `critic995r2/make_r2.py H architect995/c3-r3 critic995r1/bypass/mobile/src/bootstrap/pilot-app.tsx` поверх копии B. `bundle_probe.py --repo architect995/c3-r3` → rc1 BUNDLE_HTTP_HAS_MOCKS/BUNDLE_HTTP_RUNTIME_ABSENT (18.5 s). `env PILOT_DEMO_CODE=synthetic-verification-value python3 F/runtime_probe.py --repo architect995/c3-r3` → rc1 SHIPPED_INVALID: auth-invalid отсутствует, F02.01 видим; остальные CASES rc0. Это также живой контроль удаления унаследованного оракула.
- Ранее предъявленные C′/C″: runtime_probe rc1 на SHIPPED_INVALID/HTTP_UNAVAILABLE/UNKNOWN_MODE/RUNTIME_RESPONSES, schema_probe rc1 RUNTIME_RESPONSES_MISMATCH. wrong-session из текущей матрицы дополнительно доказывает расхождение principal_ref при существующем alias binding.

Обязательные метагейты: `bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md` и `bash scripts/check_threat_model.sh . contracts/995-cmp-mob-001-android-pilot.md`; фактические rc в докладе. Они не заменяют предмет.

