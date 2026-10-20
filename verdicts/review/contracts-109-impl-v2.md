FAIL
OBJECT=d1cece2834425d5644522eb5c3e4648eeede7cb3

Суд реализации 109 (CMP-BCK-004), круг 2. Reviewer: Rev109r2. Находки в формате reslop лежат в `review.md`
рядом (status: ready). Блокер один — Б2′, обход назван и измерен. Советы: С1, С5′, С6′, С7–С12.
Закрыто с круга 1: Б1, Б3, С2, С3, С4 и С5 в прежней форме.
Контракт: frozen/contracts/109/1 → b91be196514191953d9c8dba19326021ecb0ba32. Батарея: wip/109/architect @ 4fe53c495.
База B = 9d960a05. Все копии лежат под /tmp/dev-harness-verify/Rev109r2/: back = cp -a клона Impl109,
cC = чистый git clone C, bB = B + node_modules, hw/hf = git archive wip/frozen, hclone = shallow clone H на frozen-теге.

## Неизменность замороженного (ПРИЁМКА-СУДЬИ v2)

    git -C H diff --stat frozen/contracts/109/1^{commit} wip/109/architect -- contracts/109-cmp-bck-004-stend-evidence.md → пусто, rc 0
    git -C H diff --stat frozen/contracts/109/1^{commit} HEAD -- contracts/109-cmp-bck-004-stend-evidence.md             → пусто, rc 0
    git -C H diff frozen…wip -- fixtures/workshop_project/stend_109/probe.py → +668/−4. Удалённые строки:
      (а) mut_scrubber_identity — тот же return, переписан в if/return;
      (б) run_case для фактов — раньше check_facts(...)[target], теперь FACT_FUNCS[target]. Это та же функция цели.
          Добавлен BLOCKED, если цель красна на базе. 29 прежних кейсов сохранены, добавлено 8.
    Критерий не ослаблен. Батарея строже frozen (29 → 37 клеток, 5 → 10 фактов).

## Область правки

    python3 zone.py (git diff --name-only 9d960a05 HEAD против ЗОНА implementer из frozen-блоба, дословно)
      → paths 9: ci.yml, FILES.sha256, compose.dev.yml, package.json, scripts/drill-measure.js,
        scripts/role-bootstrap.js, tests/helpers/harness.js, tests/integration/harness.test.js, tools/run_backend_ci.py
      → outside_zone [] ; rc_untouched 0 (health.test.js, integration/migrations, infra, db, server, evidence,
        tests/run_sql_3_9_native.py, helpers/pg18.js не тронуты)
    ПЕРЕСЕЧЕНИЯ соблюдены. package.json: +`drill:evidence`, ничего не удалено. ci.yml: +job stend109
    и +stend109 в required.needs. run_backend_ci.py: +lane, LOCAL_ORDER, метод.
    Коммиты: a956917 / 9282c51 / d1cece2. Автор у всех implementer@dev-harness.local, во всех ссылка на 109.

## Сырые прогоны

Батарея (строки 1–3; счёт мой — count.py по raw.json и по литералу CASES):

    PY hw/…/probe.py --repo back --out out-wip     → rc 0; control_green=true; 10 фактов true; cases 37: 37 REJECTED_EXACT, depends==[target] 37
      STEND_UP_GUARD: «up -d --wait rc=0 | ledger='14' | повтор rc=0 ledger='14'»; FILES_SHA256_GUARD: «620 строк … сходится»
    PY hf/…/probe.py --repo back --out out-frozen  → rc 0; control_green=true; 5 фактов true; 29/29 REJECTED_EXACT, depends==[target] 29
    count.py: hw CASES literal entries 37; hf 29
    PY hf/…/probe.py --repo bB (B)                 → rc 1; control_red = COMPOSE_MISSING, DRILL_MEASUREMENTS_ABSENT,
      HARNESS_INTEGRATION_TEST_MISSING, HARNESS_MISSING; blocked TEST_INTEGRATION_NOT_WIRED; 1 rejected_exact, 28 blocked

Строка 4 (row4.sh, проект rev109r2, down -v):

    up -d --wait                         → rc_up1=0; migrator exited 0, role-bootstrap exited 0, api/document-worker/sandbox/postgres running
    migrator logs                        → «migrations: применено 14, в журнале 14»
    порядок                              → migrator finished 03:38:21.853; role-bootstrap 03:38:22.309; api started 03:38:22.847
    SELECT count(*) control.schema_migration → 14 ; md5 ledger 785c3adc0b7e873ff206c2771377d48e
    api → GET /health/ready (изнутри)    → HTTP 200 {"status":"ready","schema_version":14}
    роли                                 → brokeros_api|f|f|f|f ; hc_synthetic_only|t|f|f|f
    up #2                                → rc_up2=0; ledger 14; md5 785c3adc… (тот же); marker 'keep-me' сохранён
    run --rm --no-deps document-worker wget … (форма контракта) → rc 1, «Node.js v24.22.0» (wget нет — С1)
    … --entrypoint node document-worker fetch(example.com)       → ERR EAI_AGAIN, rc 3
    контроль: docker run complior-back:dev fetch (default bridge) → HTTP 200, rc 0
    host curl 127.0.0.1:8080/health/ready → rc 7 (порт не опубликован: только internal-сети — С10)
    повреждённая копия (printf x >> db/013_*.sql, проект rev109r2dmg) → rc_up_dmg=1; «SHA256 013_… не совпадает с манифестом»;
      migrator exited 1, api created, api_running=0
    свежий клон без backend/node_modules (проект rev109r2nonm) → rc_up_nonm=1, «service "migrator" didn't complete successfully: exit 1» (С9)

