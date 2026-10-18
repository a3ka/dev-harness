FAIL
OBJECT=cf3742d171a0c2a0c672edfbad7a8402c7201573
Предмет: contracts/995-cmp-mob-001-android-pilot.md (ветка wip/995/architect), фикстуры fixtures/workshop_project/pilot_995/. Критик, круг 1.
Источник требований: `gh issue view 5 --repo a3ka/Complior-mob` (тело прочитано). Снимки: Complior-mob B=f86eb28 (копия architect995/mob → critic995r1/mob), Complior-back f7b972913 (только чтение).

## Блокирующие находки

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:40,50 — ни одна команда приёмки не исполняет ОТГРУЖАЕМУЮ композицию дальше экрана ввода кода. Все 13 содержательных кейсов pilot.test.tsx подменяют auth/api своими портами; единственный кейс без портов (DEFAULT_OFFLINE) останавливается на `auth-code`. Поэтому «PilotApp подключает реальные AuthProvider/ApiClient», «без props выбирает реальный mock/http runtime» (:40), инвариант 1 (:32: ApiClient с типами OpenAPI 5.8.2, AuthProvider, EXPO_PUBLIC_API_MODE=mock|http, «HTTP не симулирует успешный вход») и заголовок issue #5 «…через ApiClient» не проверяются ничем.
ОБХОД (исполнен, не умозрение): C′ = копия B + `mobile/src/bootstrap/pilot-app.tsx` = фикстурный model.tsx (copy вписан строкой, ветви мутантов убраны, кнопки — JSX-компонент ради react-hooks lint), `mobile/src/app/index.tsx` реэкспортирует PilotApp, `mobile/src/mocks/pilot-responses.json` = примеры. Ни `src/api/`, ни `src/auth/`, ни чтения EXPO_PUBLIC_API_MODE нет; встроенный demoAuth.verify принимает ЛЮБОЙ код. Итог: probe.py --repo C′ rc0 (14/14 passed), schema_probe rc0, transport_probe rc0, npm run lint rc0, typecheck rc0, полный jest rc0. Одноразовый тест отгружаемой композиции на том же C′: `<PilotApp />` с кодом `obviously-wrong` → F02.01 без auth-invalid (то есть F03.V01 «неверный код… доступен без сервера» из «Ожидаемого результата» issue в приложении недостижим); EXPO_PUBLIC_API_MODE=http при падающем fetch → F02.01, fetch не вызван (HTTP симулирует вход); EXPO_PUBLIC_API_MODE=banana → F02.01 (STRUCTURE.md:164 «неподдерживаемое значение — ошибка configuration bootstrap»). pilot.yaml на таком APK [INFERENCE: эмулятора нет, не исполнено] проходит: любой PILOT_DEMO_CODE принимается, все testID/copy на месте.
Выход для автора: кейсы БЕЗ подменённых портов — default mock: правильный demo-код → F02.01 и неверный → auth-invalid без сессии (контракт обязан назвать, откуда берётся synthetic demo-код mock-рантайма); mode=http с недоступным транспортом → нет F02.01; неподдерживаемое значение → именованная ошибка конфигурации; и контрмодель «model.tsx как продукт» в MUTANTS с ожиданием rc1.

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:81 (+ :40, :83 «Добавление других файлов этих слоёв не разрешено») — зона implementer не содержит файлов, без которых предписанный STRUCTURE.md способ выбора mock-рантайма неосуществим, а ESLint B запрещает единственный оставшийся. STRUCTURE.md:163–167: Demo AuthProvider и mock ApiClient «целиком в src/mocks/», «никакой production source не импортирует src/mocks/», выбор — resolver alias Metro (`metro.config.js`, `src/bootstrap/http-runtime.ts`, `src/mocks/runtime.ts`); для Jest тот же alias требует moduleNameMapper (`mobile/package.json` key `jest` либо `jest.config.js`). Вне зоны: metro.config.js, package.json/jest.config.js, bootstrap/http-runtime.ts. Замер: `import … from '@/mocks/pilot-responses.json'` в src/bootstrap/pilot-app.tsx → ESLint rc1 `import/no-restricted-paths … Runtime mocks are isolated` (то же для относительного пути). Значит исполнитель решает сам: расширить зону молча, нарушить lint, или вписать demo-рантайм в bootstrap/pilot-app.tsx.
ОБХОД: третий путь — ровно C′ из находки выше: demo-рантайм внутри pilot-app.tsx, src/mocks/ мёртв, всё зелёное в зоне; это единственное lint-зелёное решение, которое зона оставляет.

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:36,52,63 — schema validation привязана к ФАЙЛУ `mobile/src/mocks/pilot-responses.json`, а не к данным, которые рантайм реально отдаёт; связь «рантайм читает этот файл» не проверяется ничем. Критерий issue «Проверка mock по OpenAPI отклоняет fixture с неправильным типом ответа» тем самым удовлетворяется проверкой мёртвого файла.
ОБХОД (исполнен): C″ = C′, где в отдаваемом рантаймом session `principal_ref` заменён на 42 (тот же тип-мутант, что wrong-session в матрице), pilot-responses.json валиден и не упоминается ни одним исходником (grep -c pilot-responses по src = 0 везде). schema_probe --repo C″ rc0 `995 schema checked=2`; probe.py rc0; tsc rc0.

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:50 против :63 — критерий «Дано: C; probe.py --repo R → rc0» несовместим с требованием «CI implementer добавляет frozen пилотные RNTL в bootstrap/__tests__/… frozen test bytes неизменны». Frozen pilot.test.tsx импортирует `./source.json` и `../pilot-app`, значит в C обязан лежать `mobile/src/bootstrap/__tests__/source.json`; probe.py:49–50 на его наличие падает до исполнения. Замер: frozen-копия как pilot-995.test.tsx + source.json → `995 INFRASTRUCTURE: OCCUPIED_TEST_PATH` rc2; переименование теста в pilot.test.tsx → тот же rc2 (дело в source.json).
ОБХОД: единственное дерево, где :50 даёт rc0, — C без пилотного RNTL. Тогда `npm test` в quality исполняет 2 старые suite/3 теста (замер на C′: «Test Suites: 2 passed… Tests: 3 passed»), `gh pr checks --required` rc0, а Работы 6 issue («добавить изолированные RNTL… сценарии пилота» в CI) не сделаны; ловится только чтением JUnit ревьюером. В обратном дереве (тест в C) H-проба на C не исполняется вовсе (rc2 = «INFRASTRUCTURE, не краснота»), а байтовое равенство закоммиченной копии с H механизма не имеет. Это противоречие вынудит менять критерий после раздачи — ровно класс дефекта, ради которого стоит этот гейт.

