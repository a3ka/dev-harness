# Контракт 995 — CMP-MOB-001: Android-пилот e-mail/код → F02.01

КЛАСС: КОДОВЫЙ. Авторский контракт; НЕ ГОТОВ к critic/freeze, пока не закрыт §Незаполненные требования. Продолжает a3665a569, не меняет предмет issue #5.

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
- `.github/workflows/mobile.yml` уже запускает quality (npm test/lint/typecheck/doctor), затем release APK и API36 Maestro. `.maestro/` уже несёт start/rehearsal. Их обязательность сохраняется; пилот добавляется, а не выключает прежний CI.
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

Публичный React composition `PilotApp` подключает реальные AuthProvider/ApiClient и экран; принимает необязательные auth/api/entry порты из `pilot.test.tsx`, без props выбирает реальный mock/http runtime. Это шов зависимости, НЕ отдельная тестовая реализация приложения. Root route должен использовать ту же композицию. Место composition подчиняется STRUCTURE.md; окончательное расширение зоны/путь — §Незаполненные требования. Текущий раннер ожидает экспорт `mobile/src/features/auth/pilot-app.tsx`; при выборе bootstrap меняется только import seam перед freeze, не assertions.

Auth порт: begin(email) → challenge/evidence; verify(challenge,code) → authenticated|invalid|stale|revoked|missing_scope; resend(challenge) → confirmed/evidence/optional retryAfterSeconds; recover() → unavailable либо подтверждённый исход. Это локальный DI-контракт пилота, не wire-контракт IdP. Api порт несёт getSession/getDisclosure и запрещённый в этом срезе execute; entry DIRECT, onboarding unknown/incomplete и opaque pendingIntent. Реализация не должна создавать production endpoint из этих имён.

TestIDs в RNTL/Maestro — automation-семантика, НЕ новые route/action IDs. Фикстурный model.tsx — только интерактивная контрмодель для испытания теста, в PR не копируется. Байты pilot.test.tsx/source.json/pilot.yaml берутся из H; subject не назначает себе ожидания. Матрица привязывает обманки к наблюдаемым ветвям только в probe.py.

## Приёмочный критерий

R — disposable копия Complior-mob C под /tmp/dev-harness-verify с npm ci; P — Python с jsonschema==4.26.0; H — принятый харнесс. Отсутствие инструмента/пустой Jest report = rc2 INFRASTRUCTURE, не краснота предмета. Команды исполняются из H, кроме явно названного mobile cwd.

- Дано: B без композиции; когда: `python3 fixtures/workshop_project/pilot_995/probe.py --repo R`; тогда: rc1 PILOT_ABSENT. Дано: C; та же команда → rc0, все CASES исполнены. Каждый DIRECT, invalid, resend, change-email, recovery, stale/revoked/missing-scope, secret, replay, default-offline имеет собственный assertion. Парные положительные и отрицательные состояния находятся в сценариях, а не в прозе о заглушках.
- Дано: независимые интерактивные модели; когда: `python3 fixtures/workshop_project/pilot_995/probe.py --repo R --matrix`; тогда: rc0 только при совпадении всех кодовых ожиданий, каждый красный результат несёт свою причину. Отдельный запуск: `--model M --case K` возвращает фактический rc теста; список M/K и причин — MUTANTS в probe.py.
- Дано: реальные runtime mock C; когда: `P fixtures/workshop_project/pilot_995/schema_probe.py --repo R`; тогда: rc0 для обеих схем, rc1 MOCK_SCHEMA_INVALID:<operation> для неправильного типа либо MOCK_RESPONSES_ABSENT. Дано: согласованные примеры и их type mutations; `P fixtures/workshop_project/pilot_995/schema_probe.py --repo R --matrix` → rc0, независимое различение каждого ответа. Исходная схема и её hash снимаются до субъекта; дрейф источника → rc2 SCHEMA_SOURCE_CHANGED.
- Дано: экраны C; когда: `python3 fixtures/workshop_project/pilot_995/transport_probe.py --repo R`; тогда: rc0, прямой fetch/global.fetch → rc1 no-restricted-globals. `--matrix` → rc0 при подтверждённом положительном контроле и предметных отказах существующего правила. Полный npm lint/typecheck остаётся обязательным CI, локальная проба его не заменяет.
- Дано: установленный release APK C, mock-режим и synthetic demo-code вне лога; когда: `maestro --device SERIAL test --format junit --output OUT/report.xml --test-output-dir OUT fixtures/workshop_project/pilot_995/pilot.yaml`; тогда: rc0, cold launch/ввод/F02.01/restart, pilot-first-run/pilot-welcome/pilot-restart PNG. Парный негатив: прежний APK B → ненулевой rc на отсутствии first-run-continue; parser/SDK/эмуляторная ошибка не засчитывается. Code передаётся окружением PILOT_DEMO_CODE, до публикации text/XML/log artifacts редактируются по точному значению; PNG не должны показывать полный код. Native прогон и screenshot review обязательны после реализации; модель не выдаётся за Android.
- Дано: C в PR; когда: `gh pr checks PR --repo a3ka/Complior-mob --required` и reviewer сверяет jobs/run logs/JUnit; тогда: rc0 и фактически исполненные quality/android-e2e, все пилотные assertions, schema validation и flow. Парный негатив: skipped/continue-on-error/неисполненный тест/отсутствующий PNG/APK → отказ приёмки с именем свидетельства. Cognitive-only: сверка effective workflow и immutable H-пинов, ловец reviewer. Никакой placeholder guard-registration в dev-harness CI.
- Дано: RNTL/Maestro synthetic trace; когда: reviewer сверяет UX175-F03.A01/F03.A02; тогда: no commit/replay, stale/revoked, intent проверены, статус SYNTHETIC. Без HTTP_REQUEST_RESPONSE/SQL_BEFORE_AFTER/PROVIDER_CALL_COUNT соответствующего SWITCH/backend — backend NOT_RUN. Парный негатив: запись backend PASS на одном mock → отказ BACKEND_EVIDENCE_MISSING. Cognitive-only, ловец reviewer.
- Дано: авторская пачка; когда: `bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md`; тогда: rc0 до вызова critic. Предметные прогоны и их реальные rc приложены отдельно; rc0 метагейта не заменяет их.

