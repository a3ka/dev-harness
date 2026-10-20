FAIL
OBJECT=8aca71aac5509abb0b1d825d3c808115a2648e88

# Adversary Adv109r3 — суд реализации 109 (CMP-BCK-004), круг 3

Предмет: `cp -a /tmp/dev-harness-verify/Impl109/back` → `/tmp/dev-harness-verify/Adv109r3/back` (HEAD 8aca71a, дерево чистое).
Батарея: `git archive d8e3fc19f fixtures/workshop_project/stend_109` → `Adv109r3/h`. Ход r3 повторяет r2: pii.js, struct.js, drill.js, a1.js,
мутанты M1–M9 пересобраны на коде 8aca71a, H-checkout со стабом, живой up + повтор. Новое: M10–M15, ro.js, conc.js, struct3.js, lane.sh.
Скрипты — `Adv109r3/*.js|*.sh|mk_mutants.py`. Docker: свой проект `adv109r3`, контейнер `adv109r3pg`, плюс `stend109up*`, которые поднимает сама батарея.
Все сняты (см. конец). Находки reslop — `review.md`.

## Итог по пунктам круга 2

| пункт | статус круга 3 |
|---|---|
| F4′ Set-Cookie / multicookie / экранированная cookie, структура JSON | **закрыт** (живой async-путь и sync-путь) |
| F2′ measured_at | **не закрыт**: «never»/«ok» отвергаются, но «never 1», «1», «May 5», «2026-02-31» дают MEASURED rc 0 — блокер 1 |
| A2/С3 lane при грязном дереве | **закрыт** (rc 1). Остаток — assume-unchanged/skip-worktree/tag -f (совет С2) |
| F3′ M1–M4 (связь HTTP↔SQL↔роль) | **закрыт батареей**: каждый мутант красный фактом ASYNC_TUPLE_GUARD |
| Б2′ (пустой harness зелёный) | **закрыт** батареей (harness_async_constants REJECTED_EXACT; мои M1–M4 красные) |
| С7 (M7/M8/M9 строки 4) | **закрыт** батареей (STEND_UP_GUARD красный) |

## Позитивный контроль

    bash run_all.sh /tmp/dev-harness-verify/Adv109r3/back      (батарея d8e3fc19f, probe.py --repo back --out out/back)
    → back rc=0 control_green=True control_red=[] facts_not_green=[] rejected=50/50 non_exact=[]   (176,8 с)

Батарея на честном предмете зелёная, вечно-красной она не является.

## Неизменность frozen-артефактов (ПРИЁМКА-СУДЬИ v2)

    git -C /home/harness/dev-harness diff --stat frozen/contracts/109/1 d8e3fc19f -- contracts/109-cmp-bck-004-stend-evidence.md → пусто, rc 0
    git -C back diff --stat 9d960a05 HEAD -- db server/test/harness.ts server/src/app.ts evidence/runs infra/migrations tests/run_sql_3_9_native.py → пусто, rc 0
    python3 tools/verify_handoff.py → {"status":"PASS_STATIC",…,"all_manifest_files_and_hashes":"PASS"} rc 0

## Мутанты НАСТОЯЩЕГО кода 8aca71a против батареи d8e3fc19f

