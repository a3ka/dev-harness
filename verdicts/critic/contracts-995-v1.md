accept
OBJECT=40a93f1da02d18d7323764007aac094989ee8c74

# Критик 995, круг 3 — contracts/995-cmp-mob-001-android-pilot.md (CMP-MOB-001)

Модель: критик (Critic995R3). Предмет круга закрыт решением арбитра
`b5eaa8ef4:verdicts/arbitration/contracts-995-runtime-proof-v1.md`: судится только К1–К8 и исполнение П1–П7.
Объект: ssh-клон `/tmp/dev-harness-verify/critic995r3/dh`, `git rev-parse HEAD` = OBJECT, `git status` пуст,
автор коммита `architect`. Diff круга: `a60dfde5..40a93f1d` — контракт + `pilot_995/{bundle-metro.js,bundle_probe.py,
pilot.test.tsx,pilot.yaml,runtime-model.ts,runtime.test.tsx,runtime_probe.py}`.

## Итог

Блокирующих находок нет. Все восемь признаков К1–К8 выполнены, и это проверено живыми прогонами (ниже).
Обходы прошлых кругов на новом объекте красные: C3 — в bundle_probe и runtime_probe, C′/C″ — в runtime_probe
и schema_probe. Честный вариант C3 с исправленными двумя дефектами (C3h) зелёный во всех пробах. Значит,
пробы отличают работу от имитации на дереве субъекта, а не только на моделях. Нового класса не открываю.

## К1–К8 по пунктам

- **К1 — выполнен (П1).** `bundle_probe.py` стоит в критерии (`:63`) и в CI-списке (`:75`). В `:42` ссылка
  расширена до `STRUCTURE.md:163–171`, и проба названа механизмом.
  - `--matrix` → rc0, checked=3, mismatches=0, 58.2 s. Мутант metro-always-mock красный на http
    (`BUNDLE_HTTP_HAS_MOCKS`, `BUNDLE_HTTP_RUNTIME_ABSENT`), metro-always-http красный на mock
    (`BUNDLE_MOCK_HAS_HTTP_RUNTIME`, `BUNDLE_MOCK_RUNTIME_ABSENT`). Привязка мутант→причина задана в коде (`MUTANTS`).
  - C3 → rc1: http `BUNDLE_HTTP_HAS_MOCKS` и `BUNDLE_HTTP_RUNTIME_ABSENT`, mock rc0.
  - C3h (C3 + `critic995r2/honest_metro.js`) → rc0.
  - B → rc1 `BUNDLE_SEAM_ABSENT`.
  - После прогонов `git status --short` в R (`mob`) пуст.
- **К2 — выполнен (П2 а–г).**
  - `runtime_probe.py:102` делает `env.pop('PILOT_DEMO_CODE')` после `dict(os.environ, …)`. Все мои прогоны шли с
    `export PILOT_DEMO_CODE=synthetic-verification-value` в родительском env, то есть удаление унаследованного
    ключа проверено живьём: C3 красный.
  - `runtime.test.tsx:18` и honest-ветка `runtime-model.ts:18` сверяют с литералом.
  - `--matrix` → rc0, runs=9, mismatches=0; `env-code/SHIPPED_INVALID` rc1 (причина auth-invalid).
  - C3 → rc1 SHIPPED_INVALID: «Unable to find … auth-invalid», при этом F02.01 на экране.
  - C3h с литералом в `demo-code.ts` → 6/6 rc0.
- **К3 — выполнен (П3).** В `pilot.yaml:20–29` порядок такой: `inputText: definitely-wrong-000` → verify →
  `assertVisible id: auth-invalid` → `assertNotVisible id: F02.01` → tap auth-code → `eraseText` →
  `${PILOT_DEMO_CODE}`. Неверный код задан литералом. Строка `:66` контракта называет этот шаг. ROWS в
  `native_matrix` не затронуты (STUB не читает поток), `native_matrix` → rc0, checked=16. Device-режим не исполнялся
  (по брифу).