## Пины и порядок поставки

Оркестратор до реализации записывает append-only в issue #5 H/B/S, профиль/ContextPack и hashes source.json. Затем critic → freeze → implementer → один PR C → настоящий эмулятор → adversary/reviewer → доклад владельцу, БЕЗ merge. Новый C требует новых доказательств. Для каждого run: checkout/tree T (не автоматически C), SDK/AVD/Maestro, run/attempt, APK/JUnit/PNG artifact IDs и SHA256. Судьи снимают ожидания H в память до кода PR. Дизайн/сходство со Splash/First-Run и немецкий copy — cognitive-only, reviewer сверяет источник и PNG; signoff остаётся владельцу, не объявляется агентом.

CI implementer добавляет пилотные RNTL в auth __tests__, schema validator в mocks и Python setup/install/вызов в quality либо эквивалентный уже установленный schema runtime без расширения зависимостей; frozen test bytes и исходные схемы неизменны. `.maestro/pilot.yaml` потребляется уже существующим обходом flows. Прежние start/rehearsal сценарии и checks не ослабляются. Невозможность сохранить прежний вход Start без изменения вне зоны — отдельный явный конфликт допуска, не удаление теста.

## Зоны и исполнители

ЗОНА architect: contracts/995-cmp-mob-001-android-pilot.md fixtures/workshop_project/pilot_995/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/pilot_995/ — 105 новый подкаталог существующей architect-зоны; чужие файлы не меняются.

Следующая строка дословно сохраняет целевые пути issue от корня Complior-mob, НЕ от dev-harness:

ЗОНА implementer: mobile/src/app/ mobile/src/features/auth/ mobile/src/api/ mobile/src/auth/ mobile/src/mocks/ mobile/.maestro/ .github/workflows/mobile.yml

Новые package/test-config зависимости не требуются: существующие Jest/RNTL достаточны. api/docs/design read-only, mobile-cloud-e2e и настройки GitHub вне зоны. Расширение зоны до structural composition обсуждается явно ниже, не разрешено строкой интерфейса.

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

## Незаполненные требования

- Structural zone conflict: issue не выделяет bootstrap (composition), features/onboarding (F02), navigation (pending-intent), хотя STRUCTURE.md закрепляет их владельцами. Запрошено решение оркестратора до freeze; молча переносить всё в auth запрещено. До разрешения — не раздавать реализацию.
- Native Android red/green и actual C ещё NOT_RUN: это обязательная приёмка implementer/судей, не результат авторской модели. ФОРК владельца: copy-signoff/риск/деньги не решаются этой пачкой.
- Полная native-защита артефактов от кода требует подтверждённого способа redaction Maestro перед upload; `maestro_probe.py --device SERIAL --code-file PRIVATE_FILE --out NEW_OUT` запускает те же frozen flow bytes в приватном временном каталоге и публикует только отредактированные текстовые artifacts. Код не печатается. PNG требуют secureTextEntry и визуальной сверки. Сам native runner пока NOT_RUN, не доказательство защиты.

## Фактический замер авторской пачки

`bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md` → rc0, `КРИТИК: дверь зелёная`. Это метагейт, не разрешение обойти незавершённые предметные прогоны.

`python3 fixtures/workshop_project/pilot_995/probe.py --repo /tmp/dev-harness-verify/c995/mob` → rc1, `995 PILOT_ABSENT: real composition seam is not implemented`. Отсутствие субъекта проверяется до любой записи в read-only snapshot.

Сверка `capture.capture(mob, back) == json.loads(source.json)` выполнена → rc0, hashes match. Матрицы RNTL/schema/transport, native runner — NOT_RUN: npm не запускался после обнаружения существующего родительского scratch-каталога. Созданная копия расположена `/tmp/dev-harness-verify/architect995/mob`; STOP-045 сообщён оркестратору, запрошено подтверждение маршрута. Python окружение не имеет jsonschema; requirements.txt фиксирует необходимую зависимость для разрешённого scratch/CI. Нельзя объявлять эти непрогнанные модели честными или красными по одному их тексту.