БЛОКИРУЕТ (норма AGENTS.md, правило 1, обход не требуется) contracts/995-cmp-mob-001-android-pilot.md:40,44 — «Это шов зависимости, НЕ отдельная тестовая реализация приложения» и «Фикстурный model.tsx … в PR не копируется» — правила без механизма и без пометки `cognitive-only` с остаточным риском. Обе нарушены C′ при зелёных командах (см. первую находку).

## Советы

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:63 — «Workflow получает H по immutable SHA»: SHA не назван. dev-harness публичен (`gh repo view` → PUBLIC), `actions/checkout` repository/ref осуществим; назвать SHA = коммит заморозки и тем же checkout сверять байты закоммиченных frozen test/source.json с H (cmp) — это закрывает и остаток четвёртой находки.
СОВЕТ fixtures/workshop_project/pilot_995/pilot.yaml:35–38 — после рестарта assertNotVisible по testID `invitation-accepted`/`business-command-replayed`, которых в предмете не существует ни в одном состоянии: шаг вакуумен, «нет автоматического повтора бизнес-команды» Maestro не доказывает (доказывает только RNTL REPLAY через порт). Либо утвердительная проверка состояния после рестарта, либо убрать это утверждение из :54.
СОВЕТ fixtures/workshop_project/pilot_995/probe.py:61 — после прогона в R остаётся пустой `mobile/src/bootstrap/__tests__/` (замер: появился в C′ после первого прогона); чистить, если создан пробой.
СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:26 — Splash в предмете, но ни pilot.yaml, ни RNTL его не наблюдают (cognitive через PNG); пометить cognitive-only явно.
СОВЕТ окружение: в клоне без тегов `pre_critic.sh` даёт rc1 `precision-гейт 043: реестр заморозок не читается: missing-remote`; после `git fetch --tags` rc0. Не дефект контракта; судьям клонировать с тегами.
СОВЕТ issue ↔ контракт: «смена адреса… старый адрес не получает продолжение» покрыт EMAIL_STALE; «resend и смена e-mail сохраняют управляемый путь» — RESEND_UNCONFIRMED доходит до F02.01, ок. Совместимость 991: start-screen/rehearsal RNTL на B и C′ зелёные; миграция start.yaml/rehearsal.yaml и rehearsal-evidence gate — только Android, NOT_RUN (эмулятора нет), оценена по тексту: сохраняет file `.maestro/rehearsal.yaml`, maestro_probe копирует .maestro в приватный cwd, путь `maestro-out/report.xml` и PNG-имена для rehearsal-evidence.sh совпадают.

## Проверено и чисто
- Н-39: проза связи «стаб↔ветвь» не несёт; :44 отсылает к MUTANTS в probe.py — соответствует.
- Норма 041: check_threat_model rc0 (ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 3).
- Норма 043: check_precision_gate rc0 (после fetch --tags).
- ПРОВОДКА: цитата присутствует дословно в roles/orchestrator.md:385; check_provodka rc0.
- ЗОНА implementer против STRUCTURE.md: bootstrap/pilot-app.tsx, bootstrap/__tests__/ (STRUCTURE:60, :148–149), features/onboarding/welcome-screen.tsx (F02 → onboarding, :111), navigation/pending-intent.ts (:61) — обоснованы; недостающее — вторая блокирующая находка.