- **К4 — выполнен (П2 д).** Текст `:44` совпадает с П2(д). ЗАЩИЩАЕТ `:107` («demo-код не передаётся субъекту через
  env») харнессу не противоречит: в Jest-env runtime_probe/bundle_probe ключа нет. `maestro_probe` передаёт env только
  Maestro/ci-e2e.sh, а `ci-e2e.sh` B лишь ставит готовый APK (`adb install`, `:47`).
- **К5 — выполнен (П4).** Пометка cognitive-only с чек-листом П4 (1–4) стоит в `:50–54`. Буллет НЕ ЗАЩИЩАЕТ есть
  в `:113`.
- **К6 — выполнен (П5).**
  - `:42`: интерфейсы лежат в `src/api/api-client.ts` и `src/auth/`, runtime-contract.d.ts только собирает их,
    mocks импортирует из `@/api`/`@/auth`. Источник типов назван: ручные типы двух операций со ссылкой на
    Session/Disclosure `api/mock-5_8.json`, без зависимостей.
  - Свидетельство П5(в) воспроизведено на неизменённом ESLint B. `src/mocks/type-proof.ts` с импортом из
    `@/api/api-client` → lint rc0. С импортом из `../bootstrap/runtime-contract` → rc1 `import/no-restricted-paths`
    («Lower layers cannot depend on screens/composition»).
- **К7 — выполнен (П6).** Копия B (tsconfig `types: ["jest"]`) + frozen `pilot.test.tsx`/`source.json` + model.tsx
  в роли pilot-app.tsx → `tsc --noEmit` rc0.
  - Контроль: те же байты из a60dfde5 (`global`) → rc2, TS2304 ×4 (127,22 / 129,5 / 136,14 / 138,7).
  - `runtime.test.tsx` тоже переведён на `globalThis`.
- **К8 — выполнен.** probe --matrix rc0 (runs=18); probe на B rc1 PILOT_ABSENT; frozen_matrix rc0 (checked=3, drift
  rc1 FROZEN_BYTES_MISMATCH); schema --matrix rc0 (checked=6); transport --matrix rc0 (checked=5); native_matrix rc0;
  `probe.py --check-frozen` на C3h rc0. C′ runtime rc1 (SHIPPED_INVALID/HTTP_UNAVAILABLE/UNKNOWN_MODE/RUNTIME_RESPONSES).
  C″ runtime rc1 и schema_probe rc1 `RUNTIME_RESPONSES_MISMATCH`.
- **Метагейты.** `pre_critic.sh` rc0 («КРИТИК: дверь зелёная»); `check_threat_model.sh` rc0 (4/4 буллета).
  Норма 043: `check_precision_gate.sh <клон> contracts/995-…` → rc0 «OK».
- **ПРИЁМКА-СУДЬИ.** `git diff --name-only origin/main...HEAD -- scripts/` пуст, барьерного ключа в diff нет.
  Scoped-регресс не нужен, полный прогон — за CI. (`scope_select.sh --changed` отвечает MODE: full как
  консервативный откат на add-файлах; барьеров среди них нет.)

## СОВЕТЫ (не блокируют)

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:97 — абзац о зонах по-прежнему ссылается на «STRUCTURE.md:163–167».
П1(г) требовал расширить только `:42`, но ради единообразия лучше `:163–171`: проба bundle graph относится к тем же
путям metro/jest.