`python3 mk_mutants.py` (у каждого мутанта якорь заменён ровно 1 раз, иначе exit) + `bash run_all.sh mut/…` (643 с):

    M1_async_no_http        httpResponse = obs.http_response                  → rc=1 facts_not_green=[ASYNC_TUPLE_GUARD, ASYNC_PII_GUARD] 43/50   КРАСНЫЙ
    M2_sql_const_notrun     captureSql: url = null                            → rc=1 [ASYNC_TUPLE_GUARD] 45/50                                  КРАСНЫЙ
    M3_http_after_snapshots HTTP после обоих снимков                          → rc=1 [ASYNC_TUPLE_GUARD] 45/50                                  КРАСНЫЙ
    M4_role_claimed         runtime_role: obs.runtime_role                    → rc=1 [ASYNC_TUPLE_GUARD] 45/50                                  КРАСНЫЙ
    M5_async_no_scrub       writeEvidence пишет JSON.stringify без scrubRecord → rc=1 [ASYNC_PII_GUARD] 48/50                                   КРАСНЫЙ
    M6_no_setcookie_key     SENSITIVE_KEYS без set-cookie/setcookie (структурная защита) → rc=1 [ASYNC_PII_GUARD] 48/50                     КРАСНЫЙ
    M7_role_superuser       role-bootstrap … SUPERUSER                        → rc=1 [STEND_UP_GUARD] 45/50                                     КРАСНЫЙ
    M8_api_superuser_url    api DATABASE_URL = postgres:ci-synthetic-only     → rc=1 [STEND_UP_GUARD] 45/50                                     КРАСНЫЙ
    M9_ledger_rewritten     migrator: run.js && UPDATE … applied_by=md5(…)    → rc=1 [STEND_UP_GUARD] 45/50                                     КРАСНЫЙ
    M13_basic_identity      authorization → только scrubSecrets (Bearer в заголовке течёт) → rc=1 [HARNESS_PII_GUARD] 49/50                 КРАСНЫЙ
    M14_cookie_key_off      SENSITIVE_KEYS без cookie                         → rc=1 [HARNESS_PII_GUARD, ASYNC_PII_GUARD] 47/50                КРАСНЫЙ
    M10_no_read_only_tx     BEGIN вместо BEGIN READ ONLY                      → rc=0 control_green 50/50                                        ВЫЖИЛ
    M11_readonly_filter_off readOnlySql пропускает всё                         → rc=0 control_green 50/50                                        ВЫЖИЛ (эквивалентен: READ ONLY держит)
    M12_ro_commit_after     COMMIT вместо ROLLBACK                            → rc=0 control_green 50/50                                        ВЫЖИЛ (эквивалентен)
    M15_role_label_when_notrun runtime_role: current_user || 'hc_synthetic_only' → rc=0 control_green=True 49/50,
                            клетка harness_async_role_claimed = BLOCKED_BY_RED_CONTROL «вход мутации отсутствует (база красна)»                 ВЫЖИЛ + клетка снята

Батарея держит M1–M9: на каждом красная, нужный факт назван, остальные клетки REJECTED_EXACT. Мутанты поведенческие, не NOOP.
Проверено исполнением: `m13.js` — M13 → Bearer в Authorization течёт; `pii.js` — M14 → multicookie течёт, M6 → setcookie течёт, M15 → `"runtime_role":"hc_synthetic_only","db":"NOT_RUN"`;
`ro.js` — M10 → `SELECT nextval/setval` MEASURED, последовательность сдвинута (DB CHANGED). M11/M12 по ro.js дают тот же результат, что предмет:
это эквивалентные мутанты, READ ONLY и фильтр дублируют друг друга.

**Привязка батареи к форме, измерено (орк. п. а).** M15 меняет строку-якорь клетки `harness_async_role_claimed`. `run_case` получает `mut() → None`
и пишет клетку как `BLOCKED_BY_RED_CONTROL` с примечанием «база красна», хотя `control_green=True`. Итог — **rc 0**, «49/50», и lane читает это как PASS.
Контракт (стр. 95, «от самогó обмана батареи: no-op мутация → rc 2») требует здесь rc 2. По `probe.py:2425-2430` пропавший якорь уходит в ветку,
которая не NOOP и не красит rc. Значит, любой рефакторинг предмета, убирающий якорь (переименование, перестановка, новая сигнатура
`captureSql(label, sql)` — та самая правка блокера 2), молча разоружает клетку. Батарея при этом остаётся зелёной. Факты судят предмет поведенчески,
поэтому дефекта предмета это не пропускает. Но отчёт «N/50 REJECTED_EXACT» становится нечестным, а исправление блокера 2 упрётся ровно в эту ветку.
Совет architect (С8): `overlay is None` при `control_green` → NOOP_MUTATION/rc 2, не BLOCKED.

## Атаки круга 2 на 8aca71a

### F4′ scrubber: Set-Cookie/multicookie/экранированная форма. ЗАКРЫТ.