## Сырой вывод (H = мой клон на OBJECT, R = /tmp/dev-harness-verify/critic995r1/mob, P = /tmp/dev-harness-verify/critic995r1/venv/bin/python, jsonschema 4.26.0)
```
$ python3 fixtures/workshop_project/pilot_995/probe.py --repo R --matrix
995 honest/<14 CASES>: rc=0 assertion=passed   (все 14)
995 start/DIRECT_unknown … 995 http-default/DEFAULT_OFFLINE: rc=1 assertion=failed   (все 17)
995 runs=18 mismatches=0
RC probe-matrix=0
$ P schema_probe.py --repo R --matrix
995 schema/honest: rc=0 reasons=[]
995 schema/wrong-session: rc=1 reasons=['MOCK_SCHEMA_INVALID:getSession']
995 schema/wrong-disclosure: rc=1 reasons=['MOCK_SCHEMA_INVALID:getDisclosure']
RC schema-matrix=0
$ python3 transport_probe.py --repo R --matrix
995 transport/honest: rc=0 rules=[] ; fetch: rc=1 ['no-restricted-globals'] ; global: rc=1 ['no-restricted-globals']
RC transport-matrix=0
$ python3 native_matrix.py --scratch /tmp/dev-harness-verify/critic995r1
995 native-runner checked=16 Android=NOT_RUN  (16 строк redacted=true; RC native-matrix=0)
$ probe.py --repo R (B)          → 995 PILOT_ABSENT … RC 1
$ schema_probe.py --repo R (B)   → MOCK_RESPONSES_ABSENT RC 1
$ transport_probe.py --repo R (B)→ RC 0

# C′ (make_bypass.py: model.tsx как продукт)
$ probe.py --repo C′             → 995 actual/<14 CASES>: rc=0 assertion=passed; 995 runs=1 mismatches=0; RC 0
$ schema_probe.py --repo C′      → 995 schema checked=2; RC 0
$ transport_probe.py --repo C′   → RC 0
$ (mobile) npm run -s lint       → structure: OK …; RC 0
$ (mobile) npm run -s typecheck  → RC 0
$ (mobile) jest --ci --runInBand → Test Suites: 2 passed; Tests: 3 passed; RC 0
$ (mobile) jest critic-shipped.test.tsx (одноразовый, удалён)
  ✓ SHIPPED_MOCK_wrong_code_reaches_F02
  ✓ SHIPPED_HTTP_mode_simulates_login
  ✓ UNSUPPORTED_mode_not_an_error
# ESLint bootstrap → mocks
$ printf "import responses from '@/mocks/pilot-responses.json'…" | eslint --stdin --stdin-filename src/bootstrap/pilot-app.tsx
  error  Unexpected path "@/mocks/pilot-responses.json" imported in restricted zone. Runtime mocks are isolated; … import/no-restricted-paths   rc=1
# frozen CI test в C′
$ cp pilot.test.tsx → bootstrap/__tests__/pilot-995.test.tsx; cp source.json → bootstrap/__tests__/source.json
  jest: Test Suites: 3 passed; Tests: 17 passed
$ probe.py --repo C′ → 995 INFRASTRUCTURE: OCCUPIED_TEST_PATH  RC 2   (и при имени pilot.test.tsx — RC 2)
# C″ (runtime principal_ref=42, pilot-responses.json не читается)
$ probe.py → 995 runs=1 mismatches=0 RC 0 ; schema_probe → 995 schema checked=2 RC 0 ; tsc RC 0
# метагейты (H, после git fetch --tags)
$ bash scripts/pre_critic.sh --repo . contracts/995-…md → КРИТИК: дверь зелёная  RC 0
$ bash scripts/check_precision_gate.sh . contracts/995-…md → OK RC 0
$ bash scripts/check_threat_model.sh . contracts/995-…md → модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов)) RC 0
$ bash scripts/check_provodka.sh . contracts/995-…md → RC 0
# scoped-регресс барьеров
$ git diff --name-only e7247cd9 HEAD → только contracts/995-…md и fixtures/workshop_project/pilot_995/* (ни одного барьерного ключа check_*)
$ bash scripts/scope_select.sh . --changed e7247cd9 → SCOPED: не для приёмки / MODE: full
$ bash scripts/scope_select.sh . --scope workshop_project → неизвестный ключ workshop_project rc=1
  Scoped-прогона нет: барьеры не задеты, полный гейт — CI. Нечаянно стартовавший полный verify_antiplacebo (--changed) прерван мной на 215 с (RC 143); до прерывания видны FAIL вне предмета 995: check_merge_gate.sh «нет фикстур», check_metering/case_a_proxy_up_healthz.sh «таймаут 120 с» — к контракту отношения не имеют, не засчитаны.
```
Репро: /tmp/dev-harness-verify/critic995r1/make_bypass.py (C′ = `python3 make_bypass.py dh bypass` + lint-правка кнопок), копия C′/C″ — /tmp/dev-harness-verify/critic995r1/bypass.
Native/Android не исполнялись: эмулятора нет (по Constraints).
