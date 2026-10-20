FAIL
OBJECT=a9569176c428335eca5179f07cda39eb492ac1c2

Суд реализации 109 (CMP-BCK-004), круг 1. Reviewer: Rev109. Находки в reslop-формате — `review.md` рядом
(status: ready). Блокеров три: Б1, Б2, Б3. У каждого назван обход. Советов семь: С1–С7.
Контракт: frozen/contracts/109/1 → commit b91be196514191953d9c8dba19326021ecb0ba32. Клон h на этом теге
(`git rev-parse HEAD` = b91be19…). База B = 9d960a0543eb36696b1d767bf208416e774f0a32.

Место вердикта: по ограничению сессии оркестратора вердикт лежит в `/tmp/dev-harness-verify/Rev109/`.
Писать в основной репозиторий запрещено, поэтому коммит в `verdicts/review/` за оркестратором.

## Станция

    docker info --format '{{.ServerVersion}}'                → 28.3.3, rc 0
    node -v                                                    → v26.5.1
    docker run --rm --entrypoint sh postgres:18@sha256:74935e72… -c 'command -v node || echo NO_NODE; postgres --version'
                                                               → NO_NODE / postgres (PostgreSQL) 18.6, rc 0
    docker image inspect postgres:18@sha256:74935e72…        → Env PGDATA=/var/lib/postgresql/18/docker

Docker и PG18 на станции есть, значит строки 4–5 измеримы и измерены. Честного NOT_RUN здесь нет:
строки исполнены.

## Сырые прогоны

    git -C back diff --stat B HEAD          → 8 файлов, +610/−6, все в ЗОНА implementer
    npm --prefix backend ci                 → rc 0
    probe.py --repo back --out out-full     → rc 0; control_green=true; 5 фактов true; cases 29: 29 rejected_exact, 0 blocked, 0 not_rejected
    probe.py --repo back --matrix           → rc 0; 29 строк REJECTED_EXACT (счёт мой, по перечню имён)
    probe.py --repo back --case <имя> ×29   → rc 0 каждый (29 из 29)
    probe.py --repo back --case nonexistent → rc 2, «109 UNMEASURABLE: EMPTY_SELECTION»
    probe.py --repo bB (B + node_modules)   → rc 1; control_red = COMPOSE_MISSING, DRILL_MEASUREMENTS_ABSENT, HARNESS_INTEGRATION_TEST_MISSING, HARNESS_MISSING
    git -C h diff --quiet frozen/contracts/109/1 HEAD -- fixtures/workshop_project/stend_109 contracts/109-… → rc 0
    npm --prefix backend run -s lint        → rc 0 (Prettier ok)
    npm --prefix backend test               → 63/63, rc 0
    COMPLIOR_STEND109_H_CHECKOUT=h python3 tools/run_backend_ci.py --lane stend109 → [stend109] PASS rc=0, итог rc 0
    aggregate без stend109                  → rc 1 «нет обязательных lanes: stend109»; со всеми 7 success → rc 0

Строка 4 (Б1):

    docker compose -p rev109 -f backend/compose.dev.yml up -d --wait migrator
        → «dependency failed to start: container rev109-postgres-1 exited (1)», rc 1
        logs postgres: «Error: in 18+, these Docker images are configured to store database data in a … /var/lib/postgresql/data (unused mount/volume)»
    (одноразовая копия dgen: путь тома исправлен на /var/lib/postgresql, больше ничего)
    docker compose -p rev109d -f backend/compose.dev.yml up -d --wait migrator
        → «container rev109d-migrator-1 exited (127)», rc 1; logs: «exec: node: not found»

Строка 4, проба egress (С1):

    … run --rm --no-deps document-worker wget -S --spider -T 10 http://example.com → rc 1, «Cannot find module '/app/wget'» (проба ничего не измеряет)
    … run --rm --no-deps --entrypoint wget document-worker …                        → rc 1, «"wget": executable file not found»
    … run --rm --no-deps --entrypoint node document-worker -e "fetch('http://example.com')…" → «ERR EAI_AGAIN», rc 3
    docker run --rm --entrypoint node complior-back:dev -e "fetch(…)" (default-сеть, контроль) → «HTTP 200»

