FAIL
OBJECT=a60dfde5370ffd66f0f4faf15aecd956758143af
Предмет: contracts/995-cmp-mob-001-android-pilot.md (ветка wip/995/architect) + fixtures/workshop_project/pilot_995/. Критик, круг 2.
Клон H: /tmp/dev-harness-verify/critic995r2/dh (ssh-клон, `git fetch --tags`, checkout OBJECT). Снимки: Complior-mob B=f86eb28 (копия architect995/mob → critic995r2/mob, node_modules оттуда), Complior-back f7b972913 (только чтение). P = critic995r2/venv/bin/python (jsonschema 4.26.0). Требования: `gh issue view 5 --repo a3ka/Complior-mob` (тело прочитано).

## Закрытие блокеров круга 1

1. «Ни одна команда не исполняет отгружаемую композицию» — ЗАКРЫТ для Jest-пути. runtime_probe грузит настоящий `app/index` без props; C′ (make_bypass.py r1) теперь rc1: SHIPPED_INVALID/HTTP_UNAVAILABLE/UNKNOWN_MODE/RUNTIME_RESPONSES красны. Остаток (ApiClient/AuthProvider/типы и выбор Metro) — Б1 и Б3 ниже.
2. Зона без файлов STRUCTURE.md:166 — ЗАКРЫТ. :88 добавляет metro.config.js, jest.config.js, package.json, tsconfig.json, bootstrap/http-runtime.ts, bootstrap/runtime-contract.d.ts — ровно пути STRUCTURE.md:166 (alias Metro → mocks/runtime.ts | bootstrap/http-runtime.ts, тип вне mock). Замер: обход C3 ниже собран ТОЛЬКО в этих путях, lint rc0 — зона осуществима.
3. Schema привязана к мёртвому файлу — ЗАКРЫТ. C″ (runtime principal_ref=42, валидный pilot-responses.json) → schema_probe rc1 `RUNTIME_RESPONSES_MISMATCH`; schema --matrix различает тип-мутанты в файле и в живом runtime.
4. probe.py несовместим с frozen CI-тестом — ЗАКРЫТ. `--check-frozen` на C3 с frozen-копиями rc0; frozen_matrix rc0 (оба имени preserved=true, drift rc1 FROZEN_BYTES_MISMATCH); после проб R чист (`git status` пуст на mob-p/r/s/t/f; пустой `__tests__/` больше не остаётся).
5. Правило 1 для «не отдельная тестовая реализация»/«model.tsx не копируется» — ЗАКРЫТ: :48 помечает оба запрета cognitive-only, остаточный риск и ловец (reviewer) записаны. Новые правила без механизма — в Б1/Б2/Б3.

## Блокирующие находки

