FAIL
OBJECT=a9569176c428335eca5179f07cda39eb492ac1c2

# Adversary (Adv109) — суд по реализации контракта 109 (CMP-BCK-004), круг 1

Предмет: `cmp-bck-004/stend` @ a9569176c428335eca5179f07cda39eb492ac1c2 (клон `/tmp/dev-harness-verify/Adv109/back`),
база B = 9d960a0543eb36696b1d767bf208416e774f0a32. Harness: frozen/contracts/109/1 → commit b91be196514191953d9c8dba19326021ecb0ba32
(клон `/tmp/dev-harness-verify/Adv109/h`). Станция: docker 28.3.3, node v26.5.1, образ `postgres@sha256:74935e72…` локально есть.

Итог: батарея зелёная, но ЖИВАЯ строка 4 на станции с docker — **rc 1** (стенд не поднимается одной командой);
драйл-коллектор пишет `MEASURED` без измерений и затирает прежний evidence; harness без TCP/SQL-связки пишет
`RUNTIME` на фикстуру и при упавшей БД, скраббер пропускает необъявленные токены/PII; `FILES.sha256` ссылается на файлы
вне коммита → `verify_handoff` rc 1 на чистом C (на B rc 0). Каждое — состояние «критерий батареи выполнен, предмет не сделан».

## Что зелёное (позитивный контроль) — сырые команды

```
$ python3 ../h/fixtures/workshop_project/stend_109/probe.py --repo . --out …/probe-out     (cwd back/)
control_green: true, 5 фактов true, cases: 29 (29 rejected_exact, 0 blocked, 0 not_rejected)   RC=0
$ … probe.py --repo . --matrix | grep -c REJECTED_EXACT    → 29, RC_MATRIX=0
$ … probe.py --repo . --case nonexistent                   → 109 UNMEASURABLE: EMPTY_SELECTION, RC=2
$ … --case harness_sink_decoy / drill_dead_file / compose_egress_unused_net / harness_scrubber_identity → RC=0 каждый
$ COMPLIOR_STEND109_H_CHECKOUT=…/h python3 tools/run_backend_ci.py --lane stend109 → [stend109] PASS rc=0, RC_LANE_REAL=0
$ git diff --stat B HEAD -- db server infra evidence/runs tests/run_sql_3_9_native.py VALIDATION.json → пусто (frozen не тронуты)
$ COMPLIOR_TEST_PG_ADMIN_URL=postgres://postgres:…@127.0.0.1:55109/postgres npm run -s test:integration (одноразовый PG18 по digest пина)
  → tests 21, pass 21, fail 0, RC_LINE5=0
```
Зона: 8 изменённых файлов (ci.yml, FILES.sha256, backend/compose.dev.yml, backend/package.json, backend/scripts/drill-measure.js,
backend/tests/helpers/harness.js, backend/tests/integration/harness.test.js, tools/run_backend_ci.py) — все в `ЗОНА implementer`.
Н-363: sha256 трёх файлов предмета (2b18297b…, 35af588f…, f6edc6c8…) не совпадает ни с одним файлом моделей
`/tmp/dev-harness-verify/Architect109/**` (побайтовой копии нет).

## Блокирующие находки (с названным обходом)

