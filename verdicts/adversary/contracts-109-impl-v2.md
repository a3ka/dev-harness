FAIL
OBJECT=d1cece2834425d5644522eb5c3e4648eeede7cb3

# Adversary Adv109r2 — суд реализации 109 (CMP-BCK-004), круг 2

Предмет: копия `cp -a /tmp/dev-harness-verify/Impl109/back` → `/tmp/dev-harness-verify/Adv109r2/back`, HEAD d1cece28
(a9569176 → 9282c516 → d1cece28). Батарея: `git archive wip/109/architect` (4fe53c495) → `Adv109r2/h`. Docker: проекты
`adv109r2`, `adv109r2m7`, `adv109r2m9` и `stend109up*` (их поднимает сама батарея). Все сняты `down -v`; проверка
`docker ps -a | grep -c adv109r2` → 0, `docker volume ls | grep -c adv109r2` → 0. Чужой `stend109upa81a2598-postgres-1` не трогался.
Находки в формате reslop — `review.md`.

## Позитивный контроль (батарея на честном предмете)

    python3 h/fixtures/workshop_project/stend_109/probe.py --repo back --out out/back
    → rc=0 control_green=True facts_not_green=[] rejected=37/37

Батарея на d1cece28 зелёная, вечно-красной она не является. Первый прогон (out_nonm/) дал rc 1, потому что backend/node_modules был пуст
после моего теста чистого клона (С1). STEND_UP_GUARD тогда честно красный, RUNNER_DAMAGE_GUARD — NEEDS_ENV.

## Живые строки (F1–F5) — что закрыто на деле

F1, строка 4 контракта, `docker compose -p adv109r2 -f backend/compose.dev.yml …`:

    up -d --wait                         → RC=0 (9.4 с); migrator exited 0, role-bootstrap exited 0, api/worker/sandbox running/healthy
    psql count(*) control.schema_migration → 14
    md5(ledger) до повтора                → 4f481806db074077b8ea3d1cddc0e420
    up -d --wait (повтор)                → RC2=0; md5(ledger) 4f481806db074077b8ea3d1cddc0e420; role-bootstrap «уже существует; пропуск»
    hc_synthetic_only: create table public.adv_ddl → ERROR permission denied for schema public (ddl_rc=1); rolsuper f; не член owner/gateway
    api: fetch http://example.com        → NOEGRESS EAI_AGAIN
    db/013 +1 байт, тёплый up            → RC_WARM=1, migrator exit 1, но api остаётся running (С3)
    db/013 +1 байт, down -v, холодный up → RC_COLD=1, «SHA256 013_… не совпадает с манифестом», api created (не Running)

F1 закрыт. Есть оговорки С1–С3.

F2, drill через точку входа поставки, `node drill.js back/backend`, внутри `npm run -s drill:evidence -- --out … --input …`:

    at_never     ({…, measured_at:"never"}) → rc=0 status=MEASURED at=never       ← БЛОКЕР F2'
    at_ok        ({…, measured_at:"ok"})    → rc=0 status=MEASURED at=ok          ← БЛОКЕР F2'
    negative     (rpo -5, rto -1)           → rc=0 status=MEASURED rpo=-5         (совет С5)
    dump_is_path (db_dump "/backups/db.dump") → db_hash = sha256 строки пути e0b0e657… (совет С5)

null и строковые measured_rpo/rto отвергаются (DRILL_INPUT_GUARD), append-only через wx и pre-check работает. Не-ISO `measured_at`
(«never»/«ok») — класс, который грамматика DRILL_INPUT_GUARD прямо называет, — принимается как MEASURED. F2 закрыт не полностью.

F3, honesty: battery HARNESS_HONESTY_GUARD зелёный. На реальном коде без mode / с MOCK_SUCCESS — throw на обеих ветках,
ECONNREFUSED → db_snapshot NOT_RUN. Связь «реальный HTTP между SQL-снимками» батарея не судит (мутанты M1–M5 ниже). Предмет при NOT_RUN БД пишет
`runtime_role` из заявления вызывающего: `pii.js` → `"runtime_role":"claimed_role","db":"NOT_RUN","mode":"RUNTIME"`.