СОВЕТ fixtures/workshop_project/pilot_995/bundle_probe.py:24–27 — `sources()` режет путь по ПЕРВОМУ сегменту `src`.
Если абсолютный путь R сам содержит каталог `src`, нормализованный путь станет `src/<…>/mobile/src/…`. Отказ при
этом закрытый (honest краснеет на `*_RUNTIME_ABSENT`), а не ложная зелень. Надёжнее отсчитывать путь от
`mobile/` (Path.relative_to) или брать последний `src`.

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:63 — C с pilot-app.tsx, но без alias в Metro, даёт ошибку export,
то есть rc2 INFRASTRUCTURE, а не rc1 с именем. Так прямо задано П1(а), и CI всё равно краснеет. Но дефект субъекта
классифицируется как инфраструктура, и reviewer стоит предупредить, чтобы rc2 bundle_probe на C не списывался на
среду.

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:134 — в замере указано 52.5 s, у меня `--matrix` шёл 58.2 s. Это не
расхождение по сути, но время — свойство машины, а не контракта.

СОВЕТ (метагейт) — `scripts/check_no_leak.sh` без аргументов даёт rc1 (это usage). По брифу rc0 уже получен
оркестратором, в правильной форме я его не перепрогонял.

## Сырой вывод (ключевые строки; полные логи — /tmp/dev-harness-verify/critic995r3/logs/*.log)