### F1. Живая строка 4: стенд НЕ поднимается одной командой (docker на станции ЕСТЬ — NOT_RUN был бы ложным)
```
$ timeout 600 docker compose -p adv109stend -f backend/compose.dev.yml up -d --wait
 Container adv109stend-postgres-1  Error
dependency failed to start: container adv109stend-postgres-1 exited (1)          RC=1
$ docker logs adv109stend-postgres-1
 … there appears to be PostgreSQL data in: /var/lib/postgresql/data (unused mount/volume) …
   The suggested container configuration for 18+ is to place a single mount at /var/lib/postgresql
```
Образ пина: `PGDATA=/var/lib/postgresql/18/docker`; compose монтирует `pgdata:/var/lib/postgresql/data` → PG18 отказывается стартовать.
Диагностика в одноразовой копии `diag/` (том исправлен на `/var/lib/postgresql`, предмет не тронут):
```
$ docker compose -p adv109diag -f backend/compose.dev.yml up -d --wait
 service "migrator" didn't complete successfully: exit 127                        RC=1
$ docker logs adv109diag-migrator-1 → /usr/local/bin/docker-entrypoint.sh: line 384: exec: node: not found
$ docker run --rm --entrypoint sh <postgres-пин> -c 'command -v node || echo NO_NODE' → NO_NODE
```
Сервис `migrator` — образ `postgres:18` с `command: ["node","infra/migrations/run.js"]`: node в образе нет. Далее (не достигнуто
вживую, [INFERENCE] по коду): `api`/`document-worker`/`sandbox` логинятся `hc_synthetic_only:synthetic`, а миграции `db/001–014`
создают только NOLOGIN-роли (grep `CREATE ROLE` в db/ — все NOLOGIN; `hc_synthetic_only` нигде не создаётся) → api не подключится к БД.
ОБХОД: батарея (compose-структура + `docker compose config`) зелёная, а «одна команда → migrator rc0 → API, ledger=14» невыполнима.

### F2. Drill-коллектор «зелёный» без измерений и перезаписывает прежний evidence
```
$ npm run -s drill:evidence -- --out atk/d1 --input empty.json
  (вход: db_dump="", …, measured_rpo_minutes=null, measured_rto_minutes=null, measured_at=null)
drill evidence → …/d1/drill-evidence.json status=MEASURED        rc=0
  "status": "MEASURED", "db_hash": "e3b0c442…(sha256 пустой строки)", "measured_rpo_minutes": null, "measured_rto_minutes": null, "measured_at": null
$ … --input str.json (measured_rpo_minutes:"ok", measured_rto_minutes:"fine", measured_at:"never") → status MEASURED, rc=0
$ … --out atk/d2 --input real.json → MEASURED; sha256 09cc6f73…
$ … --out atk/d2 (без входа)       → NOT_RUN;  sha256 7d1ffdf6…;  ls d2 → drill-evidence.json;  grep -c MEASURED → 0
```
Проверка входа — только `!== undefined`; запись — `fs.writeFileSync` (не `wx`). ОБХОДЫ: «drill MEASURED без измерений»,
«перезапись старого evidence» (измеренный drill молча заменён NOT_RUN).

### F3. Harness пишет режим RUNTIME на фикстуру и при остановленной БД; без TCP/SQL-связки
`/tmp/dev-harness-verify/Adv109/harness_attack.js` (через `attack.sh`), `COMPLIOR_HARNESS_DATABASE_URL=postgres://x:y@127.0.0.1:1/z`:
```
H1 без mode + БД недоступна: threw= false
  …-000001-….json → mode= RUNTIME db_snapshot.status= NOT_RUN runtime_role= hc_fixture reason= connect ECONNREFUSED 127.0.0.1:1
H4 mode=MOCK_SUCCESS: threw= false → mode= MOCK_SUCCESS
H6 captureBeforeAfter.length = 2 (observation, dir) — HTTP-вызова между снимками нет
```
`captureBeforeAfter`: `mode: observation.mode || 'RUNTIME'` без проверки по `MODE_LABELS`; «снимки» before/after берутся подряд
(`SELECT current_user`) без запроса между ними; `sql_before/sql_after` — строки вызывающего. `recordInteraction` — эхо наблюдения,
ни HTTP, ни pg не трогает. `harness.test.js` не содержит ни TCP, ни pg: `node --test tests/integration/harness.test.js` без БД →
rc 0 (RC_HARNESS_ONLY_NO_DB=0); с БД — те же три теста. Требование строки 5 «harness-тест проверяет SQL role/context isolation и
отсутствие DDL-учёток у API» harness-тестом не выполняется (зелёная строка 5 держится на тестах 126/129 базы B).
ОБХОДЫ: «harness пишет режим RUNTIME на fixture», «БД остановлена → запись RUNTIME, функция успешна»,
«реальный TCP HTTP ↔ SQL до/после» — не сделано при зелёном `HARNESS_TUPLE_GUARD`.