Строка 5 (row5.sh, одноразовый PG18 rev109r2pg на 127.0.0.1:55433):

    npm --prefix backend ci                 → rc 0
    test:integration #1                     → rc 0; tests 27, pass 27, fail 0
    test:integration #2                     → rc 0; pass 27; дерево evidence/ неизменно (sha256 списка файлов до = после)
    БД остановлена: test:integration        → rc 1; pass 8, fail 20
    БД остановлена: harness.test.js         → rc 1; pass 8, fail 1 (role isolation: ECONNREFUSED); остальные 8 тестов harness от БД не зависят

Обход Б2′ (mutant.py + mutrun.sh; дерево mut = C, в котором recordInteractionAsync не делает I/O):

    grep в mut harness.js                   → dbBefore/dbAfter = константы «connect ECONNREFUSED (constant, no I/O)»,
                                              httpResponse = {status:200, body:'{"ok":true}'}; вызовов captureSql/sendHttpRequest 0 (остались только 2 определения)
    PY hf/…/probe.py --repo mut             → rc 0, 29/29 REJECTED_EXACT
    PY hw/…/probe.py --repo mut             → rc 0, 37/37 REJECTED_EXACT
    test:integration на PG18 (rev109r2pgm)  → rc 0, tests 27, pass 27, fail 0

Регресс лейнов и агрегата:

    cC: python3 tools/verify_handoff.py     → PASS_STATIC, all_manifest_files_and_hashes PASS, rc 0 (B: rc 0)
    cC: COMPLIOR_STEND109_H_CHECKOUT=hclone run_backend_ci.py --local → rc 1. Всё PASS, кроме двух строк:
        [backend] check:node «Node v26.5.1 не совпадает с 24.22.0» и [package] validate_invitation_target «No module named 'pypdf'».
        На B то же самое: check:node rc 1, pypdf rc 1. Пути не тронуты (git diff --quiet rc 0). Причина — окружение станции, не регресс.
        [postgres] test:integration PASS; [package] generate_derived = закоммиченным PASS, verify_handoff PASS; [stend109] PASS rc 0.
    lane stend109, H на wip-коммите        → rc 1 «HEAD=4fe53c49… не совпадает с коммитом тега … b91be196…» (С3 закрыт)
    --aggregate: 7 success → rc 0; без stend109 → rc 1 «нет обязательных lanes: stend109»; stend109 failure → rc 1
    ci.yml required.needs = backend, postgres, checks, image, package, historical, stend109
    npm --prefix backend run -s lint → rc 0; npm --prefix backend test → rc 0

## Блокер

**Б2′** (подробности в review.md). §Предмет: «harness связывает реальный TCP HTTP request/response
реализованного handler с SQL-снимками до/после…». В C этого нет по трём причинам:
- в async-пути `sql_before`/`sql_after` — эхо входа (`harness.js:277-278`);
- «снимок» = `SELECT current_user` (`:123`), а у исторического `server/test/harness.ts:77-90` снимок — строки таблиц вокруг fetch;
- тест бьёт в собственный эхо-сервер (`harness.test.js:178`), не в `backend/server`, и требует `db_snapshot NOT_RUN` (`:208`).

ОБХОД: дерево `mut` без всякого I/O проходит строки 1–3 (обе батареи) и строку 5 (27/27). Строка 4 от harness
не зависит. Батарея зелёная на пустом предмете.

## Семь пунктов роли

1. Область правки: 9 путей, все в зоне. ПЕРЕСЕЧЕНИЯ соблюдены. OK.
2. Сырой вывод: все строки 1–5 и регресс исполнены мной (выше). Доклад implementer не использован.
3. Проверки не переписаны под код: текст контракта совпадает с frozen. Батарея меняется только в зоне architect
   и только строже. Тесты 126/129 не тронуты. OK.
4. Красное: батарея на B даёт rc 1 с 4 причинами; повреждённая копия — rc 1; БД остановлена — rc 1. Красного
   для «harness без I/O» нет: мутант зелёный (Б2′).
5. Атомарность: три коммита одной задачи 109, у каждого ссылка на предмет. OK.
6. Нормы не тронуты: нормативных файлов в диффе нет. OK.
7. Заявленное и сделанное: «37/37, 10 фактов» и «29/29, 5 фактов» подтверждены моим счётом
   (count.py по raw.json и по литералу CASES). Б3 «FILES.sha256 синхронизирован» подтверждён verify_handoff
   на чистом клоне. Заявление «связывает реальный TCP HTTP с SQL-снимками» (шапка harness.js) не подтверждено (Б2′).