```
# все прогоны: cwd=/tmp/dev-harness-verify/critic995r3/dh (OBJECT), PILOT_DEMO_CODE=synthetic-verification-value экспортирован
995 bundle/honest/http: rc=0 maps=1 sources=5 reasons=[]
995 bundle/honest/mock: rc=0 maps=1 sources=5 reasons=[]
995 bundle/metro-always-mock/http: rc=1 maps=1 sources=5 reasons=['BUNDLE_HTTP_HAS_MOCKS', 'BUNDLE_HTTP_RUNTIME_ABSENT']
995 bundle/metro-always-mock/mock: rc=0 maps=1 sources=5 reasons=[]
995 bundle/metro-always-http/http: rc=0 maps=1 sources=5 reasons=[]
995 bundle/metro-always-http/mock: rc=1 maps=1 sources=5 reasons=['BUNDLE_MOCK_HAS_HTTP_RUNTIME', 'BUNDLE_MOCK_RUNTIME_ABSENT']
995 bundle checked=3 mismatches=0
### bundle-matrix rc=0 t=58.2s
995 bundle/actual/http: rc=1 maps=1 sources=6 reasons=['BUNDLE_HTTP_HAS_MOCKS', 'BUNDLE_HTTP_RUNTIME_ABSENT']
995 bundle/actual/mock: rc=0 maps=1 sources=6 reasons=[]
### bundle-c3 rc=1 t=18.5s
995 bundle/actual/http: rc=0 maps=1 sources=5 reasons=[]
995 bundle/actual/mock: rc=0 maps=1 sources=6 reasons=[]
### bundle-c3h rc=0 t=16.7s
995 BUNDLE_SEAM_ABSENT
### bundle-B rc=1
(git status --short в mob после bundle-matrix/bundle-B: пусто)

995 runtime/honest/{SHIPPED_INVALID,SHIPPED_VALID,DEFAULT_VALID,HTTP_UNAVAILABLE,UNKNOWN_MODE,RUNTIME_RESPONSES}: rc=0
995 runtime/{copied-model,any-code,env-code}/SHIPPED_INVALID: rc=1
995 runtime/http-demo/HTTP_UNAVAILABLE: rc=1 ; ignore-mode/UNKNOWN_MODE: rc=1 ; bypass-ports|wrong-session|wrong-disclosure/RUNTIME_RESPONSES: rc=1
995 runtime runs=9 mismatches=0
### runtime-matrix rc=0 t=36.7s
### runtime-envcode rc=1 (--model env-code --case SHIPPED_INVALID)
C3:  995 runtime/actual/SHIPPED_INVALID: rc=1  Error: Unable to find an element with testID: auth-invalid … <View testID="F02.01">
     SHIPPED_VALID 0, DEFAULT_VALID 0, HTTP_UNAVAILABLE 0, UNKNOWN_MODE 0, RUNTIME_RESPONSES 0   ### runtime-c3rt rc=1
C3h: 6/6 rc=0                                                                                 ### runtime-c3h rc=0
C′:  SHIPPED_INVALID 1, SHIPPED_VALID 0, DEFAULT_VALID 0, HTTP_UNAVAILABLE 1, UNKNOWN_MODE 1, RUNTIME_RESPONSES 1   ### rc=1
C″:  то же                                                                                     ### rc=1
C″ schema_probe: RUNTIME_RESPONSES_MISMATCH                                                    ### schema-cdprime rc=1
C3h schema_probe: 995 schema checked=2 runtime=matched                                          ### rc=0
C3h transport_probe rc=0 ; C3h probe --check-frozen: 14/14 rc=0, runs=1 mismatches=0 rc=0

probe --matrix: runs=18 mismatches=0 rc=0 ; probe на B: 995 PILOT_ABSENT rc=1
frozen_matrix: pilot.test.tsx preserved=true, pilot-995.test.tsx preserved=true, drift rc=1 FROZEN_BYTES_MISMATCH:pilot.test.tsx, checked=3 rc=0
schema --matrix: honest 0; wrong-session MOCK_SCHEMA_INVALID:getSession 1; wrong-disclosure MOCK_SCHEMA_INVALID:getDisclosure 1; runtime-honest 0; runtime-wrong-session 1; runtime-wrong-disclosure 1; checked=6 rc=0
transport --matrix: honest 0, fetch 1 no-restricted-globals, global 1 no-restricted-globals, runtime-alias 0, bootstrap-mocks 1 import/no-restricted-paths; checked=5 rc=0
native_matrix: device/ci × 8 ROWS как ожидалось, checked=16 Android=NOT_RUN rc=0

# К7, tscb = чистая копия B (types: ["jest"]) + frozen pilot.test.tsx/source.json + model.tsx→pilot-app.tsx
tsc-new rc=0
tsc-old (a60dfde5 pilot.test.tsx): TS2304 Cannot find name 'global' @127,22 129,5 136,14 138,7 → rc=2

# К6, lintb = чистая копия B, неизменённый ESLint
mocks/type-proof.ts ← '@/api/api-client'               → lint-api rc=0
mocks/type-proof.ts ← '../bootstrap/runtime-contract' → 1:32 error … Lower layers cannot depend on screens/composition import/no-restricted-paths → rc=1

pre_critic.sh: КРИТИК: дверь зелёная rc=0
check_threat_model.sh: модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов)) rc=0
check_precision_gate.sh /tmp/dev-harness-verify/critic995r3/dh contracts/995-cmp-mob-001-android-pilot.md: OK rc=0
git diff --name-only origin/main...HEAD -- scripts/ : 0 строк
```

## Репро и артефакты (/tmp/dev-harness-verify/critic995r3/)

- `dh/` — ssh-клон на OBJECT, не изменён.
- `mob`, `mob-{rt,pr,sc,tr,fr}` — `cp -a` копии B с зависимостями из `architect995/mob`, по одной на пробу.
- `c3`, `c3rt` — C3 по `critic995r2/make_r2.py dh <T> critic995r1/bypass/mobile/src/bootstrap/pilot-app.tsx`.
- `c3h` — C3 + `honest_metro.js` + литерал в `demo-code.ts`.
- `cprime`, `cdprime` — C′ (`critic995r1/make_bypass.py`) и C″ (+`critic995r2/make_c2.py`).
- `tscb`, `lintb` — свидетельства К7 и К6.
- `run.sh`, `batch_*.sh` — обвязка; `logs/` — полные логи.

Основной чекаут не тронут, push не делался, каталоги c995/architect995/critic995r1–r2/arbiter995 только читались.
Вердикт не закоммичен (страж Н-85): коммит под `user.name=critic` в `verdicts/critic/` делает вызвавшая сторона.
Предлагаемое имя файла: `verdicts/critic/contracts-995-v3.md`.