### F4. Evidence с реальными секретами/PII: скраббер вычищает только явно перечисленное вызывающим
```
H2 утечка Bearer: true cookie: true email: true
   (authorization: 'Bearer eyJhbGciOiJIUzI1NiJ9.REAL.TOKEN', cookie: 'session=SECRETSESSION',
    body: 'patient ivan.petrov@clinic.ru, phone +7 916 000-00-00', secrets не переданы)
H5 секрет с кавычкой `tok"Q\Z`: в файле сырой= false, восстановим из JSON= true
```
`scrubSecrets` — только `split(secret).join('[REDACTED]')` по `observation.secrets`; паттернов токенов/PII нет; объявленный секрет,
меняющийся при JSON-экранировании, проходит в файл. ОБХОД: «evidence с реальными секретами/PII».

### F5. Регресс `checks`/required: FILES.sha256 пересобран на грязном дереве
```
$ (чистый клон C) python3 tools/verify_handoff.py
AssertionError: evidence/ux175/20261020T013957.891448Z/results.json            RC=1
$ (тот же клон на B) python3 tools/verify_handoff.py → {"status": "PASS_STATIC", …}   RC_B=0
$ git ls-tree -r HEAD --name-only evidence/ux175 → только 20261015T204312.317783Z/results.json
```
FILES.sha256 несёт две строки `evidence/ux175/20261020T01…` (неотслеживаемые файлы станции Impl109). Lane с `verify_handoff`
красен на CI → агрегат `required` красен; доклад «FILES.sha256 пересобран» не соответствует коммиту.

## Советы (не блокируют)

- A1. `inputHashes`: `sha256(String(v))` — для объектов и бинарных Buffer коллизия: `{doc:{id:1}}` и `{doc:{id:2}}` → одинаковый
  `b28c94b2…` (sha256 "[object Object]"); `Buffer[ff,fe]`/`Buffer[ff,fd]` → одинаковый хэш (H8/H8b true). Манифест входов не различает входы.
- A2. Lane `stend109` принимает любой `probe.py` по `COMPLIOR_STEND109_H_CHECKOUT` без сверки тега/коммита: заглушка `sys.exit(0)` →
  `[stend109] PASS rc=0` (RC_LANE_STUB=0). В CI переменная ставится клоном по тегу (`--branch`), не по sha; стоит сверять
  `git rev-parse HEAD` = b91be196….
- A3. (к architect) проба маршрута строки 4 `… document-worker wget …` вакуумна на этом образе: `wget` нет, node-entrypoint исполняет
  `node wget` → rc 1 при любом egress (RC_WGET=1, «инструмент мимо PATH»). Честная проба `node -e fetch('http://example.com')` →
  `ERR EAI_AGAIN`, rc 3 — egress реально закрыт (internal-сети).
- A4. [INFERENCE] api/postgres сидят только в `internal: true` сетях — опубликованные `127.0.0.1:8080`/`127.0.0.1:5432` с хоста
  недостижимы (docker не публикует порты internal-сетей); TCP-проба API с хоста стенда не пройдёт. Не измерено (стенд не поднялся, F1).
- A5. document-worker/sandbox делят логин API (`hc_synthetic_only`) — разделение идентичностей worker↔api отсутствует.

## Не дефект

- Строка 5 на одноразовом PG18 (пин digest) — rc 0, 21/21; без БД вся сюита rc 1 (тесты 126/129 требуют `COMPLIOR_TEST_PG_ADMIN_URL`) —
  мок-успеха на уровне сюиты нет.
- Egress worker/sandbox закрыт живьём (A3).
- Frozen-пути (db/, server/, infra/, evidence/runs/, tests/run_sql_3_9_native.py, VALIDATION.json) не изменены.

Артефакты атак: `/tmp/dev-harness-verify/Adv109/attack.sh`, `harness_attack.js`. Одноразовые клоны/стенды удалены
(`docker compose down -v`, контейнер `adv109pg` остановлен с `--rm`).
