# СДАЧА 995 — адресный ремонт предусловия пробы HTTP_UNAVAILABLE (запрос моба 165/995)

Основа: frozen/contracts/995/5 (контракт побайтно не менялся — `git diff
frozen/contracts/995/5 HEAD -- contracts/995-cmp-mob-001-android-pilot.md`
пуст), ветка `wip/995/architect` поверх main `662d6a7442`, один коммит
`31c711c245` (author=committer=architect). Решение консультанта
ConsProbe995 вариант (а), п.1–7. Зона: только
`fixtures/workshop_project/pilot_995/`. Продукт и `mobile.yml` не тронуты;
репин quality-H — владелец CI (163/197, заявка 999 v+1 `contracts/999-…:79`),
здесь не выполнялся.

## Дефект

`quality` PR mob#182 (165 v2, run 44174239656, job 134361187986) красный не
по квоте: `995 runtime/actual/HTTP_UNAVAILABLE: rc=1`, «Unable to find an
element with testID: auth-unavailable», на экране `auth-unconfigured`.
Причина по коду: `runtime_probe.py` строил окружение Jest-процесса
`dict(os.environ, EXPO_PUBLIC_API_MODE=CASES[case], …)` и для
HTTP_UNAVAILABLE (mode=http) не задавал и не удалял `EXPO_PUBLIC_API_URL` —
случайный родительский URL решал экран. Реализация 165 v2 по замороженному
165 (Ф3, инв. 6/9, приёмка :68) без URL законно показывает
`auth-unconfigured` и до fetch не доходит: `runtime.test.tsx:37–47`
(throw-fetch, ожидание `auth-unavailable`) краснел на законном поведении
продукта. Живой до-репро на этой станции — ниже, rc 1.

## Дельта предусловия (2 файла, +213/−0)

- `runtime_probe.py` (+7): константа `SYNTHETIC_API_URL =
  'https://api.example.invalid'` и case-specific присваивание в цикле
  построения env, до `subprocess.run`, одинаково для actual и model:
  `if case == 'HTTP_UNAVAILABLE': env['EXPO_PUBLIC_API_URL'] =
  SYNTHETIC_API_URL` — присваивание перекрывает любой родительский URL.
  Другие CASES, MUTANTS и интерфейсы `run`/`HERE`/`installed` не менялись
  (потребитель `from runtime_probe import HERE, installed` в
  `bundle_probe.py` работает без правок).
- `env_override_regression.py` (новый, 206 строк): регресс предусловия —
  см. «Новые контроли».

## Неизменные постусловия (п.2 задания)

`runtime.test.tsx` не менялся (sha256 `c9aa30fa…` равен прежнему): в
HTTP_UNAVAILABLE сохранены throw-fetch, ожидание `auth-unavailable`,
отсутствие F02.01/protected-start, восстановление fetch; экран не заменён
на unconfigured, «любой отказ» не принимается. Снимок оракула до субъекта
(`test_bytes`/`source`/`model_bytes`/`runtime_bytes` в `run()`) и удаление
`PILOT_DEMO_CODE` из env дочернего процесса — без изменений. Все восемь
runtime MUTANTS (включая http-demo) и все CASES сохранены — матрица ниже
ловит каждый поимённо.

## Новые контроли (Н-39: привязки в коде, не в прозе контракта)

Наблюдение env живёт ВНУТРИ отдельного процесса: в одноразовую копию
батареи байтовым якорем (ровно 1 вхождение, иначе rc 2) в блок
`it('HTTP_UNAVAILABLE', …)` вставляются
`expect(process.env.EXPO_PUBLIC_API_MODE).toBe('http')` и
`expect(process.env.EXPO_PUBLIC_API_URL).toBe(SYNTHETIC_API_URL)`; запускатель
— сам (копия) `runtime_probe.run`: машина окружения ровно та, что в CI.
Ожидания читаются из модуля пробы (`CASES`, `SYNTHETIC_API_URL`) — единый
источник. Мутации применяются к копии `runtime_probe.py` с доказанной
применимостью (якорь встречается ровно 1 раз, иначе rc 2):

| мутация | входы (где утрата НАБЛЮДАЕМА) | наблюдаемая ветвь |
|---|---|---|
| `no-override` (строка присваивания удалена) | no-url И foreign-url | наблюдение env: Received undefined / foreign; на no-url красна и сетевая клетка (auth-unconfigured, до-репро ниже) |
| `setdefault` (`env.setdefault` вместо присваивания) | только foreign-url | наблюдение env: Received foreign (на no-url мутант честно зелён — краснота не требуется) |
| `unapplied` (положительный контроль машинерии) | — | якорь отсутствует по построению → rc 2 ORACLE_TAMPERED, не «пойман» |

Сетевая клетка сама по себе НЕ различает утрату на foreign-url (посторонний
валидный URL + throw-fetch тоже даёт network_error → unavailable, честно
зелёно) — различает только наблюдение env; на no-url различают оба. Числа:
новые контроли = 3 связки + 1 положительный контроль, учтены отдельно от
восьми прежних MUTANTS.

## НЕ ЗАЩИЩАЕТ (п.4 задания)

Приёмка 165 «без URL → auth-unconfigured, ноль fetch» текущей
runtime-моделью НЕ доказывается: `runtime-model.ts` возвращает
`unavailable` при любом mode=http, не читая URL. Продуктовое поведение
ради теста не менялось. Ловец — решение владельца 165/995: отдельная no-URL
клетка (если потребуется) — предмет отдельного решения, не эта поставка.