Строка 5 (Б2):

    docker run -d --name rev109pg -p 127.0.0.1:55432:5432 … postgres:18@sha256:74935e72…
    COMPLIOR_TEST_PG_ADMIN_URL=postgres://…@127.0.0.1:55432/postgres npm --prefix backend run test:integration
        → tests 21, pass 21, fail 0, rc 0
    env -u COMPLIOR_TEST_PG_ADMIN_URL npm --prefix backend run test:integration → rc 1 (тесты 129: «COMPLIOR_TEST_PG_ADMIN_URL не задан»)
    docker stop rev109pg; node --test tests/integration/harness.test.js → tests 3, pass 3, rc 0 (БД остановлена)
    grep captureBeforeAfter|node:http|fetch(|net.connect по backend/ → в harness.js и harness.test.js нет ни HTTP, ни TCP; у captureBeforeAfter 0 вызовов

Производные (Б3), чистый клон C (dgen):

    python3 tools/verify_handoff.py   → AssertionError: evidence/ux175/20261020T013957.891448Z/results.json, rc 1
    python3 tools/generate_derived.py → rc 0, «Handoff hashes rebuilt: 619 files»; git diff --stat: FILES.sha256 | 2 -- (удалены 2 строки)
    git ls-files evidence/ux175       → только 20261015T204312.317783Z/results.json

## Семь пунктов роли

1. Область: в зоне, ПЕРЕСЕЧЕНИЯ соблюдены (детали в review.md). OK.
2. Сырой вывод: автор показал вывод пробы. Живые строки 4–5 автор не исполнял, хотя docker на станции есть.
   Я их исполнил: строка 4 → rc 1 (Б1).
3. Проверки под код не переписаны: frozen-блобы батареи и контракта не изменены (rc 0). Тесты 126/129 не тронуты. OK.
4. Красное: на B проба rc 1 с 4 причинами. OK. Красного прогона для `harness.test.js` нет: он зелен
   при остановленной БД (Б2).
5. Атомарность: один коммит 109. OK.
6. Нормы не тронуты (нормативных файлов в диффе нет). OK.
7. Заявленное ≠ сделанному: «FILES.sha256 пересобран» опровергнуто (Б3). «29 кейсов, 5 фактов» подтверждено моей мерой.

## ПРОВОДКА (038)

Guard `fixtures/workshop_project/stend_109/probe.py` подключён по ПРОВОДКА-ЭНФОРСМЕНТ. Lane `stend109` в
`tools/run_backend_ci.py` исполняет именно эту батарею (`--repo ROOT`), job `stend109` в `ci.yml` клонирует
a3ka/dev-harness на `frozen/contracts/109/1` и стоит в `needs` агрегата `required`. Канал существует, подключён,
барьер именно этого предмета. Строку 4 lane не исполняет, и это по контракту, но поэтому Б1 в CI не всплывёт.

## Паразитная сложность (050): пять ответов на артефакт

- `backend/compose.dev.yml`: (1) инварианты 1–2, строка 4. (2) Состояние — том `pgdata`, сети; явное. (3) 1 файл. (4) Интерфейс — одна команда up; работа есть, но не исполняется (Б1). (5) Потребители — строка 4 и батарея. ESSENTIAL, но сломан.
- `backend/tests/helpers/harness.js` → `recordInteraction`: (1) инварианты 3–4. (2) Модульный `seq` и env `COMPLIOR_HARNESS_RUN_TAG`; явные. (3) 1. (4) Мелкий: интерфейс шире работы, HTTP/SQL переложены на вызывающего (Б2). (5) Потребители — батарея и тест. ESSENTIAL.
- `harness.js` → `captureBeforeAfter`, env `COMPLIOR_HARNESS_DATABASE_URL`: (1) формально инвариант 5, но вызовов нет. (2) Соединение с БД — скрытое. (3) Дублирует запись файла: при правке имени/`wx` менять 2 места. (4) Мелкий. (5) Потребителя нет. ACCIDENTAL (С5). Не блокирует: проще — один путь записи.
- `harness.js` → `STATUS_LABELS` с `'MOCK_SUCCESS'`: (1) ни одно. (2) Нет. (3) 1. (4) — . (5) Потребителя нет. ACCIDENTAL (С4).
- `backend/tests/integration/harness.test.js`: (1) строка 5, кейс `HARNESS_INTEGRATION_TEST_MISSING`. (2) tmpdir; явно. (3) 1. (4) — . (5) test:integration. ESSENTIAL по наличию, по содержанию не покрывает строку 5 (Б2).
- `backend/scripts/drill-measure.js` + `scripts['drill:evidence']`: (1) инвариант 6. (2) `DIR/drill-evidence.json`, перезапись; явно в stdout. (3) 2 (скрипт и package.json). (4) Нормально. (5) Потребители — DRILL_EVIDENCE_GUARD и CMP-BCK-089. ESSENTIAL (С6 — совет).
- lane `stend109` + `Run.stend109_probe` + env `COMPLIOR_STEND109_H_CHECKOUT`/`STEND109_TAG`: (1) ПРОВОДКА-ЭНФОРСМЕНТ. (2) Temp-клон H; явно. (3) 2 (run_backend_ci.py и ci.yml держат тег порознь, но это предписано). (4) Нормально. (5) Потребители — job CI и агрегат. ESSENTIAL.
- env `COMPLIOR_STEND109_H_TAG`, передаваемый пробе: (1) ни одно. (5) Потребителя нет (`probe.py` его не читает). ACCIDENTAL (С2).
- job `stend109` в `ci.yml`: (1) ПРОВОДКА-ЭНФОРСМЕНТ. (2) `$RUNNER_TEMP/h`; явно. (3) 1. (5) `required.needs`. ESSENTIAL.

## Н-363, Н-39, Н-351

Н-363: реализация не копирует модель (`/tmp/dev-harness-verify/Architect109/modelC`): sha256 всех трёх файлов различаются,
115/168/125 строк против 35/66/44. Н-39: стабы привязаны в коде батареи, реализация их не трогает. Н-351: мои оракулы
независимы от автора: живой docker compose up, node fetch с контролем default-сети, verify_handoff на чистом клоне,
остановка PG.

## Что нужно для accept

Б1: том PG18 на `/var/lib/postgresql`; migrator на образе с node (например `complior-back:dev`/build); LOGIN-роль API,
создаваемая шагом стенда без DDL-прав. После этого показать строку 4 живьём: up rc 0, ledger = 14, повтор, повреждённая копия → rc 1.
Б2: harness делает реальный TCP-запрос к поднятому handler, снимает SQL до/после вокруг него, честно пишет NOT_RUN без БД.
Тест строки 5 проверяет role/context isolation и отсутствие DDL-учёток у API и красен при остановленной БД.
Б3: пересобрать `FILES.sha256` на чистом клоне; verify_handoff → rc 0.