Все три обхода исполнены на одном дереве C3 = `python3 critic995r2/make_r2.py critic995r2/dh C3 critic995r1/bypass/mobile/src/bootstrap/pilot-app.tsx` поверх копии B. C3 трогает только пути ЗОНЫ implementer (:88): package.json (снят inline jest), app/index.tsx, tsconfig.json (paths `@pilot/runtime` → runtime-contract.d.ts, types +node), jest.config.js (выбор по EXPO_PUBLIC_API_MODE), metro.config.js, bootstrap/{pilot-app.tsx, http-runtime.ts, runtime-contract.d.ts, __tests__/pilot.test.tsx + source.json = байты H (cmp rc0)}, mocks/{runtime.ts, demo-code.ts, pilot-responses.json}. pilot-app.tsx — честная композиция пробы (ветви мутантов сняты, порты по умолчанию = `runtime` из alias); дефекты Б1/Б2 живут ВНЕ неё и от неё не зависят. На C3 ВСЕ команды критерия, исполнимые без эмулятора, зелёные: probe.py --check-frozen rc0 (14/14), runtime_probe rc0 (6/6), schema_probe rc0 `runtime=matched`, transport_probe rc0, npm lint rc0, typecheck rc0, npm test rc0 (3 suites/17 tests).

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:42 (+ :59, :68; против Complior-mob STRUCTURE.md:171) — «Metro выбирает `src/mocks/runtime.ts` либо `src/bootstrap/http-runtime.ts`» не проверяет ни одна команда. runtime_probe исполняет только jest.config.js; Maestro (:59) — только release APK с mock; HTTP-сборки не собирает никто. STRUCTURE.md:171 прямо: «На внедрении runtime seam обязателен отдельный HTTP export/bundle graph check и сценарий HTTP без доступного mock» — контракт ссылается на :163–167 и эту строку обходит.
ОБХОД (исполнен): C3, metro.config.js отдаёт `@pilot/runtime` → `src/mocks/runtime.ts` в ОБОИХ режимах, jest.config.js выбирает верно. Все команды зелёные (см. выше). `EXPO_PUBLIC_API_MODE=http npx expo export --platform android --source-maps` → граф бандла (bundle_graph.py): `src/mocks/demo-code.ts`, `src/mocks/runtime.ts`, mocks-in-graph=2, http-runtime-in-graph=0; маркеры текста бандла: mock verify 1, `"SYNTHETIC"` 1, `evidence: "HTTP"` 0. HTTP-сборка — Demo AuthProvider, принимающий вход (STRUCTURE.md:165/167 «никакой production source не импортирует src/mocks/ в обоих режимах» нарушено, инвариант :32 mode=http не сделан).
Выход для автора (механизм измерен, ~10 с на режим, без эмулятора): пункт критерия «HTTP export → в графе source map нет `src/mocks/`, есть `src/bootstrap/http-runtime.ts`; mock export → наоборот». На C3 он красен; с честным metro (critic995r2/honest_metro.js) — http: mocks=0/http-runtime=1, mock: mocks=2/http-runtime=0.

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:44 (+ fixtures/workshop_project/pilot_995/runtime_probe.py:99, runtime.test.tsx:18, pilot.yaml:17–22) — «Mock demo-code в `src/mocks/demo-code.ts` равен synthetic `secret`» не проверяется ничем, а «runtime_probe передаёт его только тесту» ложно: runtime_probe.py:99 кладёт `PILOT_DEMO_CODE` в env ВСЕГО Jest-процесса, субъект читает его так же, как тест. Оракул подан субъекту — это ровно то, от чего ЗАЩИЩАЕТ-пункт «от подмены ожиданий диском субъекта» обещает защиту. Maestro (pilot.yaml) вводит только верный код.
ОБХОД (исполнен): C3, `mocks/demo-code.ts` = `export const DEMO_CODE = process.env.PILOT_DEMO_CODE`, mock verify = `DEMO_CODE === undefined || code === DEMO_CODE`. Под пробой env задан → SHIPPED_INVALID rc0, всё зелёное. Expo инлайнит только `EXPO_PUBLIC_*`: export с `PILOT_DEMO_CODE=synthetic-verification-value` в окружении сборки → в бандле `process.env.PILOT_DEMO_CODE` 1 раз, литерал кода 0 раз — на APK значение undefined. Одноразовый critic-apk.test.tsx (корень без props, env без PILOT_DEMO_CODE): `definitely-wrong-000` → F02.01 видим, auth-invalid нет, ✓ rc0. Значит на отгружаемом Android неверный код создаёт сессию (issue «Неверный код… доступны без сервера», :33 F03.V01), а pilot.yaml с верным кодом rc0.
Почему это не покрыто cognitive-only :48: та пометка относится к «двум запретам» — копии model.tsx/runtime-model.ts и отдельной тестовой реализации композиции. C3 не копия и не ветка композиции: это mocks/-конфигурация, которая читает переменную, поданную самой пробой, и правило :44, у которого нет ни механизма, ни пометки (AGENTS.md правило 1). Выход дешёвый: runtime.test.tsx берёт код литералом, как pilot.test.tsx:8, и runtime_probe НЕ передаёт PILOT_DEMO_CODE субъекту; плюс шаг pilot.yaml «неверный код → assertVisible auth-invalid → assertNotVisible F02.01» до верного — он ловит любое test-env ветвление этого свойства на самом APK.

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:32 (+ :40, :44 «интерфейсы — auth/api», issue Работа 1) — «ApiClient использует типы OpenAPI 5.8.2; AuthProvider отделяет identity от HTTP», «F03 остаётся features/auth, F02 — features/onboarding» не доказывает ни одна команда и не помечены cognitive-only. runtime_probe проверяет поведение объекта `runtime`, schema_probe — значения; ни то ни другое не видит, есть ли ApiClient и откуда его типы.
ОБХОД (исполнен): в C3 нет `src/api/`, `src/auth/`, `features/auth/`, `features/onboarding/` вообще (`find c3/mobile/src -type f`: только app/, bootstrap/, features/start/, mocks/); тип runtime в runtime-contract.d.ts — `Promise<unknown>`. typecheck rc0, lint rc0 (structure: OK), все пробы rc0. Работа 1 issue («Ввести ApiClient с типами OpenAPI 5.8.2 и AuthProvider») не сделана.
Выход для автора: либо механизм (tsc-проба, ставящая в R сниппет `import type { ApiClient } from '@/api/api-client'` с ожиданием, что `getSession()` возвращает сгенерированный `Session`: позитивный сниппет rc0, `principal_ref: 42` — rc≠0 TS2322; плюс отсутствие файла → rc1), либо явная cognitive-only пометка с остаточным риском «ApiClient/AuthProvider/раскладка по слоям не проверены механически» и ловцом reviewer.