## Прогоны (одноразовые клоны; H=…/Arch995Probe/harness@31c711c245, P=…/Arch995Probe/product@01e081b8dcc9, npm ci в P/mobile rc 0; сырые rc)

До-репро дефекта (проба из main 662d6a7442, продукт 01e081b8):

- `env -u EXPO_PUBLIC_API_URL python3 runtime_probe.py --repo P --case HTTP_UNAVAILABLE`
  → rc=1: «Unable to find an element with testID: auth-unavailable»,
  `testID="auth-unconfigured"`, «Umgebung nicht eingerichtet» — точное
  повторение отказа job 134361187986.

Регресс предусловия (новый helper, H@31c711c245):

- `python3 env_override_regression.py --repo P` → rc=0: оба входа
  (parent URL absent; parent `https://foreign-parent.example.com`) —
  процесс видит РОВНО синтетический URL и actual проходит сетевую клетку.
- `… --stabs` → rc=0: `SVJAZI 3 zhivykh 0`; no-override KRASEN на обоих
  входах (Expected `"https://api.example.invalid"`, Received
  `undefined` / `"https://foreign-parent.example.com"`), setdefault
  KRASEN на foreign-url (Received foreign).
- `… --mutation unapplied` → rc=2: `995 env ORACLE_TAMPERED: якорь
  unapplied не единственен (вхождений 0)` — неприменённый мутант
  отказывает, а не «пойман».

Фиксированная проба, actual (неизменный runtime.test.tsx):

- `env -u EXPO_PUBLIC_API_URL … --case HTTP_UNAVAILABLE` → rc=0.
- `EXPO_PUBLIC_API_URL=https://foreign-parent.example.com … --case HTTP_UNAVAILABLE` → rc=0.
- грязный родитель `EXPO_PUBLIC_API_MODE=mock EXPO_PUBLIC_API_URL=http://…` → rc=0 (присваивание перекрывает оба).

Матрица и прежние клетки:

- `python3 runtime_probe.py --repo P --matrix` → rc=0: `runs=9
  mismatches=0`; honest 6/6 CASES rc=0 (SHIPPED_INVALID, SHIPPED_VALID,
  DEFAULT_VALID, HTTP_UNAVAILABLE, UNKNOWN_MODE, RUNTIME_RESPONSES);
  поимённо красны copied-model, any-code, env-code (auth-invalid),
  http-demo (auth-unavailable), ignore-mode (rejects.toThrow),
  bypass-ports (toHaveBeenCalled), wrong-session (principal_ref),
  wrong-disclosure (acknowledged).
- `python3 runtime_probe.py --repo P` (без флагов, actual все CASES) → rc=0.
- `python3 probe.py --repo P --check-frozen` → rc=0 (байты равны; actual 14/14).
- `schema_probe.py` → rc=0 (`checked=2 runtime=matched`).
- `frozen_matrix.py` → rc=0 (`checked=3`; drift-строка красна по построению).
- `transport_probe.py` → rc=0 (настоящий ESLint).
- `admission_probe.py` → rc=0 (4 случая).
- `stale_probe.py` → rc=0 (REV_STALE_RESEND/SESSION).
- `pins_probe.py` → rc=0 (B5 имя rehearsal 991, B3 release mode).
- `admission_family_probe.py` → rc=0 (`family_size=860`, EDGE/NORMALIZE/LIVE_TRUE_CODE).
- `stale_table_probe.py` → rc=0 (4 клетки).
- `bundle_probe.py` → rc=0 (`actual/http sources=37`, `actual/mock
  sources=32`, настоящий Metro export, elapsed 21.6 s).
- `types_probe.py` → rc=0 (`checked=2 schema=matched`, полный
  `tsc --noEmit` mobile; средового rc 2 не было — предостережение
  консультента §2 не сбылось).
- `native_matrix.py --scratch …/Arch995Probe/scratch` → rc=0
  (`checked=16 Android=NOT_RUN`).
- `bash restart/red_ci_e2e_restart_995.sh --stabs` → rc=0 (`SVJAZI 69`,
  `zhivykh 0`, SVIP N=20); replay Android-приёмкой не объявляется.

Клон продукта после прогонов чист (`git status --short` = 0 строк).

## Пины «не менялись» (п.5 задания)

`source.json` (bdad2c40…), `pilot.test.tsx` (dee6de0b…), `model.tsx`
(0ceec830…), `runtime-model.ts` (3f081ef5…), `runtime.test.tsx`
(c9aa30fa…, равен прежнему), продуктовые копии `pilot.test.tsx`/
`source.json` (свидетельствует `probe.py --check-frozen` rc 0),
`restart/` целиком (model, nositeli, zhivoj, potrebiteli, source.json,
probe.py, red_ci_e2e_restart_995.sh — `git show --stat HEAD` = 2 файла),
`maestro_probe.py`, `bundle-metro.js`, `capture.py`. Внешние hashes не
переснимались. Новый `env_override_regression.py` потребителей-пинов не
имеет; sha256 фактических байтов `af43e2b73ef940e4a785fa0495dca03f043e887358057fc4d4090015268a8430`,
`runtime_probe.py` после правки `b4a32677841f395cdb7fa183d8f78b70dea31dff5dba13db4fe562567485bb0e`.

## Граница

Правки frozen-текста/риска не потребовались: приёмка frozen/5 (:94 «http
без capability показывает auth-unavailable») согласуется с ремонтом
предусловия; расширенная дельта не пряталась в env-ремонт. Суда
(adversary → reviewer) не звались — ждут адресной санкции владельца
(строка «ЖДЁТ ВЛАДЕЛЬЦА» (13) в HANDOFF).