`node pii.js back/backend/tests/helpers/harness.js` — живой `recordInteractionAsync` против реального `http.createServer`, rc 0:

    {"parsed":true,"leaks":["basic","phone_ru_plain","phone_ru_spaces","bearer_lower","apikey"],"runtime_role":"claimed_role","db":"NOT_RUN","mode":"RUNTIME","http_status":200}
      "cookie": "a=[REDACTED]; session=[REDACTED]",
      "authorization": "Basic dXNlcjpTM2NyZXQ=",

На круге 2 утекали `setcookie` и `multicookie`, теперь их в списке утечек нет. Остаток тот же, что на круге 2: Basic, телефоны РФ без `+`,
`x-api-key`, `bearer:` в чужом заголовке. На круге 2 это было советом, советом и остаётся (С3).

`node struct.js …`, rc 0. Все шесть кейсов дают `parse=ok`. `body_set_cookie_text`, `body_escaped_cookie_json`, `body_escaped_cookie_json_sp` дают `leak=false`.
`header_cookie_array` (`cookie: ['ARRCOOKIESECRET']`): структура цела, но `leak=true`. Значение без `=` не маскируется (С3).

### F2′ drill measured_at. НЕ ЗАКРЫТ, блокер 1.

`node drill.js back/backend` — через точку входа поставки `npm run -s drill:evidence -- --out … --input …`:

    Date.parse("never 1")=978307200000   Date.parse("1")=978307200000   Date.parse("May 5")=989020800000
    at_never:  rc=2 status=NOT_RUN  «measured_at обязан быть строкой ISO-8601; получено "never"»
    at_ok:     rc=2 status=NOT_RUN
    at_one:    rc=0 status=MEASURED at=1
    at_never1: rc=0 status=MEASURED at=never 1
    at_may5:   rc=0 status=MEASURED at=May 5
    at_feb31:  rc=0 status=MEASURED at=2026-02-31
    at_us:     rc=0 status=MEASURED at=12/31/2026
    negative:  rc=2 status=NOT_RUN «measured_rpo_minutes не может быть отрицательным; получено -5»
    dump_is_path (/etc/hostname): rc=0 MEASURED, db_hash по байтам файла (С5 круга 2 закрыт)

### A2/С3 lane при грязном дереве. Обход круга 2 ЗАКРЫТ, остаток — совет.

`bash lane.sh`: H-checkout — клон dev-harness на `frozen/contracts/109/1` (b91be196…), probe.py подменён на `sys.exit(0)`, lane из `back/tools/run_backend_ci.py`:

    1_dirty:            LANE_RC=1  «рабочее дерево не чистое ( M …/probe.py)»                  ← обход круга 2 закрыт
    2_assume_unchanged: LANE_RC=0  status_porcelain=[]  STUB в evidence lane  «[stend109] PASS»
    3_skip_worktree:    LANE_RC=0  status_porcelain=[]  STUB в evidence lane  «[stend109] PASS»
    4_tag_moved:        LANE_RC=0  (коммит со стабом, git tag -f frozen/contracts/109/1 → 75626b9a)  «PASS»

### Б2′/F3′ живая связка HTTP↔SQL↔роль

Позитивный контроль: ASYNC_TUPLE_GUARD зелёный (реальные строки таблицы до/после, MARKER только в после-снимке, роль из БД). Мутанты — ниже.
Остаток F3′ круга 2 не изменился: при NOT_RUN БД `runtime_role` = заявление вызывающего под `mode: RUNTIME`
(`pii.js`: `"runtime_role":"claimed_role","db":"NOT_RUN","mode":"RUNTIME"`). `db_snapshot.status` честно NOT_RUN, поэтому это совет (С4).