АРБИТР: roles/arbiter.md — второй FAIL по одной причине (круг 1, блокер 1: инвариант :32 ApiClient/AuthProvider/EXPO_PUBLIC_API_MODE не исполняется отгружаемой композицией). Предмет спора: достаточно ли Jest-исполнения `@pilot/runtime` (runtime_probe) для :32/:42/:44, или требуется (а) bundle-graph проверка выбора Metro по STRUCTURE.md:171, (б) снятие оракула демо-кода из env субъекта и device-шаг неверного кода, (в) tsc-проба ApiClient/OpenAPI-типов — либо явные cognitive-only пометки вместо (в). Обходы исполнены на C3, репро в critic995r2/.

## Советы

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:42 — «Общий тип — `src/bootstrap/runtime-contract.d.ts`»: ESLint B запрещает mocks импортировать bootstrap. Замер на C3 (первая сборка): `src/mocks/runtime.ts 1:35 error Unexpected path "../bootstrap/runtime-contract" … Lower layers cannot depend on screens/composition import/no-restricted-paths`. Значит mock runtime не может быть типизирован контрактом, и tsc не сверяет его форму. STRUCTURE.md:167 разрешает mocks импортировать «общие API/auth-типы» — держать интерфейсы в src/api, src/auth, а d.ts только реэкспортирует. Решение сейчас молча оставлено исполнителю.
СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:68 / fixtures/workshop_project/pilot_995/pilot.test.tsx:127–138 — frozen байты не проходят `tsc --noEmit` на tsconfig B (`types: ["jest"]`): копия B + frozen pilot.test.tsx/source.json + model.tsx → `TS2304: Cannot find name 'global'` ×4, rc2. Quality требует typecheck, а байты менять нельзя. Исполнитель вынужден решать сам (добавить "node" в types — @types/node стоит; так и сделано в C3 — или исключить файл). Назвать решение в :90 либо в frozen-тесте писать `globalThis`.
СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:42,90 — ссылка «STRUCTURE.md:163–167» короче нормы: обязательная «Граница доказательства» стоит в :171 (см. Б1).
СОВЕТ fixtures/workshop_project/pilot_995 — synthetic-код записан трижды: pilot.test.tsx:8, runtime_probe.py:75, probe.py:95 (редакция). Один источник снимает риск расхождения редакции.
СОВЕТ окружение: Н-85-страж bash отклоняет команды с литералами `'<rootDir>/…'`, `2>/dev/null`, `'/src/' in x` как запись в чекаут (ложное срабатывание, отправлено в xd://report_issue). На суть не влияет.

## Проверено и чисто
- Н-39: :48 «Матрицы привязывают обманки к наблюдаемым ветвям только в коде probe.py/runtime_probe.py» — проза пар не утверждает.
- Правило 1: :48 и :76 — cognitive-only с остаточным риском и ловцом; :60, :61 — тоже. Нарушения правила 1 — только в Б2 (:44) и Б3 (:32, :40).
- Норма 041: check_threat_model rc0 (ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 3). Смысловая граница: ЗАЩИЩАЕТ-пункт про подмену ожиданий нарушен каналом env (Б2).
- Норма 043: check_precision_gate rc0.
- ПРОВОДКА: check_provodka rc0; :107–112 опирается на действующую норму roles/orchestrator.md, внешние пробы guard-каналами не объявлены — честно на текущем check_provodka.
- ЗОНА: implementer-пути :88 совпадают со STRUCTURE.md:166; ПЕРЕСЕЧЕНИЕ architect объявлено.
- Scoped-регресс: `git diff --name-only e7247cd9 HEAD` — только contracts/995-…md и fixtures/workshop_project/pilot_995/* (16 файлов), барьерного ключа нет; `scope_select.sh --changed` → `MODE: full`. Полный verify_antiplacebo не гонялся (по Constraints).
- Android/device-режим не исполнялся: эмулятора нет.

## Сырой вывод (H = critic995r2/dh на OBJECT, F = fixtures/workshop_project/pilot_995)
```
# матрицы на копиях B (mob-p/r/s/t/f, native)
$ python3 F/probe.py --repo mob-p --matrix
995 honest/<14 CASES>: rc=0 assertion=passed ; 995 <17 MUTANTS>: rc=1 assertion=failed
995 runs=18 mismatches=0                       RC probe-matrix=0
$ python3 F/runtime_probe.py --repo mob-r --matrix
995 runtime/honest/{SHIPPED_INVALID,SHIPPED_VALID,DEFAULT_VALID,HTTP_UNAVAILABLE,UNKNOWN_MODE,RUNTIME_RESPONSES}: rc=0
995 runtime/{copied-model,any-code}/SHIPPED_INVALID: rc=1 ; http-demo/HTTP_UNAVAILABLE: rc=1 ; ignore-mode/UNKNOWN_MODE: rc=1
995 runtime/{bypass-ports,wrong-session,wrong-disclosure}/RUNTIME_RESPONSES: rc=1
995 runtime runs=8 mismatches=0                RC runtime-matrix=0
$ P F/schema_probe.py --repo mob-s --matrix
995 schema/honest rc=0 ; wrong-session rc=1 ['MOCK_SCHEMA_INVALID:getSession'] ; wrong-disclosure rc=1 ['MOCK_SCHEMA_INVALID:getDisclosure']
995 schema/runtime-honest rc=0 ; runtime-wrong-session rc=1 ; runtime-wrong-disclosure rc=1 (fixture_schema=valid)
995 schema checked=6                           RC schema-matrix=0
$ python3 F/transport_probe.py --repo mob-t --matrix
honest rc=0 ; fetch rc=1 no-restricted-globals ; global rc=1 no-restricted-globals ; runtime-alias rc=0 ; bootstrap-mocks rc=1 import/no-restricted-paths
995 transport checked=5                        RC transport-matrix=0
$ python3 F/frozen_matrix.py --repo mob-f
995 frozen/pilot.test.tsx: rc=0 preserved=true ; 995 frozen/pilot-995.test.tsx: rc=0 preserved=true ; 995 frozen/drift: rc=1 FROZEN_BYTES_MISMATCH:pilot.test.tsx
995 frozen checked=3                           RC frozen-matrix=0
$ python3 F/native_matrix.py --scratch critic995r2/native
995 native-runner checked=16 Android=NOT_RUN   RC native-matrix=0
$ git status --short в mob-p mob-r mob-s mob-t mob-f → пусто

# повтор обходов круга 1
$ python3 critic995r1/make_bypass.py dh cprime ; python3 critic995r2/make_c2.py cdprime   (C″ = C′ + runtime principal_ref=42)
C′:  runtime_probe → SHIPPED_INVALID rc=1, SHIPPED_VALID 0, DEFAULT_VALID 0, HTTP_UNAVAILABLE 1, UNKNOWN_MODE 1, RUNTIME_RESPONSES 1   RC 1
     schema_probe  → RUNTIME_RESPONSES_MISMATCH                                                                                     RC 1
C″:  runtime_probe → то же                                                                                                          RC 1
     schema_probe  → RUNTIME_RESPONSES_MISMATCH                                                                                     RC 1

# обход C3 (Б1, Б2, Б3)
$ python3 critic995r2/make_r2.py dh c3 critic995r1/bypass/mobile/src/bootstrap/pilot-app.tsx → C3 written
$ python3 F/probe.py --repo c3 --check-frozen   → 995 actual/<14 CASES>: rc=0 assertion=passed ; 995 runs=1 mismatches=0   RC 0
$ python3 F/runtime_probe.py --repo c3          → 995 runtime/actual/<6 CASES>: rc=0                                           RC 0
$ P F/schema_probe.py --repo c3                 → 995 schema checked=2 runtime=matched                                          RC 0
$ python3 F/transport_probe.py --repo c3        →                                                                               RC 0
$ (c3/mobile) npm run -s lint                   → structure: OK                                                                 RC 0
$ (c3/mobile) npm run -s typecheck              →                                                                               RC 0
$ (c3/mobile) npm test                          → Test Suites: 3 passed, 3 total ; Tests: 17 passed, 17 total                   RC 0
$ cmp F/{pilot.test.tsx,source.json} c3/mobile/src/bootstrap/__tests__/… → rc=0 ×2
$ find c3/mobile/src -type f → app/_layout.tsx app/index.tsx bootstrap/__tests__/{pilot.test.tsx,source.json} bootstrap/{http-runtime.ts,pilot-app.tsx,runtime-contract.d.ts} features/start/… mocks/{demo-code.ts,pilot-responses.json,runtime.ts}
# Б1: Metro (копия c3x)
$ EXPO_PUBLIC_API_MODE=http npx expo export --platform android --source-maps --clear → Exported RC 0
$ python3 critic995r2/bundle_graph.py export-http-map → src/app/_layout.tsx src/app/index.tsx src/bootstrap/pilot-app.tsx src/mocks/demo-code.ts src/mocks/runtime.ts ; mocks-in-graph=2 http-runtime-in-graph=0
$ python3 critic995r2/bundle_markers.py export-http export-mock   (--no-bytecode)
export-http: mock-verify 1 ; "SYNTHETIC" 1 ; evidence: "HTTP" 0 ; process.env.PILOT_DEMO_CODE 1 ; literal code 0
export-mock: mock-verify 1 ; "SYNTHETIC" 1 ; evidence: "HTTP" 0 ; process.env.PILOT_DEMO_CODE 1 ; literal code 0
# контроль механизма: c3y = c3 + critic995r2/honest_metro.js
$ export http → mocks-in-graph=0 http-runtime-in-graph=1 ; export mock → mocks-in-graph=2 http-runtime-in-graph=0
# Б2: APK-окружение (c3x, одноразовый тест)
$ env -u PILOT_DEMO_CODE EXPO_PUBLIC_API_MODE=mock npx jest --ci --runInBand src/bootstrap/critic-apk.test.tsx
  ✓ APK_ENV_wrong_code_reaches_F02 ; Tests: 1 passed, 1 total   RC 0
# совет про frozen typecheck (tsc-b = B + frozen test/source + model.tsx как pilot-app)
$ (tsc-b/mobile) npx tsc --noEmit → src/bootstrap/__tests__/pilot.test.tsx(127,22)/(129,5)/(136,14)/(138,7): error TS2304: Cannot find name 'global'.   RC 2
# метагейты (H, после git fetch --tags)
$ bash scripts/pre_critic.sh --repo . contracts/995-…md        → КРИТИК: дверь зелёная   RC 0
$ bash scripts/check_threat_model.sh . contracts/995-…md        → модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))   RC 0
$ bash scripts/check_precision_gate.sh . contracts/995-…md      → OK   RC 0
$ bash scripts/check_provodka.sh . contracts/995-…md            → RC 0
$ git diff --name-only e7247cd9 HEAD → contracts (1), fixtures/workshop_project/pilot_995 (16) ; scope_select.sh --changed → SCOPED: не для приёмки / MODE: full
```
Репро (все под /tmp/dev-harness-verify/critic995r2/): make_r2.py (C3), make_c2.py (C″), honest_metro.js, bundle_graph.py, bundle_markers.py, c3x/mobile/src/bootstrap/critic-apk.test.tsx; деревья c3 (чистый C3), c3x (export + одноразовый тест), c3y (честный metro), cprime, cdprime, tsc-b.