F4, scrubber, живой путь `recordInteractionAsync` с реальным `http.createServer` (`node pii.js back/…/harness.js`):

    {"parsed":true,"leaks":["setcookie","multicookie","basic","phone_ru_plain","phone_ru_spaces","bearer_lower","apikey"],…}
      "cookie": "[REDACTED] session=MULTICOOKIESECRET",
      "set-cookie": [ "sid=SETCOOKIESECRET123; Path=/; HttpOnly"

Структура JSON после скраббинга, `node struct.js back/…/harness.js`, синхронный recordInteraction:

    body_set_cookie_text:        parse=FAIL Bad control character …       ("Set-Cookie: v" в теле съедает закрывающую кавычку)
    body_escaped_cookie_json:    parse=FAIL Expected ',' or '}' … leak=true ("{\"cookie\":[REDACTED]\"ESCCOOKIESECRET\"}")
    body_escaped_cookie_json_sp: parse=FAIL … leak=true
    header_cookie_array:         parse=FAIL Unexpected token 'R' … leak=true ("cookie": [REDACTED] / "ARRCOOKIESECRET")

Bearer (r5) починен: структура цела. Паттерны cookie/set-cookie ломают структуру тем же способом и пропускают сам секрет: set-cookie в
JSON-ключе не срабатывает никогда, cookie чистит лишь первое значение до пробела. F4 не закрыт.

F5: каждая строка FILES.sha256 сверена с `git show HEAD:<путь> | sha256sum` → расхождений нет. Каждый файл из диффа a9569176..HEAD
перечислен. `python3 tools/verify_handoff.py` → `{"status":"PASS_STATIC",…"all_manifest_files_and_hashes":"PASS"}`, RC=0. Закрыт.

Неизменность frozen-артефактов:

    git diff --stat frozen/contracts/109/1 wip/109/architect -- contracts/109-cmp-bck-004-stend-evidence.md → пусто, rc 0
    git diff --stat 9d960a05 d1cece28 -- db server/test/harness.ts server/src/app.ts evidence/runs infra/migrations tests/run_sql_3_9_native.py → пусто, rc 0

Строка 5 (native PG18, `npm run test:integration`) в этом круге не прогонялась. Прогнано только `node --test tests/integration/harness.test.js` без
COMPLIOR_TEST_PG_ADMIN_URL и с ним на 127.0.0.1:1 → RC=1 оба раза («harness isolation требовал БД»): честный rc≠0, не success.

## Мутанты НАСТОЯЩЕГО кода d1cece28 против батареи (`mk_mutants.py` + `run_all.sh`, каждый якорь заменён ровно 1 раз)

    M1_async_no_http        httpResponse = obs.http_response (реального HTTP нет)                → rc=0 control_green 37/37  ВЫЖИЛ
    M2_sql_const_notrun     captureSql: url = null (SQL-снимок всегда NOT_RUN)                   → rc=0 control_green 37/37  ВЫЖИЛ
    M3_http_after_snapshots HTTP после обоих SQL-снимков                                         → rc=0 control_green 37/37  ВЫЖИЛ
    M4_role_claimed         runtime_role: obs.runtime_role (не current_user)                     → rc=0 control_green 37/37  ВЫЖИЛ
    M5_async_no_scrub       async-ветка пишет JSON.stringify без scrubRecord                     → rc=0 control_green 37/37  ВЫЖИЛ
    M6_no_setcookie_pattern паттерн set-cookie удалён                                            → rc=0 control_green 37/37  ВЫЖИЛ
    M7_role_superuser       role-bootstrap: CREATE ROLE … SUPERUSER                              → rc=0 control_green 37/37  ВЫЖИЛ
    M8_api_superuser_url    api DATABASE_URL = postgres:ci-synthetic-only (суперпользователь)    → rc=0 control_green 37/37  ВЫЖИЛ
    M9_ledger_rewritten     migrator после run.js: UPDATE control.schema_migration SET applied_by → rc=0 control_green 37/37  ВЫЖИЛ

Мутанты действительно меняют поведение (не NOOP):
- M5: `pii.js` → утекает и `email_upper`.
- M1: `pii.js` → `http_response` отсутствует, реального HTTP нет.
- M7: живой up → `hc_synthetic_only|t` (rolsuper).
- M9: живой up → `count 14`, `applied_by` = md5-мусор, лог «ledger rewritten» 1.
- M8: подмена env DATABASE_URL в блоке api (она детерминирована).
- M6 на JSON-пути эквивалентен предмету: паттерн и так мёртв, это и есть доказательство F4'. На теле с текстом «Set-Cookie:» поведение отличается.

M7/M8 ловит строка 5 контракта (harness-тест проверяет role isolation), не батарея. M9 — строка 4 («данные и ledger неизменны»), её
STEND_UP_GUARD сверяет только count. Это советы architect (С7), не блокеры предмета.

## Lane stend109 (A2/С3 круга 1)

    git clone /home/harness/dev-harness hstub && git -C hstub checkout frozen/contracts/109/1
    probe.py := 'import sys; print("STUB probe: always green"); sys.exit(0)'   (git status: " M …/probe.py")
    COMPLIOR_STEND109_H_CHECKOUT=hstub python3 tools/run_backend_ci.py --lane stend109 --out lane_out
    → [stend109] PASS rc=0 … ; LANE_RC=0; lane_out/stend109/01.log содержит STUB

Сверка `HEAD == commit тега` не сверяет рабочее дерево. A2/С3 не закрыт.

## Блокеры (у каждого названный обход)

1. **F4' scrubber cookie/Set-Cookie.** Обход: дерево d1cece28 как есть. Батарея rc 0, 37/37, но живой HTTP-ответ с Set-Cookie уносит
   токен сессии в sink. Многозначный cookie уносит session. Экранированная cookie-форма уносит секрет и ломает JSON, который потребитель читает
   JSON.parse. Мутанты M5/M6 зелёные.
2. **F2' drill measured_at.** Обход: дерево d1cece28 как есть. Батарея зелёная, но `measured_at:"never"`/`"ok"` → MEASURED rc 0.
3. **A2/С3 lane.** Обход: checkout на теге с грязным `probe.py`=`sys.exit(0)` → lane PASS rc 0.
4. **F3' связь HTTP↔SQL↔role не наблюдается.** Обход: M1–M4 (HTTP не делается / SQL не меряется / порядок нарушен / роль заявлена).
   Батарея на каждом rc 0, 37/37. Инвариант 3 и «HTTP между снимками» предмета батареей не подтверждены. Предмет сам при NOT_RUN пишет
   заявленную `runtime_role` под mode RUNTIME. Правка за architect (батарея) и implementer (`runtime_role` из БД либо NOT_RUN-маркер).

## Советы (не блокируют)

- С1. Чистый клон без `npm ci`: `up -d --wait` → RC_NONM=1, migrator «Cannot find module» pg (хостовый bind `../backend/node_modules`,
  он в .gitignore). Docker создаёт пустой каталог. Стоит собрать migrator-образ с зависимостями или назвать `npm ci` в «Дано».
- С2. `127.0.0.1:5432`/`8080` не публикуются: `docker port` пуст, `curl 127.0.0.1:8080/health` rc 7. Внутри api `/health` → 404 JSON.
  По умолчанию sendHttpRequest (127.0.0.1:8080) API стенда с хоста недостижим.
- С3. Тёплый стенд + порча миграции: rc 1, старый api Running.
- С4. A1 открыт: `inputHashes({a:{x:1},b:{y:2}})` → оба b28c94b2195c….
- С5. drill: отрицательные RPO/RTO принимаются; dump-поля хэшируются как строки входа (путь вместо байтов дампа).
- С6. Lane по умолчанию клонирует frozen-тег (29 мутантов, без фактов круга 2), подпись «5 фактов + 29 кейсов». Закрытие F1–F5 в CI не стережётся.
- С7. (architect) STEND_UP_GUARD судит count, не содержимое ledger/данных (M9). Роль и DSN api батареей не судятся (M7/M8 — только строка 5).