## Живая строка 4: `docker compose up -d --wait` + повтор (`bash stend.sh`, проект `adv109r3`)

    up1 RC=0 (29 s); migrator Exited (0), role-bootstrap Exited (0), api/document-worker/sandbox running, postgres healthy
    ledger count: 14; ledger md5 #1: 560661d4a2a58e06465fc72f08104498
    up2 RC=0 (3 s); ledger md5 #2: 560661d4a2a58e06465fc72f08104498 same=yes; data kept: KEEP_R3
    migrator: «применено 0, в журнале 14»; role-bootstrap: «hc_synthetic_only уже существует; пропуск CREATE ROLE»
    api role: hc_synthetic_only super=false createrole=false
    db/013 +1 байт, down -v, холодный up → RC=1 (14 s); migrator Exited (1) «SHA256 013_… не совпадает с манифестом»; api Created (не Running)
    013 восстановлен, git status --porcelain пуст; down -v rc 0

Попытка DDL под `hc_synthetic_only` в этом прогоне: в вывод попала только строка-каретка psql (вывод обрезан `tail -n1`). На круге 2 тот же прогон дал
`permission denied for schema public`. Здесь не утверждаю.

## Живая строка 5: native PG18 (`bash integ.sh`, свой `adv109r3pg`)

    COMPLIOR_TEST_PG_ADMIN_URL=postgres://adv_hc:probe@127.0.0.1:32866/postgres npm run -s test:integration → ℹ tests 31 / pass 31 / fail 0, rc=0
    COMPLIOR_TEST_PG_ADMIN_URL=…@127.0.0.1:1/… (БД остановлена)              → ℹ tests 32 / pass 12 / fail 20, rc=1   (не success)
    git status --porcelain после обоих прогонов → 0 строк

## Новые поверхности круга 3

### Глобальный `snapshotContext` при параллельных записях. Блокер 2, следствие подгонки под якорь.

`node conc.js back/…/harness.js postgres://adv_hc:probe@127.0.0.1:32866/probe` (свой disposable PG18 `adv109r3pg`). Два
`recordInteractionAsync` через `Promise.all`, у каждого свои тексты `sql_before/sql_after` (`SELECT '<tag>_BEFORE'` / `'<tag>_AFTER'`):

    record A: sql_before=MEASURED:A_BEFORE sql_after=MEASURED:B_AFTER     ← ось A измерена ЗАПРОСОМ B, статус MEASURED
    record B: sql_before=MEASURED:B_BEFORE sql_after=MEASURED:B_AFTER
    rc=0

Механизм: `captureSql(label)` держит один параметр. Комментарий `harness.js:60-61` говорит прямо: «однопараметрический вызов (грамматическая метка батареи)».
Тексты запросов он читает из модульного синглтона `snapshotContext.observation`, а его перезаписывает каждый вызов (`harness.js:419`, `:426`).
Параллельный вызов в продукте — обычный приём: `backend/tests/migrations/runner.test.js:157` `await Promise.all([run(url), run(url)])`.

### «Read-only» снимок по тексту наблюдения. Совет С1: запись в БД реальна, но evidence честно NOT_RUN.

`node ro.js back/…/harness.js <pg>`: в каждом кейсе `sql_before` = текст атаки, `sql_after` = `SELECT 1`, рядом реальный HTTP-сервер:

    multi_commit_insert  "SELECT 1; COMMIT; INSERT INTO adv_t VALUES ('ROGUE_MULTI')" → NOT_RUN «Cannot read properties of undefined (reading 'length')» | DB CHANGED: seed → ROGUE_MULTI,seed
    multi_end_drop       "SELECT 1; END; DROP TABLE adv_victim"                       → NOT_RUN (тот же TypeError) | DB CHANGED: adv_victim удалена
    multi_then_select    "…; COMMIT; INSERT …; SELECT count(*) …"                     → NOT_RUN | DB CHANGED
    select_terminate     "SELECT pg_terminate_backend(pid) FROM pg_stat_activity …"   → MEASURED rows=[{pg_terminate_backend:true}] | чужая сессия убита
    select_for_update / setval / nextval / volatile INSERT-функция / WITH … DELETE / «/* */ INSERT» → NOT_RUN, DB same   (READ ONLY и префикс-фильтр работают)