## ПРОВОДКА (038)

guard `fixtures/workshop_project/stend_109/probe.py`. Lane `stend109` исполняет именно эту батарею
(`--repo ROOT`) из H на frozen-теге и проверяет HEAD тега. Job `stend109` в ci.yml стоит в `required.needs`.
Канал существует, подключён, барьер этого предмета. Ограничение: CI держит frozen-батарею (29/5).
Усиленные факты wip в CI не попадают (С11).

## Паразитная сложность (050): пять ответов на каждый артефакт

- `backend/compose.dev.yml` (раздут: +role-bootstrap, migrator на node-образе): (1) инварианты 1–2, строка 4. (2) Том pgdata, internal-сети;
  неявная зависимость — хостовый backend/node_modules (С9). (3) 2 файла (compose + role-bootstrap.js). (4) Одна команда; работа реальна,
  строка 4 зелёная. (5) Строка 4, STEND_UP_GUARD. ESSENTIAL; мёртвые `ports` (С10) — ACCIDENTAL-совет.
- `backend/scripts/role-bootstrap.js` (новый): (1) строка 4 требует LOGIN-роль API без DDL. (2) Роль в БД; явно в stdout. (3) Логика
  `CREATE ROLE … IN ROLE brokeros_api` живёт ещё в pg18.js и harness.test.js — 3 места. (4) Интерфейс из 3 env на 1 SQL — нормально.
  (5) Сервис role-bootstrap. ESSENTIAL.
- `harness.js` → `recordInteractionAsync` / `sendHttpRequest` / `captureSql` и env `COMPLIOR_HARNESS_DATABASE_URL`, `_HTTP_HOST`, `_HTTP_PORT`, `DATABASE_URL`:
  (1) §Предмет, инвариант 3. (2) Соединение pg и HTTP — скрытое состояние за env, в аргументах его не видно. (3) Блок записи дублирован
  с sync-путём (С5′): 2 места. (4) Мелкий: 4 читаемых env и 2 точки входа, а работа — current_user и эхо осей (Б2′). (5) Потребитель — один тест
  на эхо-сервере. ESSENTIAL по свойству, но свойство не исполнено (Б2′).
- `harness.js` → sync `recordInteraction`: (1) инвариант 3/Ц (имя названо контрактом). (2) Модульный seq, `COMPLIOR_HARNESS_RUN_TAG`.
  (3) См. С5′. (4) Константные dbBefore/dbAfter — мёртвые ветви. (5) Батарея, тест. ESSENTIAL; мёртвые ветви — ACCIDENTAL-совет.
- `harness.js` → `SCRUBBER_PATTERNS`, `scrubRecord`: (1) инвариант 4 (F4 круга 1). (2) Нет. (3) 1. (4) Нормально. (5) HARNESS_PII_GUARD, тест. ESSENTIAL.
- `harness.test.js` (раздут): (1) строка 5. (2) tmpdir; env HTTP не восстанавливается (С12). (3) `roleIsolationDb` дублирует pg18.js:32-62 —
  при правке подготовки PG менять 2 файла, дифф число увеличил (С8). (4) — . (5) test:integration. ESSENTIAL по наличию; дубль — ACCIDENTAL (С8).
- `drill-measure.js` (раздут): (1) инвариант 6. (2) DIR/drill-evidence.json, теперь `wx`; явно в stdout/rc. (3) 2 (скрипт + package.json).
  (4) CLI из 2 флагов — нормально. (5) DRILL_EVIDENCE_GUARD, DRILL_INPUT_GUARD. ESSENTIAL (С6′ — совет).
- `run_backend_ci.py` → `stend109_probe` (раздут ~30 → ~90 строк) и env `COMPLIOR_STEND109_H_CHECKOUT`, `STEND109_TAG`: (1) ПРОВОДКА-ЭНФОРСМЕНТ
  и С3. (2) Temp-клон H; явно. (3) Тег держат 2 места (ci.yml, run_backend_ci.py) — так предписано. (4) Ветка fetch-fallback нужна только
  для checkout без тега; в CI тег есть (проверено shallow-клоном). (5) Job stend109 + required. ESSENTIAL.
- job `stend109` в ci.yml: (1) ПРОВОДКА. (2) $RUNNER_TEMP/h. (3) 1. (5) required.needs. ESSENTIAL.

## Что нужно для accept

Закрыть Б2′. В async-пути harness оси `sql_before`/`sql_after` должны браться из измеренных снимков
состояния до и после запроса. Тест строки 5 поднимает `backend/server` (`start()`) на `migratedDatabase()`
и пишет через harness запись реального handler с MEASURED-снимками и `runtime_role` из БД. Нужен предъявленный
прогон, где дерево «без I/O» (mutant.py) красное. Советы не блокируют.

Чистка: контейнеров и томов `rev109r2*` после прогона 0 (`docker ps -a` / `docker volume ls` → 0). Чужие проекты не трогались.