Проверка `^\s*select\b` пропускает мультистейтмент, и `COMMIT` внутри него выводит запись из `BEGIN READ ONLY`. В evidence при этом пишется NOT_RUN
с неверной причиной (TypeError), измерение не подделывается. Тексты снимков задаёт сам автор теста, и контракт не требует, чтобы harness
закрывался от собственного вызывающего. Поэтому это совет. Ложный комментарий «исполняется как чтение и только как чтение» — в review.md п.2.

### Структурный скраббер: регистр, вложенность, длинные тела (`node struct3.js …`, rc 0)

    key_upper_COOKIE / key_mixed_SetCookie / cookie_nested_array / body_json_cookie_upper / rows_email → leak=none, parse=ok
    cookie_no_eq (cookie:"NOEQCOOKIESECRET") / setcookie_no_eq                       → leak (С3)
    body_json_cookie_array ('{"cookie":["…"]}' строкой тела)                         → leak (С3)
    body_json_authorization_basic / body_raw_authorization_basic / proxy_authorization / x_api_key → leak (С3)
    body_raw_cookie_header ("Cookie: session=…" в теле-строке)                       → leak (С3)
    long_letters_20000: 410 ms; 80000: 6400 ms; 160000: 29555 ms (квадратичный email-паттерн, С6); digits_plus: 0–3 ms

Регистр ключей и вложенные массивы обработаны. Во всех кейсах структура JSON цела.

## Блокеры (у каждого названный обход)

1. **F2′: measured_at не ISO принимается как MEASURED.** Обход: дерево 8aca71a как есть, батарея rc 0, 50/50, 13 фактов зелёные.
   `npm run -s drill:evidence -- --input {…,"measured_at":"never 1"}` → rc 0, `status=MEASURED`, `measured_at="never 1"`.
   Так же ведут себя `"1"`, `"May 5"`, `"12/31/2026"`, `"2026-02-31"`. Требование — грамматика DRILL_INPUT_GUARD: «не-числом/не-ISO-строкой («ok»/«fine»/«never») → rc ≠ 0
   и sink без MEASURED». «never 1» — не-ISO-строка того же класса. Причина: `isValidIso8601` (`drill-measure.js:115-125`) сводится к
   `Number.isFinite(Date.parse(s))`, а round-trip проверка тавтологична. V8 `Date.parse` разбирает свободный текст с числом.
   Дыра батареи — её форма: клетка `drill_at_not_iso` якорится на строку вызова `isValidIso8601(...)` (MODEL_AT_ISO), а не на поведение функции.
   Живые входы факта — «never»/«ok»/«2026-13-45T99:99:99Z», все три дают NaN. Правка implementer: строгая грамматика ISO-8601,
   например `/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:\d{2})$/` и сверка календаря. Architect — совет: добавить
   во вход факта «never 1»/«2026-02-31».

2. **Перекрёстное загрязнение SQL-снимков при параллельных записях: оси MEASURED, но по чужому запросу.** Обход: дерево 8aca71a как есть,
   батарея зелёная. Два одновременных `recordInteractionAsync` (`Promise.all`) → в записи A `sql_after` измерен ТЕКСТОМ наблюдения B
   (`record A: sql_before=MEASURED:A_BEFORE sql_after=MEASURED:B_AFTER`, `conc.js`, живой PG18). Требование контракта (строка «Один наблюдаемый
   результат», инвариант 3): harness связывает ЭТОТ HTTP request/response с SQL-снимками до/после — оси записи равны её наблюдению.
   Здесь же evidence записи A несёт измерение чужого запроса со статусом MEASURED. Это подлог измерения, не NOT_RUN.
   Источник — подгонка под якорь: комментарий `harness.js:60-61` «captureSql(label) — однопараметрический вызов (грамматическая метка батареи)».
   Ради этой метки тексты передаются модульным синглтоном `snapshotContext`. Параллельный вызов в продукте — обычный приём
   (`tests/migrations/runner.test.js:157`). Правка implementer: передавать текст аргументом/замыканием на вызов, без глобального состояния.
   Architect: якорь мутанта — на поведение, не на сигнатуру.

## Советы (не блокируют)

- С1. «Read-only» снимок не read-only на мультистейтменте: `SELECT 1; COMMIT; INSERT …` и `SELECT 1; END; DROP TABLE …` реально пишут
  в БД (ro.js: DB CHANGED, adv_victim удалена). Evidence при этом NOT_RUN с причиной-TypeError. Через `SELECT pg_terminate_backend(…)` снимок
  убивает чужую сессию и пишет MEASURED. Текст снимка задаёт сам вызывающий, поэтому это совет. Нужен extended-протокол (без нескольких команд)
  либо отказ при `;` внутри, а комментарий надо привести к правде. M10/M11/M12 батарея не судит (ниже).
- С2. (орк. п. б) Lane: убранная hash-object-сверка. assume-unchanged и skip-worktree прячут подмену probe.py от `git status --porcelain` → lane PASS,
  стаб в evidence. `git tag -f frozen/contracts/109/1` на коммит со стабом → PASS: этот обход прошёл бы и мимо прежней hash-object-сверки
  (блоб берётся из того же перевешенного тега). Отношение к A2/С3 круга 2: тот обход — случайно грязное дерево, он закрыт. Остаток требует
  умышленной манипуляции индексом/тегом в checkout, которым владеет сам запускающий. CI клонирует свежо (`ci.yml:164-169`), туда эти
  состояния не попадают. Поэтому совет, не блокер. Закрытие всех трёх: сверять `git rev-parse HEAD` с ЗАШИТЫМ коммитом (`b91be196…`, он уже
  назван в комментарии `run_backend_ci.py:217`) и `git hash-object probe.py` с `git rev-parse <sha>:<path>`.
- С3. Скраббер: значения без `=` в cookie/set-cookie, `Authorization: Basic`, `proxy-authorization`, `x-api-key`, `Cookie:`/`Authorization:`
  текстом в теле, JSON-массив cookie в теле-строке, телефоны РФ без `+` уходят в sink (pii.js, struct.js, struct3.js). На круге 2 это было советом,
  тут без изменений. Регистр ключей, вложенные массивы и экранированные формы — чисто.
- С4. F3′-остаток: при NOT_RUN БД `runtime_role` = заявление вызывающего под `mode: RUNTIME`. `db_snapshot` честно NOT_RUN. M15 показывает,
  что батарея на эту ось при NOT_RUN не смотрит.
- С5. A1 открыт: `inputHashes({a:{x:1},b:{y:2}})` → оба `b28c94b2…` (`a1.js`).
- С6. Email-паттерн квадратичный: тело из 160 000 символов без `@` обрабатывается 29,5 с.
- С7. (орк. п. а) Подгонка под якоря ухудшила предмет в двух местах (блокер 2; мёртвый фолбэк `mode: rec.mode || 'RUNTIME'`), в остальном она
  косметическая (комментарии-ссылки на батарею; порядок функций «writeEvidence последним перед module.exports» под хвостовой якорь M5). Батарея
  остаётся привязанной к форме: клетки — это мутанты по точным подстрокам, и при отсутствии якоря `need()` → None → rc 2. Любой рефакторинг
  предмета (переименование, перестановка функций) ломает батарею, а не ловит дефект. Факты при этом поведенческие (живые драйверы), и это
  хорошо. Обход формы назван в блокере 1 (якорь на вызов, а не на поведение функции).
- С8. (architect) Клетка с пропавшим якорем при зелёном контроле → BLOCKED_BY_RED_CONTROL, rc 0 (M15). По контракту стр. 95 нужен rc 2 (NOOP_MUTATION).
- С9. (architect) M10 (без READ ONLY) выживает: снимок по тексту батарея не судит на неизменность БД. Если read-only — заявленное свойство, нужна клетка.

## Уборка

    bash cleanup.sh → docker rm -f adv109r3pg; compose -p adv109r3 down -v → adv109r3 containers: 0, volumes: 0
    остаток stend109up*: a81a2598 (чужой, 3 ч, с круга 2) и 0297115e-postgres-1 (Created; мой ли — не установлено, не трогал)
    back: git status --porcelain → 0 строк (013 восстановлен); основной чекаут /home/harness/dev-harness не модифицировался, push не делался.
